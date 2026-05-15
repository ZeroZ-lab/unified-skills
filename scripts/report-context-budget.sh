#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
import json
import subprocess
from pathlib import Path


def line_count(path: Path) -> int:
    return len(path.read_text(encoding="utf-8").splitlines())


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


root = Path(".")
index_path = root / "skills-index.json"
router_path = root / "skills-router.json"

print("Context Budget Report")
print("=====================")
print()

print("Startup Surface")
print("---------------")
hook_path = root / "hooks" / "session-start.sh"
if hook_path.exists():
    print(f"hooks/session-start.sh: {line_count(hook_path)} lines")
    try:
        output = subprocess.check_output(
            ["bash", "hooks/session-start.sh"],
            input=b'{"permission_mode":"default"}',
            stderr=subprocess.DEVNULL,
        )
        data = json.loads(output.decode("utf-8"))
        context = data.get("hookSpecificOutput", {}).get("additionalContext", "")
        print(f"SessionStart additionalContext: {len(context.splitlines())} lines, {len(context)} chars")
    except Exception as exc:
        print(f"SessionStart additionalContext: unavailable ({exc.__class__.__name__})")
else:
    print("hooks/session-start.sh: missing")
print()

print("Routing Surface")
print("---------------")
if index_path.exists():
    print(f"skills-index.json: {line_count(index_path)} lines, {index_path.stat().st_size} bytes")
else:
    print("skills-index.json: missing")
if router_path.exists():
    print(f"skills-router.json: {line_count(router_path)} lines, {router_path.stat().st_size} bytes")
else:
    print("skills-router.json: missing")
print()

print("Skill Lengths")
print("-------------")
skill_rows = []
aux_count = 0
for skill_file in sorted((root / "skills").glob("*/SKILL.md")):
    aux_files = sorted(p for p in skill_file.parent.glob("*.md") if p.name != "SKILL.md")
    aux_count += len(aux_files)
    skill_rows.append((line_count(skill_file), skill_file.parent.name, len(aux_files)))
for lines, name, aux in sorted(skill_rows, reverse=True)[:12]:
    print(f"{lines:4} lines  {name}  auxiliary={aux}")
print(f"Total skills: {len(skill_rows)}")
print(f"Total one-level auxiliary files: {aux_count}")
print()

print("Sample Route Load Counts")
print("------------------------")
if index_path.exists():
    index = read_json(index_path)
    samples = [
        ("simple_command_lookup", []),
        ("normal_plan", ["build-workflow-plan"]),
        ("ui_task", index.get("by_trigger", {}).get("user_says", {}).get("ui|前端|component|组件|页面", [])),
        ("adversarial_review", ["verify-workflow-review", "verify-workflow-spec-compliance", "verify-quality-code-quality"]),
        ("high_risk_ship", index.get("by_risk", {}).get("production_deployment", [])),
    ]
    for name, skills in samples:
        print(f"{name}: {len(skills)} skill(s) -> {', '.join(skills) if skills else 'router-only'}")
else:
    print("unavailable: skills-index.json missing")
PY
