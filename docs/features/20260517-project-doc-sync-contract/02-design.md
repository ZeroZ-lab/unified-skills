# Project Doc Sync Contract — Design

## Artifact Type
artifact_type: software

## Design Requirement
- Design Status: required
- Reason: 本 feature 的用户可感知产物不是 UI，而是 agent 实际生成的文档模板。模板结构、字段完整性、证据链和阅读路径都属于设计决策，必须在 `/plan` 前锁定。
- Design Track: 内容结构 / 信息架构 / 企业级文档模板设计
- DESIGN.md Sync: skipped。本轮不引入项目级视觉 token、品牌规范或跨 feature UI 组件。

## Design References
- Scan Date: 2026-05-17
- Search Status: local-only
- Enterprise Product Patterns:
  - 当前仓库的 feature artifact chain：`01-spec.md` → `02-design.md` → `03-plan.md` → `04-review.md` → `05-ship.md`
  - `docs/README.md` 对 `architecture/`、`features/`、顶层入口文档的分层约定
  - 现有高质量文档样本：`docs/features/20260515-context-runtime/02-design.md`
- Official Systems / Platform Rules:
  - `AGENTS.md` 对标准产物链、项目级 `DESIGN.md`、`docs/features/`、`docs/bugs/` 的路径约束
  - `skills/design-workflow-design/SKILL.md` 对 `02-design.md` 必填证据段落的硬门要求
  - `templates/feature/02-design.md` 的基础骨架
- Methods / Theory / Style Schools:
  - Progressive disclosure：摘要先行，细节后置，避免首屏信息噪音
  - Enterprise writing：决策、责任、风险、验证四段式比散文描述更适合协作
  - Information architecture：固定槽位、稳定标题、强制必填字段，有助于 agent 和 reviewer 稳定消费
- Anti-patterns / Verification:
  - 文档模板写成“作文”而不是“合同”
  - 模板混入实现步骤、Task N、命令清单，导致 design/plan/build 边界塌陷
  - 模板没有 Required / Optional 区分，导致所有文档无限膨胀
  - 模板缺少 reviewable fields，导致 reviewer 无法判断是否完成
- Local Project Truth:
  - Unified 的核心问题不是“有没有模板”，而是“skills 跑工作流时能不能稳定地产生正确层级的文档”
  - 当前需要覆盖的重点是 feature 级文档和 project-level doc sync，而不是重写所有 prose
  - 这轮 design 的实现目标是后续修改 `templates/feature/*.md`、相关 `SKILL.md` 和校验逻辑

## Pattern Synthesis
- Repeated Patterns:
  - 高质量 workflow 文档都需要固定骨架：目标、输入、决策、边界、验证、风险、输出
  - 企业级模板普遍强调“给 reviewer 的可检查字段”，而不是只给作者写作提示
  - feature 级文档和 project 级文档需要不同模板哲学：前者强调变更证据链，后者强调长期真相
- Conflicting Patterns:
  - 过度详细模板可以提高一致性，但会让简单任务负担过重
  - 过于精简模板可以降低负担，但会让 agent 在关键字段上自由发挥，导致漂移
- Local Constraints That Override External Patterns:
  - Unified 已有固定产物链，不能为了“最佳实践”重新发明另一套目录
  - `02-design.md` 必须保持 evidence-first，不写实现细节
  - 模板需要让 agent 和 human partner 都能快速扫描，而不是只服务单一读者

## Design Inferences
- Inference 1:
  - Based on: 现有仓库所有强合同文档都依赖固定标题和稳定路径
  - Implication: 每个模板都必须分成“固定必填区”和“按需扩展区”，标题命名不可随意变体
- Inference 2:
  - Based on: review/validate 未来要对文档同步做强校验
  - Implication: 模板里必须出现结构化可检查字段，例如 `doc_intent`、`affected_project_docs`、`Documentation Compliance`
- Inference 3:
  - Based on: 企业级文档的核心是协作，而不是作者个人表达
  - Implication: 模板应优先包含 owner、status、decision、verification、risk、rollback 等协作字段
