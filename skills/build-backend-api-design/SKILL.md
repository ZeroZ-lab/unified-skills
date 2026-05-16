---
name: build-backend-api-design
description: API 和接口设计——稳定合约、清晰边界。当需要设计 REST/HTTP API、endpoint、接口契约、请求响应 DTO、错误语义、分页、幂等、权限边界或 API 合约测试时使用
---

# API Design — REST/HTTP 接口合约设计

> 这个 Skill 不是负责写 API 实现，而是负责在实现前冻结 API 合约：资源、端点、DTO、错误、权限、分页、幂等、并发、兼容性和合约测试。


## 入口/出口

- **入口**: 需要定义新 API 端点、修改已有端点合约、或设计跨服务 HTTP 合约
- **出口**:
  - API 端点列表（method + path + 认证 + 权限）
  - Request / Response DTO
  - Error Code 列表
  - 权限与认证规则
  - 分页 / 排序 / 过滤规则
  - 幂等性与并发控制规则
  - Zod / TypeScript / OpenAPI schema
  - Contract Tests 最低覆盖
  - 接口文档
- **指向**: 接口稳定后进入实现（`build-workflow-execute`）
- **前置加载**: CANON.md + `build-quality-tdd/SKILL.md`

## 何时不使用

- 只是实现既有 API，不改变请求/响应、错误语义或模块边界
- 只是修复 API 内部 bug，外部可观察行为不变
- 只是优化查询性能，不改变 endpoint、字段、错误语义或分页语义
- 只是补充 API 文档，不需要重新设计合约
- 纯内部重构，调用方不可观察的合约没有变化
- 数据库 schema 或查询设计是主要问题（使用 `build-backend-database`）
- GraphQL schema 设计是主要问题时，使用专门 GraphQL Skill
- Webhook / Event / Message Queue 合约是主要问题时，使用事件合约 Skill

## 核心原则

### Hyrum 法则

```
有足够多的用户时，每个可观察到的行为都会变成事实合约。
```

可观察行为包括但不限于：
- 字段是否存在
- 字段类型
- 字段是否可为 null
- 默认值
- enum 取值
- 错误 code
- HTTP status
- 排序规则
- 分页稳定性
- 空列表返回结构
- 时间格式
- 权限失败时返回 403 还是 404
- 重复请求是否创建重复资源

你以为是实现细节的——消费者可能已经依赖了。**设计时就假定每个行为都是永久的。**

### 兼容演进优先

默认不要通过 v2 逃避设计问题。优先设计可以通过添加字段、添加端点、添加可选能力持续演进的 API。

只有出现不可兼容语义变化时，才考虑版本化：
- 字段类型必须改变
- 字段语义必须改变
- 资源模型发生根本变化
- 旧权限模型不再安全
- 外部客户端无法同步升级
- 合规或安全要求导致旧行为必须废弃

版本化是最后手段，不是默认方案。

### 1. 合约优先

```typescript
// 1. 先定义合约
interface CreateTaskRequest {
  title: string;
  description?: string;
  assigneeId?: string;
  priority: 'low' | 'medium' | 'high';
}

interface TaskOutput {
  id: string;
  title: string;
  status: 'pending' | 'completed';
  priority: 'low' | 'medium' | 'high';
  createdAt: string;
  updatedAt: string;
}

// 2. 再实现
async function createTask(req: CreateTaskRequest): Promise<TaskOutput> {
  // ...
}
```

**先写类型 → 再写逻辑。** 接口就是文档。代码就是合约。

**合约至少包括：**
- Method + Path
- Request params / query / body / headers
- Response body
- Error response
- Auth requirement
- Permission requirement
- Pagination / sorting / filtering
- Idempotency rule
- Backward compatibility note

**API 设计顺序：**
1. 定义资源与动作
2. 定义 endpoint
3. 定义 Request DTO
4. 定义 Response DTO
5. 定义 Error Codes
6. 定义权限规则
7. 定义分页 / 排序 / 过滤
8. 定义幂等与并发控制
9. 定义 schema
10. 定义 contract tests
11. 再进入实现

### 2. 一致错误语义

