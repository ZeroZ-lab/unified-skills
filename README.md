# Unified Skills

> 宪法 + 53 技能 + 12 命令 + 24 角色：一套面向 AI Agent 的阶段化、多产物开发技能系统。

Unified Skills 把需求提炼、设计、计划、构建、验证、发布和维护收束到同一套纪律中。它同时支持 Claude Code 与 Codex CLI：Claude Code 通过斜杠命令进入工作流，Codex CLI 直接读取 `AGENTS.md` 与 `skills/` 中的真实技能。

## 核心价值

- **一致的行为约束**：所有技能继承 `CANON.md` 的 10 条宪法，避免不同阶段、不同工具各说各话。
- **阶段化加载**：按当前任务只加载需要的技能，减少上下文噪声，同时保留完整产物链路。
- **多产物支持**：同一工作流覆盖 `software`、`document`、`article`、`deck`、`visual` 五类产物。
- **证据驱动设计**：`/design` 要求 Design Best-Practice Scan，明确 Adopt / Reject 与证据质量。
- **验证优先**：从 TDD、审查、调试到发布审计，每一步都要求可复核证据，而不是“应该可以”。
- **跨平台入口清晰**：Claude Code 使用 `commands/`；Codex CLI 使用 `AGENTS.md` + `skills/`，不依赖 repo 内薄包装命令。

## 目录

