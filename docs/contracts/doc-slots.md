# 文档槽位合同 & 产出链

> 本文件由 `/refine`、`/plan`、`/review`、`/ship` 阶段技能按需加载，不在 CLAUDE.md 中全量引用。

## 文档槽位

skills 运行工作流时，文档必须先落到正确槽位，再决定具体文件。

- `root docs`
  - `README.md`
  - `AGENTS.md`
  - `CHANGELOG.md`
  - `DESIGN.md`
- `project docs`
  - `docs/architecture/*.md`
- `feature docs`
  - `docs/features/YYYYMMDD-<name>/*`
- `bug docs`
  - `docs/bugs/<name>/*`

默认只写 `feature docs`。只有 spec 里的 `Documentation Impact` 明确要求时，才同步 `root docs` 或 `project docs`。

## 阶段责任

- `/refine`
  - 必须在 `01-spec.md` 写 `Documentation Impact`
  - 如果 `project_truth_changed: yes`，必须列出 `affected_project_docs`
- `/design`
  - 只负责 `DESIGN.md` 这类项目级设计真相，不替代其他 project doc sync
- `/plan`
  - 必须在 `03-plan.md` 写 `Project Doc Sync Plan`
  - 必须写清 `Must update`、`Stage owner`、`Verification method`、`Deferred docs with reason`
- `/review`
  - 必须检查 `Documentation Compliance`
  - spec 说要同步但未兑现时，审查不得通过
- `/ship`
  - 必须写 `Documentation Sync`
  - 必须收口 `CHANGELOG.md` / `README.md` / 其他受影响 project docs 的状态

## 文档产出链

```
README.md                     ← project entry truth（按需同步，不属于单一 feature）
AGENTS.md                     ← agent contract truth（按需同步，不属于单一 feature）
CHANGELOG.md                  ← release / user-visible change truth（按需同步）
DESIGN.md                     ← /design（项目级设计系统，Google Stitch token 格式，自动同步）
docs/architecture/*.md        ← project docs（系统长期真相，按需同步）

docs/features/YYYYMMDD-<name>/
├── state.json             ← hook 自动维护的阶段级恢复状态
├── 00-brainstorm.md        ← /brainstorm
├── 01-spec.md              ← /refine
├── 02-design.md            ← /design
├── 03-plan.md              ← /plan
├── plans/*.md              ← /plan（大型/并行任务的子计划）
├── adr/<num>.md            ← /build（决策时）
├── 04-review.md            ← /review
├── 05-ship.md              ← /ship
├── 06-canary-report.md     ← ship-workflow-canary
├── 07-deploy-report.md     ← ship-workflow-land
└── README.md               ← /ship 后聚合

docs/bugs/<name>/
├── 01-root-cause.md        ← verify-workflow-debug Phase 1-3
└── 02-fix-plan.md          ← verify-workflow-debug Phase 4
```

## Project Doc Sync 串联

`01-spec.md`、`03-plan.md`、`04-review.md`、`05-ship.md` 必须串起 project doc sync：

- `01-spec.md` → `Documentation Impact`
- `03-plan.md` → `Project Doc Sync Plan`
- `04-review.md` → `Documentation Compliance`
- `05-ship.md` → `Documentation Sync`
