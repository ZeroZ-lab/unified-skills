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

hook_command() {
  python3 - "$1" "$2" <<'PY'
import json
import sys

event, matcher = sys.argv[1:3]
hooks = json.load(open("hooks/hooks.json", encoding="utf-8"))["hooks"][event]
for entry in hooks:
    if entry.get("matcher", "") == matcher:
        print(entry["hooks"][0]["command"])
        raise SystemExit(0)
raise SystemExit(f"missing hook command for {event} {matcher}")
PY
}

codex_hook_command() {
  python3 - "$1" "$2" <<'PY'
import json
import sys

event, matcher = sys.argv[1:3]
hooks = json.load(open(".codex/hooks.json", encoding="utf-8"))["hooks"][event]
for entry in hooks:
    if entry.get("matcher", "") == matcher:
        print(entry["hooks"][0]["command"])
        raise SystemExit(0)
raise SystemExit(f"missing Codex hook command for {event} {matcher}")
PY
}

echo "Test 1: SessionStart injects Boot Kernel"
session_output=$(printf '%s' '{"permission_mode":"default"}' | bash hooks/session-start.sh)
session_context=$(printf '%s' "$session_output" | json_get "hookSpecificOutput.additionalContext")

if [[ "$session_context" != *"Boot Kernel"* ]] ||
   [[ "$session_context" != *"不自动激活 Unified runtime"* ]] ||
   [[ "$session_context" != *"/refine"* ]] ||
   [[ "$session_context" != *"AGENTS.md"* ]] ||
   [[ "$session_context" != *"skills-router.json"* ]]; then
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

echo "Test 3: careful allows scoped cleanup in generated directories"
safe_rm_output=$(printf '%s' '{"permission_mode":"default","tool_input":{"command":"rm -rf dist .next"}}' | bash hooks/careful.sh)
if [ "$safe_rm_output" != "{}" ]; then
  echo "FAIL: careful should allow scoped rm cleanup in generated directories"
  echo "$safe_rm_output"
  exit 1
fi

safe_clean_output=$(printf '%s' '{"permission_mode":"default","tool_input":{"command":"git clean -fd -- dist coverage"}}' | bash hooks/careful.sh)
if [ "$safe_clean_output" != "{}" ]; then
  echo "FAIL: careful should allow scoped git clean in generated directories"
  echo "$safe_clean_output"
  exit 1
fi

unsafe_clean_output=$(printf '%s' '{"permission_mode":"default","tool_input":{"command":"git clean -fdx"}}' | bash hooks/careful.sh)
unsafe_clean_decision=$(printf '%s' "$unsafe_clean_output" | json_get "permissionDecision")
if [ "$unsafe_clean_decision" != "deny" ]; then
  echo "FAIL: careful should deny unscoped git clean"
  echo "$unsafe_clean_output"
  exit 1
fi

echo "PASS: careful cleanup behavior is balanced"

echo "Test 4: Codex hook command resolves outside repo root"
codex_careful_command=$(codex_hook_command "PreToolUse" "Bash")
codex_tmp=$(mktemp -d)
codex_outside="$codex_tmp/outside"
mkdir -p "$codex_outside"
codex_output=$(
  cd "$codex_outside"
  printf '%s' '{"permission_mode":"default","tool_input":{"command":"ls"}}' |
    env -u CLAUDE_PLUGIN_ROOT bash -c "$codex_careful_command"
)
if [ "$codex_output" != "{}" ]; then
  echo "FAIL: Codex careful command should resolve the repo from parent/cache candidates outside repo root"
  echo "$codex_output"
  exit 1
fi

codex_missing_home="$codex_tmp/home"
mkdir -p "$codex_missing_home"
codex_missing_output=$(
  cd "$codex_outside"
  printf '%s' '{"permission_mode":"default","tool_input":{"command":"ls"}}' |
    HOME="$codex_missing_home" env -u CLAUDE_PLUGIN_ROOT bash -c "$codex_careful_command"
)
codex_missing_decision=$(printf '%s' "$codex_missing_output" | json_get "permissionDecision")
if [ "$codex_missing_decision" != "deny" ]; then
  echo "FAIL: Codex careful command should fail closed when plugin root cannot be resolved"
  echo "$codex_missing_output"
  exit 1
