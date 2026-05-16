---
name: build-backend-api-design
description: API 和接口设计——稳定合约、清晰边界。当需要设计 REST/GraphQL API、模块接口或数据合约，或提到"endpoint""接口设计""契约"
---

# API Design — 接口与合约设计


## 入口/出口
- **入口**: 需要定义新 API 端点、模块接口或跨服务合约
- **出口**: 类型定义 + 合约测试 + 接口文档
- **指向**: 接口稳定后进入实现（`build-workflow-execute`）
- **前置加载**: CANON.md + `build-quality-tdd/SKILL.md`
- **输出路径**: 接口稳定后进入 `build-workflow-execute`

## 何时不使用
- 只是实现既有 API，不改变请求/响应、错误语义或模块边界
- 纯内部重构，调用方不可观察的合约没有变化
- 数据库 schema 或查询设计是主要问题（使用 `build-backend-database`）

## 核心原则

### Hyrum 法则

```
有足够多的用户时，每个可观察到的行为都会变成事实合约。
```

你以为是实现细节的——响应字段顺序、错误消息文本、默认值——消费者可能已经依赖了。**设计时就假定每个行为都是永久的。**

### 单版本原则

设计时假设世界上只有一个版本。不预先设计 v2。设计你需要的那个 API，使它扩展而非被替换。

### 1. 合约优先

```typescript
// 1. 先定义合约
interface CreateTaskRequest {
  title: string;
  description?: string;
  assigneeId?: string;
  priority: 'low' | 'medium' | 'high';
}

interface CreateTaskResponse {
  task: Task;
}

// 2. 再实现
async function createTask(req: CreateTaskRequest): Promise<CreateTaskResponse> {
  // ...
}
```

**先写类型 → 再写逻辑。** 接口就是文档。代码就是合约。

### 2. 一致错误语义

| HTTP Status | 语义 | 何时使用 |
|-------------|------|---------|
| 200 | OK | GET/PUT/PATCH 成功 |
| 201 | Created | POST 创建新资源 |
| 204 | No Content | DELETE 成功 |
| 400 | Bad Request | 输入验证失败（可修复） |
| 401 | Unauthorized | 缺少认证凭据 |
| 403 | Forbidden | 有凭据但无权限 |
| 404 | Not Found | 资源不存在 |
| 409 | Conflict | 版本冲突、幂等键冲突 |
| 422 | Unprocessable | 语义错误（业务规则不符） |
| 429 | Too Many Requests | 速率限制 |
| 500 | Internal Error | 不可预期服务端错误 |
| 503 | Service Unavailable | 维护/过载 |

**错误体统一格式：**
```json
{
  "error": {
    "code": "TASK_TITLE_REQUIRED",
    "message": "任务标题不能为空",
    "details": [{ "field": "title", "issue": "required" }]
  }
}
```

**不混合错误模式。** 一个端点返回 `{ error: string }`，另一个返回 `{ errors: array }` —— 消费者需要两个解析器。

### 3. 边界验证

```
验证发生在边界：
  API Handler（请求体、参数、headers）
  数据库 Adapter（查询参数、结果 shape）

不在内部做验证：
  Service 层信任已通过边界验证的数据
  内部函数不做重复的参数检查
```

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
| 操作 | POST /资源/:id/操作 | POST /tasks/123/complete |

**不把动词放在 URL 路径。** HTTP method 就是动词。

## REST 模式

### 分页

```typescript
interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
}

// 用法: GET /tasks?page=1&pageSize=20
```

### 部分更新

```typescript
// PATCH /tasks/123
// Body: 只发送需要更新的字段
interface PatchTaskRequest {
  title?: string;          // 仅当需要修改时发送
  status?: 'completed';
  priority?: 'high';
}
// 未发送的字段保持原值
```

## TypeScript 接口模式

### 判别联合

```typescript
type TaskEvent =
  | { type: 'created'; task: Task }
  | { type: 'completed'; taskId: string; completedAt: Date }
  | { type: 'deleted'; taskId: string };

function handleEvent(event: TaskEvent) {
  switch (event.type) {
    case 'created': return handleCreate(event.task);
    case 'completed': return handleComplete(event.taskId, event.completedAt);
    case 'deleted': return handleDelete(event.taskId);
  }
}
```

### 输入/输出分离

