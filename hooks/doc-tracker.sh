#!/usr/bin/env bash
# Unified Skills — doc-tracker.sh
# PostToolUse Write|Edit hook: emits additionalContext notification when a phase
# document is written, showing the phase chain progress.
# Only matches files under docs/features/*/0X-*.md pattern.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Read stdin JSON
input=$(cat)

# Extract file_path from tool_input
file_path=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || echo "")
cwd=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("cwd",""))' 2>/dev/null || echo "")
project_dir="${cwd:-${CLAUDE_PROJECT_DIR:-$plugin_root}}"

if [ -z "$file_path" ]; then
  printf '{}\n'
  exit 0
fi

# Check if the file path matches the phase document pattern
# Pattern: docs/features/YYYYMMDD-<name>/0X-<phase>.md
# Also accept absolute paths by checking if the filename part matches
phase_name=""
phase_desc=""
progress_msg=$(python3 - "$file_path" <<'PY'
import sys, re, os

path = sys.argv[1].strip()
# Get the basename
basename = os.path.basename(path)

# Phase document pattern: 00-brainstorm.md, 01-spec.md, 02-design.md, 03-plan.md, 04-review.md, 05-ship.md
phase_map = {
    "00-brainstorm.md": ("brainstorm", "脑暴产出"),
    "01-spec.md": ("define", "spec 产出"),
    "02-design.md": ("design", "设计定稿"),
    "03-plan.md": ("build", "计划产出"),
    "04-review.md": ("verify", "审查产出"),
    "05-ship.md": ("ship", "发布记录"),
}

if basename in phase_map:
    # Verify the path looks like docs/features/*/ pattern
    # Accept both relative and absolute paths
    normalized = os.path.normpath(path)
    parts = normalized.split(os.sep)
    # Look for docs/features pattern in path parts
    found = False
    for i, part in enumerate(parts):
        if part == "features" and i > 0 and parts[i-1] == "docs":
            found = True
            break
    if found:
        phase, desc = phase_map[basename]
        print(f"{phase}|{desc}|{basename}")
    else:
        print("")
else:
    print("")
PY
)

if [ -z "$progress_msg" ]; then
  # Not a phase document — no-op
  printf '{}\n'
  exit 0
fi

# Parse the result: phase|desc|basename
phase=$(printf '%s' "$progress_msg" | cut -d'|' -f1)
desc=$(printf '%s' "$progress_msg" | cut -d'|' -f2)
basename=$(printf '%s' "$progress_msg" | cut -d'|' -f3)

state_note=""
if [ -f "$plugin_root/scripts/unified-state.py" ]; then
  if python3 "$plugin_root/scripts/unified-state.py" update-from-phase-doc "$project_dir" "$file_path" >/dev/null 2>&1; then
    state_note="；feature state 已更新"
  else
    state_note="；feature state 更新失败，请检查阶段文档路径"
  fi
fi

message="[progress] 产出 ${basename} \u2014 阶段链进展至 ${phase} (${desc})${state_note}"

# Output in hookSpecificOutput.additionalContext format
escaped=$(printf '%s' "$message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$escaped"
