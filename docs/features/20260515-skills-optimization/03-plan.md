# Skills 全量优化 — Implementation Plan

> For execution: implement this plan task-by-task. Treat each `### Task N` block as one execution unit, and do not start the next task until the current task has passing verification evidence unless `Parallel Execution Matrix` explicitly proves `parallel_safe: yes`.

## Artifact Type
artifact_type: software

## Inputs
- `docs/features/20260515-skills-optimization/01-spec.md`
- `docs/features/20260515-skills-optimization/00-brainstorm.md`

## Task Execution Rules

- `/plan` owns the task list; `/build` consumes it.
- Each `### Task N` must have files, dependencies, steps, and verification evidence.
- A task is done only when its own verification passes and evidence is recorded.
- Parallel execution is allowed only for tasks or subplans proven `parallel_safe: yes`.
- Missing task detail during `/build` is a `PLAN GAP`; return to `/plan` to repair it.
- 每个技能优化遵循固定流程: 评分 → 识别缺口 → 编辑 → `update-lock.sh` → `./validate`。

## Plan Topology
topology: serial

Phase 间严格串行（Phase 0 → 1 → 2 → 3 → 4）。Phase 内同批次技能可串行执行（共享 skills-lock.json）。

## 依赖顺序
```
Phase 0: 基础设施 + 全量评分（独立）
  ├── Task 0.1: update-lock.sh 脚本
  └── Task 0.2: 五轴评分 + 热力图
Phase 1: Tier 1 骨架技能（依赖 Phase 0）
  ├── Task 1.1-1.4: define + design 阶段技能
  ├── Task 1.5-1.7: build 阶段技能
  ├── Task 1.8: verify 阶段技能
  ├── Task 1.9: ship 阶段技能
  └── Task 1.10-1.12: maintain 阶段技能
  Checkpoint: Tier 1 全量验证
Phase 2: Tier 2 强纪律技能（依赖 Phase 1）
  ├── Task 2.1-2.6: build + verify 技能
  ├── Task 2.7-2.9: ship 技能
  └── Task 2.10: verify 收尾技能
  Checkpoint: Tier 2 全量验证
Phase 3: Tier 3 专项技能（依赖 Phase 2）
  ├── Task 3.1-3.3: build 后端技能
  ├── Task 3.4-3.5: build 认知技能
  ├── Task 3.6-3.7: build 内容 + 前端技能
  ├── Task 3.8-3.10: design 技能
  ├── Task 3.11-3.13: maintain + reflect 技能
  └── Task 3.14: ship 技能
  Checkpoint: Tier 3 全量验证
Phase 4: 黄金标准提取 + validate 扩展（依赖 Phase 3）
```

## Subplans

| 子计划 | 状态 | Owner | Depends On | Write Scope | Verification Evidence |
|--------|------|-------|------------|-------------|-----------------------|
| `plans/01-phase0-infra.md` | serial | main agent | none | `scripts/update-lock.sh`, `docs/features/20260515-skills-optimization/scoring/` | 脚本测试通过 + 评分热力图 |
| `plans/02-phase1-tier1.md` | serial | main agent | `plans/01-phase0-infra.md` | `skills/define-*/`, `skills/design-*/`, `skills/build-workflow-*/`, `skills/build-cognitive-execution-engine/`, `skills/verify-workflow-review/`, `skills/ship-workflow-ship/`, `skills/maintain-workflow-*/` | validate + spot-check |
| `plans/03-phase2-tier2.md` | serial | main agent | `plans/02-phase1-tier1.md` | `skills/build-quality-*/`, `skills/build-infrastructure-*/`, `skills/build-frontend-*/`, `skills/verify-quality-*/`, `skills/verify-frontend-*/`, `skills/verify-team-*/`, `skills/verify-content-*/`, `skills/verify-visual-*/`, `skills/verify-workflow-debug/`, `skills/verify-workflow-spec-compliance/`, `skills/verify-workflow-receiving-review/`, `skills/ship-infrastructure-*/`, `skills/ship-workflow-canary/`, `skills/ship-workflow-land/` | validate + spot-check |
| `plans/04-phase3-tier3.md` | serial | main agent | `plans/03-phase2-tier2.md` | `skills/build-backend-*/`, `skills/build-cognitive-*/`, `skills/build-content-*/`, `skills/build-frontend-*/`, `skills/design-content-*/`, `skills/design-experience-*/`, `skills/design-interactive-*/`, `skills/design-visual-*/`, `skills/maintain-infrastructure-*/`, `skills/maintain-team-*/`, `skills/maintain-workflow-learn/`, `skills/maintain-workflow-goal/`, `skills/reflect-*/`, `skills/ship-artifact-*/`, `skills/ship-workflow-doc-sync/` | validate + spot-check |
| `plans/05-phase4-golden.md` | serial | main agent | `plans/04-phase3-tier3.md` | `validate`（可选）, `docs/features/20260515-skills-optimization/` | validate + 全量评分表 |

