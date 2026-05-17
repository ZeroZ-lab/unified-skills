------
name: build-workflow-execute
description: 按计划增量生成软件或内容产物。当 plan 已批准需要开始实现，或提到"实现""编码""开始做"
argument-hint: "[artifact-type] [--parallel-safe]"
---

# Execute — 增量生成


## 入口/出口
- **入口**: 已批准 plan（`docs/features/<name>/03-plan.md` + 可选 `docs/features/<name>/plans/*.md`）
- **出口**: 软件代码或内容产物 + 验证证据 + ADR（如有决策）
- **指向**: 完成 → `verify-workflow-review`；遇到 Bug → `verify-workflow-debug`
- **输出路径**: → verify-workflow-review
- **前置加载**: CANON.md + `build-quality-tdd/SKILL.md` + `build-cognitive-execution-engine/SKILL.md`

## 何时不使用
- 探索性原型（标注 `// UNTESTED` 可跳过 TDD，但受 HARD GATE 约束）
- 纯配置变更（加环境变量、改 CI 配置）— 直接提交，不需要增量循环

## 前置
先读取计划拓扑，再调用 `build-cognitive-execution-engine` 选择执行模式。

读取顺序：
1. 读取 `docs/features/<name>/03-plan.md` 总控计划
2. 如果存在 `docs/features/<name>/plans/*.md`，按文件编号逐份读取子计划
3. 从总控计划确认 `Plan Topology`、`Subplans`、`Parallel Execution Matrix`、`Integration Order`
4. 验证每个子计划都有 `Write Scope`、`Read Scope`、`Shared Contracts`、`Global Invariants`、`Parallel Safety`、`Verification Evidence`、`Cross-check Command`、`Merge Checkpoint`

## Task-by-task Execution Contract

For execution: **implement this plan task-by-task**.

- `03-plan.md` 中每个 `### Task N` 是 `/build` 的最小执行单元。
- `plans/*.md` 中每个 `### Task N` 是该子计划内的最小执行单元。
- 当前 Task N 的验证步骤未通过前，不进入下一个 Task N。
- 只有 `Parallel Execution Matrix` 明确证明 `parallel_safe: yes` 时，才允许并行执行多个 task 或 subplan。
- `/build` 不重新创建任务列表。执行中发现任务缺失、验收标准缺失或切片无法执行时，记录 `PLAN GAP`，必要时回到 `/plan` 修补。
- build 阶段任何 pre-review / implementation gate 结果只用于内部质量门，不能替代 formal `/review`

执行模式：
- **inline** — 当前会话直接执行
- **subagent** — 每任务或每个复杂子计划一个新 subagent + 两阶段审查
- **parallel** — 仅对 `parallel_safe` 子计划并行 subagent

没有 `Parallel Execution Matrix` 或没有 `parallel_safe` 证据时，降级为 `serial` 执行。降级原因必须写入 build 记录。

## Agent Dispatch Contract

`/build` 的主流程由本技能和 `build-cognitive-execution-engine` 控制；persona 只在被阶段技能选中后执行对应 Task N 或子计划。

- `agents/task-planner.md`：只用于读取计划、提取 task queue、检查 Parallel Execution Matrix 和选择 inline / subagent / parallel；不得在 `/build` 中重写正式任务列表。
- `agents/software-engineer.md`：`artifact_type: software` 的默认 implementer，执行 TDD、实现和验证。
- `agents/api-designer.md`：当 Task N 是 API 契约、endpoint shape、request/response/error contract 或版本策略时先执行；输出契约后交给 `software-engineer` 实现。
- `agents/data-architect.md`：当 Task N 涉及 schema、migration、索引、约束或数据迁移策略时先执行；输出数据契约后交给 `software-engineer` 实现。
- `agents/content-writer.md`：`document` / `article` / `deck` 的内容切片 implementer。
- `agents/visual-designer.md`：`visual` 和 `deck` 的版式/视觉切片 implementer；deck 必须等 `content-writer` 完成叙事骨架后再进入 layout。
- 并行分派只允许给 `Parallel Execution Matrix` 证明 `parallel_safe` 的 Task N 或子计划；每个 persona 的 changed_files 必须落在 Write Scope 内，并满足 `Shared Contracts` / `Global Invariants` / `Cross-check Command` 合同。

再读取 spec 的 `artifact_type`，按需加载领域技能：
- `software`（默认）→ 确认 `02-design.md` 已批准；加载 `build-quality-tdd` + 按子领域加载 `build-frontend-*` / `build-backend-api-design` / `build-backend-database` / `build-backend-service-patterns`
- `document` / `article` → 加载 `build-content-writing`；涉及版式时加载 `build-content-layout`
- `deck` → **先** `build-content-writing` 完成叙事骨架 → **再** `build-content-layout` 做视觉层级。顺序执行，不并行。
- `visual` → 加载 `build-content-layout`，涉及文案时加载 `build-content-writing`

