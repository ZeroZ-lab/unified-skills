---
name: review
description: 按产物类型审查。使用 cuando 软件、文档、文章、PPT 或视觉稿完成后需要质量把关时
---

# Review — 产物审查

加载 `verify-workflow-review/SKILL.md`，按 spec 的 `artifact_type` 执行软件、内容或视觉审查。

## 流程

1. 加载 `verify-workflow-review/SKILL.md`
2. 执行标准模式（当前会话）或并行发散模式（`--full`）
3. software 五轴：Correctness / Readability / Architecture / Security / Performance
4. document/article/deck 加载 `verify-content-review/SKILL.md`
5. visual 加载 `verify-visual-review/SKILL.md`
6. 产出 `docs/features/<name>/review.md`

## 高风险触发并行模式

- 安全敏感 → `agents/security-auditor.md`
- 测试覆盖需验证 → `agents/test-engineer.md`
- 代码质量敏感 → `agents/code-reviewer.md`

## 同时加载

- `CANON.md` — 宪法第 5 条（Verify Don't Assume）、第 7 条（Push Back）
