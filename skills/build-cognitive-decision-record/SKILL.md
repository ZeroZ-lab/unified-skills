---
name: build-cognitive-decision-record
description: 架构决策记录（ADR）。当面临技术选型、架构决策、方案取舍需要记录，或提到"ADR""决策记录""为什么这样做"
---

# Decision Record — 架构决策记录 (ADR)


## 入口/出口
- **入口**: build 中面临技术选型、方案取舍、架构决策
- **出口**: `docs/features/<name>/adr/<num>.md` — 可追溯的决策文件
- **指向**: 决策记录后继续 build
- **前置加载**: CANON.md
- **输出路径**: 决策记录后继续 `build-workflow-execute`

## 何时不使用
- 只是变量命名、局部文件拆分或框架惯例内的实现细节
- 方案没有真实取舍，只有一个显然符合现有模式的做法
- 已有 ADR 覆盖当前决策，只需要引用而不是新建

## 何时写 ADR

**必须写:** 选择技术方案（X vs Y）、改变架构模式、引入新依赖、选择数据存储方案、采用新通信模式、决定废弃某个系统

**不必写:** 选择变量名、文件拆分方式、单行实现细节、框架惯例（如 Next.js 的文件路由已经是框架决策）

## Iron Law

```
每个重要设计决策必须记录。
"代码即文档"说明 WHAT，"ADR 即文档"说明 WHY。
没有 WHY 的决策在复盘时等于没做决策。
```

## ADR 模板

优先使用 `templates/feature/adr/template.md`。ADR 必须记录 WHY，而不是把实现细节复制一遍；没有驱动因素、约束、选项对比、后果和可逆性，就不是可维护的决策记录。

```markdown
# ADR-<NNN>: <简短标题>

## Status
- Status: proposed / accepted / rejected / superseded / deprecated
- Date: YYYY-MM-DD
- Owner:
- Feature: `<feature-name>`
- Supersedes: `ADR-<NNN>` / none
- Superseded By: `ADR-<NNN>` / none

## Decision Summary
- Decision:
- One-line rationale:
- Scope affected:

## Context
- Current situation:
- Problem or opportunity:
- Why this decision is needed now:
- What happens if we do nothing:

## Decision Drivers
| Driver | Priority | Notes |
|--------|----------|-------|
| | must / should / could | |

## Constraints
| Constraint | Source | Impact |
|------------|--------|--------|
| | spec / plan / code / external | |

## Options Considered
| Option | Description | Pros | Cons | Fit Against Drivers | Reversibility |
|--------|-------------|------|------|---------------------|---------------|
| A | | | | high / medium / low | reversible / costly / hard |
| B | | | | high / medium / low | reversible / costly / hard |

## Decision
- Selected option:
- Rejected options:
- Decision owner:
- Decision time:

## Rationale
- Why selected option wins:
- Why rejected options lose:
- Evidence that changed the decision:

## Consequences
### Positive
- <positive consequence>

### Negative
- <negative consequence>

### Neutral / Operational
- <operational consequence>

## Reversibility
- Reversal cost: low / medium / high
- Reversal trigger:
- Reversal steps:
- Migration / data impact:

## Follow-up
| Action | Owner | Due | Tracking |
|--------|-------|-----|----------|
| | | YYYY-MM-DD / n/a | |

## Evidence Links
- Spec:
- Plan:
- Code / PR:
- External references:
- Related ADRs:
```

## 决策生命周期

```
提议 ──→ 接受 ──→ (可能) 取代 ──→ (可能) 废弃
  │                           │
  └── 讨论后拒绝              └── 新 ADR 引用旧 ADR
```

**不删除旧 ADR。** Git 有历史，ADR 也有历史。旧 ADR 被"取代"或"废弃"仍然留存——说明为什么当时做了那个决定、以及为什么后来改变了。

## 何时不算 ADR

不是所有选择都值得 ADR。阈值检查：
- 影响 > 1 个模块/服务的架构 → ADR
- 未来不可轻易改变的（数据模型、外部依赖、通信协议）→ ADR
- 只有一个人理解的隐式选择 → ADR
- 单文件实现细节 → 代码注释
- 框架的默认做法 → 不需要 ADR

