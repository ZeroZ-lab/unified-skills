---
name: maintain-workflow-context-save
description: 保存工作上下文。当需要保存当前工作状态供后续 session 恢复，或提到"保存""save""checkpoint""挂起"
argument-hint: "[checkpoint-title]"
---

# Context Save — 保存工作上下文


## 入口/出口
- **入口**: 当前会话中的工作状态
- **出口**: `.claude/checkpoints/` 下的 checkpoint 文件
- **指向**: 恢复时 → `maintain-workflow-context-restore`；继续工作流 → `build-workflow-execute`、`verify-workflow-review`、`ship-workflow-ship` 等
- **前置加载**: CANON.md、`maintain-workflow-context-restore`（下游消费方）
- **输出路径**: `.claude/checkpoints/YYYYMMDD-HHMMSS-{title-slug}.md` → 恢复时由 `maintain-workflow-context-restore` 消费

## 与自动 feature state 的边界

`docs/features/<feature>/state.json` 由 hooks 自动维护，用于阶段级恢复：当前 feature、当前阶段、最后阶段文档、下一步命令。

`/save` 不负责基础阶段连续性。它负责保存 `state.json` 无法表达的内容：为什么选 A 不选 B、重要取舍、注意事项、阻塞原因、非显而易见的剩余工作。

## 何时不使用
- 当前任务尚未形成可恢复的状态或明确 checkpoint 价值
- 用户只是要求提交、发布或验证，不需要保存上下文
- 用户只需要知道当前 feature 阶段和下一步命令；此时先看 SessionStart 的 feature state 提示
- 需要修改代码来“整理状态”时，先回到对应 build/verify 技能

## 硬门

```
只读操作。不修改代码，只读 git 状态和写 checkpoint 文件。
```

违反此 gate = 本技能被滥用为修改代码的借口。

## 流程

### Step 1: 采集 git 状态

收集当前仓库快照：

```bash
git branch --show-current
git status --short
git diff --stat
git log --oneline -5
```

不需要更多。不需要 diff 全文——统计足够理解变更范围。

### Step 2: 总结上下文

从当前会话中提取恢复所需的九类信息：

1. **正在做什么** — 当前进度、停在哪个步骤
2. **当前目标** — 本 checkpoint 要恢复的目标、停点和 feature doc
3. **git 快照** — branch、status summary、diff stat、最近 commits
4. **进度状态** — 各工作区域 done / pending / blocked 的证据
5. **已做决策** — 为什么选 A 不选 B、权衡点
6. **验证状态** — 已跑命令、结果、未跑项和失败项
7. **剩余工作** — 还有哪些步骤未完成
8. **阻塞项和下一命令** — 被谁阻塞、下一步应该运行哪个阶段命令
9. **交接风险** — 下个 session 最容易误判什么

总结要精炼。checkpoint 不是工作日志——是恢复上下文的最小信息集。

### Step 3: 写入 checkpoint 文件

路径：`.claude/checkpoints/YYYYMMDD-HHMMSS-{title-slug}.md`

若 `.claude/checkpoints/` 目录不存在，先创建：`mkdir -p .claude/checkpoints`

示例文件名：`20260424-143052-refactor-auth-module.md`

文件格式：

模板起点：`templates/maintain/checkpoint.md`

```markdown
---
status: active|paused|blocked
branch: feature/auth-refactor
timestamp: 2026-04-24T14:30:52+08:00
current_objective: migrate auth from session to JWT
next_command: /build
files_modified:
  - src/auth/login.ts
  - src/auth/session.ts
last_commits:
  - a1b2c3d feat: add token signing
---

## Summary

将登录模块从 session-based 重构为 JWT-based。已完成 token 签发，
停在 refresh token 轮换逻辑。

## Current Objective

- Goal: 完成 JWT auth migration
- Stop point: refresh token rotation 未完成
- Feature doc: `docs/features/20260424-auth/03-plan.md`

## Git Snapshot

- Branch: feature/auth-refactor
- Status summary: 2 modified files
- Diff stat: +120/-35 across auth files
- Last commits: `a1b2c3d feat: add token signing`

## Progress State

| Area | Status | Evidence |
|------|--------|----------|
| Token signing | done | unit tests passing |
| Refresh token rotation | in_progress | plan task 2 |
| Session cleanup | pending | plan task 3 |

## Decisions Made

- 选 RS256 不选 HS256 — 多服务场景下公钥分发更安全
- access token 有效期 15min，refresh token 7 天

## Validation State

| Check | Command / Evidence | Result | Notes |
|-------|--------------------|--------|-------|
| Unit tests | `npm test -- auth` | pass | token signing covered |
| Integration tests | `npm test -- auth.integration` | not_run | blocked until rotation exists |

## Remaining Work

- [ ] Refresh token 轮换逻辑
- [ ] 旧 session 清理迁移
- [ ] 集成测试补全

## Blockers

| Blocker | Owner | Needed Decision / Action |
|---------|-------|--------------------------|
| none | | |

## Next Command

- Recommended command: `/build`
- Why: 继续实现 plan 中的 refresh token rotation
- Preconditions: 当前分支保持 feature/auth-refactor

## Handoff Risks

- 不要删除 `src/auth/legacy.ts`；下个迭代才废弃
- production migration 尚未执行

## Notes

- `src/auth/legacy.ts` 不要删，下个迭代才废弃
- DB migration 已在 staging 跑过，production 还没
```

