#!/usr/bin/env python3
"""Unified feature state contract validation.

Checks that feature state infrastructure exists and all state.json files are valid.

Exits 0 on success, 1 on failure. Errors are printed to stderr.
"""

import subprocess
import sys
from pathlib import Path


def main():
    errors = []

    helper = Path("scripts/unified-state.py")
    state_test = Path("scripts/tests/test-unified-state.sh")
    doc_tracker = Path("hooks/doc-tracker.sh")
    session_start = Path("hooks/session-start.sh")

    # ── Infrastructure existence ──
    if not helper.exists():
        errors.append("missing scripts/unified-state.py")
    if not state_test.exists():
        errors.append("missing scripts/tests/test-unified-state.sh")

    # ── Hook integration ──
    if helper.exists() and doc_tracker.exists():
        if "unified-state.py" not in doc_tracker.read_text(encoding="utf-8"):
            errors.append("hooks/doc-tracker.sh must update feature state through scripts/unified-state.py")
    if helper.exists() and session_start.exists():
        if "unified-state.py" not in session_start.read_text(encoding="utf-8"):
            errors.append("hooks/session-start.sh must read feature state through scripts/unified-state.py")

    # ── Forbidden local runtime state files ──
    for forbidden_path in (".claude/runtime-state.json", ".claude/unified-state.json"):
        if Path(forbidden_path).exists():
            errors.append(f"local runtime state file must not exist: {forbidden_path}")

    # ── Validate each feature state.json ──
    if helper.exists():
        for state in sorted(Path("docs/features").glob("*/state.json")):
            result = subprocess.run(
                ["python3", str(helper), "validate", str(state)],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            if result.returncode != 0:
                errors.append(f"{state} failed validation: {result.stderr.strip() or result.stdout.strip()}")

    # ── Run state test suite ──
    if state_test.exists():
        result = subprocess.run(
            ["bash", str(state_test)],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if result.returncode != 0:
            errors.append(f"{state_test} failed: {result.stderr.strip() or result.stdout.strip()}")

    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
