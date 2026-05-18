# Agents — 多角色风险升级体系

agent 按职责分组，用于 define、design、build、review、refine 和 ship 的阶段执行与风险升级审查。Unified 不默认全角色参与；阶段技能先按风险选择必要角色，只有 `--full`、大型/高风险变更、对抗性审核或发版前才全开。`agents/` 只定义 persona，真正调用合同必须出现在对应 `skills/` 或技能辅助文件中。

`/brainstorm` 当前没有专属 persona；它由 current agent 直接执行 `define-cognitive-brainstorm`。

## Design Review（设计阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| design-reviewer | 设计阶段审查：证据质量、交互、视觉、排版、剧本、导演、设计边界 | /design 审查 |

## 核心工程角色（跨阶段复用）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| requirements-analyst | 需求澄清、5W1H、非功能需求识别、MoSCoW 优先级、利益相关者识别、spec 生成 | /refine |
| task-planner | 任务分解、依赖分析、并行安全性 | /plan, /build |
| software-engineer | TDD 开发、API/数据库/前后端实现 | /build (software) |
| data-architect | 数据建模、schema 设计、迁移策略 | /build (软件子领域) |
| api-designer | API 接口设计、契约定义、版本管理 | /build (软件子领域) |
| content-writer | 文档/文章/PPT 叙事创作 | /design, /build (document/article/deck) |
| visual-designer | 版式布局、视觉层级、交互设计 | /design, /build (visual/deck) |

## Review Army（审查阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| review-spec-compliance-auditor | Spec 合规性审查（需求覆盖、验收标准、scope creep） | review 高风险或 `--full` Phase 1 |
| review-code-quality-auditor | 五轴审查（正确性、可读性、架构、安全、性能） | review 标准质量审查或 `--full` Phase 2 |
| review-content-auditor | 内容审计（受众、逻辑、事实、语气、完整性） | review `document` / `article` / `deck` |
| review-visual-auditor | 视觉审计（层级、对齐、可读性、导出质量） | review `deck` / `visual` |
| review-security-auditor | 安全审计（OWASP、威胁建模、密钥扫描） | 安全敏感或 `--full` |
| review-test-engineer | 测试覆盖分析（happy path、边界、错误路径、并发） | 测试覆盖不确定或 `--full` |
| review-accessibility-auditor | 无障碍审查（WCAG、屏幕阅读器、表单错误、动态内容） | UI 变更或 `--full` |

## Plan Review Army（计划阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| plan-ceo-reviewer | CEO视角：市场价值、投资回报、战略对齐 | /plan 审查 |
| plan-eng-reviewer | 工程视角：可行性、技术复杂度、依赖风险 | /plan 审查 |
| plan-design-reviewer | 设计视角：plan 是否忠实消费已批准 design 约束 | /plan 审查 |
| plan-security-reviewer | 安全视角：数据暴露、认证授权、合规 | /plan 审查 |

## Refine Scout Army（提炼阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| refine-ceo-scout | CEO视角：问题真实度、方案杠杆、优先级、成功标准、范围纪律 | /refine Phase 1.6 |
| refine-eng-scout | 工程视角：可行性、复杂度、已有方案、依赖风险、替代路径 | /refine Phase 1.6 |
| refine-design-scout | 设计视角：用户路径、心智模型、关键交互/结构、设计范围、外部模式适配 | /refine Phase 1.6 |
| refine-content-scout | 内容视角：目标读者、叙事结构、证据形态、媒介选择、范围纪律 | /refine Phase 1.6 |

## Ship Audit Army（发布阶段）

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| ship-security-auditor | 安全审计：OWASP、输入边界、认证授权、数据暴露 | /ship Phase B |
| ship-performance-auditor | 性能审计：关键路径、N+1查询、内存资源、Bundle影响 | /ship Phase B |
| ship-accessibility-auditor | 无障碍审计：WCAG合规、屏幕阅读器、表单错误 | /ship Phase B |
| ship-docs-auditor | 文档审计：CHANGELOG、README、迁移指南、API文档 | /ship Phase B |
| ship-artifact-export-auditor | 非软件交付 QA：source/final 对齐、格式、归档、交付包验证 | /ship Phase B（非 software） |

## 使用方式

各 Army 的 agent 由对应阶段技能按风险升级规则选择。并行只用于已选角色；未被选中的角色不需要占位报告。已选角色各自产出独立报告，在主 session 合并。反馈按 Blocking / Important / Suggestion 三级分级。
