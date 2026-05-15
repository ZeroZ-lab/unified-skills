# Skills + Agents 质量系统 — Implementation Plan

> For execution: implement this plan task-by-task. Treat each `### Task N` block as one execution unit, and do not start the next task until the current task has passing verification evidence unless the `Parallel Execution Matrix` explicitly proves `parallel_safe: yes`.

## Artifact Type
artifact_type: software

## Inputs
- `docs/features/20260515-skill-agent-quality/00-brainstorm.md`
- `docs/features/20260515-skill-agent-quality/01-spec.md`
- `AGENTS.md`
- `CANON.md`
- `skills-router.json`
- `skills-index.json`
- `validate`
- `skills/**/*.md`
- `agents/*.md`
- `scripts/*.sh`
- `scripts/tests/*.sh`

## Design Gate

`02-design.md` is skipped for this feature.

Reason: this is an internal workflow-contract and quality-gate feature, not a user-visible UI, visual, deck, article, or document-layout deliverable. The relevant design surface is the existing workflow contract in `AGENTS.md`, `CANON.md`, `skills/`, `agents/`, and `validate`.

## Task Execution Rules

- `/plan` owns the task list; `/build` consumes it.
- Every task must record changed files, verification commands, and residual risks.
- Any missing task detail discovered during `/build` is a `PLAN GAP`; return to `/plan` instead of inventing scope during build.
- Do not modify `AGENTS.md`, `CANON.md`, `commands/`, or plugin manifests unless a task explicitly says so and the human partner approves the scope change.
- Any edit to `SKILL.md` or skill auxiliary `.md` files must be followed by lock refresh and full validation.
- Keep `agents/` as persona definitions only; do not move routing rules into agent files.

## Plan Topology

topology: gated-parallel

The shared gate is Task 1 and `plans/01-quality-contracts.md`: establish the inventory, scoring rules, and matrix schema before touching quality content. After that gate, scorecard drafting and current validation coverage analysis can run independently. Actual skill/agent edits remain serial because write scopes overlap and behavior contracts are coupled.

## Dependency Graph

```text
Task 1: Establish quality contracts
  ├── Task 2: Generate quality matrix
  ├── Task 3: Generate scorecard baseline
  └── Task 4: Audit current validation coverage
Task 5: Repair Blocking contract gaps
Task 6: Improve high-leverage workflow paths
Task 7: Improve long-tail skills and agents
Task 8: Harden objective validation rules
Task 9: Final verification and review package
```

## Subplans

| 子计划 | 状态 | Owner | Depends On | Write Scope | Verification Evidence |
|--------|------|-------|------------|-------------|-----------------------|
| `plans/01-quality-contracts.md` | gated | main agent | none | `docs/features/20260515-skill-agent-quality/quality-matrix.md`, `docs/features/20260515-skill-agent-quality/scorecard.md` | matrix schema review + inventory commands |
| `plans/02-scorecard-baseline.md` | parallel_safe | main agent | `plans/01-quality-contracts.md` | `docs/features/20260515-skill-agent-quality/scorecard.md` | scoring coverage check |
| `plans/03-validation-coverage.md` | parallel_safe | main agent | `plans/01-quality-contracts.md` | `docs/features/20260515-skill-agent-quality/validation-coverage.md` | validate coverage map |
| `plans/04-blocking-fixes.md` | serial | main agent | `plans/01-quality-contracts.md`, `plans/02-scorecard-baseline.md`, `plans/03-validation-coverage.md` | `skills/**`, `agents/**`, `scripts/**`, `validate`, `docs/features/20260515-skill-agent-quality/**` | before/after evidence + `./validate` |
| `plans/05-path-quality.md` | serial | main agent | `plans/04-blocking-fixes.md` | `skills/**`, `agents/**`, `docs/features/20260515-skill-agent-quality/**` | path spot-checks + lock refresh + `./validate` |
| `plans/06-validate-hardening.md` | serial | main agent | `plans/05-path-quality.md` | `validate`, `scripts/tests/**`, `docs/features/20260515-skill-agent-quality/**` | targeted failing/proving checks + `./validate` |

## Parallel Execution Matrix

