# Database Engineering References — 补充材料

> `build-backend-database` 的辅助参考。主 SKILL.md 只保留短例和锚点，详细示例和论述在此按需加载。

---

## 1. Schema 命名约定

### 项目约定（非绝对标准，团队统一即可）

| 约定 | 推荐值 | 取舍 |
|------|--------|------|
| 表名 | 复数 snake_case：`tasks`、`task_assignments` | 有些团队用单数，统一比选择更重要 |
| 列名 | snake_case：`created_at` | 不用 camelCase |
| 主键 | `UUID`（分布式、外部暴露 ID）或 `BIGSERIAL`（单库性能） | UUID 索引局部性差但避免递增泄漏；BIGSERIAL 简单高效 |
| 时间 | `TIMESTAMPTZ`（带时区） | 不裸存 `TIMESTAMP`；存储 UTC，展示层转换 |
| 布尔 | `is_active`、`has_permission`（前缀 `is_`/`has_`） | — |

### 短例

```sql
CREATE TABLE task_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id),
  user_id UUID NOT NULL REFERENCES users(id),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 2. 约束前置详细示例

数据库约束是数据的类型系统。应用验证是补充，数据库约束是最后防线。

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL CHECK (char_length(title) > 0),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'in_progress', 'completed')),
  priority INTEGER NOT NULL DEFAULT 0
    CHECK (priority >= 0 AND priority <= 3),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 3. 零停机迁移：Expand-Contract 完整案例

### 场景：给 tasks 表加 NOT NULL 的 description 列

**错误做法——一次性加 NOT NULL：**

```sql
-- 危险: 锁表，现有行无值会失败
ALTER TABLE tasks ADD COLUMN description TEXT NOT NULL;
```

**正确做法——Expand → Migrate → Contract：**

```sql
-- Step 1 (Expand): 添加可空列
ALTER TABLE tasks ADD COLUMN description TEXT;

-- Step 2 (Code Deploy): 改为写入新列，兼容新旧读取

-- Step 3 (Migrate/Backfill): 回填旧数据
UPDATE tasks SET description = '' WHERE description IS NULL;

-- Step 4 (Contract): 加 NOT NULL 约束
ALTER TABLE tasks ALTER COLUMN description SET NOT NULL;
```

### 场景：删除旧列

```sql
-- Step 1 (Expand): 新代码不再读取旧列
-- Step 2 (Code Deploy): 部署不再读旧列的代码
-- Step 3 (Contract): 确认无读取后删除
ALTER TABLE tasks DROP COLUMN old_description;
```

**注意**：DROP COLUMN 必须跨至少一个 release 周期，确认旧代码不再部署后才执行。

---

## 4. N+1 查询详细示例

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

**检测规则**：任何 `findMany()` / `list()` 后的循环中出现数据库查询 = N+1 红旗。

---

## 5. EXPLAIN 结果解读

```sql
EXPLAIN ANALYZE
SELECT * FROM tasks
WHERE assignee_id = 'abc' AND status = 'pending'
ORDER BY created_at DESC;
```

**关键指标：**

| 指标 | 含义 | 红旗阈值 |
|------|------|---------|
| Seq Scan | 全表扫描 | 大表（>10k 行）+ 高选择性查询 = 需要索引 |
| Index Scan | 使用索引 | 通常期望 |
| Index Cond | 索引过滤条件 | 检查是否覆盖 WHERE 子句 |
| Sort | 内存排序 | 大结果集排序 = 考虑索引覆盖 ORDER BY |
| actual time | 实际耗时 | > 50ms 需要优化 |
| rows | 实际返回行数 | 与估计差异大 = 统计信息需要 ANALYZE |

**注意**：小表 Seq Scan 是合理的。优化器会自动选择成本最低的方案。只有"大表 + 高选择性查询 + Seq Scan"才需要加索引。

---

## 6. 索引设计详解

### Query Pattern–Driven Indexing

索引服务 WHERE、JOIN、ORDER BY，不按字段盲目建。

### Leftmost Prefix Rule

组合索引 `(a, b, c)` 可以服务：
- `WHERE a = X`
- `WHERE a = X AND b = Y`
- `WHERE a = X AND b = Y AND c = Z`

不能服务：
- `WHERE b = Y`（跳过了最左列）
- `WHERE c = Z`（跳过了最左列）

**执行规则**：组合索引列顺序 = 等值过滤列 → 范围过滤列 → 排序列。

### SARGability

索引列被函数包裹、隐式类型转换或前置通配符会导致索引失效：

```sql
-- 不可索引（Non-SARGable）
WHERE LOWER(email) = 'x@example.com'
WHERE created_at::DATE = '2024-01-01'
WHERE name LIKE '%smith'

