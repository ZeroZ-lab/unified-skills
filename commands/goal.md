---
description: 目标生命周期管理
---

# Command: /goal

## Goal

Manage persistent goals across sessions with create, pause, resume, complete, and clear operations.

## Phases

### Phase 1: Execute Goal Operation

**Agent:** 主 session 直接执行
**Skills:** maintain-workflow-goal
**Input:** 子命令 + 参数（默认 status）
**Process:**
1. 检测 Codex goal API 可用性
2. 解析子命令（create/list/pause/resume/complete/clear/status）
3. 执行对应操作
4. 输出结果
**Output:** 目标状态变更或查询结果
**Validation:**
- [ ] API 可用性已检测
- [ ] 操作结果已反馈

---

## Entry Conditions
- [ ] Codex CLI v0.128.0+ 已安装

## Exit Conditions
- [ ] 目标操作已完成（成功或明确报错）

## Next Steps
- → /refine 从目标启动需求提炼
- → /save 保存当前工作状态（关联目标上下文）

## Constitutional Rules
- CANON.md Clause 2: Simple First — 不过度设计目标结构
- CANON.md Clause 9: Structured Questions — API 不可用时清晰告知用户

## 实现

加载 CANON.md → 调用 .agents/skills/goal/SKILL.md。

用法：`/goal [create|list|pause|resume|complete|clear|status] [参数]`