## 示例

```markdown
# ADR-001: 选择 Prisma 作为 ORM

## Status
- Status: accepted
- Date: 2026-04-24
- Owner: backend lead
- Feature: `task-data-model`
- Supersedes: none
- Superseded By: none

## Decision Summary
- Decision: 使用 Prisma 作为 PostgreSQL ORM
- One-line rationale: 类型安全、迁移工具和团队经验比 raw SQL 控制力更重要
- Scope affected: data access layer, migrations, generated types

## Context
- Current situation: 项目需要管理用户、任务和评论数据。
- Problem or opportunity: 手写 SQL 缺少类型生成和迁移约束。
- Why this decision is needed now: 数据模型进入实现前必须固定访问层。
- What happens if we do nothing: 查询风格会分散，migration 责任不清。

## Decision Drivers
| Driver | Priority | Notes |
|--------|----------|-------|
| TypeScript 类型安全 | must | DTO 和查询结果需要稳定类型 |
| 迁移可审计 | must | schema 变更必须可追踪 |
| 复杂查询控制 | should | 少量路径可用 raw SQL 逃生 |

## Constraints
| Constraint | Source | Impact |
|------------|--------|--------|
| 团队已有 Prisma 经验 | plan | 降低交付风险 |
| 数据库固定为 PostgreSQL | spec | 不需要跨数据库抽象 |

## Options Considered
| Option | Description | Pros | Cons | Fit Against Drivers | Reversibility |
|--------|-------------|------|------|---------------------|---------------|
| Prisma | schema-first ORM | 类型生成、迁移成熟、团队熟悉 | 复杂查询可能退回 raw SQL | high | costly |
| Drizzle | SQL-like ORM | 更接近 SQL、运行时轻 | 团队经验少、迁移流程需补齐 | medium | costly |
| TypeORM | decorator ORM | 生态成熟 | 装饰器风格和当前代码不匹配 | low | hard |

## Decision
- Selected option: Prisma
- Rejected options: Drizzle, TypeORM
- Decision owner: backend lead
- Decision time: 2026-04-24

## Rationale
- Why selected option wins: Prisma 同时满足类型安全、迁移成熟度和团队熟悉度。
- Why rejected options lose: Drizzle 增加学习和迁移流程风险；TypeORM 和当前架构风格不匹配。
- Evidence that changed the decision: 现有团队经验权重高于 ORM 运行时体积。

## Consequences
### Positive
- schema、migration 和生成类型形成统一数据合同。

### Negative
- 复杂查询可能需要 `$queryRaw`，需要 code review 关注 SQL 安全。

### Neutral / Operational
- CI 需要执行 migration 检查和 client generation。

## Reversibility
- Reversal cost: high
- Reversal trigger: Prisma 阻塞关键查询性能且 raw SQL 无法补救
- Reversal steps: 新建数据访问层 adapter，迁移 schema，逐步替换 repository
- Migration / data impact: schema 语义保持，迁移工具链需要切换

## Follow-up
| Action | Owner | Due | Tracking |
|--------|-------|-----|----------|
| 在 CI 加 prisma generate / migration check | backend lead | 2026-04-30 | plan task |

## Evidence Links
- Spec: `01-spec.md`
- Plan: `03-plan.md`
- Code / PR: pending
- External references: Prisma docs, Drizzle docs
- Related ADRs: none
```

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "代码就是文档" | 代码显示 WHAT。6 个月后 WHY 只能在 ADR 里找到。 | 重做决策耗时 ×3；同一路径被反复讨论，浪费团队 2-4 小时/次 |
| "决策很明显不需要记录" | 对你明显≠对下一个接手的人明显。12 个月后的同事不会共享你的 context。 | 接手者误推翻已有决策 → 返工 1-2 周；重复踩同样的坑 |
| "写了没人读" | 被问"为什么选 X"时——发 ADR 链接。被问第 5 次时 ADR 的价值就出来了。 | 口头解释 ×5 次 × 15 分钟 = 75 分钟；一条 ADR 只需写 10 分钟 |
| "记录所有选择" | ADR 是精选。只有那些影响架构、不可轻易改变、或有多种合理方案的决策才需要。 | 过多 ADR → 信噪比下降 → 真正重要的决策淹没在噪声中 |

