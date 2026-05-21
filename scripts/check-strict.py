#!/usr/bin/env python3
"""Tier 2 structural convention checks extracted from validate.

Checks naming conventions, required markdown sections, and structural
contracts that won't cause runtime crashes but enforce quality standards.

Runnable standalone or called from validate with --strict.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

errors: list[str] = []


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def sgrep(pattern: str, text: str) -> bool:
    """Search for a pattern in text. Uses `in` for literal strings."""
    return pattern in text


def sgrep_line(pattern: str, text: str) -> bool:
    """Search for a pattern anchored at line start (like ^## in bash grep)."""
    for line in text.splitlines():
        if line.startswith(pattern):
            return True
    return False


def check_file_exists(path: Path, label: str) -> bool:
    if not path.exists():
        errors.append(f"缺少{label}: {path}")
        return False
    return True


# ---------------------------------------------------------------------------
# 1. Document template family (validate lines 205-222)
# ---------------------------------------------------------------------------
print("\n== 检查文档模板族完整性 ==")

template_checks = [
    ("templates/feature/00-brainstorm.md", "brainstorm 模板"),
    ("templates/feature/README.md", "feature README 模板"),
    ("templates/feature/04-review.md", "review 模板"),
    ("templates/feature/05-ship.md", "ship 模板"),
    ("templates/feature/06-canary-report.md", "canary 模板"),
    ("templates/feature/07-deploy-report.md", "deploy 模板"),
    ("templates/feature/adr/template.md", "ADR 模板"),
    ("templates/bug/01-root-cause.md", "root-cause 模板"),
    ("templates/bug/02-fix-plan.md", "fix-plan 模板"),
    ("templates/maintain/checkpoint.md", "checkpoint 模板"),
]
for rel, label in template_checks:
    check_file_exists(ROOT / rel, label)

# Section checks
brainstorm_path = ROOT / "templates/feature/00-brainstorm.md"
if brainstorm_path.exists():
    t = read(brainstorm_path)
    if not sgrep_line("## 假设", t):
        errors.append("brainstorm 模板缺少假设区")

feature_readme_path = ROOT / "templates/feature/README.md"
if feature_readme_path.exists():
    t = read(feature_readme_path)
    for section in (
        "## Feature Summary",
        "## Document Index",
        "## Timeline",
        "## Key Decisions",
        "## Delivery Outcome",
        "## Verification Evidence",
        "## Residual Risks",
        "## Follow-up Actions",
        "## Retro Notes",
    ):
        if not sgrep_line(section, t):
            errors.append(f"feature README 模板缺少章节: {section}")

adr_template_path = ROOT / "templates/feature/adr/template.md"
if adr_template_path.exists():
    t = read(adr_template_path)
    for section in (
        "## Status",
        "## Decision Summary",
        "## Context",
        "## Decision Drivers",
        "## Constraints",
        "## Options Considered",
        "## Decision",
        "## Rationale",
        "## Consequences",
        "## Reversibility",
        "## Follow-up",
        "## Evidence Links",
    ):
        if not sgrep_line(section, t):
            errors.append(f"ADR 模板缺少章节: {section}")
    for pattern in ("Supersedes:", "Superseded By:", "Fit Against Drivers", "Reversal trigger:"):
        if not sgrep(pattern, t):
            errors.append(f"ADR 模板缺少字段: {pattern}")

review_path = ROOT / "templates/feature/04-review.md"
if review_path.exists():
    t = read(review_path)
    for section in (
        "## Review Scope",
        "## Review Independence",
        "## Evidence Reviewed",
        "## Findings Detail",
        "## Resolution & Re-review",
        "## Residual Risk",
        "## Documentation Compliance",
        "## Verdict",
    ):
        if not sgrep_line(section, t):
            errors.append(f"review 模板缺少章节: {section}")
    for pattern in ("Built by:", "Stage 1 reviewed by:", "Stage 2 reviewed by:", "Independence status:", "Exemption reason:"):
        if not sgrep(pattern, t):
            errors.append(f"review 模板缺少独立性字段: {pattern}")

ship_path = ROOT / "templates/feature/05-ship.md"
if ship_path.exists():
    t = read(ship_path)
    for section in (
        "## Delivery Scope",
        "## Review Carryover",
        "## Pre-ship Evidence",
        "## Ship Audit Results",
        "## Go / No-Go Decision",
        "## Rollback / Recovery Plan",
        "## Documentation Sync",
        "## Post-ship Monitoring",
        "## Handoff / Archive",
    ):
        if not sgrep_line(section, t):
            errors.append(f"ship 模板缺少章节: {section}")

canary_path = ROOT / "templates/feature/06-canary-report.md"
if canary_path.exists():
    t = read(canary_path)
    for section in (
        "## Canary Scope",
        "## Baseline",
        "## Health Signals",
        "## Endpoint Status",
        "## Analysis Policy",
        "## Anomalies",
        "## Decision",
        "## Baseline Update",
        "## Follow-up",
    ):
        if not sgrep_line(section, t):
            errors.append(f"canary 模板缺少章节: {section}")

deploy_path = ROOT / "templates/feature/07-deploy-report.md"
if deploy_path.exists():
    t = read(deploy_path)
    for section in (
        "## Deploy Scope",
        "## Ship / Canary Carryover",
        "## CI / Merge Status",
        "## Deployment Strategy",
        "## Production Verification",
        "## Rollback Readiness",
        "## Final Deployment Status",
        "## Follow-up / Ownership",
    ):
        if not sgrep_line(section, t):
            errors.append(f"deploy 模板缺少章节: {section}")

root_cause_path = ROOT / "templates/bug/01-root-cause.md"
if root_cause_path.exists():
    t = read(root_cause_path)
    for section in ("## Status Summary", "## 复现证据", "## 时间线", "## 根因", "## 非根因排除", "## Done When"):
        if not sgrep_line(section, t):
            errors.append(f"root-cause 模板缺少章节: {section}")

fix_plan_path = ROOT / "templates/bug/02-fix-plan.md"
if fix_plan_path.exists():
    t = read(fix_plan_path)
    for section in ("## Status Summary", "## 修复目标", "## 复现测试", "## 验证计划", "## Follow-up Actions", "## Done When"):
        if not sgrep_line(section, t):
            errors.append(f"fix-plan 模板缺少章节: {section}")

checkpoint_path = ROOT / "templates/maintain/checkpoint.md"
if checkpoint_path.exists():
    t = read(checkpoint_path)
    for section in (
        "## Summary",
        "## Current Objective",
        "## Git Snapshot",
        "## Progress State",
        "## Decisions Made",
        "## Validation State",
        "## Remaining Work",
        "## Blockers",
        "## Next Command",
        "## Handoff Risks",
        "## Notes",
    ):
        if not sgrep_line(section, t):
            errors.append(f"checkpoint 模板缺少章节: {section}")
    for pattern in ("current_objective:", "next_command:", "last_commits:"):
        if not sgrep(pattern, t):
            errors.append(f"checkpoint 模板缺少 frontmatter 字段: {pattern}")

print("通过" if not errors else "FAIL")

# ---------------------------------------------------------------------------
# 2. Project-level template family (validate lines 224-245)
# ---------------------------------------------------------------------------
print("\n== 检查项目级模板族完整性 ==")

project_template_files = [
    ("templates/TEMPLATE-GUIDE.md", "TEMPLATE-GUIDE.md"),
    ("templates/root/README.md", "root README 模板"),
    ("templates/root/AGENTS.md", "root AGENTS 模板"),
    ("templates/root/CHANGELOG.md", "root CHANGELOG 模板"),
    ("templates/project/system-overview.md", "system-overview 模板"),
    ("templates/project/module-boundaries.md", "module-boundaries 模板"),
    ("templates/project/deployment-and-runtime.md", "deployment-and-runtime 模板"),
    ("templates/project/observability-and-runbook.md", "observability-and-runbook 模板"),
]
for rel, label in project_template_files:
    check_file_exists(ROOT / rel, label)

# README template sections
readme_tpl = ROOT / "templates/root/README.md"
if readme_tpl.exists():
    t = read(readme_tpl)
    if not sgrep_line("## Quick Start", t):
        errors.append("root README 模板缺少 Quick Start")

# AGENTS template sections
agents_tpl = ROOT / "templates/root/AGENTS.md"
if agents_tpl.exists():
    t = read(agents_tpl)
    if not sgrep_line("## 终端观察护栏｜Terminal Observation Guardrail", t):
        errors.append("root AGENTS 模板缺少终端观察护栏")
    if not sgrep("未知输出先限流，复杂信息先采样", t):
        errors.append("root AGENTS 模板缺少终端观察核心原则")
    if not sgrep("COMMAND 2>&1 | head -c 4000", t):
        errors.append("root AGENTS 模板缺少默认输出限流命令")
    if not sgrep_line("## Workflow Contract", t):
        errors.append("root AGENTS 模板缺少 Workflow Contract")

# CHANGELOG template
changelog_tpl = ROOT / "templates/root/CHANGELOG.md"
if changelog_tpl.exists():
    t = read(changelog_tpl)
    if not sgrep_line("## [Unreleased]", t):
        errors.append("root CHANGELOG 模板缺少 Unreleased")

# Project docs templates
sys_overview = ROOT / "templates/project/system-overview.md"
if sys_overview.exists():
    t = read(sys_overview)
    if not sgrep_line("## System Boundaries", t):
        errors.append("system-overview 模板缺少 System Boundaries")

module_bounds = ROOT / "templates/project/module-boundaries.md"
if module_bounds.exists():
    t = read(module_bounds)
    if not sgrep_line("## Allowed Dependencies", t):
        errors.append("module-boundaries 模板缺少 Allowed Dependencies")

deploy_runtime = ROOT / "templates/project/deployment-and-runtime.md"
if deploy_runtime.exists():
    t = read(deploy_runtime)
    if not sgrep_line("## Rollback Entry", t):
        errors.append("deployment-and-runtime 模板缺少 Rollback Entry")

observability = ROOT / "templates/project/observability-and-runbook.md"
if observability.exists():
    t = read(observability)
    if not sgrep_line("## Incident Actions", t):
        errors.append("observability-and-runbook 模板缺少 Incident Actions")

# TEMPLATE-GUIDE sections
guide_tpl = ROOT / "templates/TEMPLATE-GUIDE.md"
if guide_tpl.exists():
    t = read(guide_tpl)
    if not sgrep_line("## Enterprise Template Standard", t):
        errors.append("TEMPLATE-GUIDE 缺少 Enterprise Template Standard")
    if not sgrep_line("## Reviewer Checklist", t):
        errors.append("TEMPLATE-GUIDE 缺少 Reviewer Checklist")

print("通过" if not any(e for e in errors if "模板" in e or "TEMPLATE-GUIDE" in e) else "FAIL")

# ---------------------------------------------------------------------------
# 3. Doc sync contract string checks (validate lines 247-283)
# ---------------------------------------------------------------------------
print("\n== 检查文档同步合同 ==")

doc_sync_checks = {
    "doc_intent": [
        ("AGENTS.md", "AGENTS"),
        ("templates/feature/01-spec.md", "spec 模板"),
        ("skills/define-workflow-spec/SKILL.md", "spec 技能"),
    ],
    "project_truth_changed": [
        ("docs/contracts/doc-slots.md", "docs/contracts/doc-slots.md"),
        ("templates/feature/01-spec.md", "spec 模板"),
        ("skills/define-workflow-spec/SKILL.md", "spec 技能"),
    ],
    "affected_project_docs": [
        ("docs/contracts/doc-slots.md", "docs/contracts/doc-slots.md"),
        ("templates/feature/01-spec.md", "spec 模板"),
        ("skills/define-workflow-spec/SKILL.md", "spec 技能"),
    ],
    "Project Doc Sync Plan": [
        ("docs/contracts/doc-slots.md", "docs/contracts/doc-slots.md"),
        ("templates/feature/03-plan.md", "plan 模板"),
        ("skills/build-workflow-plan/SKILL.md", "plan 技能"),
    ],
    "Documentation Compliance": [
        ("docs/contracts/doc-slots.md", "docs/contracts/doc-slots.md"),
        ("skills/verify-workflow-review/SKILL.md", "review 技能"),
    ],
    "Documentation Sync": [
        ("docs/contracts/doc-slots.md", "docs/contracts/doc-slots.md"),
        ("skills/ship-workflow-ship/SKILL.md", "ship 技能"),
    ],
}

for pattern, files in doc_sync_checks.items():
    for rel, label in files:
        p = ROOT / rel
        if p.exists():
            if not sgrep(pattern, read(p)):
                errors.append(f"{label}缺少文档同步合同字段: {pattern}")

# Run the external doc sync contract checker
result = subprocess.run(
    [sys.executable, str(ROOT / "scripts/check-doc-sync-contract.py")],
    capture_output=True,
    text=True,
)
if result.returncode != 0:
    errors.append(f"文档同步合同检查失败: {result.stderr.strip() or result.stdout.strip()}")

print("通过" if not any("文档同步" in e or "doc_intent" in e or "Doc Sync" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 4. Multi-plan parallel contract (validate lines 285-302)
# ---------------------------------------------------------------------------
print("\n== 检查多计划并行契约 ==")

plan_skill = ROOT / "skills/build-workflow-plan/SKILL.md"
if plan_skill.exists():
    t = read(plan_skill)
    for pattern in ("Plan Topology", "Subplans", "Parallel Safety"):
        if not sgrep(pattern, t):
            errors.append(f"plan 技能缺少 {pattern}")
    for pattern in ("Shared Contracts", "Global Invariants", "Cross-check Command", "Semantic Independence Reason"):
        if not sgrep(pattern, t):
            errors.append(f"plan 技能缺少语义并行字段: {pattern}")

plan_template = ROOT / "templates/feature/03-plan.md"
if plan_template.exists():
    t = read(plan_template)
    for pattern in ("plans/", "Parallel Execution Matrix", "Write Scope", "Shared Contracts", "Cross-check Command", "Semantic Independence Reason"):
        if not sgrep(pattern, t):
            errors.append(f"plan 模板缺少 {pattern}")

# Task templates
task_templates = ROOT / "skills/build-workflow-plan/task-templates.md"
if task_templates.exists():
    t = read(task_templates)
    for pattern in ("Shared Contracts", "Global Invariants", "Cross-check Command", "Semantic Independence Reason"):
        if not sgrep(pattern, t):
            errors.append(f"task-templates 缺少语义并行字段: {pattern}")

# Execute and execution-engine skills
for skill_rel in ("skills/build-workflow-execute/SKILL.md", "skills/build-cognitive-execution-engine/SKILL.md"):
    p = ROOT / skill_rel
    if p.exists():
        t = read(p)
        for pattern in ("Plan Topology", "Parallel Execution Matrix", "parallel_safe", "Write Scope", "Shared Contracts", "Cross-check Command"):
            if not sgrep(pattern, t):
                name = skill_rel.split("/")[1]
                errors.append(f"{name} 技能缺少 {pattern}")

# README and AGENTS
for rel in ("README.md", "AGENTS.md"):
    p = ROOT / rel
    if p.exists():
        if not sgrep("plans/*.md", read(p)):
            errors.append(f"{rel} 缺少 plans/*.md 文档产出链")

print("通过" if not any("并行" in e or "plans/" in e or "Plan Topology" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 5. Review independence (validate lines 304-315)
# ---------------------------------------------------------------------------
print("\n== 检查 review 独立性与 pre-review 边界 ==")

review_skill = ROOT / "skills/verify-workflow-review/SKILL.md"
if review_skill.exists():
    t = read(review_skill)
    for pattern in ("trivial exemption", "Independence status", "Built by", "pre-review / implementation gate"):
        if not sgrep(pattern, t):
            errors.append(f"review 技能缺少独立性/边界合同: {pattern}")

review_cmd = ROOT / "commands/review.md"
if review_cmd.exists():
    t = read(review_cmd)
    for pattern in ("Stage 2 必须独立", "Independence status", "Exemption reason"):
        if not sgrep(pattern, t):
            errors.append(f"review 命令缺少独立性合同: {pattern}")

for skill_rel in ("skills/build-cognitive-execution-engine/SKILL.md",):
    p = ROOT / skill_rel
    if p.exists():
        t = read(p)
        for pattern in ("pre-review", "formal `/review`", "04-review.md"):
            if not sgrep(pattern, t):
                errors.append(f"execution-engine 缺少 build/review 边界: {pattern}")

build_cmd = ROOT / "commands/build.md"
if build_cmd.exists():
    t = read(build_cmd)
    for pattern in ("pre-review", "formal `/review`", "04-review.md"):
        if not sgrep(pattern, t):
            errors.append(f"build 命令缺少 build/review 边界: {pattern}")

print("通过" if not any("独立性" in e or "pre-review" in e or "04-review" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 6. Build task-by-task (validate lines 317-328)
# ---------------------------------------------------------------------------
print("\n== 检查 build task-by-task 合同 ==")

task_by_task_files = [
    "skills/build-workflow-execute/SKILL.md",
    "skills/build-cognitive-execution-engine/SKILL.md",
    "commands/build.md",
    "templates/feature/03-plan.md",
]
for rel in task_by_task_files:
    p = ROOT / rel
    if p.exists():
        if not sgrep("task-by-task", read(p)):
            errors.append(f"缺少 task-by-task 合同: {rel}")

execute_skill = ROOT / "skills/build-workflow-execute/SKILL.md"
if execute_skill.exists():
    if not sgrep("Task N", read(execute_skill)):
        errors.append("execute 技能缺少 Task N 执行单元")

plan_tpl = ROOT / "templates/feature/03-plan.md"
if plan_tpl.exists():
    if not sgrep("Task N", read(plan_tpl)):
        errors.append("plan 模板缺少 Task N 执行单元")

print("通过" if not any("task-by-task" in e or "Task N" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 7. Refine External Scan (validate lines 338-351)
# ---------------------------------------------------------------------------
print("\n== 检查 refine External Scan ==")

refine_skill = ROOT / "skills/define-workflow-refine/SKILL.md"
if refine_skill.exists():
    t = read(refine_skill)
    if not sgrep("Phase 1.4：External Scan", t):
        errors.append("refine 技能缺少 Phase 1.4 External Scan")
    if not sgrep("Fact / Pattern / Inference / Unknown / Adopt / Reject", t):
        errors.append("refine 技能缺少 External Scan 分层契约")

spec_tpl = ROOT / "templates/feature/01-spec.md"
if spec_tpl.exists():
    t = read(spec_tpl)
    if not sgrep_line("## External References", t):
        errors.append("spec 模板缺少 External References")
    if not sgrep_line("## Scout Review Summary", t):
        errors.append("spec 模板缺少 Scout Review Summary")

for agent_file in ("agents/refine-ceo-scout.md", "agents/refine-eng-scout.md", "agents/refine-design-scout.md"):
    p = ROOT / agent_file
    if not p.exists():
        errors.append(f"缺少 refine scout agent: {agent_file}")
    else:
        t = read(p)
        for section in ("Verdict", "Evidence Used", "Findings", "Spec Impact"):
            if not sgrep_line(f"## {section}", t):
                errors.append(f"refine scout 缺少章节 {section}: {agent_file}")

print("通过" if not any("External Scan" in e or "scout" in e.lower() for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 8. Design evidence gate (validate lines 353-405, skip pipeline/routing)
# ---------------------------------------------------------------------------
print("\n== 检查 design evidence gate ==")

# Best practices reference file
bp_ref = ROOT / "references/design-best-practices.md"
if not bp_ref.exists():
    errors.append("缺少设计最佳实践来源合同: references/design-best-practices.md")
else:
    t = read(bp_ref)
    for pattern in (
        "Enterprise Product Patterns",
        "Official Systems / Platform Rules",
        "Methods / Theory / Style Schools",
        "Anti-patterns / Verification",
        "Local Project Truth",
    ):
        if not sgrep(pattern, t):
            errors.append(f"design-best-practices 缺少来源层: {pattern}")

# /design command
design_cmd = ROOT / "commands/design.md"
if design_cmd.exists():
    t = read(design_cmd)
    if not sgrep("Design Best-Practice Scan", t):
        errors.append("/design 缺少 Design Best-Practice Scan phase")
    if not sgrep("Sources / Patterns / Inferences / Adopt / Reject / Unknown", t):
        errors.append("/design 缺少 scan 输出契约")
    if not sgrep("Design References", t):
        errors.append("/design 缺少 Design References gate")

# Design template sections
design_tpl = ROOT / "templates/feature/02-design.md"
if design_tpl.exists():
    t = read(design_tpl)
    for pattern in (
        "## Design References",
        "## Pattern Synthesis",
        "## Design Inferences",
        "## Adopt / Reject",
        "## Design Evidence Quality",
    ):
        if not sgrep_line(pattern, t):
            errors.append(f"02-design 模板缺少 {pattern}")

# Design reviewer agent
design_reviewer = ROOT / "agents/design-reviewer.md"
if design_reviewer.exists():
    t = read(design_reviewer)
    if not sgrep("设计证据质量", t):
        errors.append("design-reviewer 缺少设计证据质量审查")
    if not sgrep("缺少 Design References", t):
        errors.append("design-reviewer 缺少 Design References blocking")
    if not sgrep("缺少 Design Inferences", t):
        errors.append("design-reviewer 缺少 Design Inferences blocking")
    if not sgrep("缺少 Adopt / Reject", t):
        errors.append("design-reviewer 缺少 Adopt / Reject blocking")

# Design skills reference best-practices
for skill_path in sorted(ROOT.glob("skills/design-*/SKILL.md")):
    t = read(skill_path)
    if not sgrep("references/design-best-practices.md", t):
        errors.append(f"design 技能缺少 best-practices reference: {skill_path.relative_to(ROOT)}")
    if not sgrep("Adopt / Reject", t):
        errors.append(f"design 技能缺少 Adopt / Reject 合同: {skill_path.relative_to(ROOT)}")
    if not sgrep("Local Project Truth", t):
        errors.append(f"design 技能缺少 Local Project Truth: {skill_path.relative_to(ROOT)}")

# Boundary document
role_esc = ROOT / "docs/contracts/role-escalation.md"
if role_esc.exists():
    if not sgrep("不替代 `/design` 的设计扫描", read(role_esc)):
        errors.append("docs/contracts/role-escalation.md 缺少 refine scan 与 design scan 的边界")

arch_doc = ROOT / "docs/architecture/command-agent-skill-architecture.md"
if arch_doc.exists():
    if not sgrep("不替代 `/design` 的创作与呈现层扫描", read(arch_doc)):
        errors.append("架构文档缺少 refine/design scan 边界")

print("通过" if not any("design" in e.lower() or "best-practices" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 9. DESIGN.md template (validate lines 406-425)
# ---------------------------------------------------------------------------
print("\n== 检查 DESIGN.md 模板 ==")

design_md_tpl = ROOT / "templates/root/DESIGN.md"
if not design_md_tpl.exists():
    errors.append("缺少项目级设计约束模板: templates/root/DESIGN.md")
else:
    t = read(design_md_tpl)
    for token in ("colors:", "typography:", "components:"):
        if not sgrep(token, t):
            errors.append(f"DESIGN.md 模板缺少 YAML {token} token")
    if not sgrep("Sync Log", t):
        errors.append("DESIGN.md 模板缺少 Sync Log 章节")

# Skills reference DESIGN.md
design_skill = ROOT / "skills/design-workflow-design/SKILL.md"
if design_skill.exists():
    t = read(design_skill)
    if not sgrep("DESIGN.md", t):
        errors.append("design-workflow-design 缺少 DESIGN.md 引用")
    if not sgrep("design-inspiration-catalog", t):
        errors.append("design-workflow-design 缺少 design-inspiration-catalog 引用")
    if not sgrep("design-pattern-extract", t):
        errors.append("design-workflow-design 缺少 design-pattern-extract 引用")
    if not sgrep("Step 3.5：Codex", t):
        errors.append("design-workflow-design 缺少 Step 3.5 Codex 视觉生成")
    if not sgrep("design-tokens-extracted", t):
        errors.append("design-workflow-design 缺少 design-tokens-extracted 产物")

# Command references
if design_cmd.exists():
    t = read(design_cmd)
    if not sgrep("DESIGN.md", t):
        errors.append("design 命令缺少 DESIGN.md 引用")
    if not sgrep("Phase 2.5: Codex", t):
        errors.append("design 命令缺少 Phase 2.5 Codex 视觉生成")
    if not sgrep("mockup-direction", t):
        errors.append("design 命令缺少 mockup 产物说明")

# Best practices references DESIGN.md
if bp_ref.exists():
    if not sgrep("DESIGN.md", read(bp_ref)):
        errors.append("design-best-practices 缺少 DESIGN.md 说明")

# AGENTS.md references
agents_root = ROOT / "AGENTS.md"
if agents_root.exists():
    t = read(agents_root)
    if not sgrep("codex-rescue", t):
        errors.append("AGENTS 缺少 codex-rescue 引用")
    if not sgrep("design-tokens-extracted", t):
        errors.append("AGENTS 缺少 design-tokens-extracted 产物说明")

# Reference files
check_file_exists(ROOT / "references/design-inspiration-catalog.md", "设计灵感目录")
check_file_exists(ROOT / "references/design-pattern-extract.md", "设计模式提取")

print("通过" if not any("DESIGN" in e or "design-" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 10. Core chapters in skills (validate lines 464-473)
# ---------------------------------------------------------------------------
print("\n== 检查技能核心章节 ==")

required_sections = [
    ("入口/出口", "入口/出口章节"),
    ("何时不使用", "何时不使用章节"),
    ("常见说辞", "常见说辞章节"),
    ("红旗", "红旗章节"),
    ("验证清单", "验证清单章节"),
]

for skill_path in sorted(ROOT.glob("skills/*/SKILL.md")):
    t = read(skill_path)
    for pattern, label in required_sections:
        found = False
        for line in t.splitlines():
            if line.startswith("## ") and pattern in line:
                found = True
                break
        if not found:
            errors.append(f"缺少{label}: {skill_path.relative_to(ROOT)}")

print("通过" if not any("章节" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 11. Agent definition structure (validate lines 479-500)
# ---------------------------------------------------------------------------
print("\n== 检查 Agent 定义结构 ==")

# Audit/review agents
for pattern in ("agents/review-*.md", "agents/plan-*.md", "agents/refine-*.md", "agents/ship-*.md"):
    for agent_path in sorted(ROOT.glob(pattern)):
        t = read(agent_path)
        if not sgrep_line("name: ", t):
            errors.append(f"缺少 name frontmatter: {agent_path.relative_to(ROOT)}")
        if not sgrep_line("description: ", t):
            errors.append(f"缺少 description frontmatter: {agent_path.relative_to(ROOT)}")
        if not sgrep("# ", t):
            errors.append(f"缺少 H1 标题: {agent_path.relative_to(ROOT)}")
        if not sgrep("审查维度", t) and not sgrep("审计维度", t):
            errors.append(f"缺少审查维度/审计维度章节: {agent_path.relative_to(ROOT)}")
        if not sgrep("输出格式", t):
            errors.append(f"缺少输出格式章节: {agent_path.relative_to(ROOT)}")
        if not sgrep("Blocking", t) or not sgrep("Important", t) or not sgrep("Suggestion", t):
            # Check if all three appear on the same line (the bash version uses Blocking.*Important.*Suggestion regex)
            found_combined = False
            for line in t.splitlines():
                if "Blocking" in line and "Important" in line and "Suggestion" in line:
                    found_combined = True
                    break
            if not found_combined:
                errors.append(f"缺少 Blocking/Important/Suggestion 分级: {agent_path.relative_to(ROOT)}")

# Engineering agents
eng_patterns = (
    "agents/requirements-*.md",
    "agents/task-*.md",
    "agents/software-*.md",
    "agents/data-*.md",
    "agents/api-*.md",
    "agents/content-*.md",
    "agents/visual-*.md",
)
for pattern in eng_patterns:
    for agent_path in sorted(ROOT.glob(pattern)):
        t = read(agent_path)
        if not sgrep_line("name: ", t):
            errors.append(f"缺少 name frontmatter: {agent_path.relative_to(ROOT)}")
        if not sgrep_line("description: ", t):
            errors.append(f"缺少 description frontmatter: {agent_path.relative_to(ROOT)}")
        if not sgrep("# ", t):
            errors.append(f"缺少 H1 标题: {agent_path.relative_to(ROOT)}")
        if not sgrep("职责", t):
            errors.append(f"缺少职责章节: {agent_path.relative_to(ROOT)}")
        if not sgrep("输出格式", t):
            errors.append(f"缺少输出格式章节: {agent_path.relative_to(ROOT)}")

# Run external agent contracts checker
result = subprocess.run(
    [sys.executable, str(ROOT / "scripts/check-agent-contracts.py")],
    capture_output=True,
    text=True,
)
if result.returncode != 0:
    errors.append(f"Agent 调用合同检查失败: {result.stderr.strip() or result.stdout.strip()}")

print("通过" if not any("frontmatter" in e or "Agent" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 12. Iron Law coverage (validate lines 623-648)
# ---------------------------------------------------------------------------
print("\n== 检查强纪律技能 Iron Law ==")

iron_law_skills = [
    "skills/build-quality-tdd/SKILL.md",
    "skills/verify-workflow-debug/SKILL.md",
    "skills/verify-workflow-review/SKILL.md",
    "skills/ship-workflow-ship/SKILL.md",
    "skills/verify-quality-security/SKILL.md",
    "skills/ship-infrastructure-deploy/SKILL.md",
    "skills/verify-quality-performance/SKILL.md",
    "skills/build-infrastructure-git/SKILL.md",
    "skills/ship-infrastructure-ci-cd/SKILL.md",
    "skills/ship-workflow-canary/SKILL.md",
    "skills/ship-workflow-land/SKILL.md",
    "skills/verify-content-review/SKILL.md",
    "skills/verify-quality-simplify/SKILL.md",
    "skills/verify-team-skill-quality/SKILL.md",
    "skills/verify-team-code-review-standards/SKILL.md",
    "skills/verify-visual-review/SKILL.md",
    "skills/verify-workflow-receiving-review/SKILL.md",
    "skills/build-frontend-browser-testing/SKILL.md",
    "skills/verify-frontend-accessibility/SKILL.md",
    "skills/verify-quality-integration-testing/SKILL.md",
]

for rel in iron_law_skills:
    p = ROOT / rel
    if p.exists():
        if not sgrep_line("## Iron Law", read(p)):
            errors.append(f"缺少 Iron Law: {rel}")

print("通过" if not any("Iron Law" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 13. HARD-GATE coverage (validate lines 696-722)
# ---------------------------------------------------------------------------
print("\n== 检查 HARD-GATE 覆盖 ==")

hard_gate_skills = [
    "skills/build-quality-tdd/SKILL.md",
    "skills/verify-workflow-debug/SKILL.md",
    "skills/verify-workflow-review/SKILL.md",
    "skills/ship-workflow-ship/SKILL.md",
    "skills/verify-quality-security/SKILL.md",
    "skills/ship-infrastructure-deploy/SKILL.md",
    "skills/verify-quality-performance/SKILL.md",
    "skills/build-infrastructure-git/SKILL.md",
    "skills/ship-infrastructure-ci-cd/SKILL.md",
    "skills/ship-workflow-canary/SKILL.md",
    "skills/ship-workflow-land/SKILL.md",
    "skills/verify-content-review/SKILL.md",
    "skills/verify-quality-simplify/SKILL.md",
    "skills/verify-team-skill-quality/SKILL.md",
    "skills/verify-team-code-review-standards/SKILL.md",
    "skills/verify-visual-review/SKILL.md",
    "skills/verify-workflow-receiving-review/SKILL.md",
    "skills/build-frontend-browser-testing/SKILL.md",
    "skills/maintain-workflow-using-unified/SKILL.md",
    "skills/verify-frontend-accessibility/SKILL.md",
    "skills/verify-quality-integration-testing/SKILL.md",
]

for rel in hard_gate_skills:
    p = ROOT / rel
    if p.exists():
        if not sgrep("<HARD-GATE>", read(p)):
            errors.append(f"缺少 HARD-GATE: {rel}")

print("通过" if not any("HARD-GATE" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 14. Agent Skill quality contract (validate lines 650-693)
# ---------------------------------------------------------------------------
print("\n== 检查 Agent Skill 质量合同 ==")

skill_quality = ROOT / "skills/verify-team-skill-quality/SKILL.md"
if not skill_quality.exists():
    errors.append("missing skills/verify-team-skill-quality/SKILL.md")
else:
    t = read(skill_quality)
    required_phrases = [
        "什么时候触发",
        "触发后怎么做",
        "什么时候停止",
        "如何判断做对",
        "description",
        "near-miss",
        "Progressive Disclosure",
        "STOP 条件",
        "输出契约",
        "Done When",
        "Trigger Eval",
        "Task Eval",
    ]
    for phrase in required_phrases:
        if phrase not in t:
            errors.append(f"verify-team-skill-quality missing phrase: {phrase}")

# Index routing check (kept from validate since it's part of this block)
import json

index_path = ROOT / "skills-index.json"
if not index_path.exists():
    errors.append("missing skills-index.json")
else:
    index = json.loads(index_path.read_text(encoding="utf-8"))
    triggers = index.get("by_trigger", {}).get("user_says", {})
    if not any("verify-team-skill-quality" in skills for skills in triggers.values()):
        errors.append("skills-index.json missing trigger route for verify-team-skill-quality")
    if "verify-team-skill-quality" not in index.get("skill_descriptions", {}):
        errors.append("skills-index.json skill_descriptions missing verify-team-skill-quality")

print("通过" if not any("skill-quality" in e or "verify-team-skill-quality" in e for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# 15. Risk-based role escalation phrases (from validate lines 898-914)
# ---------------------------------------------------------------------------
print("\n== 检查 Risk-based role escalation phrases ==")

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

for rel, phrases in required_role_contracts.items():
    p = ROOT / rel
    if not p.exists():
        errors.append(f"missing risk-based role escalation file: {rel}")
        continue
    t = read(p)
    for phrase in phrases:
        if phrase not in t:
            errors.append(f"{rel} missing risk-based role escalation phrase: {phrase}")

print("通过" if not any("role escalation" in e or "risk" in e.lower() for e in errors) else "FAIL")

# ---------------------------------------------------------------------------
# Final result
# ---------------------------------------------------------------------------
if errors:
    print("\n--- STRICT CHECK FAILURES ---", file=sys.stderr)
    for e in errors:
        print(f"FAIL: {e}", file=sys.stderr)
    sys.exit(1)
else:
    print("\n所有 Tier 2 严格检查通过")
