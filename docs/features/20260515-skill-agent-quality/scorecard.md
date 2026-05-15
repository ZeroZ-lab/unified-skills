# Skills + Agents Quality Scorecard

## Scoring Rules

Scores are baseline implementation scores, not permanent labels. A score of `3` means the file currently satisfies the axis for its role. A score of `2` means the file is usable but has a concrete improvement opportunity. A score below `2` would be a repair candidate.

### Skill Five-Axis

| Axis | 3/3 standard |
|------|--------------|
| Operability | Steps have concrete action, input, output, and checkpoint |
| Examples | Good/bad examples or reusable output templates exist where useful |
| Behavioral convergence | Red flags are detectable and failure handling is explicit |
| Cross-skill linkage | Entry, exit, prerequisites, downstream skill, and artifact path are clear |
| Sayings table | Common excuses, reality, and consequences change agent behavior |

### Agent Five-Axis

| Axis | 3/3 standard |
|------|--------------|
| Responsibility boundary | Responsible / not responsible boundaries are explicit |
| Trigger clarity | Description, README, and consuming skill agree |
| Tool boundary | Permissions match persona responsibility |
| Consumable output | Output format can be merged by the main session or consuming skill |
| Phase consistency | Persona does not change phase order, hard gates, or escalation rules |

## High-Leverage Skill Baseline

| Skill | Operability | Examples | Convergence | Linkage | Sayings | Status | Evidence |
|-------|-------------|----------|-------------|---------|---------|--------|----------|
| `define-workflow-refine` | 3 | 3 | 3 | 3 | 3 | pass | Has External Scan, Scout Army, hard gate, templates, red flags |
| `build-workflow-plan` | 3 | 3 | 3 | 3 | 3 | pass | Owns Plan Topology, subplans, matrix, review army |
| `build-workflow-execute` | 3 | 3 | 3 | 3 | 3 | pass | Owns task-by-task execution, topology rules, PLAN GAP handling |
| `build-cognitive-execution-engine` | 3 | 3 | 3 | 3 | 3 | pass | Has inline/subagent/parallel modes and merge guards |
| `verify-workflow-review` | 3 | 3 | 3 | 3 | 3 | pass | Has two-stage review hard gate and specialist escalation |
| `ship-workflow-ship` | 3 | 3 | 3 | 3 | 3 | pass | Has audit army, Go/No-Go gate, release evidence |
| `maintain-workflow-using-unified` | 3 | 3 | 3 | 3 | 3 | pass | Owns Context Runtime and loading-tier behavior |

## Remaining Skill Baseline

