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

- 每个 `### Task N` 是一个执行单元，必须有验收条件和验证证据
- `plans/*.md` 子计划也是执行单元；子计划内部仍按 `### Task N` 逐项执行
- 引擎可以选择 inline / subagent / parallel，但不能重新创建正式任务列表
- 任何 subagent 输入都必须绑定一个明确的 `Task N` 或 `plans/*.md` 子计划

## Agent Dispatch Contract

执行引擎选择执行模式时，也必须选择明确 persona；persona 选择不改变 Task N / Write Scope / Verification Evidence。

- Plan / mode selection → `agents/task-planner.md`
- Software implementation → `agents/software-engineer.md`
- API contract task → `agents/api-designer.md` first, then `agents/software-engineer.md`
- Data schema / migration task → `agents/data-architect.md` first, then `agents/software-engineer.md`
- Document / article task → `agents/content-writer.md`
- Deck task → `agents/content-writer.md` for narrative first, then `agents/visual-designer.md` for layout
- Visual task → `agents/visual-designer.md`

Mode B fan-out can use different personas in parallel only when their Write Scope does not overlap and semantic independence is explicit. Mode C implementer/reviewer prompts must name the selected persona and include its required skills, inputs, outputs, and scope.

## 三种执行模式

### 模式 A: 直接执行

主 agent 按 `### Task N` 顺序执行。适用单文件修改、简单 bug 修复、配置变更。

规则：实现 → 测试验证 → 记录/提交 → 下一个 Task N。当前 Task N 验证未通过前不进入下一个。每个任务 < 100 行变更。不要同时开多个实现分支。

### 模式 B: 并行 Fan-Out

面对 2+ 个真正独立的 `Task N` 或 `plans/*.md` 子计划（无共享文件、无共享状态、无顺序依赖），一次性分派。

**规则：**
- 一个消息分派所有 subagent（真正并行）
- 每个 subagent 独立上下文、独立文件、独立结果
- 并行输入必须来自 `Parallel Execution Matrix` 中明确 `parallel_safe: yes` 的 task 或子计划
- 每个 subagent 只能修改所属子计划的 `Write Scope`
- 分派完 → 等结果 → 审查 → 合并

**禁止并行：** 任务有依赖关系、修改同一文件、共享 DB schema 变更、共享 API/type/flag/config/test 契约未冻结、子计划缺 Write Scope / Verification Evidence / Merge Checkpoint / Cross-check Command / Semantic Independence Reason、release/export/ship 收口子计划。

### gated-parallel

当 `Plan Topology` 是 `gated-parallel`：主 agent 先串行执行 contracts/gated/serial 子计划 → 共享契约验证通过 → 才分派依赖该契约的 `parallel_safe` 子计划。契约变化时已分派子计划全部作废。

**分派模板：** 每个 subagent 必须指定 Write Scope、Read Scope、Shared Contracts、Global Invariants、Verification Evidence、Cross-check Command、Merge Checkpoint。最后一行输出 JSON 包含 status + changed_files + test_results + artifact_paths。

### 模式 C: Subagent Pre-Review Gate 流水线

用于高复杂度任务（跨多模块、关键业务逻辑、需安全审查）。

**流程：** Implementer subagent → 返回 status → Spec Gate subagent（独立验证）→ Code Quality Gate subagent（五轴审查）。

**定位：** 这是 build 阶段的内部保险丝，不是 formal `/review`。通过此 gate 只表示“允许继续集成 / 进入正式审查候选”，不表示“已经完成正式审查”。

**关键规则：**
- Implementer 输入必须包含具体 Task N / 子计划路径、验收条件、Write Scope、Verification Evidence
- 每个 subagent 新鲜上下文 — 不传递前一个 subagent 对话历史
- Spec Gate 不信任 Implementer 报告 — 独立验证
- Code Quality Gate 必须等 spec 合规确认后才开始
- 严禁并行分派 Implementer
- 审查阶段串行门控：先 Spec Gate，SPEC_MATCH 后才分派 Code Quality Gate
- Mode C 结果不得写成 APPROVED / LGTM / READY TO MERGE；formal `/review` 仍需单独产出 `04-review.md`

**提示词模板：** 使用 `implementer-prompt.md`、`spec-reviewer-prompt.md`、`quality-reviewer-prompt.md`。

## Subagent 模型选择

| 复杂度 | 模型 | 适用 |
|--------|------|------|
| 低 | Haiku / 廉价模型 | 样板代码、格式变更、copy-paste 重构 |
| 中 | Sonnet / 标准模型 | 常规实现、CRUD、前端组件 |
| 高 | Opus / 能力最强模型 | 核心业务逻辑、复杂算法、安全关键代码 |

**原则：** 不省不该省的钱。Entity 关系重构用 Opus，改颜色变量用 Haiku。

## Fan-Out 合并

