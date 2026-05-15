#!/usr/bin/env bash
# Unified Skills — skill load notification
# Used by Claude Code plugin monitors on on-skill-invoke:<skill-name>.
set -u

skill_name="${1:-}"

if [ -z "$skill_name" ]; then
  exit 0
fi

printf '🔧 [skill] loaded %s\n' "$skill_name"
