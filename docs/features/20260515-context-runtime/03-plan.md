# Context Runtime — Plan

## Inputs
- Spec: `docs/features/20260515-context-runtime/01-spec.md`
- Design: `docs/features/20260515-context-runtime/02-design.md`
- Artifact Type: `software`

## Plan Topology
- Topology: `gated-parallel`
- Execution Reality: serial for v1
- Reason: the work spans shared global contracts (`validate`, `skills-index.json`, `skills-lock.json`, `hooks/session-start.sh`, `maintain-workflow-using-unified`). Parallel writes would overlap and create contract drift risk.
- Build Rule: do not use worker fan-out unless a future revision marks a subplan `parallel_safe: yes`.

## Subplans

| Subplan | Responsibility | Status | Write Scope |
|---------|----------------|--------|-------------|
| `plans/01-runtime-contracts.md` | compact router, budget report, generation tests | gated | `skills-router.json`, `scripts/generate-router.sh`, `scripts/report-context-budget.sh`, `scripts/tests/test-generate-router.sh` |
| `plans/02-loading-surface.md` | Boot Kernel and runtime loading guide | serial | `hooks/session-start.sh`, `scripts/tests/test-hooks.sh`, `skills/maintain-workflow-using-unified/SKILL.md` |
| `plans/03-skill-slimming.md` | entry-first shape for three high-impact skills | serial | selected skill directories, one-level auxiliary `.md`, `skills-lock.json`, `skills-index.json` |
| `plans/04-validation-evidence.md` | validation integration, docs evidence, final checks | serial | `validate`, feature docs, generated reports |

## Parallel Execution Matrix

| Pair | parallel_safe | Reason |
|------|---------------|--------|
| 01 + 02 | no | both define runtime loading semantics and must agree on router fields and tier names |
| 01 + 04 | no | validation depends on router data shape finalized in 01 |
| 02 + 03 | no | slimming changes `maintain-workflow-using-unified` and lock hashes touched by 02 |
| 03 + 04 | no | validation thresholds must reflect actual slimming state |

## Integration Order
1. Runtime contracts and reports.
2. Loading surface: SessionStart and `maintain-workflow-using-unified`.
3. Skill slimming pass.
4. Validation hardening and evidence report.

## Shared Contracts
- Loading tiers: `light`, `standard`, `expanded`, `full`
- Standard budget: one primary workflow skill plus at most one specialist skill.
- Expanded budget: one primary workflow skill plus at most two specialist skills.
- Full mode trigger: `--full`, adversarial review, full-body check, high-risk release, or explicit user request.
- Auxiliary file rule: v1 uses one-level auxiliary `.md` files only.
- No nested skill directories in v1.
- No separate router persona.

## Tasks

### Task 1: Baseline Report

**Files:**
- Create: `scripts/report-context-budget.sh`
- Reference: `hooks/session-start.sh`, `skills-index.json`, `skills/*/SKILL.md`

**Depends On:** none

- [ ] **Step 1: Define report output**
  - Include SessionStart line count, `skills-index.json` line count, `skills-router.json` status, top long `SKILL.md` files, auxiliary count, and sample route load counts.
  - Expected output is plain text so it can be pasted into docs and CI logs.
- [ ] **Step 2: Implement deterministic report script**
  - Use Bash + Python standard library only.
  - Do not mutate repository files.
- [ ] **Step 3: Verify report**
  - Run: `bash scripts/report-context-budget.sh`
  - Expected: exits 0 and prints current baseline, including long skill files.

### Task 2: Compact Router

**Files:**
- Create: `scripts/generate-router.sh`
- Create: `scripts/tests/test-generate-router.sh`
- Create/Modify: `skills-router.json`

**Depends On:** Task 1

- [ ] **Step 1: Write router generation test**
  - Test valid JSON, all referenced skills exist, version matches `package.json`, and dry-run does not mutate files.
  - Run: `bash scripts/tests/test-generate-router.sh` -> FAIL before implementation.
- [ ] **Step 2: Generate compact router**
  - Derive skill names, phases, roles, descriptions, trigger matches, risk matches, and budgets from existing metadata where possible.
  - Preserve `skills-index.json` as inventory truth.
