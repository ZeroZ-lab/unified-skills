# Unified Skills

按阶段组织的开发技能套件。融合 agent-skills 的广度、superpowers 的纪律、gstack 的编排。

## 架构

```
unified/
├── CANON.md               宪法（9 条，所有技能引用）
├── CLAUDE.md              入口配置
│
├── skills/                30 技能 / 6 阶段
│   ├── define/            定义（3）
│   ├── build/             构建（13）
│   ├── verify/            验证（6）
│   ├── ship/              发布（3）
│   ├── maintain/          维护（3）
│   └── reflect/           复盘（2）
│
├── commands/              6 命令入口
├── agents/                3 并行审查角色
├── templates/             7 文档模板
└── docs/                  设计文档
```

## 工作流

```
/refine → /plan → /build → 代码 → /review → /ship
                                     │
                ┌────────────────────┼────────────────────┐
                ▼                    ▼                    ▼
            Bug → /debug        UI → build-frontend-*    API → build-backend-*
                                 安全 → verify-quality-security   决策 → reflect-team-documentation
```

## 命名规范

每个技能目录：`<phase>-<role>-<skill>/SKILL.md`

- **phase**: define / build / verify / ship / maintain / reflect
- **role**: workflow / frontend / backend / quality / cognitive / infrastructure / team
- **skill**: 具体技能名（kebab-case）

示例：`build-quality-tdd/SKILL.md` → 构建阶段 → 质量角色 → TDD 技能

## 来源
- agent-skills: 领域广度（14 技能继承）
- superpowers: 纪律硬度（TDD Iron Law、4-Phase Debugging、subagent）
- gstack: 并行发散模式、命令编排
