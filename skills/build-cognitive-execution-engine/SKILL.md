---
name: build-cognitive-execution-engine
description: 任务执行引擎——选择正确的执行模式。当 plan 已批准需要写代码，或提到"执行""实现""编码"
---

# 执行引擎 — 3 种执行模式


## 入口/出口
- **入口**: `build-workflow-plan` 完成，任务列表已就绪
- **出口**: 所有任务完成 + 测试通过 + 代码合并
- **指向**: 全部任务完成后建议 `/review`
- **输出路径**: → verify-workflow-review
- **前置加载**: CANON.md + `build-quality-tdd/SKILL.md` + `build-workflow-execute/SKILL.md`

## 何时不使用
- 还没有批准的 plan 或任务列表
- 当前只是探索、诊断或写 spec/design，不进入实现
- 只有一个微小文档或配置改动，不需要选择执行模式

## 任务输入契约

执行引擎只消费 `/plan` 已批准的任务列表：**implement this plan task-by-task**。

- 每个 `### Task N` 是一个执行单元，必须有验收条件和验证证据。
- `plans/*.md` 子计划也是执行单元；子计划内部仍按 `### Task N` 逐项执行。
- 引擎可以选择 inline / subagent / parallel，但不能重新创建正式任务列表。
- 任何 subagent 输入都必须绑定一个明确的 `Task N` 或 `plans/*.md` 子计划。

## Agent Dispatch Contract

执行引擎选择执行模式时，也必须选择明确 persona；persona 选择不改变 Task N / Write Scope / Verification Evidence。

- Plan / mode selection → `agents/task-planner.md`
- Software implementation → `agents/software-engineer.md`
- API contract task → `agents/api-designer.md` first, then `agents/software-engineer.md`
- Data schema / migration task → `agents/data-architect.md` first, then `agents/software-engineer.md`
- Document / article task → `agents/content-writer.md`
- Deck task → `agents/content-writer.md` for narrative first, then `agents/visual-designer.md` for layout
- Visual task → `agents/visual-designer.md`

Mode B fan-out can use different personas in parallel only when their Write Scope does not overlap. Mode C implementer/reviewer prompts must name the selected persona and include its required skills, inputs, outputs, and scope.

## 三种执行模式

根据任务的性质（独立/依赖/复杂）选择对应模式：

```
任务到了
    │
    ├── 1-2 个简单任务，有依赖？ ────→ 模式 A: 直接执行
    ├── 2+ 个 parallel_safe 子计划或独立任务，无共享状态？ ──→ 模式 B: 并行 Fan-Out
    └── 多步骤、需审查、复杂？ ────────→ 模式 C: Subagent 流水线
```

### 模式 A: 直接执行

主 agent 按 `### Task N` 顺序执行每个任务。适用单文件修改、简单 bug 修复、配置变更。

**规则:**
- 实现 → 测试验证 → 记录/提交 → 下一个 Task N
- 当前 Task N 的验证证据未通过前，不进入下一个 Task N
- 每个任务 < 100 行变更
- 不要同时开多个实现分支

### 模式 B: 并行 Fan-Out

当面对 **2+ 个真正独立的 `Task N` 或 `plans/*.md` 子计划**（无共享文件、无共享状态、无顺序依赖），一次性分派。

**规则:**
- 一个消息分派所有 subagent（实现真正的并行）
- 每个 subagent 独立上下文，独立文件，独立结果
- 并行输入必须来自 `Parallel Execution Matrix` 中明确 `parallel_safe: yes` 的 task 或子计划
- 每个 subagent 只能修改所属子计划的 `Write Scope`
- 分派完 → 等结果 → 审查 → 合并

**禁止并行的情况:**
- 任务 B 依赖任务 A 的产出
- 两个任务修改同一文件
- 两个任务共享数据库 schema 变更
- 子计划缺少 `Write Scope`、`Verification Evidence` 或 `Merge Checkpoint`
- release/export/ship 收口子计划

### gated-parallel 输入

当 `Plan Topology` 是 `gated-parallel`：
1. 主 agent 先串行执行 contracts / gated / serial 子计划
2. 共享契约验证通过后，才分派依赖该契约的 `parallel_safe` 子计划
3. 如果契约变化，已分派的并行子计划全部作废，回到 `/plan` 或重新分派

**分派模板:**
```
Agent 1: 实现 Task X（只改 src/moduleA/）
Agent 2: 实现 Task Y（只改 src/moduleB/）
Agent 3: 实现 Task Z（只改 src/moduleC/）

约束: 每个只输出 JSON 最后一行，包含 status + changed_files + test_results
```

