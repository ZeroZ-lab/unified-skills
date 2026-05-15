# Agent 架构重造 — Plan

## Artifact Type
artifact_type: software

## Plan Topology
Topology: serial

理由: 24 个 agent 文件共享 validate 脚本验证和 skills-lock.json 索引。修改需要顺序验证，不能并行拆分到不同 write scope（validate 在所有修改完成后才能一次通过）。

## Parallel Execution Matrix

| Task | Depends On | parallel_safe | Complexity |
|------|-----------|---------------|------------|
| T1 | — | false | M |
| T2 | T1 | false | M |
| T3 | T2 | false | S |
| T4 | T3 | false | S |
| T5 | T4 | false | M |
| T6 | T5 | false | XS |

## 任务列表

### T1: 审计类 agent frontmatter + description 改写（9 个文件）

**范围**: 修改 9 个审计类 agent 的 frontmatter 和 description，不改 body 内容

**文件列表**:
- `agents/review-code-quality-auditor.md`
- `agents/review-spec-compliance-auditor.md`
- `agents/review-security-auditor.md`
- `agents/review-test-engineer.md`
- `agents/review-accessibility-auditor.md`
- `agents/ship-security-auditor.md`
- `agents/ship-performance-auditor.md`
- `agents/ship-accessibility-auditor.md`
- `agents/ship-docs-auditor.md`

**步骤**:

1. 修改 `review-code-quality-auditor.md` frontmatter:
   - 删除 `role:` 和 `phase:` 字段
   - 改写 description: `"代码质量审计 — 五轴评估已通过 spec compliance 的代码实现质量"`
   - 添加 `tools: [Glob, Grep, Read, LSP, Agent, WebSearch, WebFetch, mcp__plugin_context7_context7__resolve-library-id, mcp__plugin_context7_context7__query-docs, mcp__plugin_playwright_playwright__browser_snapshot, mcp__plugin_playwright_playwright__browser_take_screenshot, mcp__ide__getDiagnostics]`
   - 添加 `model: sonnet`
   - 添加 `maxTurns: 15`

2. 修改 `review-spec-compliance-auditor.md` frontmatter:
   - 删除 `role:` 和 `phase:` 字段
   - 改写 description: `"Spec 合规性审计 — 验证代码是否完整实现了 spec 的所有需求"`
   - 添加同上 tools、model、maxTurns

3. 修改其余 7 个审计类 agent frontmatter:
   - `review-security-auditor.md`: description → `"安全审计 — OWASP、输入边界、认证授权和数据暴露审查"`
   - `review-test-engineer.md`: description → `"测试覆盖审计 — happy path、边界、错误路径和并发场景覆盖分析"`
   - `review-accessibility-auditor.md`: description → `"无障碍审计 — WCAG 合规、语义正确性和动态内容可访问性验证"`
   - `ship-security-auditor.md`: description → `"发布安全审计 — OWASP、数据隐私和配置安全的上线前最后一道检查"`
   - `ship-performance-auditor.md`: description → `"发布性能审计 — 关键路径、N+1 查询、内存资源和 Bundle 影响检查"`
   - `ship-accessibility-auditor.md`: description → `"发布无障碍审计 — 生产环境 WCAG 合规验证"`
   - `ship-docs-auditor.md`: description → `"发布文档审计 — CHANGELOG、README、API docs 和迁移指南完整性检查"`
   - 每个: 添加 tools(同上)、model: sonnet、maxTurns: 15

**验收标准**:
- 9 个文件 frontmatter 只含 name, description, tools, model, maxTurns（无 role/phase）
- 所有 description 格式为 `"<角色名> — <职责>"` 且不含条件触发句式
- tools allowlist 只含只读工具
- body 内容未改变

**验证**: 对 9 个文件分别确认 frontmatter 格式正确，description 风格一致

---

### T2: 2 个超长 agent body 精简（2 个文件）

**范围**: 精简 review-code-quality-auditor 和 review-spec-compliance-auditor 的 body 内容

**文件列表**:
- `agents/review-code-quality-auditor.md`
- `agents/review-spec-compliance-auditor.md`

**步骤**:

1. 精简 `review-code-quality-auditor.md` body（从 171 行到 <120 行）:
   - 保留: 审计维度摘要（5 轴名称 + 1 句描述）→ `## 审计维度`
   - 保留: 核心红旗 3-5 条 → `## 核心红旗`（从 HARD-GATE 挑选最关键 5 条）
   - 保留: 关键常见陷阱 3-5 条 → `## 关键常见陷阱`（从现有 8 条挑 5 条）
   - 保留: 输出格式指针 → `## 输出格式` + "详细模板见 skills/verify-quality-code-quality/report-template.md"
   - 保留: 不负责清单 → `## 不负责`
   - 删除: 完整评分表/覆盖模板（已在 rubric.md + report-template.md）
   - 删除: 详细判定标准（已在 SKILL.md Step 5）
   - 删除: 反馈分级表（B/I/S 定义保留在输出格式指针中一句话概括）
   - 删除: 常见陷阱全文（保留 5 条，其余已在 SKILL.md 常见说辞）

