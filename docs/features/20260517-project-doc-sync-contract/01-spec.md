# Project Doc Sync Contract — Spec

## Artifact Type
`artifact_type: software`

可选值：`software` / `document` / `article` / `deck` / `visual`。默认 `software`。

## Goal Alignment
- Source Goal: conversation
- Goal Status: accepted
- Goal Review Score: `11/12`

### One-line Goal
让 Unified 的 skills 在实际运行工作流时，默认把文档写入正确的产物层级，并且只在项目长期真相发生变化时同步对应的项目级文档。

### Done When
- [ ] Functional: `AGENTS.md` 或相关技能合同明确区分 feature docs、bug docs、project docs、root docs 四类产物槽位。
- [ ] Functional: spec 明确 `doc_intent` 决策模型和项目级文档触发条件，不再依赖 agent 临场判断。
- [ ] Functional: spec 明确 `/refine`、`/design`、`/plan`、`/build`、`/review`、`/ship` 各阶段对文档产物和项目级同步的职责。
- [ ] Technical: spec 明确至少一套可实现的校验规则，后续 `./validate` 或 review 可据此落地。
- [ ] Regression: 现有 `docs/features/YYYYMMDD-<name>/...` 主产物链不被打散；`DESIGN.md` 继续作为项目级设计真相。
- [ ] Output: 产出一份可直接进入 `/design` 或 `/plan` 的 `01-spec.md`，供后续修改 `AGENTS.md`、相关 `SKILL.md` 和验证脚本使用。

### Stop Conditions
- [ ] Acceptance 无法验证
- [ ] 需要修改明确排除范围
- [ ] 需要改变 API / 权限 / 数据结构 / 生产配置
- [ ] 实际范围明显大于当前 Goal

## 问题
当前 Unified 已经有比较完整的 feature artifact chain，但“项目级文档是否需要同步、同步到哪个文件、由哪个阶段负责、如何验证兑现”还没有变成明确合同。结果是：

- agent 知道要写 `docs/features/...`，但不知道什么时候必须额外改 `README.md`、`CHANGELOG.md`、`DESIGN.md` 或 `docs/architecture/*`
- 文档同步容易退化为口头约定，缺少固定字段、固定路径和固定责任人
- review/ship 虽然能做人工判断，但无法稳定验证“项目长期真相变化是否已经被同步”
- feature 文档链与 project 文档层的边界仍需要进一步明确，避免要么漏同步、要么到处乱写制造噪音

本次 spec 要解决的不是新增更多文档模板，而是把“文档分层 + 同步触发 + 阶段责任 + 校验方法”固化为 Unified 的工作流合同。

## 选定方案
采用“文档槽位 + Doc Intent + 文件映射 + 阶段责任 + 校验门”的五段式合同。

首先，把运行产物固定归入四类槽位：`root docs`、`project docs`、`feature docs`、`bug docs`。默认所有 feature 工作只写 `docs/features/<feature>/...`；只有当本次变更触发项目长期真相变化时，才允许并要求同步项目级文档。

其次，在 spec 阶段引入 `doc_intent`，只允许 `feature_only`、`feature_plus_project`、`project_only` 三种结果，并在 spec 中列出受影响的项目级文件。随后，在 plan 阶段把这些同步动作收敛成 `Project Doc Sync Plan`，在 review/ship 阶段验证兑现情况。这样既保留现有 feature artifact chain，又把项目级文档同步变成可检查的正式合同。

## External References
- Search status: skipped
- Scan date: 2026-05-17
- Fact:
  - `AGENTS.md` 已定义标准 feature artifact chain：`00-brainstorm.md`、`01-spec.md`、`02-design.md`、`03-plan.md`、`04-review.md`、`05-ship.md`、`06-canary-report.md`、`07-deploy-report.md`、`README.md`。
  - 当前合同已定义 `DESIGN.md` 为 `/design` 同步出的项目级设计真相。
  - 当前 `docs/README.md` 已把 `docs/` 分成 `architecture/`、`features/` 和顶层入口文档三类。
  - `reflect-team-documentation` 已要求项目级文档关注 WHY、README、API 文档和 ADR，但尚未把“每次 feature 是否同步 project docs”变成运行合同。
- Pattern:
  - feature 级工作流记录与 project 级长期真相分层管理，是当前仓库已有方向。
  - “默认写 feature docs，条件触发才同步 project docs”比“每次都全量更新项目文档”更符合低噪音约束。
  - 文档同步要稳定，必须有固定文件映射和阶段 owner，不能只靠自然语言提醒。
- Inference:
  - 应当把项目级文档同步判断前移到 spec/plan，而不是等到 ship 才临时发现。
  - 仅靠 `README`/`AGENTS` 的 prose 规则不够，后续需要 review/validate 读取 spec 中的结构化字段做校验。
