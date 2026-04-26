---
description: 从 spec 到详细任务分解 + 多角色计划审查
---

# Command: /plan

## Goal

Transform spec into actionable task plan with multi-perspective review.

## Phases

### Phase 1: Parse Spec and Decompose Tasks

**Agent:** task-planner
**Skills:**
- build-workflow-plan
- build-cognitive-execution-engine（mode selection）
**Input:** docs/features/YYYYMMDD-<name>/01-spec.md
**Process:**
1. 读取 spec，提取 artifact_type
2. 根据 artifact_type 选择依赖图策略
3. 分解为带验收标准的任务
4. 标注依赖关系和并行安全性
5. 估算复杂度
**Output:** docs/features/YYYYMMDD-<name>/02-plan.md（draft）
**Validation:**
- [ ] 所有任务有验收标准
- [ ] 依赖关系已声明
- [ ] 并行安全任务已标记
- [ ] 复杂度已估算

### Phase 2: Multi-Role Plan Review (Parallel)

**Agents (parallel dispatch):**
- plan-ceo-reviewer（市场价值、投资回报、优先级）
- plan-eng-reviewer（可行性、技术复杂度、依赖风险）
- plan-design-reviewer（用户体验、信息架构、交互流程）
- plan-security-reviewer（数据暴露、认证授权、合规）
**Skills:** verify-workflow-review（plan mode）
**Input:** 02-plan.md（draft）
**Output:** plan-review-comments.md
**Validation:**
- [ ] 4 个 Reviewers 全部完成
- [ ] Blocking issues 已识别

### Phase 3: Present Review to User + Refine

**Agent:** task-planner
**Skills:** build-workflow-plan（refinement mode）
**Input:** 02-plan.md（draft）+ plan-review-comments.md
**Process:**
1. 向用户展示 draft plan + 分级审查反馈（Blocking / Important / Suggestion）
2. 等待用户反馈或确认
3. 根据用户意见修改 plan
**Output:** docs/features/YYYYMMDD-<name>/02-plan.md（final）
**Validation:**
- [ ] 所有 Blocking issues 已解决
- [ ] Plan 通过 Phase 1 的所有验证标准

---

## Entry Conditions
- [ ] 01-spec.md 存在且已批准
- [ ] artifact_type 已声明
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 02-plan.md 存在
- [ ] 经 4 个视角审查
- [ ] 所有 Blocking issues 已解决

## Next Steps
- If approved → /build
- If major changes → /refine（迭代 spec）

## Constitutional Rules
- CANON.md Clause 2: 一次只问一个问题
- CANON.md Clause 3: 不做未经批准的架构决策
- CANON.md Clause 4: 不跳过测试

## 实现

加载 CANON.md → 调用 .agents/skills/plan/SKILL.md。
