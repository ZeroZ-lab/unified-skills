---
name: save
description: 保存工作上下文到 checkpoint。使用 cuando 需要保存当前工作状态以便跨 session 继续时
---

# Save — 保存工作上下文

加载 `maintain-workflow-context-save/SKILL.md` 执行上下文保存。

## 流程

1. 采集当前 git 状态（分支、未提交变更、近期提交）
2. 总结正在做的工作、已做的决策、剩余工作
3. 写入 `.claude/checkpoints/YYYYMMDD-HHMMSS-{title}.md`
4. 输出 checkpoint 路径供 `$restore` 使用

## 产出

`.claude/checkpoints/` 下的 YAML frontmatter + markdown 文件。

## 同时加载

- `CANON.md` — 宪法第 9 条（Structured Questions）