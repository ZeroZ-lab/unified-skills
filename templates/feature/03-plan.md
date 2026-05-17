# <Feature Name> — Implementation Plan

> For execution: implement this plan task-by-task. Treat each `### Task N` block as one execution unit, and do not start the next task until the current task has passing verification evidence unless `Parallel Execution Matrix` explicitly proves `parallel_safe: yes`.

## Plan Status
- Status: draft / approved / blocked
- Scope Size: XS / S / M / L
- Risk Level: low / medium / high
- Project Doc Sync Plan Status: not-needed / planned / completed

## Artifact Type
artifact_type: software

## Inputs
- `docs/features/YYYYMMDD-<name>/01-spec.md`
- `docs/features/YYYYMMDD-<name>/02-design.md`（如果 design required）

## Task Execution Rules

- `/plan` owns the task list; `/build` consumes it.
- Each `### Task N` must have files, dependencies, steps, and verification evidence.
- A task is done only when its own verification passes and evidence is recorded.
- Parallel execution is allowed only for tasks or subplans proven `parallel_safe: yes`.
- Missing task detail during `/build` is a `PLAN GAP`; return to `/plan` to repair it.

## Plan Topology
topology: serial

可选值：
- `serial` — 只写本文件，按顺序执行
- `parallel` — 本文件为总控计划，另有 `plans/*.md` 子计划可并行
- `gated-parallel` — 先完成 contracts 子计划，再并行执行后续子计划

## 依赖顺序
```
Task 1（独立）
  ├── Task 2（依赖 1）
  └── Task 3（依赖 1，可与 2 并行）
Task 4（依赖 2 + 3）
```

## Subplans

小型任务可留空，只在本文件写任务。大型/并行任务使用：

| 子计划 | 状态 | Owner | Depends On | Write Scope | Shared Contracts | Cross-check Command | Verification Evidence |
|--------|------|-------|------------|-------------|------------------|---------------------|-----------------------|
| `plans/01-contracts.md` | serial | main agent | none | `docs/features/<name>/contracts/` | `API contract v1` | `n/a` | 契约审查记录 |
| `plans/02-backend.md` | parallel_safe | backend agent | `plans/01-contracts.md` | `src/server/**`, `tests/server/**` | `API contract v1`, `UserDTO` | `npm test -- backend-contract` | 后端测试结果 |
| `plans/03-frontend.md` | parallel_safe | frontend agent | `plans/01-contracts.md` | `src/ui/**`, `tests/ui/**` | `API contract v1`, `UserDTO` | `npm test -- frontend-contract` | 前端测试/截图 |

## Parallel Execution Matrix

| 子计划 A | 子计划 B | parallel_safe | 原因 |
|----------|----------|---------------|------|
| `plans/02-backend.md` | `plans/03-frontend.md` | yes | 契约已由 `01-contracts` 定义，Write Scope 不重叠，shared contract 可由 cross-check 独立验证 |
| `plans/01-contracts.md` | `plans/02-backend.md` | no | backend 依赖 contracts |

## Integration Order

1. 串行完成 contracts / schema / design / content / brand 等共享契约。
2. 并行执行所有 `parallel_safe` 子计划。
3. 主 agent 合并结果，检查 changed files 不冲突并运行 cross-check。
4. 运行全量验证。
5. 串行执行 release/export/ship 收口任务。

## Project Doc Sync Plan

- Must update:
  - `README.md`
- Optional update:
  - 无
- Stage owner:
  - Task N / phase name
- Verification method:
  - review checklist / validate rule / manual confirmation
- Deferred docs with reason:
  - 无

### Task N: <功能描述>

**Files:**
- Create: `src/path/to/file.ts`
- Test: `tests/path/to/test.ts`

**依赖:** Task N-1

- [ ] **Step 1: 写失败测试**

```typescript
test('描述预期行为', () => {
  // 测试 spec 中的验收标准
  const result = targetFunction(input);
  expect(result).toEqual(expected);
});
```

- [ ] **Step 2: 验证测试失败**

Run: `npm test -- --grep "描述预期行为"` → FAIL

- [ ] **Step 3: 写最小实现**

```typescript
function targetFunction(input: InputType): ReturnType {
  // 1. 验证输入（null/undefined/边界值）
  // 2. 执行核心逻辑（参考 spec / design / plan）
  // 3. 返回符合契约的结果格式
}
```

**说明:** 具体实现由执行 agent 根据 spec、design 和上下文推理。

- [ ] **Step 4: 验证测试通过**

Run: `npm test -- --grep "描述预期行为"` → PASS

- [ ] **Step 5: Commit**

```bash
git add src/path/to/file.ts tests/path/to/test.ts
git commit -m "feat: add <功能描述>"
```

---

# 子计划模板：docs/features/<name>/plans/NN-name.md

## Subplan Contract
- **Owner:** main agent / backend agent / frontend agent / content agent
- **Status:** serial / parallel_safe / gated
- **Depends On:** none
- **Write Scope:** `path/or/glob`
- **Read Scope:** `docs/features/YYYYMMDD-<name>/01-spec.md`, `docs/features/YYYYMMDD-<name>/03-plan.md`
- **Shared Contracts:** `types/api.ts`, `design tokens`, `feature flag semantics`
- **Global Invariants:** 登录态不丢失、响应 shape 不变化、导出分页不改变
- **Parallel Safety:** yes/no + 原因
- **Verification Evidence:** 测试命令、审查方式、截图、导出预览或人工确认
- **Cross-check Command:** `npm test -- contract-suite`
- **Semantic Independence Reason:** 为什么即使文件不重叠，语义上也不互相阻塞
- **Merge Checkpoint:** 合并前必须满足的条件

## Tasks

### Task 1: <名称>
- [ ] 明确验收标准
- [ ] 生成/实现最小可验证产物
- [ ] 独立验证并记录证据
- [ ] 汇报 changed_files / artifact_paths / test_results
