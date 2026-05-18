# Seamless Context Resume — Spec

## Status Summary
- Owner: human partner + current agent
- Date: 2026-05-18
- Status: approved

## Artifact Type
`artifact_type: software`

## Goal Alignment
- Source Goal: conversation
- Goal Status: accepted
- Goal Review Score: `11/12`

### One-line Goal
Make Unified feature progress recoverable across new agent sessions without requiring manual `/save` or `/restore` for basic stage continuity.

### Done When
- [ ] Functional: A new agent session can see the active feature path, current stage, last phase document, and recommended next command from committed project state.
- [ ] Technical: Feature state is written to `docs/features/<feature>/state.json`; no local `.claude` runtime-state file is required.
- [ ] Regression: Manual `/save` and `/restore` still work for decision-rich checkpoints and historical recovery.
- [ ] Output: Hook behavior, command docs, maintain skills, router/index/lock metadata, and validation evidence are updated.

### Stop Conditions
- [ ] Feature state cannot be derived from phase document writes without brittle heuristics.
- [ ] The design requires writing machine-local dirty state into project docs.
- [ ] SessionStart would automatically begin implementation without user-visible confirmation.
- [ ] The implementation weakens existing Unified activation, loading-tier, or checkpoint hard gates.

## Surface Assumptions
- The durable source of progress should live with the feature, not in `.claude/`.
- `docs/features/<feature>/state.json` is project state and may be committed.
- Local dirty status and branch mismatch are runtime observations, not persisted feature truth.
- `/save` remains useful for decisions, rationale, and warnings, but is no longer required for stage-level recovery.
- The first implementation should restore stage-level progress; Task N-level progress can be added later as a build ledger.

## Documentation Impact
- `doc_intent: feature_plus_project`
- `project_truth_changed: yes`
- `affected_project_docs:`
  - `AGENTS.md`
  - `commands/save.md`
  - `commands/restore.md`
  - `docs/architecture/deployment-and-runtime.md`
  - `CHANGELOG.md`
- `rationale:`
  - This changes the long-lived Unified runtime contract for how new agent sessions discover active feature progress. Root and project documentation must explain the automatic feature state boundary and the continued role of manual checkpoints.

## Problem
Unified already has stage documents and manual checkpoint commands, but basic continuation still depends on the human remembering to run `/save` or explicitly giving each new agent enough context. That makes multi-session feature work fragile: the feature chain is durable, but the "where am I now?" answer is not automatically surfaced.

The failure mode is especially visible when users intentionally split `/brainstorm`, `/refine`, `/design`, `/plan`, `/build`, `/review`, and `/ship` into separate agents to reduce context cost. Each new agent needs a compact, reliable recovery signal before it can choose the correct stage skill.

## Selected Approach
Add a feature-scoped state file that is maintained by hooks and read by SessionStart.

The canonical state file is:

```text
docs/features/<feature>/state.json
```

The file records only durable project facts:

```json
{
  "schema_version": 1,
  "feature_path": "docs/features/20260518-seamless-context-resume",
  "branch": "feature/seamless-context-resume",
  "current_stage": "build",
  "last_phase_doc": "03-plan.md",
  "next_command": "/review",
  "last_activity": "2026-05-18T10:30:00+08:00",
  "stale_reason": null
}
```

SessionStart reads the most recent non-stale feature state and injects a short resume hint into context:

- active feature path
- current stage
- last phase document
- next command
- branch match result computed at runtime
- stale warning if the state file references missing docs or an old schema

Manual `/save` and `/restore` continue to exist. Their role becomes decision recovery, not basic progress discovery.

## External References
- Search status: skipped
- Scan date: 2026-05-18
- Fact:
  - Existing hooks already include `SessionStart`, `PostToolUse Write|Edit`, and `Stop` entry points.
  - Existing `doc-tracker.sh` detects writes to feature phase documents.
  - Existing `/save` and `/restore` skills treat checkpoint files as decision-rich context, not just stage progress.
- Pattern:
  - Durable workflow state should live next to the feature evidence it describes.
  - Machine-local observations should be computed at runtime instead of committed as project truth.
- Inference:
  - `doc-tracker.sh` is the lowest-risk place to update phase-level feature state because it already observes feature document writes.
  - `session-start.sh` is the lowest-risk place to surface the state because it already emits the Boot Kernel.
- Unknown:
  - Whether build Task N progress needs a first-class ledger in v1 or should wait until the stage-level state proves useful.
- Adopt:
  - Feature-scoped `state.json`.
  - Runtime branch match checks.
  - Keep `/save` and `/restore` for deep checkpoint recovery.
- Reject:
  - Global `.claude/unified-state.json` as canonical progress state.
  - Persisted `dirty_status`.
  - Automatic implementation on SessionStart.
  - Treating a Stop hook as a complete replacement for `/save`.

## Scout Review Summary
- CEO: This improves the main user pain directly: splitting work across agents becomes routine instead of dependent on careful manual prompting.
- Eng: The safest implementation path is additive: shared state helper, then hook integration, then docs and validation. Avoid local runtime files and avoid inferring detailed build-task completion in v1.
- Design: The user-visible behavior should be quiet. New sessions should receive one compact resume hint, not a large checkpoint dump.
- Blocking resolved: Local dirty status is excluded from persistent project state.
- Important adopted: `/save` remains as a deliberate decision checkpoint instead of being removed.
- Suggestions deferred: Task-level build ledger, multi-feature picker UI, and automatic stale cleanup.