| HTTP Status | 语义 | 何时使用 |
|-------------|------|---------|
| 200 | OK | GET/PUT/PATCH 成功 |
| 201 | Created | POST 创建新资源 |
| 204 | No Content | DELETE 成功 |
| 400 | Bad Request | 请求格式错误、字段类型错误、缺少必填参数 |
| 401 | Unauthorized | 缺少认证凭据，或认证凭据无效 |
| 403 | Forbidden | 已认证，但没有权限 |
| 404 | Not Found | 资源不存在，或为安全不暴露资源存在性 |
| 409 | Conflict | 版本冲突、幂等键冲突、业务状态冲突 |
| 422 | Unprocessable | 请求格式正确，但业务语义不成立 |
| 429 | Too Many Requests | 速率限制 |
| 500 | Internal Error | 不可预期服务端错误 |
| 503 | Service Unavailable | 维护/过载 |

**400 与 422 的使用以项目约定为准。** 推荐：
- 400: 请求格式错误、字段类型错误、缺少必填参数
- 422: 请求格式正确，但业务语义不成立

如果项目已有统一约定，优先遵守既有约定。关键不是 400 或 422 的选择，而是全项目一致。

**错误体统一格式：**
```json
{
  "error": {
    "code": "TASK_TITLE_REQUIRED",
    "message": "任务标题不能为空",
    "details": [{ "field": "title", "issue": "required" }],
    "requestId": "req_01HXYZ..."
  }
}
```

| 字段 | 要求 |
|------|------|
| code | 稳定、机器可读，不随文案变化 |
| message | 给人看的说明，可本地化 |
| details | 字段级或上下文级错误 |
| requestId | 用于排查日志和链路追踪 |

**错误 code 命名规则：**
- 使用稳定的大写 snake_case：`TASK_TITLE_REQUIRED`、`TASK_NOT_FOUND`、`TASK_PERMISSION_DENIED`、`TASK_ALREADY_COMPLETED`、`IDEMPOTENCY_KEY_CONFLICT`
- 不要使用会随业务文案变化的 code
- 不要把 message 当作程序判断依据

**不混合错误模式。** 一个端点返回 `{ error: string }`，另一个返回 `{ errors: array }` —— 消费者需要两个解析器。

### 3. 边界验证与业务不变量

验证分三类：

```
1. API 边界验证
   - request body shape
   - query params
   - path params
   - headers
   - required fields
   - type validation

2. Service / Domain 业务规则验证
   - 当前用户是否能操作资源
   - 资源状态是否允许变更
   - 是否违反业务不变量
   - 是否跨租户访问
   - 是否重复提交

3. Adapter 边界验证
   - 外部服务返回 shape
   - 数据库查询结果 shape
   - 第三方 API response shape
```

Service 层可以信任 DTO 的格式正确，但不能跳过业务规则和领域不变量。

**一句话原则：边界验证格式，领域保护规则。**

### 4. 扩展优于修改

```typescript
// Good: 新增可选字段
interface GetTasksQuery {
  status?: 'pending' | 'completed';     // 原来就有
  assigneeId?: string;                   // 新增 — 不影响旧消费者
  page?: number;                         // 新增 — 不影响旧消费者
}

// Bad: 修改现有字段
interface GetTasksQuery {
  status?: 'pending' | 'in_progress' | 'completed';  // 改了枚举 → 旧客户端可能崩溃
}
```

#### 兼容性矩阵

| 变更 | 是否安全 | 说明 |
|------|----------|------|
| 新增 response 可选字段 | 通常安全 | 旧客户端会忽略未知字段 |
| 新增 request 可选字段 | 安全 | 旧客户端不传也能工作 |
| 新增 endpoint | 安全 | 不影响旧客户端 |
| 新增 error code | 谨慎 | 客户端可能未处理 |
| 新增 enum 值 | 高风险 | 强类型客户端可能崩溃 |
| 删除 response 字段 | Breaking | 旧客户端可能依赖 |
| 修改字段类型 | Breaking | 解析逻辑会失败 |
| 修改字段语义 | Breaking | 最危险，表面不报错但业务错 |
| 修改默认排序 | 高风险 | 消费者可能依赖列表顺序 |
| 修改默认值 | 高风险 | 调用方行为会变化 |
| 新增 request 必填字段 | Breaking | 旧客户端无法调用 |
| 改变错误格式 | Breaking | 错误解析器失效 |
| 改变 HTTP status | 高风险 | 客户端分支逻辑失效 |

