---
description: 发布或导出检查 + 多角色发布审计 → Go/No-Go → 归档
---
调用 skills/ship-workflow-ship/SKILL.md。

## 流程

1. Phase A：预发检查（测试、构建、lint、基础设施）
2. Phase B：Ship Audit Army — 并行分派 4 个 auditor 做发布前审计
3. Phase B.5：Staging 验证（强制）
4. Phase C：Go/No-Go 决策 + 回滚计划
5. Phase D：文档聚合
6. software 执行发布检查；document/article/deck/visual 加载 ship-artifact-export 导出最终交付物
7. 产出 `docs/features/<name>/ship.md` + README 聚合

## 发布后闭环

发布完成后，可继续使用以下技能：

| 技能 | 命令 | 作用 |
|------|------|------|
| `ship-workflow-canary` | — | 金丝雀监控：curl 关键端点，比对基线，输出健康报告 |
| `ship-workflow-land` | — | 合并 PR → 等 CI → 验证生产 → 部署报告 |
| `ship-workflow-doc-sync` | — | 发布后文档同步：交叉引用变更，更新过时文档 |

## Ship Audit Army

| 角色 | Agent | 关注点 |
|------|-------|--------|
| Security | `agents/ship-security-auditor.md` | OWASP、输入边界、认证授权、数据暴露、依赖 |
| Performance | `agents/ship-performance-auditor.md` | 关键路径、N+1查询、内存资源、Bundle影响 |
| Accessibility | `agents/ship-accessibility-auditor.md` | WCAG合规、屏幕阅读器、表单错误、动态内容 |
| Docs | `agents/ship-docs-auditor.md` | CHANGELOG、README、迁移指南、API文档 |

反馈按 Blocking / Important / Suggestion 三级分级。
