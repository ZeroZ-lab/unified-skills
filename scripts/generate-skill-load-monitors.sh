#!/usr/bin/env bash
set -euo pipefail

show_help() {
  echo "Usage: generate-skill-load-monitors.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run    Print generated monitors.json without writing"
  echo "  --check      Verify monitors.json is up to date"
  echo "  --help       Show this help"
}

DRY_RUN=false
CHECK=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --check)
      CHECK=true
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

if [ "$DRY_RUN" = true ] && [ "$CHECK" = true ]; then
  echo "--dry-run and --check cannot be used together" >&2
  exit 1
fi

python3 - "$DRY_RUN" "$CHECK" <<'PY'
import json
import re
import sys
from pathlib import Path

dry_run = sys.argv[1] == "true"
check = sys.argv[2] == "true"

monitors_path = Path(".claude-plugin/monitors/monitors.json")
skills_root = Path("skills")

if not skills_root.exists():
    raise SystemExit("skills/ directory not found")
if not monitors_path.exists():
    raise SystemExit(".claude-plugin/monitors/monitors.json not found")

def extract_name(skill_file: Path) -> str:
    text = skill_file.read_text(encoding="utf-8")
    in_frontmatter = False
    for line in text.splitlines():
        stripped = line.strip()
        if stripped == "---":
            in_frontmatter = not in_frontmatter
            continue
        if in_frontmatter and stripped.startswith("name:"):
            value = stripped[len("name:"):].strip()
            if value[:1] in {"'", '"'} and value[-1:] == value[:1]:
                value = value[1:-1]
            return value
    return skill_file.parent.name

skill_names = []
for skill_file in sorted(skills_root.glob("*/SKILL.md")):
    skill_name = extract_name(skill_file)
    if not re.match(r"^(define|design|build|verify|ship|maintain|reflect)-[a-z0-9-]+$", skill_name):
        raise SystemExit(f"invalid skill name in {skill_file}: {skill_name}")
    skill_names.append(skill_name)

if not skill_names:
    raise SystemExit("no skills found")

existing = json.loads(monitors_path.read_text(encoding="utf-8"))
if not isinstance(existing, list):
    raise SystemExit("monitors.json must be a list")

base_monitors = [
    monitor for monitor in existing
    if not str(monitor.get("name", "")).startswith("skill-load-")
]

generated = []
for skill_name in skill_names:
    generated.append({
        "name": f"skill-load-{skill_name}",
        "command": f"bash \"${{CLAUDE_PLUGIN_ROOT}}/scripts/notify-skill-loaded.sh\" \"{skill_name}\"",
        "description": f"🔧 [skill] loaded {skill_name}",
        "when": f"on-skill-invoke:{skill_name}",
    })

result = base_monitors + generated
output = json.dumps(result, indent=2, ensure_ascii=False) + "\n"

if check:
    current = monitors_path.read_text(encoding="utf-8")
    if current != output:
        raise SystemExit("monitors.json is not up to date; run scripts/generate-skill-load-monitors.sh")
    print(f"monitors.json is up to date ({len(skill_names)} skill-load monitors)")
elif dry_run:
    print(output, end="")
else:
    monitors_path.write_text(output, encoding="utf-8")
    print(f"Generated {len(skill_names)} skill-load monitors in {monitors_path}", file=sys.stderr)
PY
