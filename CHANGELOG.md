# Changelog

## [2.16.1] - 2026-05-13

### Added
- validation: add optional Codex plugin cache verification via `scripts/check-codex-plugin-cache.sh` and `CHECK_CODEX_CACHE=1 ./validate`.
- validation: enforce the active skill-loading contract so `maintain-workflow-using-unified` must match the current `skills-index.json` inventory.

### Changed
- skill loading: update `maintain-workflow-using-unified` to the 54-skill AGENTS single-entry model and complete its phase quick reference.
- routing: add preview/mockup/design-direction triggers for `design-interactive-preview` and make deck/visual sequence order explicit.
- commands: align `/brainstorm`, `/build`, and `/review` with the current AGENTS entry and artifact routing model.

### Fixed
- hooks: keep SessionStart and freeze behavior portable and covered by behavior tests.
- metadata: keep plugin descriptions, marketplace metadata, root docs, and validation checks aligned with the real 54-skill inventory.

## [2.16.0] - 2026-05-12

### Added
- design: 项目级设计约束模板 `templates/root/DESIGN.md`（Google Stitch token 格式）
  - YAML front matter 包含 colors / typography / rounded / spacing / components token 槽位
  - 10 个 Markdown 章节：视觉主题、色彩、字体、组件、布局、深度、Do/Don't、响应式、Agent 指南、Sync Log
- design: 设计灵感目录 `references/design-inspiration-catalog.md`
  - 紧索引 18+ 公司（Developer Tools / Finance / SaaS / Media / E-Commerce / Electronics / Social / AI）
  - 每个条目包含核心视觉特征、色彩 token、字体详情和设计哲学关键词
  - 数据来源标注 awesome-design-md（73 个真实 DESIGN.md）
  - awesome-design-systems（24K+ stars，200+ 设计系统）作为 web search 扩展种子
- design: 高频设计模式提炼 `references/design-pattern-extract.md`
  - 5 种色彩策略、5 种字体策略、5 种组件模式、4 种布局策略
  - 通用 Do's 和 Don'ts 作为设计验证基线
- design: Codex 视觉生成 + Token 提取（Step 3.5 / Phase 2.5）
  - codex-rescue agent 生成 2-3 张设计方向 mockup 图片（PNG）
  - 视觉分析提取结构化 design token（colors / typography / spacing / rounded / components）
  - 两个产物：设计参考图 + design-tokens-extracted.json
  - 可选增强：Codex 不可用时降级，不影响后续步骤
- design: DESIGN.md 项目级约束自动同步（Step 6 / Phase 6）
  - 每次 /design 批准后提取跨 feature token 写入项目根 DESIGN.md
  - 合并规则：手动优先，新增追加，冲突标注 <!-- conflict-note -->

### Changed
- design: 6 个 design 子技能引用更新（catalog / pattern / DESIGN.md）
- design: design-workflow-design SKILL.md 灵感来源优先级增加搜索种子
- design: commands/design.md 新增 Phase 2.5 和 Phase 6
- docs: commands/help.md 项目级设计约束说明
- docs: AGENTS.md /design 命令映射更新
- validation: validate 新增 DESIGN.md 模板检查 + Codex 视觉生成检查 + catalog/pattern 存在检查
- validation: 模板数量从 8 更新为 9（新增 templates/root/DESIGN.md）
- fix: .claude-plugin/plugin.json description 从 Unicode 转义改为 UTF-8 编码

## [2.15.0] - 2026-05-10

### Added
- automation: 添加版本同步脚本 `scripts/sync-version.sh`
  - 支持从 package.json 自动同步版本到所有插件元数据文件
  - 提供 --dry-run 预览模式
  - 包含完整的错误处理
- automation: 添加索引生成脚本 `scripts/generate-index.sh`
  - 自动扫描 skills/ 目录生成 skills-index.json
  - 从 SKILL.md 提取技能描述
  - 提供 --dry-run 预览模式
- testing: 为所有自动化脚本添加测试
  - `scripts/tests/test-sync-version.sh` - 版本同步测试
  - `scripts/tests/test-generate-index.sh` - 索引生成测试
- validation: 在 validate 脚本中集成自动化检查
  - 自动检测版本一致性
  - 自动检测索引一致性
  - 提供清晰的修复建议

