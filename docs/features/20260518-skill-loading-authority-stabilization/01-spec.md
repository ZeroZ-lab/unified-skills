# Skill 加载权与 Agent 调度权稳定化 — Spec

## Status Summary
- Owner: current session
- Date: 2026-05-18
- Status: approved

## Artifact Type
`artifact_type: software`

当前 runtime 可执行值：`software` / `document` / `article` / `deck` / `visual`。默认 `software`。

canonical 一级交付类：
- `software` ← `software`
- `content` ← `document` / `article` / `deck`
- `visual` ← `visual`

本 feature 改变的是长期工作流真相，因此额外声明：

`delivery_class: software`

## Goal Alignment
- Source Goal: conversation
- Goal Status: accepted
- Goal Review Score: `10/12`

### One-line Goal
明确 Unified 中 skills 加载权、agent 调度权和类型映射顺序的唯一合法链路，消除 agent 反向加载 skills 或扩大 scope 的歧义。

### Done When
- [ ] Functional: 明确唯一合法加载链路：`router -> stage skill -> current agent or persona`
- [ ] Functional: 明确 agent persona 没有 self-load / self-route / self-expand-scope 权
- [ ] Functional: 明确 `artifact_type -> delivery_class -> persona defaults` 的解释顺序
- [ ] Functional: 明确当前 repo 中哪些文档表述会误导成 agent 自主加载 skills
- [ ] Technical: spec 可直接被 `/plan` 消费，不需要再次讨论“skills 先还是 agent 先”
- [ ] Regression: 不破坏当前 stage-driven contract，不把 persona 重新变成独立路由器
- [ ] Output: `docs/features/20260518-skill-loading-authority-stabilization/01-spec.md`

### Stop Conditions
- [ ] Acceptance 无法验证
- [ ] 需要把 agent 重新定义成拥有独立路由权
- [ ] 需要在本 feature 中一并重写全部 artifact pipeline 或扩展更多 persona
- [ ] 实际范围明显大于当前 Goal（例如要求同步重做所有 stage skills 的内容结构）

## Documentation Impact
- `doc_intent: feature_plus_project`
- `project_truth_changed: yes`
- `affected_project_docs:`
  - `AGENTS.md`
- `rationale:`
  - 这次变更会改变 Unified 的长期工作流真相：谁拥有 skills 加载权、谁只拥有执行权，以及 runtime 类型如何映射到项目级语义。这必须最终同步到 `AGENTS.md`。

## 问题
当前 Unified 已经基本形成了“先 stage skill，后 persona”的模型，但合同里仍存在三类不稳定因素：

1. 某些 agent 文件仍然写着“加载的 Skills”，容易让人误解 agent 自己拥有加载权。
2. 项目已引入 runtime `artifact_type` 与 canonical `delivery_class` 双层语义，但顺序没有被明确钉死。
3. 不同阶段 skill 虽然各自定义了 dispatch 规则，但全局还缺一条“唯一合法加载链路”的总合同，导致维护者需要跨多个文件拼装理解。

如果不先锁死加载权与调度权，后续无论新增 skills 还是新增 persona，都可能重新引入“双重真相”：表面上 stage skill 拥有调度权，实际上 agent 文档又像是半个路由器。

## 选定方案
采用“单一路由权 + 单一解释顺序”的稳定化模型：

1. **skills 加载权归属于 workflow runtime**
   - `router / command / stage skill` 拥有加载权
   - `agent persona` 不拥有加载权
2. **agent 只拥有执行权**
   - persona 只能消费被 stage skill 预先选定的上下文
   - persona 不得 self-load skill，不得 self-route 到新 stage，不得扩大 scope
3. **类型解释顺序固定**
   - 先解析 runtime `artifact_type`
   - 再映射 canonical `delivery_class`
   - `artifact_type` 用于实际路由
   - `delivery_class` 用于项目级角色矩阵、pipeline 语义和长期合同解释
4. **文档表述去二义性**
   - agent 文件中的“加载的 Skills”改成“依赖的阶段技能上下文”或等价表述
   - 在 `AGENTS.md` 写出全局拓扑：`router -> stage skill -> current agent or persona -> merge`

