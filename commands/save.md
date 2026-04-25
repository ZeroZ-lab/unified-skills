---
description: 保存工作上下文到 checkpoint
---

# Command: /save

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

加载 CANON.md → 调用 .agents/skills/save/SKILL.md。

用法：`/save [描述]`