fi
rm -rf "$codex_tmp"

echo "PASS: Codex hook command resolves outside repo root"

echo "Test 5: Claude hook command resolves without CLAUDE_PLUGIN_ROOT"
claude_careful_command=$(hook_command "PreToolUse" "Bash")
claude_output=$(printf '%s' '{"permission_mode":"default","tool_input":{"command":"ls"}}' | env -u CLAUDE_PLUGIN_ROOT bash -c "$claude_careful_command")
if [ "$claude_output" != "{}" ]; then
  echo "FAIL: Claude careful command should fall back to repo cwd when CLAUDE_PLUGIN_ROOT is missing"
  echo "$claude_output"
  exit 1
fi

claude_tmp=$(mktemp -d)
fake_home="$claude_tmp/home"
mkdir -p "$fake_home/.claude/plugins"
python3 - "$fake_home" "$PWD" <<'PY'
import json
import sys
from pathlib import Path

home, root = sys.argv[1:3]
data = {
    "version": 2,
    "plugins": {
        "unified@unified-skills": [
            {"installPath": root, "version": "test"}
        ]
    },
}
Path(home, ".claude/plugins/installed_plugins.json").write_text(
    json.dumps(data),
    encoding="utf-8",
)
PY

outside_cwd="$claude_tmp/outside"
mkdir -p "$outside_cwd"
claude_installed_output=$(
  cd "$outside_cwd"
  printf '%s' '{"permission_mode":"default","tool_input":{"command":"ls"}}' |
    HOME="$fake_home" env -u CLAUDE_PLUGIN_ROOT bash -c "$claude_careful_command"
)
if [ "$claude_installed_output" != "{}" ]; then
  echo "FAIL: Claude careful command should fall back to installed_plugins.json when cwd is not the plugin root"
  echo "$claude_installed_output"
  exit 1
fi

missing_home="$claude_tmp/missing-home"
mkdir -p "$missing_home"
missing_output=$(
  cd "$outside_cwd"
  printf '%s' '{"permission_mode":"default","tool_input":{"command":"ls"}}' |
    HOME="$missing_home" env -u CLAUDE_PLUGIN_ROOT bash -c "$claude_careful_command"
)
missing_decision=$(printf '%s' "$missing_output" | json_get "permissionDecision")
if [ "$missing_decision" != "deny" ]; then
  echo "FAIL: Claude careful command should fail closed when plugin root cannot be resolved"
  echo "$missing_output"
  exit 1
fi
rm -rf "$claude_tmp"

echo "PASS: Claude hook command resolves without CLAUDE_PLUGIN_ROOT"

echo "Test 6: freeze allows files inside boundary and blocks outside"
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

echo "Test 7: doc-tracker updates feature state"
feature_dir="$tmp/docs/features/20260518-sample"
mkdir -p "$feature_dir"
touch "$feature_dir/00-brainstorm.md" "$feature_dir/03-plan.md" "$feature_dir/05-ship.md"

