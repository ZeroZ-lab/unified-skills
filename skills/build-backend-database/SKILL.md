---
name: build-backend-database
description: 数据库工程——schema 设计、迁移安全、查询优化、数据完整性。用于新增/修改表结构、编写迁移、设计索引、优化慢查询、处理数据约束或数据修复计划
---

# Database — 数据库工程

## 入口/出口
- **入口**: 需要新增/修改数据库表、写迁移、设计索引、优化慢查询、处理数据约束或制定数据修复计划
- **出口**: 可回滚的迁移脚本 + 验证过的查询 + 数据完整性约束 + 迁移风险评估
- **指向**: 完成后回到 `build-workflow-execute` 继续下一个切片
- **前置加载**: CANON.md
- **输出路径**: 完成后回到 `build-workflow-execute` 继续下一个切片
- **辅助参考**: `references/database-examples.md`（详细示例、说辞完整表、零停机案例、事务隔离级别、数据修复模板）

## 何时不使用
- 只改 API 层字段命名或请求校验，不涉及持久化结构
- 纯前端状态、缓存或展示逻辑问题
- 数据库行为已经明确，只是在实现业务代码
- ORM 使用问题（连接池配置、事务报错排查）不涉及 schema/查询设计

## 核心锚点

### Data Integrity Constraints

数据库约束是数据的类型系统。应用验证是补充，数据库约束是最后防线。

**执行规则：**
- 主键、外键、NOT NULL、UNIQUE、CHECK、DEFAULT 优先在 DDL 中声明
- 禁止依赖应用层作为唯一的数据完整性保障
- 直接 SQL 更新、数据修复、ETL 绕过应用层时，数据库约束是最后的安全网

### Migration as Code

所有 schema 变化必须进入迁移文件，不允许生产手改无记录。

**执行规则：**
- 每份迁移必须有 rollback plan；能写 DOWN 必须写 DOWN；不可逆迁移必须先 deprecated、备份，并提供补偿方案
- 迁移必须在 staging 验证
- 具体 DDL、锁行为、安全索引操作以当前数据库引擎为准；不确定时先查数据库文档

### Expand-Contract Migration

生产迁移默认使用 expand → migrate/backfill → contract。不一次性完成破坏性 schema 变更。

**执行规则：**
- 新增 NOT NULL 列：先加可空列 → 部署兼容代码 → 回填 → 加约束
- 删除列：先停止读取 → 部署不读旧列的代码 → 跨一个 release 后删除
- 重命名：先加新列 → 双写 → 迁移读取 → 停写旧列 → 删除旧列

### Online Schema Change

大表 ALTER、回填、建索引必须评估锁表风险、耗时和分批策略。

**执行规则：**
- 大表回填必须分批执行、可暂停/可恢复、有进度记录、避免长事务
- 大表建索引评估并发建索引能力（如 PostgreSQL `CONCURRENTLY`）
- 全表 rewrite 操作必须评估停机窗口

### EXPLAIN-first Query Design

写完复杂查询立即 EXPLAIN / EXPLAIN ANALYZE 验证执行计划。

**执行规则：**
- 大表（>10k 行）+ 高选择性查询 + Seq Scan → 需要索引
- 小表或低选择性查询的 Seq Scan 是优化器的合理选择，不是红旗
- 估计行数与实际差异大 → 跑 `ANALYZE` 更新统计信息

### Query Pattern–Driven Indexing

按 WHERE、JOIN、ORDER BY 模式建索引，不按字段盲目建。

**执行规则：**
- 组合索引列顺序：等值过滤列 → 范围过滤列 → 排序列（Leftmost Prefix Rule）
- 避免对索引列做函数包裹、隐式类型转换或前置通配符（SARGability）
- 评估写入成本：写入频繁表的索引数量需要权衡查询收益与写入放大

### N+1 Query Smell

`findMany()` / `list()` 后循环内再查库 = N+1。

