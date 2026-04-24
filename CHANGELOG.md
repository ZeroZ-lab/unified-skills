# Changelog

## [1.3.0] - 2026-04-24

### Changed
- validate script: `rg` dependency removed — `grep -E` fallback when ripgrep unavailable
- README.md: removed all external skill package references (agent-skills/superpowers/gstack)
- Updated all descriptions: "35 技能 + 5 命令 + 15 审查角色" across plugin.json, package.json, marketplace.json, CLAUDE.md, README.md

## [1.2.0] - 2026-04-24

### Added
- Idea Scout Army: /refine now fans out to 3 parallel scouts (CEO, Eng, Design) after Phase 1 clarification
- Ship Audit Army: /ship now fans out to 4 parallel auditors (Security, Performance, Accessibility, Docs) before Staging
- Accessibility Checker: /review parallel mode expands from 3 to 4 roles (adds accessibility checker for UI changes)
- 8 new agents: refine-ceo-scout, refine-eng-scout, refine-design-scout, review-accessibility-checker, ship-security-auditor, ship-performance-auditor, ship-accessibility-auditor, ship-docs-auditor

### Changed
- /refine: Phase 1.5 Idea Scout Army inserted between clarification and solution convergence
- /ship: Phase B restructured from optional quality gates to Ship Audit Army with 4 parallel auditors
- /review: parallel mode expanded with accessibility-checker role and minimum trigger conditions
- All command files (Claude Code + Codex CLI) updated with multi-role army documentation
- Agent count: 7 → 15

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
