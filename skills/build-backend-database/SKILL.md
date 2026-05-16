---
name: build-backend-database
description: 数据库工程——迁移、查询优化、数据完整性。当需要设计 schema、写迁移、优化查询，或提到"数据库""migration""索引"
---

# Database — 数据库工程


## 入口/出口
- **入口**: 需要新增/修改数据库表、写迁移、或优化慢查询
- **出口**: 可回滚的迁移脚本 + 验证过的查询 + 数据完整性约束
- **指向**: 完成后回到 `build-workflow-execute` 继续下一个切片
- **前置加载**: CANON.md
- **输出路径**: 完成后回到 `build-workflow-execute` 继续下一个切片

## 何时不使用
- 只改 API 层字段命名或请求校验，不涉及持久化结构
- 纯前端状态、缓存或展示逻辑问题
- 数据库行为已经明确，只是在实现业务代码

## Schema 设计原则

### 命名约定

```sql
-- Good: 语义明确、蛇形命名
CREATE TABLE task_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id),
  user_id UUID NOT NULL REFERENCES users(id),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Bad: 缩写、驼峰、缺少约束
CREATE TABLE taskAssign (
  id TEXT,
  taskId TEXT,
  usr TEXT
);
```

**规则:**
- 表名: 复数、snake_case（`tasks`、`task_assignments`）
- 列名: snake_case（`created_at` 不 `createdAt`）
- 主键: `UUID`（分布式友好）或 `BIGSERIAL`（单库性能）
- 时间: `TIMESTAMPTZ`（带时区），不裸存 `TIMESTAMP`
- 布尔: `is_active`、`is_deleted`（前缀 `is_`/`has_`）

### 约束前置

```sql
-- 约束是数据库的"类型系统"——让数据库保护数据
CREATE TABLE tasks (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL CHECK (char_length(title) > 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
  priority INTEGER NOT NULL DEFAULT 0 CHECK (priority >= 0 AND priority <= 3),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**永远在数据库层加约束。** 应用代码是最后一个防线，不是唯一的。

## 迁移

### 迁移铁律

```
每份迁移必须有 UP（应用）和 DOWN（回滚）。
迁移在生产前在 staging 验证。
不做不可回滚的迁移（DROP COLUMN 需先标记 deprecated）。
```

```sql
-- UP
ALTER TABLE tasks ADD COLUMN due_date TIMESTAMPTZ;

-- DOWN
ALTER TABLE tasks DROP COLUMN due_date;
```

### 零停机迁移模式

```sql
-- 危险: 锁表
ALTER TABLE tasks ADD COLUMN description TEXT NOT NULL;

-- 安全: 分步
-- Migration 1: 添加可空列
ALTER TABLE tasks ADD COLUMN description TEXT;

-- 代码部署: 改为写入新列

-- Migration 2: 回填旧数据
UPDATE tasks SET description = '' WHERE description IS NULL;

-- Migration 3: 加 NOT NULL 约束
ALTER TABLE tasks ALTER COLUMN description SET NOT NULL;
```

## 查询优化

### N+1 检测

```typescript
// N+1: 先查任务列表 → 逐个查负责人
const tasks = await db.tasks.findMany();             // 1 query
for (const task of tasks) {
  task.assignee = await db.users.findById(task.assigneeId);  // N queries
}
// Total: N+1 queries

// Fix: 一次 JOIN 或 batch 查询
const tasks = await db.tasks.findMany({
  include: { assignee: true },  // 1 query with JOIN
});
```

**任何 `.findMany()` 后的循环中出现数据库查询 → N+1 红旗。**

### EXPLAIN 验证

```sql
-- 在写复杂查询后立即 EXPLAIN
EXPLAIN ANALYZE
SELECT * FROM tasks
WHERE assignee_id = 'abc' AND status = 'pending'
ORDER BY created_at DESC;

-- 检查: 是否用了索引？Seq Scan 还是 Index Scan？
-- Seq Scan on large table → 加索引
```

### 索引策略

```sql
-- 为查询模式加索引，不为列盲目加索引
-- 查询: WHERE assignee_id = X AND status = 'pending'
CREATE INDEX idx_tasks_assignee_status ON tasks(assignee_id, status);

-- 查询: ORDER BY created_at DESC
CREATE INDEX idx_tasks_created_at ON tasks(created_at DESC);

-- 不单独索引每个列——组合索引通常更优
```

## 种子数据 vs 迁移数据

```
Migration: 逐渐改变 schema —— 每个版本累积
Seed: 开发/测试所需的数据 —— 幂等、可重复运行

