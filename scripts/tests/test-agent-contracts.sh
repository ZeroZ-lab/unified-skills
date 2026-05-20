#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECKER="$ROOT/scripts/check-agent-contracts.py"
TMPROOT="${TMPDIR:-/tmp}/unified-agent-contracts-test.$$"

trap 'rm -rf "$TMPROOT"' EXIT

make_fixture() {
  local name="$1"
  local fixture="$TMPROOT/$name"
  mkdir -p "$fixture"
  cp -R "$ROOT/agents" "$ROOT/skills" "$fixture"/
  printf '%s\n' "$fixture"
}

expect_failure() {
  local fixture="$1"
  local expected="$2"
  local output="$fixture/check.out"

  if python3 "$CHECKER" --root "$fixture" >"$output" 2>&1; then
    printf 'expected failure but checker passed: %s\n' "$expected" >&2
    return 1
  fi

  if ! grep -Fq "$expected" "$output"; then
    printf 'missing expected failure: %s\n' "$expected" >&2
    printf 'actual output:\n' >&2
    cat "$output" >&2
    return 1
  fi
}

fixture="$(make_fixture positive)"
python3 "$CHECKER" --root "$fixture"
printf 'PASS positive agent contract fixture\n'

fixture="$(make_fixture readme-extra-agent)"
python3 - "$fixture/agents/README.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
path.write_text(
    path.read_text(encoding="utf-8")
    + "\n| missing-agent | fixture-only contract drift | /review |\n",
    encoding="utf-8",
)
PY
expect_failure "$fixture" "agents/README.md lists missing agent files: missing-agent"
printf 'PASS README extra-agent negative fixture\n'

fixture="$(make_fixture readme-missing-agent)"
python3 - "$fixture" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
(root / "agents/hidden-agent.md").write_text(
    """---
name: hidden-agent
description: fixture-only hidden persona
---

# Hidden Agent

## 职责

Fixture-only role.

## 输出格式

Fixture-only output.
""",
    encoding="utf-8",
)
skill_path = root / "skills/define-cognitive-brainstorm/SKILL.md"
skill_path.write_text(
    skill_path.read_text(encoding="utf-8")
    + "\n\nFixture reference: agents/hidden-agent.md\n",
    encoding="utf-8",
)
PY
expect_failure "$fixture" "agent files missing from agents/README.md: hidden-agent"
printf 'PASS README missing-agent negative fixture\n'

fixture="$(make_fixture write-tool-auditor)"
python3 - "$fixture/agents/review-security-auditor.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
path.write_text(text.replace("tools:\n", "tools:\n  - Write\n", 1), encoding="utf-8")
PY
expect_failure "$fixture" "agents/review-security-auditor.md declares write-capable tools: Write"
printf 'PASS write-tool auditor negative fixture\n'

fixture="$(make_fixture noisy-tool-auditor)"
python3 - "$fixture/agents/review-security-auditor.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
path.write_text(text.replace("tools:\n", "tools:\n  - Agent\n", 1), encoding="utf-8")
PY
expect_failure "$fixture" "agents/review-security-auditor.md declares broad/noisy tools by default: Agent"
printf 'PASS noisy-tool auditor negative fixture\n'

fixture="$(make_fixture missing-maxturns-auditor)"
python3 - "$fixture/agents/review-security-auditor.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
lines = [
    line for line in path.read_text(encoding="utf-8").splitlines()
    if not line.startswith("maxTurns:")
]
path.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY
expect_failure "$fixture" "agents/review-security-auditor.md missing maxTurns limit"
printf 'PASS missing-maxTurns auditor negative fixture\n'
