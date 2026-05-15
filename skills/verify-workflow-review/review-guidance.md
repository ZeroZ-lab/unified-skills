# Review Guidance

本文件是 `verify-workflow-review/SKILL.md` 的辅助材料。主技能保留两阶段审查 gate；需要审查模式、拆分策略和卫生规则时读取本文件。

## 并行发散模式

高风险场景可以派发专业审查 agent：

```
安全敏感             -> agents/review-security-auditor.md
代码质量敏感          -> agents/review-code-quality-auditor.md
测试覆盖需要验证      -> agents/review-test-engineer.md
无障碍合规           -> agents/review-accessibility-auditor.md
```

触发条件：
- 敏感数据
- >50 行变更
- >2 文件
- 有 UI 变更
- 用户指定 `--full`

最少触发：
- 小型变更：标准模式
- 标准变更：spec compliance + code quality
- UI 变更：加 accessibility
- 安全敏感：加 security
- `--full`：4 角色全开

每个 agent 输出 Blocking / Important / Suggestion。

## 变更大小

```text
~100 行   -> 好，一次会议审完
~300 行   -> 可接受，如果是一个逻辑变更
~1000 行  -> 过大，要拆分
```

拆分策略：

| 策略 | 方法 | 适用场景 |
|------|------|----------|
| Stack | 提交一个小的，下一个基于它 | 串行依赖 |
| 按文件组 | 按不同审查者拆文件 | 跨关注点变更 |
| 水平拆分 | 先建共享代码，再建消费者 | 分层架构 |
| 垂直拆分 | 拆成多个全栈功能切片 | 功能开发 |

## Dead Code 卫生

审查时检查并标记废弃代码：

```text
DEAD CODE IDENTIFIED:
- formatLegacyDate() in src/utils/date.ts — replaced by formatDate()
- OldTaskCard 组件 — 已由 TaskCard 替代
-> 安全删除？
```

明确列出废弃代码，询问后再删除。不遗留死代码。

## 变更描述标准

标题行必须简短、祈使句、自包含。正文解释为什么变，不重复 diff 已经显示的 what。

反模式：
- Fix bug
- Fix build
- Add patch
- Phase 1
- Add convenience functions

## 依赖自律

审查新增依赖：
- 现有技术栈能否解决？
- 依赖多大？
- 是否活跃维护？
- 是否有已知漏洞？
- 许可证是否兼容？

优先标准库和现有工具。每个新增依赖都是负债。
