---
name: plan
description: 任务分解与计划。使用 cuando spec 已批准、需要将需求分解为可执行任务或做技术方案时
---

# Plan — 任务分解

加载 `build-workflow-plan/SKILL.md` 执行任务分解。

## 流程

1. 读取 `docs/features/<name>/01-spec.md`
2. 读取 `artifact_type`，按软件、文档、文章、PPT 或视觉稿选择任务拆分方式
3. 加载 `build-workflow-plan/SKILL.md` 执行只读分析 + 依赖图 + 垂直切片拆分
4. 自审通过后，**并行分派 Plan Review Army**（CEO + Eng + Design + Security 四视角审查）
5. 合并审查反馈，修改 plan
6. 产出 `docs/features/<name>/02-plan.md`，附审查摘要

## Plan Review Army

- `agents/plan-ceo-reviewer.md` — CEO 视角: 商业价值、范围、优先级
- `agents/plan-eng-reviewer.md` — Eng 视角: 技术可行、架构、风险
- `agents/plan-design-reviewer.md` — Design 视角: 用户体验、交互、一致性
- `agents/plan-security-reviewer.md` — Security 视角: 数据隐私、攻击面、合规

## 同时加载

- `CANON.md` — 宪法第 2 条（Simple First）、第 5 条（Verify Don't Assume）