| Skill | Operability | Examples | Convergence | Linkage | Sayings | Status | Evidence |
|-------|-------------|----------|-------------|---------|---------|--------|----------|
| `build-backend-api-design` | 3 | 3 | 3 | 3 | 3 | pass | Contract, red flags, validation evidence present |
| `build-backend-database` | 3 | 3 | 3 | 3 | 3 | pass | Migration/query/integrity workflow is concrete |
| `build-backend-service-patterns` | 3 | 3 | 3 | 3 | 3 | pass | Resilience and communication patterns include failure handling |
| `build-cognitive-context` | 3 | 3 | 3 | 3 | 3 | pass | Context quality workflow and anti-patterns present |
| `build-cognitive-decision-record` | 3 | 3 | 3 | 3 | 3 | pass | ADR-oriented output path and decision discipline present |
| `build-cognitive-source-driven` | 3 | 3 | 3 | 3 | 3 | pass | Official-source workflow and stale-memory risk covered |
| `build-content-layout` | 3 | 3 | 3 | 3 | 3 | pass | Role, principles, decision framework, evidence present |
| `build-content-writing` | 3 | 3 | 3 | 3 | 3 | pass | Reader task and writing-quality gates present |
| `build-frontend-browser-testing` | 3 | 3 | 3 | 3 | 3 | pass | Runtime validation and browser-data safety covered |
| `build-frontend-ui-engineering` | 3 | 3 | 3 | 3 | 3 | pass | UI implementation workflow and verification present |
| `build-infrastructure-git` | 3 | 3 | 3 | 3 | 3 | pass | Git scope and verification discipline present |
| `build-quality-tdd` | 3 | 3 | 3 | 3 | 3 | pass | TDD Iron Law, RED/GREEN/REFACTOR, examples present |
| `define-cognitive-brainstorm` | 3 | 3 | 3 | 3 | 3 | pass | Clear no-persona contract, recommendation, no-go list |
| `define-workflow-spec` | 3 | 3 | 3 | 3 | 3 | pass | Refine-to-spec structure and downstream routing present |
| `design-content-direction` | 3 | 3 | 3 | 3 | 3 | pass | Design source model and evidence gates present |
| `design-content-layout` | 3 | 3 | 3 | 3 | 3 | pass | Layout method and evidence gates present |
| `design-content-script` | 3 | 3 | 3 | 3 | 3 | pass | Narrative structure and validation present |
| `design-experience-interaction` | 3 | 3 | 3 | 3 | 3 | pass | Interaction flow, states, and user path checks present |
| `design-interactive-preview` | 3 | 3 | 3 | 3 | 3 | pass | Preview generation contract and validation present |
| `design-visual-direction` | 3 | 3 | 3 | 3 | 3 | pass | Visual direction evidence and adopt/reject contract present |
| `design-workflow-design` | 3 | 3 | 3 | 3 | 3 | pass | Best-practice scan and design sync gates present |
| `maintain-infrastructure-observability` | 3 | 3 | 3 | 3 | 3 | pass | Logs/metrics/tracing workflow and red flags present |
| `maintain-team-deprecation-migration` | 3 | 3 | 3 | 3 | 3 | pass | Migration lifecycle and warning discipline present |
| `maintain-workflow-context-restore` | 3 | 3 | 3 | 3 | 3 | pass | Restore workflow and validation present |
| `maintain-workflow-context-save` | 3 | 3 | 3 | 3 | 3 | pass | Checkpoint workflow and output path present |
| `maintain-workflow-goal` | 3 | 3 | 3 | 3 | 3 | pass | Goal lifecycle and stop conditions present |
| `maintain-workflow-learn` | 3 | 3 | 3 | 3 | 3 | pass | Learning record taxonomy and invocation points present |
| `reflect-team-documentation` | 3 | 3 | 3 | 3 | 3 | pass | Documentation engineering and AI-consumption rules present |
| `reflect-team-retro` | 3 | 3 | 3 | 3 | 3 | pass | Retro extraction and action tracking present |
| `ship-artifact-export` | 3 | 3 | 3 | 3 | 3 | pass | Export verification and artifact evidence present |
| `ship-infrastructure-ci-cd` | 3 | 3 | 3 | 3 | 3 | pass | Pipeline gate and validation evidence present |
| `ship-infrastructure-deploy` | 3 | 3 | 3 | 3 | 3 | pass | Deployment rollback and safety gates present |
| `ship-workflow-canary` | 3 | 3 | 3 | 3 | 3 | pass | Canary monitoring and rollback handling present |
| `ship-workflow-doc-sync` | 3 | 3 | 3 | 3 | 3 | pass | Documentation sync and inventory checks present |
| `ship-workflow-land` | 3 | 3 | 3 | 3 | 3 | pass | Land/CI/production verification workflow present |
| `verify-content-review` | 3 | 3 | 3 | 3 | 3 | pass | Content review role, principles, evidence present |
| `verify-frontend-accessibility` | 3 | 3 | 3 | 3 | 3 | pass | WCAG workflow and validation evidence present |
| `verify-quality-code-quality` | 3 | 3 | 3 | 3 | 3 | pass | Five-axis quality review and templates present |
| `verify-quality-integration-testing` | 3 | 3 | 3 | 3 | 3 | pass | Integration boundary workflow and examples present |
| `verify-quality-performance` | 3 | 3 | 3 | 3 | 3 | pass | Measurement-first discipline and red flags present |
| `verify-quality-security` | 3 | 3 | 3 | 3 | 3 | pass | Security hard gates and threat-oriented checks present |
| `verify-quality-simplify` | 3 | 3 | 3 | 3 | 3 | pass | Simplification method and abstraction thresholds present |
| `verify-team-code-review-standards` | 3 | 3 | 3 | 3 | 3 | pass | Review severity and checklist standards present |
| `verify-visual-review` | 3 | 3 | 3 | 3 | 3 | pass | Visual review role, evidence, and examples present |
| `verify-workflow-debug` | 3 | 3 | 3 | 3 | 3 | pass | Four-phase debugging and TDD handoff present |
| `verify-workflow-receiving-review` | 3 | 3 | 3 | 3 | 3 | pass | Feedback triage and disagreement handling present |
| `verify-workflow-spec-compliance` | 3 | 3 | 3 | 3 | 3 | pass | Functional completeness gate and coverage evidence present |

