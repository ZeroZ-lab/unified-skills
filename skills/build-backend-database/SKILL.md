---
name: build-backend-database
description: 数据库工程——迁移、查询优化、数据完整性。使用 cuando 需要设计数据库 schema、写迁移或优化查询
---

# Database — 数据库工程


## 入口/出口
- **入口**: 需要新增/修改数据库表、写迁移、或优化慢查询
- **出口**: 可回滚的迁移脚本 + 验证过的查询 + 数据完整性约束
- **指向**: 完成后回到 `build-workflow-execute` 继续下一个切片
- **假设已加载**: CANON.md

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

| 说辞 | 现实 |
|------|------|
| "约束在应用代码做就行" | 应用层约束绕过了数据库保护。直接 SQL 更新、数据修复、ETL 都无保护。数据库约束是最后的安全网。 |
| "先加列，索引以后再建" | 先加索引，查询快就是现在。用户等待的不是索引。 |
| "这个表很小，不需要索引" | 小表现在。小表变大的速度惊人。建索引成本低。 |
| "EXPLAIN 等到出问题再看" | 写查询时 EXPLAIN 花 5 秒。上线后排查慢查询花 5 小时。 |
| "迁移不用 DOWN——不会回滚" | 你会的。而且出问题时凌晨 3 点写回滚脚本更痛苦。 |

## 红旗 — STOP

- Query loop 中还有查询（N+1）
- 没有 DOWN 脚本的迁移文件
- 生产数据库手动改过数据——没记录、没迁移、没人知道
- 迁移用 `CASCADE` 删表（一不留神删了关联数据）
- `SELECT *` 在生产代码中（列加多了返回太多不必要数据）
- 没有 WHERE 的 UPDATE/DELETE（整表灾难）

## 验证清单

- [ ] 迁移有 UP 和 DOWN
- [ ] 关键列有 NOT NULL + CHECK 约束
- [ ] EXPLAIN 显示 Index Scan（非 Seq Scan on large table）
- [ ] 没有 N+1 查询模式
- [ ] 外键引用定义
- [ ] 时间列使用 TIMESTAMPTZ
- [ ] 迁移在 staging 验证过
