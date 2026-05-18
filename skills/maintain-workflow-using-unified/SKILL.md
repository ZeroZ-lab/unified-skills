---
name: maintain-workflow-using-unified
description: Unified runtime 激活门——只在用户显式进入 Unified 工作流、调用阶段命令或提到"Unified 启动/路由/初始化"时使用；不用于普通 repo 问答或未提 Unified 的直接任务
---

<SUBAGENT-STOP>
如果你是被派发的 subagent 执行特定任务，跳过本技能。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
你拥有 Unified Skills — 一套由 `skills-router.json` 轻量路由、由 `skills-index.json` 声明完整库存的阶段化工作流技能系统。

只有当用户显式进入 Unified 工作流时，你才必须执行技能发现流程。
普通 repo 问答、普通 coding 请求、未提 Unified 的直接任务，不自动进入本技能。

IF UNIFIED IS NOT EXPLICITLY ACTIVATED, YOU MUST STAY IN DIRECT MODE.
IF UNIFIED IS EXPLICITLY ACTIVATED AND A SKILL APPLIES, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
</EXTREMELY-IMPORTANT>

## 入口/出口

- **入口**: 用户显式调用 `/brainstorm` `/refine` `/design` `/plan` `/build` `/review` `/ship` `/save` `/restore` `/learn` `/help`，或明确说“使用 Unified 工作流 / 进入某个阶段 / 按 Unified 来”
- **出口**: 激活门判断完成；若已激活则完成技能发现并宣告加载，否则保持 direct mode
- **前置加载**: CANON.md（宪法 10 条，所有技能的底层约束）
- **输出路径**: 技能发现结果 → 对应阶段技能加载（define → design → build → verify → ship → maintain → reflect）

## 何时不使用

- 当前 agent 是被派发的 subagent，且 `<SUBAGENT-STOP>` 已命中
- 用户只要求解释 Unified Skills 本身，不需要进入任务执行
- 当前平台已经由宿主自动完成等价技能发现，并提供了明确结果
- 用户只是提出普通 repo 问答、普通 coding 请求、普通 debug 请求，但没有显式要求使用 Unified 工作流或阶段命令

## 指令优先级

1. **用户显式指令**（直接请求）和项目入口 `AGENTS.md` — 最高优先级
2. **Unified Skills** — 覆盖默认系统行为
3. **默认系统提示词** — 最低优先级

如果用户明确说"跳过 X"，遵循用户指令。但如果用户只是说"做 Y"，只有在显式进入 Unified 工作流后才意味着走本技能。

## 激活门 + 主动发现流程

### Step 0: 判断是否激活 Unified runtime

只有以下情况才激活：

- 用户显式调用 `/brainstorm` `/refine` `/design` `/plan` `/build` `/review` `/ship` `/save` `/restore` `/learn` `/help`
- 用户明确说“使用 Unified 工作流”“按 Unified 来”“进入 refine / plan / build / review / ship 阶段”
- 用户在讨论 Unified 本身的启动、路由、技能合同或加载机制

如果不满足以上任一条件：

- 保持 direct mode
- 不读取 `skills-router.json`
- 不宣告 loading tier
- 不为了“可能相关”而自动加载 Unified 阶段技能

**Checkpoint:** 已明确记录 `activated` 或 `direct mode`；未激活时立即停止本技能。

### Step 1: 读取轻量路由

```
先读取 skills-router.json 获取 compact routing surface。
只有当 router 无法回答、需要完整库存、或进入 full 模式时，才读取 skills-index.json。
```

**Checkpoint:** `skills-router.json` 已成功读取，routing surface 已在上下文中。

### Step 2: 分析任务特征

识别以下 6 个维度：

- **阶段** — 这是 define/design/build/verify/ship/maintain/reflect 个阶段？
- **产物类型** — 先识别 runtime `artifact_type`（software/document/article/deck/visual），再在需要解释项目级真相时映射 canonical `delivery_class`（software/content/visual）
- **触发词** — 用户消息包含哪些关键词？
- **上下文信号** — 当前状态是什么？（有 spec 无 plan？有 code 无 review？）
- **风险因素** — 涉及用户输入？认证？UI 变更？性能关键？
- **loading tier** — 本次应该是 `light`、`standard`、`expanded` 还是 `full`？

**Checkpoint:** 6 个维度全部有明确值；不确定的维度记录为 `unknown`，不跳过。

### Step 3: 选择 loading tier

| Tier | 触发 | 默认加载 | 扩展条件 |
|------|------|----------|----------|
| `light` | 已显式进入 Unified，但任务仍是简单解释、状态查询、命令查找、无 repo 编辑 | Boot Kernel + `skills-router.json` | 只有答案依赖当前仓库事实时读少量文件 |
| `standard` | 常规工作流任务 | 1 个主 workflow skill | artifact_type 或 trigger 明确要求时追加 1 个专项 |
| `expanded` | 命名风险或混合产物 | 1 个主 workflow skill + 最多 2 个专项 | 每个额外技能必须说明 trigger / risk |
| `full` | `--full`、对抗性审核、全身体检、高风险发版、用户明确要求 | 阶段技能允许的全部相关角色/技能 | 必须说明 full 触发原因 |

