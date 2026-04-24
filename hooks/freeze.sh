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

python3 - "$file_path" "$boundary" <<'PY'
import json
import os
import sys
from pathlib import Path

file_path = sys.argv[1]
boundary = sys.argv[2]

resolved_file = Path(file_path).expanduser()
if not resolved_file.is_absolute():
    resolved_file = Path.cwd() / resolved_file
resolved_file = resolved_file.resolve(strict=False)

resolved_boundary = Path(boundary).expanduser()
if not resolved_boundary.is_absolute():
    resolved_boundary = Path.cwd() / resolved_boundary
resolved_boundary = resolved_boundary.resolve(strict=False)

try:
    inside = os.path.commonpath([str(resolved_file), str(resolved_boundary)]) == str(resolved_boundary)
except ValueError:
    inside = False

if inside:
    print("{}")
else:
    print(json.dumps({
        "permissionDecision": "deny",
        "message": f"[freeze] 编辑范围被限制在 {resolved_boundary}。文件 {resolved_file} 在范围外。"
    }, ensure_ascii=False))
PY
