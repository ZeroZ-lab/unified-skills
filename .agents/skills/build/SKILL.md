---
name: build
description: 增量生成软件或内容产物。使用 cuando plan 已批准、需要按计划实现软件、文档、文章、PPT 或视觉稿时
---

# Build — 增量生成

加载执行引擎，读取 spec 的 `artifact_type` 后执行增量生成。

## 流程

1. 读取 `docs/features/<name>/02-plan.md`
2. 加载 `build-cognitive-execution-engine/SKILL.md` 选择执行模式（inline / subagent / parallel）
3. 加载 `build-workflow-execute/SKILL.md` 执行增量循环（每切片：生成/实现 → 验证 → 记录）
4. 遇到架构决策 → 加载 `build-cognitive-decision-record/SKILL.md` 写 ADR
5. 遇到 Bug → 加载 `verify-workflow-debug/SKILL.md`

## 同时加载

- `build-quality-tdd/SKILL.md` — software 默认加载
- `build-content-writing/SKILL.md` / `build-content-layout/SKILL.md` — document/article/deck/visual 按需加载
- `CANON.md` — 宪法第 2-5 条
