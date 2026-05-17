# Unified Skills

> 宪法 + 阶段协议 + 角色责任 + 技能方法论 = 按阶段加载的多产物开发技能套件。支持 Claude Code 和 Codex CLI。

## 如果你是一个 AI Agent

停。先读完这一节再做任何事。

Unified 是一套行为塑造技能——每个 SKILL.md 里的流程、红旗表、常见说辞表都是经过设计的，不是随意写的散文。随意修改措辞会改变 agent 行为，产生无法预料的后果。

**修改技能之前：**
1. 先通读整个技能。理解每个章节为什么存在。
2. 读 [CANON.md](CANON.md)。技能继承宪法的 10 条规则——技能级别的步骤不能与宪法冲突。
3. 跑 `./validate`（见下方验证章节）。提交前修掉所有违规。
4. 新增技能时，用 `templates/feature/` 作为起点。
5. 把完整 diff 给你的人类 partner 看过，获得明确同意。

**创建 PR 之前：**
1. 确认无 stub 残留——每个步骤必须有可操作的内容，不能是占位符。
2. 确认命名规范：`<phase>-<role>-<skill>/SKILL.md`。
3. 确认技能包含：入口/出口条件、可操作流程、常见说辞表、红旗清单、验证清单；强纪律技能必须额外包含 Iron Law。

## Context Runtime（hook 失效时仍然适用）

每次新任务开始时，先用 `skills-router.json` 做轻量路由，再按需读取完整 `SKILL.md`。这是项目入口合同的一部分，不依赖 SessionStart hook 是否成功注册。

- 先读取 `skills-router.json` 获取 compact routing surface。
- 分析 6 个维度：阶段、产物类型、触发词、上下文信号、风险因素、loading tier。
- 声明 loading tier 和选中技能原因：`light` / `standard` / `expanded` / `full`。
- `light`: router-only 或少量当前事实；`standard`: 1 个主技能 + 最多 1 个专项；`expanded`: 1 个主技能 + 最多 2 个专项；`full`: 仅限 `--full`、对抗性审核、全身体检、高风险发版或用户明确要求。
- 只有当 `skills-router.json` 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。
- 高风险、安全、UI、性能、发布等扩展必须说明触发原因。
- 文档产物先判断槽位，再判断文件：`root docs` / `project docs` / `feature docs` / `bug docs`。
- 默认 `doc_intent: feature_only`，只有当本次变更触发项目长期真相变化时，才升级为 `feature_plus_project` 或 `project_only`。

## 宪法

[CANON.md](CANON.md) — 10 条不可变规则。技能可以添加纪律，但绝不能放松宪法条款。

## 项目结构

```
unified/
├── CANON.md                 宪法（10 条，最高优先级）
├── AGENTS.md                入口配置（本文件）
├── CLAUDE.md                Claude 侧指针文件（指向 AGENTS.md）
│
├── skills/                  技能目录 / 阶段分组
│   ├── define/              定义
│   ├── design/              设计
│   ├── build/               构建
│   ├── verify/              验证
│   ├── ship/                发布
│   ├── maintain/            维护
│   └── reflect/             复盘
│
├── commands/                命令入口（Claude Code 斜杠命令）
├── agents/                  角色目录
├── templates/               模板类别（feature + bug + root + project + maintain）
├── references/              编排模式 + 设计最佳实践来源合同
└── docs/                    设计文档
```

## 技能按阶段分组

