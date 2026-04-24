---
name: build-cognitive-source-driven
description: 源码驱动开发——每个框架决策由官方文档背书。使用 cuando 使用不熟悉的 API、引入新依赖或不确定方法签名
---

# Source-Driven — 源码驱动开发

> 来源: agent-skills source-driven-development | 宪法: 第 2（Simple First）、5（Verify Don't Assume）、8（Manage Confusion）条

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
"我感觉"、"我相信"、"应该是" → 都不是证据。
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

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "我知道这个 API" | 可能是上个版本的记忆。验证 > 信任记忆。 |
| "代码比文档好，直接读源码" | 源码告诉你"是什么"，文档告诉你"为什么"和"推荐做法"。先文档，再源码。 |
| "文档太长懒得看" | 用搜索定位到具体章节。不需要从头读到尾。 |
| "这只是一个简单的 API 调用" | 简单调用也有版本差异。30 秒查文档 > 30 分钟调 bug。 |

## 红旗 — STOP

- 用 "应该是 X"、"大概率是 X"、"我记得 X" 描述 API
- 不记引用 URL（"大概是这样"行不通）
- 用 Stack Overflow 答案代替官方文档（P4 不能替代 P0）
- 在仍使用旧版 API 时不标注版本/过期信息
- "API 文档和现有代码不一致，我选代码继续"（不解决冲突）
- 多个外部 API 组合使用时没有验证它们之间的兼容性

## 验证清单

- [ ] 每个框架特定决策有对应的官方文档引用
- [ ] 引用使用完整 URL
- [ ] 未覆盖的边界行为通过源码或测试验证
- [ ] 引用的文档版本与项目使用的库版本匹配
- [ ] 偏离文档的地方有明确的版本/坑位原因标注