**判断一个变更是否兼容，不看服务端能不能跑，只看旧客户端是否无需修改仍能正确工作。**

### 5. 可预测命名

| 场景 | 模式 | 示例 |
|------|------|------|
| 资源列表 | GET /资源(复数) | GET /tasks |
| 单个资源 | GET /资源/:id | GET /tasks/123 |
| 创建 | POST /资源 | POST /tasks |
| 全量更新 | PUT /资源/:id | PUT /tasks/123 |
| 部分更新 | PATCH /资源/:id | PATCH /tasks/123 |
| 删除 | DELETE /资源/:id | DELETE /tasks/123 |
| 子资源 | GET /资源/:id/子资源 | GET /tasks/123/comments |

**默认使用资源名词建模，不把 CRUD 动词放在 URL 路径中。**

优先：
```
PATCH /tasks/123
{ "status": "completed" }
```

**谨慎使用操作端点：**
```
POST /tasks/123/complete
```

只有当动作无法自然表达为资源状态更新，或动作会触发复杂业务副作用时，才使用操作端点。

**操作端点适用场景：**
- `POST /orders/:id/cancel` — 取消订单触发退款、库存释放等副作用
- `POST /invoices/:id/send` — 发送发票触发邮件、状态流转
- `POST /tasks/:id/complete` — 完成任务触发通知、统计更新
- `POST /users/:id/reset-password` — 重置密码触发验证流程

前提：动作有明确业务含义、动作不只是普通字段更新、错误语义和幂等性已定义。

## 认证与权限

每个端点必须明确：
- 是否需要认证
- 需要什么角色或权限
- 是否有资源级权限
- 是否有租户隔离
- 无权限时返回 403 还是 404

### 401 / 403 / 404 规则

- **401 Unauthorized**：没有认证凭据，或认证凭据无效
- **403 Forbidden**：已认证，但没有权限
- **404 Not Found**：资源不存在，或为了安全不暴露资源存在性

### 资源可见性规则

如果暴露资源存在性会带来安全风险，权限失败可以返回 404：
- 私有文档
- 多租户资源
- 用户私有数据
- 安全敏感对象

## 输出白名单

API Response 必须使用白名单 DTO，不允许直接序列化数据库 model。

**禁止暴露：**
- passwordHash
- internalNotes
- deletedAt
- tenantInternalId
- permission flags
- provider tokens / refresh tokens / access tokens
- secret keys
- audit-only fields

**输出字段不是"数据库有什么就返回什么"，而是"调用方完成任务需要什么才返回什么"。**

## 分页策略选择

列表接口必须分页。分页策略根据数据规模和使用场景选择。

| 场景 | 推荐策略 | 示例 |
|------|----------|------|
| 后台管理列表 | page/pageSize | GET /tasks?page=1&pageSize=20 |
| 数据量大 | cursor | GET /tasks?cursor=xxx&limit=20 |
| 时间线/feed | cursor | GET /events?after=xxx&limit=50 |
| 排序稳定、可跳页 | page/pageSize | 适合管理后台 |
| 实时变化频繁 | cursor | 避免重复和遗漏 |

### Page Pagination

```typescript
interface PagePaginationQuery {
  page?: number;
  pageSize?: number;
}

interface PagePaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    total?: number;
    totalPages?: number;
  };
}
```

`total` 和 `totalPages` 为可选——有些接口计算 total 很贵，不能强制所有列表都返回。

### Cursor Pagination

```typescript
interface CursorPaginationQuery {
  cursor?: string;
  limit?: number;
}

interface CursorPaginatedResponse<T> {
  data: T[];
  pagination: {
    nextCursor?: string;
    hasMore: boolean;
  };
}
```

## 排序与过滤

列表接口必须定义默认排序。没有稳定排序的分页是不可靠的。

推荐：
- 默认按 `createdAt desc` 或 `id desc`
- 支持明确的 `sort` 参数
- 支持白名单字段排序
- 不允许任意字段排序直接透传到数据库

```typescript
interface GetTasksQuery {
  status?: 'pending' | 'completed';
  assigneeId?: string;
  sort?: '-createdAt' | 'createdAt' | '-updatedAt' | 'updatedAt';
  page?: number;
  pageSize?: number;
}
// GET /tasks?status=pending&assigneeId=123&sort=-createdAt&page=1&pageSize=20
```

