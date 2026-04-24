---
description: 从模糊想法到明确的 spec + 多角色 idea 验证
---
加载 CANON.md → 调用 skills/define-workflow-refine/SKILL.md。

## 流程

1. Phase 1：探索项目上下文、Scope 检查、逐一澄清问题
2. Phase 1.5：Idea Scout Army — 并行分派 CEO + Eng + Design 三视角验证 idea
3. Phase 2：基于反馈提出 2-3 种方案
4. Phase 3：产出 spec
5. 明确 artifact_type：software / document / article / deck / visual，默认 software
6. 产出 docs/features/<name>/01-spec.md。用户批准后建议 /plan

## Idea Scout Army

| 角色 | Agent | 关注点 |
|------|-------|--------|
| CEO | `agents/refine-ceo-scout.md` | 问题验证、方案杠杆、优先级、成功标准 |
| Eng | `agents/refine-eng-scout.md` | 可行性、规模估算、依赖、替代方案 |
| Design | `agents/refine-design-scout.md` | UX 方向、心智模型、关键交互、设计范围 |

反馈按 Blocking / Important / Suggestion 三级分级。
