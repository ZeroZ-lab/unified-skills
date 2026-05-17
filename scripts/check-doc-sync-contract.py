#!/usr/bin/env python3
import argparse
import re
import sys
from pathlib import Path
from typing import Optional


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=None, help="Repository root to validate")
    return parser.parse_args()


ARGS = parse_args()
ROOT = Path(ARGS.root).resolve() if ARGS.root else Path(__file__).resolve().parents[1]
FEATURES_DIR = ROOT / "docs" / "features"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def has_section(text: str, title: str) -> bool:
    return f"## {title}" in text


def normalize_field_line(line: str) -> str:
    stripped = line.strip()
    if stripped.startswith("- "):
        stripped = stripped[2:].strip()
    if stripped.startswith("* "):
        stripped = stripped[2:].strip()
    if stripped.startswith("`") and stripped.endswith("`"):
        stripped = stripped[1:-1].strip()
    return stripped


def line_value(text: str, key: str):
    for line in text.splitlines():
        normalized = normalize_field_line(line)
        prefix = f"{key}:"
        if normalized.startswith(prefix):
            return normalized[len(prefix):].strip()
    return None


def list_after_key(text: str, key: str):
    lines = text.splitlines()
    found = False
    values = []
    for line in lines:
        normalized = normalize_field_line(line)
        if not found:
            if normalized == f"{key}:":
                found = True
                continue
            prefix = f"{key}:"
            if normalized.startswith(prefix):
                value = normalized[len(prefix):].strip()
                if value and value.lower() not in {"none", "无"}:
                    values.append(value)
                return values
        else:
            stripped = line.strip()
            if not stripped:
                continue
            if stripped.startswith("- "):
                item = stripped[2:].strip()
                if item.lower() not in {"none", "无"}:
                    values.append(item)
                continue
            if re.match(r"^##\s+", stripped):
                break
            if stripped.startswith("`") and stripped.endswith("`"):
                values.append(stripped.strip("`"))
                continue
            if not line.startswith(" ") and not line.startswith("\t"):
                break
    return values


def is_yes(value: Optional[str]) -> bool:
    if value is None:
        return False
    return value.strip().lower() in {"yes", "true", "y"}


errors = []

if FEATURES_DIR.exists():
    for spec_path in sorted(FEATURES_DIR.glob("*/01-spec.md")):
        feature_dir = spec_path.parent
        spec_text = read(spec_path)
        if "## Documentation Impact" not in spec_text:
            continue

        project_truth_changed = line_value(spec_text, "project_truth_changed")
        doc_intent = line_value(spec_text, "doc_intent")
        affected = list_after_key(spec_text, "affected_project_docs")

        if doc_intent is None:
            errors.append(f"{spec_path}: missing doc_intent")

        if is_yes(project_truth_changed):
            if not affected:
                errors.append(f"{spec_path}: project_truth_changed=yes but affected_project_docs is empty")
            if doc_intent not in {"feature_plus_project", "project_only"}:
                errors.append(f"{spec_path}: project_truth_changed=yes requires doc_intent feature_plus_project or project_only")

            plan_path = feature_dir / "03-plan.md"
            if plan_path.exists():
                plan_text = read(plan_path)
                if not has_section(plan_text, "Project Doc Sync Plan"):
                    errors.append(f"{plan_path}: missing ## Project Doc Sync Plan")
                for marker in ("Must update", "Stage owner", "Verification method"):
                    if marker not in plan_text:
                        errors.append(f"{plan_path}: Project Doc Sync Plan missing {marker}")

            review_path = feature_dir / "04-review.md"
            if review_path.exists():
                review_text = read(review_path)
                if not has_section(review_text, "Documentation Compliance"):
                    errors.append(f"{review_path}: missing ## Documentation Compliance")
                required_status = line_value(review_text, "Required project docs updated")
                if required_status != "PASS":
                    errors.append(f"{review_path}: Required project docs updated must be PASS when project_truth_changed=yes")

            ship_path = feature_dir / "05-ship.md"
            if ship_path.exists():
                ship_text = read(ship_path)
                if not has_section(ship_text, "Documentation Sync"):
                    errors.append(f"{ship_path}: missing ## Documentation Sync")

        review_path = feature_dir / "04-review.md"
        if review_path.exists():
            review_text = read(review_path)
            review_required = line_value(review_text, "Required project docs updated")
            if review_required == "FAIL":
                errors.append(f"{review_path}: Required project docs updated is FAIL")

if errors:
    print("\n".join(errors))
    sys.exit(1)
