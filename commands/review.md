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
2. **Code Quality（实现质量）** — 检查代码质量（五轴体系）

只有通过第一阶段，才会进入第二阶段。

## Phases

### Phase 1: Artifact Analysis

**Agent:** 主 session
**Skills:** verify-workflow-review（路由部分）
**Input:** 产物文件 + 01-spec.md + 02-design.md（如适用） + 03-plan.md
**Process:**
1. **Step 1 理解上下文** — 这个变更要达成什么？对应 spec/plan 的哪个部分？预期的行为变化？
2. **Step 2 先看测试** — 测试揭示意图和覆盖：有测试吗？测试行为而非实现细节？边界情况覆盖？代码改了测试能捕获回归？
3. **Step 3 审查路由** — 确定审查策略：software → 两阶段审查；document / article → 内容审查；deck → 内容 + 视觉审查；visual → 视觉审查
4. **Step 3.5 独立性路由** — 判定 `trivial exemption` / `standard` / `high-risk-full`；除豁免外，Stage 2 必须独立于 build implementer
**Output:** 审查策略决策

### Phase 2: Spec Compliance Review (Stage 1)

**Agent:** current agent 或独立的 review-spec-compliance-auditor（按独立性档位）
**Skills:** verify-workflow-spec-compliance
**Input:** 产物文件 + 01-spec.md
**Process:**
1. 提取 spec 需求清单（功能需求、边界条件、错误场景、验收标准）
2. 逐项验证代码实现
3. 识别 Scope Creep
4. 生成合规性报告
**Output:** Spec Compliance 审查结果（通过/不通过 + 遗漏清单）
**Gate:** 如果不通过，退回 build 阶段，不进入 Phase 3

### Phase 3: Code Quality Review (Stage 2)

**前置条件:** Phase 2 已通过（spec compliance ✅）

**Agents (selected by `verify-workflow-review/review-guidance.md` risk triggers, software 类型):**
- review-code-quality-auditor（五轴：Correctness、Readability、Architecture、Security、Performance）
- review-security-auditor（OWASP、威胁建模、密钥扫描，安全敏感时）
- review-test-engineer（happy path、边界、错误路径、并发）
- review-accessibility-auditor（WCAG、屏幕阅读器，有 UI 变更时）

**Skills:**
- verify-quality-code-quality（code-quality-auditor）
- verify-quality-security（security-auditor）
- verify-frontend-accessibility（accessibility-auditor）
- verify-content-review（document / article / deck）
- verify-visual-review（deck / visual）

**Input:** 产物文件
**Output:** 已选 Reviewer 独立反馈（五轴评分 + Blocking/Important/Suggestion 分级）
**Rule:** `standard` 起 `review-code-quality-auditor` 必须与 build implementer 独立；`high-risk-full` 时 Stage 1 和 Stage 2 都必须独立，build 阶段 pre-review 结果不能替代 formal review

### Phase 4: 分类意见 + 验证证据 + 出报告

**Agent:** 主 session
**Skills:** verify-workflow-review（Step 4~5）+ review-guidance.md（变更大小/拆分/依赖审查）
**Input:** Spec Compliance 结果 + Code Quality 反馈
**Process:**
1. **Step 4 分类意见** — 每条审查意见标注严重级别：Critical（阻塞合并）/ Nit（可选风格偏好）/ Consider（建议不强制）/ FYI（仅供参考）。防止作者把所有反馈当强制要求
2. **Step 5 验证验证者** — 检查提交者的验证证据：跑了什么测试？构建通过？UI 变更有截图？前后对比？
3. **Step 5.2 检查审查独立性** — 写入 `Built by`、`Stage 1 reviewed by`、`Stage 2 reviewed by`、`Independence status`、`Exemption reason`
4. 合并所有反馈，生成审查报告
**Output:** docs/features/YYYYMMDD-<name>/04-review.md
**Validation:**
- [ ] 报告包含 Spec Compliance 审查结果
- [ ] 报告包含 Code Quality 审查结果（五轴评分）
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
- [ ] 两阶段审查都已完成（Stage 1 Spec Compliance + Stage 2 Code Quality）
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
