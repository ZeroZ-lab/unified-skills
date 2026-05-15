---
description: 恢复之前保存的工作上下文
---

# Command: /restore

## Runtime Preflight

执行本命令前，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Restore work context from a previously saved checkpoint.

## Phases

### Phase 1: Load Checkpoint

**Agent:** 主 session 直接执行
**Skills:** maintain-workflow-context-restore
**Input:** checkpoint 文件路径（或用户选择）
**Process:**
1. 列出可用的 checkpoints
2. 用户选择要恢复的 checkpoint
3. 加载并恢复工作上下文
**Output:** 恢复的工作上下文
**Validation:**
- [ ] 关键上下文已恢复

---

## Entry Conditions
- [ ] 存在至少一个 checkpoint 文件

## Exit Conditions
- [ ] 工作上下文已恢复

## Next Steps
- → 继续之前的工作

## 实现

加载 CANON.md → 调用 skills/maintain-workflow-context-restore/SKILL.md。

用法：`/restore [关键词]`
