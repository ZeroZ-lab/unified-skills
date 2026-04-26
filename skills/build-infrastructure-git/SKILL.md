---
name: build-infrastructure-git
description: 版本控制工作流——原子提交、整洁历史。使用 cuando 需要提交代码、创建分支或管理变更
---

# Git — 版本控制工作流


## 入口/出口
- **入口**: build 过程中需要提交代码或创建分支
- **出口**: 整洁、可分拆审查的提交历史
- **指向**: 继续 build 或进入 `/review`
- **假设已加载**: CANON.md

## Iron Law

<HARD-GATE>
```
原子提交、描述性信息、关注点分离。
绝不 `git add -A`、绝不 force-push 共享分支、绝不跳过钩子、绝不提交密钥。
每个提交是独立可理解、可 revert、可 bisect 的。
```
</HARD-GATE>

## 核心原则

### 1. Trunk-Based Development（推荐）

```
main ────○────○────────○────○── (经常合并小改动)
           \          /
feature     ○──○──○──○  (短生命周期分支，< 2 天)
```

**规则:**
- 分支存活 < 2 天
- 合并前 rebase 到最新 main
- 小 PR（100-300 行）> 大 PR
- 直接提交到 main 仅用于文档修复、配置调整等无行为变更

### 2. 原子提交 — 一个改动一个提交

```
Good:
  1a2b3c feat: add Task.create() with validation
  4d5e6f test: add unit tests for Task.create()
  7f8g9h refactor: extract validateTask to shared module

Bad:
  abc123 feat: add task creation, tests, refactor validation, fix typo in README
```

**每个提交是独立可理解、可 revert、可 bisect 的。**

### 3. 描述性提交信息

```
<type>: <简短摘要（< 50 字符）>

<详细说明 —— 为什么改，不是什么（可选，如有必要）>
```

**类型:** feat / fix / refactor / test / docs / chore / perf / security

提交信息写 **why**，不是 what。`git diff` 已经显示了 what。

```
Good:
  fix: prevent race condition when two users complete same task
  
  The task status check and update were not atomic, allowing two
  concurrent requests to both mark a task as completed.

Bad:
  fix: update task service
```

### 4. 关注点分离

- 格式化变更 → 单独的格式化提交
- 重命名/移动文件 → 单独提交（不要混入行为变更）
- 行为变更 → 单独的提交

**绝不将格式化变更和行为变更混在一次提交。**

### 5. 变更大小

| 大小 | 行数 | 评审难度 |
|------|------|---------|
| **Small** | < 100 行 | 轻松评审，快速合并 |
| **Medium** | 100-300 行 | 常规 PR，可在一个审查会话完成 |
| **Large** | 300-1000 行 | 需要拆分或更仔细审查 |
| **XL** | > 1000 行 | 必须拆分 |

**目标: 每次提交约 100 行。** 超过 300 行 → 执行是否拆分。

## Save Point 模式

频繁提交、经常 push。提交 = 保存点，不是最终成品。

```
实现 Task A      实现 Task B      格式化          Rebase 到 main
    │                │               │                  │
    ▼                ▼               ▼                  ▼
commit + push   commit + push   commit + push    git pull --rebase
                                                    │
                                               push + merge
```

**安全网:** 每完成一个逻辑单元（一个函数、一个测试、一个重构步骤）就 commit。如果之后搞砸了，回退成本低。

## Worktree 隔离

为不相关的工作创建隔离环境：

```bash
# 创建隔离工作区
git worktree add -b feature/x ../project-feature-x main

# 在隔离区工作
cd ../project-feature-x

# 完成 → 合并 → 清理
git worktree remove ../project-feature-x
```

**何时用 worktree:**
- 同时处理多个不相关的任务
- 需要快速切回 main 验证某个行为而不丢失当前进度
- 运行长时间脚本（测试、构建）时不阻塞

## Pre-Commit Hygiene

提交前检查：
```bash
git diff --staged            # 审查你实际要提交的变更
git diff --staged --check    # 检查空白字符错误
npm test                     # 运行测试（如果项目有预提交钩子则自动）
```

**绝不:**
- `git add -A` 或 `git add .` — 手动选择文件，避免误提交密钥、二进制文件
- `git push --force` 到共享分支 — 改写了别人的基准
- `--no-verify` 跳过钩子 — 除非钩子坏了且有充分理由
- 提交 `.env`、`credentials.json`、`node_modules`、编译产物

## Git 调试工具

```bash
git bisect start HEAD <known-good-commit>  # 二分查找引入 bug 的提交
git log -- path/to/file                    # 看文件变更历史
git blame -L 10,30 path/to/file            # 看特定行是谁改的
git grep "pattern" $(git rev-list --all)   # 在所有提交中搜索
```

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "把所有改动放一个提交" | 一个巨型提交无法审查、无法 revert、无法 bisect。拆开。 |
| "提交信息不重要，代码能说明一切" | 提交信息是给 2 年后的同事看的。代码显示 what，提交信息解释 why。 |
| "等全部做完再提交" | 频繁提交 = 安全网。出错时回退范围小。 |
| "force-push 无所谓，只有我在这个分支上" | CI 可能在分支上运行，force-push 会中断 CI。即使只有你一人，`--force-with-lease` > `--force`。 |
| "不用 worktree，开两个 clone 就行" | 两个 clone 没有共享对象库，浪费磁盘并需要双份 `npm install`。 |
| "格式化变更和行为变更混在一起跑一次测试就行" | 回退行为变更时被迫同时回退格式化。总是分开。 |

## 红旗 — STOP

<HARD-GATE>
以下任何一个出现，立即停止提交：

- staged 文件超过 10 个且不属于同一改动
- 提交信息 = "fix"、"update"、"WIP"（信息量为零）
- `git add -A` 把不相关的文件一起 staged
- 分支存活超过 3 天且差异超过 500 行
- 格式化变更和行为变更出现在同一 staged 中
- force-push 到 `main`/`master`（重写共享历史）
- staged 中包含 `.env` 或密钥文件
- 合并冲突时用 `--theirs` 整块解决而不是逐一检查
</HARD-GATE>

## 验证清单

- [ ] 每个提交是单一逻辑单元
- [ ] 提交信息使用 `<type>: <summary>` 格式，解释了 why
- [ ] 变更按关注点分离（格式化 vs 行为 vs 重命名）
- [ ] 没有误提交的密钥、二进制文件或生成文件
- [ ] 分支基于最新 main/master
- [ ] 测试在提交前通过
- [ ] 没有 force-push 到共享分支
