#!/usr/bin/env bash
# Unified Skills — freeze hook
# Blocks Edit/Write operations outside the configured freeze boundary.
set -u

# Read JSON from stdin
input=$(cat)

# Extract file_path field
file_path=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || echo "")

if [ -z "$file_path" ]; then
  printf '{}\n'
  exit 0
fi

# Read freeze boundary
boundary_file="${CLAUDE_PROJECT_DIR:-.}/.claude/freeze-boundary.txt"
if [ ! -f "$boundary_file" ]; then
  # No freeze active
  printf '{}\n'
  exit 0
fi

boundary=$(cat "$boundary_file" 2>/dev/null | tr -d '\n')

if [ -z "$boundary" ]; then
  printf '{}\n'
  exit 0
fi

# Resolve both paths to absolute
resolved_file=$(cd "$(dirname "$file_path")" 2>/dev/null && pwd)/$(basename "$file_path") 2>/dev/null || echo "$file_path"
resolved_boundary=$(cd "$boundary" 2>/dev/null && pwd) || echo "$boundary"

# Normalize: remove trailing slashes
resolved_file="${resolved_file%/}"
resolved_boundary="${resolved_boundary%/}"

# Check if file is within boundary
if printf '%s' "$resolved_file" | grep -qE "^${resolved_boundary}(/|\$)"; then
  # Inside boundary — allow
  printf '{}\n'
else
  # Outside boundary — deny
  printf '{"permissionDecision":"deny","message":"[freeze] 编辑范围被限制在 %s。文件 %s 在范围外。"}\n' "$resolved_boundary" "$resolved_file"
fi
