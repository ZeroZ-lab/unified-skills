#!/usr/bin/env bash
set -euo pipefail

echo "Testing unified feature state..."

tmp=$(mktemp -d)
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

repo="$tmp/repo"
mkdir -p "$repo/docs/features/20260518-sample"
cp scripts/unified-state.py "$repo/unified-state.py" 2>/dev/null || true

run_state() {
  python3 scripts/unified-state.py "$@"
}

touch "$repo/docs/features/20260518-sample/03-plan.md"

echo "Test 1: update-from-phase-doc creates valid state"
run_state update-from-phase-doc "$repo" "$repo/docs/features/20260518-sample/03-plan.md" >/dev/null
state="$repo/docs/features/20260518-sample/state.json"
python3 - "$state" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["schema_version"] == 1
assert data["feature_path"] == "docs/features/20260518-sample"
assert data["current_stage"] == "plan"
assert data["last_phase_doc"] == "03-plan.md"
assert data["next_command"] == "/build"
assert "dirty_status" not in data
PY
run_state validate "$state"
echo "PASS: update-from-phase-doc creates valid state"

echo "Test 2: latest returns active feature state"
latest=$(run_state latest "$repo")
if [[ "$latest" != *"docs/features/20260518-sample/state.json"* ]]; then
  echo "FAIL: latest did not return sample state"
  echo "$latest"
  exit 1
fi
echo "PASS: latest returns active feature state"

echo "Test 3: format-resume contains next command"
resume=$(run_state format-resume "$repo")
if [[ "$resume" != *"docs/features/20260518-sample"* ]] ||
   [[ "$resume" != *"/build"* ]]; then
  echo "FAIL: resume hint missing feature or next command"
  echo "$resume"
  exit 1
fi
echo "PASS: format-resume contains next command"

echo "Test 4: mark-build-complete advances to review"
run_state mark-build-complete "$repo" "docs/features/20260518-sample" >/dev/null
python3 - "$state" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["current_stage"] == "build"
assert data["last_phase_doc"] == "03-plan.md"
assert data["next_command"] == "/review"
PY
resume=$(run_state format-resume "$repo")
if [[ "$resume" != *"/review"* ]]; then
  echo "FAIL: build-complete resume should point to /review"
  echo "$resume"
  exit 1
fi
echo "PASS: mark-build-complete advances to review"

echo "Test 5: ship state is valid and inactive for latest"
touch "$repo/docs/features/20260518-sample/05-ship.md"
run_state update-from-phase-doc "$repo" "$repo/docs/features/20260518-sample/05-ship.md" >/dev/null
python3 - "$state" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["current_stage"] == "ship"
assert data["next_command"] is None
PY
if run_state latest "$repo" >/tmp/unified-state-latest.out 2>/tmp/unified-state-latest.err; then
  echo "FAIL: latest should not return shipped inactive state"
  cat /tmp/unified-state-latest.out
  exit 1
fi
echo "PASS: shipped state is inactive for latest"

echo "Test 6: forbidden local keys fail validation"
python3 - "$state" <<'PY'
import json
import sys

path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["dirty_status"] = "dirty"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2)
PY
if run_state validate "$state" >/tmp/unified-state-validate.out 2>/tmp/unified-state-validate.err; then
  echo "FAIL: dirty_status should fail validation"
  exit 1
fi
echo "PASS: forbidden local keys fail validation"

echo "Test 7: outside phase doc is rejected"
mkdir -p "$repo/docs/other"
touch "$repo/docs/other/03-plan.md"
if run_state update-from-phase-doc "$repo" "$repo/docs/other/03-plan.md" >/tmp/unified-state-outside.out 2>/tmp/unified-state-outside.err; then
  echo "FAIL: outside docs/features path should be rejected"
  exit 1
fi
echo "PASS: outside phase doc is rejected"

echo ""
echo "All unified state tests passed!"
