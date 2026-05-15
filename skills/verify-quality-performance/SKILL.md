---
name: verify-quality-performance
description: 性能优化——先测量、再优化、只优化测量证明有问题的。当性能不达标、慢页面调查或上线前性能审查
---

# Performance — 性能优化


## 入口/出口
- **入口**: 性能不达标（LCP > 2.5s、页面响应慢）、上线前性能审查
- **出口**: 可量化的性能改善 + 回归测试
- **指向**: 优化后回到 `verify-workflow-review` 或 `ship-workflow-ship`
- **前置加载**: CANON.md
- **输出路径**: 性能改善报告 → `verify-workflow-review` 审查

## 何时不使用
- 没有可量化的性能目标、基线或用户可感知慢点
- 只是常规代码清理或可读性优化
- 问题首先是功能错误、安全风险或架构边界不清

## Iron Law

<HARD-GATE>
```
先测量再优化。
没有测量数据的性能工作 = 猜谜。
过早优化增加的复杂性成本远超它带来的性能收益。
```
</HARD-GATE>

## 流程: MEASURE → IDENTIFY → FIX → VERIFY → GUARD

```
MEASURE    → 收集指标（Lighthouse、RUM、profiler）
IDENTIFY   → 定位瓶颈（找出最大的一个瓶颈）
FIX        → 一次改一个（只修测量证明有问题的）
VERIFY     → 重新测量（对比 before/after）
GUARD      → 加回归测试或性能预算
```

## Core Web Vitals 目标

| 指标 | Good | Needs Work | Poor |
|------|------|-----------|------|
| **LCP** (最大内容绘制) | ≤ 2.5s | 2.5-4.0s | > 4.0s |
| **INP** (交互到下一次绘制) | ≤ 200ms | 200-500ms | > 500ms |
| **CLS** (累积布局偏移) | ≤ 0.1 | 0.1-0.25 | > 0.25 |

**TTFB (首字节时间):** ≤ 800ms 为良好。

## 瓶颈定位

```
前端瓶颈:
├── 大 JS Bundle (> 200KB gzipped) → 代码拆分/lazy loading
├── 大图片 (> 500KB) → 压缩/WebP/响应式尺寸
├── 布局偏移 → 显式 width/height
├── 长任务 (> 50ms) → 拆分或 Web Worker
└── 未缓存 → 设置 Cache-Control header

后端瓶颈:
├── 慢查询 → EXPLAIN ANALYZE + 加索引
├── N+1 Queries → JOIN/batch 加载
├── 无分页 → 游标或偏移分页
├── 缺失缓存 → Redis/内存缓存热点数据
└── 同步阻塞 → 异步/队列
```

## 常见修复

### N+1 Queries

```typescript
// Bad: N+1 —— 每个 task 产生一个额外查询
const tasks = await db.tasks.findMany();
for (const t of tasks) {
  t.assignee = await db.users.findById(t.assigneeId);  // +1 query per task
}

// Good: 一次 JOIN 加载
const tasks = await db.tasks.findMany({ include: { assignee: true } });
```

### 无界查询

```typescript
// Bad: 返回全部数据
app.get('/tasks', async (req, res) => {
  const tasks = await db.tasks.findMany();
  res.json(tasks);
});

// Good: 分页 + 限制
app.get('/tasks', async (req, res) => {
  const { page = 1, pageSize = 20 } = req.query;
  const tasks = await db.tasks.findMany({
    skip: (page - 1) * pageSize,
    take: Math.min(pageSize, 100),  // 硬上限
  });
  res.json({ data: tasks, pagination: { page, pageSize } });
});
```

### 图片优化

```html
<!-- 响应式 + 现代格式 + 懒加载 -->
<img
  srcset="hero-640.webp 640w, hero-1280.webp 1280w"
  sizes="(max-width: 768px) 100vw, 50vw"
  src="hero-1280.webp"
  alt="产品图片"
  width="1280"
  height="720"
  loading="lazy"
/>
```

### 缺失缓存

```
Cache-Control 策略:
├── 静态资源 (JS/CSS/Fonts) → max-age=31536000, immutable
├── 图片 → max-age=86400
├── API 响应 (变化慢) → max-age=60, stale-while-revalidate=300
└── API 响应 (实时) → no-store
```

## 性能预算

```json
{
  "budgets": [
    { "resourceType": "script", "budget": 200 },   // KB gzipped
    { "resourceType": "style", "budget": 50 },
    { "metric": "LCP", "budget": 2500 },            // ms
    { "metric": "CLS", "budget": 0.1 }
  ]
}
```

