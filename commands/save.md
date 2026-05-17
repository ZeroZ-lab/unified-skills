---
description: 保存工作上下文到 checkpoint。当需要保存当前工作状态供后续 session 恢复，或提到"保存""save""checkpoint"
---

# Command: /save

## Runtime Preflight

本命令是显式 Unified 入口。执行本命令时，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Capture current work context as a restorable checkpoint.

## Phases

### Phase 1: Capture Context

**Agent:** 主 session 直接执行
**Skills:** maintain-workflow-context-save
**Input:** 当前对话上下文 + 当前工作文件
**Process:**
1. 收集当前工作状态
2. 记录关键决策和上下文
3. 生成 checkpoint 文件
**Output:** .claude/checkpoints/YYYYMMDD-HHMMSS-{title}.md
**Validation:**
- [ ] checkpoint 文件已生成

---

## Entry Conditions
- [ ] 有活跃的工作上下文

## Exit Conditions
- [ ] checkpoint 文件已生成

## Next Steps
- → /restore 恢复此 checkpoint

## 实现

加载 CANON.md → 调用 skills/maintain-workflow-context-save/SKILL.md。

用法：`/save [描述]`
