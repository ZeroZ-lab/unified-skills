---
name: ship
description: 发布或导出检查 + 多角色发布审计 + Go/No-Go + 归档。使用 cuando 软件准备上线，或文档、文章、PPT、视觉稿准备交付时
---

# Ship — 发布与导出

加载 `ship-workflow-ship/SKILL.md`，按 spec 的 `artifact_type` 执行软件发布或非软件产物导出。

## 流程

1. 加载 `ship-workflow-ship/SKILL.md`
2. Phase A：预发检查（测试、构建、lint、基础设施）
3. Phase B：Ship Audit Army — 并行分派 4 个 auditor
4. Phase B.5：Staging 验证强制门
5. document/article/deck/visual 加载 `ship-artifact-export/SKILL.md`
6. Go/No-Go 决策 + 回滚或导出归档计划
7. 产出 `docs/features/<name>/ship.md` + README 聚合

## Ship Audit Army

| 角色 | Agent | 关注点 |
|------|-------|--------|
| Security | `agents/ship-security-auditor.md` | OWASP、输入边界、认证授权、数据暴露 |
| Performance | `agents/ship-performance-auditor.md` | 关键路径、N+1查询、Bundle影响 |
| Accessibility | `agents/ship-accessibility-auditor.md` | WCAG合规、屏幕阅读器、表单错误 |
| Docs | `agents/ship-docs-auditor.md` | CHANGELOG、README、迁移指南 |

## 同时加载

- `CANON.md` — 宪法第 10 条（Every Feature Leaves a Trace）