## Parallel Execution Matrix

所有子计划串行执行（共享 `skills-lock.json` 和 `skills-index.json`，写入范围在 phase 边界互不重叠但全局状态文件需要串行更新）。

| 子计划 A | 子计划 B | parallel_safe | 原因 |
|----------|----------|---------------|------|
| Phase 0 | Phase 1 | no | Phase 1 依赖评分结果 |
| Phase 1 | Phase 2 | no | 共享 skills-lock.json，validate 需要前序通过 |
| Phase 2 | Phase 3 | no | 同上 |
| Phase 3 | Phase 4 | no | Phase 4 依赖全量优化完成 |

## Integration Order

1. 串行完成 Phase 0（基础设施 + 评分）。
2. 串行完成 Phase 1（Tier 1 骨架技能），checkpoint 验证。
3. 串行完成 Phase 2（Tier 2 强纪律技能），checkpoint 验证。
4. 串行完成 Phase 3（Tier 3 专项技能），checkpoint 验证。
5. 串行完成 Phase 4（黄金标准提取），最终验证。

## 单技能优化流程（所有 Phase 内任务共用）

每个技能优化任务遵循以下步骤：

```
1. 读取 SKILL.md + 辅助文件
2. 对照五轴评分标准打分（0-3 每轴）
3. 识别低于 3 分的轴和具体缺口
4. 编辑 SKILL.md（和/或辅助文件）补齐缺口
5. 运行 bash scripts/update-lock.sh <skill-name>
6. 运行 ./validate
7. 重新评分确认 ≥3/3
8. 记录验证证据
```

### 五轴缺口修复模式

| 缺口轴 | 修复动作 |
|--------|---------|
| 可操作性 < 3 | 每个步骤补充: 行为描述（动词开头）+ 检查点（可验证的输出）+ 代码/配置/输出示例 |
| 示例充足性 < 3 | 补充好/坏对比示例（标记 Good/Bad）+ 输出模板（markdown 代码块） |
| 行为收敛性 < 3 | 红旗改为可检测条件（非形容词）+ 补充 STOP 后动作 + 补充验证失败处理表 |
| 跨技能衔接 < 3 | 补充: 加载前提（`假设已加载`字段）+ 产出路径（文件路径）+ 下游技能指向 |
| 说辞表质量 < 3 | 补充: 现实列 + 具体后果列（可量化则量化，不可量化则定性场景描述）|

---

## Phase 0: 基础设施 + 全量评分

### Task 0.1: 创建哈希同步脚本

**Files:**
- Create: `scripts/update-lock.sh`

**依赖:** none

- [ ] **Step 1: 创建 `scripts/update-lock.sh`**

脚本功能：
1. 接受参数 `<skill-name>`（如 `build-quality-tdd`）
2. 计算 `skills/<skill-name>/SKILL.md` 的 SHA-256
3. 计算 `skills/<skill-name>/` 下所有辅助 `.md` 文件的 SHA-256
4. 更新 `skills-lock.json` 中对应条目的 `computedHash` 和 `auxiliaryHashes`
5. 输出更新确认

脚本要求：
- 必须可执行（`chmod +x`）
- 必须校验技能目录存在
- 必须校验 skills-lock.json 中有对应条目
- 必须在更新前备份旧哈希（输出到 stdout）

- [ ] **Step 2: 测试脚本**

对 `build-quality-tdd`（有辅助文件 `examples.md`）和 `define-workflow-refine`（有辅助文件 `refine-artifacts.md`）运行脚本，验证：
1. SHA-256 计算正确（手动 `shasum -a 256` 对比）
2. `skills-lock.json` 更新后 `./validate` 仍然通过（未修改文件时哈希不变）

