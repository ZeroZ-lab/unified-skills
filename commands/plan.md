---
description: 从已批准 spec + design 到详细任务分解 + 按风险升级的计划审查。当 spec 和 design 已定稿需要拆任务，或提到"计划""任务拆分""排期"
---

# Command: /plan

## Runtime Preflight

执行本命令前，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Transform approved spec and design into actionable task plan with risk-based multi-perspective review.

## Phases

### Phase 1: 理解与分解

**Agent:** task-planner
**Skills:** build-workflow-plan（Step 1~6）+ build-cognitive-execution-engine（mode selection）
**Auxiliary:** task-templates.md（任务模板、Subplan Contract、Parallel Safety 判定）
**Input:** docs/features/YYYYMMDD-<name>/01-spec.md + 02-design.md（如果 design required）
**Process:**
1. **Step 1 只读模式** — 读取 spec、design 和相关代码库；**单计划 vs 多计划决策门**：XS/S 只写 `03-plan.md`，M/L 或跨子系统额外写 `plans/*.md`
2. **Step 2 依赖图 + Plan Topology** — 按 artifact_type 选择依赖图策略（software/document/deck/visual）；选择 Plan Topology：`serial` / `parallel` / `gated-parallel`
3. **Step 3 文件结构映射** — 标记哪些文件会被创建或修改，锁定职责边界
4. **Step 4 垂直切片** — 一次构建一个完整功能路径（不是水平切片：先建所有 DB → 再建所有 API → 再建所有 UI）
5. **Step 5 写 bite-sized 任务** — 使用 `task-templates.md` 的任务模板；Software 用 RED→GREEN→REFACTOR，非 software 用产物切片+验证证据；每个步骤 2-5 分钟可执行
6. **Step 6 排序 + 检查点** — 依赖关系满足、每 2-3 个任务设验证检查点、高风险任务放前面
**Output:** docs/features/YYYYMMDD-<name>/03-plan.md（draft）+ plans/*.md（如多计划模式）
**Validation:**
- [ ] Plan Topology 已选择
- [ ] 所有任务有验收标准
- [ ] 依赖关系已声明
- [ ] 并行安全任务已标记
- [ ] 无占位符（TBD/TODO）
- [ ] 多计划模式下 Subplan Contract 完整

### Phase 2: 自审（10 项检查）

**Agent:** task-planner
**Skills:** build-workflow-plan（Step 7）
**Input:** 03-plan.md（draft）
**Process:**
1. **7.1 Spec 覆盖** — 逐条检查 spec 每个需求在 plan 中有对应任务
2. **7.2 占位符扫描** — 搜索 TBD/TODO/"implement later"/"添加适当的错误处理"
3. **7.3 类型一致性** — 后面任务的函数签名和属性名匹配前面定义
4. **7.4 Subplans 完整性** — 03-plan.md 中列出的每个 plans/*.md 都存在且有完整 Contract
5. **7.5 并行安全性** — 任意两个 parallel_safe 子计划没有重叠写入范围
6. **7.6 收口顺序** — release/export/ship 类子计划标为串行，非 parallel_safe
7. **7.7 任务独立性** — 每个任务有明确验收标准、独立验证步骤、依赖关系已标注
8. **7.8 验证步骤完整性** — 每个任务有具体验证命令、预期输出、失败诊断方法
9. **7.9 代码示例风格** — 最小示例+意图注释，无完整实现逻辑
10. **7.10 任务粒度** — 单任务 ≤5 文件、3-7 步骤、标题无"and"
**Output:** 自审通过/未通过 + 修正后的 plan
**Validation:**
- [ ] 10 项检查全部通过
- [ ] 发现的问题已修正

### Phase 3: Plan Review Army

**Agents (selected by `build-workflow-plan` minimum trigger rules):**
- plan-ceo-reviewer（市场价值、投资回报、优先级）
- plan-eng-reviewer（可行性、技术复杂度、依赖风险）
- plan-design-reviewer（设计约束覆盖、体验任务映射、错误下沉检查）
- plan-security-reviewer（数据暴露、认证授权、合规）
**Skills:** build-workflow-plan（Step 7.5）+ plan-review.md（详细规则）
**Input:** 03-plan.md（自审通过版）
**Process:**
1. 按风险升级规则选择必要 Reviewer（小型变更可跳过，标准至少 CEO + Eng，大型/安全/合规四视角全开）
2. 并行分派已选 Reviewer
3. 收集反馈，分级合并为 Blocking / Important / Suggestion
**Output:** Reviewer 反馈（合并进 plan 迭代，非独立产出文件）
**Validation:**
- [ ] 已按风险升级规则选择必要 Reviewer（或记录跳过理由）
- [ ] 已选 Reviewers 全部完成
- [ ] Blocking issues 已识别

### Phase 4: 用户批准

**Agent:** task-planner
**Skills:** build-workflow-plan（Step 8）
**Input:** 03-plan.md + Reviewer 反馈
**Process:**
1. 向用户展示 plan + 分级审查反馈（Blocking / Important / Suggestion）
2. 等待用户反馈或确认
3. 根据用户意见修改 plan
**Output:** docs/features/YYYYMMDD-<name>/03-plan.md（final）
**Validation:**
- [ ] 所有 Blocking issues 已解决
- [ ] spec 的每个需求在 plan 中有对应任务
- [ ] 用户已批准

---

## Entry Conditions
- [ ] 01-spec.md 存在且已批准
- [ ] 若 design required，则 02-design.md 存在且已批准
- [ ] artifact_type 已声明
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 03-plan.md 存在且为最终版
- [ ] spec 的每个需求在 plan 中有对应任务
- [ ] 经最小必要视角审查，或记录了跳过 Plan Review Army 的理由
- [ ] 所有 Blocking issues 已解决

## Next Steps
- If approved → /build
- If major changes → /refine（迭代 spec）

## Constitutional Rules
- CANON.md Clause 1: Surface Assumptions — plan 前陈述假设
- CANON.md Clause 2: Simple First — 最简单的计划覆盖需求
- CANON.md Clause 3: Scope Discipline — 计划不超出 spec 范围
- CANON.md Clause 4: TDD Iron Law — 每个实现任务必须包含测试任务

## 实现

加载 CANON.md → 调用 skills/build-workflow-plan/SKILL.md。
