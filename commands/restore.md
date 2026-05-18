---
description: 恢复之前保存的工作上下文。当新 session 需要继续之前的工作，或提到"恢复""restore""继续上次"
---

# Command: /restore

## Runtime Preflight

本命令是显式 Unified 入口。执行本命令时，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Restore work context from a previously saved checkpoint.

Use `/restore` when the automatic feature state is not enough. SessionStart already reads `docs/features/<feature>/state.json` for stage-level continuity; `/restore` is for decision-rich checkpoint recovery, historical task selection, or when the user asks to inspect previous context.

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
- [ ] 当前需要恢复决策、取舍、注意事项或历史 checkpoint，而不是只需要知道当前 feature 阶段

## Exit Conditions
- [ ] 工作上下文已恢复

## Next Steps
- → 继续之前的工作
- → 若只需继续最新 active feature，可优先使用 SessionStart 注入的 feature state 提示

## 实现

加载 CANON.md → 调用 skills/maintain-workflow-context-restore/SKILL.md。

用法：`/restore [关键词]`
