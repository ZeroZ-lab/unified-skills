#!/usr/bin/env python3
"""Check skills-index.json matches actual skills on disk."""

import json
import sys
from pathlib import Path


def main():
    index_path = Path("skills-index.json")
    if not index_path.exists():
        print("缺少 skills-index.json", file=sys.stderr)
        sys.exit(1)

    index = json.load(open("skills-index.json"))
    root_skills = sorted(p.parent.name for p in Path("skills").glob("*/SKILL.md"))
    root_set = set(root_skills)

    phase_refs = set()
    for entry in index.get("by_phase", {}).values():
        phase_refs.update(entry.get("skills", []))

    desc_refs = set(index.get("skill_descriptions", {}).keys())

    all_refs = set()
    for entry in index.get("by_phase", {}).values():
        all_refs.update(entry.get("skills", []))
    for entry in index.get("by_artifact_type", {}).values():
        for value in entry.values():
            if isinstance(value, list):
                all_refs.update(value)
    for group in index.get("by_trigger", {}).values():
        for value in group.values():
            if isinstance(value, list):
                all_refs.update(value)
    for value in index.get("by_risk", {}).values():
        if isinstance(value, list):
            all_refs.update(value)

    errors = []
    if root_set != desc_refs:
        missing = sorted(root_set - desc_refs)
        extra = sorted(desc_refs - root_set)
        if missing:
            errors.append("skill_descriptions 缺少: " + ", ".join(missing))
        if extra:
            errors.append("skill_descriptions 多余: " + ", ".join(extra))
    if root_set != phase_refs:
        missing = sorted(root_set - phase_refs)
        extra = sorted(phase_refs - root_set)
        if missing:
            errors.append("by_phase 缺少: " + ", ".join(missing))
        if extra:
            errors.append("by_phase 多余: " + ", ".join(extra))
    missing_ref_desc = sorted(all_refs - desc_refs)
    if missing_ref_desc:
        errors.append("skill_descriptions 未覆盖引用技能: " + ", ".join(missing_ref_desc))
    missing_ref_root = sorted(all_refs - root_set)
    if missing_ref_root:
        errors.append("索引引用了不存在的技能: " + ", ".join(missing_ref_root))
    legacy_names = sorted(name for name in all_refs | desc_refs if name == "verify-quality-code-review-standards")
    if legacy_names:
        errors.append("仍存在旧技能命名: " + ", ".join(legacy_names))

    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