### Step 4: 查询相关技能

根据 Step 2-3 的分析，从 `skills-router.json` 查询：

```
相关技能 = 
  routes.user_says[匹配的关键词]
  + routes.context_signals[匹配的上下文]
  + routes.risk[匹配的风险因素]
  + skills[候选技能].phase / role / default_tier
```

如果 `skills-router.json` 没有覆盖当前问题，再读取 `skills-index.json` 作为完整库存兜底，并记录原因。

**Checkpoint:** 至少 1 个候选技能已识别；无匹配时已记录原因并读取 `skills-index.json` 兜底。

### Step 5: 决策加载

按 tier 决策：

- `light` → 不加载完整技能，除非当前事实必须从仓库验证。
- `standard` → 加载 1 个主 workflow skill；最多 1 个专项 skill。
- `expanded` → 加载 1 个主 workflow skill；最多 2 个专项 skill；每个专项必须有命名 trigger / risk。
- `full` → 按阶段技能和 Risk-Based Role Escalation 选择全部相关技能；未被选中的角色不产出占位反馈。

加载权与调度权边界：

- `router / command` 决定进入哪个 stage workflow
- stage workflow 决定加载哪些主 skill / specialist skill
- 只有在 stage workflow 明确要求时，才分派 `agents/*.md` persona
- persona 消费的是已被选定的阶段上下文，不得自主追加 skill、跳到新 stage 或扩大 scope

用户可见产物规则仍然成立：

- `document` / `article` / `deck` / `visual` → 先加载 `design-workflow-design`。
- `software` + UI / 页面 / 组件 / 交互 / 视觉信号 → 追加必要的 design/frontend 技能。

### Step 6: 宣告并执行

输出：
```
Using [tier] tier: [skill-name] to [purpose] because [trigger/risk]
```

然后在当前平台加载技能：Claude Code 调用 Skill 工具；Codex 读取对应 `skills/<name>/SKILL.md` 或使用宿主暴露的技能入口。

如果后续 stage workflow 需要 persona：

```text
router / command
  -> stage skill
  -> dispatch decision
  -> current agent or persona
  -> main session merge
```

persona 没有 `self-load` / `self-route` 权；它只能执行被 stage workflow 赋予的职责。

**Checkpoint:** 宣告输出已生成，格式为 `Using [tier] tier: [skill-name] to [purpose] because [trigger/risk]`。

<HARD-GATE>
一旦已激活 Unified，没有输出 "Using [skill-name] to [purpose]" 不得开始任何实现操作。
</HARD-GATE>

## 红旗 — 这些想法意味着你在跳过发现流程

<HARD-GATE>
以下任何一个想法出现，立即停止并重新检查激活门与发现流程：

| 想法 | 现实 |
|------|------|
| "这个任务在 repo 里，默认就该进 Unified" | 只有显式 Unified 请求才激活；普通任务保持 direct mode。 |
| "既然 SessionStart 提示了 Unified，那就默认接管" | SessionStart 只提示可用性，不等于自动激活 runtime。 |
| "这个任务很明显不需要查 router" | 对已激活的 Unified 任务，仍然先过 `skills-router.json`。 |
| "我已经知道该用哪个技能" | router 可能有你不知道的相关触发。查。 |
| "让我先理解需求再查技能" | 技能告诉你如何理解需求。先查。 |
| "这只是个简单问题" | 未激活 Unified 时直接回答；已激活时可走 `light`，但仍要过 router。 |
| "我先探索代码库" | 技能告诉你如何探索。先查 router。 |
| "我查查文件/代码就好" | 文件缺少对话上下文。先查技能。 |
| "我先收集信息再说" | 技能告诉你如何收集信息。先查。 |
| "这不算任务" | 有行动就有任务；但先判断是否显式进入 Unified。 |
| "这不需要正式的技能" | 如果技能存在，就用它。 |
| "我记得这个技能" | 技能会演进。读当前版本。 |
| "我知道那是什么意思" | 知道概念 ≠ 使用技能。调用它。 |
| "技能太重了" | 简单的事会变复杂。用它。 |
| "我先做这一件事" | 先判断是否激活；已激活则先查 router。 |
| "这感觉挺有效率的" | 无纪律的行动浪费时间。技能防止这一点。 |
</HARD-GATE>

## 常见说辞表