- [ ] **Step 3: Verify router**
  - Run: `bash scripts/generate-router.sh`
  - Run: `bash scripts/tests/test-generate-router.sh`
  - Expected: generated `skills-router.json` is stable and references no missing skills.

### Task 3: Validation Budget Gate

**Files:**
- Modify: `validate`
- Read: `skills-router.json`, `skills-index.json`, `skills/maintain-workflow-using-unified/SKILL.md`

**Depends On:** Task 2

- [ ] **Step 1: Add failing validation cases mentally before patching**
  - Missing router, stale version, missing skill reference, and route over budget must fail.
- [ ] **Step 2: Add context-runtime validation block**
  - Check router exists, version matches, referenced skills exist, tier budgets are present, and standard/expanded routes fit budget rules.
  - Check `maintain-workflow-using-unified` contains tier wording and no longer contains the old 1% loading rule.
- [ ] **Step 3: Verify targeted validation**
  - Run: `./validate`
  - Expected before later tasks: if the guide still contains old wording, this task may fail until Task 5; record that dependency in build notes.

### Task 4: Boot Kernel

**Files:**
- Modify: `hooks/session-start.sh`
- Modify: `scripts/tests/test-hooks.sh`

**Depends On:** Task 2

- [ ] **Step 1: Update hook test expectation**
  - Test should require Boot Kernel phrases and reject full command map injection.
  - Run: `bash scripts/tests/test-hooks.sh` -> FAIL before hook patch.
- [ ] **Step 2: Replace broad injection**
  - SessionStart should emit compact runtime guidance only.
  - Keep platform-specific Codex/Claude hint if still useful, but do not include the full command mapping table.
- [ ] **Step 3: Verify hook behavior**
  - Run: `bash scripts/tests/test-hooks.sh`
  - Expected: SessionStart emits Boot Kernel, careful still denies destructive Codex commands, freeze still protects boundaries.

### Task 5: Loading Guide

**Files:**
- Modify: `skills/maintain-workflow-using-unified/SKILL.md`
- Modify: `skills-index.json` if frontmatter description changes
- Modify: `skills-lock.json`

**Depends On:** Task 2, Task 3

- [ ] **Step 1: Preserve current hard gates**
  - Keep active skill discovery, AGENTS single-entry priority, and explicit "Using [skill]" declaration.
- [ ] **Step 2: Replace full-index-first discovery**
  - New flow: compact router → tier decision → primary skill → optional specialist by named trigger/risk.
- [ ] **Step 3: Remove old over-loading rule**
  - Replace the "1% possible relevance" rule with tier-specific expansion criteria.
- [ ] **Step 4: Refresh generated contract files**
  - Run: `bash scripts/generate-index.sh`
  - Refresh `skills-lock.json` using the repo's existing lock refresh method.
- [ ] **Step 5: Verify guide contract**
  - Run: `./validate`
  - Expected: loading contract passes with new tier wording and no stale full-index-first requirement.

### Task 6: Slim Using Guide

**Files:**
- Modify: `skills/maintain-workflow-using-unified/SKILL.md`
- Create: `skills/maintain-workflow-using-unified/skill-reference.md`
- Modify: `skills-lock.json`

**Depends On:** Task 5

- [ ] **Step 1: Move quick reference**
  - Keep activation, tier selection, and hard gates in the main file.
  - Move long skill category quick reference into `skill-reference.md`.
- [ ] **Step 2: Ensure explicit auxiliary reference**
  - Main `SKILL.md` must name `skill-reference.md`.
- [ ] **Step 3: Verify lock**
  - Refresh `skills-lock.json`.
  - Run: `./validate`
  - Expected: auxiliary hash is present and referenced.

### Task 7: Slim Design Skill

**Files:**
- Modify: `skills/design-workflow-design/SKILL.md`
- Create: `skills/design-workflow-design/visual-generation.md`
- Create: `skills/design-workflow-design/design-sync.md`
- Modify: `skills-lock.json`

**Depends On:** Task 6

