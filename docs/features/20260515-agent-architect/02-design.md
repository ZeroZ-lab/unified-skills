# Agent 架构重造 — Design

## Artifact Type
artifact_type: software

## Design Requirement
- Design Status: required
- Design Track: configuration/interaction pattern design（非 UI/视觉设计）
- Reason: 24 个 agent 文件的 frontmatter 字段策略、body 结构模式、content separation 策略、description 改写原则需要在实现前统一锁定，否则 24 个文件各自做出不一致的选择

## Design References
- Scan Date: 2026-05-15
- Search Status: completed
- Enterprise Product Patterns:
  - Anthropic Claude Code subagent 配置模式（YAML frontmatter + Markdown body）
  - GitHub Copilot agent 配置模式（JSON schema + prompt template）
  - OpenAI Agents SDK agent 配置（Python class-based, config dict + instructions）
- Official Systems / Platform Rules:
  - Claude Code Subagents Documentation — frontmatter 字段权威列表（16 字段，项目级；11 字段，插件级：name, description, model, effort, maxTurns, tools, disallowedTools, skills, memory, background, isolation）
  - Claude Code Plugins Reference — 插件 agent 支持的字段子集（不含 hooks/mcpServers/permissionMode）
  - Claude Code Agent SDK TypeScript — Agent tool input schema（description, prompt, subagent_type, model, max_turns, isolation, mode 等）
- Methods / Theory / Style Schools:
  - Configuration-as-Code 原则：配置应结构化、声明式、可验证
  - Single Source of Truth 原则：行为塑造内容只维护一个地方，用引用代替复制
  - Progressive Enhancement 原则：省略字段 = 继承默认，显式配置 = 覆盖默认
- Anti-patterns / Verification:
  - 重复内容散布在 agent 和技能辅助文件中——维护时必须同步两处
  - 非标准 frontmatter 字段被运行时忽略——只造成噪音
  - description 写触发条件——与技能层调度合同重复，违反 CANON
  - 全局统一行数目标——不同角色类有不同信息密度需求
- Local Project Truth:
  - validate 脚本要求审查类 agent body 包含：审查维度/审计维度、输出格式、Blocking.*Important.*Suggestion
  - validate 脚本要求工程类 agent body 包含：职责、输出格式
  - 2 个超长 agent 内容与技能辅助文件重复（rubric.md, report-template.md, quality-reviewer-prompt.md）
  - 现有 agent 分 4 类：审计类（review-*, ship-*）、侦察类（refine-*）、审查类（plan-*）、核心类（requirements-analyst, task-planner 等）
  - skills-lock.json 不追踪 agent 文件
  - 阶段技能通过字符串引用调度 agent（`agents/<name>.md`）

## Pattern Synthesis
- Repeated Patterns:
  - 所有 24 个 agent 都用 YAML frontmatter（name + description）+ Markdown body
  - 审计类 agent 都有：审查维度/审计维度 + 输出格式 + Blocking/Important/Suggestion 三级
  - 工程类 agent 都有：职责 + 不负责 + 输入 + 输出格式
  - 侦察类 agent 都有：输入要求 + 审查维度 + 约束 + 输出格式 + 判断规则
  - description 格式统一为："角色名 — 职责描述"
- Conflicting Patterns:
  - 2 个超长 agent 把评分表/模板内联在 body，其他 agent 只引用技能名——信息密度不一致
  - 2 个超长 agent 有 role/phase frontmatter，其他 22 个没有——非标准字段不一致
  - 部分 description 偏角色描述（"需求分析师 — ..."），部分偏触发描述（"技术侦察 — 从工程视角..."）——风格不一致
- Local Constraints That Override External Patterns:
  - validate 脚本的关键词检查是硬约束——body 精简时必须保留这些关键词，不能下沉
  - 阶段技能是调度权威——agent description 不能复制调度触发条件
  - 插件 agent 不支持 hooks——双重护栏方案不可行