```
define/    → refine（提炼）、spec（规格）、brainstorm（头脑风暴）
design/    → design（设计总控）、interaction（交互设计）、visual-direction（视觉设计）、
             script（剧本设计）、direction（导演设计）、layout（排版设计）、
             interactive-preview（交互式视觉对比）
build/     → plan（计划）、execute（执行）、tdd（测试驱动）、context（上下文）、
             source-driven（文档驱动）、execution-engine（执行引擎）、
             decision-record（决策记录）、git（版本控制）、
             ui-engineering（UI 工程）、browser-testing（浏览器测试）、
             api-design（API 设计）、database（数据库）、service-patterns（服务模式）、
             content-writing（内容写作）、content-layout（版式）
verify/    → review（审查）、spec-compliance（功能完整性）、code-quality（代码质量）、debug（调试）、
             accessibility（无障碍）、integration-testing（集成测试）、
             performance（性能）、security（安全）、code-review-standards（审查标准）、
             content-review（内容审查）、visual-review（视觉审查）、
             skill-quality（Skill 质量审查）、receiving-review（接收审查反馈）、simplify（代码简化）
ship/      → ship（发布）、ci-cd（持续集成部署）、deploy（部署）、artifact-export（产物导出）、
             canary（金丝雀监控）、land（合并部署）、doc-sync（文档同步）
maintain/  → observability（可观测性）、deprecation-migration（废弃迁移）、
             context-save（保存上下文）、context-restore（恢复上下文）、learn（跨 session 学习）、
             goal（目标管理）、using-unified（Session 启动引导）
reflect/   → retro（回顾）、documentation（文档）
```

## 命令映射

| 命令 | 加载的技能 | 产出 | 文档路径 |
|------|-----------|------|----------|
| `/refine` | define-workflow-refine | 规范 spec | `docs/features/YYYYMMDD-<name>/01-spec.md` |
| `/design` | design-workflow-design + artifact_type 对应 design 技能 + codex-rescue（可选，视觉 mockup） | 证据驱动的创作设计定稿 + Codex 视觉 mockup（可选） + 项目级约束同步 | `docs/features/YYYYMMDD-<name>/02-design.md` + `assets/mockup-direction-{1,2,3}.png` + `assets/design-tokens-extracted.json`（可选） + `DESIGN.md` |
| `/plan` | build-workflow-plan | 任务计划 + 项目级文档同步计划 | `docs/features/YYYYMMDD-<name>/03-plan.md` |
| `/build` | build-workflow-execute + artifact_type 对应技能 | 软件/内容产物+验证+ADR | `docs/features/YYYYMMDD-<name>/adr/` |
| `/review` | verify-workflow-review + artifact_type 对应审查 | 审查报告 + 文档合同兑现检查 | `docs/features/YYYYMMDD-<name>/04-review.md` |
| `/ship` | ship-workflow-ship + artifact-export（非 software） | 发布/导出记录+README+文档同步收口 | `docs/features/YYYYMMDD-<name>/05-ship.md` |
| `/save` | maintain-workflow-context-save | 工作上下文 checkpoint | `.claude/checkpoints/YYYYMMDD-HHMMSS-{title}.md` |
| `/restore` | maintain-workflow-context-restore | 恢复上下文 | — |
| `/learn` | maintain-workflow-learn | 学习记录管理 | `.claude/learnings.jsonl` |
| `/brainstorm` | define-cognitive-brainstorm | 2-3 方案 + 推荐 + 不做清单 | `docs/features/YYYYMMDD-<name>/00-brainstorm.md` |
| `/help` | — | 能力概览 | — |

### Codex 使用方式

Codex 侧不再维护 repo 内 `$command` 薄包装入口。当前模型是：

- 项目约束入口：`AGENTS.md`
- 真实技能目录：`skills/`
- Claude 专属补充：`CLAUDE.md` 仅作指针

如果需要理解工作流阶段，对照上方命令映射即可；Codex 直接消费真实技能，不再依赖 repo 内旧的薄包装目录。

## Hooks（安全护栏 + 可观测性）

Unified Skills 有 6 个 hooks，在两个平台上行为有差异：

| Hook | Claude Code | Codex CLI |
|------|-------------|-----------|
| SessionStart | 自动注入 Boot Kernel + router 加载提示 | 自动注入 Boot Kernel + router 加载提示（需启用 hooks） |
| careful（破坏性命令拦截） | `permissionDecision: "ask"` — 提示用户确认 | `permissionDecision: "deny"` — 直接阻止（fail-closed） |
| freeze（编辑范围冻结） | `permissionDecision: "deny"` — 阻止范围外编辑 | `permissionDecision: "deny"` — 阻止范围外编辑 |
| agent-dispatch（派出通知） | `additionalContext` — 显示 subagent 角色和职责 | Codex 暂未适配（使用 `statusMessage` 模式） |
| doc-tracker（阶段进度） | `additionalContext` — 写入阶段文档时显示链进展 | Codex 暂未适配 |
| phase-stop（save 提醒） | `additionalContext` — 检查未保存工作上下文并建议 /save | Codex 暂未适配 |