不要混在一起。Seed 脚本不应出现在迁移中。
```

## 数据完整性检查表

- [ ] 主键定义
- [ ] 外键引用
- [ ] NOT NULL 在必填列
- [ ] UNIQUE 约束在业务唯一键
- [ ] CHECK 约束在所有枚举/范围
- [ ] 默认值定义
- [ ] 时间戳自动设置（`created_at`、`updated_at`）
- [ ] 索引覆盖常用查询
- [ ] 软删除一致（`deleted_at` 模式或 `is_deleted` 标志）

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "约束在应用代码做就行" | 应用层约束绕过了数据库保护。直接 SQL 更新、数据修复、ETL 都无保护。数据库约束是最后的安全网。 | 数据损坏风险 ×10；绕过应用层直接 SQL = 无校验 = 垃圾数据入库 |
| "先加列，索引以后再建" | 先加索引，查询快就是现在。用户等待的不是索引。 | 无索引查询在大表上慢 ×100-1000；生产慢查询影响所有用户 |
| "这个表很小，不需要索引" | 小表现在。小表变大的速度惊人。建索引成本低。 | 表从 1000 行到 100 万行 = 查询从 <10ms 到 >500ms；补索引需停服或锁表 |
| "EXPLAIN 等到出问题再看" | 写查询时 EXPLAIN 花 5 秒。上线后排查慢查询花 5 小时。 | 生产慢查询排查 5 小时 vs 开发时 EXPLAIN 5 秒；影响比 = 3600:1 |
| "迁移不用 DOWN——不会回滚" | 你会的。而且出问题时凌晨 3 点写回滚脚本更痛苦。 | 无 DOWN 脚本 = 凌晨紧急手写回滚 = 30-60 分钟高风险操作；有 DOWN = 5 秒回滚 |

## 红旗 — STOP

- Query loop 中还有查询（N+1）
- 没有 DOWN 脚本的迁移文件
- 生产数据库手动改过数据——没记录、没迁移、没人知道
- 迁移用 `CASCADE` 删表（一不留神删了关联数据）
- `SELECT *` 在生产代码中（列加多了返回太多不必要数据）
- 没有 WHERE 的 UPDATE/DELETE（整表灾难）

## 验证失败处理

| 验证项 | 失败表现 | 处理方式 |
|--------|----------|---------|
| 迁移无 DOWN 脚本 | 只有 UP，没有回滚 | 补写 DOWN 脚本；不可回滚操作需先标记 deprecated 再分步执行 |
| 关键列无约束 | NOT NULL / CHECK 缺失 | 在数据库层添加约束；应用层验证是补充不是替代 |
| EXPLAIN 显示 Seq Scan | 大表全表扫描 | 为查询模式添加组合索引；WHERE + ORDER BY 列优先 |
| N+1 查询 | findMany 循环中嵌套查询 | 改为 include/JOIN 批量查询；检查每个循环内的数据库调用 |
| 时间列用 TIMESTAMP | 不带时区存储 | 改为 TIMESTAMPTZ；数据迁移需统一为 UTC |

## 好坏示例

### Good: 约束前置 + 索引覆盖 + 分步迁移
```sql
-- 约束和默认值一起定义
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL CHECK (char_length(title) > 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- 索引覆盖常用查询
CREATE INDEX idx_tasks_status_assignee ON tasks(status, assignee_id);

-- 分步零停机迁移
-- M1: ALTER TABLE tasks ADD COLUMN description TEXT;     (可空)
-- M2: UPDATE tasks SET description = '' WHERE description IS NULL;  (回填)
-- M3: ALTER TABLE tasks ALTER COLUMN description SET NOT NULL;       (加约束)
```

### Bad: 无约束 + 无索引 + 不可回滚迁移
```sql
CREATE TABLE taskAssign (id TEXT, taskId TEXT, usr TEXT);  -- 无约束、缩写列名
-- 无 DOWN 脚本
ALTER TABLE tasks ADD COLUMN description TEXT NOT NULL;    -- 锁表、不可回滚
SELECT * FROM tasks;  -- SELECT * + 无 WHERE + 无索引
```

## 输出模板

```
数据库工程完成：

迁移文件:
  - migrations/<timestamp>_add_tasks_description.up.sql
  - migrations/<timestamp>_add_tasks_description.down.sql
  迁移在 staging 已验证: [是/否]

Schema 变更:
  - 新表: [表名 + 约束数]
  - 新列: [列名 + NOT NULL/DEFAULT/CHECK]
  - 新索引: [索引名 + 覆盖查询模式]
  - 外键: [引用关系]

查询优化:
  - N+1 检查: [已修复/无]
  - EXPLAIN 结果: [Index Scan / Seq Scan]
  - 关键查询延迟: [目标 < 50ms]

数据完整性:
  - 约束覆盖: [主键/外键/NOT NULL/CHECK/UNIQUE/DEFAULT]
  - 时间列: TIMESTAMPTZ
  - 软删除: [deleted_at 模式 / is_deleted 标志]
```

## 验证清单

- [ ] 迁移有 UP 和 DOWN
- [ ] 关键列有 NOT NULL + CHECK 约束
- [ ] EXPLAIN 显示 Index Scan（非 Seq Scan on large table）
- [ ] 没有 N+1 查询模式
- [ ] 外键引用定义
- [ ] 时间列使用 TIMESTAMPTZ
- [ ] 迁移在 staging 验证过