## Agent Baseline

| Agent | Responsibility | Trigger | Tools | Output | Phase | Status | Evidence |
|-------|----------------|---------|-------|--------|-------|--------|----------|
| `api-designer` | 3 | 3 | 3 | 3 | 3 | pass | Worktree isolation, build consumers, output format present |
| `content-writer` | 3 | 3 | 3 | 3 | 3 | pass | Worktree isolation, design/build consumers, output format present |
| `data-architect` | 3 | 3 | 3 | 3 | 3 | pass | Worktree isolation, build consumers, output format present |
| `design-reviewer` | 3 | 3 | 2 | 3 | 3 | important | No explicit tools allowlist; acceptable until host support is verified |
| `plan-ceo-reviewer` | 3 | 3 | 2 | 3 | 3 | important | No explicit tools allowlist; output structure is valid |
| `plan-design-reviewer` | 3 | 3 | 2 | 3 | 3 | important | No explicit tools allowlist; output structure is valid |
| `plan-eng-reviewer` | 3 | 3 | 2 | 3 | 3 | important | No explicit tools allowlist; output structure is valid |
| `plan-security-reviewer` | 3 | 3 | 2 | 3 | 3 | important | No explicit tools allowlist; output structure is valid |
| `refine-ceo-scout` | 3 | 3 | 2 | 3 | 3 | important | Has model/maxTurns but no tools allowlist |
| `refine-design-scout` | 3 | 3 | 2 | 3 | 3 | important | Has model/maxTurns but no tools allowlist |
| `refine-eng-scout` | 3 | 3 | 2 | 3 | 3 | important | Has model/maxTurns but no tools allowlist |
| `requirements-analyst` | 3 | 3 | 2 | 3 | 3 | important | No explicit tools/model; output format is valid |
| `review-accessibility-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `review-code-quality-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `review-security-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `review-spec-compliance-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `review-test-engineer` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `ship-accessibility-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `ship-docs-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `ship-performance-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `ship-security-auditor` | 3 | 3 | 3 | 3 | 3 | pass | Read-oriented tools and severity output present |
| `software-engineer` | 3 | 3 | 3 | 3 | 3 | pass | Worktree isolation and TDD output format present |
| `task-planner` | 3 | 3 | 2 | 3 | 3 | important | No explicit tools/model; plan output format is valid |
| `visual-designer` | 3 | 3 | 3 | 3 | 3 | pass | Worktree isolation, design/build consumers, output format present |

## Deferred Improvements

- Add explicit tools/model conventions for refine, plan, and design reviewer personas only after verifying host support. This is Important but not Blocking.
- Keep subjective score interpretation in this file; do not turn it into validate checks.
