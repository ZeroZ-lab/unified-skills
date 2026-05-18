#!/usr/bin/env python3
"""Read, write, and validate Unified feature state files."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


SCHEMA_VERSION = 1
STATE_FILE = "state.json"
REQUIRED_KEYS = {
    "schema_version",
    "feature_path",
    "branch",
    "current_stage",
    "last_phase_doc",
    "next_command",
    "last_activity",
    "stale_reason",
}
FORBIDDEN_KEYS = {
    "dirty_status",
    "branch_match",
    "current_branch_matches_feature",
    "hostname",
    "username",
    "machine",
    "cwd",
}
PHASES = {
    "00-brainstorm.md": ("brainstorm", "/refine"),
    "01-spec.md": ("refine", "/design"),
    "02-design.md": ("design", "/plan"),
    "03-plan.md": ("plan", "/build"),
    "04-review.md": ("review", "/ship"),
    "05-ship.md": ("ship", None),
}
BUILD_COMPLETE = ("build", "/review")


class StateError(Exception):
    pass


def fail(message: str) -> None:
    raise StateError(message)


def now_iso() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")


def project_root(path: str) -> Path:
    return Path(path).resolve()


def rel_to_project(project_dir: Path, path: Path) -> str:
    try:
        return path.resolve().relative_to(project_dir).as_posix()
    except ValueError:
        fail(f"path is outside project: {path}")


def current_branch(project_dir: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "-C", str(project_dir), "branch", "--show-current"],
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        )
    except OSError:
        return ""
    return result.stdout.strip()


def load_json(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"{path}: invalid JSON: {exc}")
    if not isinstance(data, dict):
        fail(f"{path}: state must be a JSON object")
    return data


def feature_dir_from_phase_doc(project_dir: Path, phase_doc: Path) -> tuple[Path, str]:
    relative = rel_to_project(project_dir, phase_doc)
    parts = relative.split("/")
    if len(parts) != 4 or parts[0] != "docs" or parts[1] != "features":
        fail("phase doc must be under docs/features/<feature>/")
    basename = parts[3]
    if basename not in PHASES:
        fail(f"unsupported phase document: {basename}")
    return project_dir / parts[0] / parts[1] / parts[2], basename


def next_command_for_spec(phase_doc: Path) -> str:
    text = phase_doc.read_text(encoding="utf-8", errors="ignore").lower()
    design_skipped_markers = (
        "design: skipped",
        "design skipped",
        "design is skipped",
        "design required: no",
        "design status: skipped",
    )
    if any(marker in text for marker in design_skipped_markers):
        return "/plan"
    return "/design"


def state_from_phase_doc(project_dir: Path, phase_doc: Path) -> dict[str, Any]:
    feature_dir, basename = feature_dir_from_phase_doc(project_dir, phase_doc)
    if not phase_doc.exists():
        fail(f"phase document does not exist: {phase_doc}")
    stage, next_command = PHASES[basename]
    if basename == "01-spec.md":
        next_command = next_command_for_spec(phase_doc)
    feature_path = rel_to_project(project_dir, feature_dir)
    return {
        "schema_version": SCHEMA_VERSION,
        "feature_path": feature_path,
        "branch": current_branch(project_dir),
        "current_stage": stage,
        "last_phase_doc": basename,
        "next_command": next_command,
        "last_activity": now_iso(),
        "stale_reason": None,
    }


def validate_state_data(data: dict[str, Any], state_path: Path | None = None) -> None:
    extra_forbidden = sorted(FORBIDDEN_KEYS.intersection(data))
    if extra_forbidden:
        fail(f"forbidden local state keys: {', '.join(extra_forbidden)}")

    missing = sorted(REQUIRED_KEYS.difference(data))
    if missing:
        fail(f"missing required keys: {', '.join(missing)}")

    extra = sorted(set(data).difference(REQUIRED_KEYS))
    if extra:
        fail(f"unknown keys: {', '.join(extra)}")

    if data["schema_version"] != SCHEMA_VERSION:
        fail(f"unsupported schema_version: {data['schema_version']}")

    feature_path = data["feature_path"]
    if not isinstance(feature_path, str) or not feature_path.startswith("docs/features/"):
        fail("feature_path must be a docs/features/<feature> path")
    if feature_path.endswith("/") or len(feature_path.split("/")) != 3:
        fail("feature_path must be exactly docs/features/<feature>")

    last_phase_doc = data["last_phase_doc"]
    if last_phase_doc not in PHASES:
        fail(f"invalid last_phase_doc: {last_phase_doc}")

    expected_stage, expected_next = PHASES[last_phase_doc]
    allowed_pairs = {(expected_stage, expected_next)}
    if last_phase_doc == "01-spec.md":
        allowed_pairs = {("refine", "/design"), ("refine", "/plan")}
    if last_phase_doc == "03-plan.md":
        allowed_pairs.add(BUILD_COMPLETE)
    if (data["current_stage"], data["next_command"]) not in allowed_pairs:
        allowed = ", ".join(f"{stage}->{command}" for stage, command in sorted(allowed_pairs, key=str))
        fail(f"invalid stage/next_command for {last_phase_doc}; allowed: {allowed}")

    if data["stale_reason"] is not None and not isinstance(data["stale_reason"], str):
        fail("stale_reason must be null or a string")
    if not isinstance(data["branch"], str):
        fail("branch must be a string")
    if not isinstance(data["last_activity"], str) or not data["last_activity"]:
        fail("last_activity must be a non-empty string")

    if state_path:
        feature_dir = state_path.parent
        expected_feature_path = feature_dir.as_posix()
        # When validating a real file, compare against its project-relative path
        # if it appears to live below a docs/features tree.
        parts = state_path.resolve().parts
        if "docs" in parts:
            for idx, part in enumerate(parts):
                if part == "features" and idx > 0 and parts[idx - 1] == "docs":
                    expected_feature_path = Path(*parts[idx - 1 : idx + 2]).as_posix()
                    break
        if expected_feature_path.startswith("docs/features/") and feature_path != expected_feature_path:
            fail(f"feature_path must match containing directory: {expected_feature_path}")
        if state_path.name != STATE_FILE:
            fail("state file must be named state.json")
        if not (feature_dir / last_phase_doc).exists():
            fail(f"last_phase_doc does not exist: {last_phase_doc}")


def validate_state(path: Path) -> None:
    validate_state_data(load_json(path), path)


def update_from_phase_doc(project_dir: Path, phase_doc_path: Path) -> Path:
    phase_doc = phase_doc_path if phase_doc_path.is_absolute() else project_dir / phase_doc_path
    state = state_from_phase_doc(project_dir, phase_doc)
    state_path = project_dir / state["feature_path"] / STATE_FILE
    state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    validate_state(state_path)
    return state_path


def mark_build_complete(project_dir: Path, feature_path: str) -> Path:
    if not feature_path.startswith("docs/features/") or len(feature_path.split("/")) != 3:
        fail("feature_path must be exactly docs/features/<feature>")
    feature_dir = project_dir / feature_path
    plan_doc = feature_dir / "03-plan.md"
    if not plan_doc.exists():
        fail("cannot mark build complete without 03-plan.md")
    state_path = feature_dir / STATE_FILE
    state = load_json(state_path) if state_path.exists() else state_from_phase_doc(project_dir, plan_doc)
    state.update(
        {
            "schema_version": SCHEMA_VERSION,
            "feature_path": feature_path,
            "branch": current_branch(project_dir),
            "current_stage": BUILD_COMPLETE[0],
            "last_phase_doc": "03-plan.md",
            "next_command": BUILD_COMPLETE[1],
            "last_activity": now_iso(),
            "stale_reason": None,
        }
    )
    state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    validate_state(state_path)
    return state_path


def iter_state_files(project_dir: Path) -> list[Path]:
    features = project_dir / "docs" / "features"
    if not features.is_dir():
        return []
    return sorted(features.glob(f"*/{STATE_FILE}"))


def latest_state(project_dir: Path) -> tuple[Path, dict[str, Any]]:
    candidates: list[tuple[str, Path, dict[str, Any]]] = []
    for path in iter_state_files(project_dir):
        try:
            data = load_json(path)
            validate_state_data(data, path)
        except StateError:
            continue
        if data["next_command"] is None or data["stale_reason"] is not None:
            continue
        candidates.append((data["last_activity"], path, data))
    if not candidates:
        fail("no active feature state found")
    _, path, data = sorted(candidates, key=lambda item: item[0])[-1]
    return path, data


def format_resume(project_dir: Path) -> str:
    _, data = latest_state(project_dir)
    current = current_branch(project_dir)
    branch = data["branch"]
    branch_note = "branch ok"
    if branch and current and branch != current:
        branch_note = f"branch mismatch: state={branch}, current={current}"
    elif branch and not current:
        branch_note = f"state branch={branch}, current branch unknown"
    return (
        "Unified resume: "
        f"feature {data['feature_path']} | "
        f"stage {data['current_stage']} | "
        f"last {data['last_phase_doc']} | "
        f"next {data['next_command']} | "
        f"{branch_note}"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    update = subparsers.add_parser("update-from-phase-doc")
    update.add_argument("project_dir")
    update.add_argument("phase_doc")

    build_complete = subparsers.add_parser("mark-build-complete")
    build_complete.add_argument("project_dir")
    build_complete.add_argument("feature_path")

    latest = subparsers.add_parser("latest")
    latest.add_argument("project_dir")

    validate = subparsers.add_parser("validate")
    validate.add_argument("state_path")

    resume = subparsers.add_parser("format-resume")
    resume.add_argument("project_dir")

    args = parser.parse_args()
    try:
        if args.command == "update-from-phase-doc":
            path = update_from_phase_doc(project_root(args.project_dir), Path(args.phase_doc))
            print(path)
        elif args.command == "mark-build-complete":
            path = mark_build_complete(project_root(args.project_dir), args.feature_path)
            print(path)
        elif args.command == "latest":
            path, _ = latest_state(project_root(args.project_dir))
            print(path)
        elif args.command == "validate":
            validate_state(Path(args.state_path))
            print("ok")
        elif args.command == "format-resume":
            print(format_resume(project_root(args.project_dir)))
        else:
            fail(f"unknown command: {args.command}")
    except StateError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
