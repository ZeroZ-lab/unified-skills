#!/usr/bin/env python3
"""Check SHA256 hashes in skills-lock.json match actual files on disk."""

import hashlib
import json
import re
import sys
from pathlib import Path


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    lock_path = Path("skills-lock.json")
    if not lock_path.exists():
        print("缺少 skills-lock.json", file=sys.stderr)
        sys.exit(1)

    lock = json.load(open("skills-lock.json", encoding="utf-8"))
    entries = lock.get("skills", {})
    if not isinstance(entries, dict):
        print("skills-lock.json 缺少 skills 对象", file=sys.stderr)
        sys.exit(1)

    skill_dirs = []
    for skill_file in sorted(Path("skills").glob("*/SKILL.md")):
        skill_dir = skill_file.parent.name
        if re.match(r"^(define|design|build|verify|ship|maintain|reflect)-", skill_dir):
            skill_dirs.append(skill_dir)

    checked_skills = 0
    checked_auxiliary = 0

    for skill_dir in skill_dirs:
        skill_path = Path("skills") / skill_dir / "SKILL.md"
        skill_text = skill_path.read_text(encoding="utf-8")
        entry = entries.get(skill_dir)
        if not isinstance(entry, dict):
            print(f"skills-lock.json 缺少技能: {skill_dir}", file=sys.stderr)
            sys.exit(1)

        expected = entry.get("computedHash")
        if not expected:
            print(f"skills-lock.json 缺少 computedHash: {skill_dir}", file=sys.stderr)
            sys.exit(1)
        actual = sha256(skill_path)
        if actual != expected:
            print(f"skills-lock.json 哈希不匹配: {skill_dir}", file=sys.stderr)
            sys.exit(1)
        checked_skills += 1

        skill_root = Path("skills") / skill_dir
        actual_auxiliary = sorted(
            p.name for p in skill_root.glob("*.md") if p.name != "SKILL.md"
        )
        declared_auxiliary = entry.get("auxiliaryHashes", {})
        if declared_auxiliary is None:
            declared_auxiliary = {}
        if not isinstance(declared_auxiliary, dict):
            print(f"skills-lock.json auxiliaryHashes 必须是对象: {skill_dir}", file=sys.stderr)
            sys.exit(1)

        missing = sorted(set(actual_auxiliary) - set(declared_auxiliary))
        extra = sorted(set(declared_auxiliary) - set(actual_auxiliary))
        if missing:
            print(f"skills-lock.json 缺少辅助文件哈希: {skill_dir}: {', '.join(missing)}", file=sys.stderr)
            sys.exit(1)
        if extra:
            print(f"skills-lock.json 声明了不存在的辅助文件: {skill_dir}: {', '.join(extra)}", file=sys.stderr)
            sys.exit(1)

        for name in actual_auxiliary:
            if "/" in name or name == "SKILL.md":
                print(f"skills-lock.json 辅助文件名无效: {skill_dir}: {name}", file=sys.stderr)
                sys.exit(1)
            if name not in skill_text:
                print(f"辅助文件未被主 SKILL.md 引用: {skill_dir}/{name}", file=sys.stderr)
                sys.exit(1)
            expected_aux = declared_auxiliary.get(name)
            actual_aux = sha256(skill_root / name)
            if actual_aux != expected_aux:
                print(f"skills-lock.json 辅助文件哈希不匹配: {skill_dir}/{name}", file=sys.stderr)
                sys.exit(1)
            checked_auxiliary += 1

    if checked_skills == 0:
        print("skills-lock.json 中没有有效的技能哈希", file=sys.stderr)
        sys.exit(1)

    print(f"{checked_skills} {checked_auxiliary}")


if __name__ == "__main__":
    main()
