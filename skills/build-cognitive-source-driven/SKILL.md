---
name: build-cognitive-source-driven
description: 源码驱动开发——每个框架决策由官方文档背书。使用 cuando 使用不熟悉的 API、引入新依赖或不确定方法签名
---

# Source-Driven — 源码驱动开发


## 入口/出口
- **入口**: 使用不熟悉的 API/库、实现涉及框架特定代码、引入新依赖
- **出口**: 每个决策都有官方文档/源码背书的正确实现
- **指向**: 继续当前 build 流程
- **假设已加载**: CANON.md

## 何时不使用
- 完全在自己写的模块内部（无外部 API 调用）
- 使用项目内已多次正确使用过的 API（工作示例已验证签名）

## Iron Law

```
每个框架特定的代码决策必须有官方文档支持。
"我感觉"、"我相信"、"是" → 都不是证据。
模糊 = 最差选项。要么验证，要么标注未验证。
```

## 流程: DETECT → FETCH → IMPLEMENT → CITE

```
DETECT         →  识别出哪些代码是框架特定的
FETCH          →  查找官方文档/源码验证 API 签名和行为
IMPLEMENT      →  按文档正确的签名和模式实现
CITE           →  在代码注释或对话中留下完整引用 URL
```

### Step 1: DETECT — 识别框架特定代码

在写任何代码之前，如果它涉及：
- 导入外部包/库的 API
- 使用框架特定的模式（如 Next.js 路由、Prisma 查询、React Hook 签名）
- 依赖第三方 API 行为（如 Stripe SDK、AWS SDK）

→ 触发 Source-Driven 流程。不要凭记忆写。

**DETECT 实际操作示例：**

扫描 import 语句，识别出所有框架特定代码：

```typescript
// 你准备写的代码中有这些 import：
import { PrismaClient } from '@prisma/client';       // → Prisma ORM
import { useRouter } from 'next/navigation';          // → Next.js App Router
import { z } from 'zod';                              // → Zod 验证库
import { createHmac } from 'crypto';                  // → Node.js 内置（查 Node 文档）

// DETECT 阶段产出：
// - Prisma: prisma.order.create() 的 nested write API → 需查 prisma.io docs
// - Next.js: useRouter() 的返回类型和方法 → 需查 nextjs.org docs
// - Zod: z.object() 的 refine/transform 链式 API → 需查 zod.dev docs
// - crypto: createHmac 的算法参数列表 → 需查 nodejs.org docs
```

每个 import → 一个待验证项。不要假设任何 API 签名。

### Step 2: FETCH — 查官方来源

**来源优先级（从高到低）：**

| 优先级 | 来源 | 使用场景 |
|--------|------|---------|
| **P0** | 官方文档 (.docs 站点) | API 签名、配置选项、breaking changes |
| **P1** | GitHub 源码 / 类型定义 | 文档未覆盖的边界行为、默认值、返回类型 |
| **P2** | 项目内已有正确代码 | 验证已经在这项目中成功使用过的模式 |
| **P3** | 官方示例仓库 / 集成测试 | 复杂流程（OAuth、Webhook 处理）的端到端模式 |
| **P4** | 社区（Stack Overflow / Blog） | 仅在以上来源均无答案时，且需要交叉验证 |

**不使用 P4 当 P0-P3 都存在。**

**FETCH 实际操作示例：**

```
DETECT 识别出：需要用 Prisma 的 nested write 创建订单

FETCH 执行：
1. WebSearch "prisma nested create official documentation"
2. 命中 P0: https://www.prisma.io/docs/orm/prisma-client/queries/relation-queries
3. 定位到 "Nested writes" 章节
4. 验证 API 签名: prisma.order.create({ data: { items: { create: [...] } } })
5. 确认版本兼容: 项目用 Prisma 5.x，文档对应 5.x ✓
6. 记录来源 URL 用于 CITE 阶段

如果 P0 不可达 → 降级到 P1：
1. WebSearch "prisma github prisma-client relation queries"
2. 读 TypeScript 类型定义中的 create 方法签名
3. 在 CITE 中标注：来源为类型定义（P1），官方文档不可达
```

### Step 3: IMPLEMENT — 按文档实现

按验证过的签名和模式写代码。不要"我觉得这样也行"的改动——每个改动和文档一致。

### Step 4: CITE — 留下引用

```typescript
// ref: https://www.prisma.io/docs/orm/prisma-client/queries/relation-queries#nested-writes
// Prisma nested create — creates parent + children in one transaction
await prisma.order.create({
  data: {
    items: {
      create: [{ name: 'Widget', quantity: 2 }],
    },
  },
});
```

引用规则：
- 完整 URL，不缩略
- 说明**为什么**选这个来源（不重复文档内容）
- 当实现偏离文档时（明确的版本兼容处理），标注偏离原因

## 冲突处理

```
文档说 X，现有代码做 Y？
    │
    ├── 现有代码按旧版本文档写的 → 按最新文档修正
    ├── 现有代码有意为特定坑而偏离文档 → 找到那个坑（issue/PR/ADR）
    └── 找不到为什么偏离 → STOP。问人类。
```

## 好/坏对照 — 盲猜 vs 源码驱动

```typescript
// ❌ Bad: 凭记忆写 API，不查文档
// "我记得 Prisma 的 create 可以嵌套，大概是这样："
await prisma.order.create({
  data: {
    items: {
      push: [{ name: 'Widget' }],  // push 不存在！应该是 create
    },
  },
});
// 结果：运行时报错，浪费 30 分钟调试

// ✅ Good: DETECT → FETCH → IMPLEMENT → CITE
// DETECT: prisma.order.create + nested items → 需查 Prisma 文档
// FETCH: 搜索 "prisma nested create" → 定位官方文档
// IMPLEMENT: 按验证过的签名实现
// ref: https://www.prisma.io/docs/orm/prisma-client/queries/relation-queries#nested-writes
await prisma.order.create({
  data: {
    items: {
      create: [{ name: 'Widget', quantity: 2 }],
    },
  },
});
```

