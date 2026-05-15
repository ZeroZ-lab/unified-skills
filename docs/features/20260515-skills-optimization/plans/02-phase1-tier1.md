# Phase 1: Tier 1 骨架技能优化

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/01-phase0-infra.md`
- **Write Scope:** `skills/define-*/`, `skills/design-workflow-design/`, `skills/build-workflow-plan/`, `skills/build-workflow-execute/`, `skills/build-cognitive-execution-engine/`, `skills/verify-workflow-review/`, `skills/ship-workflow-ship/`, `skills/maintain-workflow-using-unified/`, `skills/maintain-workflow-context-save/`, `skills/maintain-workflow-context-restore/`
- **Read Scope:** `docs/features/20260515-skills-optimization/scoring/scores.md`, `skills/*/SKILL.md`
- **Parallel Safety:** no（共享 skills-lock.json）
- **Verification Evidence:** 每个技能评分提升记录 + validate 通过 + human spot-check 3 个技能
- **Merge Checkpoint:** Tier 1 全部 12 个技能五轴 ≥3/3 + `./validate` 通过

## 优化策略

Tier 1 是工作流枢纽。每个技能被高频路由，优化后的行为改善放大效应最大。

对每个技能：
1. 读取 Phase 0 评分表中的具体缺口
2. 参照 `03-plan.md` 的"五轴缺口修复模式"表
3. 参考已达到 3/3 的高质量技能（build-quality-tdd、ship-workflow-ship）的结构
4. 编辑补齐 → update-lock.sh → validate → 重评

## Tasks

### Task 1.1: 优化 define-workflow-refine

**Files:** `skills/define-workflow-refine/SKILL.md`, `skills/define-workflow-refine/refine-artifacts.md`

**依赖:** Phase 0 完成

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 检查辅助文件 `refine-artifacts.md` 与主文件质量同步
- [ ] 运行 `bash scripts/update-lock.sh define-workflow-refine && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.2: 优化 define-workflow-spec

**Files:** `skills/define-workflow-spec/SKILL.md`

**依赖:** Task 1.1

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 运行 `bash scripts/update-lock.sh define-workflow-spec && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.3: 优化 define-cognitive-brainstorm

**Files:** `skills/define-cognitive-brainstorm/SKILL.md`

**依赖:** Task 1.2

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 运行 `bash scripts/update-lock.sh define-cognitive-brainstorm && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.4: 优化 design-workflow-design

**Files:** `skills/design-workflow-design/SKILL.md`, `skills/design-workflow-design/design-sync.md`, `skills/design-workflow-design/visual-generation.md`

**依赖:** Task 1.3

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 检查辅助文件 `design-sync.md`、`visual-generation.md` 质量同步
- [ ] 运行 `bash scripts/update-lock.sh design-workflow-design && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.5: 优化 build-workflow-plan

**Files:** `skills/build-workflow-plan/SKILL.md`, `skills/build-workflow-plan/plan-review.md`, `skills/build-workflow-plan/task-templates.md`

**依赖:** Task 1.4

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 检查辅助文件 `plan-review.md`、`task-templates.md` 质量同步
- [ ] 运行 `bash scripts/update-lock.sh build-workflow-plan && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.6: 优化 build-workflow-execute

**Files:** `skills/build-workflow-execute/SKILL.md`

**依赖:** Task 1.5

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 运行 `bash scripts/update-lock.sh build-workflow-execute && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.7: 优化 build-cognitive-execution-engine

**Files:** `skills/build-cognitive-execution-engine/SKILL.md`, `skills/build-cognitive-execution-engine/implementer-prompt.md`, `skills/build-cognitive-execution-engine/quality-reviewer-prompt.md`, `skills/build-cognitive-execution-engine/spec-reviewer-prompt.md`

**依赖:** Task 1.6

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 检查辅助文件 `implementer-prompt.md`、`quality-reviewer-prompt.md`、`spec-reviewer-prompt.md` 质量同步
- [ ] 运行 `bash scripts/update-lock.sh build-cognitive-execution-engine && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.8: 优化 verify-workflow-review

**Files:** `skills/verify-workflow-review/SKILL.md`, `skills/verify-workflow-review/review-guidance.md`

**依赖:** Task 1.7

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 检查辅助文件 `review-guidance.md` 质量同步
- [ ] 运行 `bash scripts/update-lock.sh verify-workflow-review && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.9: 优化 ship-workflow-ship

**Files:** `skills/ship-workflow-ship/SKILL.md`

**依赖:** Task 1.8

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 运行 `bash scripts/update-lock.sh ship-workflow-ship && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.10: 优化 maintain-workflow-using-unified

**Files:** `skills/maintain-workflow-using-unified/SKILL.md`, `skills/maintain-workflow-using-unified/skill-reference.md`

**依赖:** Task 1.9

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 检查辅助文件 `skill-reference.md` 质量同步
- [ ] 运行 `bash scripts/update-lock.sh maintain-workflow-using-unified && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.11: 优化 maintain-workflow-context-save

**Files:** `skills/maintain-workflow-context-save/SKILL.md`

**依赖:** Task 1.10

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 运行 `bash scripts/update-lock.sh maintain-workflow-context-save && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 1.12: 优化 maintain-workflow-context-restore

**Files:** `skills/maintain-workflow-context-restore/SKILL.md`

**依赖:** Task 1.11

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 运行 `bash scripts/update-lock.sh maintain-workflow-context-restore && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

## Phase 1 Checkpoint

- [ ] 12 个 Tier 1 技能全部五轴 ≥3/3
- [ ] 13 个辅助文件全部与主 SKILL.md 质量同步
- [ ] `./validate` 通过
- [ ] `skills-lock.json` 哈希同步
- [ ] Human partner spot-check 3 个随机 Tier 1 技能通过
