# /restore — 恢复工作上下文

加载技能：`maintain-workflow-context-restore`

## 用法

```
/restore          # 恢复最新的 checkpoint
/restore <关键词>  # 按关键词搜索 checkpoint
```

## 行为

1. 查找 `.claude/checkpoints/` 下所有文件
2. 默认加载最新的，或按关键词搜索匹配
3. 呈现摘要（分支、状态、决策、剩余工作）
4. 如分支不匹配，发出警告
5. 提示下一步：继续工作 / 查看完整内容 / 忽略

## 依赖

需要先用 `/save` 创建 checkpoint。