## Alternatives Considered
- Global `.claude/unified-state.json`: rejected because it does not travel with the project feature and introduces machine-local noise.
- Only improve `/save` reminders: rejected because reliability still depends on user behavior.
- Auto-run `/restore` on SessionStart: rejected because restore has a confirmation hard gate and may reference stale or mismatched branch state.
- Store state in `STATUS.md` only: rejected for v1 because hooks need machine-readable updates. A human-readable `STATUS.md` can be added later if useful.

## Scope Boundary
- **Do:**
  - Create and maintain `docs/features/<feature>/state.json`.
  - Update feature state when phase documents are written.
  - Surface resume context from SessionStart.
  - Compute branch match at runtime without persisting it.
  - Update save/restore docs and skills to explain the new boundary.
  - Add validation/tests for hook behavior and state schema.
- **Do Not:**
  - Persist `dirty_status`.
  - Write `.claude/runtime-state.json` or another local status file.
  - Automatically start `/build` or any implementation work from SessionStart.
  - Infer Task N completion from arbitrary code diffs.
  - Remove `/save` or `/restore`.

## Acceptance Criteria
- [ ] Writing `docs/features/<feature>/00-brainstorm.md` updates state to `current_stage: "brainstorm"` and `next_command: "/refine"`.
- [ ] Writing `01-spec.md` updates state to `current_stage: "refine"` and `next_command` to `/design` when design is likely required, or `/plan` when explicitly skipped.
- [ ] Writing `02-design.md` updates state to `current_stage: "design"` and `next_command: "/plan"`.
- [ ] Writing `03-plan.md` updates state to `current_stage: "plan"` and `next_command: "/build"`.
- [ ] Completing `/build` can advance state to `current_stage: "build"` and `next_command: "/review"` without adding a Task N-level ledger.
- [ ] Writing `04-review.md` updates state to `current_stage: "review"` and `next_command: "/ship"`.
- [ ] Writing `05-ship.md` updates state to `current_stage: "ship"` and `next_command: null`.
- [ ] SessionStart includes a compact resume hint when a valid active state exists.
- [ ] SessionStart warns when the current branch differs from the state `branch`, without mutating the state file.
- [ ] State validation fails if `state.json` has an unsupported schema version, missing required keys, invalid stage, invalid command, or references a missing `last_phase_doc`.
- [ ] `./validate` and `scripts/tests/test-hooks.sh` pass.

## Risks and Mitigations
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| SessionStart context grows too much | Medium | Medium | Keep resume hint under a strict line budget and reuse existing Boot Kernel budget checks. |
| Multiple active feature states exist | Medium | Medium | Choose latest `last_activity`; mark shipped states as non-active by `next_command: null`. |
| `01-spec.md` cannot reliably decide design vs plan | Medium | Low | Default to `/design` unless spec explicitly says design skipped or artifact is clearly non-user-facing. |
| Hooks update state for incomplete draft docs | Medium | Low | State records latest phase document, not approval. Plan/review/build skills still enforce approval gates. |
| Users expect `/save` to disappear | Medium | Medium | Document that automatic state restores progress, while `/save` restores decisions and rationale. |

## Verification Strategy
- Unit-style shell tests for `doc-tracker.sh` state updates.
- SessionStart test for resume hint, branch mismatch warning, and line budget.
- Validation test for malformed `state.json`.
- Full suite:
  - `bash scripts/tests/test-hooks.sh`
  - `./validate`

## Project Structure / Artifact Paths
- `docs/features/20260518-seamless-context-resume/01-spec.md`
- `docs/features/<feature>/state.json`
- `hooks/doc-tracker.sh`
- `hooks/session-start.sh`
- `hooks/phase-stop.sh`
- `scripts/tests/test-hooks.sh`
- `validate`
- `commands/save.md`
- `commands/restore.md`
- `skills/maintain-workflow-context-save/SKILL.md`
- `skills/maintain-workflow-context-restore/SKILL.md`
- `skills-lock.json`
- `skills-index.json`
- `skills-router.json`

## Boundaries
- **Always:** Keep automatic feature state small, deterministic, and project-scoped.
- **Always:** Treat branch mismatch as a runtime warning, not persisted truth.
- **Ask first:** If implementation needs a new long-lived project doc outside the affected list.
- **Ask first:** If Task N-level progress tracking requires changing the build plan format.
- **Never:** Persist local dirty status in feature state.
- **Never:** Auto-start implementation from SessionStart.
- **Never:** Replace decision checkpoints with hook-generated summaries.

## Success Criteria
- A human can start a new agent session and see the active feature progress without manually typing `/restore`.
- The new agent still respects Unified activation and stage gates.
- Feature state travels with the feature directory.
- Local machine state does not pollute committed project truth.
- Manual checkpoints remain available for richer recovery.

## Open Questions
- Should `state.json` include an explicit `status: active | paused | shipped | stale`, or is `next_command: null` enough for v1?
- Should the `/design` vs `/plan` next-command decision after `01-spec.md` be conservative (`/design` by default) or derived from `artifact_type` and design-required markers?
- Should a future build ledger live in `03-plan.md`, `state.json`, or a separate `build-state.json`?
