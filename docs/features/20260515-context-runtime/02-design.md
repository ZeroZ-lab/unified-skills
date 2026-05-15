# Context Runtime — Design

## Design Requirement
- Design Status: required
- Reason: `artifact_type: software`, but the visible user experience is an agent workflow: startup context, skill-routing explanation, load-tier behavior, validation feedback, and failure modes. These must be designed before planning implementation.
- Design Track: Interaction / information architecture for a workflow runtime. Visual mockups are not applicable.
- DESIGN.md Sync: skipped. This feature does not introduce project-wide visual tokens, UI components, brand rules, or layout standards.

## Design References

### Enterprise Product Patterns
- `references/orchestration-patterns.md` — local orchestration model for direct invocation, single-role commands, parallel fan-out, sequential pipeline, and research isolation.
- `references/design-inspiration-catalog.md` — developer-tool pattern reference. Relevant examples: Linear, Raycast, Vercel as developer workflow products where speed, precision, and low chrome matter.
- Browser research tab "省 token 技术" — user-provided synthesis of Skills Suite runtime architecture: progressive disclosure, capability routing, deterministic execution, context isolation, context budget allocator.

### Official Systems / Platform Rules
- Anthropic Claude Skills documentation — Skills use progressive disclosure: metadata first, `SKILL.md` on activation, bundled files/scripts only when needed.
- Anthropic skill-authoring guidance — `SKILL.md` should point to supporting files, and deterministic scripts are preferred for repeatable work.
- Local `skills-lock.json` validation contract — current repo validates only one-level auxiliary `.md` files under each skill directory.

### Methods / Theory / Style Schools
- Progressive disclosure — expose enough to route, then reveal details only after the decision point.
- Interaction design: Path Before Pixels, State Completeness, One Primary Flow, Mental Model Fit.
- Operating-system analogy from the browser research: context as memory, router as scheduler, compression/paging as context lifecycle management.

### Anti-patterns / Verification
- `references/orchestration-patterns.md` rejects router personas, persona chaining, sequential paraphrasing, and deep persona trees.
- Current `maintain-workflow-using-unified` red flags over-correct toward loading all possibly relevant skills.
- Current `./validate` reports skill line counts but does not yet enforce context-budget regressions.

### Local Project Truth
- `AGENTS.md` is the single project-entry contract; `CLAUDE.md` remains pointer-only.
- Codex consumes the real `skills/` tree directly; repo-local thin command wrappers must not return.
- `skills-index.json` is partly generated and partly manually preserved: `by_phase` and `skill_descriptions` are generated, while `by_artifact_type`, `by_trigger`, and `by_risk` remain hand-maintained routing sections.
- `skills-lock.json` checks `computedHash` and one-level `auxiliaryHashes`; auxiliary files must be referenced from the owning `SKILL.md`.
- `./validate` already protects many workflow contracts, so context-runtime checks should extend validation rather than replace it.
- `DESIGN.md` does not currently exist, and this feature has no visual design tokens to sync.

## Pattern Synthesis

### Pattern 1: Metadata-First Routing
Mature skill systems keep always-loaded routing metadata small. Full instructions load only after a task matches a skill. Unified currently violates this pattern in two places: broad SessionStart injection and full-index-first discovery.

### Pattern 2: Runtime, Not Bigger Prompt
The browser research and official skill model converge on the same principle: large suites need a capability runtime. The runtime decides what to load, what to defer, and how to validate context cost. Adding more prose to `AGENTS.md` or `SKILL.md` would worsen the problem.

### Pattern 3: Page Deep Guidance Behind a Gate
Red flags, common excuses, examples, rubrics, and templates are valuable, but they are not equally valuable in every task. They should stay available through explicitly referenced auxiliary files and loading tiers.

### Pattern 4: Keep Routing in the Main Agent
Local orchestration guidance rejects a separate router persona. The Context Runtime should be data and validation, not a new agent layer that forwards work.

### Pattern 5: File-Based Stage Boundaries
Unified already uses files as stage outputs. The context runtime should follow that pattern: compact router, generated reports, specs, plans, and validation evidence should live as files rather than relying on conversation memory.

## Design Inferences