**Codex hooks 激活：** 需在 `.codex/config.toml` 的 `[features]` 表中设置 `hooks = true`，或通过 CLI 参数 `--enable hooks` 临时启用。

**重要差异：** careful hook 在 Codex 上使用 fail-closed 模式（阻止破坏性命令而非提示确认），因为确认型交互语义在 Codex 上并不稳定。

spec 必须声明 `artifact_type`，默认 `software`；可选 `software` / `document` / `article` / `deck` / `visual`。后续阶段按该字段加载 design、软件、内容、版式、审查或导出技能。

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

项目级文档映射使用固定文件路径，不接受“需要更新文档”这种空话：

- `README.md` — 项目是什么、怎么启动、核心命令、项目入口
- `AGENTS.md` — agent 工作合同、运行方式、项目约束
- `CHANGELOG.md` — 用户可感知变化或 release 记录
- `DESIGN.md` — 跨 feature 设计 token / 长期设计约束
- `docs/architecture/system-overview.md` — 系统目标、边界、核心组件
- `docs/architecture/module-boundaries.md` — 模块职责、依赖方向、禁止跨层
- `docs/architecture/deployment-and-runtime.md` — 环境、配置、部署、回滚
- `docs/architecture/observability-and-runbook.md` — 指标、告警、排障入口、故障步骤
- 可选扩展：`docs/architecture/api-contracts.md`、`docs/architecture/data-model.md`、`docs/architecture/security-boundaries.md`

`/design` 只定交互、视觉、排版、剧本、导演等创作设计，不写实现步骤或任务分解。Design required 时必须执行 Design Best-Practice Scan，并在 `02-design.md` 中写明 Design References、Pattern Synthesis、Adopt / Reject 和 Evidence Quality；缺少证据不得批准。

`/build` 会读取 `03-plan.md` 总控计划；大型/并行任务还会读取 `plans/*.md` 子计划，并只在 `Parallel Execution Matrix` 证明 `parallel_safe` 时并行分派。

多产物扩展技能采用角色化方法论：先定义角色责任、长期原则和决策框架，再给出流程和验证证据；它们不是工具清单。

### Agent Persona 调用规则

`agents/` 是 persona / 职责定义层，不是独立路由器。真正的调用时机必须写在对应阶段技能或技能辅助文件中；`commands/` 和 `agents/README.md` 只能镜像阶段技能，不创建额外规则。

- 简单认知型阶段（如 `/brainstorm`）可以由 current agent 直接执行，不需要专属 persona。
- 阶段技能决定是否按 `artifact_type`、风险或任务性质选择 persona。
- persona 可以声明常用/必需 skills，但不能绕过阶段技能自行扩大 scope。
- `agents/README.md` 中声明有调用时机的 persona，必须能在 `skills/` 中找到对应消费点。

### 角色审查升级规则

Unified 使用 Risk-Based Role Escalation，而不是所有阶段默认全角色参与：

- 小型变更（单文件、纯配置、无 UI/安全/合规敏感）可跳过 army，只保留当前阶段的自审和验证证据。
- 标准变更使用最小必要角色；例如 `/refine` 和 `/plan` 至少覆盖 CEO + Eng 视角，`/review` 先完成两阶段审查，`/ship` 至少覆盖 security + docs 审计。
- 高风险变更按风险维度加角色：UI 加 design/accessibility，安全或合规加 security，性能敏感加 performance，测试覆盖不确定加 test。
- 只有大型变更、高风险发版、对抗性审核、全身体检，或用户明确指定 `--full` 时，才开启该阶段全部相关角色。
- 并行只用于已被阶段技能选中的角色；未被选中的角色不需要产出占位反馈。

`/refine` 使用 Unified 原生 External Scan：按 `artifact_type` 搜索已有方案、事实来源、设计/技术模式，并把结果分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject，再交给 Idea Scout Army 审查。

