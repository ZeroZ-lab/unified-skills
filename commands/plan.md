---
description: 从 spec 到详细任务分解 + 多角色计划审查
---
加载 CANON.md → 调用 skills/build-workflow-plan/SKILL.md。

## 流程

1. 读取 artifact_type，按软件、文档、文章、PPT 或视觉稿拆分任务和验证步骤
2. 自审通过后，自动并行分派 Plan Review Army（CEO + Eng + Design + Security 四视角）
3. 合并审查反馈，修改 plan
4. 产出 `docs/features/<name>/02-plan.md`，附 Review Army 审查摘要
5. 用户批准后建议 `/build`

## Plan Review Army

| 角色 | Agent | 关注点 |
|------|-------|--------|
| CEO | `agents/plan-ceo-reviewer.md` | 商业价值、范围、优先级 |
| Eng | `agents/plan-eng-reviewer.md` | 技术可行、架构、风险 |
| Design | `agents/plan-design-reviewer.md` | 用户体验、交互、一致性 |
| Security | `agents/plan-security-reviewer.md` | 数据隐私、攻击面、合规 |

反馈按 Blocking / Important / Suggestion 三级分级。
