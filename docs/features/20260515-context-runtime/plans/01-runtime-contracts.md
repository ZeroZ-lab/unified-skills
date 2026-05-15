# Subplan 01 — Runtime Contracts

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `docs/features/20260515-context-runtime/02-design.md`
- **Write Scope:** `skills-router.json`, `scripts/generate-router.sh`, `scripts/report-context-budget.sh`, `scripts/tests/test-generate-router.sh`
- **Read Scope:** `skills-index.json`, `package.json`, `skills/*/SKILL.md`, `hooks/session-start.sh`
- **Verification Evidence:** `bash scripts/report-context-budget.sh`, `bash scripts/generate-router.sh`, `bash scripts/tests/test-generate-router.sh`
- **Merge Checkpoint:** router exists, validates, and references only real skills

## Tasks

### Task 1.1: Context Budget Report

**Files:**
- Create: `scripts/report-context-budget.sh`

**Depends On:** none

- [ ] Define plain-text output sections: startup surface, index/router surface, skill length table, auxiliary table, and sample route count.
- [ ] Implement with Bash and Python standard library.
- [ ] Run: `bash scripts/report-context-budget.sh` -> PASS.

### Task 1.2: Router Generator

**Files:**
- Create: `scripts/generate-router.sh`
- Create/Modify: `skills-router.json`

**Depends On:** Task 1.1

- [ ] Generate router from existing repo truth where possible: package version, skill list, phases, roles, descriptions, triggers, and risks.
- [ ] Preserve `skills-index.json` as inventory truth.
- [ ] Support `--dry-run`.
- [ ] Run: `bash scripts/generate-router.sh` -> PASS.

### Task 1.3: Router Test

**Files:**
- Create: `scripts/tests/test-generate-router.sh`

**Depends On:** Task 1.2

- [ ] Test normal generation.
- [ ] Test valid JSON and required top-level keys.
- [ ] Test all referenced skills exist.
- [ ] Test version matches `package.json`.
- [ ] Test `--dry-run` does not mutate `skills-router.json`.
- [ ] Run: `bash scripts/tests/test-generate-router.sh` -> PASS.

## Parallel Safety
- `parallel_safe: no`
- Reason: router shape becomes a shared contract for all later tasks.
