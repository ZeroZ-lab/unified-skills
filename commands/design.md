---
description: 从已批准 spec 到创作设计定稿（交互 / 视觉 / 排版 / 剧本 / 导演）
---

# Command: /design

## Goal

Transform approved spec into an approved design contract for user-visible artifacts.

## Phases

### Phase 1: Decide Whether Design Is Required

**Agent:** requirements-analyst
**Skills:** design-workflow-design
**Input:** docs/features/YYYYMMDD-<name>/01-spec.md
**Process:**
1. 读取 spec 的 `artifact_type`
2. 判断当前任务是否产生用户可感知产物
3. 如果是 `software`，判断是否涉及 UI / 页面 / 组件 / 交互 / 视觉呈现
4. 记录 design required / skipped 结论和理由
**Output:** design-decision（required / skipped）
**Validation:**
- [ ] 是否需要 design 已明确
- [ ] skip 仅用于纯后端 / 纯脚本 / 纯迁移

### Phase 2: Create Design Draft

**Agent selection (by artifact_type):**
- software + UI → visual-designer
- document / article → content-writer
- deck → content-writer + visual-designer
- visual → visual-designer
**Skills:**
- design-workflow-design
- design-experience-interaction（software + UI）
- design-visual-direction（software + UI / visual）
- design-content-script（document / article / deck）
- design-content-direction（deck）
- design-content-layout（document / deck / visual）
**Input:** 01-spec.md
**Process:**
1. 只做创作和呈现层设计，不拆任务，不写实现步骤
2. 按 artifact_type 产出对应设计决策
3. 明确设计目标、关键决策、设计边界、批准标准、实施前置条件
**Output:** docs/features/YYYYMMDD-<name>/02-design.md（draft）
**Validation:**
- [ ] 设计目标明确
- [ ] 关键决策已定稿
- [ ] 不做清单明确
- [ ] 没有实现任务分解

### Phase 3: Design Review

**Agent:** design-reviewer
**Input:** 02-design.md（draft）
**Process:**
1. 审查设计目标、关键决策、边界和实施前置条件
2. 输出 Blocking / Important / Suggestion
3. 如有 Blocking，先修设计稿再进入批准
**Output:** design-review-comments.md
**Validation:**
- [ ] design-reviewer 已完成
- [ ] Blocking issues 已识别

### Phase 4: Approval

**Agent:** current
**Skills:** design-workflow-design
**Input:** 02-design.md（draft）+ design-review-comments.md
**Process:**
1. 向用户展示设计稿 + design review 反馈
2. 记录反馈并修改
3. 获得批准后定稿
**Output:** docs/features/YYYYMMDD-<name>/02-design.md（final）
**Validation:**
- [ ] design-reviewer 的 Blocking 已处理
- [ ] 用户已批准 design
- [ ] 设计稿满足批准标准

---

## Entry Conditions
- [ ] 01-spec.md 存在且已批准
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] design required 时：02-design.md 存在且已批准
- [ ] design skipped 时：skip 理由已明确记录

## Next Steps
- If design approved → /plan
- If design skipped → /plan
- If major direction issue → /refine

## Constitutional Rules
- CANON.md Clause 1: Surface Assumptions — 设计前先陈述假设
- CANON.md Clause 3: Scope Discipline — 设计不偷带实现任务
- CANON.md Clause 8: Manage Confusion — 设计目标或媒介冲突时停止推进

## 实现

加载 CANON.md → 调用 skills/design-workflow-design/SKILL.md，并按 artifact_type 追加 design-* 专项技能。
