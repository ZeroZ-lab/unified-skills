# Subplan 06: Validate Hardening and Final Review

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/05-path-quality.md`
- **Write Scope:** `validate`, `scripts/tests/**`, `docs/features/20260515-skill-agent-quality/validation-coverage.md`, `docs/features/20260515-skill-agent-quality/04-review.md`
- **Read Scope:** `quality-matrix.md`, `scorecard.md`, `validation-coverage.md`, all changed files
- **Parallel Safety:** no; final validation rules and review depend on all prior fixes.
- **Verification Evidence:** targeted rule evidence, full validation output, final review report.
- **Merge Checkpoint:** final review package complete and `./validate` passes.

## Tasks

### Task 1: Add Objective Validate Rules

**Files:**
- Modify: `validate`
- Modify as needed: `scripts/tests/*.sh`
- Modify: `docs/features/20260515-skill-agent-quality/validation-coverage.md`

**Depends On:** path quality work complete

- [ ] Select rule candidates from `validation-coverage.md`.
- [ ] Add one rule at a time with a clear failure message.
- [ ] Keep subjective scoring out of validate.
- [ ] Run focused script tests where applicable.

**Verification Evidence:**
- Each new rule maps to a drift type observed earlier in the work.

### Task 2: Verify Repository State

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/validation-coverage.md`

**Depends On:** Task 1

- [ ] Run `./validate`.
- [ ] If host cache verification is relevant, run `CHECK_CODEX_CACHE=1 ./validate` and separate source failures from installation-state failures.
- [ ] Run `git status --short`.
- [ ] Record validation commands and outcomes.

**Verification Evidence:**
- Full validation result is recorded.

### Task 3: Produce Final Review Report

**Files:**
- Create: `docs/features/20260515-skill-agent-quality/04-review.md`

**Depends On:** Task 2

- [ ] Map each `01-spec.md` acceptance criterion to evidence.
- [ ] Summarize changed files by category.
- [ ] List any residual Important or Suggestion items.
- [ ] State whether the implementation is ready for `/ship`.

**Verification Evidence:**
- `04-review.md` contains spec coverage, quality review, validation output summary, and residual risks.
