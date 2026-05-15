# Subplan 04: Blocking Fixes

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/01-quality-contracts.md`, `plans/02-scorecard-baseline.md`, `plans/03-validation-coverage.md`
- **Write Scope:** `skills/**`, `agents/**`, `scripts/**`, `validate`, `docs/features/20260515-skill-agent-quality/**`
- **Read Scope:** `quality-matrix.md`, `scorecard.md`, `validation-coverage.md`, `AGENTS.md`, `CANON.md`, `skills-index.json`, `skills-router.json`
- **Parallel Safety:** no; fixes may touch shared workflow contracts.
- **Verification Evidence:** before/after evidence for every Blocking item plus full validation.
- **Merge Checkpoint:** Checkpoint B in `03-plan.md`.

## Tasks

### Task 1: Select Blocking Items

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/quality-matrix.md`
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** scorecard and validation coverage completion

- [ ] Review all rows marked Blocking.
- [ ] Group findings by authoritative layer: stage skill, agent, script, validate, or docs.
- [ ] Confirm no finding requires changing the scope boundaries in `01-spec.md`.
- [ ] Record selected fixes and deferred human partner decisions.

**Verification Evidence:**
- Blocking list is explicit and sorted before edits begin.

### Task 2: Patch Authoritative Contracts

**Files:**
- Modify as needed: `skills/**`, `agents/**`, `docs/features/20260515-skill-agent-quality/**`

**Depends On:** Task 1

- [ ] Patch stage skill files when invocation or hard-gate behavior is wrong.
- [ ] Patch agent files when persona boundary or output format is wrong.
- [ ] Patch docs only when the issue is evidence or stale explanation.
- [ ] Avoid unrelated refactors and broad rewrites.

**Verification Evidence:**
- Each edited file maps to a selected Blocking finding.

### Task 3: Refresh Generated and Lock Artifacts

**Files:**
- Modify as needed: `skills-index.json`, `skills-router.json`, `skills-lock.json`

**Depends On:** Task 2

- [ ] For each edited skill, run `scripts/update-lock.sh <skill>`.
- [ ] If skill inventory or descriptions changed, run `scripts/generate-index.sh`.
- [ ] If index or routing changed, run `scripts/generate-router.sh`.
- [ ] Inspect diffs to confirm only intended generated sections changed.

**Verification Evidence:**
- Generated file diffs are understood and recorded.

### Task 4: Validate Blocking Fixes

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/quality-matrix.md`

**Depends On:** Task 3

- [ ] Run targeted grep for each fixed contract.
- [ ] Run `./validate`.
- [ ] Record command output summary and any residual risk.
- [ ] Mark Blocking rows fixed or escalated.

**Verification Evidence:**
- `./validate` passes before moving to path quality work.
