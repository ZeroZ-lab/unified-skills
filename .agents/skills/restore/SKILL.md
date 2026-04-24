---
name: restore
description: 恢复之前保存的工作上下文。使用 cuando 需要继续之前中断的工作时
---

# Restore — 恢复工作上下文

加载 `maintain-workflow-context-restore/SKILL.md` 执行上下文恢复。

## 流程

1. 查找 `.claude/checkpoints/` 下所有文件
2. 默认加载最新的，或按关键词搜索匹配
3. 呈现摘要（分支、状态、决策、剩余工作）
4. 如分支不匹配，发出警告
5. 提示下一步：继续工作 / 查看完整内容 / 忽略

## 依赖

需要先用 `$save` 创建 checkpoint。

## 同时加载

- `CANON.md` — 宪法第 9 条（Structured Questions）