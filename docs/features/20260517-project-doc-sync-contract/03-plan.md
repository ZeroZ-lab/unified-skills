# Project Doc Sync Contract — Implementation Plan

> For execution: implement this plan task-by-task. Treat each `### Task N` block as one execution unit, and do not start the next task until the current task has passing verification evidence unless `Parallel Execution Matrix` explicitly proves `parallel_safe: yes`.

## Artifact Type
artifact_type: software

## Inputs
- `docs/features/20260517-project-doc-sync-contract/01-spec.md`
- `docs/features/20260517-project-doc-sync-contract/02-design.md`

## Task Execution Rules

- `/plan` owns the task list; `/build` consumes it.
- Each `### Task N` must have files, dependencies, steps, and verification evidence.
- A task is done only when its own verification passes and evidence is recorded.
- Parallel execution is allowed only for tasks or subplans proven `parallel_safe: yes`.
- Missing task detail during `/build` is a `PLAN GAP`; return to `/plan` to repair it.

## Plan Status
- Status: draft
- Scope Size: medium
- Risk Level: medium
- Plan Review Requirement: CEO + Eng；design review by current session because this is documentation IA work, not UI

## Scope Summary
- 把“skills 运行工作流时如何生成文档”的规则正式接入仓库合同
- 修改 feature workflow 模板，使 project doc sync 成为显式字段
- 修改关键阶段技能，使 `/refine`、`/plan`、`/review`、`/ship` 知道何时要求同步项目级文档
- 增加验证，拦截“spec 要求同步 project docs 但实现未兑现”的合同漂移

## Assumptions
- 先采用固定 markdown 标题/字段，不引入 frontmatter/schema
- `docs/architecture/*` 本轮先定义最小固定文件集合和映射规则，不强制一次性补全文档骨架
- `CHANGELOG.md` 本轮先按“user-visible change 或 release 相关变更需要明确状态”处理，不在此轮彻底重写 release policy
- 现有 `docs/features/...` 主产物链、`docs/bugs/...` 结构和 `DESIGN.md` 项目级定位保持不变

## Plan Topology
topology: serial

选择 `serial` 的原因：
- 多个目标文件共享同一份合同语言，存在高耦合
- `AGENTS.md`、skills、templates、validate 必须按同一语义逐步收口
- 验证逻辑依赖前面文档和模板先稳定，不能提前并行落地

## 依赖顺序
```text
Task 1: Root contract + doc architecture truth
  ↓
Task 2: Feature workflow templates
  ↓
Task 3: Stage skills and documentation skill
  ↓
Task 4: Validation and negative-case coverage
  ↓
Task 5: Final review, sync check, and validate
```

## Subplans

本任务保持单计划执行，不拆 `plans/*.md`。原因：
- 写入范围重叠
- 每一步都依赖前一步的合同措辞
- 验证要在整体收口后统一执行

## Parallel Execution Matrix

不适用。所有主要写入面存在共享合同和共享验证语义，`parallel_safe: no`。

## Integration Order

1. 先收口根合同和文档层级真相，避免后续技能引用漂移。
2. 再更新 feature 模板，让产物骨架先稳定。
3. 再修改阶段技能，把模板字段和工作流职责接上。
4. 最后补验证和负例检查，确保合同能被机器和 reviewer 共同执行。
5. 全量验证后再进入 `/review`。

## Project Doc Sync Plan
- Must update:
  - `AGENTS.md`
  - `templates/feature/01-spec.md`
  - `templates/feature/03-plan.md`
  - `skills/define-workflow-spec/SKILL.md`
  - `skills/build-workflow-plan/SKILL.md`
  - `skills/verify-workflow-review/SKILL.md`
  - `skills/ship-workflow-ship/SKILL.md`
  - `skills/reflect-team-documentation/SKILL.md`
  - `validate` and/or supporting validation scripts/tests
- Optional update:
  - `docs/README.md` if docs layering wording needs sync
  - `templates/feature/02-design.md` if we decide to align its enterprise summary block in the same pass
- Stage owner:
  - Contract truth: Task 1
  - Feature templates: Task 2
  - Workflow skills: Task 3
  - Validation: Task 4
  - Final sync confirmation: Task 5
- Verification method:
  - Diff inspection for all required files
  - `./validate`
  - Negative-path evidence: a case where `project_truth_changed: yes` without synced docs is caught by validation or review logic
- Deferred docs with reason:
  - `docs/architecture/*.md` concrete prose bodies can stay deferred; this feature only needs path mapping and contract support, not full content authoring

## Task Table

