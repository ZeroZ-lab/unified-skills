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

## 重要差异

careful hook 在 Codex 上对不可逆操作使用 fail-closed 模式（阻止破坏性命令而非提示确认），因为确认型交互语义在 Codex 上并不稳定；对显式限定在生成目录内的清理命令可按条件放行，避免把常见维护动作一并卡死。
