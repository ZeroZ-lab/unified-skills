#!/usr/bin/env python3
"""Check plugin metadata descriptions match version and dynamic count rules."""

import json
import re
import sys
from pathlib import Path


def main():
    if len(sys.argv) < 2:
        print("Usage: check-version.py <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]

    metadata_fields = [
        (".claude-plugin/plugin.json", ("description",), True),
        (".codex-plugin/plugin.json", ("description",), True),
        (".codex-plugin/plugin.json", ("interface", "shortDescription"), False),
        (".claude-plugin/marketplace.json", ("description",), True),
        (".claude-plugin/marketplace.json", ("plugins", 0, "description"), True),
        ("package.json", ("description",), False),
    ]

    dynamic_count_re = re.compile(r"(^|[^0-9.])\d+\s*(?:个)?(?:技能|命令|角色|SKILL)")
    errors = []
    package_description = None
    description_bodies = []

    def get_field(data, path):
        current = data
        for key in path:
            current = current[key]
        return current

    for file, path, require_version_prefix in metadata_fields:
        p = Path(file)
        if not p.exists():
            errors.append(f"missing metadata file: {file}")
            continue
        data = json.loads(p.read_text(encoding="utf-8"))
        try:
            value = get_field(data, path)
        except Exception as exc:
            errors.append(f"{file} missing field {'.'.join(map(str, path))}: {exc}")
            continue
        if not isinstance(value, str):
            errors.append(f"{file} field {'.'.join(map(str, path))} is not a string")
            continue
        if dynamic_count_re.search(value):
            errors.append(f"{file} field {'.'.join(map(str, path))} contains dynamic inventory count")
        if "v2.14.0" in value:
            errors.append(f"{file} field {'.'.join(map(str, path))} contains stale metadata")
        if require_version_prefix and not value.startswith(f"v{version}"):
            errors.append(f"{file} field {'.'.join(map(str, path))} must start with v{version}")
        if path[-1] == "description":
            body = value
            prefix = f"v{version} — "
            if require_version_prefix and body.startswith(prefix):
                body = body[len(prefix):]
            if file == "package.json":
                package_description = body
            else:
                description_bodies.append((file, path, body))

    if package_description:
        for file, path, body in description_bodies:
            if body != package_description:
                errors.append(f"{file} field {'.'.join(map(str, path))} does not match package.json description body")

    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
