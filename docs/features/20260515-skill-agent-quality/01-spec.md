# Skills + Agents 质量系统 — Spec

## Artifact Type
`artifact_type: software`

本需求会产生文档、审计矩阵、可能的校验脚本和后续 skill / agent 内容修改；按仓库工作流归类为 software，因为最终会改变可验证的项目行为合同。

## Goal Alignment
- Source Goal: conversation + `docs/features/20260515-skill-agent-quality/00-brainstorm.md`
- Goal Status: accepted
- Goal Review Score: `11/12`

### One-line Goal
建立一套统一的 skills + agents 质量模型，先审计真实调用链，再分批提升行为塑造质量，并把稳定规则沉淀进验证门禁。

### Done When
- [ ] Functional: 每条关键阶段调用链都有明确记录：阶段技能、触发条件、可选/必需 agent、必需 sub-skill、输入、输出格式、风险升级条件和 validate 覆盖状态。
- [ ] Functional: 每个被纳入改造的 SKILL.md 和 agent 定义都有评分结果、缺口说明和修复记录。
- [ ] Technical: 每个修改批次完成后运行 `scripts/generate-index.sh`、`scripts/generate-router.sh`、`scripts/update-lock.sh`（如涉及技能内容）和 `./validate`，并记录结果。
- [ ] Regression: 不破坏 AGENTS 单入口、CANON、阶段硬门、Risk-Based Role Escalation、`human partner` 措辞和 `agents/` 非路由层边界。
- [ ] Output: 产出 `docs/features/20260515-skill-agent-quality/quality-matrix.md`、评分表、批次变更记录和最终 review 结论。

### Stop Conditions
- [ ] 发现要让方案成立必须把 `agents/` 变成独立路由器。
- [ ] 发现需要恢复 repo-local `.agents/skills/*` 薄包装模型。
- [ ] 发现 agent frontmatter / hooks 方案依赖当前宿主不支持的能力，且没有可接受降级路径。
- [ ] 某批改动无法在 `./validate` 下恢复通过。
- [ ] 评分标准推动文件变长但没有提升行为可执行性。

## 问题

Unified 的质量资产分布在 `skills/`、`agents/`、`skills-index.json`、`skills-router.json`、`validate` 和根合同文档中。现有验证能防止很多结构漂移，但不能完整回答这些问题：

- 某个 agent 是否真的被阶段技能消费？
- agent 的输出格式是否能被对应 skill 合并？
- skill 的红旗、硬门和验证失败处理是否足以改变 agent 行为？
- agent 的工具/权限边界是否匹配职责，而不是默认全能？
- 质量优化是否只是让文件更长，而不是让调用链更可靠？

因此，本需求不是简单润色文档，而是建立一个跨 `skills/` 与 `agents/` 的质量系统。

## 选定方案

选择 **统一质量模型 + 分层改造**。

先把每条阶段调用链作为审查单元，建立 `quality-matrix.md`，再用两套评分模型评估文件质量：

- Skill 五轴：可操作性、示例充足性、行为收敛性、跨技能衔接、说辞表质量。
- Agent 五轴：职责边界、触发条件、工具/权限边界、输出可消费性、阶段一致性。

执行顺序是先审计、再修 Blocking、再优化高杠杆路径，最后只把客观且稳定的规则加入自动化验证。主观评分不直接塞进 `validate`，避免把验证脚本变成不可维护的文字审美检查器。

## External References
- Search status: skipped
- Scan date: 2026-05-15
- Reason: 这是仓库内部行为合同优化；关键事实来自当前 repo、AGENTS/CANON、既有 feature 文档和 validate 输出。没有引入新外部框架或市场事实。
- Fact:
  - `./validate` 当前报告 `54` 个技能哈希校验、`13` 个辅助文件哈希校验、`54` 个 skill-load monitors。
  - `agents/` 当前包含 24 个 persona 定义文件，另有 `agents/README.md`。
  - `AGENTS.md` 明确：`agents/` 是 persona / 职责定义层，不是独立路由器；真正调用时机必须写在对应阶段技能或技能辅助文件中。
  - `skills-index.json` 的部分区段由脚本生成，`by_trigger`、`by_artifact_type`、`by_risk` 等路由区段仍需谨慎维护。
- Pattern:
  - 已有 `skills-optimization` 偏重单个 SKILL.md 质量。
  - 已有 `agent-architect` 偏重 agent frontmatter、工具权限和 body 精简。
  - 两者都需要被统一到调用链质量模型里，否则容易各自正确、整体漂移。
