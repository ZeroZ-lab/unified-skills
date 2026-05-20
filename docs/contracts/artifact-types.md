# Artifact Types & Documentation Impact

> 本文件由 `/refine`、`/design`、`/plan` 阶段技能按需加载，不在 CLAUDE.md 中全量引用。

## artifact_type 声明

spec 必须声明 `artifact_type`，默认 `software`。**当前 runtime 的可执行值** 仍是 `software` / `document` / `article` / `deck` / `visual`，因为现有 build/review/export 技能直接消费这些值。

## Canonical 一级交付类

项目级工作流语义的 **canonical 一级交付类** 收敛为：

- `software` → 可运行、可交互、需要测试和发布的系统产物
- `content` → 主要给人读、讲、学的内容型产物（兼容映射：`document` / `article` / `deck`）
- `visual` → 主要给人看、感受、导出的视觉型产物（兼容映射：`visual`；`media` 作为后续 subtype 讨论）

第一阶段兼容迁移规则：

- feature spec 仍可继续使用现有 `artifact_type` 可执行值
- 当需要表达长期工作流真相、角色矩阵或 pipeline 语义时，用 canonical 一级交付类 `software / content / visual` 讨论
- 后续阶段按 `artifact_type` 加载 design、软件、内容、版式、审查或导出技能；在项目级合同里，用 canonical 一级交付类解释为什么这样路由

## Documentation Impact

spec 还必须声明 `Documentation Impact`：

- `doc_intent: feature_only` — 默认。只更新本次 feature 证据链。
- `doc_intent: feature_plus_project` — 除 feature 证据链外，还要同步受影响的项目级真相文档。
- `doc_intent: project_only` — 纯项目级文档/合同改造，不产生新的 feature 私有产物。

只有当以下长期真相变化时，才允许并要求进入 `feature_plus_project` 或 `project_only`：

- 公共 API / CLI / 用户使用方式变化
- 启动 / 安装 / 配置 / 部署 / 环境变量变化
- 跨 feature 设计 token 或长期设计约束变化
- 系统边界 / 模块职责 / 依赖方向变化
- 运行 / 监控 / 安全 / 回滚规则变化
- 引入新的长期约定，需要后续 feature 持续遵守

## 项目级文档映射

项目级文档映射使用固定文件路径，不接受"需要更新文档"这种空话：

- `README.md` — 项目是什么、怎么启动、核心命令、项目入口
- `AGENTS.md` — agent 工作合同、运行方式、项目约束
- `CHANGELOG.md` — 用户可感知变化或 release 记录
- `DESIGN.md` — 跨 feature 设计 token / 长期设计约束
- `docs/architecture/system-overview.md` — 系统目标、边界、核心组件
- `docs/architecture/module-boundaries.md` — 模块职责、依赖方向、禁止跨层
- `docs/architecture/deployment-and-runtime.md` — 环境、配置、部署、回滚
- `docs/architecture/observability-and-runbook.md` — 指标、告警、排障入口、故障步骤
- 可选扩展：`docs/architecture/api-contracts.md`、`docs/architecture/data-model.md`、`docs/architecture/security-boundaries.md`

## 阶段特定规则

`/design` 只定交互、视觉、排版、剧本、导演等创作设计，不写实现步骤或任务分解。Design required 时必须执行 Design Best-Practice Scan，并在 `02-design.md` 中写明 Design References、Pattern Synthesis、Adopt / Reject 和 Evidence Quality；缺少证据不得批准。

`/build` 会读取 `03-plan.md` 总控计划；大型/并行任务还会读取 `plans/*.md` 子计划，并只在 `Parallel Execution Matrix` 证明 `parallel_safe` 时并行分派。

多产物扩展技能采用角色化方法论：先定义角色责任、长期原则和决策框架，再给出流程和验证证据；它们不是工具清单。
