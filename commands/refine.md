---
description: 需求提炼 + External Scan + 按风险升级的 Idea Scout 审查
---

# Command: /refine

## Goal

Transform vague idea into structured spec with risk-based multi-perspective validation.

## Phases

### Phase 1: Requirement Clarification

**Agent:** requirements-analyst
**Skills:** define-workflow-refine（需求澄清部分）
**Input:** 用户的初始需求描述
**Process:**
1. 通过 5W1H 方法论澄清模糊需求
2. 识别隐含假设和矛盾
3. 确定 artifact_type（software/document/article/deck/visual）
4. 生成 spec 初稿
**Output:** docs/features/YYYYMMDD-<name>/01-spec.md（draft）
**Validation:**
- [ ] artifact_type 已声明
- [ ] 需求无自相矛盾
- [ ] 5W1H 全部回答

### Phase 2: External Scan

**Agent:** 独立 subagent
**Skills:** define-workflow-refine（External Scan 部分）
**Input:** 01-spec.md（draft）
**Process:**
1. 按 artifact_type 搜索已有方案、事实来源、设计模式
2. 结果分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject
**Output:** external-scan-results.md
**Validation:**
- [ ] 至少 3 个事实来源
- [ ] 分层结果完整

### Phase 3: Risk-Based Scout Review

**Agents (selected by `define-workflow-refine` minimum trigger rules):**
- refine-ceo-scout（商业可行性、市场定位）
- refine-eng-scout（技术可行性、实现复杂度）
- refine-design-scout（用户体验、交互创新）
**Skills:** define-workflow-refine（审查部分）
**Input:** 01-spec.md（draft）+ external-scan-results.md
**Output:** scout-feedback.md
**Validation:**
- [ ] 已按风险升级规则选择必要 Scout（小型变更可跳过，标准至少 CEO + Eng，大型 UI/合规三视角全开）
- [ ] 已选 Scouts 全部完成
- [ ] Blocking issues 已识别

### Phase 4: Present Scout Feedback to User + Refine

**Agent:** requirements-analyst
**Skills:** define-workflow-refine（迭代部分）
**Input:** 01-spec.md（draft）+ scout-feedback.md
**Process:**
1. 向用户展示 spec 初稿 + 分级 Scout 反馈（Blocking / Important / Suggestion）
2. 等待用户反馈或确认
3. 根据用户意见修改 spec
**Output:** docs/features/YYYYMMDD-<name>/01-spec.md（final）
**Validation:**
- [ ] 所有 Blocking issues 已解决
- [ ] artifact_type 与需求匹配

---

## Entry Conditions
- [ ] 用户提供了初始需求描述
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 01-spec.md 存在且为最终版
- [ ] artifact_type 已声明
- [ ] 经最小必要视角审查，或记录了跳过 Scout Army 的理由

## Next Steps
- If approved → /design
- If major issues → 迭代 Phase 1-4

## Constitutional Rules
- CANON.md Clause 1: Surface Assumptions — 实现非平凡任务前陈述假设
- CANON.md Clause 9: Structured Questions — 一次只问一个问题，推荐项标注 (Recommended)

## 实现

加载 CANON.md → 调用 skills/define-workflow-refine/SKILL.md。