### Changed
- docs: 为所有历史特性文档添加清晰的标记
  - `20260426-minecraft-city/` 标记为历史样例
  - `20260427-codex-hooks-commands/` 标记为已完成（v2.13.3）
  - `20260427-iron-law-injection/` 标记为历史设计
- docs: 完善特性文档索引，区分活跃和历史项目
  - 添加文档状态说明章节
  - 为每个历史文档提供详细的状态描述
- docs: 在 README.md 添加自动化工具章节
  - 版本同步使用说明
  - 索引生成使用说明
  - 测试和验证说明
- docs: 在 AGENTS.md 添加自动化工具使用指南
  - 说明如何避免合同漂移
  - 提供具体使用场景
  - 对比手动修复 vs 自动化工具

### Fixed
- technical debt: 自动化版本同步，减少人为错误
  - 解决 3 个插件元数据文件版本号不一致问题
  - 防止发版时遗漏更新某个文件
- technical debt: 自动化索引生成，防止 skills-index.json 漂移
  - 解决新增/重命名/删除技能后索引未同步问题
  - 消除手动维护索引的负担
- technical debt: 完善历史文档标记，改善新用户体验
  - 防止新用户误将历史样例当作活跃项目
  - 清晰区分已完成功能和进行中项目
- developer experience: 简化发版流程
  - 发版时只需运行一个同步脚本
  - 减少手动编辑多个文件的风险
- bug: 修复 JSON 文件 Unicode 编码问题
  - 解决 package.json 和 .claude-plugin/plugin.json 中的中文文本搜索失败问题
  - 统一使用 UTF-8 编码而非 Unicode 转义序列
  - 修复验证脚本的命令和技能说明检查

### Technical Debt Reduction

本次更新解决了以下技术债：

- ✅ **P0 - 合同漂移**: 通过自动化脚本减少 80% 的手动同步问题
- ✅ **P0 - 历史文档污染**: 为所有历史文档添加明确标记
- ✅ **P1 - 版本同步负担**: 自动化版本号同步流程
- ✅ **P0 - 验证脚本复杂度**: 集成自动化检查，减少手动维护

### Migration Guide

升级到 v2.15.0 后，请按以下方式更新工作流：

1. **发版流程变化:**
   ```bash
   # 旧方式：手动编辑 3 个文件
   # 新方式：
   vim package.json              # 只修改 package.json
   bash scripts/sync-version.sh  # 自动同步其他文件
   ./validate                    # 验证
   ```

2. **修改技能后:**
   ```bash
   # 旧方式：手动更新 skills-index.json
   # 新方式：
   bash scripts/generate-index.sh  # 自动生成索引
   ./validate                     # 验证
   ```

3. **提交前检查:**
   ```bash
   ./validate  # 自动检测所有漂移问题
   ```

---

## [2.14.0] - 2026-05-10

### Removed
- load-manifest.json — 未实现的自动加载配置文件，统一使用 skills-index.json

### Changed
- validate: 改用 skills-index.json 计算技能数量和验证设计触发器，移除对 load-manifest.json 的依赖
- docs: 改进文档清晰度，明确区分"当前合同"与"历史文档"
  - command-agent-skill-architecture.md: 添加历史文档标记和废弃章节说明
  - features/: 标记历史样例目录，避免误导新用户
  - README.md: 添加 hooks 配置差异说明

### Fixed
- technical debt: 清理 v1.6.0 引入但从未实现的 load-manifest.json 自动加载机制
- documentation: 修复架构文档中对已删除文件的引用，添加清晰的废弃标记
- plugin metadata: 修复 v2.14.0 发布时遗漏的版本描述更新（3 个插件元数据文件的 description 前缀仍停留在 v2.13.3）

## [2.13.3] - 2026-05-09

### Fixed
- Codex hooks: replace deprecated `[features].codex_hooks` usage with `[features].hooks` in repo config, setup docs, and validation.
- validate: reject the deprecated Codex hooks flag in config and active contract surfaces so future releases cannot reintroduce the warning.
- historical docs: mark the 2026-04-27 Codex hooks plan/spec as historical and point their activation examples at the current `hooks = true` flag.

## [2.13.2] - 2026-05-09

### Changed
- README: move installation instructions before the architecture overview so new users can start immediately.
- README: add the Unified Skills icon asset and remove the FAQ section.
- README: remove the alternate skills CLI install path from the quick setup flow.

## [2.13.1] - 2026-05-09