## Design Inferences
- Inference 1: Agent body 应按角色类分型而非统一格式
  - Based on: 审计类需要判定标准+红旗表+常见说辞，侦察类只需要审查维度+判断规则，核心类只需要职责+不负责
  - Implication: 4 类 agent 有 4 种 body 模板，不是 1 种统一模板
- Inference 2: Frontmatter 字段按角色类分策略配置
  - Based on: 审计类不需要写权限（tools 限制），核心类需要写权限（不限制 tools），侦察类需要轻量模型（model: sonnet）
  - Implication: 不是所有 agent 都配同样的 frontmatter 字段集
- Inference 3: Content separation 只需要 2 个文件，其他 22 个无重复内容可下沉
  - Based on: 只有 review-code-quality 和 review-spec-compliance 与技能辅助文件有大量重复
  - Implication: body 精简策略分两档：2 个去重+精简，22 个只改进 description 和 frontmatter
- Inference 4: Description 改写为角色职责描述 + 适用场景
  - Based on: description 官方定义是 "When Claude should delegate to this subagent"；阶段技能是调度权威，description 重复触发条件违反 CANON
  - Implication: description 写"角色做什么 + 适合什么场景"而非纯触发条件。格式: `"<角色名> — <核心职责>"`，职责描述可包含适用场景（如"评估 idea 的可行性"），但不得包含条件句式（如"当 /review 时"、"从 X 视角"触发语法）
  - Risk: Claude Code 自动 dispatch 机制对 description 的依赖程度未完全文档化（见 Unknowns）。如果自动 dispatch 依赖 description 中的场景信息，纯角色描述可能降低 dispatch 精度。缓解: description 包含场景语义但不使用条件触发句式——既满足官方定义又避免与技能层重复
- Unknowns / Evidence Gaps:
  - Claude Code 自动 dispatch 机制对 description 的实际依赖程度（模型驱动 vs 确定性路由）未完全文档化
  - tools allowlist/denylist 的具体工具名列表需要按角色逐一确认
  - 2 个超长 agent 精简后的实际行数取决于保留多少核心红旗/常见说辞

## Adopt / Reject
- Adopt:
  - 4 类 agent 分型设计（审计/侦察/审查/核心各有专属 body 模板和 frontmatter 策略） — Source Layer: Local Project Truth; Reason: 不同角色有不同信息密度和配置需求
  - 审计类 body <120 行，其他类 <80 行 — Source Layer: Local Project Truth + Anti-patterns; Reason: 审计类需要保留判定标准和红旗表，全局 <80 不可达
  - description 改写为角色职责描述 — Source Layer: Official Systems + Local Project Truth; Reason: 官方定义 description 是 "When Claude should delegate"，职责描述包含场景语义但不使用条件触发句式，既满足官方定义又避免与技能层调度合同重复
  - 省略字段 = 继承默认（Progressive Enhancement） — Source Layer: Official Systems; Reason: 不需要给所有 agent 都显式配置每个字段
  - Content separation 指向已有技能辅助文件（不新建 agent 辅助文件） — Source Layer: Local Project Truth; Reason: 技能辅助文件已存在，不需要重复
  - 只用插件支持的 11 个 frontmatter 字段 — Source Layer: Official Systems; Reason: hooks/mcpServers/permissionMode 对插件无效
- Reject:
  - 全局统一行数目标 — Source Layer: Anti-patterns; Reason: 不同角色类有不同信息密度
  - description 加触发条件 — Source Layer: Local Project Truth + CANON; Reason: 与技能层调度合同重复
  - 新建 agents/hooks/ 目录 — Source Layer: Official Systems; Reason: hooks 对插件无效
  - 新建 agent 辅助文件机制 — Source Layer: Local Project Truth; Reason: 已有技能辅助文件，不需要额外机制
  - 3 批次执行 — Source Layer: Anti-patterns; Reason: cross-batch 依赖风险（此决策属于 /plan 阶段执行策略，此处仅记录为 Reject）

