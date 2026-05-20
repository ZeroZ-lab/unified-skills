#!/usr/bin/env python3
"""Claude Code skill-load monitors validation.

Validates .claude-plugin/monitors/monitors.json structure, skill-load monitor
coverage, business monitor presence, and the notify script.

Exits 0 on success, 1 on failure. Errors are printed to stderr.
"""

import json
import sys
from pathlib import Path


def main():
    monitors_path = Path(".claude-plugin/monitors/monitors.json")

    if not monitors_path.exists():
        print("missing .claude-plugin/monitors/monitors.json", file=sys.stderr)
        sys.exit(1)

    monitors = json.loads(monitors_path.read_text(encoding="utf-8"))
    if not isinstance(monitors, list):
        print("monitors.json must be a list", file=sys.stderr)
        sys.exit(1)

    skills = sorted(p.parent.name for p in Path("skills").glob("*/SKILL.md"))
    skill_set = set(skills)
    names = []
    skill_monitors = {}
    errors = []

    for monitor in monitors:
        if not isinstance(monitor, dict):
            errors.append("monitor entry must be object")
            continue
        name = monitor.get("name")
        when = monitor.get("when")
        command = monitor.get("command")
        description = monitor.get("description")
        if not isinstance(name, str) or not name:
            errors.append("monitor missing name")
            continue
        names.append(name)
        if name.startswith("skill-load-"):
            skill = name[len("skill-load-"):]
            skill_monitors[skill] = monitor
            expected = {
                "command": f'bash "${{CLAUDE_PLUGIN_ROOT}}/scripts/notify-skill-loaded.sh" "{skill}"',
                "description": f"🔧 [skill] loaded {skill}",
                "when": f"on-skill-invoke:{skill}",
            }
            for key, value in expected.items():
                if monitor.get(key) != value:
                    errors.append(f"{name} has invalid {key}: {monitor.get(key)!r}")
            if skill not in skill_set:
                errors.append(f"{name} references missing skill: {skill}")

    if len(names) != len(set(names)):
        errors.append("monitor names must be unique")

    missing = sorted(skill_set - set(skill_monitors))
    extra = sorted(set(skill_monitors) - skill_set)
    if missing:
        errors.append("missing skill-load monitor(s): " + ", ".join(missing))
    if extra:
        errors.append("extra skill-load monitor(s): " + ", ".join(extra))

    business_monitors = {m.get("name") for m in monitors if isinstance(m, dict)}
    for required in ("deploy-status", "error-watcher"):
        if required not in business_monitors:
            errors.append(f"missing existing business monitor: {required}")

    notify = Path("scripts/notify-skill-loaded.sh")
    if not notify.exists():
        errors.append("missing scripts/notify-skill-loaded.sh")
    elif "🔧 [skill] loaded" not in notify.read_text(encoding="utf-8"):
        errors.append("notify script must emit emoji skill-load message")

    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
