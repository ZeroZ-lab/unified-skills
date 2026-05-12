---
description: 从已批准 spec 到证据驱动的创作设计定稿（交互 / 视觉 / 排版 / 剧本 / 导演）
---

# Command: /design

## Goal

Transform approved spec into an approved, evidence-driven design contract for user-visible artifacts.

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

### Phase 2: Design Best-Practice Scan

**Agent selection (by artifact_type):**
- software + UI → visual-designer
- document / article → content-writer
- deck → content-writer + visual-designer
- visual → visual-designer
**Skills:**
- design-workflow-design
- artifact_type 对应 design-* 专项技能
**Input:** 01-spec.md + references/design-best-practices.md + local project context
**Process:**
1. 围绕交互 / 视觉 / 排版 / 剧本 / 导演目标重新扫描创作与呈现层最佳实践
2. 按 Enterprise Product Patterns / Official Systems / Methods / Anti-patterns / Local Project Truth 分层记录来源
3. 输出 Sources / Patterns / Inferences / Adopt / Reject / Unknown
4. Search unavailable 时记录原因；关键设计决策无证据时 STOP
**Output:** design-best-practice-scan（写入 02-design.md）
**Validation:**
- [ ] Sources 已按来源层分组
- [ ] Pattern Synthesis 已提炼
- [ ] Inferences 已从模式和本地约束推导
- [ ] Adopt / Reject 已记录
- [ ] Unknown / Search unavailable 已处理或阻塞

### Phase 3: Create Design Draft

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
**Input:** 01-spec.md + design-best-practice-scan
**Process:**
1. 只做创作和呈现层设计，不拆任务，不写实现步骤
2. 按 artifact_type 产出对应设计决策
3. 只有进入 Adopt 的外部模式才能成为设计决策
4. 明确设计目标、关键决策、设计边界、批准标准、实施前置条件
5. **条件分支**: 当 `artifact_type` 为 `software`(有 UI)、`visual` 或 `deck` 时，产出 2-3 个 Design Alternatives（不同布局 / 交互 / 视觉方向），供 Phase 3.5 视觉对比；其他类型产出单一草案
**Output:** docs/features/YYYYMMDD-<name>/02-design.md（draft, 含 alternatives 或单一方案）
**Validation:**
- [ ] Design References / Pattern Synthesis / Inferences / Adopt-Reject 已填写
- [ ] 设计目标明确
- [ ] 关键决策已定稿
- [ ] 不做清单明确
- [ ] 没有实现任务分解
- [ ] visual comparison applicable 时：Design Alternatives 区段包含 2-3 个方向

### Phase 3.5: Interactive Preview (conditional)

**Condition:** artifact_type 为 `software`(有 UI)、`visual` 或 `deck`，且 Phase 3 产出了 Design Alternatives
**Agent:** visual-designer
**Skills:** design-interactive-preview
**Input:** 02-design.md (draft with alternatives)
**Process:**
1. 启动本地 HTTP 服务 (`scripts/design-preview.mjs`)
2. 生成对比 HTML 并在浏览器中展示
3. 多轮对比：先整体方向，再按维度细化（布局 / 配色 / 字体 / 交互模式等）
4. 捕获用户选择，精炼 `02-design.md` 为选定方向
5. 关闭服务
**Output:** 02-design.md (refined draft, 单一方向) + design-selection.json
**Validation:**
- [ ] HTTP 服务已启动并返回端口
- [ ] 对比页面已在浏览器打开
- [ ] 用户已做出选择
- [ ] 02-design.md 已精炼为选定方向
- [ ] 未选方案已移入 Alternatives Considered

### Phase 4: Design Review

**Agent:** design-reviewer
**Input:** 02-design.md（draft）
**Process:**
1. 审查设计目标、关键决策、证据质量、边界和实施前置条件
2. 输出 Blocking / Important / Suggestion
3. 如有 Blocking，先修设计稿再进入批准
**Output:** design-review-comments.md
**Validation:**
- [ ] design-reviewer 已完成
- [ ] Blocking issues 已识别

### Phase 5: Approval

**Agent:** current
**Skills:** design-workflow-design
**Input:** 02-design.md（refined draft）+ design-review-comments.md
**Process:**
1. 向用户展示设计稿 + design review 反馈
2. 记录反馈并修改
3. 获得批准后定稿
4. **注**: 如果经过 Phase 3.5 视觉对比，用户已确认方向选择，此处聚焦证据质量、完整性和不做清单
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
- [ ] design required 时：02-design.md 包含证据来源、模式综合、Adopt / Reject
- [ ] design skipped 时：skip 理由已明确记录

## Next Steps
- If design approved → /plan
- If design skipped → /plan
- If major direction issue → /refine

## Constitutional Rules
- CANON.md Clause 1: Surface Assumptions — 设计前先陈述假设
- CANON.md Clause 3: Scope Discipline — 设计不偷带实现任务
- CANON.md Clause 5: Verify Don't Assume — 设计决策必须有来源证据或本地约束背书
- CANON.md Clause 8: Manage Confusion — 设计目标或媒介冲突时停止推进

## 实现

加载 CANON.md → 调用 skills/design-workflow-design/SKILL.md，并按 artifact_type 追加 design-* 专项技能。
