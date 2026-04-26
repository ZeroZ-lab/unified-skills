---
name: maintain-workflow-context-restore
description: 恢复保存的工作上下文。使用 cuando 新 session 需要继续之前的工作
---

# Context Restore — 恢复工作上下文


## 入口/出口
- **入口**: `.claude/checkpoints/` 下的 checkpoint 文件
- **出口**: 上下文摘要呈现给用户
- **指向**: 确认后 → 继续原工作流（build / verify / ship 等）
- **假设已加载**: CANON.md

## Hard Gate

```
只读操作。不修改代码。
```

恢复上下文后直接动手写代码 = 跳过确认。必须先呈现、再确认、再行动。

## 流程

### Step 1: 查找 checkpoint 文件

扫描 `.claude/checkpoints/` 下所有 `.md` 文件。

文件名以 `YYYYMMDD` 前缀开头，天然保证时间排序。按文件名字母序排列即为时间序。

```bash
ls .claude/checkpoints/*.md | sort
```

### Step 2: 选择 checkpoint

**默认行为：** 加载最新的（排序后最后一个）。

**按片段搜索：** 支持按标题关键词筛选。

```
/restore              → 加载最新 checkpoint
/restore auth         → 搜索文件名包含 "auth" 的最新 checkpoint
/restore list         → 列出最近 20 个 checkpoint（标题 + 时间 + 状态）
```

**按编号选择：** `list` 输出带编号，用编号指定。

### Step 3: 呈现摘要

读取 checkpoint 文件，提取并呈现关键信息：

```
📋 Checkpoint: refactor-auth-module
  分支: feature/auth-refactor
  时间: 2026-04-24 14:30
  状态: active

  Summary: 将登录模块从 session-based 重构为 JWT-based。
           已完成 token 签发，停在 refresh token 轮换逻辑。

  Remaining Work:
    - Refresh token 轮换逻辑
    - 旧 session 清理迁移
    - 集成测试补全
```

不展开全部内容。只呈现恢复决策所需的最小信息。完整内容在用户要求时才展示。

### Step 4: Branch 匹配检查

获取当前 git branch，与 checkpoint 的 `branch` 字段比对：

| 情况 | 处理 |
|------|------|
| 完全匹配 | 正常继续 |
| 不匹配 | 发出警告：`⚠️ 当前分支 {current} 与 checkpoint 分支 {saved} 不匹配。确认是否切换分支？` |
| checkpoint 无 branch 字段 | 提示：`checkpoint 缺少 branch 信息，请手动确认分支是否正确` |

branch 不匹配不阻止恢复——但必须警告。用户可能有意在另一个分支继续。

### Step 5: 提示下一步

呈现摘要后，等待用户选择：

1. **继续工作** — 按 checkpoint 的 Remaining Work 继续
2. **查看完整文件** — 输出 checkpoint 全文
3. **忽略** — 不恢复，从当前状态继续

不做任何假设。不自动开始写代码。

## Checkpoint 文件示例

一个完整、格式良好的 checkpoint 长这样：

```markdown
# .claude/checkpoints/20260425-143000-task-auth.md

## Summary
实现用户认证功能：JWT token 签发 + 验证中间件

## Decisions Made
- 选择 JWT 而非 session（理由：无状态、横向扩展友好）
- access token 15min + refresh token 7d
- 密码用 bcrypt cost=12

## Remaining Work
- [ ] 刷新 token 端点
- [ ] 密码重置流程
- [ ] 集成测试

## Notes
- spec 在 docs/features/20260425-auth/01-spec.md
- plan 在 docs/features/20260425-auth/02-plan.md
- 当前分支: feature/auth-jwt
- 下一步: 实现 refresh token 轮换
```

## Checkpoint 选择流程图

```
查找 checkpoints/
  │
  ├── 找到多个？
  │   ├── YES → 按时间戳排序 → 选最新的
  │   └── NO → 只有一个 → 使用它
  │
  ├── 分支匹配？
  │   ├── YES → 继续
  │   └── NO → 警告用户 → 确认是否继续
  │
  ├── 状态检查
  │   ├── blocked → 先调查阻塞原因
  │   └── in_progress → 直接恢复
  │
  └── 呈现摘要 → 用户确认 → 开始工作
```

## 反模式修复表

