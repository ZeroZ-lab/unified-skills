# Deployment And Runtime

## Purpose

This document records local runtime behavior for Unified Skills: hooks, generated state, validation gates, and the boundaries between project truth and machine-local observations.

## Runtime Entry

`AGENTS.md` is the project-entry contract. `CLAUDE.md` remains a pointer for Claude-specific loading behavior. Codex consumes `AGENTS.md`, `skills-router.json`, and real `skills/` entries when the user explicitly enters the Unified workflow.

Unified remains opt-in:

- ordinary repo questions stay in direct mode
- ordinary coding requests stay in direct mode
- explicit `/brainstorm`, `/refine`, `/design`, `/plan`, `/build`, `/review`, `/ship`, `/save`, `/restore`, `/learn`, or `/help` activates router-first discovery

## Feature State Resume

Feature stage continuity is project-scoped and stored beside feature evidence:

```text
docs/features/<feature>/state.json
```

The state file is maintained by hooks and validated by `./validate`. It records only durable project facts:

- `schema_version`
- `feature_path`
- `branch`
- `current_stage`
- `last_phase_doc`
- `next_command`
- `last_activity`
- `stale_reason`

It must not record local runtime observations such as `dirty_status`, current branch match result, host name, user name, local absolute working directory, or other machine-specific state.

## Hook Behavior

`hooks/doc-tracker.sh` observes writes to `docs/features/*/00-brainstorm.md` through `05-ship.md`. On phase document writes it:

- emits a compact progress message
- updates `docs/features/<feature>/state.json`
- leaves non-feature writes untouched

`hooks/session-start.sh` emits the Boot Kernel. If a valid active feature state exists, it appends a short resume hint containing the feature path, current stage, last phase document, next command, and runtime branch-match warning if applicable. This hint does not automatically activate Unified runtime and does not start implementation.

`hooks/phase-stop.sh` distinguishes automatic state from manual checkpoints. When feature state already exists, it may suggest `/save` only for decision-rich context, not for basic stage continuity.

## Checkpoints

`/save` and `/restore` are still supported. Their job is decision recovery:

- why a decision was made
- what alternatives were rejected
- what warnings or blockers matter
- what remaining work is not obvious from phase documents

Stage-level recovery comes from `state.json`; decision-level recovery comes from checkpoint files in `.claude/checkpoints/`.

## Validation

`./validate` checks committed `docs/features/*/state.json` files through `scripts/unified-state.py`. Validation fails when state files:

- use an unsupported schema version
- omit required keys
- include forbidden local-state keys
- point at a missing phase document
- mismatch the containing feature directory
- declare a stage or next command inconsistent with the last phase document

Focused tests live in:

```bash
bash scripts/tests/test-unified-state.sh
bash scripts/tests/test-hooks.sh
```

## Rollback Entry

To disable automatic feature resume without removing checkpoints:

1. Revert the `doc-tracker.sh` state update call.
2. Revert the `session-start.sh` resume hint block.
3. Keep `/save` and `/restore` unchanged.
4. Run `bash scripts/tests/test-hooks.sh` and `./validate`.

Do not delete existing `docs/features/*/state.json` files during rollback unless the corresponding feature state schema is intentionally deprecated and documented.
