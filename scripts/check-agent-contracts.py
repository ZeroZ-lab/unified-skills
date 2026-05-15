#!/usr/bin/env python3
"""Validate Unified agent inventory and dispatch contracts."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


DISALLOWED_WRITE_TOOLS = {"Bash", "Edit", "MultiEdit", "NotebookEdit", "Write"}

REQUIRED_SKILL_CONSUMERS = {
    "agents/requirements-analyst.md": [
        "skills/define-workflow-refine/SKILL.md",
        "skills/design-workflow-design/SKILL.md",
    ],
    "agents/task-planner.md": [
        "skills/build-workflow-plan/SKILL.md",
        "skills/build-workflow-execute/SKILL.md",
        "skills/build-cognitive-execution-engine/SKILL.md",
    ],
    "agents/software-engineer.md": [
        "skills/build-workflow-execute/SKILL.md",
        "skills/build-cognitive-execution-engine/SKILL.md",
    ],
    "agents/api-designer.md": [
        "skills/build-workflow-execute/SKILL.md",
        "skills/build-cognitive-execution-engine/SKILL.md",
    ],
    "agents/data-architect.md": [
        "skills/build-workflow-execute/SKILL.md",
        "skills/build-cognitive-execution-engine/SKILL.md",
    ],
    "agents/content-writer.md": [
        "skills/design-workflow-design/SKILL.md",
        "skills/build-workflow-execute/SKILL.md",
        "skills/build-cognitive-execution-engine/SKILL.md",
    ],
    "agents/visual-designer.md": [
        "skills/design-workflow-design/SKILL.md",
        "skills/build-workflow-execute/SKILL.md",
        "skills/build-cognitive-execution-engine/SKILL.md",
    ],
    "agents/design-reviewer.md": ["skills/design-workflow-design/SKILL.md"],
    "agents/review-spec-compliance-auditor.md": ["skills/verify-workflow-review/SKILL.md"],
    "agents/review-code-quality-auditor.md": ["skills/verify-workflow-review/SKILL.md"],
    "agents/review-security-auditor.md": [
        "skills/verify-workflow-review/SKILL.md",
        "skills/verify-workflow-review/review-guidance.md",
    ],
    "agents/review-test-engineer.md": [
        "skills/verify-workflow-review/SKILL.md",
        "skills/verify-workflow-review/review-guidance.md",
    ],
    "agents/review-accessibility-auditor.md": [
        "skills/verify-workflow-review/SKILL.md",
        "skills/verify-workflow-review/review-guidance.md",
    ],
}


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def collect_readme_agents(readme_path: Path) -> list[str]:
    readme = read_text(readme_path)
    readme_agents: list[str] = []
    for line in readme.splitlines():
        stripped = line.strip()
        if not stripped.startswith("|"):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if not cells:
            continue
        candidate = cells[0]
        if candidate == "Agent":
            continue
        if re.match(r"^[a-z][a-z0-9-]+$", candidate):
            readme_agents.append(candidate)
    return readme_agents


def parse_frontmatter_tools(agent_path: Path) -> list[str]:
    text = read_text(agent_path)
    frontmatter_match = re.match(r"---\n(.*?)\n---", text, re.S)
    if not frontmatter_match:
        return []

    tools: list[str] = []
    in_tools = False
    for line in frontmatter_match.group(1).splitlines():
        if line.startswith("tools:"):
            in_tools = True
            continue
        if in_tools and line and not line.startswith((" ", "\t", "-")):
            in_tools = False
        if in_tools:
            item = line.strip()
            if item.startswith("- "):
                tools.append(item[2:].strip())
    return tools


def validate(root: Path) -> list[str]:
    errors: list[str] = []
    agents_dir = root / "agents"
    skills_dir = root / "skills"

    skills_text = "\n".join(
        read_text(path)
        for path in sorted(skills_dir.rglob("*.md"))
    )

    for agent_path in sorted(agents_dir.glob("*.md")):
        if agent_path.name == "README.md":
            continue
        token = f"agents/{agent_path.name}"
        if token not in skills_text:
            errors.append(f"{agent_path.relative_to(root)} is declared but not consumed by any skills/*.md contract")

    for token, paths in REQUIRED_SKILL_CONSUMERS.items():
        for relative_path in paths:
            path = root / relative_path
            text = read_text(path)
            if token not in text:
                errors.append(f"{relative_path} missing agent dispatch token: {token}")

    agent_files = sorted(
        path.stem
        for path in agents_dir.glob("*.md")
        if path.name != "README.md"
    )
    readme_agents = collect_readme_agents(agents_dir / "README.md")

    missing_files = sorted(set(readme_agents) - set(agent_files))
    missing_readme = sorted(set(agent_files) - set(readme_agents))
    if missing_files:
        errors.append(f"agents/README.md lists missing agent files: {', '.join(missing_files)}")
    if missing_readme:
        errors.append(f"agent files missing from agents/README.md: {', '.join(missing_readme)}")

    audit_agents = sorted(list(agents_dir.glob("review-*.md")) + list(agents_dir.glob("ship-*.md")))
    for agent_path in audit_agents:
        forbidden = sorted(set(parse_frontmatter_tools(agent_path)) & DISALLOWED_WRITE_TOOLS)
        if forbidden:
            errors.append(
                f"{agent_path.relative_to(root)} declares write-capable tools: {', '.join(forbidden)}"
            )

    brainstorm_path = skills_dir / "define-cognitive-brainstorm/SKILL.md"
    brainstorm = read_text(brainstorm_path)
    if "不调用专属 `agents/*.md` persona" not in brainstorm or "当前 agent 直接执行" not in brainstorm:
        errors.append("define-cognitive-brainstorm must state current-agent execution with no dedicated persona")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd(), help="repository root to validate")
    args = parser.parse_args()

    root = args.root.resolve()
    errors = validate(root)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