- Inference 4:
  - Based on: 简单 feature 不应该被文档噪音拖死
  - Implication: 模板必须明确 Required / Conditional / Optional 区段，避免“每次都写满”
- Unknowns / Evidence Gaps:
  - 是否需要统一 frontmatter，目前未定
  - `docs/architecture/*` 是否一次性建全空模板，目前未定

## Adopt / Reject
- Adopt:
  - Sectioned enterprise templates — Source Layer: Methods / Theory; Reason: 适合多人协作、代码审查和后续自动校验
  - Summary-first opening block — Source Layer: Enterprise Product Patterns; Reason: 让 reviewer 先看到状态、范围、结论，再下钻细节
  - Required / Conditional / Optional separation — Source Layer: Anti-patterns / Verification; Reason: 兼顾完整性和低噪音
  - Doc-specific quality gates — Source Layer: Local Project Truth; Reason: 每类文档用途不同，不能只靠一个通用模板
  - Project-doc mapping fields — Source Layer: Local Project Truth; Reason: 本 feature 的核心就是把“该改哪个项目级文档”写成合同
- Reject:
  - Narrative-only templates — Source Layer: Anti-patterns; Reason: 可读但不可验证，不适合 workflow contract
  - One huge universal template for all docs — Source Layer: Anti-patterns; Reason: 会失去各阶段文档的专用职责
  - Implementation steps inside design/review templates — Source Layer: Official Systems; Reason: 破坏阶段边界
  - Full corporate ceremony for every simple task — Source Layer: Local Project Truth; Reason: 会让 agent 为了填表而填表

## Design Evidence Quality
- [x] Sources are grouped by source layer
- [x] Key decisions trace to sources or Local Project Truth
- [x] Adopt / Reject is explicit
- [x] Search unavailable or evidence gaps are recorded
- [x] No external pattern is copied blindly

## 设计目标
- 让每类 workflow 文档在首屏就回答“这是什么、状态如何、该看什么”
- 让 agent 生成的文档天然适合 reviewer、approver 和 implementer 消费
- 让项目级文档同步从“记得补一下”变成“模板显式要求 + 审查显式检查”
- 让简单任务不被模板负担压垮，让高风险任务又有足够证据密度

## 关键决策
- 决策 1: 每类文档使用专用模板，不搞一个万能模板
- 决策 2: 所有模板采用“三层字段”设计：Required / Conditional / Optional
- 决策 3: feature 级文档优先服务“变更证据链”，project 级文档优先服务“长期真相”
- 决策 4: `01-spec.md`、`03-plan.md`、`04-review.md`、`05-ship.md` 必须显式承载 project doc sync 信息
- 决策 5: project-level docs 采用“短入口 + 长正文”的企业结构，避免 README / architecture 文档失控膨胀

## 设计边界
- **做:** 定义每类文档模板的章节结构、首屏摘要、必填字段、条件字段、质量门和不该写的内容
- **不做:** 不在本设计中编写实现步骤、任务拆分、修改脚本或决定 release sequence
- **不做:** 不定义具体 prose 文案示例的最终措辞风格，只定义模板结构和字段职责

## 设计批准标准
- [ ] 每类核心文档都有明确模板哲学和固定章节
- [ ] feature docs 与 project docs 的模板边界清楚
- [ ] project doc sync 的必填字段已经嵌入相关模板
- [ ] 模板支持后续 review/validate 做结构化校验
- [ ] 没有把实现步骤写进设计稿

## 实施前置条件
- [ ] 确认本设计覆盖的模板范围：`01-spec.md`、`02-design.md`、`03-plan.md`、`04-review.md`、`05-ship.md` + 必要的 project-level docs
- [ ] 确认 project-level docs 的最小固定文件集合
- [ ] 确认后续是否用 markdown 固定标题还是 frontmatter 承载结构化字段

---

## 按类型填写

### software + UI
- 用户目标: 不适用，本轮对象不是 UI
- 关键流程: 不适用
- 页面 / 组件结构: 不适用
- 状态设计（loading / empty / error / edge cases）: 不适用
- 视觉方向: 不适用
- 不做清单: 不产出视觉稿，不设计界面组件

