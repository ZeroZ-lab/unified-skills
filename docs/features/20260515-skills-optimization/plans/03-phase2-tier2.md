# Phase 2: Tier 2 强纪律技能优化

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/02-phase1-tier1.md`
- **Write Scope:** 19 个 Tier 2 技能目录
- **Read Scope:** `docs/features/20260515-skills-optimization/scoring/scores.md`, `skills/*/SKILL.md`
- **Parallel Safety:** no（共享 skills-lock.json）
- **Verification Evidence:** 每个技能评分提升记录 + validate 通过 + human spot-check 3 个技能
- **Merge Checkpoint:** Tier 2 全部 19 个技能五轴 ≥3/3 + `./validate` 通过

## Tasks

### Task 2.1: 优化 build-quality-tdd

**Files:** `skills/build-quality-tdd/SKILL.md`, `skills/build-quality-tdd/examples.md`

**依赖:** Phase 1 完成

- [ ] 读取当前评分，确认缺口轴
- [ ] 编辑 SKILL.md 补齐缺口
- [ ] 检查辅助文件 `examples.md` 质量同步
- [ ] 运行 `bash scripts/update-lock.sh build-quality-tdd && ./validate`
- [ ] 重评确认 ≥3/3，记录证据

---

### Task 2.2: 优化 build-infrastructure-git

**Files:** `skills/build-infrastructure-git/SKILL.md`

**依赖:** Task 2.1

- [ ] 单技能优化流程（读取 → 评分 → 编辑 → update-lock → validate → 重评）

---

### Task 2.3: 优化 build-frontend-browser-testing

**Files:** `skills/build-frontend-browser-testing/SKILL.md`

**依赖:** Task 2.2

- [ ] 单技能优化流程

---

### Task 2.4: 优化 verify-workflow-debug

**Files:** `skills/verify-workflow-debug/SKILL.md`

**依赖:** Task 2.3

- [ ] 单技能优化流程

---

### Task 2.5: 优化 verify-workflow-spec-compliance

**Files:** `skills/verify-workflow-spec-compliance/SKILL.md`

**依赖:** Task 2.4

- [ ] 单技能优化流程

---

### Task 2.6: 优化 verify-quality-code-quality

**Files:** `skills/verify-quality-code-quality/SKILL.md`, `skills/verify-quality-code-quality/report-template.md`, `skills/verify-quality-code-quality/rubric.md`

**依赖:** Task 2.5

- [ ] 单技能优化流程 + 辅助文件同步（`report-template.md`、`rubric.md`）

---

### Task 2.7: 优化 verify-quality-security

**Files:** `skills/verify-quality-security/SKILL.md`

**依赖:** Task 2.6

- [ ] 单技能优化流程

---

### Task 2.8: 优化 verify-quality-performance

**Files:** `skills/verify-quality-performance/SKILL.md`

**依赖:** Task 2.7

- [ ] 单技能优化流程

---

### Task 2.9: 优化 verify-quality-simplify

**Files:** `skills/verify-quality-simplify/SKILL.md`

**依赖:** Task 2.8

- [ ] 单技能优化流程

---

### Task 2.10: 优化 verify-team-code-review-standards

**Files:** `skills/verify-team-code-review-standards/SKILL.md`

**依赖:** Task 2.9

- [ ] 单技能优化流程

---

### Task 2.11: 优化 verify-frontend-accessibility

**Files:** `skills/verify-frontend-accessibility/SKILL.md`

**依赖:** Task 2.10

- [ ] 单技能优化流程

---

### Task 2.12: 优化 verify-quality-integration-testing

**Files:** `skills/verify-quality-integration-testing/SKILL.md`

**依赖:** Task 2.11

- [ ] 单技能优化流程

---

### Task 2.13: 优化 verify-content-review

**Files:** `skills/verify-content-review/SKILL.md`

**依赖:** Task 2.12

- [ ] 单技能优化流程

---

### Task 2.14: 优化 verify-visual-review

**Files:** `skills/verify-visual-review/SKILL.md`

**依赖:** Task 2.13

- [ ] 单技能优化流程

---

### Task 2.15: 优化 verify-workflow-receiving-review

**Files:** `skills/verify-workflow-receiving-review/SKILL.md`

**依赖:** Task 2.14

- [ ] 单技能优化流程

---

### Task 2.16: 优化 ship-infrastructure-deploy

**Files:** `skills/ship-infrastructure-deploy/SKILL.md`

**依赖:** Task 2.15

- [ ] 单技能优化流程

---

### Task 2.17: 优化 ship-infrastructure-ci-cd

**Files:** `skills/ship-infrastructure-ci-cd/SKILL.md`

**依赖:** Task 2.16

- [ ] 单技能优化流程

---

### Task 2.18: 优化 ship-workflow-canary

**Files:** `skills/ship-workflow-canary/SKILL.md`

**依赖:** Task 2.17

- [ ] 单技能优化流程

---

### Task 2.19: 优化 ship-workflow-land

**Files:** `skills/ship-workflow-land/SKILL.md`

**依赖:** Task 2.18

- [ ] 单技能优化流程

---

## Phase 2 Checkpoint

- [ ] 19 个 Tier 2 技能全部五轴 ≥3/3
- [ ] 辅助文件与主 SKILL.md 质量同步
- [ ] `./validate` 通过
- [ ] `skills-lock.json` 哈希同步
- [ ] Human partner spot-check 3 个随机 Tier 2 技能通过