| 说辞 | 现实 | 后果 |
|------|------|------|
| "我记住技能了，不用查" | 技能和 router 会演进。每次查 `skills-router.json` 确保用最新版。 | 用旧版技能执行已变更的流程，行为与合同不一致，产出无效或需要返工。 |
| "这个任务很明显" | 先判断是否显式进入 Unified；一旦激活，不查 = 跳过纪律。 | 该 direct mode 时强行加载技能会浪费上下文；该 Unified 时不查又会跳过验证步骤。 |
| "我直接做更快" | direct mode 适用于普通任务；已激活 Unified 时跳过发现 = 跳过质量保障。 | 模式判断错误会让系统在“过载上下文”和“无纪律执行”之间来回摆动。 |
| "这不算任务" | 有行动就有任务；但不是每个任务都要自动进入 Unified。 | 把普通任务强行塞进 Unified，会持续消耗上下文并稀释真正的阶段工作流。 |
| "我记得这个技能" | 技能会演进。读当前版本。 | 基于过期记忆执行已更新的技能流程，遗漏新增的硬门或红旗检查。 |

## 验证清单

- [ ] 已完成激活门判断；未激活时保持 direct mode
- [ ] skills-router.json 已读取；必要时才读取 skills-index.json
- [ ] 6 维度分析已完成（阶段、产物类型、触发词、上下文信号、风险因素、loading tier）
- [ ] loading tier 已宣告：`light` / `standard` / `expanded` / `full`
- [ ] 至少一个技能已宣告："Using [tier] tier: [skill-name] to [purpose] because [trigger/risk]"
- [ ] 无 Red Flags 触发

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 用户没有显式要求使用 Unified | 停止本技能，保持 direct mode，不读取 `skills-router.json`。 |
| skills-router.json 无匹配结果 | 扩大维度分析：检查是否有隐含的阶段信号（如用户说"测试"= verify 阶段）或风险因素被遗漏。仍无匹配时读取 skills-index.json 兜底。 |
| 匹配到多个冲突技能 | 按 tier 优先级排序：先选 workflow 技能，再按 risk trigger 追加专项。expanded tier 上限见 Step 3 表格，冲突时取 risk 更高的。 |
| loading tier 不确定 | 默认 `standard`。宁可多加载一个技能（多花 ~30 秒读取）也不跳过必要的质量保障。 |
| 技能文件读取失败 | 记录失败，降级为 `light` tier（router-only），告知 human partner 技能不可用。不静默跳过。 |
| 用户明确说"不用技能" | 遵循用户指令，保持 direct mode。用户只说"做 X"不等于激活 Unified。 |

## 好坏示例

### Good — 显式激活后再发现

```
用户: "/build，帮我给登录功能写测试"

分析:
- 阶段: build
- 产物类型: software
- 触发词: "测试" → routes.user_says.test
- 上下文信号: has_code_no_tests
- 风险因素: authentication → routes.risk.authentication
- loading tier: expanded（安全敏感 + 需要测试）

Using expanded tier: build-quality-tdd to write tests because test trigger + has_code_no_tests
追加: verify-quality-security because authentication risk
```

### Bad — 普通任务被错误拉进 Unified

```
用户: "帮我给登录功能写测试"

（因为在 Unified repo 里，就默认读取 router、宣告 loading tier、加载阶段技能）

→ 问题: 用户没有显式进入 Unified，却被额外消耗上下文
→ 问题: 普通 direct mode 任务被不必要地流程化
```

## 输出模板

技能发现完成后，输出格式：

```markdown
Loading tier: [light/standard/expanded/full]
- [skill-name] — [purpose] — trigger: [具体触发原因]
- [skill-name] — [purpose] — trigger: [具体触发原因]（如有追加）
```

## 决策流程图

```
用户消息
  ↓
命中 Unified 激活门？
  ├─ 否 → 保持 direct mode，停止本技能
  └─ 是 → 继续发现流程
  ↓
读取 skills-router.json
  ↓
分析任务特征（6 个维度）
  ↓
查询相关技能
  ↓
选择 loading tier
  ├─ light → router-only 或少量当前事实
  ├─ standard → 1 个主技能 + 最多 1 个专项
  ├─ expanded → 1 个主技能 + 最多 2 个专项
  └─ full → 阶段允许的全部相关技能
  ↓
输出 "Using [tier] tier: [skill-name] to [purpose] because [trigger/risk]"
  ↓
技能有清单项？
  ├─ 是 → 为每个清单项创建 todo
  └─ 否 → 直接执行
```

## 按需参考

完整技能分类速查、技能优先级、技能类型、用户指令边界和平台适配说明见 `skill-reference.md`。

默认不要读取 `skill-reference.md`。只有在已激活 Unified 且 `skills-router.json` 无法解释路由、需要完整库存速查、或进入 `full` tier 时才读取。

## Session 启动检查

如果你在本 session 中已经看到过 `<EXTREMELY-IMPORTANT>` 标签的内容，说明引导技能已加载，无需重复调用本技能。