## 红旗 — STOP

- 选择了不同方案的项目依赖，没人知道为什么
- "我记得我们讨论过 X，但不记得为什么不选 Y"
- 引入新依赖——没有记录其他竞争方案为什么没选
- 代码走了一条和项目约定不同的路——没有 ADR 解释
- 有人提议替换决策时的方案——没有 ADR 可查"为什么当初选它"

## 验证失败处理

| 验证项 | 失败表现 | 处理方式 |
|--------|----------|---------|
| 缺少背景 | ADR 只写了"选 X"，没说为什么需要决策 | 补充背景：约束、驱动力、现状问题 |
| 选项不足 | 只评估了 1 个方案，没有对比 | 至少添加 1 个竞争方案并评估优缺点 |
| 决策理由模糊 | 理由是"大家都用"或"感觉不错" | 替换为具体证据：性能数据、团队经验、约束匹配 |
| 后果缺失 | 只列正面后果，不列负面 | 补充负面后果和被放弃选项的价值 |
| 可逆性缺失 | 不知道未来如何撤销或替换决策 | 补 Reversibility：成本、触发条件、回退步骤、数据影响 |
| 证据链接缺失 | ADR 无法追到 spec、plan、PR 或外部依据 | 补 Evidence Links；没有证据就标记为需要验证 |
| ADR 未编号保存 | ADR 写了但没放到 docs/features/<name>/adr/ | 按编号保存到正确路径，确保可引用 |

## 好坏示例

### Good: 有驱动、有对比、有可逆性
```markdown
## Decision Drivers
| Driver | Priority | Notes |
|--------|----------|-------|
| Type safety | must | 查询结果需要稳定类型 |

## Options Considered
| Option | Pros | Cons | Fit Against Drivers | Reversibility |
|--------|------|------|---------------------|---------------|
| Prisma | 类型生成、迁移成熟 | 复杂查询可能退回 raw SQL | high | costly |
| Drizzle | 更接近 SQL | 团队经验少 | medium | costly |

## Rationale
- Why selected option wins: Prisma 更匹配 must-have 类型安全和迁移可审计。

## Reversibility
- Reversal cost: high
- Reversal trigger: 关键查询性能无法通过 raw SQL 补救
```

### Bad: 无驱动、理由模糊、无可逆性
```markdown
## Decision
选择 Prisma，因为大家都用。
## Consequences
(无)
```

## 输出模板

```
ADR 完成：

编号: ADR-<NNN>
标题: <简短标题>
状态: <提议/接受/取代/废弃>
路径: docs/features/<name>/adr/<num>.md

驱动因素:
  - <driver> → must/should/could
约束:
  - <constraint> → <source> → <impact>
选项评估:
  - 选项 A: <名称> → 优点/缺点/driver fit/可逆性
  - 选项 B: <名称> → 优点/缺点/driver fit/可逆性
决策: <选择>
理由: <一句话解释>
后果:
  - 正面: <列出>
  - 负面: <列出>
  - 运维: <列出>
可逆性: <low/medium/high + trigger + steps>
证据链接: <spec/plan/PR/external/related ADR>
```

## 验证清单

- [ ] ADR 包含背景（为什么需要决策）
- [ ] ADR 使用 `templates/feature/adr/template.md` 或保留等价章节
- [ ] Decision Drivers 和 Constraints 已记录
- [ ] 至少 2 个选项被评估（有"放弃"才有"选择"）
- [ ] 每个选项有优点/缺点/driver fit/可逆性
- [ ] 决策理由清晰（不是"因为大家都用"）
- [ ] 正面和负面后果都列出
- [ ] 被放弃的选项被明确列出
- [ ] Reversibility 写清撤销成本、触发条件、步骤和数据影响
- [ ] Evidence Links 能追到 spec、plan、代码/PR、外部依据或相关 ADR
- [ ] Supersedes / Superseded By 状态正确；旧 ADR 不删除
- [ ] ADR 文件编号并保存到 `docs/features/<name>/adr/`
