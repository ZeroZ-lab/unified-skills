# Skills + Agents Quality Matrix

## Build Record

- Plan source: `docs/features/20260515-skill-agent-quality/03-plan.md`
- Execution mode: inline serial
- Parallel downgrade: `plans/02-scorecard-baseline.md` and `plans/03-validation-coverage.md` are `parallel_safe`, but this build ran them serially in the main session because no subagent fan-out was explicitly requested.
- Inventory commands:
  - `find skills -name SKILL.md | wc -l` -> `54`
  - `find agents -maxdepth 1 -type f -name '*.md' ! -name README.md | wc -l` -> `24`
  - `find skills -maxdepth 2 -type f \( -name 'SKILL.md' -o -name '*.md' \) | wc -l` -> `67` skill + auxiliary markdown files

## Matrix Legend

| Field | Meaning |
|-------|---------|
| Stage path | User-visible phase or command-equivalent path |
| Authority | File that owns behavior or dispatch rules |
| Agents | Persona files selected by that authority |
| Required skills | Skills or sub-skills that must be loaded or followed |
| Output contract | Artifact consumed by the next phase |
| Escalation | Risk or `--full` rule that adds roles |
| Validate coverage | `covered`, `partial`, `uncovered`, or `not applicable` |
| Residual risk | What still needs human review or later hardening |

## Stage Path Matrix

| Stage path | Authority | Agents | Required skills | Output contract | Escalation | Validate coverage | Residual risk |
|------------|-----------|--------|-----------------|-----------------|------------|-------------------|---------------|
| `/brainstorm` | `skills/define-cognitive-brainstorm/SKILL.md` | none; current agent only | `define-cognitive-brainstorm` | `00-brainstorm.md` | none | covered: validate checks no dedicated persona wording | Subjective brainstorm quality remains manual |
| `/refine` | `skills/define-workflow-refine/SKILL.md` | `requirements-analyst`, `refine-ceo-scout`, `refine-eng-scout`, `refine-design-scout` | `define-workflow-refine`, `define-workflow-spec` downstream | `01-spec.md` | standard: CEO + Eng; design when UI/experience-sensitive | partial: validate checks scout files and global consumption | It does not verify every scout output field against `01-spec.md` |
| `/design` | `skills/design-workflow-design/SKILL.md` | `requirements-analyst`, `content-writer`, `visual-designer`, `design-reviewer` | design workflow plus artifact-specific design skills | `02-design.md`, `DESIGN.md`, optional visual artifacts | artifact type and design risk | partial: validate checks design evidence gates and design-reviewer blocking phrases | It does not verify content/visual agent output details |
| `/plan` | `skills/build-workflow-plan/SKILL.md`, `skills/build-workflow-plan/plan-review.md` | `task-planner`, `plan-ceo-reviewer`, `plan-eng-reviewer`, `plan-design-reviewer`, `plan-security-reviewer` | `build-workflow-plan` | `03-plan.md`, optional `plans/*.md` | standard: CEO + Eng; full or high-risk: all | partial: validate checks agent files are consumed and plan contract exists | It did not previously verify `agents/README.md` entries against real files |
| `/build` | `skills/build-workflow-execute/SKILL.md`, `skills/build-cognitive-execution-engine/SKILL.md` | `task-planner`, `software-engineer`, `api-designer`, `data-architect`, `content-writer`, `visual-designer` | `build-workflow-execute`, `build-cognitive-execution-engine`, `build-quality-tdd` for software | changed files, verification evidence, optional ADR | topology-driven inline/subagent/parallel | covered for core consumers and task-by-task contract | Real changed_files subset checks are runtime discipline, not static validate |
| `/review` | `skills/verify-workflow-review/SKILL.md`, `skills/verify-workflow-review/review-guidance.md` | `review-spec-compliance-auditor`, `review-code-quality-auditor`, optional security/test/accessibility auditors | `verify-workflow-spec-compliance`, `verify-quality-code-quality`, risk specialists | `04-review.md` | security/test/UI/`--full` | partial: validate checks core reviewers and review guidance specialist tokens | It does not parse every auditor tools list for write-tool drift until this build |
| `/ship` | `skills/ship-workflow-ship/SKILL.md` | `ship-security-auditor`, `ship-performance-auditor`, `ship-accessibility-auditor`, `ship-docs-auditor` | `ship-workflow-ship`, optional ship specialists | `05-ship.md` and release/export evidence | release risk; at least security + docs | partial: global consumption check covers ship agents | Dedicated README/file alignment and read-only tool checks are added in this build |
| `/save` | `skills/maintain-workflow-context-save/SKILL.md` | none | `maintain-workflow-context-save` | checkpoint artifact | none | covered for skill structure and lock | Quality remains manual |
| `/restore` | `skills/maintain-workflow-context-restore/SKILL.md` | none | `maintain-workflow-context-restore` | restored context | none | covered for skill structure and lock | Quality remains manual |
| `/learn` | `skills/maintain-workflow-learn/SKILL.md` | none | `maintain-workflow-learn` | learning record | none | covered for skill structure and lock | Quality remains manual |
| `/goal` | `skills/maintain-workflow-goal/SKILL.md` | none | `maintain-workflow-goal` | Codex goal lifecycle state | none | covered for skill structure and lock | Runtime goal API behavior is external to static validate |

