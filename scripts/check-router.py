#!/usr/bin/env python3
"""Context Runtime contract validation.

Checks skills-router.json consistency, budgets, session-start hook output,
guide phrases, AGENTS.md opt-in phrases, and command runtime preflight phrases.

Exits 0 on success, 1 on failure. Errors are printed to stderr.
"""

import json
import subprocess
import sys
from pathlib import Path


def main():
    errors = []

    package = json.load(open("package.json", encoding="utf-8"))
    index = json.load(open("skills-index.json", encoding="utf-8"))
    router_path = Path("skills-router.json")
    guide_path = Path("skills/maintain-workflow-using-unified/SKILL.md")
    hook_path = Path("hooks/session-start.sh")

    root_skills = {p.parent.name for p in Path("skills").glob("*/SKILL.md")}

    # ── Context Runtime scripts ──
    for script in ("scripts/generate-router.sh", "scripts/report-context-budget.sh", "scripts/tests/test-generate-router.sh"):
        path = Path(script)
        if not path.exists():
            errors.append(f"missing Context Runtime script: {script}")
        elif script.startswith("scripts/") and not script.startswith("scripts/tests/") and not path.stat().st_mode & 0o111:
            errors.append(f"Context Runtime script is not executable: {script}")

    # ── skills-router.json ──
    if not router_path.exists():
        errors.append("missing skills-router.json")
    else:
        router = json.load(open(router_path, encoding="utf-8"))
        if router.get("version") != package.get("version"):
            errors.append("skills-router.json version does not match package.json")
        if router_path.stat().st_size >= Path("skills-index.json").stat().st_size:
            errors.append("skills-router.json must be smaller than skills-index.json")

        # Budget validation
        budgets = router.get("default_budget", {})
        expected_budgets = {
            "light": {"primary_skills": 0, "specialist_skills": 0},
            "standard": {"primary_skills": 1, "specialist_skills": 1},
            "expanded": {"primary_skills": 1, "specialist_skills": 2},
        }
        for tier, expected in expected_budgets.items():
            if budgets.get(tier) != expected:
                errors.append(f"skills-router.json budget mismatch for {tier}")

        # Router skills match disk
        router_skills = set(router.get("skills", {}).keys())
        if router_skills != root_skills:
            missing = sorted(root_skills - router_skills)
            extra = sorted(router_skills - root_skills)
            errors.append(f"skills-router.json skills mismatch missing={missing} extra={extra}")

        # Metadata completeness
        for skill, meta in router.get("skills", {}).items():
            for field in ("phase", "role", "summary", "default_tier"):
                if field not in meta:
                    errors.append(f"skills-router.json {skill} missing {field}")
            if meta.get("default_tier") not in {"standard", "expanded", "full", "light"}:
                errors.append(f"skills-router.json {skill} invalid default_tier")

        # Route budget enforcement
        route_limits = {"light": 0, "standard": 2, "expanded": 3}
        for group_name, routes in router.get("routes", {}).items():
            if not isinstance(routes, dict):
                errors.append(f"skills-router.json routes.{group_name} must be object")
                continue
            for pattern, route in routes.items():
                tier = route.get("tier")
                if tier not in route_limits:
                    errors.append(f"skills-router.json route {group_name}.{pattern} invalid tier")
                    continue
                route_skills = route.get("skills")
                if not isinstance(route_skills, list):
                    errors.append(f"skills-router.json route {group_name}.{pattern} missing skills list")
                    continue
                if len(route_skills) > route_limits[tier]:
                    errors.append(f"skills-router.json route {group_name}.{pattern} exceeds {tier} budget")
                missing = sorted(set(route_skills) - root_skills)
                if missing:
                    errors.append(f"skills-router.json route {group_name}.{pattern} references missing skills: {', '.join(missing)}")
                if "full_skills" in route:
                    missing_full = sorted(set(route["full_skills"]) - root_skills)
                    if missing_full:
                        errors.append(f"skills-router.json route {group_name}.{pattern} full_skills references missing skills: {', '.join(missing_full)}")
                    if "full_when" not in route:
                        errors.append(f"skills-router.json route {group_name}.{pattern} has full_skills without full_when")

    # ── Guide phrases ──
    guide = guide_path.read_text(encoding="utf-8")
    for phrase in ("skills-router.json", "`light`", "`standard`", "`expanded`", "`full`"):
        if phrase not in guide:
            errors.append(f"{guide_path} missing Context Runtime phrase: {phrase}")
    if "1% 可能相关" in guide:
        errors.append(f"{guide_path} still contains old 1% loading rule")
    for phrase in ("显式进入 Unified 工作流", "direct mode"):
        if phrase not in guide:
            errors.append(f"{guide_path} missing opt-in Context Runtime phrase: {phrase}")

    # ── AGENTS.md opt-in phrases ──
    agents = Path("AGENTS.md").read_text(encoding="utf-8")
    for phrase in ("opt-in", "只有以下情况才激活 Unified runtime", "direct mode"):
        if phrase not in agents:
            errors.append(f"AGENTS.md missing opt-in runtime phrase: {phrase}")

    # ── Command runtime preflight phrases ──
    for command_path in sorted(Path("commands").glob("*.md")):
        command = command_path.read_text(encoding="utf-8")
        for phrase in ("## Runtime Preflight", "显式 Unified 入口", "skills-router.json", "skills-index.json", "loading tier"):
            if phrase not in command:
                errors.append(f"{command_path} missing command Runtime Preflight phrase: {phrase}")

    # ── Session-start hook output ──
    if hook_path.exists():
        output = subprocess.check_output(
            ["bash", str(hook_path)],
            input=b'{"permission_mode":"default"}',
        )
        context = json.loads(output.decode("utf-8")).get("hookSpecificOutput", {}).get("additionalContext", "")
        for phrase in ("Boot Kernel", "不自动激活 Unified runtime", "/refine", "skills-router.json"):
            if phrase not in context:
                errors.append(f"SessionStart missing opt-in runtime guidance: {phrase}")
        if "## 命令映射" in context:
            errors.append("SessionStart still injects full command map")
        if len(context.splitlines()) > 80:
            errors.append("SessionStart Boot Kernel exceeds 80 lines")
    else:
        errors.append("missing hooks/session-start.sh")

    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