## 幂等性

可能被客户端重试的创建类请求必须考虑幂等性。

**需要幂等性的场景：**
- 创建订单 / 创建支付
- 提交任务 / 发送消息
- 触发外部副作用
- 网络超时后客户端可能重试的 POST 请求

**推荐使用 `Idempotency-Key` header：**

```
POST /tasks
Idempotency-Key: idem_01HXYZ...
```

- 相同 `Idempotency-Key` + 相同请求体 → 返回第一次请求的结果
- 相同 `Idempotency-Key` + 不同请求体 → 返回 409 Conflict，`error.code = IDEMPOTENCY_KEY_CONFLICT`

```typescript
interface IdempotencyHeaders {
  'idempotency-key'?: string;
}
```

## 并发控制

当资源可能被多个客户端同时更新时，必须设计并发控制。

**推荐方案：** version 字段 / `updatedAt` 条件更新 / `ETag` + `If-Match` / optimistic locking。

```
PATCH /tasks/123
If-Match: "task-version-7"
```

如果版本不匹配 → 返回 409 Conflict，`error.code = TASK_VERSION_CONFLICT`。

```typescript
interface TaskOutput {
  id: string;
  title: string;
  status: 'pending' | 'completed';
  version: number;
  createdAt: string;
  updatedAt: string;
}

interface PatchTaskRequest {
  title?: string;
  status?: 'completed';
  priority?: 'low' | 'medium' | 'high';
  version: number;  // optimistic lock
}
```

是否把 version 放 body，还是用 `If-Match` header，取决于项目风格。但必须明确一种。

## 基础类型规范

### 时间字段

API 边界使用 `string` 表示时间，格式为 ISO 8601。不要在 API DTO 中使用 `Date` 对象。

```typescript
interface TaskOutput {
  createdAt: string;  // ISO 8601
  updatedAt: string;  // ISO 8601
}
```

### ID 字段

ID 字段使用 `string`，不暴露数据库自增策略。

```typescript
interface TaskOutput {
  id: string;
}
```

### 金额字段

金额不要使用浮点数。推荐使用最小货币单位整数，或 decimal string。

```typescript
// 方案一：最小货币单位整数
interface PriceOutput {
  amountCents: number;
  currency: 'CNY' | 'USD';
}

// 方案二：decimal string
interface PriceOutput {
  amount: string;  // "19.99"
  currency: string;
}
```

## Schema 与运行时验证

TypeScript interface 只提供编译期约束，不能验证外部输入。

**API 边界必须使用运行时 schema：** Zod / Valibot / TypeBox / JSON Schema / OpenAPI Schema。

推荐：
- Request 使用 schema 验证
- Response 使用类型或 schema 约束
- OpenAPI 从 schema 生成，或 schema 与 OpenAPI 保持同步

```typescript
import { z } from 'zod';

export const CreateTaskRequestSchema = z.object({
  title: z.string().min(1),
  priority: z.enum(['low', 'medium', 'high']),
  assigneeId: z.string().optional(),
});

export type CreateTaskRequest = z.infer<typeof CreateTaskRequestSchema>;
```

**不要只写 interface 后直接信任 req.body。**

## 合约测试最低标准

每个 API 端点至少覆盖：

**成功路径：**
- 正确 status code
- response shape
- 必填字段存在
- 字段类型正确
- 不暴露内部字段

**失败路径：**
- 输入验证失败
- 未认证
- 无权限
- 资源不存在
- 业务规则失败
- 幂等键冲突（如适用）
- 版本冲突（如适用）

**列表接口：**
- 默认分页
- page/pageSize 或 cursor/limit 生效
- 空列表返回稳定结构
- 默认排序稳定

**错误格式：**
- 所有错误都符合统一 error shape
- error.code 稳定可断言
- message 不作为程序判断依据

```typescript
describe('POST /tasks contract', () => {
  it('creates a task with valid request', async () => {
    const res = await request(app)
      .post('/tasks')
      .send({ title: 'Write API design', priority: 'high' })
      .expect(201);

    expect(res.body).toMatchObject({
      id: expect.any(String),
      title: 'Write API design',
      priority: 'high',
      status: 'pending',
      createdAt: expect.any(String),
    });
    expect(res.body.passwordHash).toBeUndefined();
    expect(res.body.internalNotes).toBeUndefined();
  });

  it('returns stable error format for invalid request', async () => {
    const res = await request(app)
      .post('/tasks')
      .send({ title: '', priority: 'high' })
      .expect(400);

    expect(res.body).toMatchObject({
      error: {
        code: 'TASK_TITLE_REQUIRED',
        message: expect.any(String),
        details: expect.any(Array),
        requestId: expect.any(String),
      },
    });
  });
});
```