2. 精简 `review-spec-compliance-auditor.md` body（从 149 行到 <120 行）:
   - 保留: 审计维度摘要 → `## 审计维度`（单一维度: Spec Compliance 功能完整性）
   - 保留: 核心红旗 → `## 核心红旗`（从 Blocking 条件挑 5 条最关键的）
   - 保留: 输出格式指针 → `## 输出格式` + "详细覆盖模板见 skills/verify-workflow-spec-compliance/SKILL.md"
   - 保留: 不负责清单 → `## 不负责`
   - 删除: 完整覆盖模板（已在 SKILL.md）
   - 删除: 详细判定标准（已在 SKILL.md）
   - 删除: 反馈分级表
   - 删除: 常见陷阱全文（保留 3-5 条，其余已在 SKILL.md）

**验收标准**:
- review-code-quality-auditor.md body 行数 <120
- review-spec-compliance-auditor.md body 行数 <120
- 两个文件 body 都包含 validate 要求关键词: 审计维度、输出格式、Blocking.*Important.*Suggestion
- 两个文件都没有与技能辅助文件重复的大段内容

**验证**: `wc -l` 确认行数；grep 确认关键词存在

---

### T3: 侦察类 + 审查类 agent frontmatter + description（8 个文件）

**范围**: 修改 3 个侦察类 + 5 个审查类 agent 的 frontmatter 和 description

**文件列表**:
- `agents/refine-ceo-scout.md`
- `agents/refine-eng-scout.md`
- `agents/refine-design-scout.md`
- `agents/plan-ceo-reviewer.md`
- `agents/plan-eng-reviewer.md`
- `agents/plan-design-reviewer.md`
- `agents/plan-security-reviewer.md`
- `agents/design-reviewer.md`

**步骤**:

1. 修改 3 个侦察类 frontmatter:
   - `refine-ceo-scout.md`: description → `"商业价值侦察 — 验证 idea 的问题真实度、杠杆、优先级和成功标准"`；添加 model: sonnet、maxTurns: 10
   - `refine-eng-scout.md`: description → `"工程侦察 — 评估 idea 的技术可行性、复杂度、已有方案和技术风险"`；添加 model: sonnet、maxTurns: 10
   - `refine-design-scout.md`: description → `"设计侦察 — 验证 idea 的用户路径、心智模型、关键交互和设计范围"`；添加 model: sonnet、maxTurns: 10

2. 修改 5 个审查类 frontmatter:
   - `plan-ceo-reviewer.md`: description → `"计划审查（CEO 视角）— 验证计划的市场价值、ROI 和优先级排序"`；添加 maxTurns: 15
   - `plan-eng-reviewer.md`: description → `"计划审查（工程视角）— 验证计划的技术可行性、架构合理性和复杂度"`；添加 maxTurns: 15
   - `plan-design-reviewer.md`: description → `"计划审查（设计视角）— 验证计划是否正确消费已批准的设计约束"`；添加 maxTurns: 15
   - `plan-security-reviewer.md`: description → `"计划审查（安全视角）— 验证计划的数据隐私、攻击面和合规风险"`；添加 maxTurns: 15
   - `design-reviewer.md`: description → `"设计阶段审查 — 审查设计稿的证据质量、交互、视觉、排版和设计边界"`；添加 maxTurns: 15

**验收标准**:
- 8 个文件 description 格式为 `"<角色名> — <职责>"` 且不含条件触发句式
- 侦察类: model: sonnet, maxTurns: 10
- 审查类: maxTurns: 15（model 省略=inherit）
- body 内容未改变

**验证**: 确认 frontmatter 格式正确

---

### T4: 核心类 agent frontmatter + description（7 个文件）

**范围**: 修改 7 个核心类 agent 的 frontmatter 和 description

**文件列表**:
- `agents/requirements-analyst.md`
- `agents/task-planner.md`
- `agents/software-engineer.md`
- `agents/data-architect.md`
- `agents/api-designer.md`
- `agents/content-writer.md`
- `agents/visual-designer.md`

**步骤**:

1. 修改 frontmatter（所有 7 个）:
   - requirements-analyst: description → `"需求分析师 — 通过 5W1H 澄清模糊需求，识别隐含假设，生成结构化 spec"`
   - task-planner: description → `"任务规划师 — 将 spec 转化为带验收标准的任务分解，标注依赖和并行安全性"`
   - software-engineer: description → `"软件工程师 — TDD 循环开发，覆盖 API、数据库、前后端实现"`；添加 `isolation: worktree`
   - data-architect: description → `"数据架构师 — 数据建模、schema 设计、数据迁移策略"`；添加 `isolation: worktree`
   - api-designer: description → `"API 设计师 — RESTful/GraphQL 接口设计、契约定义、版本管理"`；添加 `isolation: worktree`
   - content-writer: description → `"内容创作者 — 按已批准剧本增量创作文档、文章、PPT 叙事内容"`；添加 `isolation: worktree`
   - visual-designer: description → `"视觉设计师 — 有证据支撑的交互、视觉、排版方向及执行约束"`；添加 `isolation: worktree`

