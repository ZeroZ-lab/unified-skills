---
name: refine
description: 模糊想法收敛 → 规范 spec + External Scan + 多角色 idea 验证。使用 cuando 有模糊想法需要提炼、用户需要规范或做功能定义时
---

# Refine — 想法收敛

加载 `define-workflow-refine/SKILL.md` 执行完整的收敛流程。

## 流程

1. 阅读项目的 CLAUDE.md / AGENTS.md / spec / plan 了解现状
2. 加载 `define-workflow-refine/SKILL.md` 执行 Phase 1（探索 + 澄清）
3. Phase 1.4：External Scan — 按 artifact_type 搜索已有方案、竞品、事实来源、设计/技术模式，并分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject
4. Phase 1.6：Idea Scout Army — 并行分派 3 个 scout 验证 idea
5. Phase 2：基于用户输入、External Scan 和 scout 反馈提出 2-3 种方案 → Phase 3：产出 spec
6. 明确 `artifact_type`: software / document / article / deck / visual，默认 software
7. 产出 `docs/features/<name>/01-spec.md`

## External Scan

External Scan 是 Unified 原生流程，不引用 gstack 或任何特定第三方技能。使用当前宿主可用的 WebSearch、browser、文档检索或用户提供资料；工具不可用时记录 unavailable 并继续。

## Idea Scout Army

| 角色 | Agent | 关注点 |
|------|-------|--------|
| CEO | `agents/refine-ceo-scout.md` | 问题验证、方案杠杆、优先级、成功标准 |
| Eng | `agents/refine-eng-scout.md` | 可行性、规模估算、依赖、替代方案 |
| Design | `agents/refine-design-scout.md` | UX 方向、心智模型、关键交互、设计范围 |

Scout 输入必须包含用户澄清结果、artifact_type、External Scan 摘要、项目上下文和"不做/待确认"边界。反馈按 Blocking / Important / Suggestion 三级分级，并写入 spec 的 Scout Review Summary。

## 同时加载

- `CANON.md` — 宪法第 1 条（Surface Assumptions）、第 7 条（Push Back）
