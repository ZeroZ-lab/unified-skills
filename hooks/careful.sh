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

# Destructive patterns
destructive_patterns=(
  'rm -rf'
  'rm -r /'
  'git push --force'
  'git push -f'
  'git reset --hard'
  'git checkout .'
  'git clean -f'
  'DROP TABLE'
  'TRUNCATE'
  'DELETE FROM'
  'kubectl delete'
  'docker rm -f'
  'docker system prune'
  ':(){:|:&};:'
  'mkfs'
  'dd if=.*of=/dev'
  '> /dev/sd'
  'chmod -R 777 /'
  'chown -R .* /'
)

# Safe exceptions (directories commonly cleaned)
safe_dirs='node_modules|.next|dist|__pycache__|.cache|build|.turbo|coverage|.gradle|target|vendor|tmp|temp'

for pattern in "${destructive_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -qE "$pattern"; then
    # Check safe exceptions
    if printf '%s' "$cmd" | grep -qE "($safe_dirs)"; then
      continue
    fi
    printf '{"permissionDecision":"ask","message":"[careful] 检测到破坏性命令: %s。确认执行？"}\n' "$pattern"
    exit 0
  fi
done

printf '{}\n'
