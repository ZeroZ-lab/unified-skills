# Unified Skills

宪法 + 47 技能 + 11 命令 + 22 角色 = 按阶段加载的多产物 AI 开发技能套件。支持 Claude Code 和 Codex CLI。

## 10 秒上手

```bash
# Claude Code
npx skills add ZeroZ-lab/unified-skills
# 然后：/refine → /plan → /build → /review → /ship

# Codex CLI
git clone https://github.com/ZeroZ-lab/unified-skills.git
cd unified-skills
# 入口：AGENTS.md
# 技能：skills/
# hooks：.codex/config.toml 中启用 codex_hooks = true
```

### 场景速查

| 你想做什么 | 用这个命令 |
|-----------|-----------|
| 有一个模糊想法 | `/refine` — 收敛成 spec |
| spec 已写好需要拆任务 | `/plan` — 生成任务分解 |
| 计划已批准需要实现 | `/build` — 增量构建 |
| 产物完成需要质量把关 | `/review` — 多角色审查 |
| 审查通过需要上线 | `/ship` — 发布审计 |
| 中间有事要离开 | `/save` — 保存上下文 |
| 新 session 继续工作 | `/restore` — 恢复上下文 |
| 学到新东西想记住 | `/learn` — 跨 session 学习 |
| 追踪当前目标进度 | `/goal` — 目标管理 |

## 命令

| Claude Code | 阶段 | 作用 |
|-------------|------|------|
| `/refine` | define | 模糊想法 → 规范 spec |
| `/plan` | build | spec → 任务分解与多角色审查 |
| `/build` | build | 按 `artifact_type` 增量生成软件或内容产物 |
| `/review` | verify | 按 `artifact_type` 做代码、内容或视觉审查 |
| `/ship` | ship | 发布/导出检查 + README 聚合 |
| `/save` | maintain | 保存工作上下文到 checkpoint |
| `/restore` | maintain | 恢复之前的工作上下文 |
| `/learn` | maintain | 跨 session 学习记录管理 |
| `/goal` | maintain | 目标生命周期管理 |

Codex 不再维护 repo 内 `$command` 薄包装入口；直接以 `AGENTS.md` 为项目入口，按需读取 `skills/` 中的真实技能。

Debug 不作为顶层命令，而是作为 `verify-workflow-debug` 被 `/build`、`/review` 在工作流中按需加载。

## 技能总览

| 阶段 | 技能数 | 核心能力 |
|------|--------|----------|
| define 定义 | 3 | refine（想法收敛）、spec（规格编写）、brainstorm（发散/收敛探索） |
| build 构建 | 15 | plan、execute、tdd、context、source-driven、execution-engine、decision-record、git、ui-engineering、browser-testing、api-design、database、service-patterns、content-writing、content-layout |
| verify 验证 | 13 | review、spec-compliance、code-quality、debug、accessibility、integration-testing、performance、security、code-review-standards、content-review、visual-review、receiving-review、simplify |
| ship 发布 | 7 | ship、ci-cd、deploy、artifact-export、canary、land、doc-sync |
| maintain 维护 | 7 | observability（可观测性）、deprecation-migration（废弃迁移）、using-unified（会话启动引导；canonical skill 为 `maintain-workflow-using-unified`）、context-save（保存上下文）、context-restore（恢复上下文）、learn（跨 session 学习）、goal（目标管理） |
| reflect 复盘 | 2 | retro（回顾）、documentation（文档） |

`artifact_type` 在 spec 中声明，默认 `software`。可选值：`software` / `document` / `article` / `deck` / `visual`。软件走 TDD、代码审查、CI/CD、部署；非软件按需加载内容写作、版式、审查和导出技能。

多产物扩展技能采用角色化方法论：先定义角色责任和决策框架，再给流程和验证证据。

## 工作流