## REST 模式

### 部分更新

```typescript
// PATCH /tasks/123
// Body: 只发送需要更新的字段
interface PatchTaskRequest {
  title?: string;
  status?: 'completed';
  priority?: 'low' | 'medium' | 'high';
}
// 未发送的字段保持原值
```

## TypeScript 接口模式

### DTO 命名

**Request DTO：** `CreateTaskRequest`、`PatchTaskRequest`、`GetTasksQuery`

**Response DTO：** `TaskOutput`、`CreateTaskResponse`、`GetTasksResponse`

不要直接使用：`TaskModel`、`TaskEntity`、`PrismaTask`、`DBTask`

### 判别联合

```typescript
type TaskEvent =
  | { type: 'created'; task: TaskOutput }
  | { type: 'completed'; taskId: string; completedAt: string }
  | { type: 'deleted'; taskId: string };

function handleEvent(event: TaskEvent) {
  switch (event.type) {
    case 'created': return handleCreate(event.task);
    case 'completed': return handleComplete(event.taskId, event.completedAt);
    case 'deleted': return handleDelete(event.taskId);
  }
}
```

### 输入/输出/内部模型分离

```typescript
// Database model
interface TaskModel {
  id: string;
  title: string;
  status: string;
  priority: string;
  tenantId: string;
  internalNotes?: string;
  deletedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

// API input
interface CreateTaskRequest {
  title: string;
  priority: 'low' | 'medium' | 'high';
  assigneeId?: string;
}

// API output
interface TaskOutput {
  id: string;
  title: string;
  status: 'pending' | 'completed';
  priority: 'low' | 'medium' | 'high';
  assigneeId?: string;
  createdAt: string;
  updatedAt: string;
}

// Model → Output 必须经过 mapper，不允许直接 return db model
function toTaskOutput(model: TaskModel): TaskOutput {
  return {
    id: model.id,
    title: model.title,
    status: model.status as TaskOutput['status'],
    priority: model.priority as TaskOutput['priority'],
    createdAt: model.createdAt.toISOString(),
    updatedAt: model.updatedAt.toISOString(),
  };
}
```

**绝不把数据库 model 直接暴露给 API 消费者。**

## API Review 流程

设计 API 时按以下顺序自检：

1. **Resource Review** — 资源是否清楚？是资源状态变化，还是业务动作？是否需要子资源？
2. **Contract Review** — Request / Response 是否完整？Error response 是否完整？是否有 runtime schema？
3. **Compatibility Review** — 是否修改已有字段？是否新增必填字段？是否改变默认排序、默认值、错误 code？
4. **Security Review** — 是否需要认证？是否需要资源级权限？403 / 404 策略是否明确？是否泄露内部字段？
5. **Reliability Review** — 是否需要幂等？是否需要并发控制？是否有 requestId？
6. **Test Review** — 是否有 contract tests？是否覆盖错误路径？是否覆盖分页和权限？

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "现在就我们一个消费者" | Hyrum 法则。未来可能有其他消费者。你有 1 个消费者时最容易做对。 | 新消费者接入时需重构接口 → 响应格式变更影响 2-3 个团队 |
| "字段名随便叫" | 命名是接口的 UI。一致的命名减少消费者困惑和重复问询。 | 消费者每次调用需翻文档 → 集成时间 ×2；命名不一致导致误解和 bug |
| "错误格式不重要" | 错误格式不一致 = 每个消费者需要不同的错误解析器。成本转嫁给了用户。 | 每个消费者写 1 个解析器 ×5 个端点 ×3 种格式 = 15 个解析器 |
| "以后再补分页" | 不分页的列表端点会在某个星期五爆炸。从第一天起给列表接口加分页。 | 数据增长后一次返回 10000+ 条 → 服务崩溃、消费者超时、用户白屏 |
| "v2 用新字段，v1 不兼容就废弃" | 扩展优于版本化。两个版本意味着双倍的维护、文档和调试。 | 维护 2 个版本 = 双倍测试 + 双倍文档 + 双倍 bug；消费者迁移成本 ×3 |
| "POST 重试就重试呗" | 客户端重试是网络环境的正常行为，不是异常。 | 创建重复订单 / 重复扣款 / 重复发送通知 |
| "并发更新很少见" | 用户双击、前端重试、移动端网络切换都会触发并发更新。 | 覆盖更新丢失 → 数据不一致 → 客户投诉 |

