# Changelog

## [1.1.0] - 2026-04-24

### Added
- Plan Review Army: /plan now fans out to 4 parallel plan reviewers (CEO, Eng, Design, Security)
- 4 new plan-review agents: plan-ceo-reviewer, plan-eng-reviewer, plan-design-reviewer, plan-security-reviewer
- Version bump validation in ./validate

### Changed
- /plan workflow: Step 7.5 Plan Review Army inserted before user approval
- All plan commands (Claude Code, Codex CLI) delegate to same multi-role workflow

## [1.0.0] - 2026-04-24

### Added
- 30 skills across 6 phases: define, build, verify, ship, maintain, reflect
- 5 commands: /refine, /plan, /build, /review, /ship
- CANON.md — 10 constitutional rules inherited by all skills
- 3 review agents: code-reviewer, test-engineer, security-auditor
- 7 document templates (feature spec/plan/adr, bug root-cause/fix-plan)
- Claude Code plugin support (.claude-plugin/plugin.json)
- Marketplace registration (ZeroZ-lab/unified-skills)
- Codex CLI compatibility ($refine, $plan, $build, $review, $ship)
- Validation script (./validate)
