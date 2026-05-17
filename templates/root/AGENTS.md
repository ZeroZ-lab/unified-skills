# AGENTS.md Template

## AI Agent Warning
- 先读 `CANON.md`
- 再读本文件
- 修改技能前必须理解行为塑造意图

## Context Runtime
- 先读 `skills-router.json`
- 声明 loading tier
- 只按需加载 `SKILL.md`

## Workflow Contract
- `/refine` → `01-spec.md`
- `/design` → `02-design.md`
- `/plan` → `03-plan.md`
- `/review` → `04-review.md`
- `/ship` → `05-ship.md`

## Documentation Slots
- `root docs`
- `project docs`
- `feature docs`
- `bug docs`

## Project-Level Truth
- `README.md`
- `AGENTS.md`
- `CHANGELOG.md`
- `DESIGN.md`
- `docs/architecture/*.md`

## Verification
- `./validate`
- skill/index/lock sync rules
- release truth surfaces

## Hard Boundaries
- Always do:
- Ask first:
- Never do:

## Editing Skills
- 用 `templates/` 作为起点
- 更新 `skills-lock.json`
- 必要时更新 `skills-index.json`
- 提交前跑 `./validate`
