# Context Runtime — Budget Report

## Baseline

Captured before implementation from `bash scripts/report-context-budget.sh` during Task 1:

- `hooks/session-start.sh`: 80 lines
- SessionStart `additionalContext`: 84 lines, 4093 chars
- `skills-index.json`: 391 lines, 17352 bytes
- `skills-router.json`: missing
- Total skills: 54
- Total one-level auxiliary files: 9
- Longest high-impact skills:
  - `design-workflow-design`: 293 lines, auxiliary=0
  - `build-workflow-plan`: 287 lines, auxiliary=1
  - `maintain-workflow-using-unified`: 267 lines, auxiliary=0

## After

Captured after implementation from `bash scripts/report-context-budget.sh`:

```text
Startup Surface
---------------
hooks/session-start.sh: 49 lines
SessionStart additionalContext: 13 lines, 596 chars

Routing Surface
---------------
skills-index.json: 391 lines, 17352 bytes
skills-router.json: 1 lines, 12866 bytes

Skill Lengths
-------------
 292 lines  ship-workflow-doc-sync  auxiliary=0
 285 lines  ship-workflow-land  auxiliary=0
 276 lines  verify-workflow-spec-compliance  auxiliary=0
 274 lines  ship-workflow-ship  auxiliary=0
 269 lines  build-workflow-execute  auxiliary=0
 265 lines  build-workflow-plan  auxiliary=2
 261 lines  build-quality-tdd  auxiliary=1
 241 lines  verify-workflow-review  auxiliary=1
 241 lines  ship-infrastructure-ci-cd  auxiliary=0
 239 lines  build-cognitive-source-driven  auxiliary=0
 228 lines  design-workflow-design  auxiliary=2
 225 lines  verify-workflow-debug  auxiliary=0
Total skills: 54
Total one-level auxiliary files: 13
```

## Delta

- SessionStart context reduced from 84 lines / 4093 chars to 13 lines / 596 chars.
- Compact router added: `skills-router.json`, 12866 bytes versus `skills-index.json` at 17352 bytes.
- One-level auxiliary files increased from 9 to 13.
- `maintain-workflow-using-unified` changed from 267 lines / auxiliary=0 to 187 lines / auxiliary=1.
- `design-workflow-design` changed from 293 lines / auxiliary=0 to 228 lines / auxiliary=2.
- `build-workflow-plan` changed from 287 lines / auxiliary=1 to 265 lines / auxiliary=2.

## Representative Routes

```text
simple_command_lookup: 0 skill(s) -> router-only
normal_plan: 1 skill(s) -> build-workflow-plan
ui_task: 2 skill(s) -> design-workflow-design, build-frontend-ui-engineering
adversarial_review: 3 skill(s) -> verify-workflow-review, verify-workflow-spec-compliance, verify-quality-code-quality
high_risk_ship: 2 skill(s) -> ship-workflow-ship, ship-workflow-canary
```

## Validation Evidence

Final commands:

```bash
bash scripts/tests/test-generate-router.sh
bash scripts/tests/test-hooks.sh
bash scripts/report-context-budget.sh
./validate
```

Result: all passed during build.