YAML frontmatter 字段说明：

| 字段 | 类型 | 说明 |
|------|------|------|
| `status` | 枚举 | `active`（进行中）、`paused`（暂停）、`blocked`（阻塞） |
| `branch` | 字符串 | 当前 git 分支 |
| `timestamp` | ISO-8601 | 保存时刻 |
| `current_objective` | 字符串 | 当前 checkpoint 要恢复的目标 |
| `next_command` | 字符串 | 推荐恢复后的下一阶段命令 |
| `files_modified` | 列表 | 已修改但未提交的文件 |
| `last_commits` | 列表 | 最近相关提交，至少 1 条或写 `none` |

Markdown body 十一个章节不可省略。内容为空（如 `## Notes` 下写 `无`），但章节标题必须存在——恢复时按标题定位信息。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "我还没做完不用保存" | 的保存时机是进行中，不是结束时。完成后再保存 = 只有结果没有决策过程。 | 只存结果不存过程 → 下次 session 不知道为什么选了 A → 重复讨论已做决策，浪费 15-30 分钟。 |
| "下次我会记得" | 上下文窗口有限。书面记录跨 session。记忆不可靠，文件可靠。 | 依赖记忆 → session 切换后丢失 70%+ 上下文细节 → 从零重建上下文 > 30 分钟 vs 从 checkpoint 恢复 < 5 分钟。 |
| "保存太花时间" | 采集 git 状态 + 写总结 < 2 分钟。重新理解上下文 > 30 分钟。 | 省下的 2 分钟在下次 session 翻倍回还：30 分钟重新理解 + 可能重复已做决策。 |
| "内容太少不值得保存" | 一行决策也比从零开始强。没有"太小不值得保存"的上下文。 | 小决策不保存 → 下次 session 重复讨论同一决策 → 每次重复讨论 5-10 分钟，累积浪费 > 30 分钟。 |

## 红旗 — STOP

- checkpoint 文件超过 100 行 — 太详细 = 不该在这里。checkpoint 是恢复索引，不是工作日记。
- 修改代码 — 违反 Hard Gate。本技能只读不写（checkpoint 文件除外）。
- 省略 YAML frontmatter — frontmatter 是机器可读的元数据，恢复依赖它。
- 省略核心 Markdown 章节 — 恢复时按标题定位信息，缺失章节 = 恢复不完整。
- 不采集 git 状态直接写总结 — 缺少 git 状态的 checkpoint 无法验证 branch 一致性。
- 不记录验证状态或下一命令 — 下个 session 不知道能否继续、该从哪个阶段继续。

## 验证清单

- [ ] git 状态完整（branch、status、diff --stat、log --oneline -5）
- [ ] 十一个 Markdown 章节全部存在（Summary、Current Objective、Git Snapshot、Progress State、Decisions Made、Validation State、Remaining Work、Blockers、Next Command、Handoff Risks、Notes）
- [ ] 决策已记录（为什么选 A 不选 B）
- [ ] Validation State 已记录已跑/未跑/失败检查
- [ ] 剩余工作已列出（可操作的待办，不是模糊描述）
- [ ] Next Command 已写清推荐命令、原因和前置条件
- [ ] Handoff Risks 已写清下个 session 最容易误判的点
- [ ] YAML frontmatter 完整（status、branch、timestamp、current_objective、next_command、files_modified、last_commits）
- [ ] 文件名格式正确（YYYYMMDD-HHMMSS-{title-slug}.md）
- [ ] 文件总行数 ≤ 100

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| checkpoint 超 100 行 | 精炼内容：删除重复描述、合并相似条目、只保留恢复所需的最小信息集。不拆分为多个 checkpoint。 |
| 核心章节有遗漏 | 强制补齐。空章节写"无"，但不省略章节标题——恢复时按标题定位信息。 |
| git 状态采集失败（非 git 仓库） | 在 frontmatter 中记录 `branch: none`，Markdown body 中注明"非 git 仓库环境，无法采集 git 状态"。 |
| frontmatter 字段不完整 | 补齐 `status`、`branch`、`timestamp`、`current_objective`、`next_command`、`files_modified`、`last_commits`。不省略任何一项。 |
| 决策未记录 | 强制列出至少 1 个决策 + 理由。"没有决策"不成立——做了选择就有决策。 |
| Validation State 缺失 | 补已跑、未跑和失败检查；没有验证就写 `not_run` 和原因。 |
| Next Command 缺失 | 根据 Remaining Work 选择 `/build`、`/review`、`/ship` 或其它明确下一步。 |