---

## 文档模板体系设计

### 总体设计原则
- **企业级首屏**: 每个文档开头必须先有状态摘要，而不是直接进入正文
- **固定章节名**: 便于 agent、reviewer、validate 稳定定位
- **字段可检查**: 能做 review/validate 的字段不用藏在自然语言里
- **按需展开**: 用 conditional 区段承载高风险或特定场景内容
- **职责单一**: 一个文档只回答该阶段最核心的问题

### 模板层级
- **Tier 1: Feature workflow templates**
  - `01-spec.md`
  - `02-design.md`
  - `03-plan.md`
  - `04-review.md`
  - `05-ship.md`
- **Tier 2: Feature support templates**
  - `plans/*.md`
  - `adr/*.md`
  - `06-canary-report.md`
  - `07-deploy-report.md`
  - `docs/bugs/*`
- **Tier 3: Project-level templates**
  - `README.md`
  - `AGENTS.md`
  - `CHANGELOG.md`
  - `docs/architecture/*.md`

## 文档模板设计明细

### 1. `01-spec.md` — Enterprise Spec Template
**模板哲学**
- 决定做什么、为什么做、做到什么算完成
- 把隐藏假设、文档影响、范围边界前置暴露

**首屏摘要块**
- Feature name
- `artifact_type`
- Goal status
- `doc_intent`
- `project_truth_changed`
- Owner / Date / Status

**Required sections**
- Objective
- Goal Alignment
- Documentation Impact
- Commands / Tools
- Project Structure / Artifact Paths
- Verification Strategy
- Boundaries
- Success Criteria
- Risks and Mitigations

**Conditional sections**
- External References
- Open Questions
- Non-goals / Explicit Exclusions

**新增关键字段**
- `doc_intent: feature_only | feature_plus_project | project_only`
- `project_truth_changed: yes | no`
- `affected_project_docs:`
- `rationale:`

**质量门**
- 没有 `Success Criteria` 不可批准
- `project_truth_changed: yes` 但没有 `affected_project_docs` 不可批准
- 不能把实现任务分解写进 spec

### 2. `02-design.md` — Enterprise Design Template
**模板哲学**
- 记录设计证据、方向、取舍，而不是实现方法
- 让 human partner 明确批准“创作方向”

**首屏摘要块**
- Design status
- `artifact_type`
- Design track
- Search status
- User approval status

**Required sections**
- Design References
- Pattern Synthesis
- Design Inferences
- Adopt / Reject
- Design Evidence Quality
- Design Goals
- Key Decisions
- Design Boundaries
- Approval Criteria

**Conditional sections**
- Alternatives
- Preview / mockup record
- DESIGN.md Sync summary

**质量门**
- 缺 Sources / Patterns / Adopt / Reject 不可批准
- 不能写 Task breakdown
- 不能把技术实现细节塞进设计稿

### 3. `03-plan.md` — Enterprise Execution Plan Template
**模板哲学**
- 把“怎么做”收敛为可执行切片，同时明确文档同步动作归谁做

**首屏摘要块**
- Plan status
- Scope size
- Execution mode: serial / parallel / gated-parallel
- Risk level
- `Project Doc Sync Plan` status

**Required sections**
- Scope Summary
- Assumptions
- Execution Topology
- Task breakdown
- Dependencies
- Verification checkpoints
- Project Doc Sync Plan

**Conditional sections**
- Parallel Execution Matrix
- Rollback / Migration checkpoint
- Release coordination notes

**Project Doc Sync Plan 必含字段**
- Must update
- Optional update
- Stage owner
- Verification method
- Deferred docs with reason

**质量门**
- 任务太大、无依赖关系、无验收条件则不通过
- spec 要求同步 project docs，但 plan 没写 owner / verification，不通过

### 4. `04-review.md` — Enterprise Review Template
**模板哲学**
- 先判断需求有没有实现，再判断实现质量好不好
- 把文档同步也纳入审查对象，而不是只看代码

