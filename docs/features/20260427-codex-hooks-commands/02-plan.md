# Plan: Codex CLI Hooks & Commands Compatibility

**artifact_type:** software
**version:** 2.5.0 → 2.6.0
**plan topology:** sequential (dependency chain)

## Plan Review Summary

4 reviewers (CEO, Eng, Design, Security) completed. All Blocking issues resolved in spec. Key adjustments incorporated:
- `CODEX_PLUGIN_ROOT` does not exist → use SCRIPT_DIR (spec already handles this)
- Codex plugin.json has no `hooks` field → hooks via separate `.codex/hooks.json` (spec already handles this)
- PreToolUse "ask" fail-open → accepted risk per user decision
- Keep `CLAUDE_PLUGIN_ROOT:-SCRIPT_DIR` fallback pattern (avoid Claude Code regression)
- Replace "message" JSON key with "permissionDecisionReason" (Codex-expected, Claude Code accepts both)
- Honest documentation of fail-open limitation

## Task Breakdown

### T1: Create `.codex-plugin/plugin.json`
**Complexity:** Low
**Verification:** File exists with name, version 2.6.0, description, author, homepage, repository, license, keywords, skills path, interface section
**Depends on:** None

Create Codex plugin manifest per spec §5.1. Skills path points to `.agents/skills/`. No hooks field (Codex discovers hooks via `.codex/hooks.json`).

### T2: Create `.codex/hooks.json`
**Complexity:** Low
**Verification:** File exists with SessionStart (matcher `startup|resume|clear`), PreToolUse/Bash (careful.sh), PreToolUse/apply_patch (freeze.sh). Has `statusMessage` fields. No `async` field.
**Depends on:** None

Create Codex hooks config per spec §5.2. Uses `$(git rev-parse --show-toplevel)/hooks/` path resolution (Codex convention). Matcher `apply_patch` replaces `Edit|Write`.

### T3: Create `.codex/config.toml`
**Complexity:** Low
**Verification:** File exists with `[features] codex_hooks = true`
**Depends on:** None

Feature flag required for Codex hooks system activation.

### T4: Modify `hooks/session-start.sh` — keep CLAUDE_PLUGIN_ROOT fallback
**Complexity:** Low
**Verification:** Script uses `${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}` pattern. Output format unchanged (identical on both platforms).
**Depends on:** None

**IMPORTANT adjustment from Eng review:** Do NOT remove `CLAUDE_PLUGIN_ROOT`. Keep the existing `${CLAUDE_PLUGIN_ROOT:-$(cd...)}` fallback pattern. This is the superpowers pattern — Claude Code sets the env var, Codex doesn't, so the SCRIPT_DIR fallback handles Codex. No regression on Claude Code. Output format is identical on both platforms (confirmed by Eng review).

### T5: Modify `hooks/careful.sh` — replace "message" with "permissionDecisionReason"
**Complexity:** Low
**Verification:** Script outputs `permissionDecisionReason` key instead of `message`. Works on both Claude Code and Codex.
**Depends on:** None

Replace `"message":"[careful] ..."` with `"permissionDecisionReason":"[careful] ..."` in the JSON output. Codex expects `permissionDecisionReason`; Claude Code also accepts it. No platform detection needed — same output works on both.

### T6: Modify `hooks/freeze.sh` — replace "message" with "permissionDecisionReason"
**Complexity:** Low
**Verification:** Python block outputs `permissionDecisionReason` key instead of `message`. Works on both Claude Code and Codex.
**Depends on:** None

Same change as T5, applied to the Python block in freeze.sh. Replace `"message"` with `"permissionDecisionReason"` in `json.dumps()`. `permissionDecision: "deny"` is fully enforced on Codex — this hook works correctly on both platforms.

### T7: Update `AGENTS.md` — add Codex hooks section
**Complexity:** Medium
**Verification:** AGENTS.md has hooks section documenting: (a) 3 hooks and what they do, (b) `codex_hooks = true` requirement, (c) fail-open limitation for careful's "ask", (d) freeze "deny" works correctly
**Depends on:** None

Add a section to AGENTS.md about hooks:
- SessionStart: injects constitution + command map (works identically on both platforms)
- PreToolUse/Bash (careful): intercepts destructive commands. **On Codex: `permissionDecision: "ask"` is parsed but fail-open — destructive commands will NOT be paused for user confirmation. This will improve when Codex makes "ask" fully functional.**
- PreToolUse/apply_patch (freeze): blocks edits outside freeze boundary. **Works correctly on Codex — "deny" is fully enforced.**
- Activation: requires `.codex/config.toml` with `[features] codex_hooks = true`

