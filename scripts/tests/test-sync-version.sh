#!/usr/bin/env bash
set -euo pipefail

echo "Testing version sync..."

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_VERSION="2.15.0-test"
TMPROOT="${TMPDIR:-/tmp}/unified-sync-version-test.$$"

trap 'rm -rf "$TMPROOT"' EXIT

mkdir -p "$TMPROOT/.claude-plugin" "$TMPROOT/.codex-plugin" "$TMPROOT/scripts"
cp "$ROOT/package.json" "$TMPROOT/package.json"
cp "$ROOT/skills-index.json" "$TMPROOT/skills-index.json"
cp "$ROOT/skills-router.json" "$TMPROOT/skills-router.json"
cp "$ROOT/.claude-plugin/plugin.json" "$TMPROOT/.claude-plugin/plugin.json"
cp "$ROOT/.claude-plugin/marketplace.json" "$TMPROOT/.claude-plugin/marketplace.json"
cp "$ROOT/.codex-plugin/plugin.json" "$TMPROOT/.codex-plugin/plugin.json"
cp "$ROOT/scripts/sync-version.sh" "$TMPROOT/scripts/sync-version.sh"
cp "$ROOT/scripts/generate-router.sh" "$TMPROOT/scripts/generate-router.sh"
cp -R "$ROOT/skills" "$TMPROOT/skills"

cd "$TMPROOT"

echo "Test 1: Normal sync"
python3 -c "import json; d=json.load(open('package.json')); d['version']='$TEST_VERSION'; json.dump(d, open('package.json', 'w'), indent=2)"

bash scripts/sync-version.sh

pkg_ver=$(python3 -c "import json; print(json.load(open('package.json'))['version'])")
claude_ver=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
codex_ver=$(python3 -c "import json; print(json.load(open('.codex-plugin/plugin.json'))['version'])")
router_ver=$(python3 -c "import json; print(json.load(open('skills-router.json'))['version'])")
metadata_check=$(python3 - <<'PY'
import json
import re

files = [
    ".claude-plugin/plugin.json",
    ".codex-plugin/plugin.json",
    ".claude-plugin/marketplace.json",
]
texts = []
for file in files:
    data = json.load(open(file))
    texts.append(json.dumps(data, ensure_ascii=False))

joined = "\n".join(texts)
if "v2.15.0-test" not in joined:
    raise SystemExit("missing synced version prefix in descriptions")
if re.search(r"(^|[^0-9.])\d+\s*(?:个)?(?:技能|命令|角色|SKILL)", joined):
    raise SystemExit("dynamic inventory count remains in descriptions")
if "v2.14.0" in joined:
    raise SystemExit("stale metadata remains")
print("ok")
PY
)

if [ "$pkg_ver" != "$TEST_VERSION" ] || [ "$claude_ver" != "$TEST_VERSION" ] || [ "$codex_ver" != "$TEST_VERSION" ] || [ "$router_ver" != "$TEST_VERSION" ] || [ "$metadata_check" != "ok" ]; then
  echo "FAIL: Version mismatch"
  echo "  package.json: $pkg_ver (expected $TEST_VERSION)"
  echo "  .claude-plugin: $claude_ver (expected $TEST_VERSION)"
  echo "  .codex-plugin: $codex_ver (expected $TEST_VERSION)"
  echo "  skills-router.json: $router_ver (expected $TEST_VERSION)"
  exit 1
fi

echo "PASS: Version sync test 1"

echo "Test 2: Dry-run mode"
python3 -c "import json; d=json.load(open('package.json')); d['version']='2.16.0'; json.dump(d, open('package.json', 'w'), indent=2)"

bash scripts/sync-version.sh --dry-run

claude_ver=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
marketplace_snapshot=$(python3 -c "import json; print(json.load(open('.claude-plugin/marketplace.json'))['description'])")
router_ver=$(python3 -c "import json; print(json.load(open('skills-router.json'))['version'])")
if [ "$claude_ver" != "$TEST_VERSION" ] || [ "$router_ver" != "$TEST_VERSION" ] || [[ "$marketplace_snapshot" != v"$TEST_VERSION"* ]]; then
  echo "FAIL: Dry-run modified files"
  exit 1
fi

echo "PASS: Dry-run test"

echo "Test 3: Error handling"
mv package.json package.json.hidden

if bash scripts/sync-version.sh 2>/dev/null; then
  echo "FAIL: Should fail when package.json missing"
  exit 1
fi

mv package.json.hidden package.json

echo "PASS: Error handling test"

echo ""
echo "All tests passed!"
