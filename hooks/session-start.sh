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
if [ -t 0 ]; then
  # No stdin (interactive) — assume Claude Code
  is_codex=0
else
  stdin_data=$(cat)
  if printf '%s' "$stdin_data" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("permission_mode",""))' 2>/dev/null | grep -q .; then
    is_codex=1
  fi
fi

# Build command syntax hint based on platform
if [ "$is_codex" -eq 1 ]; then
  platform_hint='Codex 直接读取 AGENTS.md、skills-router.json 与 skills/ 中的真实技能；不依赖 repo 内 $command 薄包装入口。'
else
  platform_hint='Claude Code 使用 /refine、/design、/plan、/build、/review、/ship 进入阶段；技能正文按需读取。'
fi

full_message="Unified Skills Boot Kernel

Unified 已加载。AGENTS.md 是项目入口合同；CANON.md 是行为宪法。

Context Runtime:
- 先用 skills-router.json 做轻量路由，再按需读取完整 SKILL.md。
- 每次任务声明 loading tier 和选中技能原因：light / standard / expanded / full。
- light: router-only 或少量当前事实；standard: 1 个主技能 + 最多 1 个专项；expanded: 1 个主技能 + 最多 2 个专项；full: 仅限 --full、对抗性审核、全身体检、高风险发版或用户明确要求。
- 高风险、安全、UI、性能、发布等扩展必须说明触发原因。
- 修改技能前读完整技能和 CANON.md；修改后同步 skills-index.json / skills-lock.json，并运行 ./validate。
- 保留 hard gates、Iron Laws、human partner 措辞、AGENTS 单入口和真实 skills/ 树。

$platform_hint"

# Show visible prompt to user
if [ "$is_codex" -eq 1 ]; then
  echo "⚡ Unified Skills 已加载（Codex 模式）— AGENTS.md + skills-router.json 就绪"
else
  echo "⚡ Unified Skills 已加载 — 使用 /refine /design /plan /build /review /ship 进入工作流"
fi

# Output in format compatible with both Claude Code and Codex
escaped=$(printf '%s' "$full_message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$escaped"
