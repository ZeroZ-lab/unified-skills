---
description: 需求提炼 + External Scan + 按风险升级的 Idea Scout 审查
---

# Command: /refine

## Runtime Preflight

执行本命令前，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Transform vague idea into structured spec with risk-based multi-perspective validation.

## Phases

### Phase 1: 理解与探索

**Agent:** requirements-analyst
**Skills:** define-workflow-refine（Phase 1 Step 1.1~1.3）
**Input:** 用户的初始需求描述
**Process:**
1. **Step 1.1 探索项目上下文** — 扫描相关代码、架构、模式、约束、已有实践。在问问题前先理解项目现状
2. **Step 1.2 Scope 检查** — 多子系统时立即标记，先帮用户分解成子项目
3. **Step 1.2.5 Goal Review** — 目标质量检查（/12 评分）：10-12 accepted / 7-9 needs-refinement / 0-6 blocked
4. **Step 1.3 逐一询问澄清问题** — 5W1H 方法论，一次一个问题，不列清单
**Output:** docs/features/YYYYMMDD-<name>/01-spec.md（draft）
**Validation:**
- [ ] 项目现状已了解（引用了具体文件）
- [ ] Scope 合理（非多子系统未拆分）
- [ ] Goal Review 评分 ≥ 7
- [ ] artifact_type 已声明
- [ ] 5W1H 全部回答

### Phase 2: External Scan + Scout Review

**Agent:** requirements-analyst（主流程）+ Scout subagents（并行分派）
**Skills:** define-workflow-refine（Phase 1 Step 1.4~1.6）
**Input:** 01-spec.md（draft）
**Process:**
1. **Step 1.4 External Scan** — 按 artifact_type 搜索外部方案，结果分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject
2. **Step 1.6 Scout Army** — 按 `define-workflow-refine` minimum trigger rules 选择 Scout 并行分派：
   - 标准功能 → 至少 CEO + Eng
   - 大型功能（涉及 UI 或合规）→ 三视角全开
   - 小型变更 → 可跳过
3. Scout 反馈分级合并为 Blocking / Important / Suggestion
**Output:** docs/features/YYYYMMDD-<name>/external-scan.md（External Scan 结果）
**Validation:**
- [ ] External Scan 分层结果完整（Fact / Pattern / Inference / Unknown / Adopt / Reject）
- [ ] 已按风险升级规则选择必要 Scout（或记录跳过理由）
- [ ] 已选 Scouts 全部完成
- [ ] Blocking issues 已识别

### Phase 3: 方案与收敛

**Agent:** requirements-analyst
**Skills:** define-workflow-refine（Phase 2）
**Input:** 01-spec.md（draft）+ external-scan.md + Scout 反馈
**Process:**
1. 基于 Phase 1 澄清、External Scan 和 Scout 反馈，提出 2-3 种方案
2. 每种方案包含优点、代价、理由
3. 明确推荐主推方案
4. 向用户展示方案，等待确认或迭代
**Output:** 方案对比 + 用户确认的方向
**Validation:**
- [ ] 2-3 种方案，每种有优点和代价
- [ ] 有明确推荐
- [ ] 用户已确认方向

### Phase 4: Spec 定稿

**Agent:** requirements-analyst
**Skills:** define-workflow-refine（Phase 3）
**Input:** 用户确认的方向 + 01-spec.md（draft）
**Process:**
1. 根据用户确认的方向修改 spec
2. 确保所有 Blocking issues 已解决
3. 写入最终版 spec
**Output:** docs/features/YYYYMMDD-<name>/01-spec.md（final）
**Validation:**
- [ ] 所有 Blocking issues 已解决
- [ ] artifact_type 与需求匹配
- [ ] spec 为最终版

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
