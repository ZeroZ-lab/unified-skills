# Seamless Context Resume — Implementation Plan

> For execution: implement this plan task-by-task. Treat each `### Task N` block as one execution unit, and do not start the next task until the current task has passing verification evidence unless `Parallel Execution Matrix` explicitly proves `parallel_safe: yes`.

## Plan Status
- Status: implemented
- Scope Size: M
- Risk Level: medium
- Project Doc Sync Plan Status: planned
- Spec: `docs/features/20260518-seamless-context-resume/01-spec.md`
- Design: skipped; this is a hook/runtime contract change with no UI, visual, deck, or content artifact design surface.

## Artifact Type
artifact_type: software

## Inputs
- `docs/features/20260518-seamless-context-resume/01-spec.md`
- Existing hook contracts: `hooks/session-start.sh`, `hooks/doc-tracker.sh`, `hooks/phase-stop.sh`, `hooks/hooks.json`
- Existing tests: `scripts/tests/test-hooks.sh`
- Existing validation entrypoint: `./validate`

## Task Execution Rules

- `/plan` owns this task list; `/build` consumes it.
- Each `### Task N` below is one execution unit.
- A task is done only when its own verification passes and evidence is recorded.
- Parallel execution is not allowed in v1 because hook behavior, validation, and docs all share the same runtime contract.
- Missing task detail during `/build` is a `PLAN GAP`; return to `/plan` to repair it.
- Build must not auto-start implementation from SessionStart; SessionStart may only surface a resume hint.

## Plan Topology
topology: serial

Reason: the feature changes shared runtime behavior across hooks, validation, root docs, and maintain skills. The write scopes overlap semantically even when files differ, so serial execution reduces contract drift.

## Dependency Order

```text
Task 1 State schema and helper
  -> Task 2 doc-tracker state updates
  -> Task 3 SessionStart resume hint
  -> Task 4 Stop hook boundary cleanup
  -> Task 5 validation and hook tests
  -> Task 6 docs and skill contract sync
  -> Task 7 final verification evidence
```

## Subplans

No subplans for v1. This is a single serial plan.

| Subplan | Status | Owner | Depends On | Write Scope | Shared Contracts | Cross-check Command | Verification Evidence |
|---------|--------|-------|------------|-------------|------------------|---------------------|-----------------------|
| none | serial | main agent | none | n/a | feature state schema v1 | `./validate` | full validation output |

## Parallel Execution Matrix

| Work A | Work B | parallel_safe | Reason |
|--------|--------|---------------|--------|
| any hook task | validation/docs tasks | no | The user-facing runtime contract and test expectations must evolve together. |

## Integration Order

1. Define the `state.json` schema and shared helper behavior.
2. Make phase document writes update feature state.
3. Make SessionStart read feature state and emit a compact resume hint.
4. Keep Stop behavior aligned with automatic state and manual checkpoints.
5. Add tests and validation for the state schema.
6. Sync root docs, commands, skills, indexes, and lock hashes.
7. Run full validation and record evidence.

## Project Doc Sync Plan

- Must update:
  - `AGENTS.md`
  - `commands/save.md`
  - `commands/restore.md`
  - `docs/architecture/deployment-and-runtime.md`
  - `CHANGELOG.md`
- Optional update:
  - `README.md` only if the user-facing usage summary needs a short mention after implementation.
- Stage owner:
  - `/build` owns code, hook tests, and first-pass docs.
  - `/review` owns Documentation Compliance.
  - `/ship` owns final Documentation Sync and changelog release wording.
- Verification method:
  - `bash scripts/tests/test-hooks.sh`
  - `./validate`
  - Manual inspection of SessionStart output for a valid sample `state.json`
  - Documentation Compliance check in `04-review.md`
- Deferred docs with reason:
  - `docs/architecture/observability-and-runbook.md` deferred; this feature changes local workflow recovery, not production monitoring or incident response.
  - `docs/architecture/module-boundaries.md` deferred unless implementation adds a reusable runtime module with cross-hook ownership rules beyond the scripts named here.

## Shared Contract: Feature State v1

Canonical path:

```text
docs/features/<feature>/state.json
```

Required fields:

