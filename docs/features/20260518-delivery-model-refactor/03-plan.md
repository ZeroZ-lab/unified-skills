# 交付模型与角色管线重构 — Implementation Plan

> For execution: implement this plan task-by-task. Treat each `### Task N` block as one execution unit, and do not start the next task until the current task has passing verification evidence unless `Parallel Execution Matrix` explicitly proves `parallel_safe: yes`.

## Plan Status
- Status: approved
- Scope Size: M
- Risk Level: medium
- Project Doc Sync Plan Status: planned

## Artifact Type
artifact_type: software

## Inputs
- `docs/features/20260518-delivery-model-refactor/01-spec.md`

Design required: no. This feature is a workflow contract refactor, not a user-facing creative design task.

## Task Execution Rules

- `/plan` owns the task list; `/build` consumes it.
- Each `### Task N` must have files, dependencies, steps, and verification evidence.
- A task is done only when its own verification passes and evidence is recorded.
- Parallel execution is allowed only for tasks or subplans proven `parallel_safe: yes`.
- Missing task detail during `/build` is a `PLAN GAP`; return to `/plan` to repair it.

## Plan Topology
topology: serial

Rationale:
- This refactor changes project truth, stage dispatch, and skill contracts.
- The write scopes are small, but semantic dependencies are tight.
- Serial execution reduces contract drift risk while keeping each task bounded.

## 依赖顺序
```text
Task 1: 冻结一级模型与兼容合同
  ↓
Task 2: 新增缺失 persona 并更新 agent inventory
  ↓
Task 3: 接通 refine/review/ship 的阶段调度合同
  ↓
Task 4: 收口帮助入口、生成元数据并验证
```

## Subplans

无。保持单计划串行执行，避免在合同重构阶段引入额外子计划同步成本。

## Parallel Execution Matrix

| Task A | Task B | parallel_safe | 原因 |
|--------|--------|---------------|------|
| Task 2 | Task 3 | no | 虽然写入面大体分离，但 Task 3 需要引用 Task 2 中冻结的 persona 名称与职责，语义上不独立 |

## Integration Order

1. 先冻结一级交付模型、兼容映射和 AGENTS 真相。
2. 再新增 persona 文件与 inventory。
3. 再更新阶段技能和命令镜像，使 persona 变为可达。
4. 最后同步帮助入口、更新 `skills-lock.json` 等生成物并跑完整验证。

## Project Doc Sync Plan

- Must update:
  - `AGENTS.md`
- Optional update:
  - 无
- Stage owner:
  - Task 1 冻结项目级合同
- Verification method:
  - `04-review.md` 的 `Documentation Compliance`
  - `./validate`
  - 手工核对 `AGENTS.md` 与阶段技能/命令镜像一致
- Deferred docs with reason:
  - 无

## Plan Review Summary

- CEO:
  - Important: 先完成 3 类一级模型和 4 个 persona 的 MVP，不把 `data/course` 第二阶段问题提前实现
  - Suggestion: 保持命令层不变，避免让用户感知到一次性工作流改名
- Eng:
  - Blocking: 新增 persona 不能拥有独立路由权，必须由阶段 skill/command 消费
  - Important: Phase 1 采用兼容迁移，先收敛模型语义，不一次性替换所有 legacy `artifact_type` 消费点

### Task 1: 冻结一级交付模型与兼容合同

**Files:**
- Update: `AGENTS.md`
- Update: `templates/feature/01-spec.md`
- Update: `skills/define-workflow-refine/SKILL.md`
- Update: `skills/define-workflow-refine/refine-artifacts.md`

**依赖:** 无

- [ ] **Step 1: 在 `AGENTS.md` 写清 canonical model**
  - 定义一级交付类型为 `software / content / visual`
  - 定义 legacy `artifact_type` 到一级类型的兼容映射
  - 明确现有命令层保留，改变的是底层语义，不是 slash command 名称

- [ ] **Step 2: 更新 spec 模板与 refine 输出模板**
  - 让 `01-spec.md` 和 `refine-artifacts.md` 能表达一级类型与 subtype/format
  - 明确 Phase 1 的兼容写法，避免立即打破现有 feature 文档

- [ ] **Step 3: 更新 refine 主 skill**
  - 让 `define-workflow-refine` 的 artifact/delivery 说明与新合同一致
  - 为后续 content scout dispatch 预留明确输入字段

- [ ] **Step 4: 验证合同冻结结果**

Run:
```bash
rg -n "software / content / visual|content|visual|artifact_type|delivery_type" AGENTS.md templates/feature/01-spec.md skills/define-workflow-refine/SKILL.md skills/define-workflow-refine/refine-artifacts.md
```

