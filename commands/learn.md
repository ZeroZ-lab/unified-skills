# /learn — 跨 session 学习

加载技能：`maintain-workflow-learn`

## 用法

```
/learn              # 显示最近 20 条学习记录
/learn search <关键词>  # 全文搜索学习记录
/learn add <洞察>    # 手动添加学习记录
/learn prune        # 清理过时和矛盾的记录
/learn export       # 导出为 markdown
```

## 行为

管理 `.claude/learnings.jsonl`（项目级学习记录）。

每条记录包含：type（pattern/pitfall/preference/architecture）、key、insight、confidence、files、source、timestamp。

## 产出

终端输出学习记录列表或搜索结果。`export` 子命令输出 markdown 文件。