- Inference:
  - 优先审计调用链能更早发现真实行为漏洞，比如 agent 定义存在但 skill 未消费，或 skill 要求的输出 agent 不会产出。
  - 自动化门禁应该从已证明稳定的漏洞类型中沉淀，而不是先写大量主观规则。
- Unknown:
  - 插件 agent 对 `hooks`、`tools`、`model`、`maxTurns` 等 frontmatter 的真实支持边界需要小样本验证。
  - 是否需要正式标记旧 `skills-optimization` 和 `agent-architect` 为 superseded，还是作为本 spec 的子材料保留。
- Adopt:
  - 以调用链矩阵作为 Phase 0 的核心产物。
  - 复用 skill 五轴评分，但修正动态库存数量。
  - 新增 agent 五轴评分。
  - 每批改动都用生成脚本、锁文件同步和 `./validate` 作为硬证据。
- Reject:
  - 把 `agents/` 改成路由层。
  - 一次性重写所有 skills 和 agents。
  - 用固定库存数字写长期合同。
  - 先写大量 validate 主观规则再反推内容。

## Scout Review Summary
- CEO: Important — 方向值得做，但必须先产出调用链矩阵，避免只做文档美化；成功标准要绑定行为和验证证据。
- Eng: Important — 技术可行，主要风险是 agent frontmatter 宿主支持边界、锁文件同步和 validate 规则过度主观。
- Design: skipped — 本轮不是用户可见 UI / visual / deck 产物；设计视角不作为必要 scout。
- Blocking resolved: none
- Important adopted:
  - `commands/` 作为调用链审计输入，不作为主要改造范围。
  - Phase 0 必须验证实际库存数量，不能沿用旧静态数字。
  - agent frontmatter 能力先小样本验证，再批量改。
  - validate 只沉淀客观可检测规则，主观评分保留为审查表。
- Suggestions deferred:
  - 是否标注旧 feature 文档 superseded，等 Phase 0 完成后决定。

## 未选择的方案

- 方案 A: 分开优化 Skills 和 Agents → 放弃原因：两条线容易各自正确但整体调用链继续漂移；可作为后续执行拆分方式，不作为总方案。
- 方案 C: 先做自动化质量门，再反推内容优化 → 放弃原因：容易优化成“通过检查”，并过早固化主观标准。

## Scope 边界

- **做:** 审计 `skills/`、`agents/`、`skills-index.json`、`skills-router.json`、`validate` 之间的真实调用链。
- **做:** 建立 `quality-matrix.md`，记录每条关键调用链的输入、输出、风险升级和验证覆盖。
- **做:** 给 SKILL.md 和 agent 定义分别建立评分表。
- **做:** 修复 Blocking 级合同漏洞。
- **做:** 分批优化低分 skills / agents，优先高杠杆阶段路径。
- **做:** 对客观、稳定、可检测的漂移类型补充自动化验证。
- **不做:** 把 `agents/` 变成独立路由器。
- **不做:** 重构命令体系；`commands/` 只参与审计，不是主要改造对象。
- **不做:** 新增、删除或合并技能，除非 Phase 0 发现 Blocking 级结构问题并经 human partner 批准。
- **不做:** 恢复 `.agents/skills/*` 薄包装模型。
- **不做:** 放松 CANON、Iron Law、HARD-GATE 或替换 `human partner` 措辞。

## 质量模型

### Skill 五轴

| 维度 | 3/3 标准 |
|------|----------|
| 可操作性 | 每个关键步骤都有动作、输入、输出和检查点 |
| 示例充足性 | 有好/坏示例或可直接复用的输出模板 |
| 行为收敛性 | 红旗可检测，STOP 后动作和验证失败处理明确 |
| 跨技能衔接 | 入口、出口、前置加载、下游指向和产物路径明确 |
| 说辞表质量 | 常见错误说法、现实、后果能具体改变 agent 行为 |

### Agent 五轴

| 维度 | 3/3 标准 |
|------|----------|
| 职责边界 | 负责 / 不负责清楚，不能绕过阶段技能 |
| 触发条件 | description、README 和 skill 消费点一致 |
| 工具/权限边界 | 实现型、写作型、审计型权限匹配职责，审计类默认只读 |
| 输出可消费性 | 输出格式能被主 session 或对应 skill 直接合并 |
| 阶段一致性 | 不改变阶段顺序、硬门、风险升级和验证证据要求 |

## Phase 计划

### Phase 0: 调用链矩阵与评分基线

产出:
- `docs/features/20260515-skill-agent-quality/quality-matrix.md`
- `docs/features/20260515-skill-agent-quality/scorecard.md`