```
想法阶段              计划阶段              构建阶段              验证阶段              发布阶段
──────               ──────               ──────               ──────               ──────
  │                    │                    │                    │                    │
  ├─ /brainstorm       ├─ /plan             ├─ /build             ├─ /review            ├─ /ship
  │  (发散→收敛)       │  (任务分解)        │  (增量生成)         │  (多角色审查)       │  (发布审计)
  │                    │                    │                    │                    │
  └─ /refine           │  ┌ 遇到bug?        │  ┌ 架构决策?        │  ┌ 有blocking?      │  ├─ canary
     (spec 输出)       │  │ → verify-debug  │  │ → ADR            │  │ → /build 修复    │  ├─ land
                       │  │                 │  │                  │  │                  │  └─ doc-sync
                       │  └ 计划不可行?     │  └ 按产物类型:      │  └ 批准 → /ship     │
                       │     → 回 /refine   │     software /      │                     │
                       │                    │     document /      │  上下文持久化:       │
                       │                    │     article /       │  /save ←→ /restore  │
                       │                    │     deck / visual   │  /learn（跨 session）│
```

`/build` 读取 `02-plan.md`；大型/并行任务读取 `plans/*.md`，并按 `Parallel Execution Matrix` 的 `parallel_safe` 标记决定是否并行。

## 为什么用 Unified

| 问题 | Unified 的解法 |
|------|---------------|
| 流程详细但缺少纪律约束 | 每技能加 Iron Law + 红旗表 |
| 纪律强但不教怎么做 | 每技能保留完整执行步骤 + 代码示例 |
| 编排强但技能间互相不知对方存在 | 统一命名规范 + 入口/出口/指向 链接链 |
| 多个工具的术语和哲学不一致 | CANON.md 10 条宪法是所有技能的单一真相源 |

**Unified 不追求更"多"，而是追求更"一致"。** 47 技能、11 命令、22 角色共享同一套宪法、同一套命名、同一套验证。

## 安装

### 通过 Claude Code Plugin 安装（推荐）

在 Claude Code 中运行：

```bash
claude plugin add https://github.com/ZeroZ-lab/unified-skills
```

或使用 skills CLI：

```bash
npx skills add ZeroZ-lab/unified-skills
```

安装完成后重启 Claude Code session，即可使用所有 `/refine`、`/plan`、`/build`、`/review`、`/ship` 命令。

### 手动安装

```bash
git clone https://github.com/ZeroZ-lab/unified-skills.git
cd unified-skills
ln -s "$(pwd)/.claude/skills/"* ~/.claude/skills/
ln -s "$(pwd)/commands/"* ~/.claude/commands/
```

### Codex CLI

```bash
git clone https://github.com/ZeroZ-lab/unified-skills.git
cd unified-skills
mkdir -p ~/.codex
cat > ~/.codex/config.toml <<'EOF'
[features]
codex_hooks = true
EOF
```

### 跨平台功能矩阵

| 功能 | Claude Code | Codex CLI |
|------|-------------|-----------|
| 项目入口 | `CLAUDE.md` + `commands/` | `AGENTS.md` + `skills/` |
| SessionStart 上下文注入 | 自动 | 自动（需 `codex_hooks = true`） |
| 破坏性命令拦截 (careful) | 提示确认 (`ask`) | 直接阻止 (`deny`) |
| 编辑范围冻结 (freeze) | 阻止编辑 (`deny`) | 阻止编辑 (`deny`) |
| 工作流参考 | `/refine` `/plan` `/build` `/review` `/ship` | 参考 `AGENTS.md` 中同名工作流阶段 |

Codex 当前使用 `permissionDecision: "deny"`，即 fail-closed。选择 `deny` 是因为 `ask` 的语义在 Codex 上并不稳定，避免把破坏性命令交给不确定的交互行为。freeze 的 `deny` 在两平台均完全生效。

### 验证

在 Claude Code 中输入 `/refine`，看到需求提炼流程启动即安装成功。

### 卸载

```bash
# plugin 方式
claude plugin remove unified

# skills CLI 方式
npx skills remove unified-skills
```

## 详参

### 宪法

[CANON.md](CANON.md) — 10 条不可变纪律，所有技能自动引用。技能可以增加纪律，不能放松宪法条款。