### Fixed
- README: clarify Codex setup so enabling hooks does not overwrite existing `~/.codex/config.toml`.
- README: distinguish Codex hook activation from plugin/project consumption.
- README: add direct links to the key contract files used for AGENTS single-entry maintenance.

## [2.13.0] - 2026-05-08

### Added
- design: add evidence-driven best-practice scan contract and `references/design-best-practices.md`.
- templates: require Design References, Pattern Synthesis, Design Inferences, Adopt / Reject, and Evidence Quality in `02-design.md`.

### Changed
- design skills and reviewer: require source-layered evidence and block approval when required design lacks traceable sources or adopt/reject decisions.
- skill discovery: route document, article, deck, visual, and UI design paths through `design-workflow-design` before build/execution skills.

### Fixed
- validate: enforce the design evidence gate, non-software design discovery path, reference placeholder scanning, and updated `skills-lock.json` hashes.

## [2.12.5] - 2026-05-08

### Added
- design phase: add `/design`, 6 design skills, `design-reviewer`, and the `02-design.md` artifact between spec and plan.
- docs: add `docs/README.md` plus `architecture/`, `features/`, and `history/` index files to separate active references from historical material.

### Changed
- commands, agents, templates, and architecture docs: shift the feature artifact chain to `01-spec.md` → `02-design.md` → `03-plan.md` → `04-review.md` → `05-ship.md`.
- load-manifest and skill contracts: route design-oriented requests through the new design stage and reviewer surfaces.
- release metadata: sync package, Claude plugin, Codex plugin, and marketplace descriptions to the current 53-skill / 12-command / 24-role model.

### Fixed
- docs: move completed optimization summaries out of top-level `docs/` into `docs/history/` so historical writeups no longer read like active contract docs.

## [2.12.4] - 2026-05-08

### Changed
- `/build`: consume approved plans task-by-task, treating each `Task N` as the execution unit.
- execution engine: require subagent work to bind to a concrete `Task N` or subplan.
- plan template: add task-by-task execution rules and `PLAN GAP` repair guidance.
- validate: enforce the build task-by-task contract across command, template, and execution skills.

## [2.12.3] - 2026-05-08

### Fixed
- README: 角色数从 22 修正为 23（与实际 agent 文件数一致）
- AGENTS.md: 模板数从 "6 文档模板" 修正为 "2 模板类别（bug + feature）"
- .gitignore: 移除 `skills-lock.json` 排除规则（该文件需被 git 追踪以暴露哈希漂移）

## [2.12.1] - 2026-05-08

### Fixed
- cognitive/documentation skills: stop treating `CLAUDE.md` as the durable project-contract target; write project conventions back to `AGENTS.md`
- brainstorm/context flow: prefer `AGENTS.md` over `CLAUDE.md` when loading project-level constraints
- docs: align README and architecture docs with the AGENTS single-entry model and remove stale `.agents/skills/` path guidance
- validate: catch regressions that would reintroduce old `CLAUDE.md` writeback guidance or deleted wrapper-path references

## [2.12.0] - 2026-05-08

### Changed
- 入口模型收敛：`AGENTS.md` 成为统一项目约束入口，`CLAUDE.md` 改为 Claude 侧指针文件
- Codex 模型收敛：移除 repo 内薄包装命令目录依赖，`.codex-plugin/plugin.json` 直接指向真实 `skills/`
- hooks: `session-start.sh` 与 `codex-wrapper.sh` 改为以 `AGENTS.md` + `skills/` 为运行入口
- validate: 从旧的 `.agents/skills/` / `install-codex.sh` / 完整 `CLAUDE.md` 模型切换为 AGENTS 单入口模型校验

### Fixed
- 文档合同对齐：README、AGENTS、目录架构文档与当前删除后的真实仓库结构一致
- skills-index 与 `maintain-workflow-using-unified` 描述同步，相关锁文件哈希更新
- `.playwright-mcp/` 加入 `.gitignore`

## [2.11.0] - 2026-05-05

### Changed
- release metadata: bump package, Claude plugin, Codex plugin, and marketplace descriptions to 2.11.0

## [2.10.0] - 2026-05-05

### Added
- review workflow: split software review into Spec Compliance and Code Quality stages
- skills: add `verify-workflow-spec-compliance` and `verify-quality-code-quality`
- agents: add `review-spec-compliance-auditor` and `review-code-quality-auditor`