矩阵字段:
- 阶段技能
- 触发条件
- 可选 / 必需 agent
- agent 必需读取的输入
- agent 必需加载或遵循的 sub-skill
- 输出格式
- 风险升级条件
- validate 是否覆盖
- 未覆盖风险

验收:
- [ ] 所有 `agents/*.md` 都能在 `skills/**/*.md` 中找到消费点，或明确标记为 orphan / future。
- [ ] 所有阶段技能中的 agent token 都指向真实文件。
- [ ] 旧 feature 文档中的静态数量与当前 repo 状态差异已记录。

### Phase 1: Blocking 漏洞修复

修复类型:
- agent 被 README 声明但没有 skill 消费点。
- skill 要求 agent 输出某结构，但 agent 文件没有该输出格式。
- agent 职责越过阶段技能硬门。
- agent 权限模型明显不符合审计 / 实现边界。
- validate 已有规则不能覆盖的高风险合同漂移。

验收:
- [ ] 每个 Blocking 修复都有 before / after 证据。
- [ ] `./validate` 通过。
- [ ] 如改动 SKILL.md 或辅助文件，`skills-lock.json` 已同步。

### Phase 2: 高杠杆路径优化

优先路径:
- `/refine`: `define-workflow-refine` + requirements / scout agents。
- `/plan`: `build-workflow-plan` + plan reviewer agents。
- `/build`: `build-workflow-execute` + execution-engine + implementer agents。
- `/review`: `verify-workflow-review` + review auditors。
- `/ship`: `ship-workflow-ship` + ship auditors。

验收:
- [ ] 每条路径的 skill-agent 输出能端到端消费。
- [ ] 每条路径至少有一个可复用输出模板或报告结构。
- [ ] 每条路径的风险升级规则和 `--full` 行为不冲突。

### Phase 3: 长尾质量拉齐

范围:
- 剩余专项 skills。
- 核心工程 / 内容 / visual agents。
- 辅助文件和评分表同步。

验收:
- [ ] 低分项都有修复或明确 defer 原因。
- [ ] 没有为了评分而增加空泛文字。
- [ ] 每批 `./validate` 通过。

### Phase 4: 自动化沉淀

只加入客观可检测规则，例如:
- agent token 存在性。
- agent 输出格式关键词存在性。
- 审计类 agent 是否出现写权限工具。
- skill-agent 消费点是否缺失。
- 静态库存数字是否再次出现在长期合同文档。

不加入:
- “说辞表是否有力量”这类主观判断。
- “示例是否足够好”这类需要人工审查的质量项。

验收:
- [ ] validate 新规则能捕获本轮已修过的至少一种漂移类型。
- [ ] 新规则误报率可接受，并有清晰失败信息。

## 验收标准

- [ ] `quality-matrix.md` 覆盖所有阶段关键调用链。
- [ ] `scorecard.md` 覆盖所有被纳入范围的 SKILL.md 和 `agents/*.md`。
- [ ] Blocking 漏洞全部修复或明确标记为 human partner 决策点。
- [ ] 每批改动都有验证记录。
- [ ] `./validate` 最终通过。
- [ ] 没有新增固定库存数量的长期合同描述。
- [ ] 没有把 agent 调用规则从阶段技能迁移到 `agents/` 独立维护。

## 核心假设（待验证）

- [ ] 当前 agent frontmatter 能支持计划中的工具 / 模型 / hook 字段 — 通过最小样本或现有宿主文档验证。
- [ ] 调用链矩阵能覆盖真实风险，而不是只重复 README — 通过抽查 `/refine`、`/build`、`/review` 三条路径验证。
- [ ] Skill 五轴和 Agent 五轴能区分质量差异 — 通过 Phase 0 评分分布验证。
- [ ] 自动化规则能防回归且不制造大量误报 — 通过新增规则前后的 validate 运行验证。

## 不做清单（及理由）

- 全量一次性改所有文件 — 回归无法定位，行为变化不可审查。
- 统一行数目标 — 行数不是质量指标。
- 把主观评分直接写进 validate — 会制造脆弱、难维护的文字检查。
- 只优化 agent frontmatter — 不能解决 skill 是否消费 agent 的核心问题。
- 只优化 SKILL.md 文案 — 不能解决 agent 输出是否可合并的问题。
- 修改命令体系 — 当前问题是 skills + agents 质量，不是命令架构重构。

## 待解决问题

- 是否在 Phase 0 后把旧 `skills-optimization` 和 `agent-architect` 标记为 superseded。
- agent frontmatter 能力验证采用本地最小实验还是官方宿主文档查证。
- Phase 4 的 validate 新规则是否单独拆成一个小 PR / 批次。
