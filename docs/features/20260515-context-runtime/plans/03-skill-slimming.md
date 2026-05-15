# Subplan 03 — Skill Slimming

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/02-loading-surface.md`
- **Write Scope:** `skills/maintain-workflow-using-unified/`, `skills/design-workflow-design/`, `skills/build-workflow-plan/`, `skills-lock.json`, `skills-index.json`
- **Read Scope:** `skills-lock.json`, `validate`, current skill bodies, existing auxiliary-file examples
- **Verification Evidence:** `bash scripts/generate-index.sh`, `./validate`, `bash scripts/report-context-budget.sh`
- **Merge Checkpoint:** three high-impact skills have entry-first main files and referenced one-level auxiliary files

## Tasks

### Task 3.1: Using Guide Slimming

**Files:**
- Modify: `skills/maintain-workflow-using-unified/SKILL.md`
- Create: `skills/maintain-workflow-using-unified/skill-reference.md`
- Modify: `skills-lock.json`

**Depends On:** Subplan 02

- [ ] Keep activation, tier selection, and hard gates in `SKILL.md`.
- [ ] Move long skill-category quick reference into `skill-reference.md`.
- [ ] Ensure `SKILL.md` explicitly references `skill-reference.md`.
- [ ] Refresh `skills-lock.json`.
- [ ] Run: `./validate` -> PASS.

### Task 3.2: Design Skill Slimming

**Files:**
- Modify: `skills/design-workflow-design/SKILL.md`
- Create: `skills/design-workflow-design/visual-generation.md`
- Create: `skills/design-workflow-design/design-sync.md`
- Modify: `skills-lock.json`

**Depends On:** Task 3.1

- [ ] Keep entry/exit, design applicability, source model, required output, hard gates, and approval gates in `SKILL.md`.
- [ ] Move Codex visual-generation details into `visual-generation.md`.
- [ ] Move DESIGN.md sync mechanics into `design-sync.md`.
- [ ] Preserve validation-required phrases in the main file.
- [ ] Refresh `skills-lock.json`.
- [ ] Run: `./validate` -> PASS.

### Task 3.3: Plan Skill Slimming

**Files:**
- Modify: `skills/build-workflow-plan/SKILL.md`
- Create: `skills/build-workflow-plan/plan-review.md`
- Modify: `skills-lock.json`

**Depends On:** Task 3.2

- [ ] Keep plan topology, dependency graph, vertical slicing, task rules, checkpoints, and self-review in `SKILL.md`.
- [ ] Move detailed Plan Review Army rules into `plan-review.md`.
- [ ] Keep existing `task-templates.md` reference.
- [ ] Ensure `SKILL.md` explicitly references `plan-review.md`.
- [ ] Refresh `skills-lock.json`.
- [ ] Run: `./validate` -> PASS.

## Parallel Safety
- `parallel_safe: no`
- Reason: every task mutates `skills-lock.json`; running them in parallel would conflict.
