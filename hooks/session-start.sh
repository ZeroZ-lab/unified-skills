#!/usr/bin/env bash
# Unified Skills — SessionStart hook
# Injects key AGENTS.md sections into every new session context.
# Detects Codex vs Claude Code and adjusts hints accordingly.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

if [ ! -f "$plugin_root/AGENTS.md" ]; then
  exit 0
fi

# Detect platform: Codex sends permission_mode in stdin JSON, Claude Code does not
is_codex=0
stdin_data=""
if [ -t 0 ]; then
  # No stdin (interactive) — assume Claude Code
  is_codex=0
else
  stdin_data=$(cat)
  if printf '%s' "$stdin_data" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("permission_mode",""))' 2>/dev/null | grep -q .; then
    is_codex=1
  fi
fi

extract_section() {
  python3 - "$plugin_root/AGENTS.md" "$1" "$2" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
start_marker = sys.argv[2]
end_marker = sys.argv[3]

lines = path.read_text(encoding="utf-8").splitlines()
capturing = False
section = []

for line in lines:
    if line == start_marker:
        capturing = True
    if capturing:
        if line == end_marker:
            break
        section.append(line)

print("\n".join(section))
PY
}

# Extract the AI Agent section and command map. Use Python instead of sed so the
# hook behaves the same on BSD/macOS and GNU environments.
content=$(extract_section "## 如果你是一个 AI Agent" "## 宪法")

if [ -z "$content" ]; then
  # Fallback: emit safe default message
  content="Unified Skills 已加载。使用 /help 查看可用命令。"
fi

# Extract command map
cmd_map=$(extract_section "## 命令映射" "## 文档产出链")

# Build command syntax hint based on platform
if [ "$is_codex" -eq 1 ]; then
  cmd_hint='Codex 直接读取 AGENTS.md 与 skills/ 中的真实技能；不再依赖 repo 内 $command 薄包装入口。'
else
  cmd_hint="使用 /refine、/plan、/build、/review、/ship 调用工作流。用 /save 和 /restore 理会话状态。用 /goal 管理目标。"
fi

full_message="Unified Skills 已加载。以下是你的行为约束和可用命令：

$content

$cmd_map

$cmd_hint"

# Output in format compatible with both Claude Code and Codex
escaped=$(printf '%s' "$full_message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$escaped"