tracker_output=$(printf '%s' "{\"cwd\":\"$tmp\",\"tool_input\":{\"file_path\":\"$feature_dir/00-brainstorm.md\"}}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/doc-tracker.sh)
tracker_context=$(printf '%s' "$tracker_output" | json_get "hookSpecificOutput.additionalContext")
if [[ "$tracker_context" != *"00-brainstorm.md"* ]] ||
   [[ "$tracker_context" != *"feature state 已更新"* ]]; then
  echo "FAIL: doc-tracker should report brainstorm progress and state update"
  echo "$tracker_output"
  exit 1
fi

python3 - "$feature_dir/state.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["current_stage"] == "brainstorm"
assert data["next_command"] == "/refine"
PY

printf '%s' "{\"cwd\":\"$tmp\",\"tool_input\":{\"file_path\":\"$feature_dir/03-plan.md\"}}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/doc-tracker.sh >/dev/null
python3 - "$feature_dir/state.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["current_stage"] == "plan"
assert data["next_command"] == "/build"
PY

printf '%s' "{\"cwd\":\"$tmp\",\"tool_input\":{\"file_path\":\"$feature_dir/05-ship.md\"}}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/doc-tracker.sh >/dev/null
python3 - "$feature_dir/state.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["current_stage"] == "ship"
assert data["next_command"] is None
PY

touch "$tmp/not-a-feature.md"
non_feature_output=$(printf '%s' "{\"cwd\":\"$tmp\",\"tool_input\":{\"file_path\":\"$tmp/not-a-feature.md\"}}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/doc-tracker.sh)
if [ "$non_feature_output" != "{}" ]; then
  echo "FAIL: doc-tracker should ignore non-feature writes"
  echo "$non_feature_output"
  exit 1
fi

touch "$tmp/03-plan.md"
outside_phase_output=$(printf '%s' "{\"cwd\":\"$tmp\",\"tool_input\":{\"file_path\":\"$tmp/03-plan.md\"}}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/doc-tracker.sh)
if [ "$outside_phase_output" != "{}" ]; then
  echo "FAIL: doc-tracker should ignore phase-named files outside docs/features"
  echo "$outside_phase_output"
  exit 1
fi

echo "PASS: doc-tracker updates feature state"

echo "Test 8: SessionStart surfaces active feature state"
resume_tmp=$(mktemp -d)
mkdir -p "$resume_tmp/docs/features/20260518-resume"
touch "$resume_tmp/docs/features/20260518-resume/03-plan.md"
python3 scripts/unified-state.py update-from-phase-doc "$resume_tmp" "$resume_tmp/docs/features/20260518-resume/03-plan.md" >/dev/null

resume_output=$(printf '%s' "{\"permission_mode\":\"default\",\"cwd\":\"$resume_tmp\"}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/session-start.sh)
resume_context=$(printf '%s' "$resume_output" | json_get "hookSpecificOutput.additionalContext")
if [[ "$resume_context" != *"Active feature resume"* ]] ||
   [[ "$resume_context" != *"docs/features/20260518-resume"* ]] ||
   [[ "$resume_context" != *"/build"* ]] ||
   [[ "$resume_context" != *"不会自动激活 Unified runtime"* ]]; then
  echo "FAIL: SessionStart should include active feature resume hint"
  echo "$resume_context"
  exit 1
fi

empty_tmp=$(mktemp -d)
empty_output=$(printf '%s' "{\"permission_mode\":\"default\",\"cwd\":\"$empty_tmp\"}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/session-start.sh)
empty_context=$(printf '%s' "$empty_output" | json_get "hookSpecificOutput.additionalContext")
if [[ "$empty_context" == *"Active feature resume"* ]]; then
  echo "FAIL: SessionStart should omit resume hint when no active state exists"
  echo "$empty_context"
  exit 1
fi

echo "PASS: SessionStart surfaces active feature state"

echo "Test 9: phase-stop distinguishes automatic state from decision checkpoints"
stop_tmp=$(mktemp -d)
mkdir -p "$stop_tmp/docs/features/20260518-stop"
touch "$stop_tmp/docs/features/20260518-stop/03-plan.md"
python3 scripts/unified-state.py update-from-phase-doc "$stop_tmp" "$stop_tmp/docs/features/20260518-stop/03-plan.md" >/dev/null

stop_output=$(printf '%s' "{\"cwd\":\"$stop_tmp\",\"reason\":\"stop\"}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/phase-stop.sh)
stop_message=$(printf '%s' "$stop_output" | json_get "systemMessage")
if [[ "$stop_message" != *"feature state 已自动记录"* ]] ||
   [[ "$stop_message" != *"决策 checkpoint"* ]]; then
  echo "FAIL: phase-stop should distinguish automatic feature state from /save"
  echo "$stop_output"
  exit 1
fi

forced_stop=$(printf '%s' "{\"cwd\":\"$stop_tmp\",\"reason\":\"interrupt\"}" | CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/phase-stop.sh)
if [ "$forced_stop" != "{}" ]; then
  echo "FAIL: phase-stop should ignore interrupt stops"
  echo "$forced_stop"
  exit 1
fi

echo "PASS: phase-stop distinguishes automatic state from decision checkpoints"

echo ""
echo "All hook tests passed!"