1. **Surface Assumptions** — 实现非平凡任务前陈述假设
2. **Simple First** — 三个相似代码行 > 一个过早抽象
3. **Scope Discipline** — 只改该改的，记下不动
4. **TDD Iron Law** — 没先失败的测试 = 不存在的代码
5. **Verify Don't Assume** — "应该能过" ≠ 证据
6. **4-Phase Debugging** — 根因在前，修复在后。3 次修复失败 → 质疑架构
7. **Push Back** — 不做 yes-machine。有具体问题直说，量化影响
8. **Manage Confusion** — 遇到矛盾 → STOP → 命名困惑 → 等待解决
9. **Structured Questions With Portable Fallback** — 需要输入时优先结构化提问；工具不可用时单问题纯文本降级
10. **Every Feature Leaves a Trace** — 完整档案：spec + plan + ADR + review + ship

### 项目结构

```
unified/
├── CANON.md              宪法（最高优先级）
├── CLAUDE.md             AI agent 入口配置
├── README.md             本文件
│
├── skills/               47 技能 / 6 阶段
│   ├── define/           定义（3）
│   ├── build/            构建（15）
│   ├── verify/           验证（13）
│   ├── ship/             发布（7）
│   ├── maintain/         维护（7）
│   └── reflect/          复盘（2）
│
├── commands/             11 命令入口（Claude Code 斜杠命令）
├── agents/               22 角色（7 核心工程 + 15 审查）
├── templates/            6 文档模板
├── references/           编排模式参考文档
├── docs/                 设计文档
├── skills-lock.json      技能完整性锁文件（SHA-256）
```

命名规范：`<phase>-<role>-<skill>/SKILL.md`（如 `build-quality-tdd`、`build-content-writing`）。

### 文档产出链

```
docs/features/<name>/
├── 00-brainstorm.md      ← /brainstorm
├── 01-spec.md            ← /refine
├── 02-plan.md            ← /plan
├── plans/*.md            ← /plan（大型/并行子计划）
├── adr/<num>.md          ← /build（决策时写 ADR）
├── 03-review.md          ← /review
├── 04-ship.md            ← /ship
├── 05-canary-report.md   ← ship-workflow-canary
├── 06-deploy-report.md   ← ship-workflow-land
└── README.md             ← /ship 后聚合

docs/bugs/<name>/
├── 01-root-cause.md      ← verify-workflow-debug
└── 02-fix-plan.md
```

### 贡献技能

1. 阅读 [CANON.md](CANON.md) — 你的技能不能与宪法冲突
2. 用 `templates/feature/` 下的模板作为起点
3. 遵循命名规范：`<phase>-<role>-<skill>/SKILL.md`
4. 确保技能包含：入口/出口条件、流程步骤、常见说辞表、红旗列表、验证清单
5. 跑 `./validate` 检查
6. 新增技能时更新 README 总览表

**不能做的事：** 添加无操作流程的空泛建议、仅服务特定领域的技能（放独立插件）、重复其他技能内容、放松宪法条款。

### FAQ

**Q: 为什么 debug 在 verify 阶段而不是 maintain？**
A: Debug 是验证失败后的自然下一步 — 当 review 发现问题、测试失败时触发。它和 verification 是紧耦合循环。Maintain 留给持续运维。

**Q: 技能目录为什么不用嵌套结构？**
A: 47 技能不需要三层嵌套。扁平命名 `build-quality-tdd`、`build-content-writing` 已包含完整语义。

**Q: Unified 和其他技能集的关系？**
A: 吸取了多种工程实践精华，融合为一致性体系。不依赖任何外部技能集。

**Q: Codex CLI 和 Claude Code 体验一致吗？**
A: 工作流语义一致，但入口形态不同。Claude 使用 `commands/` 里的斜杠命令；Codex 直接读取 `AGENTS.md` 和 `skills/`。Hooks 侧，careful 在 Codex 上使用 `deny`（fail-closed），freeze 在两平台都使用 `deny`。

## License

MIT
