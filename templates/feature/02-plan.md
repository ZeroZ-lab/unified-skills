# <Feature Name> — Implementation Plan

## Artifact Type
artifact_type: software

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

| 子计划 | 状态 | Owner | Depends On | Write Scope | Verification Evidence |
|--------|------|-------|------------|-------------|-----------------------|
| `plans/01-contracts.md` | serial | main agent | none | `docs/features/<name>/contracts/` | 契约审查记录 |
| `plans/02-backend.md` | parallel_safe | backend agent | `plans/01-contracts.md` | `src/server/**`, `tests/server/**` | 后端测试结果 |
| `plans/03-frontend.md` | parallel_safe | frontend agent | `plans/01-contracts.md` | `src/ui/**`, `tests/ui/**` | 前端测试/截图 |

## Parallel Execution Matrix

| 子计划 A | 子计划 B | parallel_safe | 原因 |
|----------|----------|---------------|------|
| `plans/02-backend.md` | `plans/03-frontend.md` | yes | 契约已由 `01-contracts` 定义，Write Scope 不重叠 |
| `plans/01-contracts.md` | `plans/02-backend.md` | no | backend 依赖 contracts |

## Integration Order

1. 串行完成 contracts / schema / design / content / brand 等共享契约。
2. 并行执行所有 `parallel_safe` 子计划。
3. 主 agent 合并结果，检查 changed files 不冲突。
4. 运行全量验证。
5. 串行执行 release/export/ship 收口任务。

### Task N: <名称>
**文件:** 创建/修改/测试路径
**依赖:** Task N-1
- [ ] 验收标准: 明确本切片完成条件
- [ ] 生成/实现: 最小可验证产物
- [ ] 验证: software 跑测试；非 software 做内容/视觉/导出检查
- [ ] 调整: 根据验证结果修正
- [ ] COMMIT

---

# 子计划模板：docs/features/<name>/plans/NN-name.md

## Subplan Contract
- **Owner:** main agent / backend agent / frontend agent / content agent
- **Status:** serial / parallel_safe / gated
- **Depends On:** none
- **Write Scope:** `path/or/glob`
- **Read Scope:** `docs/features/YYYYMMDD-<name>/01-spec.md`, `docs/features/YYYYMMDD-<name>/02-plan.md`
- **Parallel Safety:** yes/no + 原因
- **Verification Evidence:** 测试命令、审查方式、截图、导出预览或人工确认
- **Merge Checkpoint:** 合并前必须满足的条件

## Tasks

### Task 1: <名称>
- [ ] 明确验收标准
- [ ] 生成/实现最小可验证产物
- [ ] 独立验证并记录证据
- [ ] 汇报 changed_files / artifact_paths / test_results
