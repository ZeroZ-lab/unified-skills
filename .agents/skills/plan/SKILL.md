---
name: plan
description: 任务分解与计划。使用 cuando spec 已批准、需要将需求分解为可执行任务或做技术方案时
---

# Plan — 任务分解

加载 `build-workflow-plan/SKILL.md` 执行任务分解。

## 流程

1. 读取 `docs/features/<name>/01-spec.md`
2. 加载 `build-workflow-plan/SKILL.md` 执行只读分析 + 依赖图 + 垂直切片拆分
3. 产出 `docs/features/<name>/02-plan.md`

## 同时加载

- `CANON.md` — 宪法第 2 条（Simple First）、第 5 条（Verify Don't Assume）