```json
{
  "schema_version": 1,
  "feature_path": "docs/features/20260518-seamless-context-resume",
  "branch": "feature/seamless-context-resume",
  "current_stage": "plan",
  "last_phase_doc": "03-plan.md",
  "next_command": "/build",
  "last_activity": "2026-05-18T10:30:00+08:00",
  "stale_reason": null
}
```

Allowed stages:

| Phase doc | current_stage | next_command |
|-----------|---------------|--------------|
| `00-brainstorm.md` | `brainstorm` | `/refine` |
| `01-spec.md` | `refine` | `/design` by default, `/plan` only when design is explicitly skipped |
| `02-design.md` | `design` | `/plan` |
| `03-plan.md` | `plan` | `/build` |
| `/build` complete with `03-plan.md` | `build` | `/review` |
| `04-review.md` | `review` | `/ship` |
| `05-ship.md` | `ship` | `null` |

State must not include `dirty_status`, branch-match result, machine path outside the repo, username, hostname, or any local runtime-only data.

## Task List

| Task | Title | Files | Verification | Depends On |
|------|-------|-------|--------------|------------|
| 1 | Define state helper | 2-3 | helper self-check + shell test | none |
| 2 | Update phase tracking | 2 | hook test for `state.json` writes | Task 1 |
| 3 | Add resume hint | 2 | hook test for SessionStart output | Task 2 |
| 4 | Align Stop behavior | 2 | hook test for no stale `/save` nag | Task 3 |
| 5 | Add validation gate | 2 | malformed state fixtures fail | Task 4 |
| 6 | Sync docs contracts | 8-9 | generated index/lock + validate | Task 5 |
| 7 | Capture verification | 2 | full suite passes | Task 6 |

### Task 1: Define state helper

**Files:**
- Create: `scripts/unified-state.py`
- Create or modify: `scripts/tests/test-unified-state.sh`
- Create: `docs/features/20260518-seamless-context-resume/state.json` as the initial feature state for this feature

**Depends On:** none

- [ ] Step 1: Define the state schema constants in `scripts/unified-state.py`
  - Supported schema version: `1`
  - Allowed stages and next-command mapping match the shared contract above
  - Required keys match the spec
- [ ] Step 2: Implement commands for the helper
  - `update-from-phase-doc <project-dir> <phase-doc-path>`
  - `mark-build-complete <project-dir> <feature-path>`
  - `latest <project-dir>`
  - `validate <state-path>`
  - `format-resume <project-dir>`
- [ ] Step 3: Ensure helper writes only project-scoped paths
  - Reject paths outside `docs/features/<feature>/`
  - Reject persisted `dirty_status` or other machine-local keys
- [ ] Step 3.5: Support `/build` completion
  - `mark-build-complete` advances `current_stage` to `build` and `next_command` to `/review`
  - Do not add Task N-level progress fields in v1
- [ ] Step 4: Verify helper behavior
  - Run: `bash scripts/tests/test-unified-state.sh`
  - Expected: state create/update/validate/latest flows pass

**Acceptance:**
- A phase doc path can produce a valid `state.json`.
- Build completion can advance state from `/build` to `/review`.
- Invalid stage, missing `last_phase_doc`, unsupported schema, and local-only keys fail validation.
- Initial state for `20260518-seamless-context-resume` records `current_stage: "plan"` and `next_command: "/build"`.

### Task 2: Update phase tracking

**Files:**
- Modify: `hooks/doc-tracker.sh`
- Modify: `scripts/tests/test-hooks.sh`

**Depends On:** Task 1

- [ ] Step 1: Call `scripts/unified-state.py update-from-phase-doc` when `doc-tracker.sh` observes `docs/features/*/0X-*.md`
- [ ] Step 2: Preserve existing progress message output
  - The hook must still emit `[progress] 产出 ...`
- [ ] Step 3: Add hook tests for phase documents
  - `00-brainstorm.md` creates `next_command: "/refine"`
  - `03-plan.md` creates `next_command: "/build"`
  - `05-ship.md` creates `next_command: null`
- [ ] Step 4: Verify
  - Run: `bash scripts/tests/test-hooks.sh`
  - Expected: existing hook tests and new state update tests pass

