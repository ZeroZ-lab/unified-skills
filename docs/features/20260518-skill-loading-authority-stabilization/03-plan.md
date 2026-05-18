# Skill 加载权与 Agent 调度权稳定化 — Implementation Plan

> For execution: implement this plan task-by-task. Treat each `### Task N` block as one execution unit, and do not start the next task until the current task has passing verification evidence unless `Parallel Execution Matrix` explicitly proves `parallel_safe: yes`.

## Plan Status
- Status: approved
- Scope Size: S
- Risk Level: medium
- Project Doc Sync Plan Status: planned

## Artifact Type
artifact_type: software

## Inputs
- `docs/features/20260518-skill-loading-authority-stabilization/01-spec.md`

Design required: no. This feature is a workflow-contract clarification, not a user-facing design task.

## Task Execution Rules

- `/plan` owns the task list; `/build` consumes it.
- Each `### Task N` must have files, dependencies, steps, and verification evidence.
- A task is done only when its own verification passes and evidence is recorded.
- Parallel execution is allowed only for tasks or subplans proven `parallel_safe: yes`.
- Missing task detail during `/build` is a `PLAN GAP`; return to `/plan` to repair it.

## Plan Topology
topology: serial

Rationale:
- This feature changes project truth about routing authority.
- The file count is small, but semantic coupling is high.
- Serial execution reduces wording drift between project contract, runtime contract, and agent docs.

## 依赖顺序
```text
Task 1: 冻结唯一合法加载链路与类型解释顺序
  ↓
Task 2: 去掉 agent 文档里的伪加载语义
  ↓
Task 3: 同步帮助/运行时参考并验证
```

## Subplans

无。保持单计划串行执行。

## Parallel Execution Matrix

| Task A | Task B | parallel_safe | 原因 |
|--------|--------|---------------|------|
| Task 1 | Task 2 | no | Task 2 需要消费 Task 1 冻结后的标准术语 |
| Task 2 | Task 3 | no | Task 3 需要基于最终文案做帮助与运行时同步 |

## Integration Order

1. 先在 `AGENTS.md` 和 Unified runtime 合同中写死唯一合法加载链路。
2. 再统一 agent 文档表述，去掉“agent 自己加载 skills”的误导。
3. 最后同步帮助/运行时参考、刷新锁文件并跑完整验证。

## Project Doc Sync Plan

- Must update:
  - `AGENTS.md`
- Optional update:
  - `commands/help.md`
- Stage owner:
  - Task 1 收口 `AGENTS.md`
  - Task 3 收口帮助与运行时参考
- Verification method:
  - `04-review.md` 的 `Documentation Compliance`
  - `./validate`
  - 手工检查是否还能读出第二条伪加载链路
- Deferred docs with reason:
  - 无

## Plan Review Summary

- CEO:
  - Important: 先锁死加载权模型，不继续扩写更多 persona 或 artifact 范围
- Eng:
  - Blocking: agent 不能拥有 self-load / self-route 权；必须由 stage skill 消费 persona
  - Important: `artifact_type -> delivery_class` 的顺序必须写进 runtime 合同，而不只是项目级说明

### Task 1: 冻结唯一合法加载链路与类型解释顺序

**Files:**
- Update: `AGENTS.md`
- Update: `skills/maintain-workflow-using-unified/SKILL.md`
- Update: `skills/maintain-workflow-using-unified/skill-reference.md`

**依赖:** 无

- [ ] **Step 1: 在 `AGENTS.md` 写死唯一合法链路**
  - 明确 `skills` 加载权属于 `router / command / stage skill`
  - 明确 `agent persona` 只有执行权，没有 self-load / self-route / self-expand-scope 权
  - 用简短拓扑或规则表描述 `router -> stage skill -> current agent or persona -> merge`

- [ ] **Step 2: 在 Unified runtime 合同写死解释顺序**
  - 先解析 runtime `artifact_type`
  - 再映射 canonical `delivery_class`
  - 前者用于实际路由，后者用于角色矩阵和 pipeline 语义解释

- [ ] **Step 3: 验证唯一链路已可读**

Run:
```bash
rg -n "加载权|self-load|self-route|artifact_type|delivery_class|router -> stage skill" AGENTS.md skills/maintain-workflow-using-unified/SKILL.md skills/maintain-workflow-using-unified/skill-reference.md
```

Expected:
- `AGENTS.md` 能单独说明唯一合法链路
- runtime 合同能单独说明类型解释顺序

### Task 2: 去掉 agent 文档里的伪加载语义

**Files:**
- Update: `agents/content-writer.md`
- Update: `agents/visual-designer.md`
- Update: 其他仍使用“加载的 Skills”或等价误导表述的 `agents/*.md`

**依赖:** Task 1

- [ ] **Step 1: 统一章节名**
  - 把“加载的 Skills”改成“依赖的阶段技能上下文”或等价稳定表述
  - 明确这些 skill 由 stage workflow 预先加载或授权，不表示 agent 自主选择

- [ ] **Step 2: 去掉自路由暗示**
  - 确认 agent 文件没有暗示自己可追加 stage skill
  - 保留“典型消费上下文”信息，但不写成运行时调度入口

- [ ] **Step 3: 验证 agent 文档不再伪装成路由器**

Run:
```bash
rg -n "加载的 Skills|依赖的阶段技能上下文|自主加载|self-load|self-route" agents/*.md
```

Expected:
- 不再出现“加载的 Skills”作为 agent 自主动作的表述
- agent 文档明确依赖的是 stage context，而不是自有加载权

### Task 3: 同步帮助/运行时参考并验证

**Files:**
- Update: `commands/help.md`
- Update: `skills-lock.json`

**依赖:** Task 2

- [ ] **Step 1: 如有必要，在 `commands/help.md` 补一行唯一合法链路**
  - 帮助入口只需要高层表达，不重复整套合同
  - 若已有信息足够，可记录为 no-op

- [ ] **Step 2: 刷新技能锁文件**
  - 对改动过的 skill 运行 `scripts/update-lock.sh`
  - 保证 `skills-lock.json` 不漂移

- [ ] **Step 3: 运行完整验证**

Run:
```bash
./validate
```

Expected:
- 通过所有 validate 检查
- 不出现 skills-lock 漂移
- 不出现 agent contract 或 runtime contract 负向测试失败

- [ ] **Step 4: 记录残余风险**
  - 如果仍有双重真相，只允许留在第二阶段 deferred list，不允许继续混在主合同里
