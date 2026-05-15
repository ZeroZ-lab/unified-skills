# Context Runtime — Spec

## Artifact Type
`artifact_type: software`

## Goal Alignment
- Source Goal: conversation + browser research tab "省 token 技术"
- Goal Status: accepted
- Goal Review Score: `10/12`

### One-line Goal
Reduce Unified Skills' default context footprint by introducing a lightweight context runtime layer for routing, loading tiers, and budget validation without weakening existing workflow discipline.

### Done When
- [ ] Functional: Normal tasks start from a compact routing surface instead of reading the full skill index and multiple full `SKILL.md` files by default.
- [ ] Technical: `./validate` checks context-budget regressions, router/index consistency, and auxiliary-file coverage.
- [ ] Regression: AGENTS single-entry model, real `skills/` tree, `skills-lock.json`, artifact routing, risk escalation, and existing release validation remain intact.
- [ ] Output: Spec, plan, implementation diff, validation evidence, and a before/after context-load report.

### Stop Conditions
- [ ] Acceptance cannot be measured with line/token/load-count evidence.
- [ ] The change requires abandoning the AGENTS single-entry model or restoring repo-local thin wrappers.
- [ ] The change requires moving to nested skill auxiliary directories before validation supports recursive hashing and reference checks.
- [ ] The implementation weakens hard gates, Iron Laws, risk escalation, or human-partner approval wording.

## Problem
Unified Skills has strong behavior contracts, but its current loading model is too coarse. Session startup injects broad AGENTS-derived context, `maintain-workflow-using-unified` requires reading the full `skills-index.json`, and its "1% possible relevance" rule biases agents toward loading more skills than needed. As the suite grows, the bottleneck is no longer missing skill content; it is context scheduling.

How might we preserve Unified's discipline while making the default path load only the smallest sufficient routing and skill surface?

## Selected Approach
Introduce a Context Runtime layer in front of the existing skill suite. The runtime is not a new product surface; it is a small set of repo contracts and validation scripts that decide what to load, when to load it, and how much context is allowed for each mode.

The first version should keep the current directory model. It should add a compact router, define loading tiers, shrink SessionStart into a Boot Kernel, update `maintain-workflow-using-unified` to route from the compact surface, and add validation that catches context regressions. Skill content should be slimmed incrementally by moving long examples, rubrics, templates, and deep guidance into existing one-level auxiliary `.md` files, because current validation already hashes and references those files.

## External References
- Search status: completed
- Scan date: 2026-05-15
- Sources:
  - Browser tab `https://chatgpt.com/c/6a0674ee-7d58-83ea-aaf2-5329a505fdde` — user-provided research on Skills Suite runtime architecture and token reduction.
  - Anthropic Claude Docs / Help Center search results — official references describing progressive disclosure, metadata-first skill activation, optional bundled files, and deterministic scripts.
- Fact:
  - Skills are designed around progressive disclosure: metadata is available first, `SKILL.md` loads on activation, and extra files should load only when needed.
  - Anthropic documentation describes additional skill files and scripts as mechanisms to avoid loading all content into context upfront.
  - Current Unified validation only hashes and reference-checks one-level auxiliary `.md` files directly under each skill directory.
- Pattern:
  - Mature skill systems separate routing, workflow entry, core rules, examples, templates, scripts, schemas, and retrieval material by loading priority.
  - Deterministic scripts are preferred for parsing, validation, indexing, scoring, and reports.
  - Large skill suites need an explicit context budget and loading mode, not just informal "load as needed" wording.
- Inference:
  - Unified should not first reorganize every skill into nested directories; it should first create runtime contracts that make loading predictable and measurable.
  - The current `skills-index.json` is too broad to be the only first-pass routing surface, but it should remain the inventory truth source.
- Unknown:
  - Whether the acceptable default budget should be defined in lines, approximate tokens, loaded files, or a combined score.
  - Whether compact router generation should live inside `scripts/generate-index.sh` or a dedicated `scripts/generate-router.sh`.
