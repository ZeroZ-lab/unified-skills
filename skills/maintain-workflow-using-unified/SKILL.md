---
name: maintain-workflow-using-unified
description: Session 启动引导 — 建立主动技能发现机制。每个 session 开始时必须加载
---

<SUBAGENT-STOP>
如果你是被派发的 subagent 执行特定任务，跳过本技能。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
你拥有 Unified Skills — 44 个技能覆盖 6 阶段工作流。

在响应用户消息或采取任何行动之前，你必须执行技能发现流程。
这不是可选的。这不是可协商的。你无法通过推理绕过这个规则。

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
</EXTREMELY-IMPORTANT>

## 指令优先级

1. **用户显式指令**（CLAUDE.md、直接请求）— 最高优先级
2. **Unified Skills** — 覆盖默认系统行为
3. **默认系统提示词** — 最低优先级

如果用户明确说"跳过 X"，遵循用户指令。但如果用户只是说"做 Y"，不意味着跳过工作流。

## 主动发现流程（每个任务必执行）

### Step 1: 读取技能索引

```
读取 skills-index.json 获取完整技能地图
```

### Step 2: 分析任务特征

识别以下 5 个维度：

- **阶段** — 这是 define/build/verify/ship/maintain/reflect 哪个阶段？
- **产物类型** — artifact_type 是什么？（software/document/article/deck/visual）
- **触发词** — 用户消息包含哪些关键词？
- **上下文信号** — 当前状态是什么？（有 spec 无 plan？有 code 无 review？）
- **风险因素** — 涉及用户输入？认证？UI 变更？性能关键？

### Step 3: 查询相关技能

根据 Step 2 的分析，从 skills-index.json 查询：

```
相关技能 = 
  by_phase[当前阶段] 
  + by_artifact_type[产物类型].required
  + by_trigger.user_says[匹配的关键词]
  + by_trigger.context_signals[匹配的上下文]
  + by_risk[匹配的风险因素]
```

### Step 4: 决策加载

对查询结果中的每个技能：

- **required 标记的** → 必须加载
- **sequence 标记的** → 按顺序加载
- **其他** → 如果有 1% 可能相关，加载

### Step 5: 宣告并执行

输出：
```
Using [skill-name] to [purpose]
```

然后调用 Skill 工具加载技能。

<HARD-GATE>
没有输出 "Using [skill-name] to [purpose]" 不得开始任何实现操作。
</HARD-GATE>

## Red Flags — 这些想法意味着你在跳过发现流程

<HARD-GATE>
以下任何一个想法出现，立即停止并执行发现流程：

| 想法 | 现实 |
|------|------|
| "这个任务很明显不需要查索引" | 每个任务都查。没有例外。 |
| "我已经知道该用哪个技能" | 索引可能有你不知道的相关技能。查。 |
| "让我先理解需求再查技能" | 技能告诉你如何理解需求。先查。 |
| "这只是个简单问题" | 简单问题也有对应技能。查索引。 |
| "我先探索代码库" | 技能告诉你如何探索。先查索引。 |
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
读取 skills-index.json
  ↓
分析任务特征（5 个维度）
  ↓
查询相关技能
  ↓
有 required 技能？
  ├─ 是 → 必须加载
  └─ 否 → 有 1% 可能相关的？
      ├─ 是 → 加载
      └─ 否 → 直接响应（极少见）
  ↓
输出 "Using [skill-name] to [purpose]"
  ↓
技能有清单项？
  ├─ 是 → 为每个清单项创建 todo
  └─ 否 → 直接执行
