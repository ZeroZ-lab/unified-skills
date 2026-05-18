------
name: define-workflow-refine
description: 从模糊想法变成明确的 spec。当有一个模糊的想法需要结构化收敛，或提到"提炼""收敛""需求""spec"
argument-hint: "[feature-name 或模糊想法]"
---

# Refine — 想法收敛

> 领域: workflow | 宪法: 第 1（Surface Assumptions）、第 8（Manage Confusion）条

## 入口/出口
- **入口**: 模糊想法、功能请求、用户"我想做 X"
- **出口**: `docs/features/YYYYMMDD-<name>/01-spec.md` + 用户批准
- **指向**: 完成后必须调用 `define-workflow-spec`
- **输出路径**: → define-workflow-spec
- **前置加载**: CANON.md
- **辅助参考**: `refine-artifacts.md`（Goal Review 评分表、External Scan 模板、Scout Output 模板、Spec One-Pager 模板、好坏示例）

## 何时不使用
- 需求已经清晰结构化，直接写 spec
- 打字错误/单行修复等琐碎变更

## 硬门

<HARD-GATE>
**在用户批准设计之前，禁止调用任何实现技能、写任何代码、创建任何项目脚手架。**
无论你认为功能多简单，这个门不跳过。"简单"正是最多未检查假设导致返工的地方。
</HARD-GATE>

## Agent Dispatch Contract

`/refine` 主执行 persona 是 `agents/requirements-analyst.md`。

- External Scan 可由独立 subagent 执行，但必须受本技能的 Fact / Pattern / Inference / Unknown / Adopt / Reject 输出合同约束
- Idea Scout Army 按 Phase 1.6 最少触发条件选择 `agents/refine-ceo-scout.md`、`agents/refine-eng-scout.md`、`agents/refine-design-scout.md`、`agents/refine-content-scout.md`
  - `artifact_type: software` → 默认 CEO + Eng；涉及 UI / 合规 → 加 Design
  - `artifact_type: document` / `article` → 默认 CEO + Content
  - `artifact_type: deck` → 默认 CEO + Content；涉及明显视觉/版式方向时加 Design
  - `artifact_type: visual` → 默认 CEO + Design
  - 小型变更 → 可跳过
- 未被选中的 scout 不产出占位反馈；所有已选 scout 的反馈由主 session 分级合并

## 核心锚点

### 5W1H Structured Clarification

逐一询问澄清问题，一次一个，不列清单。优先用结构化提问工具（如 `AskUserQuestion`）；不可用时退化为简短纯文本。

**执行规则：**
- 6 个必问维度：问题/背景、目标用户、成功标准、产物类型（runtime `artifact_type`，默认 `software`）、约束、上下文
- 当需求是在重构项目级工作流合同、角色矩阵或 pipeline 语义时，补充标记 canonical 一级交付类：`software` / `content` / `visual`
- 在问问题前先 Glob/Grep/Read 扫描项目上下文——引用具体文件，不在无知状态下提问

### External Scan Protocol

提出方案前，先判断是否需要搜索外部世界。使用当前宿主可用的 WebSearch/browser/文档检索。工具不可用时记录 "Search unavailable"。

**执行规则：**
- 默认执行：中大型功能、`artifact_type` 非 software、引入新依赖、用户问"有没有已有方案"
- 跳过：单文件修复、用户明确禁止联网、已有素材给出足够依据
- 输出必须分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject（模板见 `refine-artifacts.md`）
- 搜索结果不能直接变成需求；只有进入 Adopt 且和目标/约束一致的内容才能进入方案
- 超过 30 天的 Scan 结果标记 `[可能过时]`；按产物类型搜索目标见 `refine-artifacts.md`

### Scout Army Dispatch

Phase 1 完成后、提出方案前，并行分派 scout 验证可行性。

**执行规则：**
- 输入：用户澄清 + artifact_type +（如适用）canonical 一级交付类 + External Scan 摘要 + 项目上下文 + 不做/待确认边界
- 输出统一结构（模板见 `refine-artifacts.md`）：Verdict + Evidence + Findings + Spec Impact
- 反馈三级：Blocking（必须解决）、Important（不采纳需记录原因）、Suggestion（自主判断）

### Pressure Test Proposals

提出 2-3 种方案，每种含优点和代价。