-- 可索引（SARGable）
WHERE email = 'X@EXAMPLE.COM'        -- 应用层处理大小写
WHERE created_at >= '2024-01-01' AND created_at < '2024-01-02'
WHERE name LIKE 'smith%'              -- 后置通配符可用索引
```

### Write Amplification

每个索引增加 INSERT/UPDATE/DELETE 的写入成本。写入频繁的表需要评估索引数量与查询收益的平衡。

---

## 7. 完整说辞表

| 说辞 | 现实 | 后果 |
|------|------|------|
| "约束在应用代码做就行" | 应用层约束绕过了数据库保护。直接 SQL 更新、数据修复、ETL 都无保护。数据库约束是最后的安全网。 | 数据损坏风险 ×10；绕过应用层直接 SQL = 无校验 = 垃圾数据入库 |
| "先加列，索引以后再建" | 先加索引，查询快就是现在。用户等待的不是索引。 | 无索引查询在大表上慢 ×100-1000；生产慢查询影响所有用户 |
| "这个表很小，不需要索引" | 小表现在。小表变大的速度惊人。建索引成本低。 | 表从 1000 行到 100 万行 = 查询从 <10ms 到 >500ms；补索引需停服或锁表 |
| "EXPLAIN 等到出问题再看" | 写查询时 EXPLAIN 花 5 秒。上线后排查慢查询花 5 小时。 | 生产慢查询排查 5 小时 vs 开发时 EXPLAIN 5 秒；影响比 = 3600:1 |
| "迁移不用 DOWN——不会回滚" | 你会的。而且出问题时凌晨 3 点写回滚脚本更痛苦。 | 无 DOWN 脚本 = 凌晨紧急手写回滚 = 30-60 分钟高风险操作；有 DOWN = 5 秒回滚 |
| "生产直接改一下数据就行" | 手改无记录 = 下次迁移可能覆盖 = 无法审计 = 无法复现。 | 手改与迁移冲突 → 数据不一致 → 排查 > 4 小时 |
| "大表回填一次性跑完" | 大表全表 UPDATE 会锁行、膨胀、长事务。 | 长事务 > 30 分钟 → 连接池耗尽 → 服务不可用 |
| "事务里调个 API 没关系" | 外部调用慢或失败 = 事务长时间持有锁 = 连接泄漏。 | 事务 10s+ → 连接池饱和 → 全服务阻塞 |

---

## 8. 事务隔离级别参考

| 隔离级别 | 脏读 | 不可重复读 | 幻读 | 序列化异常 | 适用场景 |
|---------|------|-----------|------|-----------|---------|
| Read Uncommitted | 可能 | 可能 | 可能 | 可能 | 几乎不用 |
| Read Committed | 不会 | 可能 | 可能 | 可能 | PostgreSQL 默认；大多数场景够用 |
| Repeatable Read | 不会 | 不会 | 可能 | 可能 | 需要快照一致性读 |
| Serializable | 不会 | 不会 | 不会 | 不会 | 金融、库存等强一致性要求 |

**经验法则**：默认用 Read Committed。只有业务规则明确要求快照一致性或防止并发异常时才提升隔离级别。

---

## 9. 数据修复脚本模板

```markdown
## Data Repair: <描述>

**日期**: YYYY-MM-DD
**原因**: <为什么需要修复>
**影响范围**: <哪些表、多少行>
**风险级别**: Low / Medium / High / Critical

### Dry Run
- <修复脚本附 dry-run 模式，输出影响行数但不执行>

### 备份
- <修复前备份策略>

### 执行脚本
- <分批执行，每批 N 行>
- <记录每批影响行数>

### 验证
- <修复后数据验证查询>

### 回滚 / 补偿
- <如果修复出错，如何恢复>

### 审计
- 执行人: <who>
- 执行时间: <when>
- 影响行数: <count>
```
