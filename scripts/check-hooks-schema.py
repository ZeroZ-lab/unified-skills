#!/usr/bin/env python3
"""Validate hooks/hooks.json schema."""

import json
import sys
from pathlib import Path


def main():
    hooks_path = Path("hooks/hooks.json")
    if not hooks_path.exists():
        print("缺少 hooks/hooks.json", file=sys.stderr)
        sys.exit(1)

    data = json.load(open("hooks/hooks.json"))
    if not isinstance(data, dict):
        print("top-level must be object", file=sys.stderr)
        sys.exit(1)
    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        print("missing hooks object", file=sys.stderr)
        sys.exit(1)
    for event in ("SessionStart", "PreToolUse", "PostToolUse", "Stop"):
        entries = hooks.get(event)
        if not isinstance(entries, list) or not entries:
            print(f"missing {event} hooks", file=sys.stderr)
            sys.exit(1)
        for entry in entries:
            if not isinstance(entry, dict):
                print(f"{event} entry must be object", file=sys.stderr)
                sys.exit(1)
            nested = entry.get("hooks")
            if not isinstance(nested, list) or not nested:
                print(f"{event} entry missing nested hooks", file=sys.stderr)
                sys.exit(1)
            for hook in nested:
                if hook.get("type") != "command" or not hook.get("command"):
                    print(f"{event} hook must be command with command string", file=sys.stderr)
                    sys.exit(1)
    # Verify PostToolUse has Agent and Write|Edit matchers
    ptu_entries = hooks.get("PostToolUse", [])
    ptu_matchers = [e.get("matcher", "") for e in ptu_entries]
    if "Agent" not in ptu_matchers:
        print("PostToolUse must have Agent matcher for agent-dispatch", file=sys.stderr)
        sys.exit(1)
    if not any(m in ("Write|Edit", "Write", "Edit") for m in ptu_matchers):
        print("PostToolUse must have Write|Edit matcher for doc-tracker", file=sys.stderr)
        sys.exit(1)
    # Verify Stop hook exists
    stop_entries = hooks.get("Stop", [])
    if not stop_entries:
        print("Stop hook required for phase-stop", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