并行 agent 返回后：全部 DONE → 合并变更 + 跑全量测试；有失败 → 回退失败 agent 变更 + 重新分派；有冲突 → 合并有效部分 + 手动处理冲突。

**合并前必做：**
- [ ] 每个 agent 测试通过
- [ ] 全量测试套件通过（交叉影响检测）
- [ ] 每个子计划的 `Cross-check Command` 已运行并通过
- [ ] 无文件冲突
- [ ] 每个 agent 绑定的 Task N 返回 DONE 或 BLOCKED
- [ ] changed_files ⊆ Write Scope
- [ ] Verification Evidence 和 Merge Checkpoint 已满足

## 何时不使用这些模式

- 不用模式 B 当任务有顺序依赖/共享文件，或 `Parallel Execution Matrix` 没有证明 `parallel_safe`
- 不用模式 C 当任务简单到 1 个 agent 20 分钟能完成 — 两阶段审查是复杂任务保险，不是流程税
- 不用 subagent 处理需要实时人类确认的决策 — 主 agent 直接问

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "分派太慢，我直接写" | 1 个复杂任务 subagent 做 15min > 你猜 2h。并行 3 个 15min vs 串行 45min。 | 主 agent 猜测实现 > 单次返工 30-50%，总耗时 2-3x |
| "并行不会冲突" | 两个 agent 改同一文件 = 必定合并冲突。 | 合并冲突手动解决 > 30min/冲突，严重时丢弃一个 agent 全部变更 |
| "build 里已经审过了，不用 /review" | Mode C 只是 pre-review gate，不能替代 formal `/review`。 | 缺少独立 formal review → 合并质量门失效 → 返工和漏检风险叠加 |
| "跳过审查，代码看起来对" | 两阶段审查防止"看起来对但不符 spec"的错误。 | 无审查 → Implementer 偏离 spec → 合入不合规代码 → 返工 > 2x |
| "再分派一次也一样" | 第一次偏离 → 补约束 → 第二次才可能对。 | 不补约束重分派 → 同样偏离 → 3 次循环浪费 45+ min |

## 红旗 — STOP

- 没有明确 `Task N` 或子计划就分派 subagent
- 模式 B 任务之间不是真正独立的（隐式依赖或共享文件）
- Subagent 报告 "DONE" 但没有 changed_files 列表
- Spec Gate 报告 SPEC_MATCH 但没提供独立验证证据
- 连续 3 次 Implementer 返回 ISSUES — 约束/任务描述可能有问题
- 两个并行 agent 在改同一文件 — 回退，串行化
- subagent 修改了 Write Scope 外文件 — 回退变更，重新分派或串行执行
- `parallel_safe` 不是来自 `Parallel Execution Matrix` 的显式结论 — 停止并行
- 子计划缺 `Cross-check Command` 或 `Semantic Independence Reason` 却被标为 `parallel_safe`
- Code Quality Gate 发现了 Spec Gate 应发现的问题 — 审查顺序错了
- Subagent 上下文不包含 spec 文档 — 盲区工作

## 验证清单

- [ ] 执行模式匹配任务性质（独立/依赖/复杂）
- [ ] 并行任务文件不重叠
- [ ] 并行任务的共享契约、全局不变量和语义独立性已显式记录
- [ ] 多计划 fan-out 只使用 `parallel_safe` 子计划
- [ ] 每个执行单元绑定明确 `Task N` 或子计划
- [ ] 每个 subagent 有子计划路径、Write Scope、Read Scope、Verification Evidence、Merge Checkpoint、Cross-check Command
- [ ] changed_files 没有越过 Write Scope
- [ ] 两阶段审查顺序正确
- [ ] 合并后全量测试通过
- [ ] 没有"看起来 DONE 但没证据"的状态

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Implementer 返回 BLOCKED | 人类介入。不猜测原因，不静默跳过 |
| Implementer 返回 NEEDS_CONTEXT | 提供更多上下文，重新分派 |
| Spec Gate 返回 SPEC_GAP | 退回 Implementer 修正，列出具体 gap |
| Code Quality Gate 发现 Spec Gate 应发现的问题 | STOP，重走 Spec → Quality 顺序 |
| 连续 3 次 Implementer 返回 ISSUES | STOP。回到 `/plan` 修补，不第四次分派 |
| 并行 agent changed_files 越界 | 回退越界 agent，降级串行或重切 Write Scope |
| 并行 agent 文件冲突 | 合并有效部分，冲突部分串行重做 |
| Cross-check Command 失败 | 视为语义耦合未被控制，回退相关并行结果并降级串行 |
| 全量测试合并后失败 | 定位失败 agent，回退其变更，修复后重跑 |

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

**Cross-check 结果**: [命令 + PASS/FAIL]
**合并后全量验证**: [通过 / 失败 — 具体原因]
```