`/refine` 的 External Scan 不替代 `/design` 的设计扫描。`/design` 使用 `references/design-best-practices.md` 的 4+1 来源模型：Enterprise Product Patterns、Official Systems / Platform Rules、Methods / Theory / Style Schools、Anti-patterns / Verification、Local Project Truth。

## 文档槽位合同

skills 运行工作流时，文档必须先落到正确槽位，再决定具体文件。

- `root docs`
  - `README.md`
  - `AGENTS.md`
  - `CHANGELOG.md`
  - `DESIGN.md`
- `project docs`
  - `docs/architecture/*.md`
- `feature docs`
  - `docs/features/YYYYMMDD-<name>/*`
- `bug docs`
  - `docs/bugs/<name>/*`

默认只写 `feature docs`。只有 spec 里的 `Documentation Impact` 明确要求时，才同步 `root docs` 或 `project docs`。

阶段责任固定如下：

- `/refine`
  - 必须在 `01-spec.md` 写 `Documentation Impact`
  - 如果 `project_truth_changed: yes`，必须列出 `affected_project_docs`
- `/design`
  - 只负责 `DESIGN.md` 这类项目级设计真相，不替代其他 project doc sync
- `/plan`
  - 必须在 `03-plan.md` 写 `Project Doc Sync Plan`
  - 必须写清 `Must update`、`Stage owner`、`Verification method`、`Deferred docs with reason`
- `/review`
  - 必须检查 `Documentation Compliance`
  - spec 说要同步但未兑现时，审查不得通过
- `/ship`
  - 必须写 `Documentation Sync`
  - 必须收口 `CHANGELOG.md` / `README.md` / 其他受影响 project docs 的状态

## 文档产出链

```
README.md                     ← project entry truth（按需同步，不属于单一 feature）
AGENTS.md                     ← agent contract truth（按需同步，不属于单一 feature）
CHANGELOG.md                  ← release / user-visible change truth（按需同步）
DESIGN.md                     ← /design（项目级设计系统，Google Stitch token 格式，自动同步）
docs/architecture/*.md        ← project docs（系统长期真相，按需同步）

docs/features/YYYYMMDD-<name>/
├── 00-brainstorm.md        ← /brainstorm
├── 01-spec.md              ← /refine
├── 02-design.md            ← /design
├── 03-plan.md              ← /plan
├── plans/*.md              ← /plan（大型/并行任务的子计划）
├── adr/<num>.md            ← /build（决策时）
├── 04-review.md            ← /review
├── 05-ship.md              ← /ship
├── 06-canary-report.md     ← ship-workflow-canary
├── 07-deploy-report.md     ← ship-workflow-land
└── README.md               ← /ship 后聚合

docs/bugs/<name>/
├── 01-root-cause.md        ← verify-workflow-debug Phase 1-3
└── 02-fix-plan.md          ← verify-workflow-debug Phase 4
```

`01-spec.md`、`03-plan.md`、`04-review.md`、`05-ship.md` 必须串起 project doc sync：

- `01-spec.md` → `Documentation Impact`
- `03-plan.md` → `Project Doc Sync Plan`
- `04-review.md` → `Documentation Compliance`
- `05-ship.md` → `Documentation Sync`

## 约定

### 命名规范
- 技能目录：`<阶段>-<角色>-<技能名>/` —— 每个目录必须有一个 `SKILL.md`，可包含辅助文件
- 阶段：`define` / `design` / `build` / `verify` / `ship` / `maintain` / `reflect`
- 角色：`workflow` / `experience` / `frontend` / `backend` / `quality` / `cognitive` / `infrastructure` / `team` / `content` / `visual` / `artifact`
- 技能名：kebab-case，描述动作（如 `tdd`、`debug`、`api-design`）

### SKILL.md 格式
- 每个技能必须包含中文语义章节：入口/出口条件、何时不使用、可操作流程、常见说辞表、红旗清单、验证清单
- 验证失败处理用于 workflow / gatekeeping / 高风险技能；不强制所有辅助技能重复该章节
- 引用其他技能用技能名，不用文件路径
- 强制纪律类技能（TDD、调试、审查、发布）必须有 Iron Law 章节
- 辅助文件用于下沉长模板、长示例、评分表或证据格式；主 `SKILL.md` 应保留行为流程和硬门
- 技能目录下的辅助 `.md` 文件必须由主 `SKILL.md` 明确引用，并纳入 `skills-lock.json` 的 `auxiliaryHashes`

