---
name: review
description: 五轴代码审查。使用 cuando 功能完成准备合并、需要在合入前做质量把关时
---

# Review — 代码审查

加载 `verify-workflow-review/SKILL.md` 执行五轴审查。

## 流程

1. 加载 `verify-workflow-review/SKILL.md`
2. 执行标准模式（当前会话）或并行发散模式（`--full`）
3. 五轴：Correctness / Readability / Architecture / Security / Performance
4. 产出 `docs/features/<name>/review.md`

## 高风险触发并行模式

- 安全敏感 → `agents/security-auditor.md`
- 测试覆盖需验证 → `agents/test-engineer.md`
- 代码质量敏感 → `agents/code-reviewer.md`

## 同时加载

- `CANON.md` — 宪法第 5 条（Verify Don't Assume）、第 7 条（Push Back）