| 子计划 A | 子计划 B | parallel_safe | 原因 |
|----------|----------|---------------|------|
| `plans/02-scorecard-baseline.md` | `plans/03-validation-coverage.md` | yes | Write Scope 不重叠；两者都只读取 shared matrix contract |
| `plans/04-blocking-fixes.md` | `plans/05-path-quality.md` | no | path 优化必须建立在 Blocking 修复之后 |
| `plans/05-path-quality.md` | `plans/06-validate-hardening.md` | no | validate 规则应从已稳定的修复类型中沉淀 |

## Integration Order

1. Complete quality contracts and inventory baseline.
2. Complete scorecard baseline and validation coverage map.
3. Repair all Blocking contract gaps or record explicit human partner decisions.
4. Improve high-leverage workflow paths.
5. Improve long-tail skills and agents.
6. Add only objective validate hardening.
7. Run full validation and prepare review package.

## Tasks

### Task 1: Establish Quality Contracts

**Files:**
- Create/Modify: `docs/features/20260515-skill-agent-quality/quality-matrix.md`
- Create/Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`
- Read: `docs/features/20260515-skill-agent-quality/01-spec.md`, `AGENTS.md`, `skills-index.json`, `skills-router.json`, `validate`

**Depends On:** none

- [ ] **Step 1: Capture current inventory from source**
  - Run: `find skills -name SKILL.md | wc -l`
  - Run: `find agents -maxdepth 1 -type f -name '*.md' ! -name README.md | wc -l`
  - Record the commands and counts in `quality-matrix.md`; do not use stale static counts.
- [ ] **Step 2: Define matrix schema**
  - Add columns for stage skill, trigger, agent, sub-skill, inputs, output contract, escalation rule, validate coverage, and uncovered risk.
- [ ] **Step 3: Define scorecard schema**
  - Add Skill Five-Axis and Agent Five-Axis scoring tables with 0-3 criteria.
- [ ] **Step 4: Verify contract files are internally consistent**
  - Run: `rg -n "agents/.*\\.md|Plan Review Army|Idea Scout Army|Ship Audit Army|Review Army" skills agents AGENTS.md`
  - Confirm every matrix category has a source.

**Verification Evidence:**
- `quality-matrix.md` exists and includes source inventory commands.
- `scorecard.md` exists and includes both scoring models.
- No implementation files changed.

### Task 2: Generate Skill-Agent Quality Matrix

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/quality-matrix.md`
- Read: `skills/**/*.md`, `agents/*.md`, `agents/README.md`, `validate`

**Depends On:** Task 1

- [ ] **Step 1: Extract all agent consumption tokens**
  - Run: `rg -n "agents/[a-z0-9-]+\\.md" skills agents validate`
  - Group findings by stage path.
- [ ] **Step 2: Map core stage paths**
  - Cover `/brainstorm`, `/refine`, `/design`, `/plan`, `/build`, `/review`, `/ship`, `/save`, `/restore`, `/learn`, `/goal`.
- [ ] **Step 3: Mark orphan or future agents**
  - Any `agents/*.md` without a skill consumer must be marked `Blocking` unless explicitly documented as future scope.
- [ ] **Step 4: Record validate coverage**
  - For each matrix row, mark whether current `validate` checks existence, output structure, dispatch token, or nothing.

**Verification Evidence:**
- Matrix includes every agent file or a clear exclusion reason for `agents/README.md`.
- Matrix includes all high-leverage paths from the spec.

### Task 3: Generate Scorecard Baseline