Expected:
- `AGENTS.md` 明确写出 3 类 canonical model 与兼容映射
- refine/template surfaces 不再只把 `document/article/deck/visual` 当作并列一级语义

### Task 2: 新增缺失 persona 并更新 agent inventory

**Files:**
- Add: `agents/refine-content-scout.md`
- Add: `agents/review-content-auditor.md`
- Add: `agents/review-visual-auditor.md`
- Add: `agents/ship-artifact-export-auditor.md`
- Update: `agents/README.md`

**依赖:** Task 1

- [ ] **Step 1: 新建 4 个 persona 文件**
  - 每个 persona 只定义职责、输入、输出和边界
  - 不在 persona 内复制阶段路由合同

- [ ] **Step 2: 更新 `agents/README.md`**
  - 把 4 个新 persona 放入正确的阶段分组
  - 标明它们依赖的阶段技能，而不是写成独立路由入口

- [ ] **Step 3: 自查角色边界**
  - `review-content-auditor` 承接 `verify-content-review`
  - `review-visual-auditor` 承接 `verify-visual-review`
  - `ship-artifact-export-auditor` 承接 `ship-artifact-export`
  - `refine-content-scout` 不越权到 design/build/review

- [ ] **Step 4: 验证 persona reachability 准备就绪**

Run:
```bash
rg -n "refine-content-scout|review-content-auditor|review-visual-auditor|ship-artifact-export-auditor" agents/README.md agents/*.md
```

Expected:
- 4 个 persona 文件存在
- `agents/README.md` 中能找到对应职责与阶段位置

### Task 3: 接通 refine / review / ship 的阶段调度合同

**Files:**
- Update: `commands/refine.md`
- Update: `commands/review.md`
- Update: `commands/ship.md`
- Update: `skills/verify-workflow-review/SKILL.md`
- Update: `skills/ship-workflow-ship/SKILL.md`

**依赖:** Task 2

- [ ] **Step 1: 更新 refine 命令镜像**
  - 把 content 场景下的 scout 选择规则写进 `commands/refine.md`
  - 保持“stage skill 拥有调度权”的边界

- [ ] **Step 2: 更新 formal review 合同**
  - 在 `verify-workflow-review/SKILL.md` 和 `commands/review.md` 中让 `review-content-auditor` / `review-visual-auditor` 成为正式可达角色
  - 保持 software 两阶段审查硬门不变
  - 明确 `deck` 默认走 content review，并按需叠加 visual review

- [ ] **Step 3: 更新 ship 合同**
  - 在 `ship-workflow-ship/SKILL.md` 和 `commands/ship.md` 中让 `ship-artifact-export-auditor` 成为非 software 的正式 ship audit 角色
  - 保持 software 至少 `security + docs` 的最小审计规则不变

- [ ] **Step 4: 验证 stage dispatch 已真正接通**

Run:
```bash
rg -n "refine-content-scout|review-content-auditor|review-visual-auditor|ship-artifact-export-auditor" commands/refine.md commands/review.md commands/ship.md skills/verify-workflow-review/SKILL.md skills/ship-workflow-ship/SKILL.md
```

Expected:
- 4 个 persona 都被至少一个真实阶段技能或命令镜像消费
- 不存在只在 `agents/README.md` 提到、但阶段合同不可达的角色

### Task 4: 收口帮助入口、同步生成元数据并验证

**Files:**
- Update: `commands/help.md`
- Update: `skills/maintain-workflow-using-unified/skill-reference.md`
- Update: `skills-lock.json`
- Update: `docs/features/20260518-delivery-model-refactor/03-plan.md`（必要时仅补验证证据）

**依赖:** Task 3

- [ ] **Step 1: 同步帮助入口与运行时参考**
  - 更新 `commands/help.md` 中对交付类型和阶段语义的概览
  - 更新 `skill-reference.md`，确保 runtime 参考不和新合同冲突

- [ ] **Step 2: 刷新技能生成物**
  - 运行必要脚本/验证，刷新 `skills-lock.json`
  - 如果工具链导致其他生成物漂移，一并记录并评估是否属于本次范围

- [ ] **Step 3: 运行完整验证**

Run:
```bash
./validate
```

Expected:
- 通过所有 validate 检查
- 不出现 skills-lock 漂移
- 不出现 commands / skills / AGENTS 合同不一致

- [ ] **Step 4: 记录 build 入口验证故事**
  - 汇总 changed files、验证命令和任何遗留风险
  - 若 `./validate` 暴露新的合同缺口，回写本 plan 或进入修复