## 好坏示例

### Good — 精炼 checkpoint

```markdown
---
status: paused
branch: feature/auth-refactor
timestamp: 2026-04-24T14:30:52+08:00
current_objective: migrate auth from session to JWT
next_command: /build
files_modified:
  - src/auth/login.ts
  - src/auth/session.ts
last_commits:
  - a1b2c3d feat: add token signing
---

## Summary
将登录模块从 session-based 重构为 JWT-based。已完成 token 签发，停在 refresh token 轮换逻辑。

## Current Objective
- Goal: 完成 JWT auth migration
- Stop point: refresh token rotation 未完成
- Feature doc: `docs/features/20260424-auth/03-plan.md`

## Git Snapshot
- Branch: feature/auth-refactor
- Status summary: 2 modified files
- Diff stat: +120/-35 across auth files
- Last commits: `a1b2c3d feat: add token signing`

## Progress State
| Area | Status | Evidence |
|------|--------|----------|
| Token signing | done | unit tests passing |
| Refresh token rotation | in_progress | plan task 2 |

## Decisions Made
- 选 RS256 不选 HS256 — 多服务场景下公钥分发更安全
- access token 15min，refresh token 7 天

## Validation State
| Check | Command / Evidence | Result | Notes |
|-------|--------------------|--------|-------|
| Unit tests | `npm test -- auth` | pass | token signing covered |

## Remaining Work
- [ ] Refresh token 轮换逻辑
- [ ] 旧 session 清理迁移
- [ ] 集成测试补全

## Blockers
| Blocker | Owner | Needed Decision / Action |
|---------|-------|--------------------------|
| none | | |

## Next Command
- Recommended command: `/build`
- Why: 继续 plan task 2
- Preconditions: 当前分支保持 feature/auth-refactor

## Handoff Risks
- src/auth/legacy.ts 不要删，下个迭代才废弃

## Notes
- src/auth/legacy.ts 不要删，下个迭代才废弃
```

→ frontmatter 完整、四章节齐全、决策有理由、行数 < 50

### Bad — 过详细工作日记

```markdown
## Summary
今天早上 9 点开始，先读了 spec，然后讨论了方案 A 和 B，
花了一个小时比较，然后写了第一个文件的 100 行代码...

→ 问题: 超 100 行 → 不该是日记
→ 问题: 无 YAML frontmatter → 恢复时无法机器定位 branch 和 status
→ 问题: 决策理由缺失 → 下次 session 不知道为什么选 A
→ 问题: 工作时间线无恢复价值 → 只需要当前状态和剩余工作
```

## 输出模板

```markdown
---
status: active|paused|blocked
branch: [当前 git 分支]
timestamp: [ISO-8601 保存时刻]
current_objective: [当前目标]
next_command: [/build|/review|/ship|other]
files_modified:
  - [已修改未提交文件1]
  - [已修改未提交文件2]
last_commits:
  - [short-sha message]
---

## Summary
[一句话描述当前进度和停点]

## Current Objective
- Goal:
- Stop point:
- Feature doc:

## Git Snapshot
- Branch:
- Status summary:
- Diff stat:
- Last commits:

## Progress State
| Area | Status | Evidence |
|------|--------|----------|
| | pending / in_progress / done / blocked | |

## Decisions Made
- [决策1] — [理由]
- [决策2] — [理由]

## Validation State
| Check | Command / Evidence | Result | Notes |
|-------|--------------------|--------|-------|
| | | not_run / pass / fail / blocked | |

## Remaining Work
- [ ] [未完成任务1]
- [ ] [未完成任务2]

## Blockers
| Blocker | Owner | Needed Decision / Action |
|---------|-------|--------------------------|
| none | | |

## Next Command
- Recommended command:
- Why:
- Preconditions:

## Handoff Risks
- [下个 session 最容易误判的点]

## Notes
- [注意事项/已知的坑]
```