**执行规则：**
- 每个方案测试三个维度：用户价值（止痛药还是维生素）、可行性（最难部分是什么）、差异化（和现有方案本质不同）
- 必须明示隐藏假设：赌什么是真的、什么会杀死方案、选择忽略什么及原因

## 流程

### Phase 1：理解与探索（发散）

**Step 1.1** 探索项目上下文（5W1H 锚点执行规则 2）

**Step 1.2** Scope 检查 — 多个独立子系统时先分解成子项目，只 refine 第一个

**Step 1.2.5** Goal Review — 评分维度和模板见 `refine-artifacts.md`。10-12 = accepted；7-9 = needs-refinement；0-6 = blocked。小型变更可 skip 但要有完成标准

**Step 1.3** 5W1H 澄清（锚点执行）

**Step 1.4** Phase 1.4：External Scan（锚点执行）

**Step 1.5**（可选）涉及 UI mockup/流程图时，单独一条消息询问是否用 browser 展示

**Step 1.6** Scout Army（锚点执行）

### Phase 2：方案与收敛

基于 Phase 1 全部输入，提出 2-3 种方案并 Pressure Test（锚点执行）。

### Phase 3：产出 spec

输出结构化 one-pager 到 `docs/features/YYYYMMDD-<name>/01-spec.md`。完整模板见 `refine-artifacts.md`。**"不做清单"是 spec 最有价值的部分之一。**

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 用户拒绝方向 | 问清原因，修正假设，回到 Phase 1 |
| 未能收敛到方案 | 扩大搜索范围或缩小目标范围 |
| 隐藏假设被推翻 | 更新假设集，评估影响，可能调整方向 |
| 发现已有类似方案 | 分析差别，确认需要新方案后才继续 |
| 范围暴增 | 分解为子项目，只 refine 第一个 |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "这个很简单不需要设计" | 简单项目正是未检查假设导致最多返工的地方。 | 跳过澄清的"简单"项目返工 3-5x |
| "先做一个方向看看" | 单方案无法比较 trade-off。 | 方向错误发现时修复成本 10-50x |
| "之后再加这些功能" | MVP 的范围定义就是专注。不做清单比做清单更重要。 | 需求膨胀 → 发布延期 2-4 周 |
| "别问了，直接做吧" | 跳过澄清的问题一定会回来。15 分钟澄清 > 15 小时返工。 | 假设在实现阶段暴露，每次推翻增加 4-8 小时 |

## 红旗

<HARD-GATE>
以下任何一个出现，立即停止并回到正确流程：

- 跳过"为谁做"直接开始设计
- 没有收敛到 2-3 个方案就跳到实现
- 没有问"之前有人试过吗"
- Goal Review Score 低于 10 仍继续进入 plan/build
- Done When 不可验证或缺少 Stop Conditions
- 没有明示隐藏假设
- 包含多个独立子系统时没有先分解
- yes-machine 模式：不质疑弱方案
- **在用户批准前写任何代码或调用实现技能**
</HARD-GATE>

## 验证清单

- [ ] "为谁、解决什么问题"已定义
- [ ] Goal Review 已完成或明确跳过（理由成立）
- [ ] artifact_type 已明确
- [ ] 如讨论长期工作流合同：canonical 一级交付类已明确
- [ ] External Scan 已完成/跳过/标记不可用，并记录原因
- [ ] 搜索结果已区分 Fact / Pattern / Inference / Unknown / Adopt / Reject
- [ ] 必要 scout 已分派并反馈已合并
- [ ] 探索了多个方向，不是只有第一个想法
- [ ] 隐藏假设已列出（含验证方案）
- [ ] "不做清单"让 trade-off 明确
- [ ] 产出是一份 spec 文件
- [ ] 用户批准了方向

## 输出模板

```markdown
# [功能名称] — Spec

artifact_type: [software/document/article/deck/visual]
delivery_class: [software/content/visual]  # 仅在需要表达长期项目真相时使用
Goal Review Score: [score]/12 | Status: [accepted/needs-refinement/blocked]
One-line Goal: [一句话]
Done When: [Functional + Technical + Regression + Output]
Stop Conditions: [停止条件]
External References: [Fact/Pattern/Inference/Unknown/Adopt/Reject]
核心假设: [假设 — 验证方式]
MVP 范围: Include [最小可验证] / Exclude [明确排除]
不做清单: [事项 — 理由]
```

完整模板和好坏示例见 `refine-artifacts.md`。