| 反模式 | 修复 |
|--------|------|
| 恢复后不检查分支 | 必须比对 checkpoint 分支和当前分支，不匹配则警告 |
| 跳过用户确认直接继续 | 呈现摘要后必须等待人类伙伴确认 |
| 恢复损坏格式的 checkpoint | 先检查 markdown 结构完整性，缺失字段则跳过并报告 |
| 恢复后忽略 Remaining Work | Remaining Work 是工作起点，必须逐项确认 |
| 同时恢复多个 checkpoint | 只恢复一个。多个则让用户选择最相关的 |
| 恢复后忘记原工作目标 | Summary 是你的北极星，每次操作前回顾 |
| 只看代码变更不看决策 | Decisions Made 防止重复讨论已排除的方案 |
| 恢复后不检查相关文件是否仍存在 | 验证 spec/plan 等引用路径，缺失则标记为 stale |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "从零开始更快" | 重新理解代码库比恢复上下文慢 10 倍。保存的决策和注意事项是花钱买到的经验。 |
| "文件太多了" | 只显示最近 20 个，更早的按需加载。不需要翻全部历史。 |
| "之前的上下文已经过时了" | 过时的不是整个上下文——决策记录和注意事项通常仍然有效。先看再判断。 |
| "我记得之前在做什么" | 记忆在 session 边界消失。你有 100% 信心记得每一个决策和注意事项？ |
| "只需要看代码就行" | 代码告诉你做了什么，不告诉你为什么这么做、还差什么、要注意什么。 |
| "我直接重新开始不用恢复" | 上下文恢复节省重复工作。至少看一眼之前的决策。 |
| "checkpoint 肯定过时了" | 过时的决策记录也有价值——知道什么已被排除。 |
| "我只需要代码不需要决策记录" | 决策记录防止你重新考虑已排除的方案。 |
| "git log 够了不用 checkpoint" | git log 记录 what，checkpoint 记录 why。两者互补。 |
| "恢复太麻烦了" | 比从头开始快。摘要只需 30 秒读完。 |

## 红旗 — STOP

- 恢复后直接开始写代码 — 违反 Hard Gate。必须先确认上下文仍准确。
- 忽略 branch 不匹配警告 — 不同分支的代码状态可能完全不同，强行继续 = 覆盖错误基础。
- 加载过时的 blocked checkpoint 不问原因 — blocked 有原因。不搞清楚为什么被阻塞就继续，会重蹈覆辙。
- 呈现摘要时省略 Remaining Work — 用户无法判断"接下来做什么"，恢复就失去意义。
- 不检查 checkpoint 文件格式完整性 — 格式破损的 checkpoint 可能误导恢复。

**注意来自人类伙伴的信号：**
- "之前做到哪了？" — 你没读 checkpoint 就开始工作了
- "这是新的还是继续之前的？" — 你没确认恢复状态
- "上次为什么不用方案 A？" — 你没读 Decisions Made
- "还要多久？" — 你没读 Remaining Work 了解剩余任务
- "这个之前不是讨论过吗？" — 你没恢复之前的决策上下文

**全部意味着：STOP。回去读 checkpoint。**

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Checkpoint 文件损坏或格式错误 | 跳过该 checkpoint，报告错误，尝试次新的 checkpoint |
| Checkpoint 分支已被 force-push | 警告用户分支历史已被重写，确认是否继续 |
| Checkpoint 引用的文件已不存在 | 标记为 stale，提示用户可能需要重新开始 |
| Checkpoint 状态为 blocked | 先调查阻塞原因，解决阻塞后再恢复工作 |
| 同一任务有多个 checkpoint | 选最新的。如果最新的是 blocked 状态，选最新的非 blocked |
| Checkpoint 的 Remaining Work 全部已完成 | 报告该任务可能已完工，确认是否需要清理 checkpoint |

## 验证清单

- [ ] checkpoint 文件存在于 `.claude/checkpoints/`
- [ ] YAML frontmatter 完整（status、branch、timestamp、files_modified）
- [ ] 四个 Markdown 章节全部存在（Summary、Decisions Made、Remaining Work、Notes）
- [ ] branch 匹配或已发出警告
- [ ] 用户确认继续（未自动开始操作）
- [ ] 呈现了摘要而非全文（用户未要求时）
