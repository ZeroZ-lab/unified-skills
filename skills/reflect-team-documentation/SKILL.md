---
name: reflect-team-documentation
description: 文档工程——记录决策、API、代码约定。使用 cuando 需要写文档、记录架构决策或维护项目知识
---

# Documentation — 文档工程


## 入口/出口
- **入口**: 功能完成、架构决策做出、API 新增/修改、项目约定发现
- **出口**: 可引用的文档 + ADR 文件
- **指向**: 文档完成后回到原流程
- **假设已加载**: CANON.md + `build-cognitive-decision-record/SKILL.md`（需要写 ADR 时）

## Iron Law

```
记录决策，不只是记录代码。
最有价值的文档记录的是 WHY。
代码显示 WHAT。文档说明 WHY。
```

## 四种文档

### 1. ADR — 架构决策记录

详见 `build-cognitive-decision-record/SKILL.md`。此处补充：

**ADR 生命周期:**
- **提议** → 讨论中
- **接受** → 已决定、正在实施
- **取代** → 被新的 ADR 替换（旧的保留）
- **废弃** → 决定不再适用（保留作为历史）

**不删除旧 ADR。** 旧 ADR 和代码一样有历史价值。

### 2. 内联文档

**何时写注释:**
```typescript
// 写 WHY: 解释不明显的业务规则
// 折扣必须在税之前计算，因为法规要求（见 REG-2024-0321）
function calculateTotal(items: Item[]): number { ... }

// 写 GOTCHA: 警告非显而易见的副作用
// 注意: 此函数也会更新 user.lastActivity —— 因为计费和活动追踪共享此路径
async function recordUsage(userId: string, amount: number): Promise<void> { ... }

// 写 INTENT: 当实现不匹配模式时的原因
// prisma.$queryRaw 而非 findMany —— 需要 FOR UPDATE 行级锁
```

**何时不写注释:**
```typescript
// Bad: 注释重复代码
// 计算总价
const total = items.reduce((sum, item) => sum + item.price, 0);

// Bad: TODO 应该是 issue
// TODO: 加错误处理
async function processPayment() { ... }

// Bad: 注释掉的代码
// const oldWay = await legacyApi.fetch();
// git 有历史，删掉注释掉的代码
```

**原则:** 写注释解释代码本身表达不了的东西。代码能清晰表达的 → 不写。写不对就改代码让它更清晰。

### 3. API 文档

```typescript
/**
 * 创建新任务。
 * 
 * @param input - 任务创建参数
 * @param input.title - 任务标题 (1-200 字符)
 * @param input.priority - 优先级等级
 * @returns 新创建的任务，包含默认状态 'pending'
 * @throws {ValidationError} 当标题为空或超过 200 字符
 * @throws {UnauthorizedError} 当用户未认证
 * 
 * @example
 * const task = await createTask({ title: '买菜', priority: 'high' });
 * console.log(task.status); // 'pending'
 */
async function createTask(input: CreateTaskInput): Promise<Task> { ... }
```

**API 文档标准:**
- 每个公共函数/端点有描述
- 参数和返回类型文档化
- 抛出的异常文档化
- 包含使用示例
- 不重复类型签名（TypeScript 类型已经说明了结构）

### 4. README 和项目文档

```
项目 README 应包含:
├── 项目是什么 (1 句)
├── 快速开始 (安装 + 运行 < 5 行)
├── 开发命令 (build/test/lint/dev)
├── 项目结构 (顶层目录 + 说明)
├── 关键约定 (非标准但规则)
└── 部署 (在哪运行、怎么部署)
```

**README 面向首次接触项目的人。** 不给专家写文档（专家不需要），给新手写（新手需要）。

## 文档 for AI Agents

代码库中的文档也被 AI agent 消费。AI 阅读文档的方式和人类不同：

```
AI 需要的文档:
├── CLAUDE.md / AGENTS.md → 项目命令、测试方法、架构概览
├── Spec → 需求 + 验收条件
├── ADR → 架构决策 + 为什么
└── 代码注释 → WHY、GOTCHA、INTENT（不重复代码）

AI 不需要的:
├── README 里的长段历史
├── CONTRIBUTING 中的 Git 工作流教程（AI 有自己的一套）
├── 重复 JSDoc 类型的注释
```

**项目约定的新发现 → 写入 CLAUDE.md。** 这是 AI agent 每次会话都会先加载的文件。

## Changelog 维护

```markdown
## [1.2.0] - 2026-04-24

### Added
- 任务创建支持优先级 (low/medium/high)
- 任务列表分页 (GET /tasks?page=1&pageSize=20)

### Changed
- 任务完成端点返回 completedAt 时间戳（以前不返回）

### Fixed
- 修复逾期任务的 isOverdue 标志未在 UTC 边界正确计算

### Deprecated
- `GET /v1/tasks` 将在 2026-06-01 移除。使用 `GET /v2/tasks`

### Security
- 修复 `npm audit` 报告的 critical CVE-2026-XXXX
```

**Changelog 面向用户。** "重构了 TaskService" = 内部细节、用户不关心。"任务列表支持分页（避免页面崩溃）" = 用户需要知道。

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "代码自解释，不需要文档" | 代码告诉你做什么。文档告诉你为什么做、为什么不做另一种做法、什么坑位要注意。 |
| "文档会过时" | 所以写不重复代码行为的部分（WHY > WHAT）。WHAT 会变，WHY 相对稳定。 |
| "功能简单不需要 README 更新" | README 是项目入口。新功能不写入=新功能不可发现。 |
| "TODO 放代码里就行" | TODO 注释 = 不会追踪、不会 assign、不会排期。转成 issue。 |
| "文档太费时间" | 一次 5 分钟的注释节省未来每个接手者 30 分钟。"我忘了为什么" = 文档成本的证明。 |

## 红旗 — STOP

- 注释掉的代码块（删除——Git 有历史）
- TODO 注释超过 3 个月未解决
- 函数逻辑修改了但注释/文档没更新（现在文档是假的）
- 公共 API 没有文档（至少 @param/@returns/@throws）
- README 的快速开始步骤在新 checkout 中不工作
- 新架构决策没有 ADR——"每个人都知道为什么" = 一年后没人知道为什么

## 验证清单

- [ ] 公共 API 有文档（参数、返回类型、异常、示例）
- [ ] 新架构决策有 ADR
- [ ] README 快速开始可在全新 checkout 中执行
- [ ] Changelog 已更新（如果功能有用户影响）
- [ ] 注释掉的代码已移除
- [ ] TODO 注释转为 issue 或已成为 ADR 的一部分
