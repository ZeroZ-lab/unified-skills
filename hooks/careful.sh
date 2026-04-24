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

# Safe target paths (only these paths are allowed to be destroyed)
safe_paths='node_modules|.next|dist|__pycache__|.cache|build|.turbo|coverage|.gradle|target|vendor|tmp|temp'

for pattern in "${destructive_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -qE "$pattern"; then
    # Check safe target: extract the path argument after rm/git etc.
    # Only allow if the TARGET path matches a safe directory
    target=$(printf '%s' "$cmd" | grep -oE '(rm -rf |rm -r )[^ ]+' | sed 's/^rm -[rf]* //' || true)
    if [ -n "$target" ] && printf '%s' "$target" | grep -qE "^($safe_paths)$"; then
      continue
    fi
    # Also allow if the entire command's last argument is a safe path
    last_arg=$(printf '%s' "$cmd" | awk '{print $NF}' || true)
    if printf '%s' "$last_arg" | grep -qE "^($safe_paths)$"; then
      continue
    fi
    printf '{"permissionDecision":"ask","message":"[careful] 检测到破坏性命令: %s。确认执行？"}\n' "$pattern"
    exit 0
  fi
done

printf '{}\n'