1. The first user-visible improvement should be a smaller and more predictable startup/loading experience, not a full directory reorganization.
2. The compact router must not become a second manual truth source. It should be generated from or mechanically checked against `skills-index.json`.
3. Loading tiers should be explicit enough that agents can say: "Using standard tier: one workflow skill plus one specialist skill." Vague "按需" language is not enough.
4. `full` mode should be exceptional: `--full`, adversarial review, full-body check, high-risk release, or user-explicit request.
5. `standard` mode should be conservative: one primary workflow skill plus at most one specialist by default. A second specialist requires a named risk trigger.
6. Context budget validation should start with line counts and load-count checks because they are deterministic and match the repo's zero-dependency posture.
7. Nested `core/`, `workflows/`, `retrieval/`, and `memory/` directories should wait until recursive auxiliary validation exists.

## Adopt / Reject

### Adopt
- **Boot Kernel** — Replace broad SessionStart injection with a short runtime primer. Adopted from progressive disclosure and local need to reduce always-loaded context.
- **Compact Router** — Add a small routing artifact in front of `skills-index.json`. Adopted because metadata-first routing is the core pattern.
- **Loading Tiers** — Define `light`, `standard`, `expanded`, and `full`. Adopted because users need predictable behavior and validation needs concrete thresholds.
- **Audible Loading** — Agents should state the tier and selected skill purpose. Adopted because the user has repeatedly asked for clear "because X, I loaded Y" mechanics.
- **One-Level Auxiliary Extraction First** — Slim high-impact skills using existing auxiliary-file validation. Adopted because it fits current `skills-lock.json`.
- **Budget Validation** — Extend `./validate` to catch context regressions. Adopted because Unified treats validation as contract enforcement, not optional reporting.

### Reject
- **Separate Router Agent** — Rejected as a router-persona anti-pattern. The main agent should route using compact data.
- **Full Nested Directory Migration in v1** — Rejected because current validation would not protect nested content.
- **Deleting Behavioral Discipline to Save Tokens** — Rejected because red flags and common excuses shape behavior; they should be paged, not removed.
- **Keeping Full Command Map in SessionStart** — Rejected because commands can be read on demand and do not need to occupy every session.
- **Approximate Token-Only Validation** — Rejected for v1 because it is less deterministic than line/file/load-count checks.

## Design Evidence Quality
- Local Project Truth: strong. Verified against `AGENTS.md`, `skills-index.json` shape, `validate`, `skills-lock.json`, `hooks/session-start.sh`, and current skill sizes.
- Official Systems: medium-strong. Official Anthropic sources support progressive disclosure and bundled files/scripts, but they do not prescribe Unified-specific contracts.
- Enterprise / Runtime Patterns: medium. Browser research is useful synthesis, but user-provided and not a formal spec; only adopted where it matches local constraints.
- Anti-pattern Evidence: strong locally. Existing orchestration references explicitly reject router personas and deep chaining.
- Remaining Unknowns: exact default line budget, whether compact router is generated or committed, and whether budget failures begin as hard failures or staged warnings.

## Designed User Path

### Primary Flow: Normal Task
1. Session starts with Boot Kernel only.
2. Agent reads compact router metadata for the user request.
3. Agent chooses a loading tier.
4. Agent declares: tier, selected skill, and reason.
5. Agent loads only the selected primary skill.
6. Agent loads a specialist skill only if artifact type, trigger, or named risk requires it.
7. Agent proceeds with the selected workflow.

### Expanded Flow: Risk-Triggered Task
1. Primary flow starts the same way.
2. Router identifies a named risk: security, public API, UI change, performance, production deployment, or breaking change.
3. Agent loads one additional specialist skill.
4. If more specialists are needed, agent must name the risk trigger for each one.

### Full Flow: Explicit Full Review
1. User says `--full`, asks for adversarial review, full-body check, or high-risk release.
2. Agent declares `full` tier.
3. Agent loads all stage-relevant selected roles/skills allowed by the stage contract.
4. Agent uses file-based outputs to keep stage evidence stable.

### Recovery Flow: Router Ambiguity
1. If compact router cannot confidently choose a skill, agent asks one short clarification question.
2. If the user does not answer and the task is low risk, agent chooses the smallest plausible workflow skill.
3. If the task is high risk, agent stops and asks for clarification before expanding context.

## Loading Tier Contract

| Tier | Trigger | Default Load | Expansion Rule | User-Facing Declaration |
|------|---------|--------------|----------------|-------------------------|
| `light` | Simple explanation, status question, command lookup, no repo edit | Boot Kernel + compact router only | Read files only if the answer depends on current repo truth | `Using light tier: router-only answer` |
| `standard` | Normal workflow task | One primary workflow skill | Add at most one specialist if artifact type or trigger requires it | `Using standard tier: <skill> because <trigger>` |
| `expanded` | Named risk or mixed artifact type | One workflow skill + up to two specialists | Each extra skill must cite a trigger or risk | `Using expanded tier: <skills> because <risks>` |
| `full` | `--full`, adversarial review, full-body check, high-risk release | Stage-relevant selected skills/roles | Allowed by stage skill and risk escalation contract | `Using full tier: <reason>` |

