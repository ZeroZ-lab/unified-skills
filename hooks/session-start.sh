#!/usr/bin/env bash
# Unified Skills — SessionStart hook
# Injects key CLAUDE.md sections into every new session context.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
claude_md="$plugin_root/CLAUDE.md"

if [ ! -f "$claude_md" ]; then
  exit 0
fi

# Extract the AI Agent section and command map
content=$(sed -n '/^## 如果你是一个 AI Agent/,/^## 宪法/p' "$claude_md" | head -n -1)

if [ -z "$content" ]; then
  # Fallback: extract first 50 lines
  content=$(head -50 "$claude_md")
fi

# Extract command map
cmd_map=$(sed -n '/^## 命令映射/,/^## 文档产出链/p' "$claude_md" | head -n -1)

full_message="Unified Skills 已加载。以下是你的行为约束和可用命令：

$content

$cmd_map

使用 /refine、/plan、/build、/review、/ship 调用工作流。用 /save 和 /restore 管理会话状态。"

# Output in Claude Code format
escaped=$(printf '%s' "$full_message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$escaped"
