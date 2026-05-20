#!/usr/bin/env python3
"""Check design index routing and pipeline sequences in skills-index.json.

Validates:
1. Non-software artifact types must load design-workflow-design as required,
   and user-facing triggers must route through design-workflow-design first.
2. Deck and visual sequences must match the required interactive-preview order.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main() -> None:
    errors: list[str] = []

    index_path = ROOT / "skills-index.json"
    if not index_path.exists():
        print("missing skills-index.json", file=sys.stderr)
        sys.exit(1)

    index = json.loads(index_path.read_text(encoding="utf-8"))

    # --- Design index routing (validate lines 384-395) ---
    for artifact in ("document", "article", "deck", "visual"):
        required = index["by_artifact_type"][artifact]["required"]
        if "design-workflow-design" not in required:
            errors.append(f"{artifact}.required missing design-workflow-design")

    for trigger in (
        "document|文档|article|文章",
        "deck|PPT|演示|slides",
        "visual|视觉稿|海报|版式|layout",
    ):
        skills = index["by_trigger"]["user_says"][trigger]
        if not skills or skills[0] != "design-workflow-design":
            errors.append(f"{trigger} does not start with design-workflow-design")

    # --- Pipeline sequences (validate lines 833-856) ---
    expected_deck_sequence = [
        "design-workflow-design",
        "design-content-script",
        "design-content-direction",
        "design-content-layout",
        "design-interactive-preview",
        "build-content-writing",
        "build-content-layout",
    ]
    deck_sequence = (
        index.get("by_artifact_type", {}).get("deck", {}).get("sequence")
    )
    if deck_sequence != expected_deck_sequence:
        errors.append("deck.sequence does not match required interactive-preview order")

    expected_visual_sequence = [
        "design-workflow-design",
        "design-visual-direction",
        "design-content-layout",
        "design-interactive-preview",
        "build-content-layout",
        "verify-visual-review",
    ]
    visual_sequence = (
        index.get("by_artifact_type", {}).get("visual", {}).get("sequence")
    )
    if visual_sequence != expected_visual_sequence:
        errors.append(
            "visual.sequence does not match required interactive-preview order"
        )

    if errors:
        for e in errors:
            print(e, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
