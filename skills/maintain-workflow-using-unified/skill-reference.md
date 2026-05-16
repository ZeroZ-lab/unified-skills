# Using Unified — Skill Reference

本文件是 `maintain-workflow-using-unified/SKILL.md` 的辅助材料。主技能保留 compact-router-first 发现流程、loading tier、硬门和验证清单；需要完整技能速查、优先级、类型和平台适配时读取本文件。

## 技能分类速查

### Define 阶段（想法模糊、需要方案对比、收敛到规格）

- `define-cognitive-brainstorm` — 想法模糊、开放性问题、需要方案对比
- `define-workflow-refine` — 模糊想法收敛到 spec
- `define-workflow-spec` — 规格化文档

### Design 阶段（证据驱动的创作设计定稿）

- `design-workflow-design` — 证据驱动设计阶段总控和 gate
- `design-experience-interaction` — 基于证据的交互设计、流程和状态
- `design-visual-direction` — 基于证据的视觉方向和风格系统
- `design-content-script` — 基于证据的剧本设计、故事线、消息线
- `design-content-direction` — 基于证据的导演设计、页序推进、节奏
- `design-content-layout` — 基于证据的排版设计、构图、媒介适配
- `design-interactive-preview` — 交互式视觉对比、本地预览、方向选择

### Build 阶段（拆分任务、增量生成产物）

- `build-workflow-plan` — 拆分任务
- `build-workflow-execute` — 增量生成产物
- `build-quality-tdd` — 写逻辑代码（MUST）
- `build-cognitive-context` — 上下文混乱或输出质量下降
- `build-cognitive-source-driven` — 使用不熟悉的 API/框架
- `build-cognitive-execution-engine` — 执行引擎
- `build-cognitive-decision-record` — 面临技术选型或架构决策
- `build-infrastructure-git` — 版本控制操作
- `build-frontend-ui-engineering` — 构建/修改 UI 组件
- `build-frontend-browser-testing` — 浏览器自动化测试
- `build-backend-api-design` — 设计 API/接口/数据合约
- `build-backend-database` — 设计 schema/写迁移/优化查询
- `build-backend-service-patterns` — 服务模式和架构
- `build-content-writing` — 文档/文章/PPT 内容
- `build-content-layout` — 版式执行落地/信息层级

### Verify 阶段（质量把关、Bug 调查、审查）

- `verify-workflow-review` — 产物完成后质量把关
- `verify-workflow-spec-compliance` — 功能完整性审查
- `verify-quality-code-quality` — 代码质量审查
- `verify-workflow-debug` — 遇到 bug/测试失败/意外行为（MUST）
- `verify-frontend-accessibility` — 构建 UI 组件/表单/导航
- `verify-quality-integration-testing` — 集成测试
- `verify-quality-performance` — 性能不达标或上线前审查
- `verify-quality-security` — 涉及用户输入/认证/数据存储
- `verify-team-code-review-standards` — 代码审查标准
- `verify-team-skill-quality` — 创建/修改/审查 Agent Skill 或 `SKILL.md`
- `verify-content-review` — 内容审查
- `verify-visual-review` — 视觉审查
- `verify-workflow-receiving-review` — 接收审查反馈
- `verify-quality-simplify` — 代码变得复杂/重复/过度抽象

### Ship 阶段（发布检查、部署、监控）

- `ship-workflow-ship` — 审查通过后上线或交付
- `ship-infrastructure-ci-cd` — 设置/修改 CI/CD 管道
- `ship-infrastructure-deploy` — 部署操作
- `ship-artifact-export` — 产物导出
- `ship-workflow-canary` — 代码已部署需要持续验证
- `ship-workflow-land` — PR 合并到主分支并验证部署
- `ship-workflow-doc-sync` — 文档同步

### Maintain 阶段（可观测性、上下文管理、学习记录）

- `maintain-infrastructure-observability` — 可观测性
- `maintain-team-deprecation-migration` — 废弃迁移
- `maintain-workflow-context-save` — 保存工作上下文供后续恢复
- `maintain-workflow-context-restore` — 新 session 继续之前的工作
- `maintain-workflow-learn` — 发现项目模式/踩坑/偏好需要持久化
- `maintain-workflow-using-unified` — Session 启动引导和主动技能发现

### Reflect 阶段（事后回顾、文档工程）

- `reflect-team-retro` — 功能完成/里程碑达成/事故处理后复盘
- `reflect-team-documentation` — 记录架构决策或维护项目知识

## 技能优先级

当多个技能可能适用时：

1. **流程技能优先**（brainstorm、debug、tdd）— 决定如何做
2. **实现技能其次**（ui-engineering、api-design）— 指导执行

## 技能类型

- **刚性技能**（TDD、调试、审查）：严格遵循，不要适应掉纪律
- **柔性技能**（模式、设计）：根据上下文调整原则

技能本身会告诉你它是哪种类型。

## 用户指令

用户指令说明"做什么"，不是"怎么做"。"添加 X" 或 "修复 Y" 不意味着跳过工作流。

## 平台适配

技能使用 Claude Code 的工具名和约定。在其他平台上的等效方式：

- **Claude Code**：使用 `Skill` 工具调用技能。当技能被调用时，其内容会被加载并呈现——直接遵循。不要用 Read 工具读技能文件。
- **Codex CLI**：直接读取 `AGENTS.md`、`skills-router.json` 与 `skills/` 中的真实技能；如果宿主暴露技能入口，优先使用宿主入口，否则读取对应 `skills/<name>/SKILL.md`。Codex 不依赖 repo 内旧的命令薄包装或 wrapper skill 目录。
