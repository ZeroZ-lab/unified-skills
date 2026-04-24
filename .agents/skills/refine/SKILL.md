---
name: refine
description: 模糊想法收敛 → 规范 spec + 多角色 idea 验证。使用 cuando 有模糊想法需要提炼、用户需要规范或做功能定义时
---

# Refine — 想法收敛

加载 `define-workflow-refine/SKILL.md` 执行完整的收敛流程。

## 流程

1. 阅读项目的 CLAUDE.md / AGENTS.md / spec / plan 了解现状
2. 加载 `define-workflow-refine/SKILL.md` 执行 Phase 1（探索 + 澄清）
3. Phase 1.5：Idea Scout Army — 并行分派 3 个 scout 验证 idea
4. Phase 2：基于反馈提出 2-3 种方案 → Phase 3：产出 spec
5. 明确 `artifact_type`: software / document / article / deck / visual，默认 software
6. 产出 `docs/features/<name>/01-spec.md`

## Idea Scout Army

| 角色 | Agent | 关注点 |
|------|-------|--------|
| CEO | `agents/refine-ceo-scout.md` | 问题验证、方案杠杆、优先级、成功标准 |
| Eng | `agents/refine-eng-scout.md` | 可行性、规模估算、依赖、替代方案 |
| Design | `agents/refine-design-scout.md` | UX 方向、心智模型、关键交互、设计范围 |

## 同时加载

- `CANON.md` — 宪法第 1 条（Surface Assumptions）、第 7 条（Push Back）
