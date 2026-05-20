#!/usr/bin/env bash
set -e

echo "Testing router generation..."

BACKUP_DIR=$(mktemp -d)

if [ -f skills-router.json ]; then
  cp skills-router.json "$BACKUP_DIR/skills-router.json"
  had_router=1
else
  had_router=0
fi

cleanup() {
  if [ "$had_router" -eq 1 ]; then
    cp "$BACKUP_DIR/skills-router.json" skills-router.json
  else
    rm -f skills-router.json
  fi
  rm -rf "$BACKUP_DIR"
}
trap cleanup EXIT

echo "Test 1: Normal generation"
bash scripts/generate-router.sh

python3 - <<'PY'
import json
from pathlib import Path

router = json.load(open("skills-router.json", encoding="utf-8"))
package = json.load(open("package.json", encoding="utf-8"))
index = json.load(open("skills-index.json", encoding="utf-8"))

required = ["version", "default_budget", "routes", "skills"]
for key in required:
    if key not in router:
        raise SystemExit(f"FAIL: missing required key: {key}")

if router["version"] != package["version"]:
    raise SystemExit("FAIL: router version does not match package.json")

for tier in ("light", "standard", "expanded"):
    if tier not in router["default_budget"]:
        raise SystemExit(f"FAIL: missing budget tier: {tier}")

root_skills = {
    p.parent.name for p in Path("skills").glob("*/SKILL.md")
}
router_skills = set(router["skills"])
if router_skills != root_skills:
    missing = sorted(root_skills - router_skills)
    extra = sorted(router_skills - root_skills)
    raise SystemExit(f"FAIL: router skills mismatch missing={missing} extra={extra}")

desc_skills = set(index.get("skill_descriptions", {}))
if router_skills != desc_skills:
    raise SystemExit("FAIL: router skills do not match skills-index descriptions")

if Path("skills-router.json").stat().st_size >= Path("skills-index.json").stat().st_size:
    raise SystemExit("FAIL: skills-router.json should be smaller than skills-index.json")

for skill, meta in router["skills"].items():
    for field in ("phase", "role", "summary", "default_tier"):
        if field not in meta:
            raise SystemExit(f"FAIL: {skill} missing field {field}")
    if meta["default_tier"] not in ("light", "standard", "expanded", "full"):
        raise SystemExit(f"FAIL: invalid default_tier for {skill}: {meta['default_tier']}")

limits = {"light": 0, "standard": 2, "expanded": 3}
for group_name, routes in router["routes"].items():
    if not isinstance(routes, dict):
        raise SystemExit(f"FAIL: routes.{group_name} should be an object")
    for pattern, route in routes.items():
        tier = route.get("tier")
        if tier not in limits:
            raise SystemExit(f"FAIL: route {group_name}.{pattern} has invalid tier {tier}")
        route_skills = route.get("skills")
        if not isinstance(route_skills, list):
            raise SystemExit(f"FAIL: route {group_name}.{pattern} missing skills list")
        if len(route_skills) > limits[tier]:
            raise SystemExit(f"FAIL: route {group_name}.{pattern} exceeds {tier} budget")
        missing = sorted(set(route_skills) - root_skills)
        if missing:
            raise SystemExit(f"FAIL: route {group_name}.{pattern} references missing skills {missing}")
        if "full_skills" in route:
            missing_full = sorted(set(route["full_skills"]) - root_skills)
            if missing_full:
                raise SystemExit(f"FAIL: route {group_name}.{pattern} full_skills references missing skills {missing_full}")

print(f"PASS: {len(router_skills)} router skills valid")
PY

echo "Test 2: Dry-run mode"
dry_run_snapshot="$BACKUP_DIR/skills-router.dry-run.json"
cp skills-router.json "$dry_run_snapshot"
bash scripts/generate-router.sh --dry-run > /dev/null
if ! diff -q skills-router.json "$dry_run_snapshot" > /dev/null; then
  echo "FAIL: dry-run modified skills-router.json"
  exit 1
fi
echo "PASS: dry-run test"

echo ""
echo "All router tests passed!"