**Files:**
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`
- Read: `skills/**/*.md`, `agents/*.md`

**Depends On:** Task 1

- [ ] **Step 1: Score all high-leverage workflow skills**
  - Start with `define-workflow-refine`, `build-workflow-plan`, `build-workflow-execute`, `verify-workflow-review`, `ship-workflow-ship`.
- [ ] **Step 2: Score all agents on the high-leverage paths**
  - Include requirements, task planner, implementers, plan reviewers, review auditors, and ship auditors.
- [ ] **Step 3: Score remaining files in batches**
  - Record lower-confidence scores explicitly as `needs second pass`.
- [ ] **Step 4: Sort by risk**
  - Rank items by Blocking gap first, then low score, then workflow leverage.

**Verification Evidence:**
- Scorecard includes a row for every in-scope `SKILL.md` and `agents/*.md`.
- Each low score has a concrete reason tied to the scoring rubric.

### Task 4: Audit Existing Validation Coverage

**Files:**
- Create: `docs/features/20260515-skill-agent-quality/validation-coverage.md`
- Read: `validate`, `scripts/tests/*.sh`, `scripts/generate-index.sh`, `scripts/generate-router.sh`, `scripts/update-lock.sh`

**Depends On:** Task 1

- [ ] **Step 1: Map current `validate` sections**
  - Summarize what each relevant section checks for skills, agents, index, router, lock, and stale contract text.
- [ ] **Step 2: Compare against quality matrix risks**
  - Identify which risks are already covered, partially covered, or not covered.
- [ ] **Step 3: Propose objective rule candidates**
  - Only list rules that can be checked with low false positives.
- [ ] **Step 4: Mark deferred subjective checks**
  - Keep prose quality, example strength, and score interpretation out of validate.

**Verification Evidence:**
- `validation-coverage.md` links each proposed rule to a specific matrix risk.
- No validate code changed in this task.

### Task 5: Repair Blocking Contract Gaps

**Files:**
- Modify as needed: `skills/**`, `agents/**`, `docs/features/20260515-skill-agent-quality/**`
- Modify only if justified: `scripts/**`, `validate`

**Depends On:** Tasks 2, 3, 4

- [ ] **Step 1: Select Blocking findings**
  - Only address rows marked Blocking in `quality-matrix.md` or `scorecard.md`.
- [ ] **Step 2: Patch the contract at the authoritative layer**
  - If routing or invocation is wrong, patch the stage skill.
  - If persona output is wrong, patch the agent.
  - If existing automation should catch it, patch validate or a script test.
- [ ] **Step 3: Refresh generated artifacts**
  - If SKILL.md changed, run `scripts/update-lock.sh <skill>` for affected skills.
  - If router/index source changed, run `scripts/generate-index.sh` and `scripts/generate-router.sh`.
- [ ] **Step 4: Verify**
  - Run targeted grep for the fixed token or output contract.
  - Run: `./validate`

**Verification Evidence:**
- Before/after evidence recorded in `quality-matrix.md`.
- `./validate` passes.

### Task 6: Improve High-Leverage Workflow Paths

**Files:**
- Modify as needed: `skills/define-workflow-refine/**`, `skills/build-workflow-plan/**`, `skills/build-workflow-execute/**`, `skills/verify-workflow-review/**`, `skills/ship-workflow-ship/**`
- Modify as needed: corresponding `agents/*.md`
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 5

- [ ] **Step 1: Improve `/refine` path**
  - Ensure requirements analyst and scout outputs are directly consumable by `01-spec.md`.
- [ ] **Step 2: Improve `/plan` path**
  - Ensure plan reviewer feedback maps to `03-plan.md`, subplans, and Parallel Execution Matrix.
- [ ] **Step 3: Improve `/build` path**
  - Ensure task planner, execution engine, and implementer personas share the same Task N / Write Scope contract.
- [ ] **Step 4: Improve `/review` path**
  - Ensure two-stage review and specialist auditors have consistent output severity and gate behavior.
- [ ] **Step 5: Improve `/ship` path**
  - Ensure ship auditors feed the Go/No-Go decision and docs/export evidence.
- [ ] **Step 6: Refresh and verify**
  - Update lock entries for edited skill files.
  - Run: `./validate`

**Verification Evidence:**
- Scorecard shows improved scores or explicit defer reasons for each high-leverage path.
- `./validate` passes.

### Task 7: Improve Long-Tail Skills and Agents

**Files:**
- Modify as needed: remaining `skills/**`, `agents/*.md`
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`

**Depends On:** Task 6

- [ ] **Step 1: Batch by phase**
  - Work in define/design/build/verify/ship/maintain/reflect order.
- [ ] **Step 2: Apply scoring-driven fixes**
  - Prefer concrete steps, output contracts, red flag actions, and verification evidence.
- [ ] **Step 3: Avoid prose inflation**
  - Reject edits that add length without improving a scorecard axis.
- [ ] **Step 4: Refresh and verify per batch**
  - Update lock entries for edited skill files.
  - Run: `./validate`

**Verification Evidence:**
- Scorecard records final scores and remaining deferred items.
- Each batch has validation evidence.

### Task 8: Harden Objective Validation Rules

**Files:**
- Modify: `validate`
- Modify: `scripts/tests/*.sh` if a dedicated test is needed
- Modify: `docs/features/20260515-skill-agent-quality/validation-coverage.md`

**Depends On:** Task 7

- [ ] **Step 1: Select objective rule candidates**
  - Choose only rules proven by Tasks 5-7, such as missing agent tokens, broken output structure, or unsafe audit-agent tools.
- [ ] **Step 2: Add one rule at a time**
  - Each rule must have a clear failure message and low false-positive risk.
- [ ] **Step 3: Prove rule behavior**
  - Use existing shell tests where available, or add a focused script test.
- [ ] **Step 4: Run full validation**
  - Run: `./validate`

**Verification Evidence:**
- `validation-coverage.md` records each new rule and the drift type it catches.
- `./validate` passes.

### Task 9: Final Verification and Review Package

**Files:**
- Create: `docs/features/20260515-skill-agent-quality/04-review.md`
- Modify: `docs/features/20260515-skill-agent-quality/quality-matrix.md`
- Modify: `docs/features/20260515-skill-agent-quality/scorecard.md`
- Modify: `docs/features/20260515-skill-agent-quality/validation-coverage.md`

**Depends On:** Task 8

- [ ] **Step 1: Run full validation suite**
  - Run: `./validate`
  - If relevant to host cache, run: `CHECK_CODEX_CACHE=1 ./validate` and record installation-state failures separately.
- [ ] **Step 2: Perform spec coverage review**
  - Map every acceptance criterion in `01-spec.md` to completed evidence.
- [ ] **Step 3: Perform quality review**
  - Review changed contracts for correctness, maintainability, and unintended behavior changes.
- [ ] **Step 4: Prepare handoff**
  - Record remaining deferred items and human partner decision points.

**Verification Evidence:**
- `04-review.md` contains spec coverage, quality findings, executed commands, and residual risks.
- Final `git status --short` is recorded in the review package.

## Checkpoints

### Checkpoint A: Phase 0 Gate

Must pass before any skill or agent content edits:
- [ ] `quality-matrix.md` exists and has full inventory coverage.
- [ ] `scorecard.md` exists and has scoring rubric plus baseline rows.
- [ ] `validation-coverage.md` exists and maps current validate coverage.

### Checkpoint B: Blocking Repair Gate

Must pass before high-leverage quality improvements:
- [ ] All Blocking findings are fixed or explicitly escalated to the human partner.
- [ ] `./validate` passes.
- [ ] Any SKILL.md edits have matching `skills-lock.json` updates.

### Checkpoint C: Automation Gate

Must pass before final review:
- [ ] New validate rules are objective and tied to fixed drift types.
- [ ] New rules have clear failure messages.
- [ ] `./validate` passes.

## Plan Review Summary

Plan Review was performed inline in the main session rather than by subagent dispatch.

### CEO Perspective

Verdict: Important

- [Important] The plan correctly starts with a matrix and baseline instead of editing prose first. This keeps the work tied to behavior and verification.
- [Important] Success depends on not treating all scores as equal. Blocking contract drift and high-leverage paths should stay ahead of long-tail polish.
- [Suggestion] Old `skills-optimization` and `agent-architect` documents should be reconciled after Phase 0, not before.

Plan Impact:
- Adopt: Phase 0 gate and Blocking repair gate.
- Reject: direct full-repo rewrite.
- Ask user: none before writing the plan.

### Engineering Perspective

Verdict: Important

- [Important] `gated-parallel` is appropriate: scorecard and validation coverage can be independent after contracts, but actual edits overlap and should remain serial.
- [Important] Lock refresh and generated index/router steps need to be attached to the tasks that edit skills, not left as a final cleanup.
- [Suggestion] Validate hardening should happen after real fixes so rules are based on observed drift, not speculative style preferences.

Plan Impact:
- Adopt: explicit refresh commands in Tasks 5-7.
- Adopt: validate hardening only after path and long-tail quality work.
- Reject: broad subjective validate rules.

### Design Perspective

Skipped. This is not a user-visible UI, deck, visual, article, or layout deliverable.

### Security Perspective

Skipped for dedicated review. The plan does not introduce authentication, authorization, data storage, secrets, or production deployment changes. Audit-agent tool boundaries remain covered as an engineering contract risk in Tasks 4 and 8.

## Approval Gate

Do not start `/build` until the human partner approves this plan or requests changes.
