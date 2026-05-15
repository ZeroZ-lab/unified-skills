# Subplan 01: Quality Contracts

## Subplan Contract
- **Owner:** main agent
- **Status:** gated
- **Depends On:** none
- **Write Scope:** `docs/features/20260515-skill-agent-quality/quality-matrix.md`, `docs/features/20260515-skill-agent-quality/scorecard.md`
- **Read Scope:** `docs/features/20260515-skill-agent-quality/01-spec.md`, `AGENTS.md`, `CANON.md`, `skills-router.json`, `skills-index.json`, `validate`, `skills/**/*.md`, `agents/*.md`
- **Parallel Safety:** no; downstream plans depend on this contract.
- **Verification Evidence:** inventory commands, matrix schema, scorecard rubric, and source references recorded in the generated docs.
- **Merge Checkpoint:** Checkpoint A in `03-plan.md`.

## Tasks

### Task 1: Capture Inventory Baseline

**Files:**
- Create/Modify: `docs/features/20260515-skill-agent-quality/quality-matrix.md`

**Depends On:** none

- [ ] Run `find skills -name SKILL.md | wc -l` and record the count.
- [ ] Run `find agents -maxdepth 1 -type f -name '*.md' ! -name README.md | wc -l` and record the count.
- [ ] Run `rg -n "agents/[a-z0-9-]+\\.md" skills agents validate` and record the source categories.
- [ ] Record any mismatch with older feature docs as drift evidence.

**Verification Evidence:**
- `quality-matrix.md` includes commands, counts, and the source files used.

### Task 2: Define Matrix Contract

**Files:**
- Create/Modify: `docs/features/20260515-skill-agent-quality/quality-matrix.md`

**Depends On:** Task 1

- [ ] Add the required matrix fields from `01-spec.md`.
- [ ] Define severity values: Blocking, Important, Suggestion, Covered.
- [ ] Define coverage states: covered, partial, uncovered, not applicable.
- [ ] Add a short rule that `agents/README.md` is an index, not a persona row.

**Verification Evidence:**
- Matrix has a clear legend and no ambiguous status labels.

### Task 3: Define Scorecard Contract

**Files:**
- Create/Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 1

- [ ] Add Skill Five-Axis scoring with 0-3 meanings.
- [ ] Add Agent Five-Axis scoring with 0-3 meanings.
- [ ] Define how deferred items are recorded.
- [ ] Define how scoring evidence must cite concrete file paths or observed gaps.

**Verification Evidence:**
- Scorecard rubric is complete enough for another agent to apply without guessing.
