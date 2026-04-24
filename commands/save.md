# /save — 保存工作上下文

加载技能：`maintain-workflow-context-save`

## 用法

```
/save [描述]
```

## 行为

1. 采集当前 git 状态（分支、未提交变更、近期提交）
2. 总结正在做的工作、已做的决策、剩余工作
3. 写入 `.claude/checkpoints/YYYYMMDD-HHMMSS-{title}.md`
4. 输出 checkpoint 路径供 `/restore` 使用

## 产出

`.claude/checkpoints/` 下的 YAML frontmatter + markdown 文件。