## Plan Topology 执行规则

### `serial`
按 `### Task N` 顺序直接执行。存在 `plans/*.md` 时按文件编号顺序执行子计划，每个子计划内按 Task N 顺序。不分派并行 subagent。

### `gated-parallel`
1. 先串行执行 `contracts` / `serial` / `gated` 子计划
2. 验证共享契约通过（API、schema、design、content、brand 或导出规格已稳定）
3. 确认 Write Scope 不重叠、共享契约已冻结后，调用 `build-cognitive-execution-engine` fan-out
4. 并行子计划全部完成并通过验证后，先运行各自 `Cross-check Command`，再按 `Integration Order` 串行合并和全量验证

### `parallel`
fan-out 必须同时满足：`Parallel Execution Matrix` 列出 `parallel_safe: yes`、依赖已完成、有明确 Write Scope、任意两个子计划 Write Scope 不重叠、共享契约已冻结、全局不变量可被 `Cross-check Command` 独立验证。

不满足时：缺 Write Scope / Cross-check Command / Semantic Independence Reason → STOP 回 `/plan`；共享写入 → 降级串行；release/export/ship 标 `parallel_safe` → STOP 收口任务必须串行；共享契约未完成 → 按 `gated-parallel` 先执行契约。

## 增量循环

```
每个 Task N：实现 → 测试 → 验证 → 记录/提交 → 下一个 Task N
```

### Step 1：选切片策略
- **计划拓扑优先** — `03-plan.md` 定义了拓扑时按拓扑执行
- **Task-by-task 优先** — 计划已列出 `### Task N` 时按 task queue 执行，不合并
- **垂直切片（推荐）** — 一次建一条完整路径（DB + API + UI）
- **风险优先切片** — 最难/最不确定的部分先做
- **契约优先切片** — 先定接口契约，前后端并行

### Step 2-4：实现 → 测试 → 验证
- **Step 2**：实现让测试通过的最小代码。不提前抽象、不加未要求的功能。
- **Step 3**：每个切片后跑对应验证。`software` 先 TDD（`build-quality-tdd`）；`document/article` 事实核查 + 逻辑链 + 语气；`deck` 叙事线 + 信息密度 + speaker notes；`visual` 视觉层级 + 对齐 + 对比度。
- **Step 4**：`software` 测试通过 + 构建成功 + 类型检查 + Lint + 新功能按预期；非软件产物 review 证据齐全 + 导出物能打开且符合 spec。

### Step 5：提交
用描述性信息提交。一个提交一个逻辑变更。

### Step 6：循环
进入下一个切片，不要重新开始。多计划模式下循环单位是子计划：子计划内按任务切片循环；结束时记录 changed_files / artifact_paths / test_results；主 agent 按 `Integration Order` 合并并跑全量验证。

## 任务偏离处理

- **阻塞（外部依赖缺失）** → 记录阻塞项，跳过当前切片，切到下一个独立切片
- **技术障碍** → STOP。调用 `build-cognitive-decision-record` 记录问题，执行备选方案
- **PLAN GAP** → STOP。记录缺口，回到 `/plan` 修补，不在 build 中创建新任务
- **scope creep** → 记录为 "NOTED"，不移出当前任务范围
- **预计耗时翻倍** → 和用户沟通

## 纪律规则

### Rule 0：Simple First（YAGNI + Rule of Three）
写任何代码前问："最简单的能工作的方法是什么？"三个相似的代码行 > 一个过早的抽象。第三次使用场景出现前不建抽象。

### Rule 0.5：Scope Discipline
只改该改的。看到值得改进但不相关的内容 → 记录 `NOTICED BUT NOT TOUCHING`，不改。不改相邻代码、不重构未改文件的 import、不删不理解的内容。

### Rule 1-3
1. 一个提交 = 一个逻辑变更。不混重构和新功能。
2. 每个切片后项目必须能构建，已有测试必须通过。
3. 不完整功能用 feature flag（`process.env.FEATURE_X === 'true'`）隔离。

### Rule 4-5
4. 新代码默认保守行为，opt-in 而非 opt-out。
5. 新增文件容易回滚；修改最小化；migration 要有 rollback；删除和替换不在同一个提交。

## 遇到架构决策 → 写 ADR
调用 `build-cognitive-decision-record/SKILL.md`，产出到 `docs/features/<name>/adr/<num>-<title>.md`。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 测试失败 | 新代码 → 修复直到通过；已有测试 → 检查回归并修复 |
| 构建失败 | 检查错误信息，修复编译/类型错误，不跳过 |
| 检查点门未通过 | STOP。标记未通过项 → 回到对应任务修复 → 重新运行检查点 → 全部绿色才继续 |
| 子计划缺 Write Scope / Cross-check Command / Semantic Independence Reason | STOP。不能分派 subagent，回到 `/plan` 修补 |
| PLAN GAP | STOP。记录缺口，回到 `/plan` 修补 |
| 两个 parallel_safe 子计划写同一路径 | 降级串行或回到 `/plan` 重新切分 |
| shared contract / global invariant cross-check 失败 | 降级串行，必要时回到 `/plan` 重切分 |
| release/export/ship 标 parallel_safe | STOP。收口任务必须串行 |
| 切片比预期复杂 | 评估分解。预计耗时翻倍时与用户沟通 |
| 架构决策阻塞 | 停止实现，记录 ADR，执行备选方案 |
| Scope creep | 记录为 "NOTED"，不移出当前范围 |