Run: `bash scripts/update-lock.sh build-quality-tdd && ./validate` → PASS

- [ ] **Step 3: Commit**

```bash
git add scripts/update-lock.sh
git commit -m "feat: add scripts/update-lock.sh for skill hash sync"
```

---

### Task 0.2: 五轴评分全量技能

**Files:**
- Create: `docs/features/20260515-skills-optimization/scoring/heatmap.md`
- Create: `docs/features/20260515-skills-optimization/scoring/scores.md`

**依赖:** Task 0.1

- [ ] **Step 1: 评分所有 55 个 SKILL.md + 13 个辅助文件**

逐个读取每个 `skills/*/SKILL.md`，对照五轴评分标准打分。输出格式：

```markdown
| 技能 | 可操作性 | 示例充足性 | 行为收敛性 | 跨技能衔接 | 说辞表质量 | 总分 | 辅助文件同步 |
|------|---------|-----------|-----------|-----------|-----------|------|------------|
| build-quality-tdd | 3 | 3 | 3 | 3 | 3 | 15/15 | examples.md: 3/3 |
| design-content-direction | 1 | 0 | 1 | 2 | 1 | 5/15 | n/a |
```

评分时注意：
- 可操作性: 每个步骤必须有动词 + 可检查输出 + 示例才给 3 分
- 示例充足性: 必须有好/坏对比 + 输出模板才给 3 分
- 行为收敛性: 红旗可检测 + STOP 后动作 + 验证失败处理表才给 3 分
- 跨技能衔接: 入口/出口 + 加载前提 + 产出路径才给 3 分
- 说辞表质量: 说辞 + 现实 + 具体后果才给 3 分

辅助文件评分：与主 SKILL.md 质量是否同步，是否被主文件引用。

- [ ] **Step 2: 生成热力图**

产出按 Tier 分组的热力图，标注每个轴低于 3 的具体缺口描述。

- [ ] **Step 3: 确定优化优先级**

按 Tier 内总分从低到高排序，确定每个 Tier 内的优化顺序。

- [ ] **验证**

评分表覆盖全部 55 个技能 + 13 个辅助文件。无遗漏。

---

## Phase 0 Checkpoint

- [ ] `scripts/update-lock.sh` 可执行且测试通过
- [ ] 55 个技能五轴评分完成，评分表已产出
- [ ] 热力图已生成，优化优先级已确定
- [ ] `./validate` 通过

---

Phase 1-4 的详细任务在子计划中定义：

- `plans/01-phase0-infra.md` — Task 0.1-0.2（上方已展开）
- `plans/02-phase1-tier1.md` — Task 1.1-1.12
- `plans/03-phase2-tier2.md` — Task 2.1-2.10
- `plans/04-phase3-tier3.md` — Task 3.1-3.14
- `plans/05-phase4-golden.md` — Task 4.1-4.3

每个子计划内的任务遵循"单技能优化流程"，格式如下：

```
### Task N.M: 优化 <skill-name>

**Files:** skills/<skill-name>/SKILL.md [ + 辅助文件]
**依赖:** Task N.M-1

- [ ] Step 1: 读取 SKILL.md，确认当前评分
- [ ] Step 2: 识别 <3 分轴的具体缺口
- [ ] Step 3: 编辑补齐缺口（参照缺口修复模式表）
- [ ] Step 4: 运行 update-lock.sh + validate
- [ ] Step 5: 重新评分确认 ≥3/3，记录证据
```

**验证证据:** 评分提升记录 + validate 输出 + update-lock.sh 确认

---

## 验证清单

- [ ] 每个任务有验收条件
- [ ] 每个任务有验证步骤
- [ ] 任务依赖已识别并正确排序
- [ ] 没有任务超过 ~5 个文件
- [ ] 主要阶段间设了检查点
- [ ] plan 没有占位符（TBD/TODO）
- [ ] spec 的每个需求在 plan 中都有对应任务
- [ ] 多计划任务有 `plans/*.md` 子计划索引
- [ ] `parallel_safe` 子计划之间没有重叠写入范围
- [ ] 用户已审查并批准 plan
