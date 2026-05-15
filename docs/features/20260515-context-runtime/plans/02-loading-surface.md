# Subplan 02 — Loading Surface

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/01-runtime-contracts.md`
- **Write Scope:** `hooks/session-start.sh`, `scripts/tests/test-hooks.sh`, `skills/maintain-workflow-using-unified/SKILL.md`, `skills-index.json`, `skills-lock.json`
- **Read Scope:** `AGENTS.md`, `CANON.md`, `skills-router.json`, `skills-index.json`, current hook tests
- **Verification Evidence:** `bash scripts/tests/test-hooks.sh`, `bash scripts/generate-index.sh`, `./validate`
- **Merge Checkpoint:** SessionStart emits Boot Kernel and using-unified declares loading tiers

## Tasks

### Task 2.1: Hook Test Update

**Files:**
- Modify: `scripts/tests/test-hooks.sh`

**Depends On:** Subplan 01

- [ ] Replace old expectation for full AGENTS command map with Boot Kernel expectations.
- [ ] Add negative check that SessionStart no longer includes the full command mapping table.
- [ ] Run: `bash scripts/tests/test-hooks.sh` -> FAIL until `hooks/session-start.sh` is updated.

### Task 2.2: Boot Kernel Hook

**Files:**
- Modify: `hooks/session-start.sh`

**Depends On:** Task 2.1

- [ ] Emit compact runtime guidance only.
- [ ] Include AGENTS single-entry, compact router, loading tier declaration, CANON preservation, and high-risk expansion cues.
- [ ] Do not emit full command table, full artifact chain, full hook matrix, or full skill inventory.
- [ ] Run: `bash scripts/tests/test-hooks.sh` -> PASS.

### Task 2.3: Loading Guide Rewrite

**Files:**
- Modify: `skills/maintain-workflow-using-unified/SKILL.md`
- Modify: `skills-index.json` if generated descriptions change
- Modify: `skills-lock.json`

**Depends On:** Task 2.2

- [ ] Replace full-index-first discovery with compact-router-first discovery.
- [ ] Define `light`, `standard`, `expanded`, and `full`.
- [ ] Preserve hard gate requiring an audible skill-use declaration.
- [ ] Remove the old "1% possible relevance means load" rule.
- [ ] Run: `bash scripts/generate-index.sh`.
- [ ] Refresh `skills-lock.json`.
- [ ] Run: `./validate` -> PASS.

## Parallel Safety
- `parallel_safe: no`
- Reason: hook output and loading guide must use the same tier vocabulary.
