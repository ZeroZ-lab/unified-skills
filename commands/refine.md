---
description: 从模糊想法到明确的 spec + External Scan + 多角色 idea 验证
---
加载 CANON.md → 调用 skills/define-workflow-refine/SKILL.md。

## 流程

1. Phase 1：探索项目上下文、Scope 检查、逐一澄清问题
2. Phase 1.4：External Scan — 搜索已有方案、竞品、事实来源、设计/技术模式，并分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject
3. Phase 1.6：Idea Scout Army — 并行分派 CEO + Eng + Design 三视角验证 idea
4. Phase 2：基于用户输入、External Scan 和 scout 反馈提出 2-3 种方案
5. Phase 3：产出 spec
6. 明确 artifact_type：software / document / article / deck / visual，默认 software
7. 产出 docs/features/<name>/01-spec.md。想法收敛后可继续 /plan，或先用 define-workflow-spec 编写更详细的 spec

## External Scan

External Scan 是 Unified 原生流程，不引用 gstack 或任何特定第三方技能。使用当前宿主可用的 WebSearch、browser、文档检索或用户提供资料；工具不可用时记录 unavailable 并继续。

按 artifact_type 搜索：
- software：竞品功能、现有库/框架能力、技术最佳实践、已知坑
- document/article：目标读者、同类结构、事实来源、写作范式
- deck：同类演示结构、叙事模式、页面信息密度、数据表达方式
- visual：竞品视觉、品牌/媒介规范、布局模式、可读性要求

## Idea Scout Army

| 角色 | Agent | 关注点 |
|------|-------|--------|
| CEO | `agents/refine-ceo-scout.md` | 问题验证、方案杠杆、优先级、成功标准 |
| Eng | `agents/refine-eng-scout.md` | 可行性、规模估算、依赖、替代方案 |
| Design | `agents/refine-design-scout.md` | UX 方向、心智模型、关键交互、设计范围 |

Scout 输入必须包含用户澄清结果、artifact_type、External Scan 摘要、项目上下文和"不做/待确认"边界。反馈按 Blocking / Important / Suggestion 三级分级，并写入 spec 的 Scout Review Summary。
