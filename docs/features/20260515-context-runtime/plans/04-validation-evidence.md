# Subplan 04 — Validation Evidence

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/03-skill-slimming.md`
- **Write Scope:** `validate`, `docs/features/20260515-context-runtime/context-budget-report.md`, optional review artifact if `/review` is invoked later
- **Read Scope:** `skills-router.json`, `skills-index.json`, `hooks/session-start.sh`, selected skill files, script test outputs
- **Verification Evidence:** `bash scripts/tests/test-generate-router.sh`, `bash scripts/tests/test-hooks.sh`, `bash scripts/report-context-budget.sh`, `./validate`
- **Merge Checkpoint:** final validation and context-budget evidence are recorded

## Tasks

### Task 4.1: Validation Integration

**Files:**
- Modify: `validate`

**Depends On:** Subplan 01, Subplan 02

- [ ] Add context-runtime validation block.
- [ ] Check `skills-router.json` exists and version matches package metadata.
- [ ] Check router references only real skills.
- [ ] Check tier budgets are present and route skill counts stay within tier limits.
- [ ] Check SessionStart no longer emits prohibited full command-map content.
- [ ] Check `maintain-workflow-using-unified` contains tier wording and lacks the old over-loading rule.
- [ ] Run: `./validate` -> PASS.

### Task 4.2: Budget Evidence

**Files:**
- Create: `docs/features/20260515-context-runtime/context-budget-report.md`

**Depends On:** Task 4.1, Subplan 03

- [ ] Run: `bash scripts/report-context-budget.sh`.
- [ ] Record startup surface, router surface, long skill files, auxiliary extraction state, and representative route counts.
- [ ] Include before/after notes where baseline values are available from earlier report output.

### Task 4.3: Final Verification

**Files:**
- No source file changes expected beyond evidence updates.

**Depends On:** Task 4.2

- [ ] Run: `bash scripts/tests/test-generate-router.sh` -> PASS.
- [ ] Run: `bash scripts/tests/test-hooks.sh` -> PASS.
- [ ] Run: `bash scripts/report-context-budget.sh` -> PASS.
- [ ] Run: `./validate` -> PASS.
- [ ] Record commands and results in the final response or later review artifact.

## Parallel Safety
- `parallel_safe: no`
- Reason: final validation depends on all earlier shared contract changes.