## 验证证据

输出或记录必须包含：
- **输入/来源**: 读取的 spec、plan、代码、反馈或发布上下文
- **执行动作**: 实际完成的检查、生成、修复、导出或发布步骤
- **验证结果**: 命令、审查结论、产物路径、截图或人工确认
- **阻塞/回退**: 未通过项、回退路径或需要 human partner 决策的问题

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "先写代码，测试最后一起跑" | Bug 叠加。切片 1 的 bug 让切片 2-5 都错。 | Bug 延迟发现 → 定位成本线性增长 → 5 切片叠加 ≥ 4h，vs 每切片 < 5min |
| "一次做完更快" | 感觉更快直到 500 行改了之后找不到哪行出的问题。 | 大提交出错回退范围 = 全部；小提交回退范围 = 最后一个切片，差距 10-50x |
| "这个改动太小不需要单独提交" | 小提交没成本。大提交隐藏 bug 并让回滚困难。 | 混合提交回退行为变更 → 格式化也丢失 → 额外 30-60 分钟 |
| "之后加 feature flag" | 功能不完整就不暴露给用户。现在加 flag。 | 无 flag → 出问题只能回滚整个部署 → 全部用户受影响 vs flag 关闭 < 1min |
| "顺便重构一下" | 重构混在新功能里让审查和回滚都更难。 | 混合提交无法独立 revert 重构 → 丢失格式化改进 |

## 红旗
- 写了超过 100 行还没有跑测试
- 一个切片里包含多个不相关的变更
- 未读取 `plans/*.md` 就开始执行多计划任务
- 跳过 `### Task N` 顺序，按自己理解重组任务
- 在 `/build` 中临时创建新的正式任务列表
- 没有 `Parallel Execution Matrix` 却并行分派 subagent
- subagent 修改超出子计划 Write Scope 的文件
- `parallel_safe` 子计划之间出现 changed_files 冲突
- "让我快速加这个" scope 膨胀
- 跳过测试/验证以加快速度
- 切片之间构建失败或测试中断
- 累积大量未提交变更
- 在第三个使用场景出现前就建抽象
- 为一次性操作建工具文件

## 验证清单

每个切片后：
- [ ] 当前 `### Task N` 的验证步骤已通过
- [ ] 变更做了一件事且做完整了
- [ ] 所有测试通过
- [ ] 构建成功
- [ ] 类型检查通过
- [ ] Lint 通过
- [ ] 新功能按预期工作
- [ ] 已用描述性信息提交

多计划任务额外检查：
- [ ] 已读取 `03-plan.md` 和所有 `plans/*.md`
- [ ] `Plan Topology` 已决定执行模式
- [ ] 每个子计划内的 `### Task N` 已逐项完成并记录证据
- [ ] `Parallel Execution Matrix` 支持所有 fan-out 决策
- [ ] 每个并行子计划的 `Cross-check Command` 已通过
- [ ] 每个 subagent 的 changed_files 没有越过 Write Scope
- [ ] 合并后全量验证通过

## 好坏示例

### Good — 增量切片 + TDD
Task 1: 用户注册 API → RED（写失败测试）→ GREEN（最小实现让测试通过）→ Commit（`feat: add user registration endpoint`）。一个逻辑变更，描述性信息。

### Bad — 大批量 + 跳过测试
一次性写 500 行包含注册、登录、任务创建、列表查询 → 无测试 Bug 叠加 → 单次提交包含 4 功能回滚丢全部 → 无 feature flag 注册失败时全部暴露 → 无垂直切片任何一步阻塞后续全卡。

## 输出模板

```markdown
### Build Execute 交付记录

**Plan 来源**: [03-plan.md / plans/*.md 子计划名]
**执行模式**: [inline / subagent / parallel]
**artifact_type**: [software / document / article / deck / visual]

**Task 完成状态**:
| Task N | 实现描述 | 测试结果 | 验证证据 | 提交 SHA |
|--------|---------|---------|---------|---------|
| Task 1 | [描述] | PASS / FAIL | [证据] | [SHA] |

**PLAN GAP**（如有）: [缺口描述 + 处理方式]
**ADR**（如有）: [adr/<num>-<title>.md 路径]
**合并后全量验证**: [通过 / 失败]
```
