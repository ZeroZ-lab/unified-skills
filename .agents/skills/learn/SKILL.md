---
name: learn
description: 跨 session 学习记录管理。使用 cuando 需要记录模式、陷阱、偏好或架构洞察时
---

# Learn — 跨 session 学习

加载 `maintain-workflow-learn/SKILL.md` 执行学习记录管理。

## 流程

1. 管理 `.claude/learnings.jsonl`（项目级学习记录）
2. 支持操作：
   - 显示最近 20 条学习记录
   - `search <关键词>` — 全文搜索学习记录
   - `add <洞察>` — 手动添加学习记录
   - `prune` — 清理过时和矛盾的记录
   - `export` — 导出为 markdown
3. 每条记录包含：type（pattern/pitfall/preference/architecture）、key、insight、confidence、files、source、timestamp

## 产出

终端输出学习记录列表或搜索结果。`export` 子命令输出 markdown 文件。

## 同时加载

- `CANON.md` — 宪法第 5 条（Verify Don't Assume）