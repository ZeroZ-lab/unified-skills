# 交付模型与角色管线重构 — Spec

## Status Summary
- Owner: current session
- Date: 2026-05-18
- Status: approved

## Artifact Type
`artifact_type: software`

当前 runtime 可执行值：`software` / `document` / `article` / `deck` / `visual`。默认 `software`。

canonical 一级交付类：
- `software` ← `software`
- `content` ← `document` / `article` / `deck`
- `visual` ← `visual`

本 feature 改变的是长期工作流真相，因此额外声明：

`delivery_class: software`

## Goal Alignment
- Source Goal: conversation
- Goal Status: accepted
- Goal Review Score: `10/12`

### One-line Goal
把 Unified 当前混合了交付物、实现介质和阶段命令语义的模型，收敛成一套更聚焦的交付分类、角色配置和阶段映射合同，为后续实现提供清晰边界。

### Done When
- [ ] Functional: 明确推荐的一级交付分类模型，以及它如何映射当前 `/refine / design / plan / build / review / ship`
- [ ] Functional: 明确每个场景的默认角色、条件角色和暂不引入的角色
- [ ] Functional: 明确哪些缺口通过新增 persona 解决，哪些仅需接入现有 skill，不新增顶层 skill
- [ ] Functional: 明确第一批 MVP 改动范围，不把全量 8 类型扩编一次性推入实现
- [ ] Technical: spec 中的方案、放弃方案、风险和范围边界可直接被 `/plan` 消费
- [ ] Regression: 不破坏当前 stage-driven contract；`agents/` 仍是 persona 层，skills/commands 仍保留调度权
- [ ] Output: `docs/features/20260518-delivery-model-refactor/01-spec.md`

### Stop Conditions
- [ ] Acceptance 无法验证
- [ ] 需要修改明确排除范围
- [ ] 需要把当前收敛后的 3 类模型推翻，改回 5 类或扩到 8 类并列一级类型
- [ ] 实际范围明显大于当前 Goal（例如要求本次直接完成所有 agent、router、AGENTS、commands、skills 的实现与发布）

## Documentation Impact
- `doc_intent: feature_plus_project`
- `project_truth_changed: yes`
- `affected_project_docs:`
  - `AGENTS.md`
- `rationale:`
  - 这次改动不是一次性 feature 行为，而是 Unified 长期工作流合同重构。即使第一阶段只做最小实现，也会改变项目级 agent contract、交付分类和阶段语义，必须最终同步 `AGENTS.md`。

## 问题
当前 Unified 有三个混层问题：

1. `artifact_type` 同时承担“最终交付物是什么”和“底层用什么实现”的语义，导致 `document / article / deck / visual` 与 `software` 处在不同层级上却被并列处理。
2. 角色体系明显偏 software。`content` 和 `visual` 在 refine、formal review、ship audit 上缺少一等 persona 承接，出现“有 skill、无正式岗位”的断层。
3. 阶段命令已经稳定为 `/refine / design / plan / build / review / ship`，但我们对不同交付物的生产规律理解更接近“统一槽位 + 按交付物填充”，当前合同还没有把这层语义说清楚。

如果直接在现有 5 类 artifact_type 上继续打补丁，会把交付物语义、角色调度和 pipeline 规则继续绑死在一起；如果直接跳到 8 类一级类型和全量新管线，则会在没有验证 80% 主要场景之前把复杂度一次性推高。

## 选定方案
采用一个分两层的收敛模型：

第一层只保留 3 个一级交付类型：`software` / `content` / `visual`。这三类覆盖当前 80% 的核心需求：
- `software`：需要运行、交互、测试、发布的系统性产物
- `content`：主要给人读、讲、学的内容型产物，包含 `document / article / deck / course`
- `visual`：主要给人看、感受、呈现风格或导出的视觉型产物，包含 `visual / media`

第二层保留 subtype/format 语义，但不把它们提升为一级工作流路由主键。也就是说，`deck` 仍然存在，但它是 `content` 的子类；`media` 仍然存在，但它是 `visual` 的子类；`data` 暂不作为一级交付类型，而是延后到第二阶段再决定是 subtype 还是标签。

阶段上不重命名现有命令，只在语义层收敛成统一生产主线：
- `/refine`：Clarify + Converge
- `/design`：Direction
- `/plan`：Prepare
- `/build`：Produce
- `/review`：Improve Loop / formal gate
- `/ship`：Deliver

角色上不做大扩编，只补足当前真正断层的位置：
- 新增 `refine-content-scout`
- 新增 `review-content-auditor`
- 新增 `review-visual-auditor`
- 新增 `ship-artifact-export-auditor`

这 4 个新增 persona 均优先复用现有 skills，而不是同步发明一批新顶层 skill。`plan-content-reviewer` 不进入第一批；只有当内容型计划在 `/plan` 到 `/build` 的转换中持续暴露结构性问题时，再进入第二批。

