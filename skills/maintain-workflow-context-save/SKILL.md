---
name: maintain-workflow-context-save
description: 保存工作上下文。使用 cuando 需要保存当前工作状态供后续 session 恢复
---

# Context Save — 保存工作上下文


## 入口/出口
- **入口**: 当前会话中的工作状态
- **出口**: `.claude/checkpoints/` 下的 checkpoint 文件
- **指向**: 恢复时 → `maintain-workflow-context-restore`
- **假设已加载**: CANON.md

## Hard Gate

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

从当前会话中提取四类信息：

1. **正在做什么** — 当前进度、停在哪个步骤
2. **已做决策** — 为什么选 A 不选 B、权衡点
3. **剩余工作** — 还有哪些步骤未完成
4. **注意事项** — 已知的坑、需要注意的约束

总结要精炼。checkpoint 不是工作日志——是恢复上下文的最小信息集。

### Step 3: 写入 checkpoint 文件

路径：`.claude/checkpoints/YYYYMMDD-HHMMSS-{title-slug}.md`

示例文件名：`20260424-143052-refactor-auth-module.md`

文件格式：

```markdown
---
status: active|paused|blocked
branch: feature/auth-refactor
timestamp: 2026-04-24T14:30:52+08:00
files_modified:
  - src/auth/login.ts
  - src/auth/session.ts
---

## Summary

将登录模块从 session-based 重构为 JWT-based。已完成 token 签发，
停在 refresh token 轮换逻辑。

## Decisions Made

- 选 RS256 不选 HS256 — 多服务场景下公钥分发更安全
- access token 有效期 15min，refresh token 7 天

## Remaining Work

- [ ] Refresh token 轮换逻辑
- [ ] 旧 session 清理迁移
- [ ] 集成测试补全

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
| `files_modified` | 列表 | 已修改但未提交的文件 |

Markdown body 四个章节不可省略。内容为空（如 `## Notes` 下写 `无`），但章节标题必须存在——恢复时按标题定位信息。

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "我还没做完不用保存" | 的保存时机是进行中，不是结束时。完成后再保存 = 只有结果没有决策过程。 |
| "下次我会记得" | 上下文窗口有限。书面记录跨 session。记忆不可靠，文件可靠。 |
| "保存太花时间" | 采集 git 状态 + 写总结 < 2 分钟。重新理解上下文 > 30 分钟。 |
| "内容太少不值得保存" | 一行决策也比从零开始强。没有"太小不值得保存"的上下文。 |

## 红旗 — STOP

- checkpoint 文件超过 100 行 — 太详细 = 不该在这里。checkpoint 是恢复索引，不是工作日记。
- 修改代码 — 违反 Hard Gate。本技能只读不写（checkpoint 文件除外）。
- 省略 YAML frontmatter — frontmatter 是机器可读的元数据，恢复依赖它。
- 省略四个 Markdown 章节 — 恢复时按标题定位信息，缺失章节 = 恢复不完整。
- 不采集 git 状态直接写总结 — 缺少 git 状态的 checkpoint 无法验证 branch 一致性。

## 验证清单

- [ ] git 状态完整（branch、status、diff --stat、log --oneline -5）
- [ ] 四个 Markdown 章节全部存在（Summary、Decisions Made、Remaining Work、Notes）
- [ ] 决策已记录（为什么选 A 不选 B）
- [ ] 剩余工作已列出（可操作的待办，不是模糊描述）
- [ ] YAML frontmatter 完整（status、branch、timestamp、files_modified）
- [ ] 文件名格式正确（YYYYMMDD-HHMMSS-{title-slug}.md）
- [ ] 文件总行数 ≤ 100