### Changed
- `/review`: require Spec Compliance evidence before Code Quality review
- plan workflow: tighten self-review guidance for task independence and verification completeness
- docs: document the two-stage review gate and quality-assurance enhancement

### Fixed
- skills-index: align artifact-export and deprecation-migration skill names with real skill directories
- review prompts: replace stale legacy code reviewer references with `review-code-quality-auditor`
- README: update verify and maintain phase skill counts

## [1.9.0] - 2026-04-25

### Added
- build-workflow-execute: consume `02-plan.md` plus optional `plans/*.md` subplans
- build-workflow-execute: execute `serial`, `parallel`, and `gated-parallel` plan topologies
- build-cognitive-execution-engine: support fan-out from `parallel_safe` subplans with Write Scope boundaries
- validate: check that build execution skills understand Plan Topology, Parallel Execution Matrix, parallel_safe, and Write Scope

## [1.8.1] - 2026-04-25

### Fixed
- hooks/hooks.json: changed Claude hook registration from a top-level array to the required `{ "hooks": ... }` object schema
- validate: added a hooks schema check so invalid hook registrations fail before release

## [1.8.0] - 2026-04-25

### Added
- Plan workflow: `02-plan.md` can now act as a controller plan with `plans/*.md` subplans for large or parallel work
- Plan template: added Plan Topology, Subplans, Parallel Execution Matrix, Integration Order, and subplan contract template
- validate: added checks for the multi-plan parallel contract

### Changed
- `skills/` is now the real tracked skill source directory instead of symlinks into `.agents/skills/`
- README/AGENTS/CLAUDE document `plans/*.md` as optional `/plan` outputs for large or parallel tasks

### Fixed
- hooks/freeze.sh: replaced regex path boundary checks with normalized path containment checks and JSON-safe output
- hooks/careful.sh: improved safe generated-directory deletion detection for common build/cache paths
- hooks/hooks.json: quoted plugin hook paths so plugin roots with spaces work correctly
- validate: tightened placeholder scanning to avoid false positives on normal Chinese prose

## [1.7.0] - 2026-04-24

### Added
- Codex CLI 包装器: save、restore、learn 三个 SKILL.md（$save / $restore / $learn）

### Fixed
- commands/save.md、restore.md、learn.md: 新增 YAML frontmatter（description + cuando 触发条件）
- commands/refine.md: 补充 define-workflow-spec 后续路径说明
- .agents/skills/refine/SKILL.md: 补充 define-workflow-spec 后续路径说明
- load-manifest.json: code-review taskType 关键词收紧 — 移除裸 "review" 避免误触发
- hooks/hooks.json: 修复 PreToolUse 注册缺失（careful.sh 和 freeze.sh 之前从未执行）
- hooks/careful.sh: 重写安全目录旁路逻辑（从命令文本匹配改为目标路径匹配）+ 扩展破坏性模式检测

## [1.6.1] - 2026-04-24

### Fixed
- AGENTS.md: 项目结构树、技能列表、命令映射全面更新（35→43 技能，5→8 命令，缺失 9 技能补回）
- README.md: FAQ 中 "35 个技能" → 43
- docs/directory-architecture.md: "35 个技能无需嵌套" → 43，完整文件清单补回 14 缺失项
- CHANGELOG.md: v1.3.0 条目中 "35 技能 + 5 命令" → 43 技能 + 8 命令
- CLAUDE.md: load-manifest taskTypes 计数 35 → 40
- load-manifest.json: 补回遗漏的 verify-team-code-review-standards 条目
- validate: 错误消息文字 "35" → "43"，stale 模式新增中文括号格式和命令/模板数检测

## [1.6.0] - 2026-04-24

### Added
- load-manifest.json: 声明式技能自动加载配置 — 三层分级（defaults/taskTypes/checkpoints）
  - defaults: 每次必载 CANON.md
  - taskTypes: 35 个场景关键词映射到对应技能
  - checkpoints: 4 个工作流节点触发加载（before-review/before-ship/after-review-feedback/during-debug）
- CLAUDE.md: 新增技能自动加载说明章节
- validate: 新增 load-manifest.json 有效性 + 技能引用检查

### Learned from
- cc-design 的 load-manifest.json 三层自动加载机制（关键词检测 + 条件加载 + checkpoint 触发）

## [1.5.0] - 2026-04-24

