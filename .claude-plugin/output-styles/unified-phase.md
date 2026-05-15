---
name: Unified Phase
description: 阶段驱动的交互范式 — 每次回复标注阶段、loading tier、产出目标
keep-coding-instructions: true
force-for-plugin: true
---

## 回复格式约束

每次回复开头必须标注三项状态（一行即可）：

**格式**: `[阶段 | tier | 产出目标]`

示例：
- `[define | standard | spec 产出]`
- `[design | expanded | 02-design.md 定稿]`
- `[build | standard | 软件产物 + ADR]`
- `[verify | expanded | 04-review.md 审查报告]`
- `[ship | standard | 05-ship.md 发布记录]`
- `[maintain | light | context save]`

如果当前没有明确的阶段 skill 激活，标注：
- `[none | light | 响应用户问题]`

## 阶段标注规则

阶段由当前激活的 skill 决定：
- define-cognitive-brainstorm → define
- define-workflow-refine → define
- define-workflow-spec → define
- design-workflow-design → design
- design-experience-interaction → design
- design-visual-direction → design
- design-content-script → design
- design-content-direction → design
- design-content-layout → design
- design-interactive-preview → design
- build-workflow-plan → build
- build-workflow-execute → build
- build-quality-tdd → build
- build-frontend-ui-engineering → build
- build-backend-* → build
- build-cognitive-* → build
- build-content-* → build
- build-infrastructure-git → build
- verify-workflow-review → verify
- verify-workflow-spec-compliance → verify
- verify-quality-* → verify
- verify-workflow-debug → verify
- verify-* → verify
- ship-workflow-ship → ship
- ship-workflow-canary → ship
- ship-workflow-land → ship
- ship-infrastructure-* → ship
- ship-artifact-export → ship
- maintain-workflow-* → maintain
- reflect-team-* → reflect

## Loading tier 规则

声明当前 loading tier（与 Context Runtime 一致）：
- light: router-only 或少量当前事实
- standard: 1 主技能 + 最多 1 专项
- expanded: 1 主技能 + 最多 2 专项
- full: 全部角色（仅 --full、对抗性审核、全身体检）

## 产出目标

标注本轮操作意图产出的目标产物名称（一句话），例如：
- spec 产出 → 本轮目标是产出 01-spec.md
- 02-design.md 定稿 → 本轮目标是完成设计定稿
- 软件产物 + ADR → 本轮目标是实现代码 + 记录架构决策

## 退出条件提醒

在阶段 skill 激活时，回复结尾简要提及出口条件是否已满足。例如：
- /refine 激活时："spec 是否已通过 External Scan + Idea Scout Army 审查？"
- /build 激活时："所有 Task 是否有验证证据？是否需要 ADR？"

不要长篇重复完整出口条件清单，一句话点检即可。

## 何时不标注

以下情况不需要阶段标注：
- 纯问答（用户只是问一个概念问题，没有 skill 激活）
- 紧急修复（用户说"帮我看一下这个报错"，不走正式阶段）
- 用户明确说"不需要标注"或 "--fast"

此时标注 `[none | light | 响应用户问题]`。