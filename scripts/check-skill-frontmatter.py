#!/usr/bin/env python3
"""Validate SKILL.md YAML frontmatter delimiters for Codex skill loading."""

from __future__ import annotations

import sys
from pathlib import Path


def validate_skill(skill_path: Path) -> list[str]:
    errors: list[str] = []
    rel = skill_path.as_posix()
    lines = skill_path.read_text(encoding="utf-8").splitlines()

    if not lines:
        return [f"{rel}: empty file"]
    if lines[0] != "---":
        return [f"{rel}: first line must be exact YAML frontmatter delimiter ---"]

    try:
        closing_index = lines[1:].index("---") + 1
    except ValueError:
        return [f"{rel}: missing closing YAML frontmatter delimiter ---"]

    frontmatter = lines[1:closing_index]
    fields: dict[str, str] = {}
    for line in frontmatter:
        if not line.strip():
            continue
        if line.startswith((" ", "\t", "-")):
            continue
        if ":" not in line:
            errors.append(f"{rel}: invalid frontmatter line: {line}")
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        if not key:
            errors.append(f"{rel}: empty frontmatter key")
            continue
        fields[key] = value.strip()

    for required in ("name", "description"):
        if not fields.get(required):
            errors.append(f"{rel}: missing required frontmatter field: {required}")

    return errors


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    skills_root = root / "skills"
    if not skills_root.exists():
        print(f"{skills_root}: missing skills directory", file=sys.stderr)
        return 1

    errors: list[str] = []
    skill_files = sorted(skills_root.glob("*/SKILL.md"))
    if not skill_files:
        errors.append(f"{skills_root}: no SKILL.md files found")

    for skill_path in skill_files:
        errors.extend(validate_skill(skill_path))

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print(f"SKILL.md frontmatter valid: {len(skill_files)} files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