## 红旗 — STOP

- 接口定义没有先于实现（先写代码再回头定义类型）
- 只定义成功响应，没有定义错误响应
- 端点间错误格式不一致
- error.message 被客户端当作判断依据
- URL 路径包含 CRUD 动词（`/createTask`、`/getTasks`）
- 普通状态更新却设计成 action endpoint
- 列表接口无分页
- 列表接口无默认排序
- 大数据 / feed 列表使用 page/pageSize 导致性能或一致性问题
- 创建类 POST 有副作用但没有幂等策略
- PATCH / PUT 可能覆盖更新但没有并发控制
- 数据库 model 直接序列化暴露给 API
- API 输出没有白名单 mapper
- 暴露 passwordHash、token、internalNotes、deletedAt 等内部字段
- PATCH 和 PUT 的语义混用
- 新增 request 必填字段
- 修改已有字段类型或语义
- 新增 enum 值但未评估旧客户端
- 权限失败时 403 / 404 策略不明确
- 只写 TypeScript interface，没有运行时 schema 验证
- 没有 contract tests 就进入实现

## 验证失败处理

| 验证项 | 失败表现 | 处理方式 |
|--------|----------|---------|
| 接口类型未先于实现 | 先写了代码再回头定义类型 | 停止实现，先定义 TypeScript interface / schema，再写逻辑 |
| 没有错误 code | 只返回 message | 增加稳定 error.code，message 只给人看 |
| 错误格式不一致 | 不同端点返回不同错误结构 | 统一为 `{ error: { code, message, details, requestId } }` 格式，逐端点修正 |
| 列表端点无分页 | GET /tasks 返回全部数据 | 添加分页参数和 `PaginatedResponse` wrapper |
| 无默认排序 | 分页结果在多次请求之间顺序不稳定 | 增加固定排序字段（如 createdAt desc） |
| 无幂等策略 | POST 重试会重复创建 | 增加 Idempotency-Key 规则 |
| 无并发控制 | 两个 PATCH 相互覆盖 | 增加 version / If-Match |
| 数据库 model 直出 | API 返回包含内部字段 | 定义独立的 Output DTO 和 mapper 白名单 |
| 无权限说明 | endpoint 只写 authenticated | 明确 role、permission、ownership |
| 无 schema | 只有 interface | 增加 Zod / JSON Schema / OpenAPI schema |
| 无兼容性判断 | 修改字段类型或语义 | 停止修改，改为新增字段或制定版本化策略 |
| 枚举新增未评估 | 新增 enum value | 检查强类型客户端 fallback 逻辑 |
| 命名不一致 | 端点混用 snake_case 和 camelCase | 选定命名规范，逐端点修正 |

## 好坏示例

### Good: 合约优先 + 输入/输出分离 + 分页 + 权限 + 幂等

```typescript
// 1. Schema（运行时验证）
const CreateTaskRequestSchema = z.object({
  title: z.string().min(1),
  priority: z.enum(['low', 'medium', 'high']),
  assigneeId: z.string().optional(),
});

// 2. DTO
type CreateTaskRequest = z.infer<typeof CreateTaskRequestSchema>;

interface TaskOutput {
  id: string;
  title: string;
  status: 'pending' | 'completed';
  priority: 'low' | 'medium' | 'high';
  assigneeId?: string;
  version: number;
  createdAt: string;
  updatedAt: string;
}

interface PagePaginatedResponse<T> {
  data: T[];
  pagination: { page: number; pageSize: number; total?: number; };
}

// 3. Endpoint contract
// POST /tasks — authenticated, task:create
// Idempotency-Key supported
// Returns 201 + TaskOutput

// 4. Mapper
function toTaskOutput(model: TaskModel): TaskOutput { ... }
```

### Bad: 实现优先 + 数据库直出 + 无分页 + 无权限

