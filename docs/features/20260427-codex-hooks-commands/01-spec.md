# Spec: Codex CLI Hooks & Commands Compatibility

**artifact_type:** software
**version:** 2.5.0 → 2.6.0

## 1. Goal

Make Unified Skills' 3 hooks (SessionStart, careful, freeze) and 10 commands fully functional on Codex CLI v0.124+, alongside the existing Claude Code support. Single-source hook scripts, dual-platform config manifests.

## 2. Current State

- 3 hooks in `hooks/hooks.json` using Claude Code format (SessionStart, PreToolUse/Bash via careful.sh, PreToolUse/Edit|Write via freeze.sh)
- 53 skill wrappers in `.agents/skills/` already Codex-compatible (SKILL.md format, `$command` invocation)
- `.claude-plugin/plugin.json` exists; `.codex-plugin/plugin.json` does NOT exist
- `.codex/` config directory does NOT exist
- Hook scripts use `${CLAUDE_PLUGIN_ROOT}` for path resolution
- Hook scripts output Claude Code JSON protocol (`permissionDecision`, `hookSpecificOutput.additionalContext`)

## 3. Assumptions (CANON Clause 1)

1. Codex CLI v0.124+ hooks are stable enough to ship — `permissionDecision: "deny"` is enforced; `"ask"` and `"allow"` are parsed but fail-open (acceptable risk per user decision)
2. `CODEX_PLUGIN_ROOT` env var does NOT exist — must use `SCRIPT_DIR` path resolution instead
3. Codex plugin manifest (`plugin.json`) does NOT have a `hooks` field — hooks are registered separately via `.codex/hooks.json`
4. Codex `apply_patch` matcher catches both Edit and Write — no functional gap for freeze hook
5. Codex SessionStart output format is identical to Claude Code (`hookSpecificOutput.additionalContext`)
6. `.agents/skills/` is the canonical Codex skills directory — no need for `.codex/skills/`

## 4. Scope

### In Scope

1. Create `.codex-plugin/plugin.json` — Codex plugin manifest pointing to `.agents/skills/`
2. Create `.codex/hooks.json` — Codex hooks config (SessionStart, PreToolUse/Bash via careful, PreToolUse/apply_patch via freeze)
3. Create `.codex/config.toml` — feature flag `[features] codex_hooks = true`
4. Modify 3 hook scripts to use `SCRIPT_DIR` path resolution (replacing `CLAUDE_PLUGIN_ROOT`)
5. Add `permissionDecisionReason` field to hook output (Codex-compatible, also accepted by Claude Code)
6. Update `validate` to check dual manifest version sync
7. Update README with Codex installation instructions + hooks activation steps
8. Create `AGENTS.md` for Codex instruction loading
9. Version bump: `package.json` 2.5.0 → 2.6.0 + `.claude-plugin/plugin.json` + `.codex-plugin/plugin.json`

### Out of Scope (不做清单)

- `hooks/lib/platform.sh` platform adaptation layer — env var detection doesn't work (`CODEX_PLUGIN_ROOT` doesn't exist); use `SCRIPT_DIR` instead
- `scripts/generate-manifest.sh` — two manifests have different field structures; maintain manually, validate with a simple version sync check
- Modifying `.agents/skills/` SKILL.md content — already Codex-compatible
- Creating `.codex/skills/` — `.agents/skills/` is the established convention
- Codex `PermissionRequest` event for careful — would require different behavioral semantics; use PreToolUse with fail-open "ask" as acceptable risk per user decision
- Codex `Stop` / `PostToolUse` / `UserPromptSubmit` hooks — not part of current hook set

## 5. Detailed Design

### 5.1 `.codex-plugin/plugin.json`

```json
{
  "name": "unified",
  "version": "2.6.0",
  "description": "统一开发技能套件 — 宪法 + 44 技能 + 10 命令 + 22 角色（15 审查 + 7 核心工程），按阶段加载",
  "author": {
    "name": "ZeroZ-lab",
    "url": "https://github.com/ZeroZ-lab/unified-skills"
  },
  "homepage": "https://github.com/ZeroZ-lab/unified-skills",
  "repository": "https://github.com/ZeroZ-lab/unified-skills",
  "license": "MIT",
  "keywords": ["skills", "codex", "ai-agent", "development-workflow"],
  "skills": "./.agents/skills/",
  "interface": {
    "displayName": "Unified Skills",
    "shortDescription": "宪法 + 44 技能 + 10 命令，按阶段加载"
  }
}
```

No `hooks` field — Codex discovers hooks via `.codex/hooks.json`, not plugin manifest.

