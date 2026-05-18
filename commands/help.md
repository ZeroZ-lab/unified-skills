---
description: 显示 Unified Skills 能力概览——命令、制品类型、工作流阶段。当需要了解 Unified 支持什么，或提到"帮助""help""命令列表"
---

# Command: /help

## Runtime Preflight

本命令是显式 Unified 入口。执行本命令时，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


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
| /brainstorm | Define | 模糊想法 → 2-3 方案 + 推荐 | 00-brainstorm.md |
| /refine | Define | 模糊想法 → 明确 spec | 01-spec.md |
| /design | Design | spec → 证据驱动设计定稿 | 02-design.md + DESIGN.md |
| /plan | Build | spec + design → 可执行任务计划 | 03-plan.md |
| /build | Build | 按计划增量生成产物 | 软件/内容/视觉 + ADR |
| /review | Verify | 按制品类型质量审查 | 04-review.md |
| /ship | Ship | 发布/导出检查 + Go/No-Go | 05-ship.md |
| /save | Maintain | 保存工作上下文 | checkpoint 文件 |
| /restore | Maintain | 恢复之前的工作上下文 | — |
| /learn | Maintain | 跨 session 学习记录 | learnings.jsonl |
| /help | — | 显示本概览 | — |

### 一级交付类 + 兼容 `artifact_type`

| 一级交付类 | 当前 runtime `artifact_type` | 适用场景 | 关键技能 |
|------------|-----------------------------|----------|----------|
| software | software | 代码、API、数据库、UI | TDD、调试、安全审查 |
| content | document / article / deck | 文档、文章、PPT、讲述型产物 | 内容写作、内容审查、版式 |
| visual | visual | 视觉稿、设计稿、导出视觉产物 | 版式、视觉审查、导出 QA |

说明：
- 第一阶段兼容迁移里，实际路由字段仍是 `artifact_type`
- 项目级工作流语义用 `software / content / visual` 三类解释角色和 pipeline
- `deck` 属于 `content`，但在 `/review` 中通常叠加视觉审查

### 典型工作流

想法模糊 → /brainstorm → /refine → /design → /plan → /build → /review → /ship

唯一合法加载链路：

`router / command -> stage skill -> current agent or persona -> main session merge`

### 项目级设计约束

| 文档 | 位置 | 用途 |
|------|------|------|
| DESIGN.md | 项目根目录 | 跨 feature 的设计系统（Google Stitch token 格式），/design 批准后自动同步 |
| 02-design.md | docs/features/YYYYMMDD-<name>/ | 当前 feature 的创作设计定稿 |

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
