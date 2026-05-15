# Agent 架构重造

## 问题陈述

How might we 把 24 个 Unified agent 从"手工长 prompt + 最少 frontmatter"升级到"结构化 frontmatter + 轻量 body + 技能辅助文件去重"，使每个 agent 更聚焦、更安全、更高效？

## 方案及理由

对 24 个 agent 全量重构：补齐插件支持的文档化 frontmatter 字段（tools, model, maxTurns 等），精简 body 去除与技能辅助文件重复的内容，改进 description 让其描述角色职责而非触发条件。

只有 2 个 agent（review-code-quality-auditor 171行, review-spec-compliance-auditor 149行）真正需要大幅精简；其他 22 个需要的是 frontmatter 补齐 + description 改进 + 与技能辅助文件的内容去重。validate 脚本要求审查类 agent body 包含关键词（审查维度、输出格式、Blocking.*Important.*Suggestion），精简时必须保留这些关键词。

核心理由：当前 agent 的内容与技能辅助文件大量重复（如 code-quality auditor 和 verify-quality-code-quality/rubric.md + report-template.md），去除重复后 body 更聚焦、维护更单点。frontmatter 补齐后，Claude Code 可以在 dispatch 时限制 tools、路由 model、隔离 worktree，无需依赖技能层手动约束。

## Artifact Type
artifact_type: software

Allowed: software / document / article / deck / visual

## Goal Alignment
- Source Goal: conversation（brainstorm + Scout feedback）
- Goal Status: accepted
- Goal Review Score: 11/12（修正后：Clarity 2, Scope 2, Context 2, Constraints 2, Acceptance 2, Safety 1）

### One-line Goal
对 24 个 Unified agent 补齐文档化 frontmatter 字段、精简 body 去除技能辅助文件重复内容、改进 description。

### Done When
- [ ] Functional: 24 个 agent 文件重构完成，body 行数分级达标（审计类 <120，其他类 <80）
- [ ] Functional: 所有 agent frontmatter 只使用插件支持的文档化字段
- [ ] Functional: 2 个超长 agent 与技能辅助文件的重复内容已去除
- [ ] Functional: description 字段描述角色职责，不含触发条件
- [ ] Functional: validate 脚本所有 agent 结构检查通过
- [ ] Functional: skills-lock.json 和 skills-index.json 无漂移
- [ ] Technical: `./validate` 通过
- [ ] Regression: 阶段技能对 agent 的引用路径不变（`agents/<name>.md`）
- [ ] Output: `docs/features/20260515-agent-architect/01-spec.md`

### Stop Conditions
- [ ] Acceptance 无法验证（validate 通过是硬门）
- [ ] 需要修改明确排除范围（如增加新 agent 或改变目录结构）
- [ ] 需要改变 validate 脚本的核心检查逻辑
- [ ] 实际范围明显大于当前 Goal（如需要修改技能文件流程）

## External References
- Search status: completed
- Scan date: 2026-05-15
- Sources:
  - Claude Code Subagents Documentation (code.claude.com/docs/en/sub-agents) — frontmatter 字段完整列表
  - Claude Code Plugins Reference (code.claude.com/docs/en/plugins-reference) — 插件 agent 支持的字段子集
- Fact:
  - 插件 agent 支持 11 个文档化 frontmatter 字段：name, description, model, effort, maxTurns, tools, disallowedTools, skills, memory, background, isolation
  - 插件 agent 不支持 hooks, mcpServers, permissionMode（安全原因被忽略）
  - 只有 2 个 agent 超过 80 行（review-code-quality 171, review-spec-compliance 149），22 个已合规
  - 只有 2 个 agent 有非标准 frontmatter 字段（role, phase），即上述 2 个超长文件
  - `name` 是身份/调度键，不是 filename
  - 2 个长 agent 的内容与技能辅助文件大量重复（rubric.md, report-template.md, quality-reviewer-prompt.md）
- Pattern:
  - YAML frontmatter + Markdown body 是 canonical 格式
  - 省略 tools 时继承所有工具；省略 model 时继承父模型
  - 阶段技能是调度权威，agent description 不应复制调度触发条件
- Inference:
  - 审计类 agent 行数 <80 不可达（需要保留判定标准/红旗表），合理目标是 <120
  - content separation（body vs 辅助文件）只影响 2 个文件——其他 22 个无重复内容需要下沉
- Unknown:
  - Claude Code 自动 dispatch 时如何匹配 subagent_type（模型驱动 vs 确定性路由）
