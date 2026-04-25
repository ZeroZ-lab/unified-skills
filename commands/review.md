---
description: 按产物类型审查（软件五轴 / 内容 / 视觉）+ 多角色并行审查
---

# Command: /review

## Goal

Multi-perspective artifact review with severity-graded feedback.

## Phases

### Phase 1: Artifact Analysis

**Agent:** 主 session
**Skills:** verify-workflow-review（路由部分）
**Input:** 产物文件 + 02-plan.md
**Process:**
1. 读取 artifact_type
2. 确定审查策略：software → 五轴审查；document → 内容审查；visual → 视觉审查
**Output:** 审查策略决策

### Phase 2: Multi-Role Review (Parallel)

**Agents (parallel dispatch, software 类型):**
- review-code-reviewer（正确性、可读性、架构、安全、性能）
- review-security-auditor（OWASP、威胁建模、密钥扫描）
- review-test-engineer（happy path、边界、错误路径、并发）
- review-accessibility-auditor（WCAG、屏幕阅读器，有 UI 变更时）
**Skills:**
- verify-workflow-review
- verify-team-code-review-standards（code-reviewer）
- verify-quality-security（security-auditor）
- verify-frontend-accessibility（accessibility-auditor）
**Input:** 产物文件
**Output:** 各 Reviewer 独立反馈

### Phase 3: Merge Feedback and Report

**Agent:** 主 session
**Skills:** verify-workflow-review（合并部分）
**Input:** 各 Reviewer 反馈
**Output:** docs/features/YYYYMMDD-<name>/review.md
**Validation:**
- [ ] 报告包含所有 Reviewer 反馈
- [ ] Blocking issues 清晰标注

---

## Entry Conditions
- [ ] 产物已完成（/build 已完成）
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] review.md 存在
- [ ] 反馈已按 Blocking / Important / Suggestion 分级

## Next Steps
- If no Blocking → /ship
- If has Blocking → /build（修复后重新 /review）

## Constitutional Rules
- CANON.md Clause 6: 审查不是走过场
- CANON.md Clause 7: Blocking issues 必须修复

## 实现

调用 .agents/skills/review/SKILL.md。