**执行规则：**
- 检测到 N+1 → 改 JOIN / include / batch 查询
- 任何循环体内的数据库调用都需要证明不是 N+1

### Transaction Boundary

多表一致性写入必须定义事务边界。

**执行规则：**
- 事务内禁止调用外部 API（外部调用慢/失败 → 事务长持锁 → 连接泄漏）
- 长任务不要占用数据库事务；先写"待处理"状态，异步执行，完成后更新
- 并发状态更新（库存、余额、任务领取）必须评估 optimistic locking / row lock
- 默认 Read Committed；业务规则要求快照一致性或防止并发异常时才提升隔离级别

### Data Repair Playbook

生产数据修复不是 seed，也不是普通 migration。三者不混用：Migration 改 schema（有序、需 rollback plan）；Seed 填开发数据（幂等、可重复）；Data Repair 修生产数据。

**执行规则：**
- 必须有 dry-run 模式 + 备份恢复方案 + 分批执行 + 审计日志 + 修复后验证查询

## Schema 设计约定

项目约定（团队统一即可，非绝对标准）：表名复数 snake_case、列名 snake_case、主键 UUID 或 BIGSERIAL、时间 `TIMESTAMPTZ`（不裸用 `TIMESTAMP`）、布尔前缀 `is_`/`has_`、软删除优先 `deleted_at`。短例详见 `references/database-examples.md` §1-2。

## 迁移风险分级

| 级别 | 场景 | 要求 |
|------|------|------|
| Low | 可空列、普通索引、小表约束 | UP + DOWN，staging 验证 |
| Medium | 回填、新增 NOT NULL、改默认值 | + 分步迁移 + backfill 策略 |
| High | DROP/重命名列、改字段类型、大表索引/回填 | + expand-contract + 备份 + 回滚验证 |
| Critical | CASCADE 删除、无 WHERE DML、不可逆变更 | + 人工审批 + 备份恢复演练 |

## 流程

### Step 1：设计 Schema + 约束

Checkpoint：每个约束都有业务语义，Schema 约定一致。

### Step 2：写迁移 + 风险分级

Checkpoint：迁移有 rollback plan，风险已分级。

### Step 3：执行迁移（Medium+ 使用 expand-contract；大表分批 backfill）

Checkpoint：staging 验证 + rollback plan 已测试。

### Step 4：建索引 + 查询验证

按查询模式建索引 → EXPLAIN ANALYZE → 确认无 N+1。
Checkpoint：每个索引有查询说明，关键查询延迟达标。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "约束在应用代码做就行" | 直接 SQL 更新、数据修复、ETL 都绕过应用层。数据库约束是最后防线。 | 数据损坏风险 ×10；垃圾数据无校验入库 |
| "先加列，索引以后再建" | 查询慢就是现在。建索引成本低。 | 大表无索引查询慢 ×100-1000；补索引需锁表或停服 |
| "迁移不用 DOWN——不会回滚" | 出问题时凌晨 3 点写回滚脚本更痛苦。 | 有 DOWN = 5 秒回滚；无 DOWN = 30-60 分钟高风险手写 |
| "大表回填一次性跑完" | 大表全表 UPDATE 会锁行、膨胀、长事务。 | 长事务 → 连接池耗尽 → 服务不可用 |

完整 8 条说辞表详见 `references/database-examples.md` §7。

## 红旗 — STOP

- `.findMany()` / `list()` 后循环内还有数据库查询（N+1）
- 迁移文件没有 rollback plan
- 大表 ALTER 未评估锁表风险
- 大表 backfill 未分批
- 破坏性迁移没有备份/恢复路径
- DROP COLUMN 没有 deprecated 阶段
- 字段类型转换没有数据兼容性检查
- 多表一致性写入没有事务
- 事务中调用外部 API
- 高并发状态更新没有并发控制
- 生产数据库手动改数据——没记录、没迁移、没人知道
- 迁移用 `CASCADE` 删表
- `SELECT *` 在生产代码中
- 没有 WHERE 的 UPDATE / DELETE
- 为低选择性字段盲目建索引且未说明服务查询
- 生产数据修复没有 dry-run