```

## 技能分类速查

### Define 阶段（想法模糊、需要方案对比、收敛到规格）

- `define-cognitive-brainstorm` — 想法模糊、开放性问题、需要方案对比
- `define-workflow-refine` — 模糊想法收敛到 spec
- `define-workflow-spec` — 规格化文档

### Build 阶段（拆分任务、增量生成产物）

- `build-workflow-plan` — 拆分任务
- `build-workflow-execute` — 增量生成产物
- `build-quality-tdd` — 写逻辑代码（MUST）
- `build-cognitive-context` — 上下文混乱或输出质量下降
- `build-cognitive-source-driven` — 使用不熟悉的 API/框架
- `build-cognitive-execution-engine` — 执行引擎
- `build-cognitive-decision-record` — 面临技术选型或架构决策
- `build-infrastructure-git` — 版本控制操作
- `build-frontend-ui-engineering` — 构建/修改 UI 组件
- `build-frontend-browser-testing` — 浏览器自动化测试
- `build-backend-api-design` — 设计 API/接口/数据合约
- `build-backend-database` — 设计 schema/写迁移/优化查询
- `build-backend-service-patterns` — 服务模式和架构
- `build-content-writing` — 文档/文章/PPT 内容
- `build-content-layout` — 版式设计/信息层级

### Verify 阶段（质量把关、Bug 调查、审查）

- `verify-workflow-review` — 产物完成后质量把关
- `verify-workflow-debug` — 遇到 bug/测试失败/意外行为（MUST）
- `verify-frontend-accessibility` — 构建 UI 组件/表单/导航
- `verify-quality-integration-testing` — 集成测试
- `verify-quality-performance` — 性能不达标或上线前审查
- `verify-quality-security` — 涉及用户输入/认证/数据存储
- `verify-quality-code-review-standards` — 代码审查标准
- `verify-content-review` — 内容审查
- `verify-visual-review` — 视觉审查
- `verify-workflow-receiving-review` — 接收审查反馈
- `verify-quality-simplify` — 代码变得复杂/重复/过度抽象

### Ship 阶段（发布检查、部署、监控）

- `ship-workflow-ship` — 审查通过后上线或交付
- `ship-infrastructure-ci-cd` — 设置/修改 CI/CD 管道
- `ship-infrastructure-deploy` — 部署操作
- `ship-workflow-artifact-export` — 产物导出
- `ship-workflow-canary` — 代码已部署需要持续验证
- `ship-workflow-land` — PR 合并到主分支并验证部署
- `ship-workflow-doc-sync` — 文档同步

### Maintain 阶段（可观测性、上下文管理、学习记录）

- `maintain-infrastructure-observability` — 可观测性
- `maintain-workflow-deprecation-migration` — 废弃迁移
- `maintain-workflow-context-save` — 保存工作上下文供后续恢复
- `maintain-workflow-context-restore` — 新 session 继续之前的工作
- `maintain-workflow-learn` — 发现项目模式/踩坑/偏好需要持久化

### Reflect 阶段（事后回顾、文档工程）

- `reflect-team-retro` — 功能完成/里程碑达成/事故处理后复盘
- `reflect-team-documentation` — 记录架构决策或维护项目知识

## 技能优先级

当多个技能可能适用时：

1. **流程技能优先**（brainstorm、debug、tdd）— 决定如何做
2. **实现技能其次**（ui-engineering、api-design）— 指导执行

## 技能类型

- **刚性技能**（TDD、调试、审查）：严格遵循，不要适应掉纪律
- **柔性技能**（模式、设计）：根据上下文调整原则

技能本身会告诉你它是哪种类型。

## 用户指令

用户指令说明"做什么"，不是"怎么做"。"添加 X" 或 "修复 Y" 不意味着跳过工作流。

## 平台适配

技能使用 Claude Code 的工具名和约定。在其他平台上的等效方式：

- **Claude Code**：使用 `Skill` 工具调用技能。当技能被调用时，其内容会被加载并呈现——直接遵循。不要用 Read 工具读技能文件。
- **Codex CLI**：技能通过 `.agents/skills/` 目录自动发现。`skill` 工具的工作方式与 Claude Code 的 `Skill` 工具相同。

## Session 启动检查

如果你在本 session 中已经看到过 `<EXTREMELY-IMPORTANT>` 标签的内容，说明引导技能已加载，无需重复调用本技能。
