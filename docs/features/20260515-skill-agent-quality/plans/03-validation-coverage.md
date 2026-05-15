# Subplan 03: Validation Coverage

## Subplan Contract
- **Owner:** main agent
- **Status:** parallel_safe
- **Depends On:** `plans/01-quality-contracts.md`
- **Write Scope:** `docs/features/20260515-skill-agent-quality/validation-coverage.md`
- **Read Scope:** `validate`, `scripts/tests/*.sh`, `scripts/generate-index.sh`, `scripts/generate-router.sh`, `scripts/update-lock.sh`, `docs/features/20260515-skill-agent-quality/quality-matrix.md`
- **Parallel Safety:** yes; writes only validation coverage documentation.
- **Verification Evidence:** coverage map from current scripts to matrix risks.
- **Merge Checkpoint:** Rule candidates are documented before any validate edits.

## Tasks

### Task 1: Map Current Validate Sections

**Files:**
- Create/Modify: `docs/features/20260515-skill-agent-quality/validation-coverage.md`

**Depends On:** `plans/01-quality-contracts.md`

- [ ] Read `validate` section by section.
- [ ] Summarize which sections check skills, agents, lock files, router, index, hooks, stale text, and generated monitors.
- [ ] Record current known limits from `01-spec.md`.
- [ ] Record commands used for inspection.

**Verification Evidence:**
- Coverage doc maps current checks to concrete validate sections.

### Task 2: Compare Coverage Against Matrix Risks

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/validation-coverage.md`

**Depends On:** Task 1

- [ ] For each matrix risk category, mark current coverage as covered, partial, uncovered, or not applicable.
- [ ] Identify false-positive risk for each uncovered candidate.
- [ ] Separate contract checks from subjective quality checks.
- [ ] Record why subjective checks stay outside validate.

**Verification Evidence:**
- Each uncovered risk has a proposed handling path.

### Task 3: Select Rule Candidates

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/validation-coverage.md`

**Depends On:** Task 2

- [ ] List only objective candidates with clear failure messages.
- [ ] Tie each candidate to a fixed drift type or observed gap.
- [ ] Rank candidates by value and implementation risk.
- [ ] Mark candidates that need human partner approval before scripting.

**Verification Evidence:**
- Validate hardening candidates are ready for Task 8.