```typescript
// ❌ Bad: 从 Stack Overflow 复制代码（P4 当 P0）
// "Stack Overflow 上说 useEffect 这样用"
useEffect(() => {
  fetchData();
}, []); // 缺少依赖项，ESLint 警告被忽略

// ✅ Good: 查 React 官方文档
// DETECT: useEffect + 依赖数组 → 需查 React 文档
// FETCH: 搜索 "react useEffect dependencies official"
// ref: https://react.dev/reference/react/useEffect#my-effect-keeps-re-running-every-render
useEffect(() => {
  fetchData();
  // fetchData 已用 useCallback 包裹，依赖稳定
}, [fetchData]);
```

## 反模式修复表

| 反模式 | 问题 | 修复 |
|--------|------|------|
| 凭记忆写 API 调用 | 记忆可能是上个版本的，签名已变 | DETECT 阶段必须搜索官方文档验证签名 |
| 用 Stack Overflow 回答替代官方文档（P4 优先级当 P0 用） | 社区回答可能过时或针对不同版本 | P4 来源仅做参考，以 P0-P1 为准 |
| 跳过冲突处理直接用找到的方案 | 文档和现有代码矛盾时不解决 | 按冲突处理决策树逐级判断 |
| 文档说废弃但代码还在用 | 文档可能滞后于实际版本 | 以实际版本 CHANGELOG 为准，文档可能滞后 |
| 抄了示例代码没看上下文版本 | 示例可能对应不同大版本 | CITE 时记录文档版本和日期 |
| 同一个 API 在 P0 和 P1 源描述矛盾 | 官方文档和类型定义不同步 | 以 P0 为准，在 CITE 中注明差异 |
| 找到一个能跑的方案就停了 | 可能还有更优解或隐藏陷阱 | 至少检查 P0 和 P1 两个来源再决定 |
| 把 GitHub Issues 里的 workarounds 当正式 API | Issue 中的临时方案可能在下版本移除 | 仅作为 P3 参考，不作为正式 API 使用 |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "我知道这个 API" | 可能是上个版本的记忆。验证 > 信任记忆。 |
| "代码比文档好，直接读源码" | 源码告诉你"是什么"，文档告诉你"为什么"和"做法"。先文档，再源码。 |
| "文档太长懒得看" | 用搜索定位到具体章节。不需要从头读到尾。 |
| "这只是一个简单的 API 调用" | 简单调用也有版本差异。30 秒查文档 > 30 分钟调 bug。 |
| "类型定义就够了不用看文档" | 类型定义不含语义约束、副作用、废弃说明。读文档。 |
| "我在另一个项目用过这个 API" | 版本可能不同。API 签名可能变了。验证。 |
| "CHANGELOG 太长了不想看" | 那正是 bug 藏身的地方。看 Breaking Changes 章节。 |
| "这个框架很简单不需要文档" | 简单框架也有陷阱。React 的 useEffect 依赖数组就是反例。 |
| "示例代码能跑就行" | 能跑 ≠ 正确。示例可能用的是已废弃 API。 |
| "官方文档有时候也是错的" | 个别错误不构成跳过文档的理由。发现文档错误时在 CITE 中标注。 |

## 红旗 — STOP

- 用 "是 X"、"大概率是 X"、"我记得 X" 描述 API
- 不记引用 URL（"大概是这样"行不通）
- 用 Stack Overflow 答案代替官方文档（P4 不能替代 P0）
- 在仍使用旧版 API 时不标注版本/过期信息
- "API 文档和现有代码不一致，我选代码继续"（不解决冲突）
- 多个外部 API 组合使用时没有验证它们之间的兼容性

**注意来自人类伙伴的信号：**
- "你确定这是对的？" — 你可能跳过了验证步骤，回去做 DETECT
- "有文档吗？" — 你没有 CITE，回去补充引用
- "版本对吗？" — 你没有 DETECT 版本，检查 package.json 后验证文档版本
- "我记得这个 API 不是这样的" — 你的来源可能过时了，重新 FETCH 最新文档
- "这个 API 已经废弃了吧？" — 你可能用了旧 API，查 CHANGELOG 确认

**全部意味着：STOP。回到 DETECT。**

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 官方文档不可达 | 降级到 P1 源（GitHub README、类型定义）。无任何文档则标记 Unknown 并告知人类伙伴 |
| P0 文档与实际代码行为矛盾 | 以代码行为为准，在 CITE 中记录差异。可能是文档版本滞后 |
| 无法确定框架版本 | 检查 package.json / lock 文件。仍然无法确定 → 标记 Unknown |
| 多个 P0 源互相矛盾 | 选最近更新日期的为准，记录所有矛盾源 |
| 找不到任何文档 | 标记 Unknown。读源码类型定义作为最后手段。不猜测 |
| 社区方案互相矛盾 | 不采信任何 P4 方案。回到 P0-P1 寻找权威来源。无权威来源则标记 Unknown |

## 验证清单

- [ ] 每个框架特定决策有对应的官方文档引用
- [ ] 引用使用完整 URL
- [ ] 未覆盖的边界行为通过源码或测试验证
- [ ] 引用的文档版本与项目使用的库版本匹配
- [ ] 偏离文档的地方有明确的版本/坑位原因标注