**首屏摘要块**
- Review verdict
- `artifact_type`
- Stage 1 status
- Stage 2 status
- Blocking count / Important count
- Documentation compliance status

**Required sections**
- Artifact Context
- Stage 1: Spec Compliance
- Stage 2: Code Quality / Content Quality / Visual Quality
- Findings Summary
- Documentation Compliance
- Verdict

**Conditional sections**
- Security / Performance / Accessibility specialist review
- Deferred risks
- Follow-up review requirements

**Documentation Compliance 必含字段**
- Feature artifact chain complete: PASS / FAIL
- Project doc sync required by spec: yes / no
- Required project docs updated: PASS / FAIL
- Missing sync

**质量门**
- 没做两阶段审查不通过
- spec 声明要同步 project docs，但 review 没检查，不通过
- 没有 severity 分类不通过

### 5. `05-ship.md` — Enterprise Ship Template
**模板哲学**
- 记录发布决策、交付状态、文档同步是否收口
- 对 software 来说是 Go/No-Go 记录，对非 software 是交付记录

**首屏摘要块**
- Release status
- Version / Date
- Go / No-Go
- Rollback ready
- Changelog status
- Documentation sync status

**Required sections**
- Basic release information
- Pre-ship checks
- Audit results
- Go / No-Go
- Documentation Sync
- Next step

**Conditional sections**
- Staging validation
- Export verification
- Canary trigger
- Deploy handoff

**Documentation Sync 必含字段**
- Updated project docs
- Deferred project docs
- `CHANGELOG.md` updated: yes / no
- README verified: yes / no

**质量门**
- 没回滚计划不通过
- user-visible change 但 changelog 状态不明，不通过
- review 要求的 project docs 没同步完，不通过

### 6. `README.md` — Enterprise Project Entry Template
**模板哲学**
- 给首次接手者看的短入口文档，不承载长篇机制解释

**固定结构**
- What this project is
- Quick start
- Core commands
- Project structure
- Key conventions
- Deploy / release entry points
- Where to read more

**不该承载**
- 长篇历史
- feature 过程记录
- 大段 architecture 细节

### 7. `AGENTS.md` — Enterprise Agent Contract Template
**模板哲学**
- 这是 agent 的运行宪章，不是 README 的副本

**固定结构**
- AI-agent specific warnings
- Context runtime / routing
- Canon / boundaries
- Output chain
- Verification
- Hard constraints for editing skills

**新增设计要求**
- 在相关章节显式定义文档槽位和 project doc sync contract
- 保持短入口，避免再把全部 docs 体系塞回 `CLAUDE.md`

### 8. `CHANGELOG.md` — Enterprise Release Notes Template
**模板哲学**
- 面向用户可感知变化，不面向内部重构细节

**固定结构**
- Version + date
- Added
- Changed
- Fixed
- Deprecated
- Security

**质量门**
- 不写纯内部重构
- 同一发布条目内用用户语言描述影响

### 9. `docs/architecture/*.md` — Enterprise Architecture Template Family
**模板哲学**
- 长期真相、WHY、边界、运行规则

**推荐固定家族**
- `system-overview.md`
  - Goals
  - System boundaries
  - Core components
  - Non-goals
- `module-boundaries.md`
  - Modules
  - Responsibilities
  - Allowed dependencies
  - Forbidden crossings
- `deployment-and-runtime.md`
  - Environments
  - Config
  - Deploy flow
  - Rollback entry
- `observability-and-runbook.md`
  - Signals
  - Alerts
  - Debug entry points
  - Incident actions
- Optional:
  - `api-contracts.md`
  - `data-model.md`
  - `security-boundaries.md`

**共同质量门**
- 必须写“当前真相”而不是 feature 历史
- 必须区分 stable rules 和 historical notes
- 避免和 README / feature docs 重复

## 文档模板不做清单
- 不做一个万能 super-template
- 不要求所有简单 feature 写满全部 optional 区段
- 不把 review / ship 里的检查项提前塞进 spec prose 里重复三遍
- 不把 architecture 文档写成 release 日志
- 不让 README 承担 feature artifact archive 的职责
