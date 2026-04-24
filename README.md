# Unified Skills

宪法 + 30 技能 + 5 命令 = 按阶段加载的 AI 开发技能套件。

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

```bash
npx skills add ZeroZ-lab/unified-skills
```

## 总览

| 阶段 | 技能数 | 核心能力 |
|------|--------|----------|
| define 定义 | 3 | refine（想法收敛）、spec（规格编写）、brainstorm（发散/收敛探索） |
| build 构建 | 13 | plan（任务分解）、execute（增量实现）、tdd（测试驱动）、context（上下文加载）、source-driven（文档驱动）、execution-engine（3 种执行模式）、decision-record（决策记录）、git（版本控制）、ui-engineering、browser-testing、api-design、database、service-patterns |
| verify 验证 | 7 | review（审查）、debug（四阶段调试）、accessibility（无障碍）、integration-testing、performance、security、code-review-standards |
| ship 发布 | 3 | ship（发布流水线）、ci-cd（持续集成部署）、deploy（部署） |
| maintain 维护 | 2 | observability（可观测性）、deprecation-migration（废弃迁移） |
| reflect 复盘 | 2 | retro（回顾）、documentation（文档） |

## 为什么用 Unified

三个独立的技能集合各自优秀，但组合使用时会出现问题：

| 问题 | Unified 的解法 |
|------|---------------|
| agent-skills 流程详细但缺少纪律约束 | 每技能加 Iron Law + 红旗表 |
| superpowers 纪律强但不教怎么做 | 每技能保留完整执行步骤 + 代码示例 |
| gstack 编排强但技能间互相不知对方存在 | 统一命名规范 + 入口/出口/指向 链接链 |
| 三个集合的术语和哲学不一致 | CANON.md 9 条宪法是所有技能的单一真相源 |

**Unified 不追求比三个源更"多"，而是追求更"一致"。** 30 个技能共享同一套宪法、同一套命名、同一套文档模板、同一套验证标准。

## 命令

| 命令 | 阶段 | 作用 |
|------|------|------|
| `/refine` | define | 模糊想法 → 规范 spec |
| `/plan` | build | spec → 任务分解与计划 |
| `/build` | build | 增量实现 + TDD + 决策记录 |
| `/review` | verify | 五轴代码审查 |
| `/ship` | ship | 发布检查 + README 聚合 |

Debug 不再作为顶层命令，而是作为 `verify-workflow-debug` 被 `/build`、`/review` 在工作流中按需加载。

## 工作流

```
/refine ──→ /plan ──→ /build ──→ /review ──→ /ship
               │           │            │
               │           ├──→ verify-workflow-debug（遇到bug）
               │           ├──→ build-cognitive-decision-record（架构决策）
               │           └──→ build-frontend-* / build-backend-*（按领域）
               │
               └──→ 回到 /refine（计划不可行）
```

## 宪法

[CANON.md](CANON.md) — 9 条不可变纪律，所有技能自动引用。技能可以增加纪律，不能放松宪法条款。

1. **Surface Assumptions** — 实现非平凡任务前陈述假设
2. **Simple First** — 三个相似代码行 > 一个过早抽象
3. **Scope Discipline** — 只改该改的，记下不动
4. **TDD Iron Law** — 没先失败的测试 = 不存在的代码
5. **Verify Don't Assume** — "应该能过" ≠ 证据
6. **4-Phase Debugging** — 根因在前，修复在后。3 次修复失败 → 质疑架构
7. **Push Back** — 不做 yes-machine。有具体问题直说，量化影响
8. **Manage Confusion** — 遇到矛盾 → STOP → 命名困惑 → 等待解决
9. **Every Feature Leaves a Trace** — 完整档案：spec + plan + ADR + review + ship

## 项目结构

```
unified/
├── CANON.md             宪法（最高优先级）
├── CLAUDE.md            AI agent 入口配置
├── README.md            本文件
│
├── skills/              30 技能 / 6 阶段
│   ├── define/          定义（3）
│   ├── build/           构建（13）
│   ├── verify/          验证（7）
│   ├── ship/            发布（3）
│   ├── maintain/        维护（2）
│   └── reflect/         复盘（2）
│
├── commands/            5 命令入口
├── agents/              3 并行审查角色
├── templates/           7 文档模板
└── docs/                设计文档
```

命名规范：`<phase>-<role>-<skill>/SKILL.md`（如 `build-quality-tdd`）。

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
5. 跑 `./validate` 检查占位符残留和命名违规
6. 新增技能链接到本 README 的总览表

**不能做的事：** 添加无操作流程的"空泛建议"、仅服务特定领域的技能（这类放独立插件）、重复其他技能的内容、放松宪法条款。

## FAQ

**Q: 为什么 debug 在 verify 阶段而不是 maintain？**
A: Debug 是验证失败后的自然下一步 — 当 review 发现问题、测试失败时触发。它和 verification是紧耦合循环。Maintain 阶段留给持续运维（observability + deprecation）。

**Q: 技能目录为什么不用嵌套结构（如 `skills/build/quality/tdd/`）？**
A: 30 个技能不需要三层嵌套。扁平命名 `build-quality-tdd` 已包含完整语义，glob 加载 `skills/build-*` 方便，ls 自动按阶段排序。

**Q: Unified 和 agent-skills/superpowers/gstack 的关系是什么？**
A: Unified 吸收了三者的精华而非替代它们。agent-skills 贡献了流程和代码示例的广度，superpowers 贡献了 Iron Law 和红旗的纪律硬度，gstack 贡献了并行 fan-out 和编排模式。Unified 的价值在于将它们统一到一个一致性体系中。

## License

MIT
