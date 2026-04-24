# Agents — 并行审查角色

用于 review、plan、refine 和 ship 的多角色并行发散模式。15 个 agent 按工作流阶段分组。

## Review Army（审查阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| code-reviewer | 五轴审查（正确性、可读性、架构、安全、性能） | review --full |
| security-auditor | 安全审计（OWASP、威胁建模、密钥扫描） | review --full |
| test-engineer | 测试覆盖分析（happy path、边界、错误路径、并发） | review --full |
| review-accessibility-checker | 无障碍审查（WCAG、屏幕阅读器、表单错误、动态内容） | review --full（有 UI 变更时） |

## Plan Review Army（计划阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| plan-ceo-reviewer | CEO视角：市场价值、投资回报、战略对齐 | /plan 审查 |
| plan-eng-reviewer | 工程视角：可行性、技术复杂度、依赖风险 | /plan 审查 |
| plan-design-reviewer | 设计视角：用户体验、信息架构、交互流程 | /plan 审查 |
| plan-security-reviewer | 安全视角：数据暴露、认证授权、合规 | /plan 审查 |

## Refine Scout Army（提炼阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| refine-ceo-scout | CEO视角：商业可行性、市场定位、投资回报 | /refine Phase 1.6 |
| refine-eng-scout | 工程视角：技术可行性、实现复杂度、技术债务 | /refine Phase 1.6 |
| refine-design-scout | 设计视角：用户体验、信息架构、交互创新 | /refine Phase 1.6 |

## Ship Audit Army（发布阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| ship-security-auditor | 安全审计：OWASP、输入边界、认证授权、数据暴露 | /ship Phase B |
| ship-performance-auditor | 性能审计：关键路径、N+1查询、内存资源、Bundle影响 | /ship Phase B |
| ship-accessibility-auditor | 无障碍审计：WCAG合规、屏幕阅读器、表单错误 | /ship Phase B |
| ship-docs-auditor | 文档审计：CHANGELOG、README、迁移指南、API文档 | /ship Phase B |

## 使用方式

各 Army 的 agent 必须同时并行派发，各自产出独立报告，在主 session 合并。反馈按 Blocking / Important / Suggestion 三级分级。