## Design Evidence Quality
- [x] Sources are grouped by source layer
- [x] Key decisions trace to sources or Local Project Truth
- [x] Adopt / Reject is explicit
- [x] Search unavailable or evidence gaps are recorded
- [x] No external pattern is copied blindly

## 设计目标
- Claude Code 用户（开发者）要更快完成什么？——agent 配置更聚焦、维护更单点、dispatch 更精准
- 这份设计要减少什么理解成本或操作摩擦？——消除 agent 和技能辅助文件的重复维护；让 frontmatter 提供原生安全护栏而不是依赖技能层手动约束

## 关键决策

### 决策 1: Agent 4 类分型设计

24 个 agent 分为 4 类，每类有专属的 body 结构模板和 frontmatter 策略：

| 类 | Agent | 数量 | Body 模板核心章节 | Frontmatter 策略 |
|----|-------|------|-------------------|-------------------|
| 审计类 | review-code-quality, review-spec-compliance, review-security, review-test-engineer, review-accessibility, ship-security, ship-performance, ship-accessibility, ship-docs | 9 | 审计维度摘要 + 核心红旗(3-5条) + 关键常见说辞(3-5条) + 输出格式指针 | tools: 只读集合 + model: sonnet + maxTurns: 15 |
| 侦察类 | refine-ceo-scout, refine-eng-scout, refine-design-scout | 3 | 输入要求 + 审查维度 + 约束 + 输出格式 + 判断规则 | model: sonnet + maxTurns: 10 |
| 审查类 | plan-ceo-reviewer, plan-eng-reviewer, plan-design-reviewer, plan-security-reviewer, design-reviewer | 5 | 审查维度 + Blocking 条件 + 输出格式 | model: inherit + maxTurns: 15 |
| 核心类 | requirements-analyst, task-planner, software-engineer, data-architect, api-designer, content-writer, visual-designer | 7 | 职责 + 不负责 + 输入 + 输出格式 | tools: inherit + model: inherit + isolation: worktree(写操作类) |

**理由**: 审计类不需要写权限（审查代码不改代码），侦察类需要轻量模型（快速侦察不深度分析），审查类和核心类继承父模型。核心类中的写操作角色（software-engineer 等）需要 worktree 隔离。

### 决策 2: Description 改写原则

description 字段改写为角色职责描述，格式统一为：

```
"<角色名> — <核心职责一句话>"
```

改写规则：职责描述可包含场景语义，但禁止条件触发句式（详细边界规则见 Description 改写边界规则章节）。

示例：
- 审计类: `"代码质量审计 — 五轴评估已通过 spec compliance 的代码实现质量"`
- 侦察类: `"工程侦察 — 评估 idea 的技术可行性、复杂度和已有方案"`
- 审查类: `"计划审查（CEO 视角）— 验证计划的市场价值、ROI 和优先级"`
- 核心类: `"软件工程师 — TDD 循环开发，覆盖 API/数据库/前后端实现"`

**不加触发条件**（如 "当 /review Phase 2 时"），因为技能层是调度权威。但职责描述中可包含场景语义（如"评估 idea 的可行性"），以满足 Claude Code description 官方定义 "When Claude should delegate" 的语义需求。

### 决策 3: 2 个超长 agent content separation 策略

review-code-quality-auditor (171行) 和 review-spec-compliance-auditor (149行) 的精简策略：

**保留在 body**（validate 要求 + 行为塑造核心）：
- 审计维度摘要（5 轴名称 + 1 句话描述，不是完整 rubric）
- 核心红旗表（3-5 条最关键的 HARD-GATE 红旗）
- 关键常见说辞表（3-5 条最容易犯的错误）
- 输出格式指针（引用技能辅助文件名，不内联完整模板）
- Blocking/Important/Suggestion 三级描述（validate 要求关键词）
- 不负责清单