### 5.2 `.codex/hooks.json`

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$(git rev-parse --show-toplevel)/hooks/session-start.sh\"",
            "async": false,
            "statusMessage": "Loading Unified Skills"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$(git rev-parse --show-toplevel)/hooks/careful.sh\"",
            "statusMessage": "Checking for destructive commands"
          }
        ]
      },
      {
        "matcher": "apply_patch",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$(git rev-parse --show-toplevel)/hooks/freeze.sh\"",
            "statusMessage": "Checking freeze boundary"
          }
        ]
      }
    ]
  }
}
```

Key differences from Claude Code `hooks/hooks.json`:
- Matcher `apply_patch` instead of `Edit|Write`
- Matcher `startup|resume|clear` for SessionStart (Codex includes `resume`)
- Uses `$(git rev-parse --show-toplevel)/hooks/` for path resolution (Codex convention)
- `statusMessage` field (Codex-specific, Claude Code ignores)
- No `async` field in Codex format (remove)

### 5.3 `.codex/config.toml`

```toml
[features]
codex_hooks = true
```

Required to activate Codex hooks system.

### 5.4 Hook Script Modifications

#### `hooks/session-start.sh`

Change: Replace `CLAUDE_PLUGIN_ROOT` with `SCRIPT_DIR` path resolution.

```bash
# Before:
plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# After:
plugin_root="$(cd "$(dirname "$0")/.." && pwd)"
```

No output format changes needed — SessionStart JSON format is identical on both platforms.

#### `hooks/careful.sh`

Change: Add `permissionDecisionReason` alongside `message` (Codex-expected field name; Claude Code also accepts it).

```bash
# Before:
printf '{"permissionDecision":"ask","message":"[careful] 检测到破坏性命令: %s。确认执行？"}\n' "$pattern"

# After:
printf '{"permissionDecision":"ask","permissionDecisionReason":"[careful] 检测到破坏性命令: %s。确认执行？"}\n' "$pattern"
```

**Known risk**: Codex PreToolUse parses `permissionDecision: "ask"` but fails open — it does not prompt the user. The destructive command will still execute. This is an accepted risk per user decision. When Codex makes "ask" fully functional, this hook will work correctly without changes.

#### `hooks/freeze.sh`

Change: Add `permissionDecisionReason` alongside `message`.

```bash
# Before:
print(json.dumps({
    "permissionDecision": "deny",
    "message": f"[freeze] ..."
}, ensure_ascii=False))

# After:
print(json.dumps({
    "permissionDecision": "deny",
    "permissionDecisionReason": f"[freeze] ..."
}, ensure_ascii=False))
```

`permissionDecision: "deny"` is fully enforced on Codex — this hook works correctly.

### 5.5 `AGENTS.md`

Create alongside `CLAUDE.md` with Codex-specific instructions:
- Reference `CANON.md` (宪法)
- Reference `$command` syntax instead of `/command`
- Reference `.agents/skills/` for skill discovery
- Note that hooks require `codex_hooks = true` feature flag in `.codex/config.toml`

Content structure mirrors `CLAUDE.md` but adapted for Codex conventions.

### 5.6 `validate` Update

Add a check that `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` have the same `version` field. Simple grep-based check, no generation script needed.

### 5.7 README Update

Add Codex installation section:
- Step 1: Clone repo
- Step 2: Symlink `.agents/skills/` entries to `~/.agents/skills/` (existing)
- Step 3: Create `.codex/config.toml` with `codex_hooks = true` (new)
- Step 4: Verify hooks with `$refine` test invocation (new)
- Note: Codex hooks `permissionDecision: "ask"` is parsed but not fully enforced yet — destructive command interception will improve when Codex makes this field fully functional

### 5.8 Version Bump

Update version in 3 files:
- `package.json`: `"version": "2.6.0"`
- `.claude-plugin/plugin.json`: `"version": "2.6.0"`
- `.codex-plugin/plugin.json`: `"version": "2.6.0"`

## 6. File Change Summary

| File | Action | Description |
|------|--------|-------------|
| `.codex-plugin/plugin.json` | CREATE | Codex plugin manifest |
| `.codex/hooks.json` | CREATE | Codex hooks config |
| `.codex/config.toml` | CREATE | Codex feature flag |
| `AGENTS.md` | CREATE | Codex instruction file |
| `hooks/session-start.sh` | MODIFY | Replace CLAUDE_PLUGIN_ROOT with SCRIPT_DIR |
| `hooks/careful.sh` | MODIFY | Add permissionDecisionReason field |
| `hooks/freeze.sh` | MODIFY | Add permissionDecisionReason field |
| `package.json` | MODIFY | Version bump 2.5.0 → 2.6.0 |
| `.claude-plugin/plugin.json` | MODIFY | Version bump 2.5.0 → 2.6.0, compatibility update |
| `validate` | MODIFY | Add dual manifest version sync check |
| `README.md` | MODIFY | Add Codex installation + hooks activation instructions |

## 7. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Codex PreToolUse `permissionDecision: "ask"` fail-open | Medium | Accepted per user decision. Will improve when Codex makes "ask" functional. freeze.sh (deny) works correctly. |
| Codex hooks API changes before full GA | Medium | Keep hook scripts minimal and simple. When Codex changes, only hooks.json/config.toml needs update, not scripts. |
| `.codex/hooks.json` requires project trust | Low | Document in README that Codex users must trust the project for local hooks to load |
| Dual manifest version drift | Low | validate check prevents drift |

## 8. Validation Criteria

- [ ] `.codex-plugin/plugin.json` exists with correct fields and version
- [ ] `.codex/hooks.json` exists with SessionStart + PreToolUse/Bash + PreToolUse/apply_patch
- [ ] `.codex/config.toml` exists with `codex_hooks = true`
- [ ] `AGENTS.md` exists with Codex-adapted instructions
- [ ] All 3 hook scripts use SCRIPT_DIR path resolution (no CLAUDE_PLUGIN_ROOT dependency)
- [ ] All 3 hook scripts output `permissionDecisionReason` field
- [ ] `validate` passes with dual manifest version sync check
- [ ] README documents Codex installation flow including hooks activation
- [ ] Version is 2.6.0 in all 3 manifest files