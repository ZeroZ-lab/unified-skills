#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECKER="$ROOT/scripts/check-doc-sync-contract.py"
TMPROOT="${TMPDIR:-/tmp}/unified-doc-sync-test.$$"

trap 'rm -rf "$TMPROOT"' EXIT

make_fixture() {
  local name="$1"
  local fixture="$TMPROOT/$name"
  mkdir -p "$fixture/docs/features/sample"
  printf '%s\n' "$fixture"
}

expect_failure() {
  local fixture="$1"
  local expected="$2"
  local output="$fixture/check.out"

  if python3 "$CHECKER" --root "$fixture" >"$output" 2>&1; then
    printf 'expected failure but checker passed: %s\n' "$expected" >&2
    return 1
  fi

  if ! grep -Fq "$expected" "$output"; then
    printf 'missing expected failure: %s\n' "$expected" >&2
    cat "$output" >&2
    return 1
  fi
}

fixture="$(make_fixture positive-feature-only)"
cat >"$fixture/docs/features/sample/01-spec.md" <<'EOF'
# Sample — Spec

## Documentation Impact
- `doc_intent: feature_only`
- `project_truth_changed: no`
- `affected_project_docs:`
  - 无
EOF
python3 "$CHECKER" --root "$fixture"
printf 'PASS feature_only positive fixture\n'

fixture="$(make_fixture negative-missing-affected)"
cat >"$fixture/docs/features/sample/01-spec.md" <<'EOF'
# Sample — Spec

## Documentation Impact
- `doc_intent: feature_plus_project`
- `project_truth_changed: yes`
- `affected_project_docs:`
  - 无
EOF
expect_failure "$fixture" "project_truth_changed=yes but affected_project_docs is empty"
printf 'PASS missing affected_project_docs negative fixture\n'

fixture="$(make_fixture positive-full-chain)"
cat >"$fixture/docs/features/sample/01-spec.md" <<'EOF'
# Sample — Spec

## Documentation Impact
- `doc_intent: feature_plus_project`
- `project_truth_changed: yes`
- `affected_project_docs:`
  - README.md
EOF
cat >"$fixture/docs/features/sample/03-plan.md" <<'EOF'
# Sample — Plan

## Project Doc Sync Plan
- Must update:
  - README.md
- Stage owner:
  - ship
- Verification method:
  - review
EOF
cat >"$fixture/docs/features/sample/04-review.md" <<'EOF'
# Sample — Review

## Documentation Compliance
- Required project docs updated: PASS
EOF
python3 "$CHECKER" --root "$fixture"
printf 'PASS full-chain positive fixture\n'

fixture="$(make_fixture negative-review-fail)"
cat >"$fixture/docs/features/sample/01-spec.md" <<'EOF'
# Sample — Spec

## Documentation Impact
- `doc_intent: feature_plus_project`
- `project_truth_changed: yes`
- `affected_project_docs:`
  - README.md
EOF
cat >"$fixture/docs/features/sample/03-plan.md" <<'EOF'
# Sample — Plan

## Project Doc Sync Plan
- Must update:
  - README.md
- Stage owner:
  - ship
- Verification method:
  - review
EOF
cat >"$fixture/docs/features/sample/04-review.md" <<'EOF'
# Sample — Review

## Documentation Compliance
- Required project docs updated: FAIL
EOF
expect_failure "$fixture" "Required project docs updated must be PASS"
printf 'PASS review FAIL negative fixture\n'
