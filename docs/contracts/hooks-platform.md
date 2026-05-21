# Hooks 平台差异

> 本文件在修改 hooks 或做跨平台适配时按需加载，不在 CLAUDE.md 中全量引用。

## Hooks 表

Unified Skills 有 6 个 hooks，在两个平台上行为有差异：

| Hook | Claude Code | Codex CLI |
|------|-------------|-----------|
| SessionStart | 自动注入 Boot Kernel 可用性提示 | 自动注入 Boot Kernel 可用性提示（需启用 hooks，不自动激活 router） |
| careful（破坏性命令拦截） | `permissionDecision: "ask"` — 提示用户确认 | 默认 `permissionDecision: "deny"`；但限定在生成目录内的清理命令可放行 |
| freeze（编辑范围冻结） | `permissionDecision: "deny"` — 阻止范围外编辑 | `permissionDecision: "deny"` — 阻止范围外编辑 |
| agent-dispatch（派出通知） | `additionalContext` — 显示 subagent 角色和职责 | Codex 暂未适配（使用 `statusMessage` 模式） |
| doc-tracker（阶段进度） | `additionalContext` — 写入阶段文档时显示链进展，并更新 `docs/features/<feature>/state.json` | Codex 暂未适配 |
| phase-stop（决策 checkpoint 提醒） | `systemMessage` — feature state 已自动记录时，仅提示可按需 `/save` 关键决策 | Codex 暂未适配 |

## Codex hooks 激活

需在 `.codex/config.toml` 的 `[features]` 表中设置 `hooks = true`，或通过 CLI 参数 `--enable hooks` 临时启用。

## Hook 入口解析

Claude Code 插件 hooks 不能在命令字符串里直接 shell 展开 `${CLAUDE_PLUGIN_ROOT}/hooks/*.sh`。当宿主未注入该变量时，shell 会把路径展开成 `/hooks/*.sh`，导致 hook 以 `127` 失败。

Claude Code 的 `hooks/hooks.json` 必须使用 portable bootstrap：优先使用 `CLAUDE_PLUGIN_ROOT` / `CODEX_PLUGIN_ROOT`，其次尝试当前 cwd 及父目录、`~/.claude/plugins/installed_plugins.json`、Claude/Codex installed cache、marketplace source 来定位 Unified 根目录，再执行真实 hook 脚本。`PreToolUse` 找不到根目录时必须 fail-closed 返回 `permissionDecision: "deny"`，不能静默放行。

Codex 的 `.codex/hooks.json` 也必须使用同一套 portable bootstrap，不能依赖 `bash hooks/codex-wrapper.sh` 这种 repo-relative 路径。Codex hook 可能从项目根、子目录、插件 cache 或其他 cwd 启动；入口命令必须先定位 Unified 根目录，再执行真实 hook 脚本。

## 重要差异

careful hook 在 Codex 上对不可逆操作使用 fail-closed 模式（阻止破坏性命令而非提示确认），因为确认型交互语义在 Codex 上并不稳定；对显式限定在生成目录内的清理命令可按条件放行，避免把常见维护动作一并卡死。