- Adopt:
  - 采用插件支持的 10 个 frontmatter 字段作为权威 schema
  - 采用分级行数目标：审计类 <120，侦察/审查/核心类 <80
  - 采用 description 描述角色职责，不含触发条件（避免与技能层调度合同重复）
  - 采用 `name` 字段作为身份键（不是 filename）
  - 采用单次提交策略（不做 3 批次）
- Reject:
  - 不采用 hooks, mcpServers, permissionMode（插件不支持）
  - 不采用全局 <80 行目标（审计类不可达）
  - 不采用 description 加触发条件（与技能层调度重复）
  - 不采用 agents/ 目录新建辅助文件机制（内容下沉指向已有技能辅助文件）
  - 不采用 3 批次执行（cross-batch 依赖风险）
  - 不采用 isolation 作为多选项概念（只有 worktree 或省略）

## Scout Review Summary
- CEO: Important — 只有 2 个 agent 真正需要精简，不是系统性问题；<80 行对审计类不可达；3 批次有跨依赖风险；description 不应加触发条件
- Eng: Suggestion — 2 个长 agent 内容已在技能辅助文件存在，去除重复即可；validate 要求关键词必须在 body 中；agent 目录没有辅助文件机制
- Blocking resolved:
  - scope 从"24 个全量精简 body"修正为"2 个精简 + 22 个 frontmatter 补齐 + description 改进"
  - 行数目标从全局 <80 修正为分级（审计类 <120，其他 <80）
  - frontmatter 从"只用 name+description"修正为"插件支持的 10 个字段"
- Important adopted:
  - 单次提交替代 3 批次
  - description 描述角色职责而非触发条件
  - 内容下沉指向已有技能辅助文件
- Suggestions deferred:
  - 是否也重构 22 个已合规 agent 的 body（用户选择 Full 重构）

## 核心假设（待验证）
- [ ] 假设 1：去除 2 个超长 agent 与技能辅助文件的重复内容后，agent body 仍包含 validate 要求的关键词 — 通过 spot-check 验证
- [ ] 假设 2：22 个已合规 agent 只需 frontmatter 补齐 + description 改进，body 内容不需要精简 — 通过 spot-check 验证
- [ ] 假设 3：frontmatter 补齐（tools, model 等）不影响 Claude Code 当前行为（省略字段 = 继承默认） — 通过文档确认
- [ ] 假设 4：description 改进不破坏 validate 对 description frontmatter 的检查 — validate 只检查 `^description: ` 存在，不检查内容

## MVP 范围

包含：
- 24 个 agent 文件的 frontmatter 补齐（添加按角色需要的 tools, model, maxTurns, isolation 等字段）
- 24 个 agent description 改进（描述角色职责）
- 2 个超长 agent body 精简（去除与技能辅助文件重复的评分表/输出模板/判定标准，保留审查维度摘要 + 核心红旗 + 关键常见说辞 + 输出格式指针）
- 2 个 agent 清理非标准 frontmatter（role, phase）
- validate 脚本更新（如需适配新 frontmatter 结构）
- skills-lock.json + skills-index.json 同步

不包含：
- 技能辅助文件内容变更
- agent 目录结构变更
- 新建 agent 辅助文件
- AGENTS.md / agents/README.md 内容变更（除非 frontmatter schema 描述需要更新）

## 不做清单（及理由）
- 不给 agent 加 hooks frontmatter — 插件不支持，写入会被忽略，造成误导
- 不给 description 加触发条件 — 与技能层调度合同重复，违反 CANON "不能在技能间重复内容"
- 不创建 agents/hooks/ 共享模板目录 — hooks 对插件 agent 无效，双重护栏不可行
- 不建 agent 辅助文件机制 — 内容下沉指向已有技能辅助文件，不新建目录
- 不合并重叠 agent — 24 个职责边界清晰
- 不改 agents/ 目录位置 — 作为插件目录位置正确
- 不改 filename — name 字段是身份键，filename 无功能影响
- 不给所有 agent 加 background: true — 审查类需要同步交互
- 不给 agent 加 memory 字段 — 当前由阶段技能一次性调度，不需跨 session 记忆

## 待解决问题
- 每个 agent 应配置哪些具体的 frontmatter 字段值（tools allowlist/denylist 内容、model 路由选择、maxTurns 数值、isolation 是否需要）— 需在 plan 阶段按角色逐个确定
- validate 脚本是否需要新增对新 frontmatter 字段的检查（如 tools 字段格式合法性）— 需在 build 阶段评估
- 2 个超长 agent 精简后 body 行数的实际可达值（取决于保留多少核心红旗/常见说辞）— 需在 build 阶段实际测量