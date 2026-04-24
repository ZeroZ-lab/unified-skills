# Unified Skills

宪法 + 35 技能 + 5 命令 = 按阶段加载的 AI 多产物开发技能套件。支持 Claude Code 和 Codex CLI。

融合 [agent-skills](https://github.com/anthropics/skills) 的教学深度、superpowers 的纪律硬度、gstack 的工程编排模式。不是要替代它们，而是把三者的精华压缩到一个一致性体系里。

## 目录

- [安装](#安装)
- [总览](#总览)
- [为什么用 Unified](#为什么用-unified)
- [命令](#命令)
- [工作流](#工作流)
- [宪法](#宪法)
- [项目结构](#项目结构)
- [文档产出链](#文档产出链)
- [贡献技能](#贡献技能)
- [FAQ](#faq)
- [License](#license)

## 安装

### Claude Code

```bash
npx skills add ZeroZ-lab/unified-skills
```

### Codex CLI

```bash
# 克隆仓库后，symlink 技能到 Codex 发现路径
git clone https://github.com/ZeroZ-lab/unified-skills.git
cd unified-skills
ln -s "$(pwd)/skills" "$HOME/.agents/skills/unified"

# 或者只安装 5 个命令入口技能
ln -s "$(pwd)/.agents/skills"/* "$HOME/.agents/skills/"
```

Codex 会自动扫描 `.agents/skills/` 发现所有技能。用 `$refine`、`$plan`、`$build`、`$review`、`$ship` 调用命令。

## 总览

| 阶段 | 技能数 | 核心能力 |
|------|--------|----------|
| define 定义 | 3 | refine（想法收敛）、spec（规格编写）、brainstorm（发散/收敛探索） |
| build 构建 | 15 | plan、execute、tdd、context、source-driven、execution-engine、decision-record、git、ui-engineering、browser-testing、api-design、database、service-patterns、content-writing、content-layout |
| verify 验证 | 9 | review、debug、accessibility、integration-testing、performance、security、code-review-standards、content-review、visual-review |
| ship 发布 | 4 | ship、ci-cd、deploy、artifact-export |
| maintain 维护 | 2 | observability（可观测性）、deprecation-migration（废弃迁移） |
| reflect 复盘 | 2 | retro（回顾）、documentation（文档） |

## 为什么用 Unified

三个独立的技能集合各自优秀，但组合使用时会出现问题：

| 问题 | Unified 的解法 |
|------|---------------|
| agent-skills 流程详细但缺少纪律约束 | 每技能加 Iron Law + 红旗表 |
| superpowers 纪律强但不教怎么做 | 每技能保留完整执行步骤 + 代码示例 |
| gstack 编排强但技能间互相不知对方存在 | 统一命名规范 + 入口/出口/指向 链接链 |
| 三个集合的术语和哲学不一致 | CANON.md 10 条宪法是所有技能的单一真相源 |

**Unified 不追求比三个源更"多"，而是追求更"一致"。** 35 个技能共享同一套宪法、同一套命名、同一套文档模板、同一套验证标准。

## 命令

| Claude Code | Codex CLI | 阶段 | 作用 |
|-------------|-----------|------|------|
| `/refine` | `$refine` | define | 模糊想法 → 规范 spec |
| `/plan` | `$plan` | build | spec → 任务分解与计划 |
| `/build` | `$build` | build | 按 `artifact_type` 增量生成软件或内容产物 |
| `/review` | `$review` | verify | 按 `artifact_type` 做代码、内容或视觉审查 |
| `/ship` | `$ship` | ship | 发布/导出检查 + README 聚合 |

Debug 不再作为顶层命令，而是作为 `verify-workflow-debug` 被 `/build`、`/review` 在工作流中按需加载。

`artifact_type` 在 spec 中声明，默认 `software`。可选值：`software` / `document` / `article` / `deck` / `visual`。软件继续走 TDD、代码审查、CI/CD、部署；非软件产物按需加载内容写作、版式、内容审查、视觉审查和导出技能。

多产物扩展技能采用角色化方法论：先定义角色责任、长期原则和决策框架，再给出流程和验证证据；它们不是工具清单。

`/refine` 使用 Unified 原生 External Scan：按 `artifact_type` 搜索已有方案、事实来源、设计/技术模式，并把结果分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject，再交给 Idea Scout Army 审查。

## 工作流

```
/refine ──→ /plan ──→ /build ──→ /review ──→ /ship
               │           │            │
               │           ├──→ verify-workflow-debug（遇到bug）
               │           ├──→ build-cognitive-decision-record（架构决策）
               │           └──→ build-frontend-* / build-backend-* / build-content-*（按产物类型）
               │
               └──→ 回到 /refine（计划不可行）
```

## 宪法

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

## 项目结构

```
unified/
├── CANON.md             宪法（最高优先级）
├── CLAUDE.md            AI agent 入口配置
├── README.md            本文件
│
├── skills/              35 技能 / 6 阶段
│   ├── define/          定义（3）
│   ├── build/           构建（13）
│   ├── verify/          验证（7）
│   ├── ship/            发布（3）
│   ├── maintain/        维护（2）
│   └── reflect/         复盘（2）
│
├── commands/            5 命令入口（Claude Code 斜杠命令）
├── .agents/skills/       5 命令入口（Codex CLI skill 命令）
├── agents/              7 审查角色（3 代码 + 4 计划）
├── templates/           7 文档模板
└── docs/                设计文档
```

命名规范：`<phase>-<role>-<skill>/SKILL.md`（如 `build-quality-tdd`、`build-content-writing`）。

## 文档产出链

```
docs/features/<name>/
├── 01-spec.md           ← /refine
├── 02-plan.md           ← /plan
├── adr/<num>.md         ← /build（决策时）
├── review.md            ← /review
├── ship.md              ← /ship
└── README.md            ← /ship 后聚合

docs/bugs/<name>/
├── 01-root-cause.md     ← verify-workflow-debug Phase 1-3
└── 02-fix-plan.md       ← verify-workflow-debug Phase 4
```

## 贡献技能

1. 阅读 [CANON.md](CANON.md) — 你的技能不能与宪法冲突
2. 用 `templates/feature/` 下的模板作为起点
3. 遵循命名规范：`<phase>-<role>-<skill>/SKILL.md`
4. 确保技能包含：入口/出口条件、流程步骤、常见说辞表、红旗清单、验证清单
5. 跑 `./validate` 检查占位符残留、命名规范、核心章节、命令包装入口和强纪律技能
6. 新增技能链接到本 README 的总览表

**不能做的事：** 添加无操作流程的"空泛建议"、仅服务特定领域的技能（这类放独立插件）、重复其他技能的内容、放松宪法条款。

## FAQ

**Q: 为什么 debug 在 verify 阶段而不是 maintain？**
A: Debug 是验证失败后的自然下一步 — 当 review 发现问题、测试失败时触发。它和 verification是紧耦合循环。Maintain 阶段留给持续运维（observability + deprecation）。

**Q: 技能目录为什么不用嵌套结构（如 `skills/build/quality/tdd/`）？**
A: 35 个技能不需要三层嵌套。扁平命名 `build-quality-tdd`、`build-content-writing` 已包含完整语义，glob 加载 `skills/build-*` 方便，ls 自动按阶段排序。

**Q: Unified 和 agent-skills/superpowers/gstack 的关系是什么？**
A: Unified 吸收了三者的精华而非替代它们。agent-skills 贡献了流程和代码示例的广度，superpowers 贡献了 Iron Law 和红旗的纪律硬度，gstack 贡献了并行 fan-out 和编排模式。Unified 的价值在于将它们统一到一个一致性体系中。

**Q: Codex CLI 和 Claude Code 的体验一致吗？**
A: 命令层面一致 — `$refine` 和 `/refine` 加载相同的工作流技能。Claude Code 用斜杠命令（`commands/`），Codex CLI 用 skill 包装器（`.agents/skills/`），底层都是同一套 `skills/` 技能。

## License

MIT
