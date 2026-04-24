#!/usr/bin/env bash
# Unified Skills — careful hook
# Intercepts destructive Bash commands and asks for user confirmation.
set -u

# Read JSON from stdin
input=$(cat)

# Extract command field
cmd=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")

if [ -z "$cmd" ]; then
  printf '{}\n'
  exit 0
fi

# Destructive patterns (regex-safe: dots and special chars escaped)
destructive_patterns=(
  'rm -rf'
  'rm -r /'
  'git push --force'
  'git push -f'
  'git reset --hard'
  'git checkout \.'
  'git clean -f'
  'git branch -D'
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
)

# Safe generated directories that may be removed without confirmation when used
# as rm targets. Absolute paths and parent traversal are never bypassed.
is_safe_rm_command() {
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

if not parts or parts[0] != "rm":
    sys.exit(1)

recursive = False
targets = []
for part in parts[1:]:
    if part == "--":
        targets.extend(parts[parts.index(part) + 1:])
        break
    if part.startswith("-"):
        recursive = recursive or "r" in part or "R" in part
        continue
    targets.append(part)

if not recursive or not targets:
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

for pattern in "${destructive_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -qE "$pattern"; then
    if printf '%s' "$pattern" | grep -qE '^rm -r' && is_safe_rm_command "$cmd"; then
      continue
    fi
    printf '{"permissionDecision":"ask","message":"[careful] 检测到破坏性命令: %s。确认执行？"}\n' "$pattern"
    exit 0
  fi
done

printf '{}\n'
