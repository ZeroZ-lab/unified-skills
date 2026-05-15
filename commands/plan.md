---
description: 从已批准 spec + design 到详细任务分解 + 按风险升级的计划审查
---

# Command: /plan

## Runtime Preflight

执行本命令前，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Transform approved spec and design into actionable task plan with risk-based multi-perspective review.

## Phases

### Phase 1: Parse Spec and Decompose Tasks

**Agent:** task-planner
**Skills:**
- build-workflow-plan
- build-cognitive-execution-engine（mode selection）
**Input:** docs/features/YYYYMMDD-<name>/01-spec.md + docs/features/YYYYMMDD-<name>/02-design.md（如果 design required）
**Process:**
1. 读取 spec 和 design，提取 artifact_type 与已锁定的设计约束
2. 根据 artifact_type 选择依赖图策略
3. 分解为带验收标准的任务
4. 标注依赖关系和并行安全性
5. 估算复杂度
**Output:** docs/features/YYYYMMDD-<name>/03-plan.md（draft）
**Validation:**
- [ ] 所有任务有验收标准
- [ ] 依赖关系已声明
- [ ] 并行安全任务已标记
- [ ] 复杂度已估算

### Phase 2: Risk-Based Plan Review

**Agents (selected by `build-workflow-plan` minimum trigger rules):**
- plan-ceo-reviewer（市场价值、投资回报、优先级）
- plan-eng-reviewer（可行性、技术复杂度、依赖风险）
- plan-design-reviewer（设计约束覆盖、体验任务映射、错误下沉检查）
- plan-security-reviewer（数据暴露、认证授权、合规）
**Skills:** verify-workflow-review（plan mode）
**Input:** 03-plan.md（draft）
**Output:** plan-review-comments.md
**Validation:**
- [ ] 已按风险升级规则选择必要 Reviewer（小型变更可跳过，标准至少 CEO + Eng，大型/安全/合规四视角全开）
- [ ] 已选 Reviewers 全部完成
- [ ] Blocking issues 已识别

### Phase 3: Present Review to User + Refine

**Agent:** task-planner
**Skills:** build-workflow-plan（refinement mode）
**Input:** 03-plan.md（draft）+ plan-review-comments.md
**Process:**
1. 向用户展示 draft plan + 分级审查反馈（Blocking / Important / Suggestion）
2. 等待用户反馈或确认
3. 根据用户意见修改 plan
**Output:** docs/features/YYYYMMDD-<name>/03-plan.md（final）
**Validation:**
- [ ] 所有 Blocking issues 已解决
- [ ] Plan 通过 Phase 1 的所有验证标准

---

## Entry Conditions
- [ ] 01-spec.md 存在且已批准
- [ ] 若 design required，则 02-design.md 存在且已批准
- [ ] artifact_type 已声明
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 03-plan.md 存在
- [ ] 经最小必要视角审查，或记录了跳过 Plan Review Army 的理由
- [ ] 所有 Blocking issues 已解决

## Next Steps
- If approved → /build
- If major changes → /refine（迭代 spec）

## Constitutional Rules
- CANON.md Clause 2: Simple First — 最简单的计划覆盖需求
- CANON.md Clause 3: Scope Discipline — 计划不超出 spec 范围
- CANON.md Clause 4: TDD Iron Law — 每个实现任务必须包含测试任务

## 实现

加载 CANON.md → 调用 skills/build-workflow-plan/SKILL.md。
