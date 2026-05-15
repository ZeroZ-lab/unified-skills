---
description: 按计划增量生成产物（软件 TDD / 内容 / 视觉）+ ADR
---

# Command: /build

## Goal

Execute plan incrementally, generating artifact slices with continuous verification.

## Phases

### Phase 1: Load Plan and Select Execution Mode

**Agent:** task-planner
**Skills:** build-cognitive-execution-engine
**Input:** 03-plan.md（final）
**Process:**
1. 读取总控计划
2. 提取 `### Task N` task queue
3. 如有并行任务，读取 plans/*.md 子计划并提取子计划 task queue
4. 检查 Parallel Execution Matrix 的 parallel_safe 标记
5. 选择执行模式：inline / subagent / parallel
**Output:** task queue + 执行模式决策

### Phase 2: Task-by-task Build Loop

**Agent selection (by artifact_type):**
- software → software-engineer
- API contract task → api-designer first, then software-engineer
- schema/migration task → data-architect first, then software-engineer
- document/article → content-writer
- deck → content-writer + visual-designer
- visual → visual-designer
**Skills (loaded by Agent):**
- software-engineer: build-quality-tdd, build-infrastructure-git, build-backend-*, build-frontend-*（按 artifact_type / 风险 / UI 信号追加）
- content-writer: build-content-writing（document / article / deck）
- visual-designer: build-content-layout（document / deck / visual）
- Common: build-workflow-execute, build-cognitive-execution-engine
**Input:** 03-plan.md（final）+ 当前 Task N
**Process:**
1. implement this plan task-by-task：按 Task N 循环生成 → 验证 → 记录
2. 当前 Task N 未通过自身验证前，不进入下一个 Task N
3. 只有 Parallel Execution Matrix 证明 parallel_safe 时才并行
4. 遇到架构决策 → 写 ADR
5. 遇到 Bug → 进入调试
**Output:** 增量产物 + adr/*.md（如有）

### Phase 3: Final Verification

**Agent:** 主 session
**Skills:** verify-workflow-debug（如有 Bug）+ build-quality-tdd（完整测试）
**Input:** 所有 Task N 产出
**Output:** 完整产物
**Validation:**
- [ ] 所有 Task N 已完成
- [ ] 所有测试通过

---

## Entry Conditions
- [ ] 03-plan.md 存在且已批准
- [ ] 若 design required，则 02-design.md 存在且已批准
- [ ] artifact_type 已声明
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 所有任务已实现
- [ ] 所有计划 Task N 已完成并有验证证据
- [ ] 所有测试通过
- [ ] 产物完整

## Next Steps
- → /review

## Constitutional Rules
- CANON.md Clause 4: TDD Iron Law — 没有测试先失败的代码 = 不存在的代码
- CANON.md Clause 5: Verify Don't Assume — 没有刚运行的验证证据不能声称完成

## 实现

加载 CANON.md → 调用 skills/build-workflow-execute/SKILL.md。