### Default Budget
- Boot Kernel: target under 80 lines.
- Compact router: target under 180 lines or equivalent generated JSON.
- Primary `SKILL.md`: target under 180 lines for standard mode, unless grandfathered with report-only warning.
- Standard mode: one primary skill plus one specialist maximum.
- Expanded mode: one primary skill plus two specialists maximum.
- Full mode: no default skill-count cap, but must be explicitly triggered.

## Runtime Data Shape

The compact router should expose only routing-relevant fields:

```json
{
  "version": "2.16.4",
  "default_budget": {
    "light": { "primary_skills": 0, "specialist_skills": 0 },
    "standard": { "primary_skills": 1, "specialist_skills": 1 },
    "expanded": { "primary_skills": 1, "specialist_skills": 2 }
  },
  "skills": {
    "verify-workflow-review": {
      "phase": "verify",
      "role": "workflow",
      "summary": "审查完成产物",
      "default_tier": "standard",
      "triggers": ["review", "审查", "code review"],
      "risks": [],
      "full_when": ["--full", "adversarial_review", "full_body_check"]
    }
  }
}
```

Design constraint: the router is allowed to summarize and route, not to duplicate full workflow instructions.

## Boot Kernel Contract

Boot Kernel should communicate only:
- Unified is active.
- `AGENTS.md` remains the project-entry contract.
- Use compact router before loading full skills.
- Declare loading tier and selected skill reason.
- Preserve CANON hard disciplines.
- For skill edits: read full skill, read CANON, update lock/index, run `./validate`.
- High-risk or `--full` requests may expand loading.

Boot Kernel should not include:
- Full command mapping table.
- Full artifact output chain.
- Full risk escalation prose.
- Full hooks behavior matrix.
- Full skill inventory.

## State Design

| State | Required Behavior |
|-------|-------------------|
| Default | Boot Kernel + compact router only. |
| No matching route | Ask one short clarification or choose smallest low-risk workflow skill. |
| Ambiguous artifact type | Default `software`, but do not load UI/design specialists unless user-visible signal exists. |
| Named risk present | Move from `standard` to `expanded` and cite the risk. |
| Full trigger present | Move to `full` and cite trigger. |
| Router/index drift | Validation fails. Agent must fix routing truth before release. |
| Skill over budget | Validation reports or fails according to migration phase. |
| Auxiliary file unreferenced | Existing lock validation fails; keep this behavior. |

## Validation Design

Validation should cover:
- Boot Kernel size and prohibited sections.
- Compact router exists and references only real skills.
- Compact router version matches package/plugin version.
- Router skill summaries match `skills-index.json.skill_descriptions` or are generated from it.
- Standard routes do not exceed the standard skill-count budget.
- Expanded routes do not exceed expanded budget without `full_when`.
- `maintain-workflow-using-unified` contains loading tiers and does not contain "1% possible relevance means load" wording.
- Long `SKILL.md` files are reported first; after migration, over-budget files fail unless they have referenced auxiliary extraction.

## First Slimming Candidates

These are design candidates, not implementation tasks:
- `maintain-workflow-using-unified` — highest leverage because every task touches it.
- `design-workflow-design` — long and frequently loaded for user-visible work.
- `build-workflow-plan` — long, high-frequency, and already has `task-templates.md`.

Slimming rule:
- Keep entry conditions, hard gates, core flow, tier selection, and validation checklist in `SKILL.md`.
- Move long quick references, detailed examples, report templates, and deep guidance into one-level auxiliary `.md` files.
- Main `SKILL.md` must explicitly name every auxiliary file.

## Approval Criteria
- Design preserves AGENTS single-entry and real `skills/` tree.
- Design does not reintroduce thin wrappers.
- Design keeps behavior-shaping content available.
- Design makes loading decisions visible to the user.
- Design has deterministic validation hooks.
- Design stays compatible with current one-level auxiliary lock checks.

## Design Boundary
- This design defines runtime contracts, state behavior, and validation expectations.
- It does not define implementation tasks, shell commands, code patches, or release sequence.
- It does not create visual mockups or update `DESIGN.md`.
- It does not migrate nested skill directories in v1.
