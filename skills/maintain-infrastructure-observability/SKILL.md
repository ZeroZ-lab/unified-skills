---
name: maintain-infrastructure-observability
description: 可观测性——日志、指标、追踪三支柱。使用 cuando 需要监控生产、调查线上问题或配置告警
---

# Observability — 可观测性


## 入口/出口
- **入口**: 服务上线前、生产问题调查、监控配置
- **出口**: 可工作的监控 Dashboard + 告警规则
- **指向**: 上线后持续监控，异常时进入 `verify-workflow-debug`
- **假设已加载**: CANON.md

## 三支柱

```
Metrics  → 数字：知道"有问题"          (WHAT)
Logging  → 事件：知道"具体是什么问题"    (WHAT + CONTEXT)
Tracing  → 请求链路：知道"问题在哪层"    (WHERE)
```

### Metrics — 症状检测

**RED 方法（服务端点）:**
- **R**ate — 每秒请求数
- **E**rrors — 失败率
- **D**uration — P50/P95/P99 延迟

**USE 方法（基础设施/资源）:**
- **U**tilization — CPU、内存、磁盘使用率
- **S**aturation — 队列深度、连接池等待
- **E**rrors — 硬件错误、网络丢包

### Logging — 上下文

```typescript
// Bad: 信息不足
console.log('Task created');

// Good: 结构化 + 上下文
logger.info('task.created', {
  taskId: task.id,
  userId: req.user.id,
  title: task.title,
  duration: Date.now() - start,
});
```

**日志级别:**
| 级别 | 用途 | 生产环境 |
|------|------|---------|
| ERROR | 需要人工介入的问题 | 始终开启 |
| WARN | 需要注意但可自动恢复 | 始终开启 |
| INFO | 关键业务事件 | 始终开启 |
| DEBUG | 详细诊断信息 | 按需开启 |
| TRACE | 逐行追踪 | 从不开启（太详细） |

### Tracing — 请求链路

```
请求进入 → API Gateway(50ms) → Service(200ms) → DB Query(180ms) → 返回
                                          └→ Cache Read(2ms)
```

**分布式追踪在跨越 3 个以上服务时必须使用。** 追踪 ID 从头传递到尾（不改写）。

## 告警设计

```
告警的黄金信号:
├── 错误率突升（baseline 对比）→ P1
├── P95 延迟突升（baseline 对比）→ P1
├── 健康检查失败 → P0
├── 磁盘/内存使用率 > 90% → P2
├── SSL 证书即将过期（< 7 天）→ P2
└── 队列积压 > 阈值 → P2
```

**告警设计原则:**
- 告警 = 症状，不是原因。"数据库连接池满了"是症状（告警），"N+1 查询导致太多连接"是原因（调试）
- 告警必须有 Runbook 链接（"怎么办"的文档）
- 告警阈值必须有足够的余量—— P95 > 1s 可能触发太频繁，P95 > 5s 才是真正的异常

## 健康检查端点

```
GET /health        → 公开。返回 200 或 503。负载均衡器用。
GET /health/ready  → 内部。检查 DB 连接、Redis 连接、关键依赖。
GET /health/live   → 内部。进程存活检查（最简单，仅返回 200）。
```

## Dashboard 设计

**按受众分层:**
```
工程师 Dashboard:
├── 请求量 + 错误率 + 延迟（按端点）
├── 依赖健康（DB、Redis、Queue、外部 API）
├── 基础设施（CPU、内存、磁盘、网络）
└── 最近部署标记（竖线）

业务 Dashboard:
├── 用户操作量（注册、登录、关键操作）
├── 转化率（漏斗每步）
└── 支付成功率
```

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "console.log 就够了" | 没结构化、没上下文、没级别。日志框架（pino/winston/logrus）成本极低，收益极高。 |
| "指标太多看不过来" | 告警不靠人看。设置阈值 + 自动告警 + Runbook。人只在告警触发时介入。 |
| "追踪太贵不搞" | 在跨越 3 个以上服务时必须。没追踪时定位慢请求 = 每个服务逐一排查 = 花费更多。 |
| "生产问题靠用户报告才知道" | 说明你没有告警。用户在帮你做监控。 |

## 红旗 — STOP

- 生产代码用 `console.log` 而非结构化日志
- 日志记录中包含密码、token、PII（个人身份信息）
- 没有 `/health` 端点或 `/health` 始终返回 200（即使 DB 挂了）
- 关键路径缺少追踪（跨越多服务时的黑盒）
- 告警无 Runbook 链接（告警触发→不知道做什么）
- 关键错误被捕获但不记录（`catch (e) {}` 无声吃掉）

## 验证清单

- [ ] 结构化日志在关键业务路径上记录
- [ ] `/health` + `/health/ready` 端点存在
- [ ] 核心指标在 Dashboard 上可见
- [ ] 关键告警已配置（错误率、延迟、健康检查）
- [ ] 每个告警有 Runbook
- [ ] 分布式追踪 ID 在服务间传递（如果跨越 3+ 服务）
- [ ] 日志不包含密钥或 PII
