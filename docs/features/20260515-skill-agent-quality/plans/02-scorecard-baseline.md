# Subplan 02: Scorecard Baseline

## Subplan Contract
- **Owner:** main agent
- **Status:** parallel_safe
- **Depends On:** `plans/01-quality-contracts.md`
- **Write Scope:** `docs/features/20260515-skill-agent-quality/scorecard.md`
- **Read Scope:** `docs/features/20260515-skill-agent-quality/01-spec.md`, `docs/features/20260515-skill-agent-quality/quality-matrix.md`, `skills/**/*.md`, `agents/*.md`
- **Parallel Safety:** yes; writes only `scorecard.md` and depends only on the quality contract.
- **Verification Evidence:** scorecard coverage commands and sampled file evidence.
- **Merge Checkpoint:** Scorecard has rows for all in-scope files before Blocking fixes begin.

## Tasks

### Task 1: Score High-Leverage Workflow Skills

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** `plans/01-quality-contracts.md`

- [ ] Read each high-leverage skill listed in `03-plan.md`.
- [ ] Score each Skill Five-Axis dimension.
- [ ] Record one concrete evidence snippet per low score.
- [ ] Mark candidates for Blocking repair separately from general quality improvement.

**Verification Evidence:**
- High-leverage workflow skills have complete score rows.

### Task 2: Score High-Leverage Agents

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 1

- [ ] Read agent files used by `/refine`, `/plan`, `/build`, `/review`, and `/ship`.
- [ ] Score each Agent Five-Axis dimension.
- [ ] Record whether output format matches the consuming skill.
- [ ] Flag agent permission or tool-boundary concerns.

**Verification Evidence:**
- High-leverage agent rows are complete and tied to consuming skills.

### Task 3: Score Remaining Files

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 2

- [ ] Batch remaining skills by phase.
- [ ] Batch remaining agents by persona group.
- [ ] Mark low-confidence rows as `needs second pass` with the reason.
- [ ] Sort final scorecard by severity and workflow leverage.

**Verification Evidence:**
- Scorecard includes every in-scope file or a clear exclusion reason.