**下沉到已有技能辅助文件**（去重）：
- 完整评分表/ rubric → 已在 `skills/verify-quality-code-quality/rubric.md`
- 完整输出模板 → 已在 `skills/verify-quality-code-quality/report-template.md`
- 详细判定标准 → 已在 `skills/verify-quality-code-quality/SKILL.md` Step 5
- 完整常见陷阱 → 已在 `skills/verify-quality-code-quality/SKILL.md` 常见说辞
- Spec compliance 的完整覆盖模板 → 已在 `skills/verify-workflow-spec-compliance/SKILL.md`

**不下沉到新文件**——不需要新建 agent 辅助文件或 agents/ 子目录。

### 决策 4: Frontmatter 字段配置矩阵

| 字段 | 审计类 | 侦察类 | 审查类 | 核心类 |
|------|--------|--------|--------|--------|
| name | ✓（必需） | ✓（必需） | ✓（必需） | ✓（必需） |
| description | ✓（改写） | ✓（改写） | ✓（改写） | ✓（改写） |
| tools | ✓（只读集合） | —（省略=继承） | —（省略=继承） | —（省略=继承） |
| disallowedTools | — | — | — | — |
| model | sonnet | sonnet | —（省略=inherit） | —（省略=inherit） |
| maxTurns | 15 | 10 | 15 | —（省略=默认） |
| isolation | — | — | — | worktree（software-engineer, api-designer, data-architect, content-writer, visual-designer） |
| effort | — | — | — | — |
| skills | — | — | — | — |
| memory | — | — | — | — |
| background | — | — | — | — |

**省略字段 = 继承默认**（Progressive Enhancement 原则）。只显式配置有明确安全或效率理由的字段。

**审计类 tools 只读集合**: Glob, Grep, Read, LSP, Agent, WebSearch, WebFetch, mcp__plugin_context7_context7__resolve-library-id, mcp__plugin_context7_context7__query-docs, mcp__plugin_playwright_playwright__browser_snapshot, mcp__plugin_playwright_playwright__browser_take_screenshot, mcp__ide__getDiagnostics

**注**: tools allowlist 是审计类的唯一安全护栏——未列入的工具自动被排除。不需要 disallowedTools，因为 allowlist 已构成完整限制。MCP 工具名需要枚举具体工具 ID（不支持 glob 模式），当前列表基于项目实际 MCP 配置。如 MCP 配置变化，tools allowlist 需同步更新。

## 设计边界
- **做**: frontmatter 字段策略、body 结构模板、content separation 策略、description 改写原则、validate 兼容性
- **不做**: 具体每个文件的逐行改写、task breakdown、技能辅助文件内容变更、agent 目录结构变更、执行策略（提交批次属于 /plan）

## Validate 兼容性追溯

| 设计类 | validate glob pattern | 需要的关键词 | body 模板章节是否覆盖 | 备注 |
|--------|----------------------|-------------|----------------------|------|
| 审计类 | `review-*.md`, `ship-*.md` | 审查维度|审计维度, 输出格式, Blocking.*Important.*Suggestion | ✓ `## 审计维度` + `## 输出格式` + B/I/S 三级 | keywords 在模板中明确出现 |
| 侦察类 | `refine-*.md` | 审查维度|审计维度, 输出格式, Blocking.*Important.*Suggestion | ✓ `## 审查维度` + `## 输出格式` + `## 判断规则` 含 B/I/S | 判断规则章节包含 Blocking/Important/Suggestion 关键词 |
| 审查类（plan-*） | `plan-*.md` | 审查维度|审计维度, 输出格式, Blocking.*Important.*Suggestion | ✓ `## 审查维度` + `## 输出格式` + `## Blocking 条件` | plan-* 归入 validate 的审查类 glob |
| 审查类（design-reviewer） | **无匹配 glob** | N/A（validate 不检查） | — | **已知缺口**: `design-*.md` 不在 validate 的两个 glob pattern 中。build 阶段需评估是否给 validate 加 `design-*.md` pattern，或手动确认该 agent 结构合规 |
| 核心类 | `requirements-*.md`, `task-*.md`, `software-*.md` 等 | 职责, 输出格式 | ✓ `## 职责` + `## 输出格式` | data-*, api-*, content-*, visual-* 也在工程类 glob 中 |