多计划分派模板：
```
Agent 1: 执行 docs/features/<name>/plans/02-backend.md
Write Scope: src/server/**, tests/server/**
Read Scope: 01-spec.md, 02-design.md（如适用）, 03-plan.md, plans/01-contracts.md
Verification Evidence: npm test -- server
Merge Checkpoint: changed_files 必须全部落在 Write Scope 内

Agent 2: 执行 docs/features/<name>/plans/03-frontend.md
Write Scope: src/ui/**, tests/ui/**
Read Scope: 01-spec.md, 02-design.md（如适用）, 03-plan.md, plans/01-contracts.md
Verification Evidence: npm test -- ui
Merge Checkpoint: changed_files 必须全部落在 Write Scope 内

约束: 每个 subagent 最后一行输出 JSON，包含 status + changed_files + test_results + artifact_paths
```

### 模式 C: Subagent 两阶段审查流水线

用于高复杂度任务（跨多个模块、涉及关键业务逻辑、需要安全审查）。采用 **两阶段审查：**

```
明确的 Task N 或 subplan 到达
    │
    ▼
分派 Implementer subagent（新鲜上下文）
    │
    ▼
Implementer 返回 → 报告 status + changed_files + test_results
    │
    ├── DONE → Phase 2
    ├── DONE_WITH_CONCERNS → 先解决关切问题再进入 Phase 2
    ├── NEEDS_CONTEXT → 提供更多上下文，重新实现
    └── BLOCKED → 人类介入
    │
    ▼
Phase 2: 分派 Spec Reviewer subagent（验证 spec 合规）
    │
    ├── SPEC_MATCH → 进入 Phase 3
    └── SPEC_GAP → 退回 Implementer 修正
    │
    ▼
Phase 3: 分派 Code Quality Reviewer subagent（五轴审查）
    │
    ├── APPROVED → 合并
    └── ISSUES → 退回 Implementer 修正
```

**关键规则:**
- Implementer 输入必须包含具体 `Task N` 或子计划路径、验收条件、Write Scope、Verification Evidence
- 每个 subagent **新鲜上下文** — 不传递前一个 subagent 的对话历史
- Spec Reviewer **不信任 Implementer 的报告** — 独立验证
- Code Quality Reviewer **必须等到 spec 合规确认后才开始** — 绝不提前审查不合规的代码
- **严禁**并行分派 Implementer → 并行实现产生合并冲突
- 审查阶段串行门控：先 Spec Reviewer，只有 `SPEC_MATCH` 后才分派 Code Quality Reviewer

**提示词模板:** 模式 C 分派时使用 `implementer-prompt.md`、`spec-reviewer-prompt.md`、`quality-reviewer-prompt.md`，并按当前任务填充 Task、scope、spec、验证证据和输出格式。

## Subagent 模型选择

| 复杂度 | 模型 | 适用 |
|--------|------|------|
| 低 | Haiku / 廉价模型 | 样板代码、格式变更、copy-paste 重构 |
| 中 | Sonnet / 标准模型 | 常规实现、CRUD、前端组件 |
| 高 | Opus / 能力最强模型 | 核心业务逻辑、复杂算法、安全关键代码 |

**原则:** 不省不该省的钱。Entity 关系重构用 Opus，改颜色变量用 Haiku。

## Fan-Out 合并模式

并行 agent 返回后：

```
Agent 1 结果 ─┐
Agent 2 结果 ─┤ → 主 Agent 审查
Agent 3 结果 ─┘
                    │
                    ├── 全部 DONE → 合并变更，跑全量测试
                    ├── 有失败 → 回退失败 agent 变更，重新分派
                    └── 有冲突 → 合并有效部分，手动处理冲突部分
```

**合并前必做:**
- [ ] 每个 agent 的测试通过
- [ ] 全量测试套件仍然通过（交叉影响检测）
- [ ] 无文件冲突（两个 agent 不该改同一文件）
- [ ] 每个 agent 绑定的 Task N / subplan 返回 DONE 或明确 BLOCKED
- [ ] 每个 agent 的 changed_files 都满足 `changed_files ⊆ Write Scope`
- [ ] 每个子计划的 Verification Evidence 和 Merge Checkpoint 已满足

## 何时不使用这些模式

- **不用模式 B** 当任务有顺序依赖或共享文件
- **不用模式 B** 当 `Parallel Execution Matrix` 没有证明 `parallel_safe`
- **不用模式 C** 当任务简单到 1 个 agent 20 分钟能完成 — 两阶段审查是复杂任务保险，不是流程税
- **不用 subagent 处理**需要实时人类确认的决策 — 主 agent 直接问

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "分派太慢，我直接写" | 1 个复杂任务 subagent 做 15 分钟 > 你猜 2 小时。并行 3 个独立任务 15 分钟 vs 串行 45 分钟。 | 主 agent 猜测实现 > 单次返工概率 30-50%，总耗时 2-3x subagent 流水线。 |
| "并行不会冲突" | 两个 agent 改同一文件 = 必定合并冲突。B 模式前提是文件不重叠。 | 并行写同一文件 → 合并冲突 → 手动解决 > 30 分钟/冲突，严重时需丢弃一个 agent 全部变更。 |
| "跳过审查，代码看起来对" | 两阶段审查正好用来防止"看起来对但不符 spec"的错误。 | 模式 C 无审查 → Implementer 偏离 spec → 主 agent 合入不合规代码 → 后续 review 才发现 → 返工 > 2x。 |
| "再分派一次也一样" | 第一次偏离 spec → 补约束 → 第二次才可能对。 | 不补约束重分派 → 同样的偏离 → 3 次循环后浪费 45+ 分钟且问题未解。 |