```typescript
// API 边界: 输入 + 输出不同
interface TaskCreateInput {
  title: string;
  priority: 'low' | 'medium' | 'high';
}
interface TaskOutput {
  id: string;
  title: string;
  status: 'pending' | 'completed';
  createdAt: string;
}

// 绝不把数据库 model 直接暴露给 API 消费者
```

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "现在就我们一个消费者" | Hyrum 法则。未来可能有其他消费者。你有 1 个消费者时最容易做对。 | 新消费者接入时需重构接口 → 响应格式变更影响 2-3 个团队 |
| "字段名随便叫" | 命名是接口的 UI。一致的命名减少消费者困惑和重复问询。 | 消费者每次调用需翻文档 → 集成时间 ×2；命名不一致导致误解和 bug |
| "错误格式不重要" | 错误格式不一致 = 每个消费者需要不同的错误解析器。成本转嫁给了用户。 | 每个消费者写 1 个解析器 ×5 个端点 ×3 种格式 = 15 个解析器 |
| "以后再补分页" | 不分页的列表端点会在某个星期五爆炸。从第一天起给列表接口加分页。 | 数据增长后一次返回 10000+ 条 → 服务崩溃、消费者超时、用户白屏 |
| "v2 用新字段，v1 不兼容就废弃" | 扩展优于版本化。两个版本意味着双倍的维护、文档和调试。 | 维护 2 个版本 = 双倍测试 + 双倍文档 + 双倍 bug；消费者迁移成本 ×3 |

## 红旗 — STOP

- 接口定义没有先于实现（先写代码再回头定义类型）
- 端点间错误格式不一致
- URL 路径包含动词（`/createTask`、`/getTasks`）
- 列表接口无分页
- 数据库 model 直接序列化暴露给 API
- PATCH 和 PUT 的语义混用

## 验证失败处理

| 验证项 | 失败表现 | 处理方式 |
|--------|----------|---------|
| 接口类型未先于实现 | 先写了代码再回头定义类型 | 停止实现，先定义 TypeScript interface / schema，再写逻辑 |
| 错误格式不一致 | 不同端点返回不同错误结构 | 统一为 `{ error: { code, message, details } }` 格式，逐端点修正 |
| 列表端点无分页 | GET /tasks 返回全部数据 | 添加 `page` / `pageSize` 参数和 `PaginatedResponse` wrapper |
| 数据库 model 直接暴露 | API 返回包含内部字段（如 passwordHash） | 定义独立的 Output 类型，只暴露消费者需要的字段 |
| 命名不一致 | 端点混用 snake_case 和 camelCase | 选定一种命名规范（REST: snake_case，JS: camelCase），逐端点修正 |

## 好坏示例

### Good: 合约优先 + 输入/输出分离 + 分页
```typescript
// 1. 先定义合约
interface CreateTaskRequest {
  title: string;
  priority: 'low' | 'medium' | 'high';
}
interface TaskOutput {
  id: string;
  title: string;
  status: 'pending' | 'completed';
  createdAt: string;
}
interface PaginatedResponse<T> {
  data: T[];
  pagination: { page: number; pageSize: number; total: number; };
}
// 2. 再实现
async function createTask(req: CreateTaskRequest): Promise<TaskOutput> { ... }
```

### Bad: 实现优先 + 数据库直出 + 无分页
```typescript
// 直接返回数据库 model（包含 passwordHash、internalNotes）
async function getTasks(): Promise<Task[]> {
  return db.tasks.findMany();  // 无分页，返回全部
}
```

## 输出模板

```
API 设计完成：

端点列表:
  - GET    /tasks          → PaginatedResponse<TaskOutput>
  - POST   /tasks          → CreateTaskRequest → TaskOutput
  - GET    /tasks/:id      → TaskOutput
  - PATCH  /tasks/:id      → PatchTaskRequest → TaskOutput
  - DELETE /tasks/:id      → 204

错误格式: { error: { code, message, details } }
命名规范: REST snake_case / JS camelCase
分页: page + pageSize, PaginatedResponse wrapper
输入/输出分离: CreateTaskRequest / TaskOutput (不暴露 DB model)

类型定义路径: src/types/api.ts
合约测试路径: tests/api-contracts/
```

## 验证清单

- [ ] 接口类型先于实现定义
- [ ] 错误格式在所有端点间一致
- [ ] 列表端点有分页
- [ ] 所有输入在边界验证
- [ ] 命名一致（复数资源、不混用 snake_case/camelCase）
- [ ] 新字段是添加（扩展）而非修改已有字段
