---
description: 两阶段审查（Spec Compliance → Code Quality）+ 多角色并行审查
---

# Command: /review

## Goal

Two-stage artifact review: first verify functional completeness (Spec Compliance), then assess implementation quality (Code Quality). Multi-perspective review with severity-graded feedback.

## 两阶段审查流程

`/review` 命令执行两阶段审查：

1. **Spec Compliance（功能完整性）** — 检查是否实现了 spec 的所有需求
2. **Code Quality（实现质量）** — 检查代码质量（五轴体系）

只有通过第一阶段，才会进入第二阶段。

## Phases

### Phase 1: Artifact Analysis

**Agent:** 主 session
**Skills:** verify-workflow-review（路由部分）
**Input:** 产物文件 + 01-spec.md + 02-plan.md
**Process:**
1. 读取 artifact_type
2. 确定审查策略：software → 两阶段审查；document → 内容审查；visual → 视觉审查
**Output:** 审查策略决策

### Phase 2: Spec Compliance Review (Stage 1)

**Agent:** 主 session 或 review-spec-compliance-auditor（并行模式）
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

**Agents (parallel dispatch, software 类型):**
- review-code-quality-auditor（五轴：Correctness、Readability、Architecture、Security、Performance）
- review-security-auditor（OWASP、威胁建模、密钥扫描，安全敏感时）
- review-test-engineer（happy path、边界、错误路径、并发）
- review-accessibility-auditor（WCAG、屏幕阅读器，有 UI 变更时）

**Skills:**
- verify-quality-code-quality（code-quality-auditor）
- verify-quality-security（security-auditor）
- verify-frontend-accessibility（accessibility-auditor）

**Input:** 产物文件
**Output:** 各 Reviewer 独立反馈（五轴评分 + Blocking/Important/Suggestion 分级）

### Phase 4: Merge Feedback and Report

**Agent:** 主 session
**Skills:** verify-workflow-review（合并部分）
**Input:** Spec Compliance 结果 + Code Quality 反馈
**Output:** docs/features/YYYYMMDD-<name>/03-review.md
**Validation:**
- [ ] 报告包含 Spec Compliance 审查结果
- [ ] 报告包含 Code Quality 审查结果（五轴评分）
- [ ] 报告包含所有 Reviewer 反馈
- [ ] Blocking issues 清晰标注

---

## Entry Conditions
- [ ] 产物已完成（/build 已完成）
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 03-review.md 存在
- [ ] 反馈已按 Blocking / Important / Suggestion 分级

## Next Steps
- If no Blocking → /ship
- If has Blocking → /build（修复后重新 /review）

## Constitutional Rules
- CANON.md Clause 5: Verify Don't Assume — 没有验证证据不能声称完成
- CANON.md Clause 7: Push Back — 有具体问题直说，量化影响，不做 yes-machine

## 实现

调用 skills/verify-workflow-review/SKILL.md。
