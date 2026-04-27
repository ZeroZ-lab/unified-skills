---
description: 显示 Unified Skills 能力概览——命令、制品类型、工作流阶段
---

# Command: /help

## Goal

Show what Unified Skills can do: available commands, artifact types, workflow stages, and how to get started.

## Phases

### Phase 1: Display Overview

**Agent:** current
**Process:**
1. 输出 Unified Skills 能力概览（命令、制品类型、阶段、用法）
2. 根据用户当前上下文给出推荐起点

**Output:**

```
## Unified Skills — 能力概览

### 工作流命令（按阶段）

| 命令 | 阶段 | 做什么 | 产出 |
|------|------|--------|------|
| /brainstorm | Define | 模糊想法 → 2-3 方案 + 推荐 | brainstorm.md |
| /refine | Define | 模糊想法 → 明确 spec | 01-spec.md |
| /plan | Build | spec → 可执行任务计划 | 02-plan.md |
| /build | Build | 按计划增量生成产物 | 软件/内容/视觉 + ADR |
| /review | Verify | 按制品类型质量审查 | review.md |
| /ship | Ship | 发布/导出检查 + Go/No-Go | ship.md |
| /save | Maintain | 保存工作上下文 | checkpoint 文件 |
| /restore | Maintain | 恢复之前的工作上下文 | — |
| /learn | Maintain | 跨 session 学习记录 | learnings.jsonl |
| /help | — | 显示本概览 | — |

### 制品类型（artifact_type）

| 类型 | 适用场景 | 关键技能 |
|------|----------|----------|
| software | 代码、API、数据库、UI | TDD、调试、安全审查 |
| document | 技术文档、规范 | 内容写作、版式 |
| article | 文章、博客 | 内容写作 + 内容审查 |
| deck | PPT、演示文稿 | 内容写作 → 版式（顺序不可逆）|
| visual | 视觉稿、设计稿 | 版式 + 视觉审查 |

### 典型工作流

想法模糊 → /brainstorm → /refine → /plan → /build → /review → /ship

### 宪法（CANON.md）

10 条不可变规则，核心四条：
1. TDD Iron Law — 没有测试先失败的代码 = 不存在的代码
2. 4-Phase Debugging — 根因在前，修复在后
3. Verify Don't Assume — 没有验证证据不能声称完成
4. Scope Discipline — 只改该改的
```

---

## Entry Conditions
- 无（任何时刻可用）

## Exit Conditions
- [ ] 能力概览已展示

## 实现

直接输出能力概览。不加载额外技能。
