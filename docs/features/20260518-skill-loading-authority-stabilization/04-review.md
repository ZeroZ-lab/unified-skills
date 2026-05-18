# Skill 加载权与 Agent 调度权稳定化 — Independent Review

## Review Summary
- Reviewer: current independent review session
- Date: 2026-05-18
- Overall: APPROVED_WITH_CONCERNS
- Blocking issues: 0
- Important issues: 2
- Suggestion issues: 0

## Artifact Type
artifact_type: software

## Review Independence
- Built by: prior build session for this feature
- Stage 1 reviewed by: current independent review session
- Stage 2 reviewed by: current independent review session
- Independence status: PASS
- Exemption reason: n/a

## Stage 1: Spec Compliance
- Status: PASS
- Coverage: 核心合同要求已覆盖
- Blocking gaps:
  - 无

## Stage 2: Artifact Quality
- software:
  - Correctness: 已把唯一合法加载链路、skills 加载权归属、agent 无 self-load/self-route/self-expand-scope 权、artifact_type -> delivery_class 顺序写入项目级与 runtime 合同。
  - Readability: `content-writer`、`visual-designer`、`software-engineer` 的伪加载语义已明显收口，但帮助文档和一份架构文档仍保留第二套说法。
  - Architecture: 主链路 `router / command -> stage skill -> current agent or persona -> main session merge` 已明确；不过 repo 里仍有项目级文档把 agent 写成 skills 加载者，稳定性未完全闭环。
  - Security: n/a
  - Performance: n/a

## Findings Summary
| # | Severity | Category | Description | File:Line | Status |
|---|----------|----------|-------------|-----------|--------|
| 1 | Important | Contract Drift | `commands/help.md` 把 `deck` 写成“通常叠加视觉审查”，与 AGENTS/review/skill 合同中的“仅在视觉问题影响结论时叠加”不一致。 | commands/help.md:57 | Open |
| 2 | Important | Documentation Drift | `docs/architecture/command-agent-skill-architecture.md` 仍保留“加载的 Skills / Agent 需要加载的 Skills”模板措辞，继续暗示 agent 有加载权，形成第二套真相。 | docs/architecture/command-agent-skill-architecture.md:1492 | Open |

## Documentation Compliance
- Feature artifact chain complete: PASS
- Project doc sync required by spec: yes
- Required project docs updated: PASS
- Missing sync:
  - 无（按 spec 明示的 `affected_project_docs` 判断）
- Residual drift outside declared sync set:
  - `docs/architecture/command-agent-skill-architecture.md` 仍应后续收口或标记为历史

## Verification Evidence
- Reviewed:
  - `docs/features/20260518-skill-loading-authority-stabilization/01-spec.md`
  - `docs/features/20260518-skill-loading-authority-stabilization/03-plan.md`
  - `AGENTS.md`
  - `skills/maintain-workflow-using-unified/SKILL.md`
  - `skills/maintain-workflow-using-unified/skill-reference.md`
  - `agents/content-writer.md`
  - `agents/visual-designer.md`
  - `agents/software-engineer.md`
  - `commands/help.md`
  - `commands/review.md`
  - `skills/verify-workflow-review/SKILL.md`
- Executed validation:
  - `./validate` PASS

## Verdict
- Merge condition: 可继续推进，但建议在后续小修中收口 help 与 architecture 文档的残余漂移
- Deferred risks:
  - `deck` 审查语义在帮助入口仍可能被误读成默认双审
  - 一份项目级架构文档仍保留 agent 加载 skills 的旧模板
- Follow-up owner:
  - next build session or doc-sync cleanup
