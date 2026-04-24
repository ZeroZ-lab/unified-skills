---
name: ship
description: 发布或导出检查 + Go/No-Go + 归档。使用 cuando 软件准备上线，或文档、文章、PPT、视觉稿准备交付时
---

# Ship — 发布与导出

加载 `ship-workflow-ship/SKILL.md`，按 spec 的 `artifact_type` 执行软件发布或非软件产物导出。

## 流程

1. 加载 `ship-workflow-ship/SKILL.md`
2. software 执行 Pre-Launch 检查表 + Staging 验证强制门
3. document/article/deck/visual 加载 `ship-artifact-export/SKILL.md`
4. Go/No-Go 决策 + 回滚或导出归档计划
5. software 可选加载 `ship-infrastructure-ci-cd/SKILL.md` + `ship-infrastructure-deploy/SKILL.md`
6. 产出 `docs/features/<name>/ship.md` + README 聚合

## 同时加载

- `CANON.md` — 宪法第 10 条（Every Feature Leaves a Trace）