**Acceptance:**
- Feature state updates are automatic after phase document writes.
- Non-feature writes do not create state files.

### Task 3: Add resume hint

**Files:**
- Modify: `hooks/session-start.sh`
- Modify: `scripts/tests/test-hooks.sh`

**Depends On:** Task 2

- [ ] Step 1: Read the latest valid active feature state during SessionStart
  - Active means `next_command` is not null and `stale_reason` is null
- [ ] Step 2: Compute branch match at runtime
  - Use `git -C <project-dir> branch --show-current`
  - Do not write branch match into `state.json`
- [ ] Step 3: Append a compact resume hint to Boot Kernel
  - Include feature path, current stage, last phase doc, next command, and branch warning if mismatched
  - Keep total SessionStart context under the existing 80-line budget
- [ ] Step 4: Verify
  - Run: `bash scripts/tests/test-hooks.sh`
  - Expected: SessionStart output includes resume hint when sample state exists, and omits it when no valid state exists

**Acceptance:**
- New sessions can see the active feature and next command without manual `/restore`.
- Branch mismatch is visible but not persisted.
- SessionStart still says Unified runtime is not automatically activated.

### Task 4: Align Stop behavior

**Files:**
- Modify: `hooks/phase-stop.sh`
- Modify: `scripts/tests/test-hooks.sh`

**Depends On:** Task 3

- [ ] Step 1: Stop treating the absence of manual checkpoint as the only unsaved-work signal
- [ ] Step 2: If a valid active `state.json` exists, emit at most a short decision-checkpoint hint
  - Message should distinguish automatic state from manual `/save`
- [ ] Step 3: Keep forced/error/interrupt stop behavior unchanged
- [ ] Step 4: Verify
  - Run: `bash scripts/tests/test-hooks.sh`
  - Expected: Stop hook no longer implies manual `/save` is required for basic progress recovery

**Acceptance:**
- Automatic feature state prevents misleading save nagging.
- `/save` is still suggested only as a decision checkpoint when useful.

### Task 5: Add validation gate

**Files:**
- Modify: `validate`
- Modify: `scripts/tests/test-hooks.sh` or create `scripts/tests/test-unified-state.sh` if not completed in Task 1

**Depends On:** Task 4

- [ ] Step 1: Add validation for every committed `docs/features/*/state.json`
  - Required keys present
  - `schema_version` is `1`
  - `feature_path` matches containing directory
  - `last_phase_doc` exists when non-null
  - `current_stage` and `next_command` match allowed mapping
  - Forbidden local keys are absent
- [ ] Step 2: Add validation that hooks use the helper
  - `doc-tracker.sh` updates state through the helper
  - `session-start.sh` reads resume state through the helper
- [ ] Step 3: Verify malformed fixture behavior without committing fixture files
  - Use temporary directories inside shell tests
- [ ] Step 4: Verify
  - Run: `bash scripts/tests/test-unified-state.sh`
  - Run: `./validate`

**Acceptance:**
- Bad `state.json` files fail validation.
- No `.claude/runtime-state.json` or `.claude/unified-state.json` is introduced.

### Task 6: Sync docs contracts

**Files:**
- Modify: `AGENTS.md`
- Modify: `commands/save.md`
- Modify: `commands/restore.md`
- Modify: `skills/maintain-workflow-context-save/SKILL.md`
- Modify: `skills/maintain-workflow-context-restore/SKILL.md`
- Modify: `docs/architecture/deployment-and-runtime.md`
- Modify: `CHANGELOG.md`
- Modify as generated: `skills-index.json`, `skills-router.json`, `skills-lock.json`, `.claude-plugin/monitors/monitors.json`

**Depends On:** Task 5

- [ ] Step 1: Document the automatic feature state boundary in `AGENTS.md`
  - `state.json` gives stage-level recovery
  - `/save` gives decision-level checkpoint recovery
- [ ] Step 2: Update `/save` and `/restore` command docs
  - Explain that manual commands are no longer required for basic stage continuity
- [ ] Step 3: Update maintain skills with the same boundary
  - Preserve restore confirmation hard gate
  - Preserve save as decision checkpoint
