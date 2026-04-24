# Changelog

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
