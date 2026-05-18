#!/usr/bin/env bash
# Unified Skills — SessionStart hook
# Injects a compact Boot Kernel into every new session context.
# Detects Codex vs Claude Code and adjusts hints accordingly.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

if [ ! -f "$plugin_root/AGENTS.md" ]; then
  exit 0
fi

# Detect platform: Codex sends permission_mode in stdin JSON, Claude Code does not
is_codex=0
stdin_data=""
cwd=""
if [ -t 0 ]; then
  # No stdin (interactive) — assume Claude Code
  is_codex=0
else
  stdin_data=$(cat)
  if printf '%s' "$stdin_data" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("permission_mode",""))' 2>/dev/null | grep -q .; then
    is_codex=1
  fi
  cwd=$(printf '%s' "$stdin_data" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("cwd",""))' 2>/dev/null || echo "")
fi
project_dir="${cwd:-${CLAUDE_PROJECT_DIR:-$plugin_root}}"

# Build command syntax hint based on platform
if [ "$is_codex" -eq 1 ]; then
  platform_hint='Codex 可在显式进入 Unified 工作流时直接读取 AGENTS.md、skills-router.json 与 skills/ 中的真实技能；不依赖 repo 内 $command 薄包装入口。'
else
  platform_hint='Claude Code 用 commands/ 作为显式 Unified 工作流入口；技能正文按需读取。'
fi

resume_hint=""
if [ -f "$plugin_root/scripts/unified-state.py" ]; then
  resume_output=$(python3 "$plugin_root/scripts/unified-state.py" format-resume "$project_dir" 2>/dev/null || true)
  if [ -n "$resume_output" ]; then
    resume_hint="
Active feature resume:
- $resume_output
- 这是恢复提示，不会自动激活 Unified runtime；继续前仍按用户命令或明确阶段入口执行。"
  fi
fi

full_message="Unified Skills Boot Kernel

Unified 可用。AGENTS.md 是项目入口合同；CANON.md 是行为宪法。

Default runtime:
- 普通 repo 问答、普通 coding 请求、未提 Unified 的直接任务，不自动激活 Unified runtime。
- 只有用户显式输入 /brainstorm /refine /design /plan /build /review /ship /save /restore /learn /help，或明确要求使用 Unified 工作流时，才进入 compact router + loading tier 流程。
- 激活后先用 skills-router.json 做轻量路由；只有 router 无法回答、需要完整库存、或进入 full 模式时，才读取 skills-index.json。

If editing Unified skills/contracts:
- 读完整技能和 CANON.md。
- 同步 skills-index.json / skills-lock.json，并运行 ./validate。
$resume_hint

$platform_hint

每次新 session 启动时，必须在首次回复的开头用一行显示加载提示：
⚡ Unified Skills 已加载 — 使用 /help 查看命令，或直接说需求开始工作。"

# Output in format compatible with both Claude Code and Codex
escaped=$(printf '%s' "$full_message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$escaped"