- [ ] Step 4: Update project runtime docs and changelog
  - `deployment-and-runtime.md` covers hook/session behavior
  - `CHANGELOG.md` records the user-visible workflow improvement
- [ ] Step 5: Refresh generated contract files
  - Run: `bash scripts/generate-index.sh`
  - Run: `bash scripts/generate-router.sh`
  - Run: `bash scripts/update-lock.sh maintain-workflow-context-save`
  - Run: `bash scripts/update-lock.sh maintain-workflow-context-restore`
  - Run: `bash scripts/generate-skill-load-monitors.sh`

**Acceptance:**
- Root, command, skill, and project docs tell the same story.
- Generated indexes and lock hashes are synchronized.

### Task 7: Capture verification

**Files:**
- Modify: `docs/features/20260518-seamless-context-resume/03-plan.md`
- Create or modify later: `docs/features/20260518-seamless-context-resume/04-review.md` during review stage, not during build

**Depends On:** Task 6

- [ ] Step 1: Run focused tests
  - `bash scripts/tests/test-unified-state.sh`
  - `bash scripts/tests/test-hooks.sh`
- [ ] Step 2: Run full validation
  - `./validate`
- [ ] Step 3: Record validation evidence in the build response
  - Commands run
  - Pass/fail result
  - Any deferred docs
- [ ] Step 4: Confirm plan tasks are complete before `/review`

**Acceptance:**
- Focused tests pass.
- Full validation passes.
- No unrelated local changes are staged or modified.

## Plan Self-Review

- Spec coverage: each acceptance criterion maps to Tasks 1-7.
- Placeholder scan: no placeholder markers are intentionally introduced.
- Subplans: none; serial topology avoids incomplete subplan contracts.
- Parallel safety: no parallel-safe work declared.
- Verification: each task has concrete commands and expected results.
- Documentation sync: required project docs are mapped with owners and verification.
- Task granularity: all tasks have bounded write scope and clear acceptance.

## Plan Review Summary

- CEO: Adopted. The plan keeps the user-facing value narrow: new agents know the current feature progress without manual `/restore`.
- Eng: Adopted. State helper first, hook integration second, validation third is the lowest-risk sequence.
- Design: Skipped. No UI, visual, deck, or content experience design surface; SessionStart copy is constrained by the Boot Kernel line budget.
- Security: Skipped. No authentication, authorization, secrets, network calls, or data storage beyond repo-local JSON.
- Blocking issues: none identified.
- Important notes: The spec is still marked draft. Build should proceed only after human partner approves this plan or explicitly says to implement.

## User Approval

- Status: approved by user request: "build 一下"
- Next stage: `/review`

## Build Execution Evidence

### Completed Tasks

| Task | Status | Evidence |
|------|--------|----------|
| Task 1: Define state helper | done | `bash scripts/tests/test-unified-state.sh` PASS |
| Task 2: Update phase tracking | done | `bash scripts/tests/test-hooks.sh` PASS, doc-tracker state update tests PASS |
| Task 3: Add resume hint | done | `bash scripts/tests/test-hooks.sh` PASS, SessionStart active state test PASS |
| Task 4: Align Stop behavior | done | `bash scripts/tests/test-hooks.sh` PASS, phase-stop decision checkpoint test PASS |
| Task 5: Add validation gate | done | `./validate` PASS, `Unified feature state` check PASS |
| Task 6: Sync docs contracts | done | `bash scripts/generate-index.sh`, `bash scripts/generate-router.sh`, `bash scripts/update-lock.sh`, `bash scripts/generate-skill-load-monitors.sh` completed |
| Task 7: Capture verification | done | focused tests + full validation PASS |

### State After Build

`docs/features/20260518-seamless-context-resume/state.json` now records `current_stage: "build"` and `next_command: "/review"` so the next agent does not loop back into `/build`.

### Final Commands

```bash
bash scripts/tests/test-unified-state.sh
bash scripts/tests/test-hooks.sh
./validate
```

### Deferred Docs

- `docs/architecture/observability-and-runbook.md` remains deferred because this feature changes local workflow recovery, not production monitoring.
- `docs/architecture/module-boundaries.md` remains deferred because the implementation added a small script helper but did not change cross-module runtime ownership beyond documented hooks.
