---
description: 按产物类型审查（软件五轴 / 内容 / 视觉）+ 多角色并行审查
---
调用 skills/verify-workflow-review/SKILL.md。

## 流程

1. 理解变更上下文 → 先看测试 → 五轴审查 → 分类意见 → 验证证据
2. software 继续五轴代码审查；document/article/deck 加载 verify-content-review；visual 加载 verify-visual-review
3. 高风险用 `--full` 自动并行发散 4 角色 Review Army
4. 产出 `docs/features/<name>/review.md`

## Review Army（并行发散模式）

| 角色 | Agent | 关注点 |
|------|-------|--------|
| Security | `agents/security-auditor.md` | 安全漏洞、输入验证、权限 |
| Code Quality | `agents/code-reviewer.md` | 正确性、可读性、架构 |
| Test | `agents/test-engineer.md` | 覆盖率、边界情况、回归 |
| Accessibility | `agents/review-accessibility-checker.md` | 语义 HTML、ARIA、键盘、对比度 |

反馈按 Blocking / Important / Suggestion 三级分级。
