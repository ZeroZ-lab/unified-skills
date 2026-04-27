#!/usr/bin/env bash
# Unified Skills — Codex hook wrapper
# Resolves plugin root via SCRIPT_DIR, validates, and calls the actual hook script.
# This avoids using $(git rev-parse --show-toplevel) which fails outside git repos.
set -u

hook_script="$1"

# Resolve plugin root from wrapper script location
# The wrapper is in hooks/ directory, so plugin root is one level up
plugin_root="$(cd "$(dirname "$0")/.." && pwd)"

# Validate we're in the right directory
if [ ! -f "$plugin_root/CLAUDE.md" ] || [ ! -f "$plugin_root/CANON.md" ]; then
  # Safe no-op — invalid plugin root
  printf '{}\n'
  exit 0
fi

# Export plugin root so hook scripts can use it
export CLAUDE_PLUGIN_ROOT="$plugin_root"

# Pipe stdin through to the actual hook script
bash "$plugin_root/hooks/$hook_script"