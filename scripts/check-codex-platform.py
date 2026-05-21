#!/usr/bin/env python3
"""Codex platform validation.

Combines three checks:
1. Codex plugin manifest (.codex-plugin/plugin.json)
2. Codex hooks.json (.codex/hooks.json)
3. Codex config.toml (.codex/config.toml)

Exits 0 on success, 1 on failure. Errors are printed to stderr.
"""

import json
import re
import sys
from pathlib import Path


def check_manifest():
    """Validate .codex-plugin/plugin.json."""
    errors = []
    manifest_path = Path(".codex-plugin/plugin.json")

    if not manifest_path.exists():
        return ["missing .codex-plugin/plugin.json"]

    try:
        data = json.load(open(manifest_path, encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as exc:
        return [f"cannot parse .codex-plugin/plugin.json: {exc}"]

    version = data.get("version")
    if not version:
        return ["cannot parse .codex-plugin/plugin.json version"]

    # Check version matches package.json
    try:
        package = json.load(open("package.json", encoding="utf-8"))
        pkg_ver = package.get("version")
        if pkg_ver and version != pkg_ver:
            errors.append(f"version mismatch: package.json={pkg_ver}, .codex-plugin/plugin.json={version}")
    except (json.JSONDecodeError, OSError):
        errors.append("cannot read package.json for version comparison")

    # Check required fields
    content = manifest_path.read_text(encoding="utf-8")
    for required in ("skills", "interface"):
        if required not in content:
            errors.append(f".codex-plugin/plugin.json missing {required} field")

    if '"skills": "./skills/"' not in content:
        errors.append('.codex-plugin/plugin.json must point skills to ./skills/')

    return errors


def check_hooks_json():
    """Validate .codex/hooks.json schema."""
    errors = []
    hooks_path = Path(".codex/hooks.json")

    if not hooks_path.exists():
        return ["missing .codex/hooks.json"]

    try:
        data = json.load(open(hooks_path, encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as exc:
        return [f"cannot parse .codex/hooks.json: {exc}"]

    if not isinstance(data, dict):
        return [".codex/hooks.json top-level must be object"]

    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        return [".codex/hooks.json missing hooks object"]

    for event in ("SessionStart", "PreToolUse"):
        entries = hooks.get(event)
        if not isinstance(entries, list) or not entries:
            errors.append(f".codex/hooks.json missing {event} hooks")
            continue
        for entry in entries:
            if not isinstance(entry, dict):
                errors.append(f".codex/hooks.json {event} entry must be object")
                continue
            nested = entry.get("hooks")
            if not isinstance(nested, list) or not nested:
                errors.append(f".codex/hooks.json {event} entry missing nested hooks")
                continue
            for hook in nested:
                command = hook.get("command", "")
                if hook.get("type") != "command" or not command:
                    errors.append(f".codex/hooks.json {event} hook must be command with command string")
                if not hook.get("statusMessage"):
                    errors.append(f".codex/hooks.json {event} hook missing statusMessage")
                if "hooks/codex-wrapper.sh" in command:
                    errors.append(
                        f".codex/hooks.json {event} hook must not depend on repo-relative hooks/codex-wrapper.sh"
                    )
                if "os.execvp" not in command or ".codex/plugins/cache/unified-skills/unified" not in command:
                    errors.append(
                        f".codex/hooks.json {event} hook must use the portable Codex plugin-root bootstrap"
                    )
                if event == "PreToolUse" and '"permissionDecision":"deny"' not in command:
                    errors.append(
                        ".codex/hooks.json PreToolUse hook must fail closed when plugin root is unresolved"
                    )

    return errors


def check_config_toml():
    """Validate .codex/config.toml has hooks = true and no deprecated codex_hooks."""
    errors = []
    config_path = Path(".codex/config.toml")

    if not config_path.exists():
        return ["missing .codex/config.toml"]

    section = None
    hooks_true = False
    deprecated_lines = []

    for lineno, raw in enumerate(open(config_path, encoding="utf-8"), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        if line.startswith("[") and line.endswith("]"):
            section = line.strip("[]").strip()
            continue
        if section != "features" or "=" not in line:
            continue
        key, value = [part.strip() for part in line.split("=", 1)]
        if key == "codex_hooks":
            deprecated_lines.append(lineno)
        if key == "hooks" and value.lower() == "true":
            hooks_true = True

    if deprecated_lines:
        lines = ", ".join(str(line) for line in deprecated_lines)
        errors.append(f"deprecated codex_hooks flag at line(s): {lines}")
    if not hooks_true:
        errors.append("missing [features] hooks = true")

    return errors


def main():
    errors = []
    errors.extend(check_manifest())
    errors.extend(check_hooks_json())
    errors.extend(check_config_toml())

    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
