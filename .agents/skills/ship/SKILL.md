---
name: ship
description: 发布检查 + Go/No-Go + 回滚计划。使用 cuando 功能代码已合入、准备上线或需要发布管理时
---

# Ship — 发布流水线

加载 `ship-workflow-ship/SKILL.md` 执行发布检查。

## 流程

1. 加载 `ship-workflow-ship/SKILL.md`
2. Pre-Launch 检查表 + Staging 验证强制门
3. Go/No-Go 决策 + 回滚计划
4. 可选加载 `ship-infrastructure-ci-cd/SKILL.md` + `ship-infrastructure-deploy/SKILL.md`
5. 产出 `docs/features/<name>/ship.md` + README 聚合

## 同时加载

- `CANON.md` — 宪法第 10 条（Every Feature Leaves a Trace）
