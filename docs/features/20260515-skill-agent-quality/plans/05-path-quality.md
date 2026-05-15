# Subplan 05: High-Leverage and Long-Tail Path Quality

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/04-blocking-fixes.md`
- **Write Scope:** `skills/**`, `agents/**`, `docs/features/20260515-skill-agent-quality/scorecard.md`
- **Read Scope:** `quality-matrix.md`, `scorecard.md`, high-leverage skill and agent files
- **Parallel Safety:** no; workflow path edits overlap in shared behavioral contracts.
- **Verification Evidence:** path spot-checks, scorecard updates, lock refresh, and full validation.
- **Merge Checkpoint:** scorecard shows improved or explicitly deferred quality gaps.

## Tasks

### Task 1: Improve High-Leverage Paths

**Files:**
- Modify as needed: high-leverage `skills/**` and corresponding `agents/*.md`
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Blocking fixes complete

- [ ] Improve `/refine` path outputs and scout consumption.
- [ ] Improve `/plan` path outputs, review feedback merge, and Parallel Execution Matrix clarity.
- [ ] Improve `/build` path Task N / Write Scope / execution-engine consistency.
- [ ] Improve `/review` path two-stage gate and severity consistency.
- [ ] Improve `/ship` path audit findings and Go/No-Go consumption.
- [ ] Record every score change with evidence.

**Verification Evidence:**
- Each high-leverage path has an updated scorecard row and spot-check note.

### Task 2: Improve Remaining Skills by Phase

**Files:**
- Modify as needed: remaining `skills/**`
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 1

- [ ] Work through define, design, build, verify, ship, maintain, reflect.
- [ ] Prefer output contracts, examples, red-flag actions, and verification evidence.
- [ ] Reject edits that only increase length.
- [ ] Refresh lock entries after each skill batch.

**Verification Evidence:**
- Remaining skill rows are improved or deferred with a reason.

### Task 3: Improve Remaining Agents by Persona Group

**Files:**
- Modify as needed: remaining `agents/*.md`
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 2

- [ ] Work through refine, plan, build, review, ship, and core reusable personas.
- [ ] Align description, role boundary, output format, and tool boundary with consuming skills.
- [ ] Keep agent files as persona definitions, not routing authorities.
- [ ] Record score changes with evidence.

**Verification Evidence:**
- Agent scorecard rows are improved or deferred with a reason.

### Task 4: Validate Path Quality Work

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 3

- [ ] Run `scripts/generate-index.sh` if descriptions or skill inventory changed.
- [ ] Run `scripts/generate-router.sh` if index/routing inputs changed.
- [ ] Run `./validate`.
- [ ] Record validation results and residual risks.

**Verification Evidence:**
- `./validate` passes after quality improvements.