- Unknown:
  - `doc_intent` 未来是写在 markdown 固定字段里，还是需要额外 frontmatter/schema，目前未定。
  - `docs/architecture/*` 是否需要进一步细分固定文件名，还是允许一部分按主题扩展，目前未定。
  - `CHANGELOG.md` 是否所有 user-visible change 都强制在 ship 阶段更新，还是仅 release 时更新，需要后续设计收口。
- Adopt:
  - 采用四类文档槽位，保证 agent 先判断文档层级，再决定具体文件。
  - 采用 `doc_intent` + `affected_project_docs` 字段，把项目级同步前置到 spec。
  - 采用固定映射表，把“改什么真相就更新哪个文件”写成合同。
  - 采用阶段责任和 review/ship 校验，避免文档同步沦为非强制建议。
- Reject:
  - 不采用“每次 feature 都强制更新全部项目级文档”，因为噪音过大且容易制造过时信息。
  - 不采用“完全依赖 reviewer 自由裁量判断是否补文档”，因为结果不稳定、难以自动化验证。
  - 不采用“新增独立 docs 流程，和 feature 主链割裂”，因为会打破 Unified 当前按阶段推进的工作模型。

## Scout Review Summary
- CEO: 方向清晰，解决的是长期信息真相和交付噪音的平衡问题。
- Eng: 需要把字段、文件映射和校验责任写死，否则后续实现会再次漂移。
- Design: 此变更不涉及用户界面，但涉及信息架构，需要保证层级清晰、命名稳定、阅读负担低。
- Blocking resolved: 已把“项目级文档最小集合”和“feature vs project 分层”收敛为合同目标。
- Important adopted: 前置 `doc_intent` 判断；固定 `Project Doc Sync Plan`；把 review/ship 作为兑现检查点。
- Suggestions deferred: 是否引入 frontmatter/schema、是否扩展到 bug 流程以外的特殊产物链，延后到 design 阶段再定。

## 未选择的方案
- 方案 A: 每个阶段都允许自由更新任意项目级文档 → 放弃原因：缺少边界，容易造成文档噪音和重复真相。
- 方案 B: 只有 ship 阶段负责全部项目级文档同步 → 放弃原因：发现太晚，容易在实现结束后才暴露缺口。
- 方案 C: 仅在 `reflect-team-documentation` 中补说明，不修改主 workflow 技能 → 放弃原因：无法真正改变运行产物合同，执行仍然不稳定。

## 验收标准
- [ ] spec 明确定义四类文档槽位：
  - root docs: `README.md`、`AGENTS.md`、`CHANGELOG.md`、`DESIGN.md`
  - project docs: `docs/architecture/*.md`
  - feature docs: `docs/features/YYYYMMDD-<name>/*`
  - bug docs: `docs/bugs/<name>/*`
- [ ] spec 明确定义 `doc_intent` 只允许 `feature_only` / `feature_plus_project` / `project_only`
- [ ] spec 明确定义触发 `feature_plus_project` 的条件，至少覆盖：
  - 公共 API / CLI / 使用方式变化
  - 启动 / 安装 / 配置 / 部署 / 环境变量变化
  - 跨 feature 设计 token 或长期设计约束变化
  - 系统边界 / 模块职责 / 依赖方向变化
  - 运行 / 监控 / 安全 / 回滚规则变化
- [ ] spec 明确定义项目级文档映射表，至少覆盖：
  - `README.md`
  - `AGENTS.md`
  - `CHANGELOG.md`
  - `DESIGN.md`
  - `docs/architecture/system-overview.md`
  - `docs/architecture/module-boundaries.md`
  - `docs/architecture/deployment-and-runtime.md`
  - `docs/architecture/observability-and-runbook.md`
  - 可选扩展：`api-contracts.md`、`data-model.md`、`security-boundaries.md`
- [ ] spec 明确定义阶段责任：
  - `/refine` 记录 `doc_intent` 和 `affected_project_docs`
  - `/design` 只同步 `DESIGN.md`
  - `/plan` 产出 `Project Doc Sync Plan`
  - `/build` 按需补 ADR 和项目级 WHY 文档
  - `/review` 检查文档合同是否兑现
  - `/ship` 汇总 project doc sync 和 changelog 状态
- [ ] spec 明确定义后续文档模板最少新增字段：
  - `01-spec.md` 的 `Documentation Impact`
  - `03-plan.md` 的 `Project Doc Sync Plan`
  - `04-review.md` 的 `Documentation Compliance`
  - `05-ship.md` 的 `Documentation Sync`
- [ ] spec 明确定义至少一条强校验规则：
  - spec 声明 `project_truth_changed: yes` 但未同步受影响 project docs 时，review 或 validate 必须失败

