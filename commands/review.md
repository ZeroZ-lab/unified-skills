---
description: 两阶段审查（Spec Compliance → Code Quality）+ 按风险升级的专业审查。当代码或内容完成后需要质量把关，或提到"审查""review""质量检查"
---

# Command: /review

## Runtime Preflight

本命令是显式 Unified 入口。执行本命令时，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Two-stage artifact review: first verify functional completeness (Spec Compliance), then assess implementation quality (Code Quality). Add specialist reviewers only when risk triggers require them or the user requests `--full`.

## 两阶段审查流程

`/review` 命令执行两阶段审查：

1. **Spec Compliance（功能完整性）** — 检查是否实现了 spec 的所有需求
2. **Artifact Quality（实现/内容/视觉质量）** — 按产物类型检查实现质量、内容质量或视觉质量

只有通过第一阶段，才会进入第二阶段。

## Phases

### Phase 1: Artifact Analysis

**Agent:** 主 session
**Skills:** verify-workflow-review（路由部分）
**Input:** 产物文件 + 01-spec.md + 02-design.md（如适用） + 03-plan.md
**Process:**
1. **Step 1 理解上下文** — 这个变更要达成什么？对应 spec/plan 的哪个部分？预期的行为变化？
2. **Step 2 先看主要验证证据** — `software` 看测试/构建结果；非 software 看产物预览、导出结果、引用来源和前后对比。不要把 software 的测试语义强套到内容或视觉产物上。
3. **Step 3 审查路由** — 确定审查策略：software → 两阶段审查；document / article → `review-content-auditor` + 内容审查；deck → 默认 `review-content-auditor`，如视觉层级或版式会影响结论，再叠加 `review-visual-auditor`；visual → `review-visual-auditor` + 视觉审查
4. **Step 3.5 独立性路由** — 判定 `trivial exemption` / `standard` / `high-risk-full`；除豁免外，Stage 2 必须独立于 build implementer
**Output:** 审查策略决策

### Phase 2: Spec Compliance Review (Stage 1)

**Agent:** current agent 或独立的 review-spec-compliance-auditor（按独立性档位）
**Skills:** verify-workflow-spec-compliance
**Input:** 产物文件 + 01-spec.md
**Process:**
1. 提取 spec 需求清单（功能需求、边界条件、错误场景、验收标准）
2. 逐项验证产物是否兑现这些要求；`software` 看实现与测试，非 software 看内容/视觉产物、预览和导出证据
3. 识别 Scope Creep
4. 生成合规性报告
**Output:** Spec Compliance 审查结果（通过/不通过 + 遗漏清单）
**Gate:** 如果不通过，退回 build 阶段，不进入 Phase 3

### Phase 3: Artifact Quality Review (Stage 2)

**前置条件:** Phase 2 已通过（spec compliance ✅）

**Agents (selected by `verify-workflow-review/review-guidance.md` and `artifact_type`):**
- `software` → review-code-quality-auditor（五轴：Correctness、Readability、Architecture、Security、Performance）
- `software` 安全敏感 → review-security-auditor（OWASP、威胁建模、密钥扫描）
- `software` 测试覆盖不确定 → review-test-engineer（happy path、边界、错误路径、并发）
- `software` 有 UI 变更 → review-accessibility-auditor（WCAG、屏幕阅读器）
- `document` / `article` → review-content-auditor（目标读者、逻辑、事实、语气、完整性）
- `deck` → 默认 review-content-auditor；如视觉层级、版式、投屏可读性或信息密度会影响结论，再叠加 review-visual-auditor
- `visual` → review-visual-auditor

**Skills:**
- verify-quality-code-quality（code-quality-auditor）
- verify-quality-security（security-auditor）
- verify-frontend-accessibility（accessibility-auditor）
- verify-content-review（document / article / deck）
- verify-visual-review（deck / visual）

**Input:** 产物文件
**Output:** 已选 Reviewer 独立反馈（软件为五轴评分；非 software 为内容/视觉质量结论 + Blocking/Important/Suggestion 分级）
**Rule:** `software` 在 `standard` 起 `review-code-quality-auditor` 必须与 build implementer 独立；非 software 默认由对应独立 auditor 执行 Stage 2；`high-risk-full` 时 Stage 1 和 Stage 2 都必须独立，build 阶段 pre-review 结果不能替代 formal review

### Phase 4: 分类意见 + 验证证据 + 出报告

**Agent:** 主 session
**Skills:** verify-workflow-review（Step 4~5）+ review-guidance.md（变更大小/拆分/依赖审查）
**Input:** Spec Compliance 结果 + Code Quality 反馈
**Process:**
1. **Step 4 分类意见** — 每条审查意见标注严重级别：Critical（阻塞合并）/ Nit（可选风格偏好）/ Consider（建议不强制）/ FYI（仅供参考）。防止作者把所有反馈当强制要求
2. **Step 5 验证验证者** — 检查提交者的验证证据：`software` 看测试与构建；非 software 看产物预览、导出验证、引用来源、截图或前后对比。
3. **Step 5.2 检查审查独立性** — 写入 `Built by`、`Stage 1 reviewed by`、`Stage 2 reviewed by`、`Independence status`、`Exemption reason`
4. 合并所有反馈，生成审查报告
**Output:** docs/features/YYYYMMDD-<name>/04-review.md
**Validation:**
- [ ] 报告包含 Spec Compliance 审查结果
- [ ] 报告包含 Stage 2 质量审查结果（软件为五轴；非 software 为内容/视觉质量结论）
- [ ] 报告包含所有已选 Reviewer 反馈，或记录标准模式未派发专业 reviewer 的理由
- [ ] 报告包含独立性字段，且状态不是未解释的 FAIL
- [ ] 意见已按严重级别分类（Critical/Nit/Consider/FYI）
- [ ] Blocking issues 清晰标注

---

## Entry Conditions
- [ ] 产物已完成（/build 已完成）
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 04-review.md 存在
- [ ] 两阶段审查都已完成（Stage 1 Spec Compliance + Stage 2 Artifact Quality）
- [ ] 独立性要求已满足，或命中 `trivial exemption` 且理由具体
- [ ] 反馈已按 Blocking / Important / Suggestion 分级

## Next Steps
- If no Blocking → /ship
- If has Blocking → /build（修复后重新 /review）

## Constitutional Rules
- CANON.md Clause 5: Verify Don't Assume — 没有验证证据不能声称完成
- CANON.md Clause 7: Push Back — 有具体问题直说，量化影响，不做 yes-machine

## 实现

调用 skills/verify-workflow-review/SKILL.md。
