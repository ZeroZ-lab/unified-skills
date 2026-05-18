#!/usr/bin/env bash
# Unified Skills — phase-stop.sh
# Stop hook: checks for unsaved work context and suggests /save.
# Emits additionalContext reminder if there are checkpoint-worthy unsaved changes.
set -u

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Read stdin JSON
input=$(cat)

# Extract reason for stop
reason=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("reason",""))' 2>/dev/null || echo "")

# Find project directory from cwd or environment
cwd=$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("cwd",""))' 2>/dev/null || echo "")
project_dir="${cwd:-${CLAUDE_PROJECT_DIR:-.}}"

active_state=0
if [ -f "$plugin_root/scripts/unified-state.py" ]; then
  if python3 "$plugin_root/scripts/unified-state.py" latest "$project_dir" >/dev/null 2>&1; then
    active_state=1
  fi
fi

# Check for unsaved work indicators
# 1. Check if .claude/checkpoints/ has any recent files (within current session)
# 2. Check if docs/features/ has any phase documents modified recently
has_unsaved=$(python3 - "$project_dir" "$reason" <<'PY'
import sys, os, time, glob

project_dir = sys.argv[1]
reason = sys.argv[2] if len(sys.argv) > 1 else ""

# Don't nag on forced stops or error stops
if reason in ("error", "interrupt", "force"):
    print("no")
    sys.exit(0)

# Check for checkpoint files
checkpoint_dir = os.path.join(project_dir, ".claude", "checkpoints")
if os.path.isdir(checkpoint_dir):
    # Check if there are any checkpoint files
    checkpoints = glob.glob(os.path.join(checkpoint_dir, "*.md"))
    if checkpoints:
        # If checkpoints exist, user has already saved — no nag needed
        # But check if they're old (more than 1 hour) vs recent
        now = time.time()
        recent = [f for f in checkpoints if now - os.path.getmtime(f) < 3600]
        if recent:
            print("already_saved")
            sys.exit(0)

# Check for phase documents in docs/features/
features_dir = os.path.join(project_dir, "docs", "features")
if os.path.isdir(features_dir):
    # Look for any phase documents that exist
    phase_docs = glob.glob(os.path.join(features_dir, "*", "0[1-5]-*.md"))
    if phase_docs:
        # There are phase documents — check if they have corresponding checkpoints
        checkpoint_dir = os.path.join(project_dir, ".claude", "checkpoints")
        if not os.path.isdir(checkpoint_dir):
            # No checkpoint directory at all — definitely unsaved
            print("unsaved")
            sys.exit(0)

# No indicators of unsaved work
print("no")
PY
)

if [ "$has_unsaved" = "no" ] || [ "$has_unsaved" = "already_saved" ]; then
  # No unsaved work or already saved — no-op
  printf '{}\n'
  exit 0
fi

# There is unsaved work — emit systemMessage reminder
# Stop hooks support: systemMessage, decision, reason, continue, suppressOutput, stopReason
# NOT hookSpecificOutput.additionalContext (that's only for PreToolUse/UserPromptSubmit/PostToolUse)
if [ "$active_state" -eq 1 ]; then
  message="[reminder] feature state 已自动记录；如本 session 有关键决策，可执行 /save 记录决策 checkpoint"
else
  message="[reminder] 本 session 有可保存的工作上下文，建议 /save 后再离开"
fi

escaped=$(printf '%s' "$message" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
printf '{"systemMessage":%s}\n' "$escaped"