## Agent Inventory Matrix

| Agent | Primary consuming path | Consumed by `skills/**/*.md` | README listed | Validate status | Risk |
|-------|------------------------|------------------------------|---------------|-----------------|------|
| `api-designer` | `/build` | yes | yes | covered | none |
| `content-writer` | `/design`, `/build` | yes | yes | covered | none |
| `data-architect` | `/build` | yes | yes | covered | none |
| `design-reviewer` | `/design` | yes | yes | covered | none |
| `plan-ceo-reviewer` | `/plan` | yes | yes | covered | none |
| `plan-design-reviewer` | `/plan` | yes | yes | covered | none |
| `plan-eng-reviewer` | `/plan` | yes | yes | covered | none |
| `plan-security-reviewer` | `/plan` | yes | yes | covered | none |
| `refine-ceo-scout` | `/refine` | yes | yes | covered | none |
| `refine-design-scout` | `/refine` | yes | yes | covered | none |
| `refine-eng-scout` | `/refine` | yes | yes | covered | none |
| `requirements-analyst` | `/refine`, `/design` | yes | yes | covered | none |
| `review-accessibility-auditor` | `/review` | yes | yes | covered | no write tools declared |
| `review-code-quality-auditor` | `/review` | yes | yes | covered | no write tools declared |
| `review-security-auditor` | `/review` | yes | yes | covered | no write tools declared |
| `review-spec-compliance-auditor` | `/review` | yes | yes | covered | no write tools declared |
| `review-test-engineer` | `/review` | yes | yes | covered | no write tools declared |
| `ship-accessibility-auditor` | `/ship` | yes | yes | covered | no write tools declared |
| `ship-docs-auditor` | `/ship` | yes | yes | covered | no write tools declared |
| `ship-performance-auditor` | `/ship` | yes | yes | covered | no write tools declared |
| `ship-security-auditor` | `/ship` | yes | yes | covered | no write tools declared |
| `software-engineer` | `/build` | yes | yes | covered | none |
| `task-planner` | `/plan`, `/build` | yes | yes | covered | none |
| `visual-designer` | `/design`, `/build` | yes | yes | covered | none |

## Blocking Findings

No Blocking skill-agent dispatch gaps were found in the current source tree.

Evidence:
- Every `agents/*.md` persona file is consumed by at least one `skills/**/*.md` contract.
- Every agent listed in `agents/README.md` has a corresponding `agents/<name>.md` file.
- No review or ship auditor currently declares `Edit`, `Write`, `Bash`, `MultiEdit`, or `NotebookEdit` in frontmatter tools.

## Important Findings

- `validate` already checks agent structure and global consumption, but it did not explicitly verify `agents/README.md` against the real agent file set. This build adds that objective rule.
- `validate` did not explicitly guard against future review/ship auditors declaring write tools. This build adds that objective rule.
- Scorecard quality remains a human-reviewed baseline. The repository should not turn subjective prose quality into brittle shell checks.
