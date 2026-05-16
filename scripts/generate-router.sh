#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false

show_help() {
  echo "Usage: generate-router.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run    Print generated router without writing skills-router.json"
  echo "  --help       Show this help"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

if [ ! -f "skills-index.json" ]; then
  echo "Error: skills-index.json not found" >&2
  exit 1
fi

output=$(
python3 <<'PY'
import json
import re
from pathlib import Path

package = json.load(open("package.json", encoding="utf-8"))
index = json.load(open("skills-index.json", encoding="utf-8"))

root_skills = sorted(p.parent.name for p in Path("skills").glob("*/SKILL.md"))
root_set = set(root_skills)

phase_by_skill = {}
for phase, entry in index.get("by_phase", {}).items():
    for skill in entry.get("skills", []):
        phase_by_skill[skill] = phase

trigger_by_skill = {skill: [] for skill in root_skills}
for group in index.get("by_trigger", {}).values():
    for pattern, skills in group.items():
        for skill in skills:
            if skill in trigger_by_skill:
                trigger_by_skill[skill].append(pattern)

risk_by_skill = {skill: [] for skill in root_skills}
for risk, skills in index.get("by_risk", {}).items():
    for skill in skills:
        if skill in risk_by_skill:
            risk_by_skill[skill].append(risk)

def role_for(skill: str) -> str:
    parts = skill.split("-")
    if len(parts) >= 2:
        return parts[1]
    return "workflow"

def default_tier(skill: str) -> str:
    risks = set(risk_by_skill.get(skill, []))
    if risks & {"authentication", "authorization", "production_deployment", "public_api", "breaking_change"}:
        return "expanded"
    return "standard"

skills = {}
descriptions = index.get("skill_descriptions", {})
for skill in root_skills:
    if skill not in phase_by_skill:
        raise SystemExit(f"missing phase for skill: {skill}")
    skills[skill] = {
        "phase": phase_by_skill[skill],
        "role": role_for(skill),
        "summary": descriptions.get(skill, "").split("。", 1)[0][:60],
        "default_tier": default_tier(skill),
    }

def compact_route(route_skills, tier):
    budget = {
        "light": 0,
        "standard": 2,
        "expanded": 3,
    }[tier]
    compact = [skill for skill in route_skills if skill in root_set][:budget]
    route = {
        "tier": tier,
        "skills": compact,
    }
    full = [skill for skill in route_skills if skill in root_set]
    if len(full) > len(compact):
        route["full_skills"] = full
        route["full_when"] = ["--full", "adversarial_review", "full_body_check", "high_risk_release"]
    return route

routes = {"user_says": {}, "context_signals": {}, "risk": {}}
for group_name, group in index.get("by_trigger", {}).items():
    for pattern, route_skills in group.items():
        tier = "expanded" if len(route_skills) > 2 else "standard"
        routes[group_name][pattern] = compact_route(route_skills, tier)

for risk, route_skills in index.get("by_risk", {}).items():
    tier = "expanded" if len(route_skills) > 1 else "standard"
    routes["risk"][risk] = compact_route(route_skills, tier)

router = {
    "version": package["version"],
    "default_budget": {
        "light": {"primary_skills": 0, "specialist_skills": 0},
        "standard": {"primary_skills": 1, "specialist_skills": 1},
        "expanded": {"primary_skills": 1, "specialist_skills": 2},
    },
    "routes": routes,
    "skills": skills,
}

# Compact JSON keeps the first-pass routing surface small while remaining deterministic.
print(json.dumps(router, ensure_ascii=False, sort_keys=True, separators=(",", ":")))
PY
)

if [ "$DRY_RUN" = true ]; then
  printf '%s\n' "$output"
else
  printf '%s\n' "$output" > skills-router.json
  printf 'Generated skills-router.json\n' >&2
fi
