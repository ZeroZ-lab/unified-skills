#!/usr/bin/env bash
# Unified Skills — Codex CLI one-command installer
# Symlinks skills + sets up hooks configuration
set -u

plugin_root="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -f "$plugin_root/CANON.md" ]; then
  printf 'ERROR: Cannot find Unified Skills root (missing CANON.md).\n'
  exit 1
fi

codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_home="${HOME}/.agents/skills"
codex_hooks_dir="${codex_home}"

printf '== Installing Unified Skills for Codex CLI ==\n\n'

# Step 1: Symlink .agents/skills/ entries
printf '1. Symlinking skills to %s ...\n' "$agents_home"
mkdir -p "$agents_home"
linked=0
for skill_dir in "$plugin_root/.agents/skills"/*/; do
  if [ -d "$skill_dir" ]; then
    skill_name=$(basename "$skill_dir")
    target="$agents_home/$skill_name"
    if [ -L "$target" ]; then
      printf '   %s already linked, skipping\n' "$skill_name"
    else
      ln -s "$skill_dir" "$target"
      printf '   %s linked\n' "$skill_name"
      linked=$((linked + 1))
    fi
  fi
done
printf '   %d skills linked\n\n' "$linked"

# Step 2: Create ~/.codex/hooks.json with absolute paths
printf '2. Creating Codex hooks configuration ...\n'
mkdir -p "$codex_hooks_dir"

cat > "$codex_hooks_dir/hooks.json" <<HOOKJSON
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$plugin_root/hooks/codex-wrapper.sh\" session-start.sh",
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
            "command": "bash \"$plugin_root/hooks/codex-wrapper.sh\" careful.sh",
            "statusMessage": "Checking for destructive commands"
          }
        ]
      },
      {
        "matcher": "apply_patch",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$plugin_root/hooks/codex-wrapper.sh\" freeze.sh",
            "statusMessage": "Checking freeze boundary"
          }
        ]
      }
    ]
  }
}
HOOKJSON
printf '   hooks.json created at %s\n\n' "$codex_hooks_dir/hooks.json"

# Step 3: Create ~/.codex/config.toml with feature flag
printf '3. Creating Codex config with hooks feature flag ...\n'
if [ -f "$codex_hooks_dir/config.toml" ]; then
  # Append feature flag to existing config
  if ! grep -q 'codex_hooks' "$codex_hooks_dir/config.toml"; then
    printf '\n[features]\ncodex_hooks = true\n' >> "$codex_hooks_dir/config.toml"
    printf '   codex_hooks feature flag appended to existing config\n\n'
  else
    printf '   codex_hooks feature flag already present\n\n'
  fi
else
  cat > "$codex_hooks_dir/config.toml" <<CONFTOML
[features]
codex_hooks = true
CONFTOML
  printf '   config.toml created at %s\n\n' "$codex_hooks_dir/config.toml"
fi

printf '== Installation complete ==\n\n'
printf 'Available commands:\n'
printf '  $refine  $plan  $build  $review  $ship  $save  $restore  $learn\n\n'
printf 'NOTES:\n'
printf '  - The careful hook uses fail-closed mode on Codex (blocks destructive\n'
printf '    commands by default). On Claude Code it prompts for confirmation.\n'
printf '  - The freeze hook blocks edits outside the freeze boundary on both platforms.\n'
printf '  - SessionStart auto-injects Unified Skills context on every new session.\n'