## Description 改写边界规则

职责描述可包含场景语义，但禁止条件触发句式：

**允许**: `"<角色名> — <职责动作>"`
- "代码质量审计 — 五轴评估已通过 spec compliance 的代码实现质量"
- "工程侦察 — 评估 idea 的技术可行性、复杂度和已有方案"

**禁止条件句式**: 不得包含"从 X 视角"、"当 X 时"、"在 X 场景下"、"适用于 X"等条件前缀或触发语法
- ❌ "技术侦察 — 从工程视角评估 idea"（"从工程视角" 是条件句式）
- ❌ "代码质量审计 — 当 /review Phase 2 时使用"（"当" 是触发条件）
- ❌ "安全审计 specialist"（无角色名 + 职责结构）

**name 字段约定**: `name` 值必须与 filename stem 一致（`review-code-quality-auditor.md` → `name: review-code-quality-auditor`），因为技能层通过 `agents/<name>.md` 引用。

## 设计批准标准
- [ ] 4 类分型设计已定稿
- [ ] description 改写原则已定稿
- [ ] content separation 策略已定稿（2 个超长 agent）
- [ ] frontmatter 配置矩阵已定稿
- [ ] validate 兼容性已确认
- [ ] 没有把实现步骤写进设计稿

## 实施前置条件
- [ ] 已明确每个 agent 的具体 frontmatter 字段值（tools allowlist/denylist 内容需在 build 阶段逐一确认）
- [ ] 已明确 2 个超长 agent 精简后的保留 vs 下沉边界（需在 build 阶段实际测量行数）
- [ ] 已明确 validate 脚本是否需要适配新 frontmatter（如检查 tools 字段格式）
- [ ] 已明确 agents/README.md 是否需要更新（frontmatter schema 描述）

---

## 按类型填写 — Configuration Design

### Agent Body 结构模板

**审计类 body 模板（<120 行）**:
```markdown
# <Agent Title>

你是<角色描述>。你的职责是<核心职责>。

## 审计维度
1. **维度1** — <一句话描述>
2. **维度2** — <一句话描述>
...

## 核心红旗
<HARD-GATE>
- <红旗1>
- <红旗2>
- <红旗3>
</HARD-GATE>

## 关键常见陷阱
❌ <陷阱1>
❌ <陷阱2>
❌ <陷阱3>

## 输出格式
按 **Blocking / Important / Suggestion** 三级输出。<详细模板见 skills/<skill>/report-template.md>
```

**侦察类 body 模板（<80 行）**:
```markdown
# <Agent Title>

你是<角色描述>。

## 输入要求
- <必须读取的内容>

## 审查维度
1. <维度1>
2. <维度2>
...

## 约束
- <约束1>
- <约束2>

## 输出格式
<统一 scout 输出模板>

## 判断规则
- **Blocking**: <条件>
- **Important**: <条件>
- **Suggestion**: <条件>
```

**审查类 body 模板（<80 行）**:
```markdown
# <Agent Title>

你是<角色描述>。

## 审查维度
1. <维度1>
2. <维度2>
...

## Blocking 条件
- <条件1>
- <条件2>

## 输出格式
按 **Blocking / Important / Suggestion** 三级输出。
```

**核心类 body 模板（<80 行）**:
```markdown
# <Agent Title>

你是<角色描述>。

## 职责
1. <职责1>
2. <职责2>
...

## 不负责
- <不负责1>
- <不负责2>

## 输入
- <输入1>

## 输出格式
<输出格式描述或模板>
```

### 不做清单
- 不给每个 agent 配相同的 frontmatter 字段集（按角色类分策略配置）
- 不把所有 22 个已合规 agent 的 body 也精简（只改进 frontmatter + description）
- 不新建 agent 辅助文件或 agents/hooks/ 目录
- 不在 description 加触发条件
- 不改变 agent filename
- 不修改技能辅助文件内容