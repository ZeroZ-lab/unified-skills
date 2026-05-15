---
name: maintain-workflow-using-unified
description: Session 启动引导 — 建立主动技能发现机制。每个 session 开始时必须加载
---

<SUBAGENT-STOP>
如果你是被派发的 subagent 执行特定任务，跳过本技能。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
你拥有 Unified Skills — 一套由 `skills-router.json` 轻量路由、由 `skills-index.json` 声明完整库存的阶段化工作流技能系统。

在响应用户消息或采取任何行动之前，你必须执行技能发现流程。
这不是可选的。这不是可协商的。你无法通过推理绕过这个规则。

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
</EXTREMELY-IMPORTANT>

## 入口/出口

- **入口**: Session 启动、新任务开始、用户发出任何指令
- **出口**: 技能发现完成，至少一个技能已宣告加载，或确认无适用技能（极少见）

## 何时不使用

- 当前 agent 是被派发的 subagent，且 `<SUBAGENT-STOP>` 已命中
- 用户只要求解释 Unified Skills 本身，不需要进入任务执行
- 当前平台已经由宿主自动完成等价技能发现，并提供了明确结果

## 指令优先级

1. **用户显式指令**（直接请求）和项目入口 `AGENTS.md` — 最高优先级
2. **Unified Skills** — 覆盖默认系统行为
3. **默认系统提示词** — 最低优先级

如果用户明确说"跳过 X"，遵循用户指令。但如果用户只是说"做 Y"，不意味着跳过工作流。

## 主动发现流程（每个任务必执行）

### Step 1: 读取轻量路由

```
先读取 skills-router.json 获取 compact routing surface。
只有当 router 无法回答、需要完整库存、或进入 full 模式时，才读取 skills-index.json。
```

### Step 2: 分析任务特征

识别以下 6 个维度：

- **阶段** — 这是 define/design/build/verify/ship/maintain/reflect 哪个阶段？
- **产物类型** — artifact_type 是什么？（software/document/article/deck/visual）
- **触发词** — 用户消息包含哪些关键词？
- **上下文信号** — 当前状态是什么？（有 spec 无 plan？有 code 无 review？）
- **风险因素** — 涉及用户输入？认证？UI 变更？性能关键？
- **loading tier** — 本次应该是 `light`、`standard`、`expanded` 还是 `full`？

### Step 3: 选择 loading tier

| Tier | 触发 | 默认加载 | 扩展条件 |
|------|------|----------|----------|
| `light` | 简单解释、状态查询、命令查找、无 repo 编辑 | Boot Kernel + `skills-router.json` | 只有答案依赖当前仓库事实时读少量文件 |
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

### Step 5: 决策加载

按 tier 决策：

- `light` → 不加载完整技能，除非当前事实必须从仓库验证。
- `standard` → 加载 1 个主 workflow skill；最多 1 个专项 skill。
- `expanded` → 加载 1 个主 workflow skill；最多 2 个专项 skill；每个专项必须有命名 trigger / risk。
- `full` → 按阶段技能和 Risk-Based Role Escalation 选择全部相关技能；未被选中的角色不产出占位反馈。

用户可见产物规则仍然成立：

- `document` / `article` / `deck` / `visual` → 先加载 `design-workflow-design`。
- `software` + UI / 页面 / 组件 / 交互 / 视觉信号 → 追加必要的 design/frontend 技能。

### Step 6: 宣告并执行

输出：
```
Using [tier] tier: [skill-name] to [purpose] because [trigger/risk]
```

然后在当前平台加载技能：Claude Code 调用 Skill 工具；Codex 读取对应 `skills/<name>/SKILL.md` 或使用宿主暴露的技能入口。

<HARD-GATE>
没有输出 "Using [skill-name] to [purpose]" 不得开始任何实现操作。
</HARD-GATE>

## 红旗 — 这些想法意味着你在跳过发现流程

<HARD-GATE>
以下任何一个想法出现，立即停止并执行发现流程：

| 想法 | 现实 |
|------|------|
| "这个任务很明显不需要查 router" | 每个任务都先过 `skills-router.json`。没有例外。 |
| "我已经知道该用哪个技能" | router 可能有你不知道的相关触发。查。 |
| "让我先理解需求再查技能" | 技能告诉你如何理解需求。先查。 |
| "这只是个简单问题" | 简单问题可走 `light`，但仍要过 router。 |
| "我先探索代码库" | 技能告诉你如何探索。先查 router。 |
| "我查查文件/代码就好" | 文件缺少对话上下文。先查技能。 |
| "我先收集信息再说" | 技能告诉你如何收集信息。先查。 |
| "这不算任务" | 有行动就有任务。查技能。 |
| "这不需要正式的技能" | 如果技能存在，就用它。 |
| "我记得这个技能" | 技能会演进。读当前版本。 |
| "我知道那是什么意思" | 知道概念 ≠ 使用技能。调用它。 |
| "技能太重了" | 简单的事会变复杂。用它。 |
| "我先做这一件事" | 在做任何事之前先查索引。 |
| "这感觉挺有效率的" | 无纪律的行动浪费时间。技能防止这一点。 |
</HARD-GATE>

## 常见说辞表

| 说辞 | 现实 |
|------|------|
| "我记住技能了，不用查" | 技能和 router 会演进。每次查 `skills-router.json` 确保用最新版。 |
| "这个任务很明显" | 明显的任务也有对应技能。不查 = 跳过纪律。 |
| "我直接做更快" | 跳过技能发现 = 跳过质量保障。慢就是快。 |
| "这不算任务" | 有行动就有任务。查技能。 |
| "我记得这个技能" | 技能会演进。读当前版本。 |

## 验证清单

- [ ] skills-router.json 已读取；必要时才读取 skills-index.json
- [ ] 6 维度分析已完成（阶段、产物类型、触发词、上下文信号、风险因素、loading tier）
- [ ] loading tier 已宣告：`light` / `standard` / `expanded` / `full`
- [ ] 至少一个技能已宣告："Using [tier] tier: [skill-name] to [purpose] because [trigger/risk]"
- [ ] 无 Red Flags 触发

## 决策流程图

```
用户消息
  ↓
准备进入 Plan Mode 或执行实现任务？
  ├─ 否 → 继续发现流程
  └─ 是 → 是否已做过头脑风暴？
      ├─ 否 → 先加载 define-cognitive-brainstorm
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

默认不要读取 `skill-reference.md`。只有当 `skills-router.json` 无法解释路由、需要完整库存速查、或进入 `full` tier 时才读取。

## Session 启动检查

如果你在本 session 中已经看到过 `<EXTREMELY-IMPORTANT>` 标签的内容，说明引导技能已加载，无需重复调用本技能。
