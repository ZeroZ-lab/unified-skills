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

## 核心锚点

### Hyrum's Law

所有可观察行为都可能成为事实合约。字段类型、null 语义、默认值、错误 code、HTTP status、排序、分页结构均视为合约。

**执行规则：** 设计时假定每个行为都是永久的。判断变更是否兼容，不看服务端能不能跑，只看旧客户端是否无需修改仍能正确工作。

### Contract-first / Schema-first

先定义 Method + Path + Request + Response + Error + Auth + Pagination + Schema，再进入实现。

**执行规则：** API 设计顺序——资源 → endpoint → Request DTO → Response DTO → Error Codes → 权限 → 分页/排序/过滤 → 幂等/并发 → schema → contract tests → 再进入实现。

### RFC 9110 / RFC 5789

遵循 HTTP method 语义。默认使用资源名词建模，不把 CRUD 动词放在 URL 路径中。

**执行规则：**
- GET 查询，POST 创建/动作，PUT 全量更新，PATCH 部分更新，DELETE 删除
- 操作端点（`POST /tasks/:id/complete`）仅在动作有明确业务含义、触发复杂副作用、且错误语义和幂等性已定义时使用
- 普通状态更新优先 `PATCH /tasks/:id { "status": "completed" }`

### RFC 9457 / Problem Details

错误响应必须统一、稳定、机器可读。

**执行规则：**
- 格式：`{ error: { code, message, details, requestId } }`
- `code`：大写 snake_case，稳定不变，如 `TASK_TITLE_REQUIRED`、`IDEMPOTENCY_KEY_CONFLICT`
- `message`：给人看的，可本地化，不作为程序判断依据
- `requestId`：用于排查和链路追踪
- 400 vs 422 以项目约定为准，关键是全项目一致

### DTO / Clean Architecture

DB Model 是内部实现，API Output 是外部合约。

**执行规则：**
- Response 必须通过 Output DTO / mapper 白名单转换，不得直接 return db model
- 禁止暴露：passwordHash、internalNotes、deletedAt、tenantInternalId、token、secret、audit-only fields
- 输出字段不是"数据库有什么就返回什么"，而是"调用方完成任务需要什么才返回什么"

### DDD Domain Invariants

API 边界验证格式；Service / Domain 保护业务规则和不变量。

**执行规则：**
- API 边界：request body shape、query/params、headers、required fields、type validation
- Service / Domain：权限、资源状态、业务不变量、租户隔离、重复提交
- Adapter 边界：外部服务返回 shape、数据库查询结果 shape
- 一句话原则：**边界验证格式，领域保护规则。**

### Backward Compatibility

优先兼容扩展，避免 breaking change。

**执行规则：** 遵循兼容性矩阵——新增可选字段通常安全；修改字段类型/语义、删除字段、新增必填字段、修改默认排序/默认值/错误格式通常 breaking。版本化是最后手段，不是默认方案。

### Idempotency-Key

有副作用且可能重试的 POST 必须评估幂等性。

**执行规则：** 推荐 `Idempotency-Key` header。相同 key + 相同 body → 返回第一次结果；相同 key + 不同 body → 409 Conflict `IDEMPOTENCY_KEY_CONFLICT`。

### Optimistic Locking

可能并发更新的 PATCH / PUT 必须评估 version / ETag / If-Match。

**执行规则：** version 放 body 或 `If-Match` header 取决于项目风格，但必须明确一种。版本冲突返回 409 `TASK_VERSION_CONFLICT`。

### Cursor / Page Pagination

列表接口必须分页，必须定义默认排序。

**执行规则：**
- 后台管理列表 → page/pageSize；大数据/feed/实时变化 → cursor/limit
- 默认按 `createdAt desc` 或 `id desc`
- 支持白名单字段排序，不允许任意字段透传数据库
- `total` / `totalPages` 为可选（计算 total 可能很贵）

### Schema / Runtime Validation

TypeScript interface 只提供编译期约束。API 边界必须使用运行时 schema（Zod / Valibot / TypeBox / JSON Schema / OpenAPI）。

**执行规则：** Request 使用 schema 验证；OpenAPI 从 schema 生成或保持同步。**不要只写 interface 后直接信任 req.body。**

### 基础类型规范

- 时间：ISO 8601 string，不在 DTO 中使用 Date 对象
- ID：string，不暴露数据库自增策略
- 金额：最小货币单位整数或 decimal string，不用 float

## 认证与权限

每个端点必须明确：是否需要认证、角色/权限、资源级权限、租户隔离、无权限时 403 还是 404。

- **401**：无认证或凭据无效
- **403**：已认证但无权限
- **404**：资源不存在，或为安全不暴露资源存在性（私有文档、多租户资源、用户私有数据）

## API Review 流程

设计 API 时按顺序自检：Resource → Contract → Compatibility → Security → Reliability → Test。


## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "现在就我们一个消费者" | Hyrum 法则。1 个消费者时最容易做对。 | 新消费者接入时需重构接口 |
| "错误格式不重要" | 不一致 = 每个消费者需要不同的解析器。 | n 个端点 × m 种格式 = n×m 个解析器 |
| "以后再补分页" | 不分页的列表端点会在某个星期五爆炸。 | 数据增长后服务崩溃、超时 |
| "v2 不兼容就废弃" | 扩展优于版本化，两个版本 = 双倍维护。 | 双倍测试 + 双倍 bug + 迁移成本 |
| "POST 重试就重试呗" | 客户端重试是网络环境的正常行为。 | 重复订单 / 重复扣款 |
| "并发更新很少见" | 双击、重试、移动端网络切换都会触发。 | 覆盖更新丢失 |

## 红旗 — STOP

- 没有先定义合约就开始实现
- 只定义成功响应，没有错误响应
- 端点错误格式不一致
- error.message 被客户端当作判断依据
- URL 路径包含 CRUD 动词（`/createTask`、`/getTasks`）
- 普通状态更新却设计成 action endpoint
- 列表无分页或无默认排序
- 大数据/feed 列表使用 page/pageSize 导致性能或一致性问题
- POST 有副作用但无幂等策略
- PATCH / PUT 无并发控制
- DB model 直接返回
- API 输出没有白名单 mapper
- 暴露 passwordHash、token、internalNotes 等内部字段
- 新增 request 必填字段
- 修改已有字段类型或语义
- 新增 enum 值未评估旧客户端
- 权限失败时 403 / 404 策略不明确
- 只写 TypeScript interface，没有 runtime schema
- 没有 contract tests 就进入实现

## 验证失败处理

| 验证项 | 失败表现 | 处理方式 |
|--------|----------|---------|
| 合约未先于实现 | 先写代码再定义类型 | 停止实现，先定义 schema 和 DTO |
| 没有错误 code | 只返回 message | 增加稳定 error.code，message 只给人看 |
| 错误格式不一致 | 不同端点不同错误结构 | 统一为 `{ error: { code, message, details, requestId } }` |
| 无分页 | 列表返回全部数据 | 添加分页参数和 PaginatedResponse wrapper |
| 无默认排序 | 分页结果顺序不稳定 | 增加固定排序字段 |
| 无幂等策略 | POST 重试重复创建 | 增加 Idempotency-Key |
| 无并发控制 | PATCH 相互覆盖 | 增加 version / If-Match |
| DB model 直出 | 返回内部字段 | 定义 Output DTO 和 mapper |
| 无权限说明 | 只写 authenticated | 明确 role、permission、ownership |
| 无 schema | 只有 interface | 增加 Zod / OpenAPI schema |
| 修改已有字段 | 改类型或语义 | 停止，改为新增字段或版本化策略 |

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
  - TASK_TITLE_REQUIRED / TASK_NOT_FOUND / TASK_PERMISSION_DENIED
  - TASK_VERSION_CONFLICT / IDEMPOTENCY_KEY_CONFLICT

命名规范:
  - URL path: plural resource names
  - JSON body: camelCase
  - TypeScript: camelCase
  - Error code: UPPER_SNAKE_CASE

分页: 管理列表 page/pageSize，Feed/大数据 cursor/limit，必须有默认排序
幂等性: 有副作用的 POST 支持 Idempotency-Key，冲突返回 409
并发控制: PATCH/PUT 使用 version 或 If-Match，冲突返回 409
输入/输出分离: Output DTO + mapper 白名单，不暴露 DB model
Schema: src/schemas/task.schema.ts + src/types/api.ts + openapi.yaml
合约测试: tests/api-contracts/tasks.contract.test.ts

Done When:
  - endpoint、DTO、schema、错误 code、权限、分页、幂等、并发控制、contract tests 全部定义完成
  - 未进入业务实现
```

## 验证清单

### Contract Checklist

- [ ] 每个 endpoint 都有 method + path
- [ ] 每个 endpoint 都有 Request DTO 和 Response DTO
- [ ] 每个 endpoint 都定义成功和错误 status code
- [ ] 每个错误都有稳定 error.code
- [ ] 所有错误响应使用统一格式
- [ ] 每个 endpoint 都定义认证和权限要求
- [ ] 每个列表 endpoint 都有分页和默认排序
- [ ] 创建类 POST 已评估幂等性
- [ ] PATCH / PUT 已评估并发控制
- [ ] API DTO 与 DB model 分离
- [ ] schema 可运行时验证
- [ ] contract tests 覆盖成功和失败路径

### Compatibility Checklist

- [ ] 没有删除 response 字段或修改字段类型/语义
- [ ] 没有新增 request 必填字段
- [ ] 没有改变默认排序、默认值、错误格式或已有 error.code
- [ ] 新增 enum 值已评估旧客户端影响
- [ ] breaking change 已明确迁移策略

### Security Checklist

- [ ] 未认证返回 401，无权限返回 403 或安全隐藏为 404
- [ ] 多租户资源检查 tenant ownership
- [ ] 不暴露 passwordHash / token / secret / internal fields
- [ ] sort/filter 不直接透传数据库字段
- [ ] 错误 message 不泄露内部实现细节
