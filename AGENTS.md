# Unified Skills

> 宪法 + 阶段协议 + 角色责任 + 技能方法论 = 按阶段加载的多产物开发技能套件。支持 Claude Code 和 Codex CLI。

## Token 压缩描述

Unified Skills = `AGENTS.md`/`CANON.md` 单入口纪律 + `commands/` 阶段协议 + `skills-router.json` 紧凑路由 + `skills/` 行为技能 + `agents/` 角色责任 + hooks 护栏 + `docs/features/*` 证据链。默认 direct mode；只有显式进入 `/brainstorm` → `/ship` 等 Unified 阶段时，才先读 compact router，并按 `light` / `standard` / `expanded` / `full` 选择最小必要技能。修改 `SKILL.md` 或技能辅助文件时，必须同步索引/锁文件并运行 `./validate`。

运行时详细规则按需加载：`docs/contracts/artifact-types.md`（产物类型 + 文档影响）、`docs/contracts/doc-slots.md`（文档槽位 + 产出链）、`docs/contracts/role-escalation.md`（角色升级 + 矩阵）、`docs/contracts/hooks-platform.md`（hooks 平台差异）、`docs/contracts/persona-rules.md`（persona 调用规则）。开发贡献指南见 `CONTRIBUTING.md`。

## 如果你是一个 AI Agent

停。先读完这一节再做任何事。

Unified 是一套行为塑造技能——每个 SKILL.md 里的流程、红旗表、常见说辞表都是经过设计的，不是随意写的散文。随意修改措辞会改变 agent 行为，产生无法预料的后果。

## 终端观察护栏｜Terminal Observation Guardrail

Agent 在终端中执行命令时，必须保护上下文预算。终端输出会进入模型上下文，任何大规模、重复、无关或不可控输出，都会污染后续推理。

核心原则：

> 未知输出先限流，复杂信息先采样；终端观察要服务判断，而不是淹没判断。

任何输出规模未知、递归型、日志型、测试型、构建型、生成型或可能产生大量文本的命令，都必须默认限制输出：

```bash
COMMAND 2>&1 | head -c 4000
```

如果必须保留命令真实退出码，先把完整输出写入临时日志，再采样展示：

```bash
COMMAND > /tmp/command.log 2>&1; rc=$?; head -c 4000 /tmp/command.log; exit $rc
```

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

Unified runtime 默认是 opt-in。普通 repo 问答、普通 coding 请求、普通 debug 请求、未提 Unified 的直接任务，不自动进入 router-first 流程。

只有以下情况才激活 Unified runtime：

- 用户显式调用 `/brainstorm` `/refine` `/design` `/plan` `/build` `/review` `/ship` `/save` `/restore` `/learn` `/help`
- 用户明确说"使用 Unified 工作流""按 Unified 来""进入某个阶段"
- 用户在讨论 Unified 本身的启动、路由、技能合同或加载机制

激活后：

- 先读取 `skills-router.json` 获取 compact routing surface。
- 分析 6 个维度：阶段、产物类型、触发词、上下文信号、风险因素、loading tier。
- 声明 loading tier：`light`（router-only）/ `standard`（1 主 + 1 专项）/ `expanded`（1 主 + 2 专项）/ `full`（仅限 `--full`、对抗性审核、全身体检、高风险发版或用户明确要求）。
- 按需读取 `docs/contracts/` 下的详细运行时合同。

### Feature State Resume

- canonical path: `docs/features/<feature>/state.json`
- 写入阶段文档时，`doc-tracker` 会更新当前阶段、最后阶段文档、下一步命令和最后活动时间。
- 新 session 的 `SessionStart` 读取最新 active feature state 并注入短恢复提示；不自动激活 Unified runtime。
- `state.json` 只记录可随项目走的事实；禁止写入本地瞬时状态。
- `/save` 和 `/restore` 仍用于 decision-rich checkpoint。

## 宪法

[CANON.md](CANON.md) — 10 条不可变规则。技能可以添加纪律，但绝不能放松宪法条款。

## 项目结构

```
unified/
├── CANON.md                 宪法（10 条，最高优先级）
├── AGENTS.md                入口配置（本文件）
├── CLAUDE.md                Claude 侧指针文件（指向 AGENTS.md）
├── CONTRIBUTING.md          开发贡献指南
├── docs/contracts/          运行时合同（按需加载）
│   ├── artifact-types.md    产物类型 + 文档影响
│   ├── doc-slots.md         文档槽位 + 产出链
│   ├── role-escalation.md   角色升级 + 矩阵
│   ├── hooks-platform.md    hooks 平台差异
│   └── persona-rules.md     persona 调用规则
├── skills/                  技能目录 / 阶段分组
├── commands/                命令入口（Claude Code 斜杠命令）
├── agents/                  角色目录
├── templates/               模板类别
├── references/              编排模式 + 设计最佳实践
└── docs/                    设计文档
```

## 命令映射

| 命令 | 加载的技能 | 文档路径 |
|------|-----------|----------|
| `/brainstorm` | define-cognitive-brainstorm | `docs/features/YYYYMMDD-<name>/00-brainstorm.md` |
| `/refine` | define-workflow-refine | `docs/features/YYYYMMDD-<name>/01-spec.md` |
| `/design` | design-workflow-design + artifact_type 对应技能 + codex-rescue（可选） | `docs/features/YYYYMMDD-<name>/02-design.md` + `assets/mockup-direction-{1,2,3}.png` + `assets/design-tokens-extracted.json`（可选） + `DESIGN.md` |
| `/plan` | build-workflow-plan | `docs/features/YYYYMMDD-<name>/03-plan.md` + `plans/*.md`（大型任务） |
| `/build` | build-workflow-execute + artifact_type 对应技能 | `docs/features/YYYYMMDD-<name>/adr/` |
| `/review` | verify-workflow-review + artifact_type 对应审查 | `docs/features/YYYYMMDD-<name>/04-review.md` |
| `/ship` | ship-workflow-ship + artifact-export（非 software） | `docs/features/YYYYMMDD-<name>/05-ship.md` |
| `/save` | maintain-workflow-context-save | `.claude/checkpoints/YYYYMMDD-HHMMSS-{title}.md` |
| `/restore` | maintain-workflow-context-restore | — |
| `/learn` | maintain-workflow-learn | `.claude/learnings.jsonl` |
| `/help` | — | — |

spec 必须声明 `artifact_type`（默认 `software`）和 `Documentation Impact`（`doc_intent`，默认 `feature_only`）。详细规则见 `docs/contracts/artifact-types.md`。

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
