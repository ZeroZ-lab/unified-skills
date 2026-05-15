# Architecture Docs

这里放仍可能被当前仓库引用的机制与架构文档。

## 当前文档

- `review-two-stage-gate.md`：两阶段审查门控设计，和当前 `verify-workflow-review` / `verify-workflow-spec-compliance` / `verify-quality-code-quality` 直接相关。内容仍然反映当前实现。
- `current-skill-call-graph.md`：当前 Command → Agent → Skill 调用关系图，结构化展示从阶段命令到 persona、专项技能和风险升级的真实调用链。

## 历史文档（已标注）

- `command-agent-skill-architecture.md`：Command / Agent / Skill 三层架构设计稿（v2.12 时期）。部分内容已过时（如 `load-manifest.json` 已在 v2.14.0 删除）。文档本身已带 ⚠️ 历史标注，保留作为架构背景阅读。

## 使用规则

1. 先看 `AGENTS.md` 和 `skills/`，再把这里当作 WHY 背景。
2. 如果实现已经变化，但这里未同步，优先修正文档而不是让历史设计继续冒充现状。
3. 历史文档已带显式标注；如果发现未标注的过时内容，立即补标注。