- Adopt:
  - Boot Kernel instead of broad SessionStart injection.
  - Compact router before full index/skill loading.
  - Loading tiers: `light`, `standard`, `expanded`, `full`.
  - Context budget validation in `./validate`.
  - Incremental one-level auxiliary-file extraction before nested directory migration.
- Reject:
  - Full immediate migration to `core/`, `workflows/`, `retrieval/`, `memory/`, and `schemas/` subdirectories, because current validation would not fully protect nested content.
  - Deleting red flags, common excuses, or Iron Laws to save tokens; these are behavior-shaping assets and should be moved behind loading tiers instead.

## Scout Review Summary
- CEO: The leverage point is reducing default friction without diluting Unified's brand promise: disciplined workflow, explicit gates, and evidence-backed delivery.
- Eng: The safest implementation path is additive: generate or validate a compact router, then update the loading guide and SessionStart. Avoid nested directory migration until recursive lock validation exists.
- Design: The user experience should make loading audible and predictable: agents should say which tier and skill they are using, not silently expand context.
- Blocking resolved: No need to reintroduce command wrappers or replace `skills-index.json`; the runtime can sit in front of existing surfaces.
- Important adopted: Keep `skills-lock.json` and one-level auxiliary-file constraints in v1.
- Suggestions deferred: Multi-agent scheduler, memory layer, schema-driven outputs, and recursive retrieval directories belong after the first context-budget system exists.

## Unselected Alternatives
- Alternative A: Only shorten SessionStart.
  - Rejected because it reduces startup cost but does not fix full-index routing, over-broad skill loading, or future drift.
- Alternative B: Immediately restructure every skill into nested `core/`, `workflows/`, `retrieval/`, `memory/` directories.
  - Rejected because it is a high-blast-radius migration and current validation does not fully guard nested auxiliary content.
- Alternative C: Remove long behavior sections from skills.
  - Rejected because red flags, common excuses, and Iron Laws are core behavior contracts. They should be paged out, not deleted.

## Acceptance Criteria
- [ ] SessionStart output is reduced to a compact Boot Kernel and no longer injects the full command map by default.
- [ ] A compact routing artifact exists and is either generated from or validated against `skills-index.json`.
- [ ] `maintain-workflow-using-unified` defines loading tiers and no longer defaults to "1% possible relevance means load".
- [ ] `./validate` fails when a route loads more than the allowed default number of skills for its tier.
- [ ] `./validate` reports or fails when `SKILL.md` files exceed the agreed line budget without referenced auxiliary extraction.
- [ ] At least three high-impact skills are converted to entry-first shape with long material moved into one-level auxiliary files.
- [ ] Before/after report shows startup injection size, router size, and default selected skill count for representative tasks.

## Scope Boundary
- **Do:**
  - Add compact context-routing contracts.
  - Define loading tiers and budget rules.
  - Reduce SessionStart default injection.
  - Update `maintain-workflow-using-unified`.
  - Extend validation around context budget and router/index consistency.
  - Slim a small set of high-impact skills using current one-level auxiliary-file support.
- **Do Not:**
  - Change workflow phase semantics.
  - Remove hard gates, Iron Laws, red flags, or common-excuse behavior contracts.
  - Reintroduce repo-local Codex thin command wrappers.
  - Convert all skills to nested directory structures in v1.
  - Treat external research claims as requirements unless they are adopted through this spec and validated against local constraints.

## Core Assumptions To Validate
- [ ] A compact router can be derived from current `skills-index.json` without creating a second manual source of truth.
- [ ] Agents can still choose correct skills with a smaller routing surface.
- [ ] Line-count or approximate-token checks are good enough as a first budget proxy.
- [ ] One-level auxiliary extraction meaningfully reduces active context without weakening behavior.

## Open Questions
- What is the default `standard` budget: one workflow skill plus two specialist skills, or one workflow skill plus one specialist skill?
- Should context budget checks be hard failures immediately, or start as report-only until the first slimming pass lands?
- Should compact router be committed as generated JSON, or produced on demand and validated in CI?