## 红旗 — STOP

- 没有明确 `Task N` 或子计划就分派 subagent
- 模式 B 任务之间不是真正独立的（有隐式依赖或共享文件）
- Subagent 报告 "DONE" 但没有 changed_files 列表
- Spec Reviewer 报告 SPEC_MATCH 但没提供独立验证证据
- 连续 3 次 Implementer 返回 ISSUES — 约束/任务描述可能有问题
- 两个并行 agent 在改同一文件 — 回退，串行化
- subagent 修改了 Write Scope 外文件 — 回退该 subagent 变更，重新分派或串行执行
- `parallel_safe` 不是来自 `Parallel Execution Matrix` 的显式结论 — 停止并行
- Code Quality Reviewer 发现了 Spec Reviewer 发现的问题 — 审查顺序错了
- Subagent 上下文加载不包含 spec 文档 — 它工作在盲区

## 验证清单

- [ ] 执行模式匹配任务性质（独立/依赖/复杂）
- [ ] 并行任务文件不重叠
- [ ] 多计划 fan-out 只使用 `parallel_safe` 子计划
- [ ] 每个执行单元绑定明确 `Task N` 或子计划
- [ ] 每个 subagent 有子计划路径、Write Scope、Read Scope、Verification Evidence、Merge Checkpoint
- [ ] changed_files 没有越过 Write Scope
- [ ] Subagent 流水线两阶段审查顺序正确
- [ ] 合并后全量测试通过
- [ ] 每个 subagent 有明确的约束和验收条件
- [ ] 没有"看起来 DONE 但没证据"的状态

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Implementer 返回 BLOCKED | 人类介入。不猜测阻塞原因，不静默跳过阻塞任务。 |
| Implementer 返回 NEEDS_CONTEXT | 提供更多上下文（spec、设计、相关代码），重新分派。不自行补充模糊上下文。 |
| Spec Reviewer 返回 SPEC_GAP | 退回 Implementer 修正。列出具体 gap，不笼统说"不符 spec"。 |
| Code Quality Reviewer 发现 Spec Reviewer 应发现的问题 | 审查顺序执行有误。STOP，重走 Spec Review → Quality Review 顺序。 |
| 连续 3 次 Implementer 返回 ISSUES | STOP。约束或任务描述有问题。回到 `/plan` 修补，不第四次分派相同输入。 |
| 并行 agent changed_files 越界 | 回退越界 agent 变更，降级串行或重新切分 Write Scope。 |
| 并行 agent 文件冲突 | 合并有效部分，冲突部分手动处理或串行重做。不强行合并。 |
| 全量测试在合并后失败 | 检查交叉影响。定位失败 agent，回退其变更，修复后重跑。 |

## 好坏示例

### Good — 模式 B 并行 fan-out

```markdown
Plan Topology: gated-parallel

Step 1: 串行执行 contracts 子计划（API schema + DB schema）
→ 验证: npm test -- schema → 全部通过

Step 2: 并行分派
Agent 1: 执行 plans/02-backend.md
  Write Scope: src/server/**, tests/server/**
  Verification: npm test -- server

Agent 2: 执行 plans/03-frontend.md
  Write Scope: src/ui/**, tests/ui/**
  Verification: npm test -- ui

→ 两个 agent 文件不重叠，测试各自通过
→ 合并后全量验证: npm test → 通过
```

### Bad — 盲目并行

```markdown
（看到 3 个 task，直接并行分派，不检查 Write Scope）

Agent 1: 实现 Task 1-3 → 改 src/api/auth.ts
Agent 2: 实现 Task 4-5 → 改 src/api/auth.ts

→ 问题: 两个 agent 改同一文件 → 合并冲突 → 需手动解决
→ 问题: 无 Parallel Execution Matrix → 并行无证据支撑
→ 问题: 无 Merge Checkpoint → 合并后无法验证交叉影响
```

## 输出模板

```markdown
### Execution Engine 交付记录

**执行模式**: [inline / subagent / parallel fan-out]
**任务来源**: [03-plan.md Task N / plans/*.md 子计划名]

**任务完成状态**:
| Task N | 状态 | changed_files | test_results | 验证证据 |
|--------|------|--------------|-------------|---------|
| [Task N] | DONE / BLOCKED / NEEDS_CONTEXT | [文件列表] | [通过/失败] | [描述] |

**并行结果**（如适用）:
- Agent 1: [status] — Write Scope: [范围] — changed_files ⊆ Write Scope ✓/✗
- Agent 2: [status] — Write Scope: [范围] — changed_files ⊆ Write Scope ✓/✗

**合并后全量验证**: [通过 / 失败 — 具体原因]
```
