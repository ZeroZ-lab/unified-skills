#!/usr/bin/env bash
# Unified Skills — subagentStatusLine script
# Reads JSON from stdin, extracts agent context, and outputs a formatted
# status line showing phase, role, agent name, description, and context usage.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Read stdin JSON
input=$(cat)

# Extract key fields from stdin JSON
agent_name=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("agent",{}).get("name",""))' 2>/dev/null || echo "")
ctx_pct=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); cw=d.get("context_window",{}); print(str(int(cw.get("used_percentage",0))))' 2>/dev/null || echo "0")

if [ -z "$agent_name" ]; then
  # No agent context available — output nothing
  echo ""
  exit 0
fi

# Phase inference from agent naming convention
# refine-*       → define:scout
# plan-*          → build:reviewer
# review-*        → verify:auditor
# ship-*          → ship:auditor
# design-*        → design:reviewer
# software-engineer → build:engineer
# task-planner     → build:planner
# requirements-analyst → define:analyst
# content-writer   → build:writer
# visual-designer  → design:designer
# data-architect   → build:architect
# api-designer     → build:designer

phase=""
role=""
case "$agent_name" in
  refine-*)           phase="define";  role="scout"    ;;
  plan-*)             phase="build";   role="reviewer" ;;
  review-*)           phase="verify";  role="auditor"  ;;
  ship-*)             phase="ship";    role="auditor"  ;;
  design-*)           phase="design";  role="reviewer" ;;
  software-engineer)  phase="build";   role="engineer" ;;
  task-planner)       phase="build";   role="planner"  ;;
  requirements-analyst) phase="define"; role="analyst" ;;
  content-writer)     phase="build";   role="writer"   ;;
  visual-designer)    phase="design";  role="designer" ;;
  data-architect)     phase="build";   role="architect" ;;
  api-designer)       phase="build";   role="designer" ;;
  *)                  phase="?";       role="?"        ;;
esac

# Try to read description from agents/<name>.md frontmatter
description=""
agent_file="$plugin_root/agents/${agent_name}.md"
if [ -f "$agent_file" ]; then
  description=$(python3 -c '
import sys
with open(sys.argv[1], "r") as f:
    lines = f.readlines()
# Find YAML frontmatter between --- markers
inside = False
for line in lines:
    stripped = line.strip()
    if stripped == "---":
        inside = not inside
        continue
    if inside and stripped.startswith("description:"):
        # Remove "description:" prefix and quotes
        val = stripped[len("description:"):].strip()
        # Strip surrounding quotes if present
        if val.startswith("\"") and val.endswith("\""):
            val = val[1:-1]
        elif val.startswith("'") and val.endswith("'"):
            val = val[1:-1]
        # Truncate to 30 chars for status line
        print(val[:30] if len(val) > 30 else val)
        break
' "$agent_file" 2>/dev/null || echo "")
fi

# Format status line
if [ -n "$description" ]; then
  printf '[%s:%s] %s — %s | %s%%' "$phase" "$role" "$agent_name" "$description" "$ctx_pct"
else
  printf '[%s:%s] %s | %s%%' "$phase" "$role" "$agent_name" "$ctx_pct"
fi