- [ ] **Step 1: Move optional visual generation**
  - Move Step 3.5 Codex visual generation details into `visual-generation.md`.
  - Main file keeps trigger summary and hard gate.
- [ ] **Step 2: Move DESIGN.md sync mechanics**
  - Move detailed token extraction and merge rules into `design-sync.md`.
  - Main file keeps required output and approval gate.
- [ ] **Step 3: Verify design gate**
  - Run: `./validate`
  - Expected: existing design evidence checks still pass, including required phrases.

### Task 8: Slim Plan Skill

**Files:**
- Modify: `skills/build-workflow-plan/SKILL.md`
- Modify/Create: `skills/build-workflow-plan/plan-review.md`
- Modify: `skills-lock.json`

**Depends On:** Task 7

- [ ] **Step 1: Move review army details**
  - Keep plan topology, dependency graph, task writing rules, and checkpoint gates in main file.
  - Move detailed Plan Review Army prompts and feedback rules into `plan-review.md`.
- [ ] **Step 2: Preserve task template reference**
  - Keep existing `task-templates.md` reference.
  - Add explicit `plan-review.md` reference.
- [ ] **Step 3: Verify plan contract**
  - Run: `./validate`
  - Expected: task-by-task, multi-plan, and auxiliary hash checks pass.

### Task 9: Evidence Report

**Files:**
- Create/Modify: `docs/features/20260515-context-runtime/04-review.md` only if doing review in same pass
- Create: `docs/features/20260515-context-runtime/context-budget-report.md`

**Depends On:** Task 8

- [ ] **Step 1: Capture before/after report**
  - Run: `bash scripts/report-context-budget.sh`
  - Save summarized output into `context-budget-report.md`.
- [ ] **Step 2: Record representative route samples**
  - Include examples for simple command lookup, normal build task, UI task, adversarial review, and high-risk ship.
- [ ] **Step 3: Verify full suite**
  - Run: `bash scripts/tests/test-generate-router.sh`
  - Run: `bash scripts/tests/test-hooks.sh`
  - Run: `./validate`
  - Expected: all pass.

## Checkpoints

### Checkpoint A: Runtime Contract
- After Task 3.
- Must pass: router test, context-runtime validation block except known guide dependency if Task 5 not yet complete.
- Blocking if router/index drift exists.

### Checkpoint B: Loading Surface
- After Task 5.
- Must pass: hook test and `./validate`.
- Blocking if old 1% loading rule remains.

### Checkpoint C: Slimming
- After Task 8.
- Must pass: `./validate` with updated `skills-lock.json`.
- Blocking if auxiliary files are not referenced from main `SKILL.md`.

### Checkpoint D: Final Evidence
- After Task 9.
- Must pass: router test, hook test, and `./validate`.
- Blocking if no before/after report is available.

## Plan Review Summary

### CEO Review
- Verdict: Important.
- Finding: The plan keeps the product promise clear: less default context without weakening discipline.
- Adopted: Boot Kernel and compact router ship before skill slimming, so value appears early.

### Eng Review
- Verdict: Blocking resolved.
- Finding: Shared files make parallel implementation unsafe.
- Adopted: All subplans are serial unless a future revision proves non-overlapping write scopes.

### Design Review
- Verdict: Important.
- Finding: The agent-facing experience must be audible and predictable.
- Adopted: Loading tier declaration is part of acceptance, not optional copy.

### Security Review
- Verdict: Suggestion.
- Finding: The change does not alter secrets, auth, or external permissions.
- Adopted: No full security subplan; release review can still add security if runtime scripts start reading sensitive files.

## Spec Coverage
- Compact routing surface: Task 2, Task 3.
- Loading tiers: Task 3, Task 5.
- Boot Kernel: Task 4.
- Context budget validation: Task 1, Task 3, Task 9.
- Three high-impact skills slimmed: Task 6, Task 7, Task 8.
- No nested directories in v1: enforced by task write scopes and auxiliary-file rules.
- Preserve AGENTS and real `skills/`: all tasks keep existing entry model.

## User Approval Gate
Plan approval is required before `/build`. No implementation should start until this file and subplans are approved.