### T8: Update `validate` — add Codex manifest + hooks checks
**Complexity:** Medium
**Verification:** ./validate exits 0 with new checks: (a) .codex-plugin/plugin.json version matches .claude-plugin/plugin.json version, (b) .codex/hooks.json schema valid (SessionStart + PreToolUse entries), (c) .codex/config.toml has codex_hooks = true, (d) hook scripts output permissionDecisionReason not message
**Depends on:** T1, T2, T3, T5, T6

Add 3 new check sections:
1. `== 检查 Codex manifest 版本同步 ==` — compare .claude-plugin/plugin.json version with .codex-plugin/plugin.json version
2. `== 检查 Codex hooks.json ==` — validate schema (SessionStart, PreToolUse/Bash, PreToolUse/apply_patch, command type, no async field)
3. `== 检查 Codex config.toml ==` — verify `codex_hooks = true` exists
4. `== 检查 hook 输出字段 ==` — grep hook scripts for "permissionDecisionReason", fail if "message" key found in permissionDecision contexts

### T9: Version bump + manifest sync
**Complexity:** Low
**Verification:** package.json, .claude-plugin/plugin.json, .codex-plugin/plugin.json all have "2.6.0". marketplace.json description updated to reflect current state (44 skills + 10 commands + 22 roles). .claude-plugin/plugin.json compatibility updated.
**Depends on:** T1

Update 4 files:
- `package.json`: version 2.5.0 → 2.6.0
- `.claude-plugin/plugin.json`: version 2.5.0 → 2.6.0, description updated
- `.codex-plugin/plugin.json`: version 2.6.0 (already set in T1)
- `.claude-plugin/marketplace.json`: description updated (currently stale — says "43 技能 + 8 命令 + 15 审查角色")

### T10: Update `README.md` — Codex installation with hooks + feature matrix
**Complexity:** Medium
**Verification:** README has: (a) expanded Codex installation with hooks activation step, (b) cross-platform feature matrix table, (c) honest documentation of careful fail-open, (d) FAQ updated about Codex/Claude parity
**Depends on:** None

Add to README:
- Expand Codex installation section with Step 3: Create `.codex/config.toml` with `codex_hooks = true`
- Add cross-platform feature matrix:

| Feature | Claude Code | Codex CLI |
|---------|------------|-----------|
| Skills (44) | `/command` | `$command` |
| SessionStart injection | Automatic | Automatic (with codex_hooks) |
| Destructive command guard (careful) | Ask → user confirms | Fail-open* (parsed but not enforced yet) |
| Freeze boundary (freeze) | Deny → blocks edit | Deny → blocks edit |
| Context save/restore | `/save` `/restore` | `$save` `$restore` |

*Will improve when Codex makes permissionDecision "ask" fully functional.

- Update FAQ: "Codex CLI 和 Claude Code 体验一致吗？" → honest answer about hooks parity difference
- Note: Codex hooks require `codex_hooks = true` in `.codex/config.toml` or `~/.codex/config.toml`

### T11: Smoke test — `./validate` passes
**Complexity:** Low
**Verification:** `./validate` exits 0, all checks pass including new Codex checks
**Depends on:** T1-T10 (all)

Run ./validate and verify all checks pass. Fix any issues found.

## Execution Order

```
T1 ──┐
T2 ──┤
T3 ──┤──→ T8 ──┐
T4 ──┤           │
T5 ──┤           │
T6 ──┤           │──→ T11
T7 ──┤           │
T9 ──┤ (T1 dep)  │
T10 ─┤           │
```

T1-T7 and T10 can run in parallel. T8 depends on T1,T2,T3,T5,T6. T9 depends on T1. T11 depends on all.

## Write Scope

Files to create: 3 (`.codex-plugin/plugin.json`, `.codex/hooks.json`, `.codex/config.toml`)
Files to modify: 6 (`hooks/session-start.sh`, `hooks/careful.sh`, `hooks/freeze.sh`, `AGENTS.md`, `validate`, `README.md`)
Files to version-bump: 3 (`package.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`)

Total: 12 file operations. No generation scripts, no platform adaptation layer, no new directories beyond `.codex/` and `.codex-plugin/`.