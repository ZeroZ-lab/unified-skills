# Skills + Agents 质量系统 — Review

## Formal Review Result

Status: APPROVED

This formal `/review` initially found two Important issues. Both were fixed and revalidated:

- `scorecard.md` now applies the five-axis skill rubric to the remaining skill baseline instead of using a single aggregate baseline.
- `scripts/check-agent-contracts.py` now owns the objective agent contract rules, and `scripts/tests/test-agent-contracts.sh` proves the negative cases.

## Resolved Findings

### Resolved: Scorecard baseline applies the five-axis rubric

Evidence:
- `scorecard.md` high-leverage and remaining skill sections now both use `Operability / Examples / Convergence / Linkage / Sayings`.

### Resolved: New validate rules are proven by negative tests

Evidence:
- `scripts/tests/test-agent-contracts.sh` proves README extra-agent drift fails.
- `scripts/tests/test-agent-contracts.sh` proves README missing-agent drift fails.
- `scripts/tests/test-agent-contracts.sh` proves review auditor write-tool drift fails.
- `./validate` runs the fixture test as part of the automated quality gate.

## Formal Stage 1: Spec Compliance

Result: PASSED

- Functional coverage: complete for this scoped quality baseline.
- Acceptance coverage: complete for the documented outputs and new validation rules.
- Scope creep: none found.

## Formal Stage 2: Code Quality

Result: PASSED

| Axis | Result | Notes |
|------|--------|-------|
| Correctness | PASS | The same checker powers `validate` and the negative fixture tests |
| Readability | PASS | Agent contract logic moved out of embedded validate heredoc into a named script |
| Architecture | PASS | Objective checks stay automated; subjective scoring stays in review artifacts |
| Security | PASS | Review/ship auditor write-tool guard is enforced and regression-tested |
| Performance | PASS | Checker scans small repo-local markdown files and fixture tests copy only `agents/` plus `skills/` |

---

# Build Self-Review Record

## Build Summary

Execution mode: inline serial.

Completed:
- Created `quality-matrix.md` with current inventory, stage-path matrix, agent inventory matrix, and finding severity.
- Created `scorecard.md` with per-axis skill and agent scoring baseline.
- Created `validation-coverage.md` with existing coverage, implemented rules, deferred rule candidates, rejected subjective checks, and negative fixture coverage.
- Added objective validation rules through `scripts/check-agent-contracts.py` and `validate`:
  - `agents/README.md` must match real `agents/*.md` files.
  - `review-*.md` and `ship-*.md` agents that declare `tools:` must not declare write-capable tools.
- Added `scripts/tests/test-agent-contracts.sh` to prove failing fixtures for the new objective rules.
- Ran full `./validate` successfully after fixing a documentation wording issue that triggered the placeholder gate.

Not changed:
- No `SKILL.md` or skill auxiliary file was edited.
- No `agents/*.md` persona file was edited.
- No `skills-index.json`, `skills-router.json`, or `skills-lock.json` update was required.
- No `AGENTS.md`, `CANON.md`, `commands/`, or plugin manifest was changed.

## Spec Coverage

| Spec requirement | Status | Evidence |
|------------------|--------|----------|
| Key stage invocation chains documented | PASS | `quality-matrix.md` covers brainstorm/refine/design/plan/build/review/ship/maintain paths |
| Each included skill/agent has score baseline | PASS | `scorecard.md` covers 54 skills and 24 persona agents with per-axis scoring |
| Batch validation evidence recorded | PASS | `./validate` passed after validate hardening |
| Preserve AGENTS single entry and agent non-router boundary | PASS | No root contract or agent routing model changes |
| Avoid fixed inventory count in long-lived docs | PASS | Counts are recorded with commands in feature-scoped evidence docs |
| Output quality matrix and scorecard | PASS | `quality-matrix.md`, `scorecard.md`, `validation-coverage.md` created |

## Findings

### Blocking

None found in the current source tree.

Evidence:
- Every real `agents/*.md` persona file is consumed by at least one `skills/**/*.md` contract.
- Every agent listed in `agents/README.md` has a corresponding file.
- No review or ship auditor declares write-capable tools.
- `./validate` passes.

### Important

- Several refine/plan/design persona files still do not declare explicit tools allowlists. This is recorded in `scorecard.md` as Important, not Blocking, because host support and desired defaults need a separate decision before broad frontmatter changes.
- Subjective content quality remains review-driven. The build intentionally did not turn score thresholds, example quality, or writing quality into shell checks.
- No unresolved Important finding remains from the formal review.

### Suggestions

- If the next iteration targets persona frontmatter, start with a small host-support proof before editing all refine/plan/design reviewers.
- If the next iteration targets skills prose quality, use `scorecard.md` to select one phase at a time rather than broad rewrites.

## Validation Evidence

Commands executed:

- `find skills -name SKILL.md | wc -l` -> `54`
- `find agents -maxdepth 1 -type f -name '*.md' ! -name README.md | wc -l` -> `24`
- `find skills -maxdepth 2 -type f \( -name 'SKILL.md' -o -name '*.md' \) | wc -l` -> `67`
- `rg -n "agents/[a-z0-9-]+\.md" skills agents validate`
- `python3 scripts/check-agent-contracts.py` -> PASS
- `bash scripts/tests/test-agent-contracts.sh` -> PASS
- `./validate` -> PASS

Validation note:
- First `./validate` run failed because `validation-coverage.md` quoted the placeholder marker names directly. The wording was changed to avoid including the raw markers, then `./validate` passed.
- The final `./validate` run includes the new negative fixture test.

## Changed Files

- `validate`
- `scripts/check-agent-contracts.py`
- `scripts/tests/test-agent-contracts.sh`
- `docs/features/20260515-skill-agent-quality/00-brainstorm.md`
- `docs/features/20260515-skill-agent-quality/01-spec.md`
- `docs/features/20260515-skill-agent-quality/03-plan.md`
- `docs/features/20260515-skill-agent-quality/04-review.md`
- `docs/features/20260515-skill-agent-quality/quality-matrix.md`
- `docs/features/20260515-skill-agent-quality/scorecard.md`
- `docs/features/20260515-skill-agent-quality/validation-coverage.md`
- `docs/features/20260515-skill-agent-quality/plans/01-quality-contracts.md`
- `docs/features/20260515-skill-agent-quality/plans/02-scorecard-baseline.md`
- `docs/features/20260515-skill-agent-quality/plans/03-validation-coverage.md`
- `docs/features/20260515-skill-agent-quality/plans/04-blocking-fixes.md`
- `docs/features/20260515-skill-agent-quality/plans/05-path-quality.md`
- `docs/features/20260515-skill-agent-quality/plans/06-validate-hardening.md`

## Residual Risk

- `scorecard.md` is a baseline artifact; it should be treated as an implementation guide, not a permanent truth.
- `CHECK_CODEX_CACHE=1 ./validate` was not run because this build changed source validation and feature docs, not installed host cache state.

## Review Result

PASS.

Recommended next stage: `/ship` if the human partner wants to package or release this scoped quality baseline.
