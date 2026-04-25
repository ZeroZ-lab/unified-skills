---
name: maintain-workflow-learn
description: 跨会话学习记忆。使用 cuando 发现项目模式、踩坑、偏好需要持久化
---

# Learn — 跨会话学习记忆


## 入口/出口
- **入口**: 手动添加或技能自动采集的学习条目
- **出口**: `.claude/learnings.jsonl`
- **指向**: 其他技能在关键节点调用本技能记录学习
- **假设已加载**: CANON.md

## 存储

文件：`.claude/learnings.jsonl`（项目级，必须加入 `.gitignore`）

每行一个 JSON 对象，追加写入：

```json
{"type":"pitfall","key":"orm-n+1-query","insight":"User.list() 默认加载关联，列表接口必须用 .select() 限制字段","confidence":8,"files":["src/services/user.service.ts"],"source":"manual","ts":"2026-04-24T14:30:52+08:00"}
```

## 格式

| 字段 | 类型 | 说明 |
|------|------|------|
| `type` | 枚举 | `pattern` / `pitfall` / `preference` / `architecture` |
| `key` | 字符串 | 唯一标识，kebab-case。同 key 后写入覆盖前写入（last-write-wins） |
| `insight` | 字符串 | 一句话洞察。具体、可操作，不是泛泛描述 |
| `confidence` | 整数 | 1-10。10 = 确凿证据，1 = 初步观察 |
| `files` | 列表 | 相关文件路径（可为空列表） |
| `source` | 枚举 | `auto`（技能自动采集）/ `manual`（人工添加） |
| `ts` | ISO-8601 | 记录时间 |

### type 四种类型

| type | 用途 | 示例 |
|------|------|------|
| `pattern` | 已验证的模式 | "错误处理统一用 Result 类型，不用 try/catch" |
| `pitfall` | 已踩的坑 | "CI 中不能访问内网服务，测试需要 mock" |
| `preference` | 团队偏好 | "commit message 用 conventional commits 格式" |
| `architecture` | 架构约束 | "事件总线只允许 async 通信，禁止同步调用" |

## 去重

同 key 后写入覆盖前写入（last-write-wins）。

```bash
# 去重方法：按 key 保留最后一条
tac .claude/learnings.jsonl | awk -F'"key":"' '!seen[$2]++' | tac > .claude/learnings.jsonl.tmp && mv .claude/learnings.jsonl.tmp .claude/learnings.jsonl
```

## 子命令

### /learn（默认）

显示最近 20 条学习，按 type 分组：

```
Patterns (8):
  [conf:9] api-error-handling → 统一用 Result 类型
  [conf:7] pagination-cursor → 列表接口用游标分页

Pitfalls (5):
  [conf:8] orm-n+1-query → User.list() 默认加载关联
  [conf:6] ci-internal-access → CI 中不能访问内网服务

Preferences (4):
  [conf:9] commit-convention → conventional commits 格式

Architecture (3):
  [conf:10] event-bus-async-only → 事件总线只允许 async 通信
```

`conf` 为 confidence 缩写。每个条目一行。

### /learn search \<query\>

全文搜索 `learnings.jsonl`：

```
/learn search auth
```

在 key 和 insight 字段中搜索匹配项，高亮匹配行。

### /learn prune

交互式清理：

1. **过时检测** — 引用的 `files` 已不存在的条目标记为过时
2. **矛盾检测** — 同 key 不同 insight 的条目标记为矛盾
3. **交互确认** — 逐条展示，用户选择保留/删除/更新
4. **去重** — 执行 last-write-wins 去重

### /learn export

导出为 markdown（按 type 分组）：

```markdown
# Learnings

## Patterns
- **api-error-handling** (conf:9) — 统一用 Result 类型
  Files: src/utils/result.ts
- **pagination-cursor** (conf:7) — 列表接口用游标分页
  Files: src/middleware/pagination.ts

## Pitfalls
- **orm-n+1-query** (conf:8) — User.list() 默认加载关联
  Files: src/services/user.service.ts

## Preferences
- **commit-convention** (conf:9) — conventional commits 格式

## Architecture
- **event-bus-async-only** (conf:10) — 事件总线只允许 async 通信
```

### /learn add

手动添加。必须指定 type、key、insight、confidence：

```
/learn add type:pitfall key:env-var-case insight:"环境变量用 UPPER_SNAKE_CASE，不用 camelCase" confidence:7 files:"config/env.ts"
```

缺少必填字段拒绝写入并提示。`files` 和 `ts` 可选（ts 默认当前时间）。

## 自动学习

其他技能在关键节点调用本技能记录学习。触发场景：

| 场景 | 记录 type | 来源技能 |
|------|-----------|---------|
| 调试发现根因 | `pitfall` | `verify-workflow-debug` |
| 采纳新的实现模式 | `pattern` | `build-workflow-execute` |
| 确认团队偏好 | `preference` | `verify-workflow-review` |
| 做出架构决策 | `architecture` | `build-cognitive-decision-record` |

自动记录的 source 为 `auto`，confidence 默认为 5（待验证）。人工 review 后可提高 confidence。

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "学习记了也没用" | 每次重复踩坑的代价远超记录成本。一条 pitfall 避免一次返工就回本。 |
| "让 AI 自己记" | 自动采集是补充不是替代。人工判断价值更高——auto 记录需要人工筛选和提权。 |
| "JSONL 格式太原始" | 原始 = 可 grep、可追加、无依赖。不需要数据库。 |
| "confidence 主观不靠谱" | 主观但有价值。confidence 7 和 3 的差异传达了确定程度。全标 10 才是问题。 |
| "prune 太麻烦" | 不 prune 更麻烦——过时和矛盾的学习比没有学习更危险。 |

## 红旗 — STOP

- `learnings.jsonl` 超过 1000 条 — 需要 prune。1000+ 条意味着过时条目未清理，信噪比下降。
- confidence 都是 10 — 缺乏自我怀疑。所有洞察都是"确凿证据"？不可能。检查是否需要降权。
- 大量 `auto` source 少 `manual` — 缺乏人工筛选。auto 记录的 confidence 默认 5，需要人工 review。
- insight 超过两句话 — 太长了。insight 是一句话洞察，不是段落。长文本放文档，key 指向文档。
- 缺少 files 字段 — 是空列表，但字段必须存在。引用文件的学习比泛泛描述有价值 10 倍。
- key 不用 kebab-case — 命名不一致导致去重失败，同一洞察出现多个变体。

## 验证清单

- [ ] JSONL 格式正确（每行一个有效 JSON 对象）
- [ ] type 为四种之一（pattern / pitfall / preference / architecture）
- [ ] confidence 在 1-10 范围内
- [ ] key 为 kebab-case 且唯一（或有明确更新理由）
- [ ] insight 为一句话（不超过两句话）
- [ ] files 字段存在（可为空列表）
- [ ] source 为 auto 或 manual
- [ ] ts 为有效 ISO-8601 格式