```typescript
// 直接返回数据库 model（包含 passwordHash、internalNotes）
async function getTasks(): Promise<Task[]> {
  return db.tasks.findMany();  // 无分页，返回全部
}
```

## 输出模板

```
API 设计完成：

资源模型:
  - Task: 用户任务资源
  - Comment: 任务评论子资源

端点列表:
  - GET    /tasks              → GetTasksQuery → PagePaginatedResponse<TaskOutput>
  - POST   /tasks              → CreateTaskRequest → TaskOutput
  - GET    /tasks/:id          → TaskOutput
  - PATCH  /tasks/:id          → PatchTaskRequest → TaskOutput
  - DELETE /tasks/:id          → 204
  - GET    /tasks/:id/comments → CursorPaginatedResponse<CommentOutput>

权限规则:
  - 所有端点需要 authenticated
  - GET /tasks/:id 需要 task:read + tenant ownership
  - PATCH /tasks/:id 需要 task:write + tenant ownership
  - 无权限是否返回 403/404: 私有资源返回 404

错误格式:
  { error: { code, message, details, requestId } }

错误 code:
  - TASK_TITLE_REQUIRED
  - TASK_NOT_FOUND
  - TASK_PERMISSION_DENIED
  - TASK_VERSION_CONFLICT
  - IDEMPOTENCY_KEY_CONFLICT

命名规范:
  - URL path: plural resource names
  - JSON body: camelCase
  - TypeScript: camelCase
  - Error code: UPPER_SNAKE_CASE

分页:
  - 管理列表使用 page/pageSize
  - Feed/大数据列表使用 cursor/limit
  - 列表接口必须有默认排序

幂等性:
  - 创建类 POST 如有副作用，支持 Idempotency-Key
  - 幂等键冲突返回 409

并发控制:
  - PATCH/PUT 使用 version 或 If-Match
  - 版本冲突返回 409

输入/输出分离:
  - CreateTaskRequest / PatchTaskRequest / TaskOutput
  - 不暴露 DB model
  - 输出通过 mapper 白名单转换

Schema:
  - Request schema: src/schemas/task.schema.ts
  - API types: src/types/api.ts
  - OpenAPI: openapi.yaml 或自动生成

合约测试:
  - tests/api-contracts/tasks.contract.test.ts

Done When:
  - endpoint、DTO、schema、错误 code、权限、分页、幂等、并发控制、contract tests 全部定义完成
  - 未进入业务实现
```

## 验证清单

### Contract Checklist

- [ ] 每个 endpoint 都有 method + path
- [ ] 每个 endpoint 都有 Request DTO
- [ ] 每个 endpoint 都有 Response DTO
- [ ] 每个 endpoint 都定义成功 status code
- [ ] 每个 endpoint 都定义错误 status code
- [ ] 每个错误都有稳定 error.code
- [ ] 所有错误响应使用统一格式
- [ ] 每个 endpoint 都定义认证要求
- [ ] 每个 endpoint 都定义权限要求
- [ ] 每个列表 endpoint 都有分页
- [ ] 每个列表 endpoint 都有默认排序
- [ ] 创建类 POST 已评估幂等性
- [ ] PATCH / PUT 已评估并发控制
- [ ] API DTO 与 DB model 分离
- [ ] 不暴露敏感字段
- [ ] 时间字段使用 ISO string
- [ ] 金额字段不用 float
- [ ] schema 可运行时验证
- [ ] contract tests 覆盖成功和失败路径

### Compatibility Checklist

- [ ] 没有删除 response 字段
- [ ] 没有修改字段类型
- [ ] 没有修改字段语义
- [ ] 没有新增 request 必填字段
- [ ] 没有改变默认排序
- [ ] 没有改变默认值
- [ ] 没有改变错误格式
- [ ] 没有改变已有 error.code
- [ ] 新增 enum 值已评估强类型客户端影响
- [ ] breaking change 已明确迁移策略

### Security Checklist

- [ ] 未认证返回 401
- [ ] 无权限返回 403 或安全隐藏为 404
- [ ] 多租户资源检查 tenant ownership
- [ ] 不暴露 passwordHash / token / secret / internal fields
- [ ] 输入字段有白名单
- [ ] sort/filter 不直接透传数据库字段
- [ ] 错误 message 不泄露内部实现细节
