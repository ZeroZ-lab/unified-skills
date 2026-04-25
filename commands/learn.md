---
description: 跨 session 学习记录管理
---

# Command: /learn

## Goal

Manage cross-session learning records for continuous improvement.

## Phases

### Phase 1: Learning Operation

**Agent:** 主 session 直接执行
**Skills:** maintain-workflow-learn
**Input:** 用户操作（add / search / prune / export）
**Process:**
1. 根据用户意图执行操作
2. 更新 .claude/learnings.jsonl
**Output:** 操作结果
**Validation:**
- [ ] 操作成功完成

---

## Entry Conditions
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 学习记录操作完成

## Next Steps
- → 继续工作

## 实现

加载 CANON.md → 调用 .agents/skills/learn/SKILL.md。

用法：`/learn [search <关键词> | add <洞察> | prune | export]`