### 命令
- `commands/` 下每个命令一个 `.md` 文件（Claude Code 斜杠命令）
- 命令加载技能，但不重复技能内容

## 验证

```bash
./validate
```

## 边界

### 始终要做
- 新增技能必须遵循命名规范
- 引用 CANON.md 而不是重复宪法条款
- 引用其他技能名而不是复制其内容
- 用 `templates/` 下的模板作为起点
- 调用技能前先通读整个技能
- 实现非平凡变更前先陈述假设

### 绝不能做
- 不能添加"空泛建议"而非可操作流程的技能
- 不能添加仅服务特定项目/团队/领域的技能——这类技能属于独立插件
- 不能在技能间重复内容——用引用代替
- 不能在技能中放松宪法条款。技能只能增加纪律，不能减少
- 不能在未理解其行为塑造目的的情况下修改红旗表或常见说辞表
- 不能替换"human partner"的措辞——这是有意为之，不可与"the user"互换
- 不能引入第三方依赖。Unified 设计为零依赖

## 开发注意事项

### 近期复盘：合同漂移修复后的硬经验

- `./validate` 通过不代表合同一致。改动技能、包装、根文档、hooks 行为或产物链时，必须额外检查：
  - `skills-index.json` 是否仍与 `skills/` 中的真实技能集一致
  - 根文档与包装层是否仍引用同一产物路径（如 `05-ship.md`）
  - 安全相关行为说明是否仍与真实 hook 实现一致
- `skills-index.json` 不是说明性文件，而是默认技能发现路径的一部分。新增、重命名、删除技能后，必须同步更新：
  - `by_phase`
  - 其他索引段中的技能引用
  - `skill_descriptions`
- 入口收口后，`AGENTS.md` 是统一项目约束源，`CLAUDE.md` 只保留指针职责。改动入口文档时，不要再把完整合同复制回 `CLAUDE.md`。
- 历史设计文档会反向污染当前合同。旧 spec/plan/优化报告里如果保留过时方案，必须显式标注“历史 / 已过期”，不能让它们继续像当前真相一样表述。
- 改动任何 `SKILL.md` 或技能辅助 `.md` 文件后，除了跑 `./validate`，还要确认 `skills-lock.json` 中 `computedHash` / `auxiliaryHashes` 已同步更新；否则仓库会在最后一步才暴露漂移。

### 自动化工具使用（v2.15.0+）

为避免合同漂移，新增或修改技能后必须：

1. **版本同步** - 发版时运行：
   ```bash
   bash scripts/sync-version.sh
   ```

2. **索引更新** - 修改技能后运行：
   ```bash
   bash scripts/generate-index.sh
   ```

3. **验证通过** - 运行完整验证：
   ```bash
   ./validate
   ```

这些工具可以防止 80% 的常见合同漂移问题：

| 问题类型 | 手动修复 | 自动化工具 |
|----------|----------|------------|
| 版本号不一致 | 手动编辑 3 个文件 | `sync-version.sh` |
| 索引漂移 | 手动更新 skills-index.json | `generate-index.sh` |
| 技能缺失 | 人工检查 | `validate` 自动检测 |

**何时使用自动化工具：**

- **发版前:** 运行 `sync-version.sh` 确保版本一致
- **修改技能后:** 运行 `generate-index.sh` 更新索引
- **提交前:** 运行 `validate` 确保无漂移
- **CI/CD:** 集成 `validate` 作为质量门控

技能支持多平台挂载：

- **Claude Code**: `commands/` 提供斜杠命令入口，`skills/` 是真实技能目录
- **Codex CLI**: 直接读取 `AGENTS.md` 与 `skills/`，不再维护 repo 内薄包装命令目录

修改**实时生效**。这意味着：
- 对 SKILL.md 的修改在下一次调用时立即生效
- 重构期间的破坏性变更可能导致并行 session 出错
- 大规模修改前先在隔离环境中测试