## External References
- Search status: skipped
- Scan date: 2026-05-18
- Fact:
  - 当前项目合同已经明确 `agents/` 是 persona 层，不是独立路由器
  - 当前项目合同已经明确 Unified 激活后先读 `skills-router.json`
  - 若干 agent 文件仍保留“加载的 Skills”章节，容易被理解成 agent 有加载权
  - 当前项目已经存在 runtime `artifact_type` 与 canonical `delivery_class` 双层语义
- Pattern:
  - 稳定的多 agent 工作流通常把“方法选择”与“角色执行”拆层，而不是让角色反向选择方法
  - 当系统同时存在 runtime 类型和项目级语义类型时，必须固定解释顺序，否则维护时会反复分叉
- Inference:
  - 这一轮最重要的不是新增角色，而是锁死加载权与解释顺序
  - 如果不修文档表述，未来维护者仍会自然滑回“agent 自己找 skill”的思维模型
- Unknown:
  - agent 文件的章节名最终用“依赖的阶段技能上下文”还是“典型消费技能”更清晰
  - 是否需要在 `commands/help.md` 中也显式展示这一条唯一合法链路
- Adopt:
  - 采用 `router -> stage skill -> persona` 唯一合法加载链路
  - 采用 `artifact_type -> delivery_class` 单向解释顺序
  - 采用“agent 文档去掉伪加载语义”的稳定化策略
- Reject:
  - 不采用 agent 自主加载 skill
  - 不采用 agent 自主跳阶段或追加 stage skill
  - 不采用在本 feature 中继续扩展更多业务角色

## Scout Review Summary
- CEO:
  - Important: 先锁死加载权模型，再讨论更多流程细节，否则系统复杂度会继续无序增长
- Eng:
  - Blocking: agent 不能同时拥有 persona 权和 routing 权
  - Important: runtime key 与项目级语义 key 必须有固定顺序
- Design:
  - Suggestion: 用一张全局拓扑图写清主链路，比零散文字更稳定
- Blocking resolved:
  - 从“讨论顺序感受”收敛为“定义唯一合法加载链路”
- Important adopted:
  - 不在本 feature 中新增更多 persona
  - 不在本 feature 中重写所有 pipeline
- Suggestions deferred:
  - `commands/help.md` 是否同步展示全局拓扑，留到 plan 阶段决定

## 未选择的方案
- 方案 A：保持现状，只靠口头说明“先 skill 后 agent”
  - 放弃原因：没有写进合同的规则无法长期稳定
- 方案 B：允许 agent 在被 dispatch 后自主追加 skill
  - 放弃原因：会立刻打破 stage skill 的单一调度权
- 方案 C：直接让 `delivery_class` 取代 `artifact_type` 成为 runtime key
  - 放弃原因：当前现有 build/review/export skills 仍直接消费 `artifact_type`，现在切换会把范围拉爆

## 验收标准
- [ ] spec 写清唯一合法加载链路
- [ ] spec 写清 agent 没有加载权
- [ ] spec 写清 `artifact_type -> delivery_class` 顺序
- [ ] spec 点出至少 2 处当前 repo 的歧义表述面

## Risks and Mitigations
| 风险 | 概率 | 影响 | 应对方案 |
|------|------|------|---------|
| 只改术语，不改合同消费点 | 中 | 高 | plan 阶段要求同时改 `AGENTS.md`、agent 文档、Unified runtime 参考 |
| `artifact_type` 和 `delivery_class` 再次被混用 | 中 | 高 | 在 spec 中先锁死顺序，再由 plan 映射到具体文件 |
| 维护者认为 agent 文件里列 skill 只是说明，不值得处理 | 高 | 中 | 把它定义为“伪加载语义”，要求显式改名 |

## Scope 边界
- **做:**
  - 定义加载权归属
  - 定义调度权归属
  - 定义类型解释顺序
  - 明确需要修的歧义表述面
- **不做:**
  - 不新增更多 persona
  - 不扩展更多 artifact 类型
  - 不在本 feature 中重做整个交付 pipeline
