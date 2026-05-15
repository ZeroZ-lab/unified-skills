---
description: 发布或导出检查 + 按风险升级的发布审计 → Go/No-Go → 归档
---

# Command: /ship

## Runtime Preflight

执行本命令前，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Pre-release audit and artifact export/publishing.

## Phases

### Phase 1: Pre-Release Preparation

**Agent:** 主 session
**Skills:** ship-workflow-ship（准备部分）
**Input:** 产物文件 + 04-review.md
**Process:**
1. 确认所有 Blocking issues 已修复
2. 准备发布清单
3. 生成变更摘要
**Output:** 发布准备状态

### Phase 2: Risk-Based Ship Audit

**Agents (selected by `ship-workflow-ship` minimum trigger rules):**
- ship-security-auditor（OWASP、输入边界、认证授权）
- ship-performance-auditor（关键路径、N+1查询、内存资源）
- ship-accessibility-auditor（WCAG合规、屏幕阅读器）
- ship-docs-auditor（CHANGELOG、README、API文档）
**Skills:** ship-workflow-ship（审计部分）
**Input:** 产物文件 + 04-review.md
**Output:** 已选 Auditor 审计报告

### Phase 3: Export / Publish

**Agent:** 主 session
**Skills:** ship-workflow-ship + ship-artifact-export（非 software）+ ship-ci-cd（software）
**Input:** 产物文件 + 审计报告
**Output:** docs/features/YYYYMMDD-<name>/05-ship.md

### Phase 4: Documentation Sync

**Agent:** 主 session
**Skills:** ship-workflow-doc-sync
**Output:** docs/features/YYYYMMDD-<name>/README.md

---

## Entry Conditions
- [ ] /review 已完成
- [ ] 所有 Blocking issues 已修复

## Exit Conditions
- [ ] 05-ship.md 存在
- [ ] README.md 已更新

## Next Steps
- If deploying → 监控 05-canary-report.md
- If exported → 交付产物

## Constitutional Rules
- CANON.md Clause 5: Verify Don't Assume — 发布前必须有验证证据
- CANON.md Clause 10: Every Feature Leaves a Trace — spec + plan + ADR + review + ship + 事后总结

## 实现

调用 skills/ship-workflow-ship/SKILL.md。
