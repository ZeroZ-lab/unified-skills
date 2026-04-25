---
name: build-backend-service-patterns
description: 服务架构模式——分层、通信、韧性。使用 cuando 需要设计后端服务架构、跨服务通信或处理分布式系统问题
---

# Service Patterns — 服务架构模式


## 入口/出口
- **入口**: 涉及多个服务/模块的边界设计、通信模式选择、韧性策略
- **出口**: 模式选择记录 + 接口定义 + 韧性配置
- **指向**: 架构确定后进入 `build-backend-api-design`（定义具体接口）
- **假设已加载**: CANON.md

## 服务分层

```
Presentation  →  API Handler / Controller（HTTP、验证、序列化）
     │
Business      →  Service（领域逻辑、规则、工作流）
     │
Data          →  Repository / Adapter（数据访问、外部 API 封装）
     │
Infrastructure →  DB、Cache、Queue、外部服务
```

**依赖方向:** 上层依赖下层，依层不跨层。Business 不直接 import HTTP 框架类型。

## 通信模式

| 模式 | 适用场景 | 示例 |
|------|---------|------|
| **同步 Request-Response** | 需要立即结果、强一致性 | 创建订单 → 返回订单号 |
| **异步 Message Queue** | 可延迟、高吞吐 | 订单创建后发送邮件通知 |
| **Event-Driven Pub/Sub** | 多消费者、解耦 | 订单完成 → (通知服务 + 分析服务 + 积分服务) |
| **Saga (编排)** | 跨服务长事务 | 下单 → 扣库存 → 扣款 → 通知（任一步失败 = 补偿回滚） |

**选择原则:**
```
需要立即响应 + 强一致？→ 同步
可延迟 + 需要韧性？  → 异步
多消费者 + 解耦？   → Event-Driven
跨服务长事务？      → Saga
```

## 韧性模式

### 重试与退避

```typescript
async function withRetry<T>(fn: () => Promise<T>, maxRetries = 3): Promise<T> {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt === maxRetries) throw err;
      const delay = Math.pow(2, attempt) * 100;  // 100ms → 200ms → 400ms
      await sleep(delay);
    }
  }
  throw new Error('unreachable');
}
```

### 断路器

```
状态机:
  CLOSED → (连续失败 N 次) → OPEN（立即失败，不调用）
  OPEN → (等待 timeout) → HALF_OPEN（尝试一次）
  HALF_OPEN → 成功 → CLOSED | 失败 → OPEN
```

**断路器保护下游服务不被雪崩淹没。** 当调用已经反复失败时，快速失败 > 继续重试拖死上游。

### 幂等性

```typescript
// 每个写操作需要幂等键
interface CreateOrderRequest {
  idempotencyKey: string;  // 客户端生成 UUID
  items: OrderItem[];
}

// 服务端: 相同幂等键 → 返回相同结果（不重复创建）
async function createOrder(req: CreateOrderRequest): Promise<Order> {
  const existing = await db.orders.findBy({ idempotencyKey: req.idempotencyKey });
  if (existing) return existing;
  return db.orders.create(req);
}
```

**任何涉及支付的端点必须有幂等键。** 网络重试 + 重复扣款 = 灾难。

## 模式选择

| 需求 | 模式 | 复杂度代价 |
|------|------|-----------|
| CRUD 围绕单一实体 | Repository + Service | 低 |
| 读/写负载不对称 | CQRS（读写分离） | 中 |
| 跨服务事务 | Saga | 高 |
| 复杂业务规则链 | Chain of Responsibility / Pipeline | 中 |
| 多策略可切换 | Strategy Pattern | 低 |
| 领域逻辑密集 | Domain-Driven（Entity + Value Object + Aggregate） | 中-高 |

**原则:** 从最简单的模式开始。当代码变复杂**因为模式不够**时才升级，不因为"如此"。

## 错误处理

```typescript
// 区分可恢复错误 vs 不可恢复错误
class RetryableError extends Error { /* 网络超时、503 */ }
class FatalError extends Error { /* 验证失败、404 */ }

async function handleServiceCall(fn: () => Promise<T>): Promise<T> {
  try {
    return await fn();
  } catch (err) {
    if (err instanceof RetryableError) {
      return withRetry(fn);
    }
    throw err;  // Fatal — 上层处理
  }
}
```

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "以后需要时再加重试" | 网络是不确定的。从第一条跨服务调用开始就加重试。 |
| "断路器太复杂，直接重试" | 一直重试失败的服务 = 拖着上游一起死。断路器是保护装置。 |
| "幂等性以后补" | 有支付的系统从第一天就需要。补幂等性需要改 API 合约。 |
| "同步耦合没关系，微服务间调用很快" | 现在快。调用链 lengthens，故障面扩大。能不耦合就不耦合。 |
| "选 CQRS，虽然简单但万一以后要读扩展" | 为"万一"增加复杂度 = 过早工程化。简单需求简单方案。 |

## 红旗 — STOP

- 单体拆成微服务但没有定义故障模式（网络分区、超时、下游宕机）
- 没有重试/断路器的跨服务 HTTP 调用
- 支付相关端点缺少幂等键
- 队列消费者没有死信队列（DLQ）—— 坏消息反复消费
- 同步调用链 > 3 层（请求串行穿透多个服务）
- 从表现层直接调用数据层（跳过 Business/Service）

## 验证清单

- [ ] 服务边界清晰（按业务领域，不按技术层）
- [ ] 跨服务调用有重试和超时配置
- [ ] 支付/扣款相关有幂等键
- [ ] 异步消费者有死信队列
- [ ] 故障模式已识别（单点在哪？降级方案？）
- [ ] 选择的是当前需要的最简模式