- [10 秒上手](#10-秒上手)
- [什么时候用哪个命令](#什么时候用哪个命令)
- [工作流](#工作流)
- [技能版图](#技能版图)
- [安装](#安装)
- [平台差异](#平台差异)
- [项目结构](#项目结构)
- [文档产出链](#文档产出链)
- [贡献与验证](#贡献与验证)
- [FAQ](#faq)

## 10 秒上手

### Claude Code

```bash
claude plugin add https://github.com/ZeroZ-lab/unified-skills
# 重启 session 后使用：/refine → /design → /plan → /build → /review → /ship
```

也可以使用 skills CLI：

```bash
npx skills add ZeroZ-lab/unified-skills
```

### Codex CLI

```bash
git clone https://github.com/ZeroZ-lab/unified-skills.git
cd unified-skills
```

Codex 侧的入口是：

- 项目约束：`AGENTS.md`
- 真实技能目录：`skills/`
- Hooks 配置：在 `.codex/config.toml` 中启用 `codex_hooks = true`

## 什么时候用哪个命令

| 目标 | Claude Code 命令 | 输出 / 结果 |
|------|------------------|-------------|
| 模糊想法需要发散方案 | `/brainstorm` | 2–3 个方案、推荐方案、不做清单 |
| 模糊想法需要收敛规格 | `/refine` | `01-spec.md`，含 `artifact_type` |
| 规格已批准，需要定创作设计 | `/design` | `02-design.md`，含设计证据、采纳与拒绝理由 |
| 规格 / 设计已明确，需要拆任务 | `/plan` | `03-plan.md` 与可选 `plans/*.md` |
| 计划已批准，需要实现产物 | `/build` | 软件 / 内容产物、验证证据、必要 ADR |
| 产物完成，需要质量把关 | `/review` | `04-review.md`，含 blocking / non-blocking 审查结论 |
| 审查通过，需要发布或导出 | `/ship` | `05-ship.md`、发布 / 导出记录、README 聚合 |
| 临时中断，需要保存上下文 | `/save` | `.claude/checkpoints/*.md` |
| 新 session 继续工作 | `/restore` | 恢复最近或指定 checkpoint |
| 记录跨 session 经验 | `/learn` | `.claude/learnings.jsonl` |
| 管理当前目标进度 | `/goal` | 目标生命周期记录 |
| 查看能力概览 | `/help` | 命令与工作流提示 |

> Codex CLI 不维护 repo 内 `$command` 薄包装入口；请直接根据 `AGENTS.md` 的工作流说明读取对应技能。

## 工作流

```text
想法 / 问题
  ├─ /brainstorm       发散并比较方案（可选）
  └─ /refine           收敛为 spec，声明 artifact_type
        ↓
/design                证据驱动设计；纯后端或无创作设计时可按规则跳过
        ↓
/plan                  拆分任务；大型任务产出 plans/*.md 与并行矩阵
        ↓
/build                 增量构建；必要时写 ADR；遇到缺陷进入 verify-debug
        ↓
/review                多角色审查；blocking 问题回到 /build
        ↓
/ship                  发布 / 导出 / 文档同步 / canary / land
```

关键约束：

- `/refine` 使用 Unified 原生 External Scan，把信息分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject。
- `/design` 不写实现步骤或任务分解；它只负责交互、视觉、排版、剧本、导演等创作设计定稿。
- `/build` 读取 `03-plan.md`；大型或并行任务还会读取 `plans/*.md`，并只在 `Parallel Execution Matrix` 标记 `parallel_safe` 时并行。
- Debug 不是顶层命令；它作为 `verify-workflow-debug` 被 `/build` 或 `/review` 在验证失败时加载。

## 技能版图

| 阶段 | 技能数 | 核心能力 |
|------|--------|----------|
| define 定义 | 3 | refine（想法收敛）、spec（规格编写）、brainstorm（发散 / 收敛探索） |
| design 设计 | 6 | design（设计总控）、interaction（交互）、visual-direction（视觉）、script（剧本）、direction（导演）、layout（排版） |
| build 构建 | 15 | plan、execute、tdd、context、source-driven、execution-engine、decision-record、git、ui-engineering、browser-testing、api-design、database、service-patterns、content-writing、content-layout |
| verify 验证 | 13 | review、spec-compliance、code-quality、debug、accessibility、integration-testing、performance、security、code-review-standards、content-review、visual-review、receiving-review、simplify |
| ship 发布 | 7 | ship、ci-cd、deploy、artifact-export、canary、land、doc-sync |
| maintain 维护 | 7 | observability、deprecation-migration、using-unified、context-save、context-restore、learn、goal |
| reflect 复盘 | 2 | retro、documentation |

`artifact_type` 在 spec 中声明，默认 `software`。可选值如下：

| artifact_type | 典型产物 | 重点技能 / 纪律 |
|---------------|----------|------------------|
| `software` | 应用、服务、脚本、库 | TDD、代码审查、集成测试、CI/CD、部署 |
| `document` | 说明文档、方案、规范 | 读者任务、事实核查、结构化表达、文档同步 |
| `article` | 文章、长文、叙述性内容 | 内容写作、逻辑链、风格一致性、内容审查 |
| `deck` | 演示文稿、汇报材料 | 信息层级、版式、叙事节奏、导出检查 |
| `visual` | 视觉稿、图像、设计产物 | 视觉方向、构图、可访问性、视觉审查 |

## 安装

### Claude Code Plugin（推荐）

```bash
claude plugin add https://github.com/ZeroZ-lab/unified-skills
```

安装后重启 Claude Code session，即可使用 `commands/` 下的 12 个斜杠命令。

### skills CLI

```bash
npx skills add ZeroZ-lab/unified-skills
```

### 本地开发 / 手动挂载

```bash
git clone https://github.com/ZeroZ-lab/unified-skills.git
cd unified-skills
mkdir -p ~/.claude/skills ~/.claude/commands
ln -s "$(pwd)/skills/"* ~/.claude/skills/
ln -s "$(pwd)/commands/"* ~/.claude/commands/
```

### Codex CLI Hooks

```bash
git clone https://github.com/ZeroZ-lab/unified-skills.git
cd unified-skills
mkdir -p ~/.codex
cat > ~/.codex/config.toml <<'CODEX_CONFIG'
[features]
codex_hooks = true
CODEX_CONFIG
```

## 平台差异

| 能力 | Claude Code | Codex CLI |
|------|-------------|-----------|
| 项目入口 | `CLAUDE.md` 指向 `AGENTS.md`，命令在 `commands/` | `AGENTS.md` + `skills/` |
| 命令形态 | `/refine`、`/design`、`/plan` 等斜杠命令 | 按 `AGENTS.md` 工作流直接读取技能 |
| SessionStart 上下文注入 | 自动 | 自动（需 `codex_hooks = true`） |
| careful 破坏性命令拦截 | `permissionDecision: "ask"`，提示确认 | `permissionDecision: "deny"`，fail-closed |
| freeze 编辑范围冻结 | `permissionDecision: "deny"` | `permissionDecision: "deny"` |

Codex 使用 `deny` 而不是 `ask`，是为了避免确认型交互语义不稳定时把破坏性命令交给不确定的运行环境。

## 项目结构

```text
unified/
├── CANON.md                 10 条宪法；所有技能的最高纪律
├── AGENTS.md                统一项目约束入口
├── CLAUDE.md                Claude 侧指针文件
├── README.md                项目说明
├── skills/                  53 个真实技能，按阶段命名
├── commands/                12 个 Claude Code 斜杠命令入口
├── agents/                  24 个角色定义
├── templates/               bug / feature 文档模板
├── references/              编排模式与设计最佳实践来源合同
├── docs/                    架构、历史与 feature 档案
├── hooks/                   SessionStart / careful / freeze 护栏
├── skills-index.json        技能发现索引
└── skills-lock.json         技能完整性锁文件（SHA-256）
```

命名规范：`<phase>-<role>-<skill>/SKILL.md`，例如 `build-quality-tdd`、`design-content-script`、`verify-workflow-review`。

## 文档产出链

```text
docs/features/YYYYMMDD-<name>/
├── 00-brainstorm.md        ← /brainstorm
├── 01-spec.md              ← /refine
├── 02-design.md            ← /design
├── 03-plan.md              ← /plan
├── plans/*.md              ← /plan（大型 / 并行子计划）
├── adr/<num>.md            ← /build（架构或产品决策）
├── 04-review.md            ← /review
├── 05-ship.md              ← /ship
├── 06-canary-report.md     ← ship-workflow-canary
├── 07-deploy-report.md     ← ship-workflow-land
└── README.md               ← /ship 后聚合

docs/bugs/<name>/
├── 01-root-cause.md        ← verify-workflow-debug Phase 1–3
└── 02-fix-plan.md          ← verify-workflow-debug Phase 4
```

## 贡献与验证

修改技能前必须先理解它的行为塑造目的：

1. 通读目标 `SKILL.md`，不要只改片段。
2. 阅读 `CANON.md`，确认技能没有放松宪法条款。
3. 新增技能时从 `templates/feature/` 起步，并遵循 `<phase>-<role>-<skill>/SKILL.md` 命名。
4. 不复制其他技能内容；跨技能复用请引用技能名。
5. 修改技能、入口文档、hooks 或产物链后，同步检查 `skills-index.json` 与 `skills-lock.json`。
6. 提交前运行：

```bash
./validate
```

禁止事项：

- 添加没有可操作流程的空泛建议。
- 添加只服务特定项目、团队或领域的技能；这类能力应做成独立插件。
- 在技能间重复大段内容。
- 放松 `CANON.md` 的任何条款。
- 随意替换 `human partner` 等有行为含义的措辞。
- 引入第三方依赖；Unified 设计为零依赖。

## FAQ

**Q: 为什么 debug 在 verify 阶段，而不是 maintain？**
A: Debug 是验证失败后的自然下一步。当 review 发现 blocking 问题、测试失败或行为偏离 spec 时，debug 会进入“根因在前，修复在后”的验证循环。Maintain 保留给持续运维、迁移、上下文与学习记录。

**Q: 为什么技能目录不用多层嵌套？**
A: 53 个技能通过扁平命名已经包含阶段、角色和动作，例如 `build-quality-tdd`、`design-content-script`、`build-content-writing`。这比深层目录更容易被 Agent 精确发现和引用。

**Q: Unified 和其他技能集是什么关系？**
A: Unified 吸收工程、设计、审查、发布等实践，统一为同一套宪法、命名、入口/出口条件和验证纪律；它不依赖外部技能集。

**Q: Claude Code 和 Codex CLI 的体验一致吗？**
A: 工作流语义一致，入口形态不同。Claude Code 使用 `commands/` 的斜杠命令；Codex CLI 直接读取 `AGENTS.md` 和 `skills/`。Hooks 侧，Codex 的 careful 使用 `deny`（fail-closed），freeze 在两平台都使用 `deny`。

## License

MIT
