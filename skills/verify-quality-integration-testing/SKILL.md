---
name: verify-quality-integration-testing
description: 集成测试——验证组件间交互和边界契约。当需要在单元测试之上验证跨组件/跨服务的正确性
---

# Integration Testing — 集成测试


## 入口/出口
- **入口**: 单元测试覆盖了单组件逻辑，需要验证组件间交互
- **出口**: 集成测试通过 + 边界契约验证
- **输出路径**: 集成测试结果 → `verify-workflow-review`
- **指向**: 集成测试通过后进入 `/review`
- **前置加载**: CANON.md + `build-quality-tdd/SKILL.md`

## 何时不使用
- 只验证纯函数或单组件内部逻辑
- 跨组件/服务契约没有变化，已有集成覆盖仍有效
- 当前问题是 spec 缺失或代码质量审查，不是边界交互验证

## Iron Law

<HARD-GATE>
```
组件间交互必须在真实（非 mock）边界上验证。
单元测试通过但集成测试失败 = 系统不可靠。
没有集成测试的接口契约 = 猜测。
```
</HARD-GATE>

## 何时写集成测试

**必须写:** API 端点（请求→响应）、数据库操作（ORM→真实DB）、跨服务调用、认证流程、文件上传/处理、Webhook 处理

**不必写:** 纯函数逻辑（单元测试）、第三方 SDK 内部行为、简单 CRUD 无业务逻辑

## 测试替身优先级

```
偏好顺序（从高到低）:
1. 真实实现  → 最高信心，能抓到真实 bug
2. Fake      → 依赖的内存版本（如内存数据库）
3. Stub      → 返回固定数据，无行为
4. Mock      → 验证方法调用 —— 仅用于无法控制副作用的边界
```

**仅在以下场景 mock：** 外部支付网关、邮件发送服务、第三方 API（无法控制、有速率限制或要花钱）。

**绝不 mock 数据库。** 用测试数据库或事务回滚。

## 测试结构

### Arrange-Act-Assert (AAA)

```typescript
describe('POST /tasks', () => {
  it('创建任务并返回 201', async () => {
    // Arrange: 设置测试场景
    const user = await createTestUser();
    const payload = { title: '买菜', priority: 'high' };

    // Act: 执行被测动作
    const response = await request(app)
      .post('/tasks')
      .auth(user.token)
      .send(payload);

    // Assert: 验证结果
    expect(response.status).toBe(201);
    expect(response.body.task.title).toBe('买菜');
    expect(response.body.task.status).toBe('pending');

    // 验证副作用: 确实写入了数据库
    const saved = await db.tasks.findById(response.body.task.id);
    expect(saved).not.toBeNull();
  });
});
```

## API 集成测试模式

```typescript
// Happy path
it('创建资源返回 201', ...);

// Validation errors
it('缺少必填字段返回 400', async () => {
  const response = await request(app).post('/tasks').send({});
  expect(response.status).toBe(400);
  expect(response.body.error.code).toBe('VALIDATION_ERROR');
});

// Auth errors
it('未认证用户返回 401', async () => {
  const response = await request(app).post('/tasks').send(validPayload);
  expect(response.status).toBe(401);
});

// Permission errors  
it('非所有者修改他人任务返回 403', async () => {
  const task = await createTask({ ownerId: 'user-a' });
  const response = await request(app)
    .patch(`/tasks/${task.id}`)
    .auth('user-b-token')
    .send({ title: 'hacked' });
  expect(response.status).toBe(403);
});

// Not found
it('修改不存在的资源返回 404', async () => {
  const response = await request(app)
    .patch('/tasks/non-existent-id')
    .auth(user.token)
    .send({ title: 'test' });
  expect(response.status).toBe(404);
});

// Edge cases (边界)
it('标题超过最大长度返回 400', ...);
it('分页 pageSize 超过上限自动截断', ...);
it('并发创建相同幂等键返回同一资源', ...);
```

**覆盖每个端点的:** Happy → Validation → Auth → Permission → Not Found → Edge

## 数据库测试的测试隔离

```typescript
// 方法 A: 事务回滚（首选 —— 快速、可靠）
let tx: Transaction;

beforeEach(async () => {
  tx = await db.startTransaction();
});

afterEach(async () => {
  await tx.rollback();  // 所有变更回滚，不污染数据库
});

// 方法 B: 测试数据库（事务回滚不可用时）
beforeEach(async () => {
  await testDb.truncate();  // 清空测试库
});
```

## 测试命名约定