## Scope 边界
- **做:** 定义文档分层规则、项目级同步触发条件、文件映射、阶段职责、模板字段和校验方向
- **做:** 约束 skills 运行时的文档产物架构，作为后续改 `AGENTS.md`、相关 `SKILL.md` 和 `./validate` 的输入
- **不做:** 本次 spec 不直接修改任何技能、模板或验证脚本
- **不做:** 本次 spec 不重写现有 `docs/architecture/*` 内容，只定义未来如何接入
- **不做:** 本次 spec 不决定所有项目级文档的最终 prose 模板细节，只定义结构和最小必填字段

## Commands / Tools
- Read contract: `sed -n '1,260p' AGENTS.md`
- Read spec skill: `sed -n '1,260p' skills/define-workflow-spec/SKILL.md`
- Read feature spec template: `sed -n '1,260p' templates/feature/01-spec.md`
- Validate after implementation phase: `./validate`

## Project Structure / Artifact Paths
- 本次 spec 文件：`docs/features/20260517-project-doc-sync-contract/01-spec.md`
- 预期后续修改入口：
  - `AGENTS.md`
  - `skills/define-workflow-spec/SKILL.md`
  - `skills/build-workflow-plan/SKILL.md`
  - `skills/verify-workflow-review/SKILL.md`
  - `skills/ship-workflow-ship/SKILL.md`
  - `skills/reflect-team-documentation/SKILL.md`
  - `templates/feature/01-spec.md`
  - `templates/feature/03-plan.md`
  - `validate` 或相关 `scripts/tests/*`

## Style / Quality Bar
- 合同优先于散文。每条规则必须能映射到明确的文件、字段、阶段或校验点。
- 不写“需要更新文档”这类空泛措辞；必须指向具体文档路径。
- 尽量延续 Unified 现有命名和产物链，不引入与当前结构竞争的新目录。
- 默认低噪音：未触发长期真相变化时，不制造项目级文档更新。

## Verification Strategy
- 当前回合验证：
  - 读取现有 `AGENTS.md`、spec 技能和模板，确认本 spec 与现有产物链兼容。
  - 检查 spec 是否覆盖目标、槽位、触发条件、文件映射、阶段责任、模板字段和校验方向。
- 后续实现阶段验证：
  - 运行 `./validate`
  - 用至少一个 feature case 验证 `doc_intent: feature_only`
  - 用至少一个 feature case 验证 `doc_intent: feature_plus_project`
  - 在 `review` 阶段故意制造“spec 要求同步 project docs 但未更新”的负例，确保能被拦截

## Boundaries
- **Always:** 保留现有 `docs/features/...` 主产物链；保留 `DESIGN.md` 的项目级定位；在修改技能前同步更新相关模板和校验逻辑。
- **Ask first:** 若需要新增全新的项目级目录、引入 frontmatter/schema、改变 `CHANGELOG.md` 更新策略、或让 bug 流程共享同一套字段。
- **Never:** 不把所有 feature 都强制同步全部项目级文档；不允许“project docs required”但不指明具体文件；不允许新规则与 `AGENTS.md` 主产物链冲突。

## Success Criteria
- 后续 implementer 可以仅凭此 spec，清楚知道应在哪些文件写入哪些规则。
- 后续 reviewer 可以仅凭此 spec，判断文档同步相关实现是否完整。
- 新合同落地后，agent 对“这次变更只写 feature docs 还是还要同步 project docs”有稳定、一致、可验证的答案。

## Risks and Mitigations
| 风险 | 概率 | 影响 | 应对方案 |
|------|------|------|---------|
| 规则太抽象，后续实现者各自理解 | 中 | 高 | 在 spec 中写死槽位、字段、映射表和阶段 owner |
| 引入过多字段，增加普通 feature 负担 | 中 | 中 | 默认 `feature_only`，只在触发长期真相变化时要求额外同步 |
| 只改文档不改校验，合同再次漂移 | 高 | 高 | 在验收标准中明确 review/validate 的强校验要求 |
| `docs/architecture/*` 文件命名仍不稳定 | 中 | 中 | 先列最小固定文件集合；设计阶段再决定是否允许扩展主题文档 |
| `CHANGELOG.md` 触发条件和 release 纪律冲突 | 低 | 中 | 在后续 design 阶段单独收口 user-visible change 的定义 |

## Open Questions
- `Documentation Impact` 等新增字段是用固定 markdown 小节，还是引入 frontmatter / 结构化 schema？
- `docs/architecture/*` 是否要在本轮一起补齐最小文件骨架，还是先只定义规则？
- `CHANGELOG.md` 的更新触发是“每次 user-visible change”还是“每次正式 release”？
