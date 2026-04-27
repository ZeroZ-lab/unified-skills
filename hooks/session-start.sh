#!/usr/bin/env bash
# Unified Skills — SessionStart hook
# Injects key CLAUDE.md sections into every new session context.
# Detects Codex vs Claude Code and adjusts command syntax accordingly.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

if [ ! -f "$plugin_root/CLAUDE.md" ]; then
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

# Extract the AI Agent section and command map
content=$(sed -n '/^## 如果你是一个 AI Agent/,/^## 宪法/{ /^## 宪法/d; p }' "$plugin_root/CLAUDE.md")

if [ -z "$content" ]; then
  # Fallback: emit safe default message
  content="Unified Skills 已加载。使用 /help 查看可用命令。"
fi

# Extract command map
cmd_map=$(sed -n '/^## 命令映射/,/^## 文档产出链/{ /^## 文档产出链/d; p }' "$plugin_root/CLAUDE.md")

# Build command syntax hint based on platform
if [ "$is_codex" -eq 1 ]; then
  cmd_hint='使用 $refine、$plan、$build、$review、$ship 调用工作流。用 $save 和 $restore 理会话状态。'
else
  cmd_hint="使用 /refine、/plan、/build、/review、/ship 调用工作流。用 /save 和 /restore 理会话状态。"
fi

full_message="Unified Skills 已加载。以下是你的行为约束和可用命令：

$content

$cmd_map

$cmd_hint"

# Output in format compatible with both Claude Code and Codex
escaped=$(printf '%s' "$full_message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$escaped"