# Validation Coverage Map

## Current Coverage

| Validate area | Current behavior | Coverage for this feature |
|---------------|------------------|---------------------------|
| Version metadata | Checks package/plugin version alignment and metadata description drift | not directly relevant |
| Dynamic inventory count | Rejects mutable inventory counts in root docs and metadata | covered |
| Placeholder scan | Rejects known placeholder markers | covered |
| Skill structure | Requires naming convention and core sections for every `SKILL.md` | covered |
| Skill lock | Verifies `skills-lock.json` for 54 skill hashes and 13 auxiliary hashes | covered |
| Index/router | Checks `skills-index.json`, context runtime, and generated monitors | covered |
| Agent structure | Requires frontmatter, H1, role sections, output format, severity where applicable | covered |
| Agent consumption | Ensures every `agents/*.md` persona is consumed by at least one `skills/**/*.md` contract | covered |
| Specific core consumers | Hardcodes required consumer paths for core build/design/review agents | partial |
| README agent inventory | Did not previously verify `agents/README.md` against real agent files | gap fixed in this build |
| Audit-agent write tools | Did not previously reject future write-tool drift in review/ship auditors | gap fixed in this build |
| Agent contract negative fixtures | Did not previously prove failing cases for new agent contract rules | gap fixed in this build |

## Objective Rule Candidates

| Candidate | Status | Reason |
|-----------|--------|--------|
| `agents/README.md` entries must map to real files | implemented | Prevents docs from advertising a persona that cannot be loaded |
| Every real agent file must be listed in `agents/README.md` | implemented | Prevents hidden persona drift outside the documented role system |
| Review/ship auditors that declare tools must not include write tools | implemented | Preserves audit/read-only boundary for release and review roles |
| Negative fixtures for README/file drift and auditor write tools | implemented | Prevents future checker refactors from silently dropping the new rules |
| Parse every agent output format against consuming skill templates | deferred | Useful but fragile; output templates vary by persona |
| Require tools/model for all agents | deferred | Host support and desired defaults need explicit verification |
| Scorecard thresholds in validate | rejected | Subjective quality scoring should stay in review artifacts |

## Implemented Rule Details

### Agent README Consistency

Validation now runs `scripts/check-agent-contracts.py`, which parses the first column of tables in `agents/README.md`, keeps only names that look like real agent IDs, and compares that set with `agents/*.md` excluding `README.md`.

Failure modes:
- README names an agent with no file.
- A real agent file is not listed in README.

### Audit Tool Boundary

Validation now scans frontmatter for `agents/review-*.md` and `agents/ship-*.md`. If a file declares a `tools:` list, these write-capable tool names are forbidden:

- `Edit`
- `Write`
- `Bash`
- `MultiEdit`
- `NotebookEdit`

This rule is intentionally narrow. It does not infer runtime permissions for agents that do not declare tools, and it does not judge whether read/search/browser tools are semantically ideal.

### Negative Fixture Coverage

`scripts/tests/test-agent-contracts.sh` copies `agents/` and `skills/` into temporary fixtures, then proves the checker fails for these regressions:

- `agents/README.md` lists an agent with no file.
- A real agent file is omitted from `agents/README.md`.
- A review auditor declares a write-capable tool.

`./validate` now runs this fixture test after checking the script files exist.

## Deferred Subjective Checks

The following stay out of validate:

- Whether a common-sayings table is persuasive enough.
- Whether a good/bad example is high quality.
- Whether a score of 2 should be upgraded to 3.
- Whether a phase skill is "too long" or "too short".

These require human or review-agent judgment and are recorded in `scorecard.md` instead.
