# Unified Skills

宪法 + 30 技能 + 5 命令 = 按阶段加载的开发技能套件。

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

## 命令

| 命令 | 作用 |
|------|------|
| `/refine` | 模糊想法 → 规范 spec |
| `/plan` | spec → 任务分解与计划 |
| `/build` | 增量实现 + TDD + 决策记录 |
| `/review` | 多轴代码审查 |
| `/ship` | 发布检查 + README 聚合 |

## 宪法

[CANON.md](CANON.md) — 9 条不可变纪律，所有技能自动引用：

1. Surface Assumptions — 实现前陈述假设
2. Simple First — 三个相似行 > 一个过早抽象
3. Scope Discipline — 只改该改的
4. TDD Iron Law — 没先失败的测试 = 不存在
5. Verify Don't Assume — 无证据不能声称完成
6. 4-Phase Debugging — 根因在前，修复在后
7. Push Back — 不做 yes-machine
8. Manage Confusion — 困惑时 STOP，不猜
9. Every Feature Leaves a Trace — 完整档案：spec + plan + ADR + review + ship

## 项目结构

```
unified/
├── CANON.md             宪法
├── CLAUDE.md            入口配置
├── skills/              30 技能
├── commands/            5 命令入口
├── agents/              3 并行审查角色
├── templates/           7 文档模板
└── docs/                设计文档
```

## 文档产出链

```
/refine → docs/features/<name>/01-spec.md
/plan   → docs/features/<name>/02-plan.md
/build  → docs/features/<name>/adr/<num>.md
/review → docs/features/<name>/review.md
/ship   → docs/features/<name>/ship.md + README.md
```