| Task N | 标题 | 文件数 | 验收条件 | 验证命令 | 依赖 |
|--------|------|-------|---------|---------|------|
| 1 | 收口根合同与文档槽位真相 | 2-3 | `AGENTS.md` 明确 doc slots、project doc sync 触发与阶段责任 | `rg -n "doc_intent|project docs|feature docs|Documentation Impact|Project Doc Sync"` AGENTS.md docs/README.md | 无 |
| 2 | 升级 feature 模板到企业级骨架 | 2-4 | `01-spec.md`、`03-plan.md` 至少包含新增字段和摘要块；必要时同步 `02-design.md` | `rg -n "Documentation Impact|Project Doc Sync Plan|Owner / Date / Status|Plan Status"` templates/feature/*.md | Task 1 |
| 3 | 把文档同步合同接入阶段技能 | 5-6 | spec/plan/review/ship/documentation 技能都知道何时记录、检查、收口 project doc sync | `rg -n "doc_intent|affected_project_docs|Documentation Compliance|Documentation Sync|project_truth_changed" skills/*/SKILL.md` | Task 2 |
| 4 | 增加验证与负例覆盖 | 2-5 | `./validate` 或相关 tests 能拦截至少一种文档同步漂移负例 | `./validate` and targeted `scripts/tests/*` command(s) added/updated in this task | Task 3 |
| 5 | 全量收口、自审与证据确认 | 3-6 | 计划要求的文件已更新，验证全绿，project doc sync 状态在 feature chain 中自洽 | `./validate` plus `git diff --stat` and targeted grep checks | Task 4 |

## Verification Checkpoints

### Checkpoint A — Contract Truth Locked
在 Task 1 结束后确认：
- `AGENTS.md` 已定义四类文档槽位
- `AGENTS.md` 已说明默认 `feature_only` 与 project-doc trigger 规则
- 根合同与 `docs/README.md` 不冲突

### Checkpoint B — Templates Ready
在 Task 2 结束后确认：
- `templates/feature/01-spec.md` 有 `Documentation Impact`
- `templates/feature/03-plan.md` 有 `Project Doc Sync Plan`
- 如有同步 `02-design.md`，不引入实现步骤

### Checkpoint C — Stage Contract Connected
在 Task 3 结束后确认：
- `/refine` 负责记录 doc intent
- `/plan` 负责规划 doc sync owner 与 verification
- `/review` 负责检查兑现
- `/ship` 负责最终收口
- documentation skill 解释 project-level docs 的职责边界

### Checkpoint D — Validation Gate Works
在 Task 4 结束后确认：
- 至少一个负例会失败
- 正常路径不被误伤
- 无需手工记忆即可发现明显漂移

### Checkpoint E — Release-Ready Review Input
在 Task 5 结束后确认：
- `./validate` 通过
- 变更范围与 spec/design 一致
- 可以进入 `/review`

### Task 1: 收口根合同与文档槽位真相

**Files:**
- Update: `AGENTS.md`
- Update: `docs/README.md` (only if wording conflict exists)

**依赖:** 无

- [ ] **Step 1: 对齐 `AGENTS.md` 与 spec/design 的文档分层语言**
  - 明确 `root docs` / `project docs` / `feature docs` / `bug docs`
  - 明确默认 `feature_only`，以及何时触发 project-level sync

- [ ] **Step 2: 把阶段责任写入根合同**
  - `/refine` 记录 `doc_intent`
  - `/plan` 生成 `Project Doc Sync Plan`
  - `/review` / `/ship` 负责检查和收口

- [ ] **Step 3: 处理根文档冲突**
  - 检查 `docs/README.md` 是否需要同步 wording
  - 如无冲突，不额外改动

- [ ] **Step 4: 验证根合同已可 grep 到核心字段**

**Verification Evidence**
- Run: `rg -n "doc_intent|feature_only|feature docs|project docs|Project Doc Sync Plan|Documentation Compliance" AGENTS.md docs/README.md`
- Expect: 新合同术语与阶段责任都能被定位到

### Task 2: 升级 feature 模板到企业级骨架

**Files:**
- Update: `templates/feature/01-spec.md`
- Update: `templates/feature/03-plan.md`
- Optional: `templates/feature/02-design.md`

**依赖:** Task 1

- [ ] **Step 1: 升级 `01-spec.md`**
  - 加首屏摘要和 `Documentation Impact`
  - 加 `doc_intent` / `project_truth_changed` / `affected_project_docs`

- [ ] **Step 2: 升级 `03-plan.md`**
  - 加 plan summary block
  - 加 `Project Doc Sync Plan`

- [ ] **Step 3: 评估是否顺手升级 `02-design.md`**
  - 仅在不扩 scope 的前提下，让其 summary block 更贴近 enterprise pattern

- [ ] **Step 4: 校验模板没有把实现逻辑写死**

**Verification Evidence**
- Run: `rg -n "Documentation Impact|doc_intent|project_truth_changed|Project Doc Sync Plan|Deferred docs with reason" templates/feature/01-spec.md templates/feature/03-plan.md templates/feature/02-design.md`
- Expect: 新字段存在，且模板仍然是结构指导而非完整实现

### Task 3: 把文档同步合同接入阶段技能

**Files:**
- Update: `skills/define-workflow-spec/SKILL.md`
- Update: `skills/build-workflow-plan/SKILL.md`
- Update: `skills/verify-workflow-review/SKILL.md`
- Update: `skills/ship-workflow-ship/SKILL.md`
- Update: `skills/reflect-team-documentation/SKILL.md`
- Optional: `skills/design-workflow-design/SKILL.md`

**依赖:** Task 2

- [ ] **Step 1: 更新 spec 技能**
  - 要求 `Documentation Impact`
  - 要求声明 `doc_intent`

- [ ] **Step 2: 更新 plan 技能**
  - 要求 `Project Doc Sync Plan`
  - 要求写 owner / verification / deferred reason

- [ ] **Step 3: 更新 review 技能**
  - 把 `Documentation Compliance` 纳入必须检查项
  - 明确 spec 说要同步但未兑现时的失败语义

- [ ] **Step 4: 更新 ship 和 documentation 技能**
  - ship 负责最终文档同步状态
  - documentation skill 解释 project-level docs 的长期职责与最小集合

- [ ] **Step 5: 如有必要，补 design 技能一句边界**
  - 只同步 `DESIGN.md`，不替代其他 project doc sync 逻辑

**Verification Evidence**
- Run: `rg -n "Documentation Impact|Project Doc Sync Plan|Documentation Compliance|Documentation Sync|project_truth_changed|affected_project_docs" skills/define-workflow-spec/SKILL.md skills/build-workflow-plan/SKILL.md skills/verify-workflow-review/SKILL.md skills/ship-workflow-ship/SKILL.md skills/reflect-team-documentation/SKILL.md skills/design-workflow-design/SKILL.md`
- Expect: 每个阶段都有清晰职责，且术语一致

### Task 4: 增加验证与负例覆盖

**Files:**
- Update: `validate`
- Update/Add: `scripts/tests/*` relevant validation tests
- Optional: supporting scripts touched by validate

**依赖:** Task 3

- [ ] **Step 1: 确定最小可执行校验**
  - 例如检查 spec 模板字段存在
  - 检查 review/ship 模板字段存在
  - 检查 required sync 情况下的负例逻辑

- [ ] **Step 2: 落地一个负例**
  - 构造或复用 fixture，证明 `project_truth_changed: yes` 但缺少同步信息时会失败

- [ ] **Step 3: 补对应测试脚本或 validate 分支**

- [ ] **Step 4: 跑验证，确保正反路径都合理**

**Verification Evidence**
- Run: `./validate`
- Run: task-specific test command(s) added in `scripts/tests/*`
- Expect: 新规则能拦截漂移，且不会无差别误报

### Task 5: 全量收口、自审与证据确认

**Files:**
- Review all files touched in Tasks 1-4
- Update any lock/index files only if required by actual skill file changes and repo rules

**依赖:** Task 4

- [ ] **Step 1: 检查技能改动是否需要同步 lock/index**
  - 按仓库规则处理 `skills-lock.json`、`skills-index.json`

- [ ] **Step 2: 运行全量验证**
  - `./validate`

- [ ] **Step 3: 做文档合同自审**
  - spec → plan → review → ship 的 project doc sync 链路是否闭合
  - 根合同、技能、模板、验证术语是否一致

- [ ] **Step 4: 生成进入 `/review` 所需证据**
  - 列出 changed files
  - 列出验证结果
  - 标注任何 deferred item

**Verification Evidence**
- Run: `./validate`
- Run: `git diff --stat`
- Run: `rg -n "doc_intent|project_truth_changed|Documentation Impact|Project Doc Sync Plan|Documentation Compliance|Documentation Sync" AGENTS.md templates/feature/*.md skills/*/SKILL.md`
- Expect: 合同术语贯通、验证通过、无漏同步关键文件

## Plan Self-Check
- [x] Spec 覆盖：每条 spec 需求在任务中有归属
- [x] 占位符扫描：无 TBD/TODO/"implement later"
- [x] 类型一致性：所有任务围绕同一合同术语
- [x] Subplans 完整：本计划不拆 subplans，理由明确
- [x] 并行安全：已明确本次不并行
- [x] 收口顺序：验证和最终收口在最后
- [x] 任务独立性：每个任务有验收条件、验证步骤、依赖
- [x] 验证完整性：每个任务有命令和预期
- [x] 代码示例风格：未提前给出完整实现
- [x] 任务粒度：标题无 "and"，单任务职责明确

## User Approval
- Status: 待批准
