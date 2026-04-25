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
**Input:** 02-plan.md（final）
**Process:**
1. 读取总控计划
2. 如有并行任务，读取 plans/*.md 子计划
3. 检查 Parallel Execution Matrix 的 parallel_safe 标记
4. 选择执行模式：inline / subagent / parallel
**Output:** 执行模式决策

### Phase 2: Incremental Build (Loop)

**Agent selection (by artifact_type):**
- software → software-engineer
- document/article → content-writer
- deck → content-writer + visual-designer
- visual → visual-designer
**Skills (loaded by Agent):**
- software-engineer: build-quality-tdd, build-backend-*, build-frontend-*
- content-writer: build-content-writing
- visual-designer: build-content-layout
- Common: build-workflow-execute, build-cognitive-execution-engine
**Input:** 02-plan.md（final）+ 当前切片任务
**Process:**
1. 按切片循环：生成 → 验证 → 记录
2. 遇到架构决策 → 写 ADR
3. 遇到 Bug → 进入调试
**Output:** 增量产物 + adr/*.md（如有）

### Phase 3: Final Verification

**Agent:** 主 session
**Skills:** verify-workflow-debug（如有 Bug）+ build-quality-tdd（完整测试）
**Input:** 所有切片产出
**Output:** 完整产物
**Validation:**
- [ ] 所有任务已完成
- [ ] 所有测试通过

---

## Entry Conditions
- [ ] 02-plan.md 存在且已批准
- [ ] artifact_type 已声明
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 所有任务已实现
- [ ] 所有测试通过
- [ ] 产物完整

## Next Steps
- → /review

## Constitutional Rules
- CANON.md Clause 4: 不跳过测试（TDD Iron Law）
- CANON.md Clause 5: 每个切片都要可验证

## 实现

加载 CANON.md → 调用 .agents/skills/build/SKILL.md。
