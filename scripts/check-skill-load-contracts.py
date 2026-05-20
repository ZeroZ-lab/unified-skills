#!/usr/bin/env python3
"""Check skill loading contracts across guide, commands, and contract files.

Validates:
- No dynamic skill counts in guide
- AGENTS.md single-entry wording in guide
- No stale CLAUDE.md entry wording in guide
- 3 opt-in phrases in guide
- No stale mandatory runtime wording in guide
- Skill reference completeness (every phase skill listed in skill-reference.md)
- Preview route existence
- Command wording checks (brainstorm, build, review)
- No fixed all-role review wording (7 forbidden patterns in 7 files)
- Risk-based role escalation phrases in 6 files
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main() -> None:
    errors: list[str] = []

    index = json.loads((ROOT / "skills-index.json").read_text(encoding="utf-8"))
    guide_path = ROOT / "skills/maintain-workflow-using-unified/SKILL.md"
    guide = guide_path.read_text(encoding="utf-8")

    phase_skills: list[str] = []
    for entry in index.get("by_phase", {}).values():
        phase_skills.extend(entry.get("skills", []))

    # --- No dynamic skill counts in guide ---
    if re.search(r"(^|[^0-9.])\d+\s*(?:个)?技能", guide):
        errors.append(f"{guide_path} contains dynamic skill count")

    # --- AGENTS.md single-entry wording ---
    if "`AGENTS.md`" not in guide:
        errors.append(f"{guide_path} missing AGENTS.md single-entry wording")

    # --- No stale CLAUDE.md entry wording ---
    if "CLAUDE.md、直接请求" in guide or "CLAUDE.md / spec" in guide:
        errors.append(f"{guide_path} contains stale CLAUDE.md entry wording")

    # --- 3 opt-in phrases ---
    for phrase in ("显式进入 Unified 工作流", "direct mode", "skills-router.json"):
        if phrase not in guide:
            errors.append(f"{guide_path} missing opt-in runtime phrase: {phrase}")

    # --- No stale mandatory runtime wording ---
    for stale in (
        "每个任务都先过 `skills-router.json`。没有例外。",
        "在响应用户消息或采取任何行动之前，你必须执行技能发现流程。",
    ):
        if stale in guide:
            errors.append(
                f"{guide_path} still contains stale mandatory runtime wording: {stale}"
            )

    # --- Skill reference completeness ---
    reference_text = guide
    reference_path = ROOT / "skills/maintain-workflow-using-unified/skill-reference.md"
    if reference_path.exists():
        reference_text += "\n" + reference_path.read_text(encoding="utf-8")
    for skill in sorted(set(phase_skills)):
        if f"`{skill}`" not in reference_text:
            errors.append(f"{guide_path} quick reference missing {skill}")

    # --- Preview route existence ---
    triggers = index.get("by_trigger", {}).get("user_says", {})
    preview_routes = [
        skills
        for pattern, skills in triggers.items()
        if any(
            token in pattern
            for token in ("preview", "预览", "mockup", "设计方向", "对比", "interactive")
        )
    ]
    if not any(
        skills[:2] == ["design-workflow-design", "design-interactive-preview"]
        for skills in preview_routes
    ):
        errors.append(
            "skills-index.json missing preview route to design-workflow-design + design-interactive-preview"
        )

    # --- Command wording: brainstorm ---
    brainstorm = (ROOT / "commands/brainstorm.md").read_text(encoding="utf-8")
    if "CLAUDE.md / spec" in brainstorm:
        errors.append("commands/brainstorm.md still references CLAUDE.md / spec")

    # --- Command wording: build ---
    build = (ROOT / "commands/build.md").read_text(encoding="utf-8")
    if "build-infrastructure-git" not in build:
        errors.append(
            "commands/build.md missing software required build-infrastructure-git"
        )

    # --- Command wording: review ---
    review = (ROOT / "commands/review.md").read_text(encoding="utf-8")
    for required in (
        "document / article",
        "deck",
        "verify-content-review",
        "verify-visual-review",
    ):
        if required not in review:
            errors.append(
                f"commands/review.md missing artifact review route: {required}"
            )
    for required in ("Spec Compliance", "Code Quality"):
        if required not in review:
            errors.append(
                f"commands/review.md missing two-stage review gate: {required}"
            )

    # --- No fixed all-role review wording (7 forbidden patterns in 7 files) ---
    contract_files = [
        ROOT / "AGENTS.md",
        ROOT / "agents/README.md",
        ROOT / "commands/refine.md",
        ROOT / "commands/plan.md",
        ROOT / "commands/review.md",
        ROOT / "commands/ship.md",
        ROOT / "docs/architecture/command-agent-skill-architecture.md",
    ]
    for path in contract_files:
        text = path.read_text(encoding="utf-8")
        forbidden = [
            r"[34]\s*个\s*(?:Scouts|Reviewers|Auditors)\s*全部完成",
            r"经\s*[34]\s*个视角审查",
            r"报告包含所有\s*Reviewer\s*(?:的)?反馈",
            r"所有\s*(?:Reviewers|Auditors)\s*(?:已)?完成",
            r"所有\s*Auditors\s*通过",
            r"必须同时并行派发",
            r"(?:Review Army|Plan Review Army|Refine Scout Army|Ship Audit Army)[^\n]*（\s*[34]\s*个\s*）",
        ]
        for pattern in forbidden:
            if re.search(pattern, text, re.IGNORECASE):
                errors.append(
                    f"{path} contains fixed all-role review wording: {pattern}"
                )

    # --- Risk-based role escalation phrases ---
    required_role_contracts = {
        "docs/contracts/role-escalation.md": [
            "Risk-Based Role Escalation",
            "最小必要角色",
            "并行只用于已被阶段技能选中的角色",
        ],
        "AGENTS.md": ["--full"],
        "agents/README.md": ["风险升级", "`--full`", "并行只用于已选角色"],
        "commands/refine.md": ["按风险升级", "minimum trigger rules", "已选 Scouts"],
        "commands/plan.md": ["按风险升级", "minimum trigger rules", "已选 Reviewers"],
        "commands/review.md": ["按风险升级", "risk triggers", "已选 Reviewer"],
        "commands/ship.md": ["按风险升级", "minimum trigger rules", "已选 Auditor"],
    }
    for file, phrases in required_role_contracts.items():
        text = (ROOT / file).read_text(encoding="utf-8")
        for phrase in phrases:
            if phrase not in text:
                errors.append(
                    f"{file} missing risk-based role escalation phrase: {phrase}"
                )

    if errors:
        for e in errors:
            print(e, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