## 验证证据

输出或记录必须包含：
- **输入/来源**: 读取的 spec、plan、代码、反馈或发布上下文。
- **执行动作**: 实际完成的检查、生成、修复、导出或发布步骤。
- **验证结果**: 命令、审查结论、产物路径、截图或人工确认。
- **阻塞/回退**: 未通过项、回退路径或需要 human partner 决策的问题。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "我本地很快" | 你的 MacBook Pro ≠ 用户的 4G Android。用 Lighthouse (模拟 4G + mid-tier CPU) 测量。 | 本地快 ≠ 用户快 → 上线后 LCP > 4s 在 4G 设备上 → 用户跳出率增加 30-50%。 |
| "多加点缓存就行" | 缓存掩盖问题。先修查询/加载再缓存。 | 缓存掩盖慢查询 → 缓存过期时慢查询瞬间暴露 → 用户体验在高峰期断崖式下降。 |
| "React.memo + useMemo 全加了" | 过度 memo 和不够 memo 一样有害。每个 memo 都有比对成本。测量清楚哪里需要。 | 过度 memo → 比对成本 > 渲染成本 → 总耗时反而增加 5-15%；不测量的 memo 优化方向随机。 |
| "先上线，性能以后优化" | 上线后性能问题 = 用户已经跑了。从第一天起设置预算。 | 无预算上线 → 用户首次体验慢 → 7 天留存率下降 20-30%，"以后优化"平均 = 永不。 |
| "优化所有瓶颈" | 优化最大的那个瓶颈。其余的除非测量证明值得——不修。 | 全优化 → 变更范围过大 → 回归风险不可控 → 一个优化引入 bug 会让全部优化失效。 |

## 红旗 — STOP

<HARD-GATE>
以下任何一个出现，立即停止"优化"：

- 没有测量就开始"优化"
- 将多个性能修复打包在一起（不知道哪个有效）
- 优化后不重新测量（不知道自己改了什么）
- 过早优化（"万一以后需要快"——现在需要吗？）
- N+1 查询在循环中出现了
- 列表端点没有分页
</HARD-GATE>

## 验证清单

- [ ] Before 和 After 测量数据存在
- [ ] 性能改善量化（LCP 从 Xms → Yms）
- [ ] 没有引入新的性能回归
- [ ] 添加性能回归测试或 CI 预算检查
- [ ] 只修改了测量证明有问题的部分
- [ ] N+1 查询检测通过
- [ ] 列表端点有分页限制

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 没有测量数据就开始优化 | STOP。回到 MEASURE 步骤，收集 Lighthouse/RUM/profiler 数据。没有基线 = 猜谜。 |
| 优化后性能无改善 | 回退修复，重新定位瓶颈。可能找错了瓶颈——回到 IDENTIFY。 |
| 优化引入功能回归 | 回退优化，先修复回归再重新测量。性能优化不能牺牲功能正确性。 |
| 无法复现性能问题 | 模拟生产条件：4G 网络 + mid-tier CPU + 真实数据量。本地测试条件不等于生产。 |
| 多个瓶颈同时存在 | 只修最大的那个。修完重新测量后再看下一个。不批量优化——无法判断哪个有效。 |

## 好坏示例

### Good — 量化 before/after + 瓶颈证据
Lighthouse 测量 LCP 4.2s → IDENTIFY 定位 N+1 查询为瓶颈 → FIX 一次改一个 → VERIFY 重测 LCP 1.8s（改善 57%）→ GUARD 加性能预算。每步有测量数据，不是猜测。

### Bad — "感觉更快了" 无测量
"我加了缓存，页面应该快了" — 没有 before/after 数据、没有瓶颈定位、没有重新测量。可能优化了不重要的瓶颈，也可能引入新回归但未发现。

## 输出模板

性能优化完成后，产出必须包含：

```markdown
## Performance Optimization Report

### Baseline
- LCP: [X]ms → [Y]ms (改善 [Z]%)
- INP: [X]ms → [Y]ms
- CLS: [X] → [Y]

### Bottleneck Identified
- 位置: [文件:行号]
- 类型: N+1 / 无界查询 / 大 bundle / 未缓存 / 长任务
- 测量证据: [profiler/screenshot 数据]

### Fix Applied
- 改动: [描述]
- 文件: [路径]
- 变更行数: [N] 行

### Verification
- Before/after 测量对比: [数据]
- 无功能回归: ✅ / ❌
- 性能预算检查: ✅ / ❌
```