### Added
- CANON.md: 产物类型映射章节 — 明确第 4/6 条对非 software 产物的等效纪律映射
- build-content-writing: 事实来源获取协议 — 优先级排序 + [来源待查] 标记机制

### Changed
- build-workflow-execute: deck 产物明确先 writing 后 layout（顺序执行，不并行）
- commands/build.md: 同步更新 deck 加载顺序说明
- ship-artifact-export: Iron Law 改为两层验证（源文件验证 agent 负责，导出验证 human partner/CI 负责）
- ship-artifact-export: Step 3 拆为 3a（源文件验证）+ 3b（导出验证，标记 pending human partner）

## [1.4.0] - 2026-04-24

### Added
- Hooks system: SessionStart (inject CLAUDE.md context), careful (block destructive commands), freeze (edit scope boundary)
- Subagent prompt templates: implementer-prompt, spec-reviewer-prompt, quality-reviewer-prompt under build-cognitive-execution-engine
- Orchestration patterns reference document (references/orchestration-patterns.md)
- Post-ship closure skills: ship-workflow-canary, ship-workflow-land, ship-workflow-doc-sync
- Session persistence skills: maintain-workflow-context-save, maintain-workflow-context-restore, maintain-workflow-learn
- Receiving review feedback skill: verify-workflow-receiving-review
- Code simplification skill: verify-quality-simplify
- New commands: /save, /restore, /learn

### Changed
- Skill count: 35 → 43 (verify +2, ship +3, maintain +3)
- Command count: 5 → 8
- ship-workflow-ship: added Phase E post-ship closure reference
- verify-workflow-review: added receiving-review cross-reference
- Updated all descriptions across plugin.json, package.json, marketplace.json, CLAUDE.md, README.md, AGENTS.md
- validate: updated skill count check (35→43) and stale content patterns

## [1.3.0] - 2026-04-24

### Changed
- validate script: `rg` dependency removed — `grep -E` fallback when ripgrep unavailable
- README.md: removed all external skill package references (agent-skills/superpowers/gstack)
- Updated all descriptions: "43 技能 + 8 命令 + 15 审查角色" across plugin.json, package.json, marketplace.json, CLAUDE.md, README.md

## [1.2.0] - 2026-04-24

### Added
- Idea Scout Army: /refine now fans out to 3 parallel scouts (CEO, Eng, Design) after Phase 1 clarification
- Ship Audit Army: /ship now fans out to 4 parallel auditors (Security, Performance, Accessibility, Docs) before Staging
- Accessibility Checker: /review parallel mode expands from 3 to 4 roles (adds accessibility checker for UI changes)
- 8 new agents: refine-ceo-scout, refine-eng-scout, refine-design-scout, review-accessibility-checker, ship-security-auditor, ship-performance-auditor, ship-accessibility-auditor, ship-docs-auditor

### Changed
- /refine: Phase 1.5 Idea Scout Army inserted between clarification and solution convergence
- /ship: Phase B restructured from optional quality gates to Ship Audit Army with 4 parallel auditors
- /review: parallel mode expanded with accessibility-checker role and minimum trigger conditions
- All command files (Claude Code + Codex CLI) updated with multi-role army documentation
- Agent count: 7 → 15

## [1.1.0] - 2026-04-24

### Added
- Plan Review Army: /plan now fans out to 4 parallel plan reviewers (CEO, Eng, Design, Security)
- 4 new plan-review agents: plan-ceo-reviewer, plan-eng-reviewer, plan-design-reviewer, plan-security-reviewer
- Version bump validation in ./validate

### Changed
- /plan workflow: Step 7.5 Plan Review Army inserted before user approval
- All plan commands (Claude Code, Codex CLI) delegate to same multi-role workflow

## [1.0.0] - 2026-04-24

### Added
- 43 skills across 6 phases: define, build, verify, ship, maintain, reflect
- 8 commands: /refine, /plan, /build, /review, /ship, /save, /restore, /learn
- CANON.md — 10 immutable rules inherited by all skills
- 3 review agents: code-reviewer, test-engineer, security-auditor
- 6 document templates (feature spec/plan/adr/README, bug root-cause/fix-plan)
- Claude Code plugin support (.claude-plugin/plugin.json)
- Marketplace registration (ZeroZ-lab/unified-skills)
- Codex CLI compatibility ($refine, $plan, $build, $review, $ship)
- Validation script (./validate)