```typescript
// 格式: <动作> + <场景> + <预期>
it('拒绝没有标题的任务创建')
it('对未认证用户返回 401')
it('幂等创建 —— 相同幂等键返回同一资源')
it('并发更新时返回 409 冲突')
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
| "单元测试就够了" | 单元测试验证孤立单元。集成测试验证它们一起工作时正确。API 参数会正确传递吗？数据库会接受数据吗？单元测试不答这些。 | 单元测试全绿但集成失败是最常见的生产故障模式——参数格式不匹配、数据库约束冲突、认证流程断裂。这些 bug 只在用户真实操作时才暴露。 |
| "mock 外部依赖更快" | Mock 的数据库返回数据 ≠ 真实数据库接受数据。用测试DB而不用mock。 | Mock 通过但真实数据库拒绝数据（类型不匹配、约束违反、字符编码问题），上线后以 500 错误形式爆发。 |
| "写集成测试很慢" | 500ms-2s 一个集成测试。发现一个跨组件 bug 省下的调试时间远多于此。 | 一个跨组件 bug 在生产排查需 4-8 小时（日志追踪 + 多服务定位）；集成测试写 2 分钟就能捕获同类问题。 |
| "Happy path 就够了，error case 手工测" | 手工测错误路径不做回归保护。下次代码改动可能不经意在 error path 崩溃。 | 未测试的错误路径在 2 周后的改动中回归，以 500/空响应/数据不一致形式出现，且无法自动检测。 |

**违反字面规则就是违反精神。** 没有灰色地带。

## 红旗 — STOP

- 集成测试 mock 了数据库（用真实DB/事务回滚代替）
- 测试只覆盖 Happy Path（不测 Validation/Auth/Permission/Not Found）
- 测试之间不隔离（测试 A 的数据影响测试 B 的结果）
- 集成测试调用外部真实服务（支付网关、邮件）—— 这些应该 mock
- 测试用 `setTimeout` 等待（用条件轮询 `waitFor`）

## 好/坏示例

### 坏：只测 Happy Path

```typescript
describe('POST /tasks', () => {
  it('创建任务成功', async () => {
    const res = await request(app).post('/tasks').auth(token).send({ title: 'test' });
    expect(res.status).toBe(201);
  });
});
```

问题：没有验证 400（缺字段）、401（未认证）、403（无权限）、404（不存在）、边界情况。上线后这些路径会以 500 错误暴露。

### 好：完整端点覆盖

```typescript
describe('POST /tasks', () => {
  it('创建任务返回 201', async () => { /* happy path */ });
  it('缺少 title 返回 400 VALIDATION_ERROR', async () => { /* validation */ });
  it('未认证返回 401', async () => { /* auth */ });
  it('非所有者修改他人任务返回 403', async () => { /* permission */ });
  it('修改不存在任务返回 404', async () => { /* not found */ });
  it('幂等键重复返回同一资源', async () => { /* edge: idempotency */ });
});
```

优点：覆盖 Happy + Validation + Auth + Permission + Not Found + Edge，每条路径都有回归保护。

## 验证失败处理

| 失败场景 | 处理方式 |
|----------|----------|
| 集成测试全红（Happy Path 失败） | 阻塞，先修复核心功能再测其他路径。不跳过 Happy Path 进入 review |
| Auth/Permission 测试失败 | 阻塞，认证和权限问题属于安全红线，不降级为"后续修复" |
| 数据库隔离失败（测试间状态泄漏） | 修复隔离策略（事务回滚或 truncate），不依赖手动清理。测试间共享状态 = 结果不可信 |
| 外部服务 mock 与真实行为不一致 | 更新 mock 行为匹配真实 API 文档，或替换为 Fake 实现。mock 与真实不一致 = 测试无效 |
| 部分端点测试未覆盖 | 在 review 前补充缺失端点测试，不接受"后续补测试"。未覆盖端点 = 未验证契约 |

## 输出模板

```markdown
# Integration Test Report — <name>

## 覆盖范围
- 端点数: N
- 覆盖端点: [列表]
- 未覆盖端点: [列表 + 原因]

## 测试矩阵
| 端点 | Happy | Validation | Auth | Permission | Not Found | Edge |
|------|-------|------------|------|------------|-----------|------|
| POST /tasks | PASS | PASS | PASS | PASS | — | PASS |
| PATCH /tasks/:id | PASS | PASS | PASS | PASS | PASS | PASS |

## 测试替身使用
| 依赖 | 替身类型 | 原因 |
|------|---------|------|
| 数据库 | 真实（事务回滚） | 绝不 mock 数据库 |
| 支付网关 | Mock | 外部服务，不可控 |
| 邮件服务 | Mock | 外部服务，有副作用 |

## 隔离策略
- 方式: 事务回滚 / truncate
- 验证: 测试间无共享状态

## 结果
- 通过数: X
- 失败数: Y
- 跳过数: Z

## 失败详情
[列出每个失败测试：端点、路径、失败原因、修复建议]

## 下一步
- 全绿 → 进入 /review
- 有失败 → 修复后重新运行，不跳过进入 review
```

## 验证清单

- [ ] 每个 API 端点有 Happy + Validation + Auth + Not Found 测试
- [ ] 权限敏感的端点有 403 测试
- [ ] 数据库测试用事务回滚隔离
- [ ] 外部服务（支付/邮件）被 mock
- [ ] 没有测试间的共享状态
- [ ] 测试名称描述行为和预期
