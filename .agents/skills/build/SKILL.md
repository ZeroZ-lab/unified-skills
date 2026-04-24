---
name: build
description: 增量实现 + TDD + 决策记录。使用 cuando plan 已批准、需要按计划写代码实现功能时
---

# Build — 增量实现

加载执行引擎，选择模式后执行增量实现。

## 流程

1. 读取 `docs/features/<name>/02-plan.md`
2. 加载 `build-cognitive-execution-engine/SKILL.md` 选择执行模式（inline / subagent / parallel）
3. 加载 `build-workflow-execute/SKILL.md` 执行增量循环（每切片：实现 → 测试 → 验证 → 提交）
4. 遇到架构决策 → 加载 `build-cognitive-decision-record/SKILL.md` 写 ADR
5. 遇到 Bug → 加载 `verify-workflow-debug/SKILL.md`

## 同时加载

- `build-quality-tdd/SKILL.md` — TDD Iron Law
- `CANON.md` — 宪法第 2-5 条
