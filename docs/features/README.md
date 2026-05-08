# Feature Artifacts

`docs/features/` 是 Unified 的标准产物链目录：

```text
docs/features/YYYYMMDD-<name>/
├── 00-brainstorm.md
├── 01-spec.md
├── 02-design.md
├── 03-plan.md
├── plans/*.md
├── adr/*.md
├── 04-review.md
├── 05-ship.md
├── 06-canary-report.md
├── 07-deploy-report.md
└── README.md
```

## 当前目录说明

- `20260426-minecraft-city/`：历史样例，只包含 `spec` 和 `plan`，不是完整产物链。
- `20260427-codex-hooks-commands/`：历史样例，记录早期 Codex hooks 兼容方案。
- `20260427-iron-law-injection/`：历史样例，记录早期 brainstorming / plan 讨论。

这些现有目录主要作为格式和演进痕迹保留，不代表“当前推荐从这里继续做”。新的工作项继续按上面的标准结构创建。