## 验证失败处理

| 验证项 | 失败表现 | 处理方式 |
|--------|----------|---------|
| 迁移无 rollback plan | 只有 UP，没有回滚 | 补写 DOWN 或备份+补偿方案；不可逆操作需 deprecated + 分步 |
| 关键列无约束 | NOT NULL / CHECK 缺失 | 在 DDL 层添加约束 |
| 大表 Seq Scan + 高选择性 | EXPLAIN 显示全表扫描 | 为查询模式添加组合索引 |
| N+1 查询 | findMany 循环中嵌套查询 | 改为 include/JOIN 批量查询 |
| 时间列用 TIMESTAMP | 不带时区存储 | 改为 TIMESTAMPTZ；数据迁移统一为 UTC |
| 大表 backfill 未分批 | 单条 UPDATE 全表 | 改为分批执行 + 可恢复策略 |
| 事务内调外部 API | 外部调用在事务块内 | 将外部调用移到事务外；先持久化意图，异步执行 |
| 迁移风险未分级 | 所有迁移同等待遇 | 按 Low/Medium/High/Critical 分级并执行对应要求 |

## 好坏示例

### Good — 约束前置 + 分步迁移 + 查询驱动索引

```sql
-- 约束和默认值一起定义
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL CHECK (char_length(title) > 0),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- 索引覆盖查询模式: WHERE status = X AND assignee_id = Y
CREATE INDEX idx_tasks_status_assignee ON tasks(status, assignee_id);
-- 零停机: 可空列 → 回填 → 加约束（三步迁移）
```

### Bad — 无约束 + 不可回滚 + N+1

```sql
CREATE TABLE taskAssign (id TEXT, taskId TEXT, usr TEXT);
-- 无约束、缩写列名、无主键、无外键
ALTER TABLE tasks ADD COLUMN description TEXT NOT NULL;
-- 一次性 NOT NULL → 锁表 → 现有行无值 → 迁移失败
-- 无 DOWN 脚本 → 不可回滚
SELECT * FROM tasks;
-- SELECT * + 无 WHERE + 无索引
```

## 输出模板

```
数据库工程完成：

迁移文件: <timestamp>_<name>.up.sql + .down.sql（或备份+补偿方案）
风险级别: Low / Medium / High / Critical
大表: 是/否 | 破坏性变更: 是/否 | staging 已验证: 是/否 | rollback 已测试: 是/否

Schema 变更: [新表 +约束数 | 新列 +约束 | 外键引用]
索引: [索引名 + 服务的查询模式 + 写入成本评估]
查询: N+1 [已修复/无] | EXPLAIN [Index/Seq Scan] | 延迟 [< 50ms]
完整性: 约束 [PK/FK/NOT NULL/CHECK/UNIQUE/DEFAULT] | 时间 TIMESTAMPTZ | 软删除 [deleted_at/is_deleted]
Backfill: [需要/不需要 | 分批策略 | 可恢复]（如有）
事务: [边界 | 并发控制: optimistic/row lock/none]（如有）
```

## 验证清单

- [ ] 每个表有主键 + 外键引用
- [ ] 关键列有 NOT NULL / CHECK / UNIQUE / DEFAULT
- [ ] 时间列使用 TIMESTAMPTZ；软删除策略一致
- [ ] 迁移有 rollback plan；风险已分级
- [ ] Medium+ 使用 expand-contract；大表 backfill 分批；破坏性变更已备份
- [ ] staging 验证 + rollback plan 测试
- [ ] EXPLAIN 合理（大表无不应有的 Seq Scan）；无 N+1
- [ ] 每个索引有查询模式说明
- [ ] 多表写入有事务；事务内无外部 API；并发有锁策略
