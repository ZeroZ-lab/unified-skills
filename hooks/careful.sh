#!/usr/bin/env bash
# Unified Skills — careful hook
# Intercepts destructive Bash commands.
# On Claude Code: prompts user (permissionDecision: "ask")
# On Codex: blocks irreversible commands by default and only allows
# tightly-scoped cleanup commands when targets stay inside generated dirs.
set -u

# Read JSON from stdin
input=$(cat)

# Detect platform: Codex sends permission_mode, Claude Code does not
is_codex=0
permission_mode=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("permission_mode",""))' 2>/dev/null || echo "")
if [ -n "$permission_mode" ]; then
  is_codex=1
fi

# Extract command field
cmd=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")

if [ -z "$cmd" ]; then
  printf '{}\n'
  exit 0
fi

# Destructive patterns (regex-safe: dots and special chars escaped)
# Keep this list focused on commands that are hard to recover from.
destructive_patterns=(
  'rm -rf'
  'rm -r /'
  'git push --force'
  'git push -f'
  'git reset --hard'
  'git checkout \.'
  'git push origin --delete'
  'DROP TABLE'
  'TRUNCATE'
  'DELETE FROM'
  'kubectl delete'
  'docker rm -f'
  'docker system prune'
  'docker compose down -v'
  'docker volume prune'
  ':(){:|:&};:'
  'mkfs'
  'dd if=.*of=/dev'
  '> /dev/sd'
  'chmod -R 777 /'
  'chown -R .* /'
  'sudo rm'
  'shutdown'
  'reboot'
  'halt'
  'terraform destroy'
  'aws s3 rm'
  'rm -fr'
  'rm -Rf'
  'rm -r -f'
  'rm --recursive'
  'rm --force'
  'drop table'
  'truncate table'
  'delete from'
)

# Safe generated directories that may be removed without confirmation when used
# as cleanup targets. Absolute paths and parent traversal are never bypassed.
is_safe_cleanup_targets() {
  python3 - "$1" <<'PY'
import os
import shlex
import sys

safe_roots = {
    "node_modules", ".next", "dist", "__pycache__", ".cache", "build",
    ".turbo", "coverage", ".gradle", "target", "vendor", "tmp", "temp",
}

try:
    parts = shlex.split(sys.argv[1])
except ValueError:
    sys.exit(1)

if not parts:
    sys.exit(1)

targets = []
if parts[0] == "rm":
    recursive = False
    saw_double_dash = False
    for index, part in enumerate(parts[1:], start=1):
        if saw_double_dash:
            targets.append(part)
            continue
        if part == "--":
            saw_double_dash = True
            continue
        if part.startswith("-"):
            recursive = recursive or "r" in part or "R" in part
            continue
        targets.append(part)
    if not recursive or not targets:
        sys.exit(1)
elif parts[0] == "git" and len(parts) >= 3 and parts[1] == "clean":
    has_force = False
    saw_double_dash = False
    for part in parts[2:]:
        if saw_double_dash:
            targets.append(part)
            continue
        if part == "--":
            saw_double_dash = True
            continue
        if part.startswith("-"):
            has_force = has_force or "f" in part
            continue
        targets.append(part)
    # Unscoped git clean remains destructive and must be denied.
    if not has_force or not targets:
        sys.exit(1)
else:
    sys.exit(1)

for target in targets:
    normalized = os.path.normpath(target)
    if os.path.isabs(normalized) or normalized == ".." or normalized.startswith("../"):
        sys.exit(1)
    root = normalized.split(os.sep, 1)[0]
    if root not in safe_roots:
        sys.exit(1)

sys.exit(0)
PY
}

# On Codex: use "deny" (fail-closed — safer than fail-open "ask")
# On Claude Code: use "ask" (prompts user for confirmation)
if [ "$is_codex" -eq 1 ]; then
  decision="deny"
else
  decision="ask"
fi

for pattern in "${destructive_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -qE "$pattern"; then
    if printf '%s' "$pattern" | grep -qE '^rm -r' && is_safe_cleanup_targets "$cmd"; then
      continue
    fi
    printf '{"permissionDecision":"%s","permissionDecisionReason":"[careful] 检测到破坏性命令: %s。"}\n' "$decision" "$pattern"
    exit 0
  fi
done

# Scoped git clean on generated directories is allowed; broad git clean is denied.
if printf '%s' "$cmd" | grep -qE '^git clean -'; then
  if is_safe_cleanup_targets "$cmd"; then
    printf '{}\n'
  else
    printf '{"permissionDecision":"%s","permissionDecisionReason":"[careful] 检测到未限定范围的 git clean。请只清理生成目录并显式传入路径。"}\n' "$decision"
  fi
  exit 0
fi

printf '{}\n'
