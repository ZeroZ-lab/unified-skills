#!/usr/bin/env bash
set -e

echo "Testing hooks..."

json_get() {
  python3 -c '
import json
import sys

path = sys.argv[1].split(".")
data = json.load(sys.stdin)
for key in path:
    data = data[key]
print(data)
  ' "$1"
}

echo "Test 1: SessionStart injects Boot Kernel"
session_output=$(printf '%s' '{"permission_mode":"default"}' | bash hooks/session-start.sh)
session_context=$(printf '%s' "$session_output" | json_get "hookSpecificOutput.additionalContext")

if [[ "$session_context" != *"Boot Kernel"* ]] ||
   [[ "$session_context" != *"skills-router.json"* ]] ||
   [[ "$session_context" != *"AGENTS.md"* ]] ||
   [[ "$session_context" != *"loading tier"* ]]; then
    echo "FAIL: SessionStart output missing Boot Kernel runtime guidance"
    echo "$session_context"
    exit 1
fi

if [[ "$session_context" == *"## 命令映射"* ]] ||
   [[ "$session_context" == *"| 命令 | 加载的技能 |"* ]]; then
    echo "FAIL: SessionStart should not inject full command map"
    echo "$session_context"
    exit 1
fi

line_count=$(printf '%s' "$session_context" | wc -l | tr -d ' ')
if [ "$line_count" -gt 80 ]; then
    echo "FAIL: Boot Kernel too long: $line_count lines"
    echo "$session_context"
    exit 1
fi

echo "PASS: SessionStart injects Boot Kernel"

echo "Test 2: careful denies destructive command on Codex"
careful_output=$(printf '%s' '{"permission_mode":"default","tool_input":{"command":"rm -rf /tmp/unified-danger"}}' | bash hooks/careful.sh)
careful_decision=$(printf '%s' "$careful_output" | json_get "permissionDecision")

if [ "$careful_decision" != "deny" ]; then
  echo "FAIL: careful should deny destructive Codex command"
  echo "$careful_output"
  exit 1
fi

echo "PASS: careful denies destructive Codex command"

echo "Test 3: freeze allows files inside boundary and blocks outside"
tmp=$(mktemp -d)
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

mkdir -p "$tmp/.claude" "$tmp/allowed" "$tmp/blocked"
printf '%s' "$tmp/allowed" > "$tmp/.claude/freeze-boundary.txt"

inside_output=$(printf '%s' "{\"cwd\":\"$tmp\",\"tool_input\":{\"file_path\":\"$tmp/allowed/file.txt\"}}" | CLAUDE_PROJECT_DIR="$tmp" bash hooks/freeze.sh)
if [ "$inside_output" != "{}" ]; then
  echo "FAIL: freeze should allow file inside boundary"
  echo "$inside_output"
  exit 1
fi

outside_output=$(printf '%s' "{\"cwd\":\"$tmp\",\"tool_input\":{\"file_path\":\"$tmp/blocked/file.txt\"}}" | CLAUDE_PROJECT_DIR="$tmp" bash hooks/freeze.sh)
outside_decision=$(printf '%s' "$outside_output" | json_get "permissionDecision")
if [ "$outside_decision" != "deny" ]; then
  echo "FAIL: freeze should deny file outside boundary"
  echo "$outside_output"
  exit 1
fi

echo "PASS: freeze boundary behavior"

echo ""
echo "All hook tests passed!"
