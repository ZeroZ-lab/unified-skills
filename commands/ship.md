---
description: 发布或导出检查 + 多角色发布审计 → Go/No-Go → 归档
---

# Command: /ship

## Goal

Pre-release audit and artifact export/publishing.

## Phases

### Phase 1: Pre-Release Preparation

**Agent:** 主 session
**Skills:** ship-workflow-ship（准备部分）
**Input:** 产物文件 + review.md
**Process:**
1. 确认所有 Blocking issues 已修复
2. 准备发布清单
3. 生成变更摘要
**Output:** 发布准备状态

### Phase 2: Ship Audit (Parallel)

**Agents (parallel dispatch):**
- ship-security-auditor（OWASP、输入边界、认证授权）
- ship-performance-auditor（关键路径、N+1查询、内存资源）
- ship-accessibility-auditor（WCAG合规、屏幕阅读器）
- ship-docs-auditor（CHANGELOG、README、API文档）
**Skills:** ship-workflow-ship（审计部分）
**Input:** 产物文件 + review.md
**Output:** 各 Auditor 审计报告

### Phase 3: Export / Publish

**Agent:** 主 session
**Skills:** ship-workflow-ship + ship-artifact-export（非 software）+ ship-ci-cd（software）
**Input:** 产物文件 + 审计报告
**Output:** docs/features/YYYYMMDD-<name>/ship.md

### Phase 4: Documentation Sync

**Agent:** 主 session
**Skills:** ship-workflow-doc-sync
**Output:** docs/features/YYYYMMDD-<name>/README.md

---

## Entry Conditions
- [ ] /review 已完成
- [ ] 所有 Blocking issues 已修复

## Exit Conditions
- [ ] ship.md 存在
- [ ] README.md 已更新

## Next Steps
- If deploying → 监控 canary-report.md
- If exported → 交付产物

## Constitutional Rules
- CANON.md Clause 8: 不发布未经审计的产物

## 实现

调用 .agents/skills/ship/SKILL.md。
