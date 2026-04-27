#!/usr/bin/env bash
# Unified Skills — freeze hook
# Blocks Edit/Write/apply_patch operations outside the configured freeze boundary.
# Uses os.path.realpath() for proper symlink resolution.
# Validates boundary file to reject overly broad paths.
set -u

# Read JSON from stdin
input=$(cat)

# Extract file_path field
file_path=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || echo "")

if [ -z "$file_path" ]; then
  printf '{}\n'
  exit 0
fi

# Resolve plugin root for freeze-boundary.txt path
plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
boundary_file="${CLAUDE_PROJECT_DIR:-.}/.claude/freeze-boundary.txt"

if [ ! -f "$boundary_file" ]; then
  # Also check plugin-root-relative path (for Codex wrapper scenario)
  boundary_file_alt="$plugin_root/.claude/freeze-boundary.txt"
  if [ ! -f "$boundary_file_alt" ]; then
    # No freeze active
    printf '{}\n'
    exit 0
  fi
  boundary_file="$boundary_file_alt"
fi

boundary=$(cat "$boundary_file" 2>/dev/null | tr -d '\n')

if [ -z "$boundary" ]; then
  printf '{}\n'
  exit 0
fi

# Extract cwd from stdin JSON for project root detection
cwd=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("cwd",""))' 2>/dev/null || echo "")

python3 - "$file_path" "$boundary" "$cwd" <<'PY'
import json
import os
import sys
from pathlib import Path

file_path = sys.argv[1]
boundary = sys.argv[2]
cwd = sys.argv[3] if len(sys.argv) > 3 else ""

# Resolve file path using realpath (follows symlinks)
resolved_file = Path(file_path).expanduser()
if not resolved_file.is_absolute():
    if cwd:
        resolved_file = Path(cwd) / resolved_file
    else:
        resolved_file = Path.cwd() / resolved_file
resolved_file = Path(os.path.realpath(str(resolved_file)))

# Resolve boundary using realpath (follows symlinks)
resolved_boundary = Path(boundary).expanduser()
if not resolved_boundary.is_absolute():
    if cwd:
        resolved_boundary = Path(cwd) / resolved_boundary
    else:
        resolved_boundary = Path.cwd() / resolved_boundary
resolved_boundary = Path(os.path.realpath(str(resolved_boundary)))

# Validate boundary: reject "/" or paths outside project
boundary_real = str(resolved_boundary)
if boundary_real == "/" or boundary_real == os.sep:
    print(json.dumps({
        "permissionDecision": "deny",
        "permissionDecisionReason": f"[freeze] 边界路径 '/' 过宽，不允许冻结整个文件系统。"
    }, ensure_ascii=False))
    sys.exit(0)

# Reject boundary outside project root (cwd)
if cwd and not boundary_real.startswith(os.path.realpath(cwd)):
    print(json.dumps({
        "permissionDecision": "deny",
        "permissionDecisionReason": f"[freeze] 边界路径 {boundary_real} 不在项目目录 {os.path.realpath(cwd)} 内。"
    }, ensure_ascii=False))
    sys.exit(0)

# Check if file is inside freeze boundary
try:
    inside = os.path.commonpath([resolved_file, resolved_boundary]) == resolved_boundary
except ValueError:
    inside = False

if inside:
    print("{}")
else:
    print(json.dumps({
        "permissionDecision": "deny",
        "permissionDecisionReason": f"[freeze] 编辑范围被限制在 {resolved_boundary}。文件 {resolved_file} 在范围外。"
    }, ensure_ascii=False))
PY