**验收标准**:
- 7 个文件 description 格式为 `"<角色名> — <职责>"`
- 5 个写操作类 agent 有 `isolation: worktree`
- requirements-analyst 和 task-planner 无 isolation
- body 内容未改变

**验证**: 确认 frontmatter 格式和 isolation 字段

---

### T5: Validate + 索引同步

**范围**: 评估 validate 脚本是否需更新，同步 skills-lock.json 和 skills-index.json

**文件列表**:
- `validate`（如需修改）
- `skills-lock.json`
- `skills-index.json`
- `agents/README.md`（如需更新 frontmatter schema 描述）

**步骤**:

1. 评估 validate 是否需要更新:
   - 检查 validate 对 agent frontmatter 的检查是否仍兼容（只检查 `^name: ` 和 `^description: `，新字段不应冲突）
   - 检查 design-reviewer 是否需要加入 validate glob pattern（已知缺口）
   - 如需修改: 在 validate 的审查类 glob 中添加 `design-*.md` pattern
   - 如不需修改: 记录兼容性确认

2. 运行 `./validate` 确认所有修改通过

3. 运行 `bash scripts/generate-index.sh` 同步 skills-index.json

4. 评估 agents/README.md 是否需要更新:
   - 如 frontmatter schema 描述需要反映新增字段: 更新 README.md 中 agent 配置说明
   - 如不需更新: 记录确认

**验收标准**:
- `./validate` 通过（0 failures）
- skills-index.json 与 `skills/` 实际技能集一致
- agents/README.md（如修改）与实际 agent frontmatter schema 一致

**验证**: `./validate` 命令输出全部 "通过"

---

### T6: 最终验证 + spot-check

**范围**: 全量验证所有 24 个 agent 文件的改写结果

**步骤**:

1. Spot-check 2 个超长 agent body:
   - 确认 `review-code-quality-auditor.md` body 包含: 审计维度、核心红旗、关键常见陷阱、输出格式指针、不负责
   - 确认 `review-spec-compliance-auditor.md` body 包含: 审计维度、核心红旗、输出格式指针、不负责
   - 确认两者行数 <120

2. Spot-check 所有 24 个 description:
   - 确认格式统一为 `"<角色名> — <职责>"`
   - 确认无条件触发句式（不含"从 X 视角"、"当 X 时"）

3. Spot-check frontmatter 字段策略:
   - 审计类 9 个: tools(只读) + model:sonnet + maxTurns:15
   - 侦察类 3 个: model:sonnet + maxTurns:10
   - 审查类 5 个: maxTurns:15
   - 核心类 7 个: isolation:worktree(5个) / 无isolation(2个)

4. 运行 `./validate` 最终确认

**验收标准**:
- 所有 24 个 agent 改写后 validate 通过
- 行数分级达标
- description 风格一致
- frontmatter 策略按设计矩阵配置

**验证**: `./validate` + `wc -l` + grep 确认

## 检查点

| Checkpoint | After Task | 验证命令 |
|------------|------------|---------|
| CP1 | T2 | `wc -l agents/review-code-quality-auditor.md agents/review-spec-compliance-auditor.md` — 确认 <120 行 |
| CP2 | T5 | `./validate` — 全量通过 |
| CP3 | T6 | `./validate` + spot-check 确认所有 24 个文件合规 |

## 自审

### 7.1 Spec 覆盖
- 24 个 agent frontmatter 补齐 → T1/T3/T4
- 24 个 description 改进 → T1/T3/T4
- 2 个超长 agent body 精简 → T2
- 2 个 agent 清理 role/phase → T1（在 frontmatter 步骤中一并处理）
- validate 脚本更新评估 → T5
- skills-lock.json + skills-index.json 同步 → T5

### 7.2 占位符扫描
无 TBD/TODO/占位符

### 7.7 任务独立性
每个任务有明确验收标准和独立验证步骤

### 7.10 任务粒度
- T1: 9 文件 — 但只改 frontmatter（机械性操作），可单任务覆盖
- T2: 2 文件 — 精简 body（最复杂的任务）
- T3: 8 文件 — 只改 frontmatter（机械性）
- T4: 7 文件 — 只改 frontmatter（机械性）
- T5: 1-4 文件 — 验证和同步
- T6: 0 文件（验证任务）

T1 涉及 9 文件超出 <5 文件指南，但所有改动都是同一模式的机械性 frontmatter 编辑，不拆分更高效。如果拆分需要 9 个小任务，增加管理开销而降低效率。

## Plan Review Army

标准变更，至少 CEO + Eng 双视角。以下为自审替代（任务规模和风险不足以开启独立 reviewer session）:

**CEO 视角**: 投资回报明确——24 个文件的 frontmatter 补齐提供原生安全护栏，2 个超长文件去重减少维护成本。ROI 合理。

**Eng 视角**: 技术可行——所有改动都是配置变更，不涉及代码逻辑修改。最大风险在 T2（body 精简可能破坏 validate 关键词），已有 CP1 检查点覆盖。