## External References
- Search status: skipped
- Scan date: 2026-05-18
- Fact:
  - 当前 `artifact_type` 允许值仍是 `software / document / article / deck / visual`
  - 当前 `/review` 已接入 `verify-content-review` 和 `verify-visual-review`，但 Agent 列表仍以 software reviewers 为主
  - 当前 `/ship` 已接入 `ship-artifact-export`，但 ship audit persona 列表没有 export/artifact auditor
  - 当前 `/refine` 仅有 `refine-ceo-scout`、`refine-eng-scout`、`refine-design-scout`
  - 当前 `/plan` skill 已对 `content`、`deck`、`visual` 写了不同的切片规则
- Pattern:
  - 当前 repo 的真实问题更接近“有方法论 skill，但没有 persona 承接与阶段触发”，而不是“完全没有内容/视觉工作流”
  - stage-driven contract 已经稳定，适合在其上重写语义，而不是推翻命令层
- Inference:
  - 第一批改动应优先补 persona reachability，而不是新增大量平行顶层 skill
  - `content` 比 `visual` 更需要 refine 阶段的专属 scout，因为视觉前期至少部分被 design scout 覆盖，而内容前期完全缺一等视角
- Unknown:
  - `data` 最终应作为 `software` 的子类、`content` 的标签，还是保留为独立 subtype
  - `course` 是否在第一阶段就要显式进入 subtype 集合
- Adopt:
  - 采用一级 3 类模型：`software / content / visual`
  - 采用“先补 persona，再接现有 skill”的第一阶段策略
  - 采用“命令不改名，底层语义收敛”的阶段映射策略
- Reject:
  - 不采用当前 5 类并列模型作为长期目标
  - 不采用立即扩到 8 类一级类型并同步重写全管线
  - 不采用“新增岗位 = 新增顶层 skill”的一一对应扩编方式

## Scout Review Summary
- CEO:
  - Important: 需要抓住 80% 核心需求，不能为了理论完整性一次性引入过多一级类型和岗位
  - Suggestion: 第一阶段必须有清晰 MVP 和不做清单，避免变成长期无边界重构
- Eng:
  - Blocking: 不能让新增 persona 自己决定 skill 路由；必须维持 stage skill 为调度权威
  - Important: 优先复用现有 `verify-content-review`、`verify-visual-review`、`ship-artifact-export`
- Design:
  - Important: `deck` 与 `visual` 的视觉审查闭环必须显式化，否则“设计完成”和“可交付完成”仍会断开
- Blocking resolved:
  - 从“所有缺口都补新 skill”收敛为“先补 persona reachability + 复用现有 skill”
  - 从“5 类或 8 类并列 artifact_type”收敛为“3 个一级交付类型 + subtype/format”
- Important adopted:
  - 不在第一阶段引入 `plan-content-reviewer`
  - 不在第一阶段引入 `refine-visual-scout` 或 `refine-data-scout`
- Suggestions deferred:
  - `data` 与 `course` 的最终归属放到第二阶段

## 未选择的方案
- 方案 A：保留当前 5 类并列模型，只补几条路由规则
  - 放弃原因：能暂时修补，但无法消除“交付物 vs 实现介质”混层问题，后续还会反复讨论类型边界
- 方案 B：直接扩到 8 类一级类型，并同步改写全 pipeline
  - 放弃原因：复杂度过高，当前没有足够证据证明 `media / course / data` 需要在第一阶段就成为一级路由主键
- 方案 C：把所有内容最终都视为 software，只保留实现介质分类
  - 放弃原因：会丢掉 Unified 最重要的交付意图语义，导致 design/review/ship 的质量门退化

## 验收标准
- [ ] spec 明确一级交付类型、subtype/format 的分层关系
- [ ] spec 明确第一阶段新增 persona 清单与不新增 persona 清单
- [ ] spec 明确第一阶段只复用现有顶层 skills，不新增内容/视觉平行 skill 套件
- [ ] spec 明确现有命令层保留不变
- [ ] spec 明确 `AGENTS.md` 最终需要同步的项目级真相

## Risks and Mitigations
| 风险 | 概率 | 影响 | 应对方案 |
|------|------|------|---------|
| 3 类模型过于粗糙，后续 `data` 无法自然归位 | 中 | 中 | 第一阶段先不冻结 `data`，放入 deferred decision |
| 只补 persona 不补合同触发，新增岗位不可达 | 高 | 高 | 第一阶段实现必须同时改 `commands/review.md`、`commands/ship.md`、`define-workflow-refine` dispatch |
| `content` 与 `visual` 边界在 `deck` 上继续模糊 | 中 | 中 | 明确 `deck` 属于 `content`，并只在视觉层级或版式会影响结论时按需叠加 `visual` 审查 |
| `plan` 阶段内容视角仍有漏项 | 中 | 低 | 先观察第一阶段效果，再决定是否引入 `plan-content-reviewer` |

## Scope 边界
- **做:**
  - 收敛一级交付类型模型
  - 定义第一阶段新增 persona MVP
  - 规定哪些 persona 复用哪些现有 skill
  - 明确阶段命令与统一生产主线的语义映射
- **不做:**
  - 不在本 spec 中直接落地 8 类一级类型
  - 不在本 spec 中直接重写所有 skills、commands、router、agents
  - 不在本 spec 中决定 `data` 与 `course` 的最终长期位置
  - 不在本 spec 中加入第二批岗位（如 `plan-content-reviewer`）
