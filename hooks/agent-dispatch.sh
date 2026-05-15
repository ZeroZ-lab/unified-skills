#!/usr/bin/env bash
# Unified Skills — agent-dispatch.sh
# PostToolUse Agent hook: emits additionalContext notification when a subagent is dispatched.
# Shows the dispatched agent's phase, role, and description in the session context.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Read stdin JSON
input=$(cat)

# Extract agent name from tool_input
# The Agent tool's input contains the agent specification
# We try multiple possible field names for robustness
agent_name=$(printf '%s' "$input" | python3 -c '
import sys, json
d = json.loads(sys.stdin.read())
ti = d.get("tool_input", {})
# Try common field names for agent specification
for key in ["name", "agent", "subagent_type", "prompt"]:
    val = ti.get(key, "")
    if val:
        print(val)
        break
' 2>/dev/null || echo "")

# Also try extracting from the tool_result or tool_name
if [ -z "$agent_name" ]; then
  # Fallback: try to extract from the full input
  agent_name=$(printf '%s' "$input" | python3 -c '
import sys, json
d = json.loads(sys.stdin.read())
# Look for agent name in various places
for section in ["tool_input", "tool_result"]:
    obj = d.get(section, {})
    if isinstance(obj, dict):
        for key in ["name", "agent", "subagent_type"]:
            val = obj.get(key, "")
            if val:
                print(val)
                sys.exit(0)
    elif isinstance(obj, str):
        # Try to parse as JSON if it looks structured
        try:
            inner = json.loads(obj)
            for key in ["name", "agent", "subagent_type"]:
                val = inner.get(key, "")
                if val:
                    print(val)
                    sys.exit(0)
        except (json.JSONDecodeError, TypeError):
            pass
print("")
' 2>/dev/null || echo "")
fi

if [ -z "$agent_name" ]; then
  # Could not determine agent name — no-op
  printf '{}\n'
  exit 0
fi

# Phase inference (same logic as subagent-statusline.sh)
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
inside = False
for line in lines:
    stripped = line.strip()
    if stripped == "---":
        inside = not inside
        continue
    if inside and stripped.startswith("description:"):
        val = stripped[len("description:"):].strip()
        if val.startswith("\"") and val.endswith("\""):
            val = val[1:-1]
        elif val.startswith("'") and val.endswith("'"):
            val = val[1:-1]
        print(val)
        break
' "$agent_file" 2>/dev/null || echo "")
fi

# Build notification message
if [ -n "$description" ]; then
  message="[dispatch] \u2192 ${agent_name} (${phase}:${role}) \u2014 ${description}"
else
  message="[dispatch] \u2192 ${agent_name} (${phase}:${role})"
fi

# Output in hookSpecificOutput.additionalContext format (same as session-start.sh)
escaped=$(printf '%s' "$message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$escaped"