# Architecture Docs

这里放仍可能被当前仓库引用的机制与架构文档。

## 当前文档

- `command-agent-skill-architecture.md`：Command / Agent / Skill 三层架构设计稿。可作为架构背景阅读，但其中“设计阶段”表述不自动等于当前实现真相。
- `review-two-stage-gate.md`：两阶段审查门控设计，和当前 `verify-workflow-review` / `verify-workflow-spec-compliance` / `verify-quality-code-quality` 直接相关。

## 使用规则

1. 先看 `AGENTS.md` 和 `skills/`，再把这里当作 WHY 背景。
2. 如果实现已经变化，但这里未同步，优先修正文档而不是让历史设计继续冒充现状。
