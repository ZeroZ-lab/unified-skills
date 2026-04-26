# Command-Agent-Skill 三层架构设计文档

**版本：** 1.0  
**日期：** 2026-04-25  
**作者：** Unified Skills Architecture Team  
**状态：** 设计阶段

---

## 文档摘要

本文档定义了 Unified Skills 项目从"提示词组织系统"升级为"Agent 工作制度"的完整架构方案。核心理念是：

> **Command 负责阶段切分，Agent 负责角色分工，Skills 负责能力注入。**

通过三层架构分离，Unified Skills 将从当前的"快捷方式模式"（Commands 只是简单的技能调用入口）升级为"编排协议模式"（Commands 定义清晰的工作流状态机，Agents 代表专业责任边界，Skills 提供可复用方法论）。

**关键变更：**
- 新增 7 个核心工程角色 Agents（requirements-analyst、task-planner、software-engineer 等）
- 重命名 4 个 Review Agents（补充 phase 前缀）
- 重写 8 个 Commands（从 1 行代码升级为完整的 Phase 编排协议）
- 保持 artifact_type 路由逻辑在 Skill 层（设计决策）
- 保留 11 个阶段专属 Agents（已有正确命名）

**预期成果：**
- 更清晰的责任边界（Command/Agent/Skill 各司其职）
- 更强的可扩展性（新增 Agent 或 Skill 不影响其他层）
- 更好的可维护性（每层独立演进）
- 更高的可理解性（架构意图明确）

---

## 目录

### 第一部分：架构原理
1.1 三层架构定义  
1.2 设计哲学与核心原则  
1.3 与现有编排模式的关系  
1.4 架构演进路径  

### 第二部分：现状分析
2.1 Commands 层现状  
2.2 Agents 层现状  
2.3 Skills 层现状  
2.4 artifact_type 路由机制分析  
2.5 并行执行模式分析  
2.6 现状问题总结  

### 第三部分：重构方案
3.1 新 Agent 体系设计  
3.2 新 Command 结构设计  
3.3 Skills 层调整  
3.4 文件组织结构  

### 第四部分：迁移实施计划
4.1 迁移策略  
4.2 Phase 1：创建新 Agents  
4.3 Phase 2：重命名 Review Agents  
4.4 Phase 3：重写 Commands  
4.5 Phase 4：更新 Skills 引用  
4.6 Phase 5：更新 load-manifest.json  
4.7 Phase 6：回归测试  
4.8 风险与回滚策略  

### 第五部分：验证与测试
5.1 架构一致性验证清单  
5.2 功能回归测试用例  
5.3 性能与并行执行验证  
5.4 文档完整性检查  

### 附录
A. 完整重命名映射表  
B. 新 Agent 定义清单  
C. 新 Command 模板清单  
D. 术语表  
E. 参考资料  

---

# 第一部分：架构原理

## 1.1 三层架构定义

Unified Skills 的三层架构将系统职责清晰地分为三个层次，每层有明确的边界和职责：

### Command 层：流程控制层

**本质：** 任务编排器 / Workflow Controller / 阶段协议

**职责：**
- 定义复杂任务的阶段切分（Phase 1 → Phase 2 → Phase 3）
- 指定每个阶段的输入、输出、验收标准
- 决定哪些阶段必须串行、哪些可以并行
- 定义阶段间的状态转换条件
- 声明最终产物的质量门控

**不负责：**
- 具体的执行逻辑（由 Agent 负责）
- 技术实现细节（由 Skill 负责）
- 角色能力定义（由 Agent 负责）

**类比：** Command 像电影导演，负责整体节奏和场景调度，但不亲自演戏。

**示例：**
```yaml
# Command: /plan
Phase 1: Parse Spec → Agent: task-planner → Output: 02-plan.md (draft)
Phase 2: Multi-Role Review (parallel) → Agents: 4 reviewers → Output: review-comments.md
Phase 3: Refine Plan → Agent: task-planner → Output: 02-plan.md (final)
```

---

### Agent 层：角色责任层

**本质：** 专业责任边界 / Role Protocol / 认知分工

**职责：**
- 代表一种专业视角或执行角色
- 定义该角色的责任范围和决策权限
- 声明该角色需要加载哪些 Skills
- 提供该角色的输出格式和质量标准

**不负责：**
- 工作流编排（由 Command 负责）
- 具体方法论（由 Skill 负责）
- 跨角色协调（由 Command 负责）

**类比：** Agent 像剧组中的演员，每个人有明确的角色定位（主角/配角/专家顾问），但不决定剧情走向。

**关键价值：** 避免 self-confirming loop（自己提需求、自己实现、自己验收通过）。

**示例：**
```yaml
# Agent: software-engineer
职责：软件开发（TDD、API 设计、数据库、前后端）
加载 Skills: build-quality-tdd, build-backend-*, build-frontend-*
不负责：需求分析（requirements-analyst）、任务分解（task-planner）、代码审查（review-code-reviewer）
```

---

### Skill 层：能力注入层

**本质：** 可复用方法论 / Capability Protocol / 执行手册

**职责：**
- 提供具体的执行流程（Step 1 → Step 2 → Step 3）
- 定义入口/出口条件、验证清单、红旗规则
- 包含最佳实践、常见陷阱、决策框架
- 可被多个 Agent 复用

**不负责：**
- 决定何时调用（由 Command 或 Agent 决定）
- 角色责任定义（由 Agent 负责）
- 工作流状态管理（由 Command 负责）

**类比：** Skill 像剧本和表演技巧手册，告诉演员"怎么演"，但不决定"谁来演"或"什么时候演"。

**示例：**
```yaml
# Skill: build-quality-tdd
提供：RED → GREEN → REFACTOR 循环的详细步骤
可被复用：software-engineer、data-architect、api-designer 都可以加载此 Skill
不决定：何时使用 TDD（由 Command 根据 artifact_type 决定）
```

---

### 三层关系图

```
┌─────────────────────────────────────────────────────────┐
│ Command 层：阶段编排                                      │
│ ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│ │ Phase 1 │ →  │ Phase 2 │ →  │ Phase 3 │              │
│ └────┬────┘    └────┬────┘    └────┬────┘              │
└──────┼──────────────┼──────────────┼────────────────────┘
       │              │              │
       ▼              ▼              ▼
┌─────────────────────────────────────────────────────────┐
│ Agent 层：角色分工                                        │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│ │ Agent A  │  │ Agent B  │  │ Agent C  │               │
│ │(并行)    │  │(并行)    │  │(串行)    │               │
│ └────┬─────┘  └────┬─────┘  └────┬─────┘               │
└──────┼─────────────┼─────────────┼───────────────────┘
       │              │              │
       ▼              ▼              ▼
┌─────────────────────────────────────────────────────────┐
│ Skill 层：能力注入                                        │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│ │ Skill X  │  │ Skill Y  │  │ Skill Z  │               │
│ │(方法论)  │  │(方法论)  │  │(方法论)  │               │
│ └──────────┘  └──────────┘  └──────────┘               │
└─────────────────────────────────────────────────────────┘
```

**信息流向：**
- **向下流动：** Command 调用 Agent，Agent 加载 Skill
- **向上反馈：** Skill 产出结果，Agent 整合输出，Command 验收产物
- **横向隔离：** 同层元素互不直接调用（Agent 不调用 Agent，Skill 不调用 Skill）

---

### 三层对比表

| 维度 | Command | Agent | Skill |
|------|---------|-------|-------|
| **本质** | 工作流状态机 | 专业责任边界 | 可复用方法论 |
| **回答的问题** | 分几个阶段？何时进入下一阶段？ | 谁来做？负责什么？ | 怎么做？步骤是什么？ |
| **类比** | 导演 | 演员 | 剧本+表演技巧 |
| **数量级** | 少（8个） | 中（15-25个） | 多（40-50个） |
| **稳定性** | 高（很少变化） | 中（按需扩展） | 低（频繁优化） |
| **复用性** | 低（项目特定） | 中（跨项目复用） | 高（跨角色复用） |
| **文件格式** | YAML frontmatter + Phase 定义 | YAML frontmatter + 职责描述 | YAML frontmatter + 流程步骤 |
| **调用方式** | 用户输入 `/command` | Command 或 Skill 引用 | Agent 加载 |

---

## 1.2 设计哲学与核心原则

### 设计哲学

Unified Skills 的三层架构基于以下核心哲学：

#### 哲学 1：分离关注点（Separation of Concerns）

**问题：** 如果 Command、Agent、Skill 混在一起，会导致：
- 修改工作流时影响执行逻辑
- 修改方法论时影响角色定义
- 难以复用、难以测试、难以理解

**解决：** 三层分离后：
- Command 变更不影响 Agent 和 Skill
- Agent 扩展不影响 Command 和 Skill
- Skill 优化不影响 Command 和 Agent

#### 哲学 2：单一职责原则（Single Responsibility Principle）

**问题：** 一个"万能 Agent"既做需求分析、又做代码实现、还做审查验收，容易出现 self-confirming loop。

**解决：** 每个 Agent 只负责一种专业视角：
- requirements-analyst 只做需求分析
- software-engineer 只做代码实现
- review-code-reviewer 只做代码审查

#### 哲学 3：依赖倒置原则（Dependency Inversion Principle）

**问题：** 如果 Command 直接依赖具体的 Skill 实现，扩展时需要修改 Command。

**解决：** Command 依赖 Agent 抽象，Agent 依赖 Skill 抽象：
```
Command → Agent 接口 → 具体 Agent → Skill 接口 → 具体 Skill
```

#### 哲学 4：开闭原则（Open-Closed Principle）

**问题：** 新增功能时需要修改现有代码，容易引入 bug。

**解决：** 通过扩展而非修改来增加功能：
- 新增 Agent：不修改 Command，只在 Command 中引用新 Agent
- 新增 Skill：不修改 Agent，只在 Agent 中加载新 Skill
- 新增 Command：不修改现有 Command

---

### 核心原则

#### 原则 1：Command 不写细节，只管阶段

**定义：** Command 应该像导演，不像演员。

**具体要求：**
- Command 定义 Phase 结构（Phase 1 → Phase 2 → Phase 3）
- 每个 Phase 指定 Agent、Skills、Input、Output、Validation
- Command 不包含具体的执行逻辑（if/else、循环、算法）
- Command 不直接操作文件或调用工具

**反例（违反原则）：**
```yaml
# ❌ 错误：Command 包含执行逻辑
Phase 1:
  if artifact_type == "software":
    run TDD
  else:
    run content writing
```

**正例（符合原则）：**
```yaml
# ✓ 正确：Command 只定义阶段，由 Agent 决定执行逻辑
Phase 1: Generate Artifact
  Agent: software-engineer (if artifact_type: software)
  Agent: content-writer (if artifact_type: document)
  Skills: [由 Agent 决定]
```

---

#### 原则 2：Agent 不塞太多能力，只定义责任

**定义：** Agent 应该保持稳定，代表一种专业视角。

**具体要求：**
- 一个 Agent 只代表一种角色（CEO / 工程师 / 设计师 / 安全专家）
- Agent 可以加载多个相关 Skills，但这些 Skills 必须属于同一领域
- Agent 不应该根据条件加载完全不同的 Skill 集合
- Agent 可以跨项目复用

**反例（违反原则）：**
```yaml
# ❌ 错误：workflow-execute 根据 artifact_type 加载完全不同的技能
Agent: workflow-execute
  if artifact_type == "software":
    load: TDD, API design, Database, Frontend, Backend
  elif artifact_type == "document":
    load: Content writing, Layout
  elif artifact_type == "visual":
    load: Visual design
```

**正例（符合原则）：**
```yaml
# ✓ 正确：拆分为专业角色
Agent: software-engineer
  load: TDD, API design, Database, Frontend, Backend

Agent: content-writer
  load: Content writing

Agent: visual-designer
  load: Visual design, Layout
```

---

#### 原则 3：Skill 要可组合、可替换

**定义：** Skill 应该像插件，可以被多个 Agent 复用。

**具体要求：**
- 一个 Skill 只解决一种可复用问题
- Skill 不应该超过 400 行（当前最大 348 行）
- Skill 可以被多个 Agent 加载
- Skill 可以被同类 Skill 替换（如 mysql-schema-design 替换为 postgres-schema-design）

**判断标准：**
```
一个 Skill 是否好 = 是否只解决一种可复用问题
```

**反例（违反原则）：**
```yaml
# ❌ 错误：backend-development-skill（过大、不聚焦）
包含：API 设计 + 数据库 + 服务模式 + 部署 + 监控
```

**正例（符合原则）：**
```yaml
# ✓ 正确：拆分为小而强的 Skills
build-backend-api-design
build-backend-database
build-backend-service-patterns
ship-infrastructure-deploy
maintain-infrastructure-observability
```

---

#### 原则 4：并行扇出必须在单个 assistant turn 中发起

**定义：** 真正的并行执行需要在同一条消息中同时调用多个 Agent。

**具体要求：**
- 并行分派的 Agents 必须在同一个 `<function_calls>` 块中调用
- 分开调用是串行，不是并行
- 每个 subagent 独立上下文，互不干扰
- 合并步骤在主 agent 上下文中完成

**示例（并行分派 4 个 plan reviewers）：**

```
在同一条 assistant 消息中，同时发起 4 个 Agent 工具调用：
  - Agent 1: plan-ceo-reviewer — 审查商业价值
  - Agent 2: plan-eng-reviewer — 审查工程可行性
  - Agent 3: plan-design-reviewer — 审查用户体验
  - Agent 4: plan-security-reviewer — 审查安全合规

每个 Agent 独立上下文运行，产出各自的审查报告。
所有 Agent 完成后，在主 session 中合并为统一反馈文档。
```

**反例（串行分派，不是并行）：**
```
Turn 1: 调用 plan-ceo-reviewer → 等待完成
Turn 2: 调用 plan-eng-reviewer → 等待完成
Turn 3: 调用 plan-design-reviewer → 等待完成
Turn 4: 调用 plan-security-reviewer → 等待完成
❌ 这是串行执行，总耗时 = 4 个 Agent 耗时之和
```

---

#### 原则 5：Phase 间通过文件通信，不通过对话历史

**定义：** 阶段之间的信息传递通过文件系统完成，不依赖对话上下文。

**具体要求：**
- 每个 Phase 的产出必须写入文件（如 `02-plan.md`、`review.md`）
- 下一个 Phase 从文件读取输入，不依赖前一个 Phase 的对话记忆
- 这确保了 Phase 的幂等性——可以单独重跑某个 Phase
- Agent 的上下文是独立的，不能假设"之前的对话还记得"

**为什么重要：**
- Subagent 没有主 session 的对话历史
- 文件是唯一可靠的跨 Phase 通信机制
- 支持断点续做——中断后从文件恢复状态

---

#### 原则 6：编排深度最大为 1

**定义：** Command 可以调用 Agent，Agent 可以加载 Skill，但不允许嵌套更深。

**具体要求：**
- Command → Agent → Skill（最大深度 3 层）
- 不允许 Command → Agent → Sub-Agent → Skill（深度 4）
- 不允许 Skill 调用 Skill（横向隔离）
- 不允许 Agent 调用 Agent（横向隔离）

**为什么重要：**
- 深度嵌套导致上下文丢失和调试困难
- 每增加一层，可观测性指数级下降
- 扁平结构更容易理解和维护

---

### 原则总结表

| 编号 | 原则 | 一句话总结 |
|------|------|-----------|
| 1 | Command 不写细节，只管阶段 | Command 是导演，不是演员 |
| 2 | Agent 不塞太多能力，只定义责任 | Agent 是角色，不是万能工具 |
| 3 | Skill 要可组合、可替换 | Skill 是插件，不是定制件 |
| 4 | 并行扇出必须在单个 turn 中发起 | 同一条消息，多个 Agent 调用 |
| 5 | Phase 间通过文件通信 | 文件是唯一的跨 Phase 通信机制 |
| 6 | 编排深度最大为 1 | Command → Agent → Skill，到此为止 |

---

## 1.3 与现有编排模式的关系

Unified Skills 已有一套成熟的编排模式（定义在 `references/orchestration-patterns.md`），三层架构与这些模式的关系如下：

### 三层架构是编排模式的容器

编排模式描述的是"怎么做"（How），三层架构描述的是"谁来做"（Who）和"在哪里做"（Where）：

```
编排模式（How）          三层架构（Who + Where）
─────────────          ──────────────────────
Direct Invocation   →  Command 直接调用单个 Agent
Parallel Fan-Out    →  Command 在一个 Phase 中并行分派多个 Agent
Sequential Pipeline →  Command 的多个 Phase 串行执行
Research Isolation  →  Command 分派 Agent 做研究，结果写入文件
```

### 各编排模式在三层的映射

#### Direct Invocation（直接调用）

**模式：** 一个 Command 直接调用一个 Agent，不经过并行或复杂编排。

**在三层架构中：**
```
Command: /save
  Phase 1: Save Context
    Agent: （无，主 session 直接执行）
    Skill: maintain-workflow-context-save
```

**适用命令：** `/save`、`/restore`、`/learn`

---

#### Parallel Fan-Out + Merge（并行扇出 + 合并）

**模式：** 一个 Phase 同时分派多个 Agent，各自独立产出，最后合并。

**在三层架构中：**
```
Command: /review
  Phase 1: Multi-Role Review (Parallel)
    Agents: [review-code-reviewer, review-security-auditor,
             review-test-engineer, review-accessibility-auditor]
    （4 个 Agent 在同一个 assistant turn 中并行调用）
  Phase 2: Merge Feedback
    Agent: （主 session 合并）
    Output: review.md
```

**适用命令：** `/plan`（Phase 2）、`/review`、`/refine`（Phase 1.6）、`/ship`（Phase B）

---

#### Sequential Pipeline（顺序管道）

**模式：** 多个 Phase 串行执行，前一 Phase 的产出是后一 Phase 的输入。

**在三层架构中：**
```
Command: /build
  Phase 1: Load Plan → Agent: task-planner
  Phase 2: Execute Slices → Agent: software-engineer (循环)
  Phase 3: Verify → Skill: verify-workflow-debug
  Phase 4: Record → Skill: build-cognitive-decision-record
```

**适用命令：** `/build`、`/refine`

---

#### Research Isolation（研究隔离）

**模式：** 将研究任务分派给独立 Agent，避免主上下文污染。

**在三层架构中：**
```
Command: /refine
  Phase 1.3: External Scan
    Agent: （独立 subagent）
    Skill: define-workflow-refine（External Scan 部分）
    Output: 写入文件（分层结果）
```

**适用命令：** `/refine`（External Scan）

---

### 反模式的防御

三层架构天然防御了 `orchestration-patterns.md` 中定义的反模式：

| 反模式 | 三层架构如何防御 |
|--------|-----------------|
| Router Persona | Agent 不根据条件加载完全不同的 Skill 集合；拆分为专业角色 |
| Persona Chaining | Agent 不调用 Agent；横向隔离原则 |
| Sequential Paraphraser | 每个 Phase 必须有明确的 Input/Output/Validation |
| Deep Persona Trees | 编排深度最大为 1（原则 6） |

---

## 1.4 架构演进路径

### 演进阶段

```
Stage 0（当前）          Stage 1（本次重构）       Stage 2（未来）
快捷方式模式              编排协议模式              自适应编排模式
───────────              ────────────              ────────────
Commands 是 1 行         Commands 定义 Phase       Commands 可嵌套子工作流
Skills 做 Phase 编排     Agents 定义角色           Agents 可组合为团队
artifact_type 在 Skill   artifact_type 仍在 Skill   artifact_type 可能提升到 Command
workflow-* 是万能 Agent   专业角色 Agent            Agent 自动发现和加载
15 agents               22 agents                按需扩展
```

### Stage 0 → Stage 1 的关键变化

| 维度 | Stage 0（当前） | Stage 1（本次重构） |
|------|----------------|-------------------|
| Command 文件 | 1 行代码 | 完整的 Phase 编排协议 |
| Agent 分类 | 只有审查角色 | 审查角色 + 核心工程角色 |
| Agent 命名 | 不一致（code-reviewer vs plan-ceo-reviewer） | 统一 phase-lens-role 命名 |
| workflow-* Agent | 万能路由（根据 artifact_type 加载不同技能） | 拆分为专业角色 |
| artifact_type 路由 | 分散在 4 个 workflow skills | 保持现状（设计决策） |
| 可扩展性 | 新增产物类型需改 workflow Agent | 新增产物类型只需新增 Agent |

### Stage 2 的展望（不在本次范围）

Stage 2 是远期愿景，不在本次重构范围内：
- Command 可嵌套子工作流（如 `/build` 内嵌 `/test`）
- Agent 团队模式（如 "全栈团队" = software-engineer + data-architect + api-designer）
- artifact_type 路由可能提升到 Command 层（如果 Skill 层路由证明维护成本过高）
- Agent 自动发现：根据 spec 自动选择合适的 Agent 组合

---

# 第二部分：现状分析

## 2.1 Commands 层现状

### 概览

当前 8 个 Command 文件全部采用"快捷方式模式"——每个文件只有 1-2 行，实质是一个技能加载入口，不包含任何阶段编排逻辑。

### 逐命令分析

#### /refine

**文件：** `commands/refine.md`

```yaml
---
description: 需求提炼 + External Scan + 多角色 Idea Scout 审查
---
加载 CANON.md → 调用 .agents/skills/refine/SKILL.md。
```

**实际行为：** 将所有逻辑委托给 `define-workflow-refine` 技能，包括：
- 需求澄清（5W1H 提问）
- External Scan（按 artifact_type 搜索已有方案）
- Idea Scout Army 并行审查（3 个 scouts）
- 需求文档生成

**问题：** Command 没有定义 Phase 结构，所有编排逻辑隐藏在 Skill 内部。

---

#### /plan

**文件：** `commands/plan.md`

```yaml
---
description: 从 spec 到详细任务分解 + 多角色计划审查
---
加载 CANON.md → 调用 .agents/skills/plan/SKILL.md。
```

**实际行为：** 委托给 `build-workflow-plan` 技能，包括：
- 读取 spec 的 artifact_type
- 根据类型选择依赖图策略（software → vertical slices；document → chapter groups）
- 任务分解（acceptance criteria + dependencies + parallel safety）
- Plan Review Army 并行审查（4 个 reviewers）
- 计划迭代

**问题：** 3 个 Phase（解析 → 审查 → 迭代）的结构没有在 Command 层声明。

---

#### /build

**文件：** `commands/build.md`

```yaml
---
description: 按计划增量生成产物（软件 TDD / 内容 / 视觉）+ ADR
---
调用 .agents/skills/build/SKILL.md。
```

**实际行为：** 委托给 `build` 技能，再委托给 `build-cognitive-execution-engine`（选择执行模式）和 `build-workflow-execute`（执行增量循环）：
- 选择执行模式（inline / subagent / parallel）
- 读取 artifact_type，加载对应领域技能
- 执行增量循环（每切片：生成 → 验证 → 记录）
- 遇到决策时写 ADR
- 遇到 Bug 时进入调试

**问题：** artifact_type 路由在 Skill 层完成，workflow-execute 根据 artifact_type 加载完全不同的技能集。

---

#### /review

**文件：** `commands/review.md`

```yaml
---
description: 按产物类型审查（软件五轴 / 内容 / 视觉）+ 多角色并行审查
---
调用 .agents/skills/review/SKILL.md。
```

**实际行为：** 委托给 `verify-workflow-review` 技能：
- 读取 artifact_type，路由到对应的审查策略
- software → 五轴审查（正确性、可读性、架构、安全、性能）
- document/article → 内容审查
- visual/deck → 视觉审查
- Review Army 并行分派（4 个 reviewers）

**问题：** 审查策略选择逻辑在 Skill 内部，Command 没有声明并行分派策略。

---

#### /ship

**文件：** `commands/ship.md`

```yaml
---
description: 发布准备（安全/性能/无障碍/文档审计）+ 导出/发布
---
调用 .agents/skills/ship/SKILL.md。
```

**实际行为：** 委托给 `ship-workflow-ship` 技能：
- Phase A: 准备发布
- Phase B: Ship Audit Army 并行审计（4 个 auditors）
- Phase C: 导出/发布
- Phase D: 文档同步

**问题：** 4 个 Phase 的结构和 Ship Audit Army 的并行策略没有在 Command 层声明。

---

#### /save

**文件：** `commands/save.md`

```yaml
---
description: 保存当前工作上下文为 checkpoint
---
调用 .agents/skills/save/SKILL.md。
```

**实际行为：** 委托给 `maintain-workflow-context-save` 技能，保存工作上下文到 `.claude/checkpoints/`。

**问题：** 这是最简单的 Command，1 行委托模式在这里是合理的。但为了一致性，也应该定义 Phase 结构。

---

#### /restore

**文件：** `commands/restore.md`

```yaml
---
description: 从 checkpoint 恢复工作上下文
---
调用 .agents/skills/restore/SKILL.md。
```

**实际行为：** 委托给 `maintain-workflow-context-restore` 技能，从 checkpoint 恢复上下文。

**问题：** 同 `/save`，简单但缺乏结构化定义。

---

#### /learn

**文件：** `commands/learn.md`

```yaml
---
description: 跨 session 学习记录管理
---
调用 .agents/skills/learn/SKILL.md。
```

**实际行为：** 委托给 `maintain-workflow-learn` 技能，管理学习记录的读写和检索。

**问题：** 同 `/save`。

---

### Commands 层现状总结

| 维度 | 现状 | 理想 |
|------|------|------|
| 文件长度 | 1-2 行 | 30-100 行（Phase 定义） |
| Phase 声明 | 无 | 每个 Command 2-4 个 Phase |
| Agent 引用 | 无 | 每个 Phase 指定 Agent |
| 并行策略 | 无 | 标注哪些 Phase 可并行 |
| 入口/出口条件 | 无 | 明确定义 |
| 验收标准 | 无 | 每个 Phase 有 Validation 清单 |

---

## 2.2 Agents 层现状

### 概览

当前 15 个 Agent 全部用于审查阶段（Review / Plan Review / Refine Scout / Ship Audit），没有核心工程执行角色（如软件开发、内容创作、任务规划）。

### 分类分析

#### Review Army（4 个）

| Agent | 文件 | 职责 | 命名规范 |
|-------|------|------|---------|
| code-reviewer | `agents/code-reviewer.md` | 五轴审查（正确性、可读性、架构、安全、性能） | ❌ 缺少 phase 前缀 |
| security-auditor | `agents/security-auditor.md` | 安全审计（OWASP、威胁建模、密钥扫描） | ❌ 缺少 phase 前缀 |
| test-engineer | `agents/test-engineer.md` | 测试覆盖分析（happy path、边界、错误路径） | ❌ 缺少 phase 前缀 |
| review-accessibility-checker | `agents/review-accessibility-checker.md` | 无障碍审查（WCAG、屏幕阅读器） | ⚠️ 有 phase 但 role-type 不统一（checker vs auditor） |

**问题：**
1. 4 个 Agent 中 3 个缺少 `review-` phase 前缀
2. `review-accessibility-checker` 使用 `checker` 而非 `auditor`（与其他 Ship Audit Army 的命名不一致）

---

#### Plan Review Army（4 个）

| Agent | 文件 | 职责 | 命名规范 |
|-------|------|------|---------|
| plan-ceo-reviewer | `agents/plan-ceo-reviewer.md` | CEO 视角：市场价值、投资回报 | ✅ phase-lens-role |
| plan-eng-reviewer | `agents/plan-eng-reviewer.md` | 工程视角：可行性、复杂度 | ✅ phase-lens-role |
| plan-design-reviewer | `agents/plan-design-reviewer.md` | 设计视角：用户体验、交互流程 | ✅ phase-lens-role |
| plan-security-reviewer | `agents/plan-security-reviewer.md` | 安全视角：数据暴露、合规 | ✅ phase-lens-role |

**问题：** 无。命名一致，职责清晰。

---

#### Refine Scout Army（3 个）

| Agent | 文件 | 职责 | 命名规范 |
|-------|------|------|---------|
| refine-ceo-scout | `agents/refine-ceo-scout.md` | CEO 视角：商业可行性 | ✅ phase-lens-role |
| refine-eng-scout | `agents/refine-eng-scout.md` | 工程视角：技术可行性 | ✅ phase-lens-role |
| refine-design-scout | `agents/refine-design-scout.md` | 设计视角：用户体验 | ✅ phase-lens-role |

**问题：** 无。命名一致，职责清晰。

---

#### Ship Audit Army（4 个）

| Agent | 文件 | 职责 | 命名规范 |
|-------|------|------|---------|
| ship-security-auditor | `agents/ship-security-auditor.md` | 安全审计 | ✅ phase-lens-role |
| ship-performance-auditor | `agents/ship-performance-auditor.md` | 性能审计 | ✅ phase-lens-role |
| ship-accessibility-auditor | `agents/ship-accessibility-auditor.md` | 无障碍审计 | ✅ phase-lens-role |
| ship-docs-auditor | `agents/ship-docs-auditor.md` | 文档审计 | ✅ phase-lens-role |

**问题：** 无。命名一致，职责清晰。

---

### Agents 层现状总结

| 维度 | 现状 | 理想 |
|------|------|------|
| 总数 | 15 | 22（+7 核心工程角色） |
| 类型 | 仅审查角色 | 审查 + 核心工程执行角色 |
| 命名一致性 | 4 个 Review agents 不一致 | 全部遵循 phase-lens-role |
| 核心执行角色 | 缺失（由 workflow skills 兼任） | 独立 Agent（software-engineer 等） |
| 职责边界 | 清晰（按审查视角划分） | 需要扩展到执行阶段 |

---

## 2.3 Skills 层现状

### 概览

当前 43 个 Skill 按 6 个阶段组织，整体结构良好。核心问题集中在 4 个 workflow skills 上。

### 按阶段分布

```
define/     3 skills  (refine, spec, brainstorm)
build/      15 skills (plan, execute, tdd, context, source-driven,
                        execution-engine, decision-record, git,
                        ui-engineering, browser-testing,
                        api-design, database, service-patterns,
                        content-writing, content-layout)
verify/     11 skills (review, debug, accessibility, integration-testing,
                        performance, security, code-review-standards,
                        content-review, visual-review,
                        receiving-review, simplify)
ship/       7 skills  (ship, ci-cd, deploy, artifact-export,
                        canary, land, doc-sync)
maintain/   5 skills  (observability, deprecation-migration,
                        context-save, context-restore, learn)
reflect/    2 skills  (retro, documentation)
─────────────────────
Total:     43 skills
```

### 关键 Workflow Skills 分析

#### build-workflow-plan

**职责：** 将 spec 转化为任务计划。

**artifact_type 路由逻辑：**
```
software  → vertical slices (feature-complete increments)
document  → chapter/section groups
article   → chapter/section groups
deck      → page groups (narrative → visual)
visual    → component groups
```

**问题：** artifact_type 路由逻辑在此 Skill 内部，但这是设计决策保持的现状。

---

#### build-workflow-execute

**职责：** 按计划增量生成产物。

**artifact_type 路由逻辑（最复杂）：**
```
software  → 加载 build-quality-tdd + build-backend-* + build-frontend-*
document  → 加载 build-content-writing
article   → 加载 build-content-writing
deck      → 加载 build-content-writing + build-content-layout
visual    → 加载 build-content-layout
```

**问题：** 这是架构问题的核心——一个 Skill 根据 artifact_type 加载完全不同的技能集，相当于一个"万能 Agent"，违反原则 2。

---

#### verify-workflow-review

**职责：** 按产物类型执行审查。

**artifact_type 路由逻辑：**
```
software  → 五轴审查（正确性、可读性、架构、安全、性能）+ Review Army
document  → 内容审查
article   → 内容审查
deck      → 视觉审查
visual    → 视觉审查
```

**问题：** 审查策略路由在此 Skill 内部，合理但需要文档化。

---

#### ship-workflow-ship

**职责：** 发布流程编排。

**artifact_type 路由逻辑：**
```
software  → CI/CD + 部署 + 金丝雀 + 合并
document  → 导出 + 文档同步
article   → 导出 + 文档同步
deck      → 导出（PPT/PDF）
visual    → 导出
```

**问题：** 发布策略路由合理，保持现状。

---

#### define-workflow-refine

**职责：** 需求提炼 + External Scan + Scout Army 审查。

**特点：** 依赖 artifact_type 做 External Scan 的搜索策略选择。整体结构清晰。

---

### Skills 层现状总结

| 维度 | 现状 | 理想 |
|------|------|------|
| 总数 | 43 | 保持不变 |
| 阶段分布 | 合理 | 保持不变 |
| artifact_type 路由 | 在 workflow skills 内部 | 保持现状（设计决策） |
| workflow-execute | 万能路由（核心问题） | 通过拆分 Agent 解决 |
| 命名规范 | 一致 | 保持不变 |

---

## 2.4 artifact_type 路由机制分析

### 路由分布图

```
artifact_type
    │
    ├── define-workflow-refine ──→ External Scan 搜索策略
    │
    ├── build-workflow-plan ──→ 依赖图策略选择
    │
    ├── build-workflow-execute ──→ 领域技能加载（最复杂）
    │       software  → TDD + API + DB + Frontend + Backend
    │       document  → Content Writing
    │       article   → Content Writing
    │       deck      → Content Writing + Layout
    │       visual    → Layout
    │
    ├── verify-workflow-review ──→ 审查策略选择
    │       software  → 五轴审查 + Review Army
    │       document  → 内容审查
    │       visual    → 视觉审查
    │
    └── ship-workflow-ship ──→ 发布策略选择
            software  → CI/CD + Deploy + Canary + Land
            document  → Artifact Export + Doc Sync
            visual    → Artifact Export
```

### 设计决策：保持路由在 Skill 层

**理由：**
1. 当前实现已经工作良好
2. 分散但灵活——每个 Skill 只关心自己阶段的路由
3. 避免在 Command 层引入复杂的条件分支
4. 如果未来需要集中管理，可以新增一个 `build-cognitive-type-router` Skill

**权衡：**
- **优点：** Skill 自治，修改一个阶段不影响其他阶段
- **缺点：** 新增 artifact_type 需要修改多个 Skill
- **缓解：** 在文档中提供集中的 artifact_type 路由参考表

---

## 2.5 并行执行模式分析

### 当前并行模式

#### Review Army（/review 阶段）

```
Command: /review
  └── Skill: verify-workflow-review
        └── 并行分派 4 个 Agents:
              ├── code-reviewer        → 正确性、可读性、架构、安全、性能
              ├── security-auditor     → OWASP、威胁建模、密钥扫描
              ├── test-engineer        → Happy path、边界、错误路径
              └── review-accessibility-checker → WCAG、屏幕阅读器
```

**并行发起方式：** 主 session 在单个 assistant turn 中发起 4 个 Agent 调用。
**反馈合并：** 按 Blocking / Important / Suggestion 三级分级。

---

#### Plan Review Army（/plan 阶段）

```
Command: /plan
  └── Skill: build-workflow-plan
        └── 并行分派 4 个 Agents:
              ├── plan-ceo-reviewer      → 市场价值、投资回报
              ├── plan-eng-reviewer      → 可行性、复杂度
              ├── plan-design-reviewer   → 用户体验、交互流程
              └── plan-security-reviewer → 数据暴露、合规
```

**并行发起方式：** 同 Review Army。
**反馈合并：** 同 Review Army。

---

#### Refine Scout Army（/refine 阶段）

```
Command: /refine
  └── Skill: define-workflow-refine
        └── 并行分派 3 个 Agents:
              ├── refine-ceo-scout    → 商业可行性
              ├── refine-eng-scout    → 技术可行性
              └── refine-design-scout → 用户体验
```

**并行发起方式：** 同 Review Army。
**反馈合并：** 同 Review Army。

---

#### Ship Audit Army（/ship 阶段）

```
Command: /ship
  └── Skill: ship-workflow-ship
        └── 并行分派 4 个 Agents:
              ├── ship-security-auditor      → OWASP、输入边界
              ├── ship-performance-auditor   → 关键路径、N+1 查询
              ├── ship-accessibility-auditor → WCAG、屏幕阅读器
              └── ship-docs-auditor          → CHANGELOG、README、API 文档
```

**并行发起方式：** 同 Review Army。
**反馈合并：** 同 Review Army。

---

### 并行执行模式总结

| Army | Agent 数量 | 并行位置 | 反馈分级 |
|------|-----------|---------|---------|
| Review Army | 4 | verify-workflow-review 内部 | Blocking / Important / Suggestion |
| Plan Review Army | 4 | build-workflow-plan 内部 | 同上 |
| Refine Scout Army | 3 | define-workflow-refine 内部 | 同上 |
| Ship Audit Army | 4 | ship-workflow-ship 内部 | 同上 |

**关键问题：** 并行策略由 Skill 内部实现，Command 层没有声明。重构后，Command 应该明确标注哪些 Phase 使用并行分派。

---

## 2.6 现状问题总结

### 问题 1：Commands 是"快捷方式"而非"编排协议"

**严重程度：** 高
**影响范围：** 全部 8 个 Command

**现状：** 每个 Command 文件只有 1 行代码："调用 XXX/SKILL.md"。

**后果：**
- 无法从 Command 文件了解工作流结构
- 修改工作流需要深入 Skill 内部
- 新成员难以理解系统行为
- Phase 间的状态转换条件不明确

---

### 问题 2：artifact_type 路由逻辑分散

**严重程度：** 中
**影响范围：** 4 个 workflow skills

**现状：** 每个 workflow skill 独立实现 artifact_type 路由。

**后果：**
- 新增 artifact_type 需要修改 4 个 Skill
- 没有统一的路由参考视图
- 不同 Skill 的路由逻辑可能有遗漏

**缓解：** 这是设计决策保持的现状，通过文档化（本章节 + 参考表）来缓解。

---

### 问题 3：workflow-execute 是"万能 Agent"

**严重程度：** 高
**影响范围：** `/build` 命令

**现状：** `build-workflow-execute` 根据 artifact_type 加载完全不同的技能集：
- software → TDD + API + DB + Frontend + Backend（5+ 技能）
- document → Content Writing（1 技能）
- visual → Layout（1 技能）

**后果：**
- 违反单一职责原则
- Software 的 TDD 纪律被"万能 Agent"稀释
- 难以针对特定产物类型优化行为
- 新增产物类型（如 `data-pipeline`）需要修改此 Skill

---

### 问题 4：Agent 命名不一致

**严重程度：** 低
**影响范围：** 4 个 Review agents

**现状：**
- Plan Review Army: `plan-ceo-reviewer` ✅（有 phase 前缀）
- Ship Audit Army: `ship-security-auditor` ✅（有 phase 前缀）
- Review Army: `code-reviewer` ❌（缺少 `review-` 前缀）
- `review-accessibility-checker` ⚠️（role-type 不统一）

**后果：**
- 新成员无法从命名推断 Agent 的所属阶段
- 与 Plan/Ship Army 的命名规范不一致

---

### 问题优先级排序

| 优先级 | 问题 | 修复方式 | 风险 |
|--------|------|---------|------|
| P0 | Commands 是快捷方式 | 重写 8 个 Commands 为编排协议 | 低（纯文档变更） |
| P1 | workflow-execute 万能 Agent | 拆分为专业角色 Agents | 中（需要创建新文件） |
| P1 | Agent 命名不一致 | 重命名 4 个 Review agents | 低（文件重命名） |
| P2 | artifact_type 路由分散 | 文档化（保持现状） | 无 |


---

# 第三部分：重构方案

## 3.1 新 Agent 体系设计

### 3.1.1 核心工程角色（7 个新 Agents）

以下 7 个 Agent 是本次重构的核心新增，它们填补了 Unified Skills 在执行阶段的角色空白。

#### Agent 1：requirements-analyst

```yaml
---
name: requirements-analyst
description: 需求分析师——负责需求澄清、5W1H 提问、需求文档生成
phase: define
invoked_by: /refine (Phase 1)
skills:
  - define-workflow-refine（需求澄清部分）
output: docs/features/YYYYMMDD-<name>/01-spec.md
---
```

**职责：**
- 通过 5W1H 方法论澄清模糊需求
- 识别需求中的隐含假设和矛盾
- 生成结构化的需求文档（spec）
- 声明 artifact_type

**不负责：**
- External Scan（由独立 subagent 完成）
- 需求审查（由 Refine Scout Army 完成）
- 任务分解（由 task-planner 完成）

---

#### Agent 2：task-planner

```yaml
---
name: task-planner
description: 任务规划师——负责将 spec 转化为可执行的任务分解
phase: build
invoked_by: /plan (Phase 1, Phase 3)
skills:
  - build-workflow-plan
  - build-cognitive-execution-engine（mode selection）
output: docs/features/YYYYMMDD-<name>/02-plan.md
---
```

**职责：**
- 读取 spec，提取 artifact_type
- 根据 artifact_type 选择依赖图策略
- 分解为带验收标准的任务
- 标注任务间的依赖和并行安全性
- 估算复杂度

**不负责：**
- 需求分析（由 requirements-analyst 完成）
- 代码实现（由 software-engineer 等完成）
- 计划审查（由 Plan Review Army 完成）

---

#### Agent 3：software-engineer

```yaml
---
name: software-engineer
description: 软件工程师——负责软件开发（TDD、API 设计、数据库、前后端）
phase: build
invoked_by: /build (Phase 2, artifact_type: software)
skills:
  - build-quality-tdd
  - build-backend-api-design
  - build-backend-database
  - build-backend-service-patterns
  - build-workflow-execute（software 模式）
  - build-cognitive-execution-engine
  - build-cognitive-decision-record
output: 代码产物 + tests + adr/
---
```

**职责：**
- 按 TDD 循环（RED → GREEN → REFACTOR）开发软件
- API 设计和数据库建模
- 前端和后端实现
- 遇到架构决策时写 ADR
- 遇到 Bug 时进入调试

**不负责：**
- 需求分析（由 requirements-analyst 完成）
- 任务分解（由 task-planner 完成）
- 代码审查（由 review-code-reviewer 完成）

---

#### Agent 4：data-architect

```yaml
---
name: data-architect
description: 数据架构师——负责数据建模、schema 设计、数据迁移
phase: build
invoked_by: /build (Phase 2, 软件子领域)
skills:
  - build-backend-database
  - build-cognitive-decision-record
output: 数据模型 + schema + 迁移脚本
---
```

**职责：**
- 数据建模（ER 图、关系设计）
- Schema 设计（索引、约束、分区）
- 数据迁移策略
- 与 API 设计师协作（数据契约）

**不负责：**
- API 设计（由 api-designer 完成）
- 业务逻辑实现（由 software-engineer 完成）
- 性能调优（由 ship-performance-auditor 审查）

---

#### Agent 5：api-designer

```yaml
---
name: api-designer
description: API 设计师——负责 API 接口设计、契约定义、版本管理
phase: build
invoked_by: /build (Phase 2, 软件子领域)
skills:
  - build-backend-api-design
  - build-cognitive-decision-record
output: API 契约 + OpenAPI spec
---
```

**职责：**
- RESTful / GraphQL API 设计
- 接口契约定义（输入/输出/错误码）
- API 版本管理策略
- 与数据架构师协作（数据契约）

**不负责：**
- 数据建模（由 data-architect 完成）
- 业务逻辑实现（由 software-engineer 完成）
- 前端集成（由 software-engineer 完成）

---

#### Agent 6：content-writer

```yaml
---
name: content-writer
description: 内容创作者——负责文章、文档、PPT 叙事的内容创作
phase: build
invoked_by: /build (Phase 2, artifact_type: document/article/deck)
skills:
  - build-content-writing
  - build-workflow-execute（content 模式）
  - build-cognitive-execution-engine
output: 文档/文章/PPT 内容
---
```

**职责：**
- 按章节/段落增量创作内容
- 保持叙事连贯性和逻辑一致性
- 遵循内容审查标准
- 适配目标受众

**不负责：**
- 视觉版式（由 visual-designer 完成）
- 需求分析（由 requirements-analyst 完成）
- 内容审查（由 verify-workflow-review 完成）

---

#### Agent 7：visual-designer

```yaml
---
name: visual-designer
description: 视觉设计师——负责版式布局、视觉层级、交互设计
phase: build
invoked_by: /build (Phase 2, artifact_type: visual/deck)
skills:
  - build-content-layout
  - build-workflow-execute（visual 模式）
  - build-cognitive-execution-engine
output: 视觉设计稿 / 布局方案
---
```

**职责：**
- 版式布局设计
- 视觉层级定义
- 交互状态设计
- 无障碍合规（WCAG）

**不负责：**
- 内容创作（由 content-writer 完成）
- 前端实现（由 software-engineer 完成）
- 视觉审查（由 verify-workflow-review 完成）

---

### 3.1.2 审查角色重命名（4 个 Review Agents）

以下 4 个 Agent 需要重命名以保持命名一致性：

| 旧名 | 新名 | 变更说明 |
|------|------|---------|
| `code-reviewer` | `review-code-reviewer` | 添加 `review-` phase 前缀 |
| `security-auditor` | `review-security-auditor` | 添加 `review-` phase 前缀 |
| `test-engineer` | `review-test-engineer` | 添加 `review-` phase 前缀 |
| `review-accessibility-checker` | `review-accessibility-auditor` | 统一 role-type 为 `auditor` |

**重命名后，Review Army 命名完全对齐 Plan/Ship Army：**

```
Review Army:
  review-code-reviewer          ← phase-lens-role
  review-security-auditor       ← phase-lens-role
  review-test-engineer          ← phase-lens-role
  review-accessibility-auditor  ← phase-lens-role

Plan Review Army:
  plan-ceo-reviewer             ← phase-lens-role ✅
  plan-eng-reviewer             ← phase-lens-role ✅
  plan-design-reviewer          ← phase-lens-role ✅
  plan-security-reviewer        ← phase-lens-role ✅
```

---

### 3.1.3 保留的阶段专属 Agents（11 个）

以下 11 个 Agent 命名正确、职责清晰，不做变更：

```
Plan Review Army (4):
  plan-ceo-reviewer.md          ✓
  plan-eng-reviewer.md          ✓
  plan-design-reviewer.md       ✓
  plan-security-reviewer.md     ✓

Refine Scout Army (3):
  refine-ceo-scout.md           ✓
  refine-eng-scout.md           ✓
  refine-design-scout.md        ✓

Ship Audit Army (4):
  ship-security-auditor.md      ✓
  ship-performance-auditor.md   ✓
  ship-accessibility-auditor.md ✓
  ship-docs-auditor.md          ✓
```

---

### 3.1.4 Agent 定义模板

每个新 Agent 文件应遵循以下模板：

```yaml
---
name: <agent-name>
description: <一句话职责描述>
phase: <define|build|verify|ship>
invoked_by: <哪个 Command 的哪个 Phase>
skills:
  - <加载的 Skill 列表>
output: <输出产物路径>
---

# <Agent Name> — <角色标题>

## 职责范围

<描述该 Agent 负责什么>

## 不负责

<明确边界，避免角色重叠>

## 加载的 Skills

<列出加载的 Skills 及其用途>

## 输入

<期望的输入格式>

## 输出

<输出的格式和质量标准>

## 并行安全性

<是否可以与其他 Agent 并行执行>

## 调用示例

<展示如何在 Command 的 Phase 中引用此 Agent>
```

---

### 3.1.5 完整 Agent 体系全景图

重构后的 22 个 Agent 按职责分为三大类：

```
┌─────────────────────────────────────────────────────────────────┐
│                        22 Agents 全景图                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  核心工程角色 (7)                    审查角色 (15)                │
│  ─────────────────                 ──────────────               │
│  requirements-analyst              Review Army (4)              │
│  task-planner                        review-code-reviewer       │
│  software-engineer                   review-security-auditor    │
│  data-architect                      review-test-engineer       │
│  api-designer                        review-accessibility-auditor│
│  content-writer                                                  │
│  visual-designer                   Plan Review Army (4)         │
│                                      plan-ceo-reviewer          │
│                                      plan-eng-reviewer          │
│                                      plan-design-reviewer       │
│                                      plan-security-reviewer     │
│                                                                  │
│                                    Refine Scout Army (3)        │
│                                      refine-ceo-scout           │
│                                      refine-eng-scout           │
│                                      refine-design-scout        │
│                                                                  │
│                                    Ship Audit Army (4)          │
│                                      ship-security-auditor      │
│                                      ship-performance-auditor   │
│                                      ship-accessibility-auditor │
│                                      ship-docs-auditor          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3.2 新 Command 结构设计

### 3.2.1 Command 作为编排协议的定义

**从"快捷方式"到"编排协议"的转变：**

| 维度 | 快捷方式模式 | 编排协议模式 |
|------|------------|------------|
| 文件长度 | 1-2 行 | 30-100 行 |
| Phase 定义 | 无 | 明确的 2-4 个 Phase |
| Agent 引用 | 无 | 每个 Phase 指定 Agent |
| 并行标注 | 无 | 明确标注并行 Phase |
| 入口/出口条件 | 无 | 明确定义 |
| 验收标准 | 无 | 每个 Phase 有 Validation |
| CANON 引用 | 简单加载 | 引用具体条款 |

### 3.2.2 Phase 结构设计

每个 Phase 包含以下要素：

```yaml
Phase N: <Phase 名称>
  Agent: <负责此 Phase 的 Agent>
  Skills:
    - <Agent 需要加载的 Skills>
  Input:
    - <输入文件或数据>
  Process:
    1. <步骤 1>
    2. <步骤 2>
    3. ...
  Output:
    - <输出文件>
  Validation:
    - [ ] <验收条件 1>
    - [ ] <验收条件 2>
```

---

### 3.2.3 八个 Command 的完整重写方案

#### Command 1：/refine

```yaml
---
description: 需求提炼 + External Scan + 多角色 Idea Scout 审查
---

# Command: /refine

## Goal
Transform vague idea into structured spec with multi-perspective validation.

## Phases

### Phase 1: Requirement Clarification
Agent: requirements-analyst
Skills:
  - define-workflow-refine（需求澄清部分）
Input:
  - 用户的初始需求描述
Process:
  1. 通过 5W1H 方法论澄清模糊需求
  2. 识别隐含假设和矛盾
  3. 确定artifact_type（software/document/article/deck/visual）
  4. 生成 spec 初稿
Output:
  - docs/features/YYYYMMDD-<name>/01-spec.md（draft）

Validation:
  - [ ] artifact_type 已声明
  - [ ] 需求无自相矛盾
  - [ ] 5W1H 全部回答

---

### Phase 2: External Scan
Agent: （独立 subagent）
Skills:
  - define-workflow-refine（External Scan 部分）
Input:
  - 01-spec.md（draft）
Process:
  1. 按 artifact_type 搜索已有方案、事实来源、设计模式
  2. 结果分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject
  3. 写入文件
Output:
  - external-scan-results.md

Validation:
  - [ ] 至少 3 个事实来源
  - [ ] 分层结果完整

---

### Phase 3: Multi-Role Scout Review (Parallel)
Agents (parallel dispatch):
  - refine-ceo-scout（商业可行性、市场定位）
  - refine-eng-scout（技术可行性、实现复杂度）
  - refine-design-scout（用户体验、交互创新）
Skills:
  - define-workflow-refine（审查部分）
Input:
  - 01-spec.md（draft）
  - external-scan-results.md
Process:
  1. 并行分派 3 个 Scouts
  2. 每个 Scout 独立产出反馈（Blocking / Important / Suggestion）
  3. 收集所有反馈
Output:
  - scout-feedback.md

Validation:
  - [ ] 3 个 Scouts 全部完成
  - [ ] Blocking issues 已识别

---

### Phase 4: Refine Spec Based on Feedback
Agent: requirements-analyst
Skills:
  - define-workflow-refine（迭代部分）
Input:
  - 01-spec.md（draft）
  - scout-feedback.md
Process:
  1. 解决所有 Blocking issues
  2. 纳入 Important 建议
  3. 记录被拒绝的建议及理由
  4. 生成最终 spec
Output:
  - docs/features/YYYYMMDD-<name>/01-spec.md（final）

Validation:
  - [ ] 所有 Blocking issues 已解决
  - [ ] artifact_type 与需求匹配

---

## Entry Conditions
- [ ] 用户提供了初始需求描述
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] docs/features/YYYYMMDD-<name>/01-spec.md 存在且最终版
- [ ] artifact_type 已声明
- [ ] 经 3 个视角审查
- [ ] 所有 Blocking issues 已解决
- [ ] 用户已批准 spec

## Next Steps
- If approved → /plan
- If major issues → 迭代 Phase 1-4

## Constitutional Rules
- CANON.md Clause 2: 一次只问一个问题
- CANON.md Clause 3: 不做未经批准的架构决策
```

---

#### Command 2：/plan

```yaml
---
description: 从 spec 到详细任务分解 + 多角色计划审查
---

# Command: /plan

## Goal
Transform spec into actionable task plan with multi-perspective review.

## Phases

### Phase 1: Parse Spec and Decompose Tasks
Agent: task-planner
Skills:
  - build-workflow-plan
  - build-cognitive-execution-engine（mode selection）
Input:
  - docs/features/YYYYMMDD-<name>/01-spec.md
Process:
  1. 读取 spec，提取 artifact_type
  2. 根据 artifact_type 选择依赖图策略：
     - software → vertical slices
     - document/article → chapter/section groups
     - deck → page groups
     - visual → component groups
  3. 分解为带验收标准的任务
  4. 标注依赖关系和并行安全性
  5. 估算复杂度
Output:
  - docs/features/YYYYMMDD-<name>/02-plan.md（draft）
  - docs/features/YYYYMMDD-<name>/plans/*.md（子计划，如有并行任务）

Validation:
  - [ ] 所有任务有验收标准
  - [ ] 依赖关系已声明
  - [ ] 并行安全任务已标记
  - [ ] 复杂度已估算

---

### Phase 2: Multi-Role Plan Review (Parallel)
Agents (parallel dispatch):
  - plan-ceo-reviewer（市场价值、投资回报、优先级）
  - plan-eng-reviewer（可行性、技术复杂度、依赖风险）
  - plan-design-reviewer（用户体验、信息架构、交互流程）
  - plan-security-reviewer（数据暴露、认证授权、合规）
Skills:
  - verify-workflow-review（plan mode）
Input:
  - 02-plan.md（draft）
Process:
  1. 并行分派 4 个 Reviewers
  2. 每个 Reviewer 独立产出反馈
  3. 收集所有反馈
Output:
  - plan-review-comments.md

Validation:
  - [ ] 4 个 Reviewers 全部完成
  - [ ] Blocking issues 已识别
  - [ ] 反馈按严重度分级

---

### Phase 3: Refine Plan Based on Feedback
Agent: task-planner
Skills:
  - build-workflow-plan（refinement mode）
Input:
  - 02-plan.md（draft）
  - plan-review-comments.md
Process:
  1. 解决所有 Blocking issues
  2. 纳入 Important 建议
  3. 记录被拒绝的建议及理由
  4. 更新任务列表和依赖关系
Output:
  - docs/features/YYYYMMDD-<name>/02-plan.md（final）

Validation:
  - [ ] 所有 Blocking issues 已解决
  - [ ] Important 建议已处理
  - [ ] Plan 通过 Phase 1 的所有验证标准

---

## Entry Conditions
- [ ] 01-spec.md 存在且已批准
- [ ] artifact_type 已声明
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 02-plan.md 存在
- [ ] 经 4 个视角审查
- [ ] 所有 Blocking issues 已解决
- [ ] 用户已批准 plan

## Next Steps
- If approved → /build
- If major changes → /refine（迭代 spec）

## Constitutional Rules
- CANON.md Clause 2: 一次只问一个问题
- CANON.md Clause 3: 不做未经批准的架构决策
- CANON.md Clause 4: 不跳过测试
```

---

#### Command 3：/build

```yaml
---
description: 按计划增量生成产物（软件 TDD / 内容 / 视觉）+ ADR
---

# Command: /build

## Goal
Execute plan incrementally, generating artifact slices with continuous verification.

## Phases

### Phase 1: Load Plan and Select Execution Mode
Agent: task-planner
Skills:
  - build-cognitive-execution-engine
Input:
  - 02-plan.md（final）
Process:
  1. 读取总控计划
  2. 如有并行任务，读取 plans/*.md 子计划
  3. 检查 Parallel Execution Matrix 的 parallel_safe 标记
  4. 选择执行模式：
     - inline → 单任务，主 session 执行
     - subagent → 需要隔离上下文的任务
     - parallel → parallel_safe 的多任务
Output:
  - 执行模式决策（不写文件，进入 Phase 2）

Validation:
  - [ ] 计划文件存在且已批准
  - [ ] 执行模式已选择

---

### Phase 2: Incremental Build (Loop)
Agent selection (by artifact_type):
  - software → software-engineer
  - document/article → content-writer
  - deck → content-writer + visual-designer
  - visual → visual-designer
Skills (loaded by Agent):
  - software-engineer: build-quality-tdd, build-backend-*, build-frontend-*
  - content-writer: build-content-writing
  - visual-designer: build-content-layout
  - Common: build-workflow-execute, build-cognitive-execution-engine
Input:
  - 02-plan.md（final）
  - 当前切片的任务描述
Process:
  1. 按切片循环执行：
     a. 生成/实现当前切片
     b. 验证切片（运行测试 / 内容审查）
     c. 记录进度
  2. 遇到架构决策 → 加载 build-cognitive-decision-record 写 ADR
  3. 遇到 Bug → 加载 verify-workflow-debug 进入调试
  4. 切片完成 → 进入下一个切片
Output:
  - 增量产物（代码 / 文档 / 设计稿）
  - docs/features/YYYYMMDD-<name>/adr/*.md（如有决策）

Validation:
  - [ ] 每个切片通过验证
  - [ ] 所有架构决策已记录
  - [ ] 无遗留 Bug

---

### Phase 3: Final Verification
Agent: （主 session）
Skills:
  - verify-workflow-debug（如有 Bug）
  - build-quality-tdd（运行完整测试套件）
Input:
  - 所有切片的产出
Process:
  1. 运行完整验证（测试套件 / 内容完整性检查）
  2. 确认所有切片已实现
  3. 生成产物摘要
Output:
  - 完整产物

Validation:
  - [ ] 所有任务已完成
  - [ ] 所有测试通过
  - [ ] 产物与 plan 一致

---

## Entry Conditions
- [ ] 02-plan.md 存在且已批准
- [ ] artifact_type 已声明
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 所有 plan 中的任务已实现
- [ ] 所有测试通过
- [ ] ADR 已记录（如有决策）
- [ ] 产物完整

## Next Steps
- → /review

## Constitutional Rules
- CANON.md Clause 2: 一次只问一个问题
- CANON.md Clause 4: 不跳过测试（TDD Iron Law）
- CANON.md Clause 5: 每个切片都要可验证
```

---

#### Command 4：/review

```yaml
---
description: 按产物类型审查（软件五轴 / 内容 / 视觉）+ 多角色并行审查
---

# Command: /review

## Goal
Multi-perspective artifact review with severity-graded feedback.

## Phases

### Phase 1: Artifact Analysis
Agent: （主 session）
Skills:
  - verify-workflow-review（路由部分）
Input:
  - 产物文件
  - 02-plan.md
Process:
  1. 读取 artifact_type
  2. 确定审查策略：
     - software → 五轴审查 + Review Army
     - document/article → 内容审查
     - visual/deck → 视觉审查
  3. 准备审查上下文
Output:
  - 审查策略决策（不写文件，进入 Phase 2）

Validation:
  - [ ] artifact_type 已确认
  - [ ] 审查策略已选择

---

### Phase 2: Multi-Role Review (Parallel)
Agents (parallel dispatch, software 类型):
  - review-code-reviewer（正确性、可读性、架构、安全、性能）
  - review-security-auditor（OWASP、威胁建模、密钥扫描）
  - review-test-engineer（happy path、边界、错误路径、并发）
  - review-accessibility-auditor（WCAG、屏幕阅读器，有 UI 变更时）
Skills:
  - verify-workflow-review
  - verify-code-review-standards（code-reviewer）
  - verify-security（security-auditor）
  - verify-accessibility（accessibility-auditor）
Input:
  - 产物文件
Process:
  1. 并行分派 Reviewers（1-4 个，取决于审查策略）
  2. 每个 Reviewer 独立产出反馈
  3. 反馈分级：Blocking / Important / Suggestion
Output:
  - 各 Reviewer 的独立反馈文件

Validation:
  - [ ] 所有 Reviewers 完成
  - [ ] 反馈已按严重度分级

---

### Phase 3: Merge Feedback and Report
Agent: （主 session）
Skills:
  - verify-workflow-review（合并部分）
Input:
  - 各 Reviewer 的反馈文件
Process:
  1. 合并所有反馈
  2. 按严重度和类别排序
  3. 生成统一审查报告
Output:
  - docs/features/YYYYMMDD-<name>/review.md

Validation:
  - [ ] 报告包含所有 Reviewer 的反馈
  - [ ] Blocking issues 清晰标注
  - [ ] 报告格式符合规范

---

## Entry Conditions
- [ ] 产物已完成（/build 已完成）
- [ ] 02-plan.md 存在
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] review.md 存在
- [ ] 所有 Reviewers 已完成
- [ ] Blocking issues 已识别
- [ ] 反馈已分级

## Next Steps
- If no Blocking issues → /ship
- If has Blocking issues → /build（修复后重新 /review）

## Constitutional Rules
- CANON.md Clause 6: 审查不是走过场
- CANON.md Clause 7: Blocking issues 必须修复
```

---

#### Command 5：/ship

```yaml
---
description: 发布准备（安全/性能/无障碍/文档审计）+ 导出/发布
---

# Command: /ship

## Goal
Pre-release audit and artifact export/publishing.

## Phases

### Phase 1: Pre-Release Preparation
Agent: （主 session）
Skills:
  - ship-workflow-ship（准备部分）
Input:
  - 产物文件
  - review.md
Process:
  1. 确认所有 Blocking issues 已修复
  2. 准备发布清单
  3. 生成变更摘要
Output:
  - 发布准备状态

Validation:
  - [ ] 所有 Blocking issues 已修复
  - [ ] 发布清单完整

---

### Phase 2: Ship Audit (Parallel)
Agents (parallel dispatch):
  - ship-security-auditor（OWASP、输入边界、认证授权、数据暴露）
  - ship-performance-auditor（关键路径、N+1查询、内存资源、Bundle影响）
  - ship-accessibility-auditor（WCAG合规、屏幕阅读器、表单错误）
  - ship-docs-auditor（CHANGELOG、README、迁移指南、API文档）
Skills:
  - ship-workflow-ship（审计部分）
Input:
  - 产物文件
  - review.md
Process:
  1. 并行分派 4 个 Auditors
  2. 每个 Auditor 独立产出审计报告
  3. 收集所有审计结果
Output:
  - 各 Auditor 的审计报告

Validation:
  - [ ] 4 个 Auditors 全部完成
  - [ ] 无新的 Blocking issues

---

### Phase 3: Export / Publish
Agent: （主 session）
Skills:
  - ship-workflow-ship（发布部分）
  - ship-artifact-export（非 software 类型）
  - ship-ci-cd（software 类型）
  - ship-deploy（software 类型）
Input:
  - 产物文件
  - 审计报告
Process:
  1. 根据 artifact_type 执行发布：
     - software → CI/CD + 部署 + 金丝雀监控
     - document/article → 导出 + 文档同步
     - deck → 导出 PPT/PDF
     - visual → 导出设计稿
  2. 记录发布信息
Output:
  - docs/features/YYYYMMDD-<name>/ship.md

Validation:
  - [ ] 发布/导出成功
  - [ ] ship.md 已生成

---

### Phase 4: Documentation Sync
Agent: （主 session）
Skills:
  - ship-doc-sync
Input:
  - ship.md
  - 产物变更摘要
Process:
  1. 更新 README.md
  2. 更新 CHANGELOG（如有）
  3. 生成最终产物文档
Output:
  - docs/features/YYYYMMDD-<name>/README.md

Validation:
  - [ ] README 已更新
  - [ ] 文档与产物一致

---

## Entry Conditions
- [ ] /review 已完成
- [ ] 所有 Blocking issues 已修复
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] ship.md 存在
- [ ] 发布/导出成功
- [ ] README.md 已更新
- [ ] 所有 Auditors 通过

## Next Steps
- If deploying → 监控 canary-report.md
- If exported → 交付产物

## Constitutional Rules
- CANON.md Clause 8: 不发布未经审计的产物
- CANON.md Clause 10: 发布后做 retro
```

---

#### Command 6：/save

```yaml
---
description: 保存当前工作上下文为 checkpoint
---

# Command: /save

## Goal
Capture current work context as a restorable checkpoint.

## Phases

### Phase 1: Capture Context
Agent: （主 session 直接执行）
Skills:
  - maintain-workflow-context-save
Input:
  - 当前对话上下文
  - 当前工作文件
Process:
  1. 收集当前工作状态（已完成的任务、进行中的任务）
  2. 记录关键决策和上下文
  3. 生成 checkpoint 文件
Output:
  - .claude/checkpoints/YYYYMMDD-HHMMSS-{title}.md

Validation:
  - [ ] checkpoint 文件已生成
  - [ ] 包含完整的工作状态

---

## Entry Conditions
- [ ] 有活跃的工作上下文需要保存

## Exit Conditions
- [ ] checkpoint 文件已生成
- [ ] 用户确认保存成功

## Next Steps
- → 继续工作或结束 session
- → /restore 恢复此 checkpoint
```

---

#### Command 7：/restore

```yaml
---
description: 从 checkpoint 恢复工作上下文
---

# Command: /restore

## Goal
Restore work context from a previously saved checkpoint.

## Phases

### Phase 1: Load Checkpoint
Agent: （主 session 直接执行）
Skills:
  - maintain-workflow-context-restore
Input:
  - checkpoint 文件路径（或让用户选择）
Process:
  1. 列出可用的 checkpoints
  2. 用户选择要恢复的 checkpoint
  3. 加载 checkpoint 内容
  4. 恢复工作上下文
Output:
  - 恢复的工作上下文（在当前 session 中生效）

Validation:
  - [ ] checkpoint 已成功加载
  - [ ] 关键上下文已恢复

---

## Entry Conditions
- [ ] 存在至少一个 checkpoint 文件

## Exit Conditions
- [ ] 工作上下文已恢复
- [ ] 用户确认恢复成功

## Next Steps
- → 继续之前的工作
```

---

#### Command 8：/learn

```yaml
---
description: 跨 session 学习记录管理
---

# Command: /learn

## Goal
Manage cross-session learning records for continuous improvement.

## Phases

### Phase 1: Learning Operation
Agent: （主 session 直接执行）
Skills:
  - maintain-workflow-learn
Input:
  - 用户的学习记录操作（add / search / review）
Process:
  1. 根据用户意图执行操作：
     - add → 添加新的学习记录
     - search → 搜索相关学习记录
     - review → 回顾和整理学习记录
  2. 更新 .claude/learnings.jsonl
Output:
  - 操作结果（学习记录文件更新）

Validation:
  - [ ] 操作成功完成
  - [ ] learnings.jsonl 已更新

---

## Entry Conditions
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 学习记录操作完成

## Next Steps
- → 继续工作
```

---

### 3.2.4 Command 模板

所有 Command 文件应遵循以下模板：

```yaml
---
description: <一句话描述>
---

# Command: /<name>

## Goal
<一句话目标>

## Phases

### Phase 1: <名称>
Agent: <Agent 名>
Skills:
  - <Skill 列表>
Input:
  - <输入文件>
Process:
  1. <步骤>
Output:
  - <输出文件>
Validation:
  - [ ] <验收条件>

### Phase 2: <名称>（如有）
...

---

## Entry Conditions
- [ ] <前置条件>

## Exit Conditions
- [ ] <后置条件>

## Next Steps
- If <条件> → /<command>

## Constitutional Rules
- CANON.md Clause <N>: <引用>
```

---

## 3.3 Skills 层调整

### 3.3.1 workflow skills 的职责重新定义

重构后，workflow skills 的职责从"万能路由器"转变为"Agent 的执行手册"：

| Skill | 当前职责 | 重构后职责 |
|-------|---------|-----------|
| define-workflow-refine | 需求澄清 + External Scan + Scout 分派 + 迭代 | 保持不变（职责清晰） |
| build-workflow-plan | 依赖图策略 + 任务分解 + Plan Review 分派 + 迭代 | 保持不变（职责清晰） |
| build-workflow-execute | **万能路由**（根据 artifact_type 加载不同技能集） | **拆分为 3 个 Agent 专用的执行手册** |
| verify-workflow-review | 审查策略路由 + Review Army 分派 + 合并 | 保持不变（职责清晰） |
| ship-workflow-ship | 发布准备 + Ship Audit 分派 + 发布执行 + 文档同步 | 保持不变（职责清晰） |

**build-workflow-execute 的拆分方案：**

```
build-workflow-execute（重构前）:
  software  → 加载 TDD + API + DB + Frontend + Backend
  document  → 加载 Content Writing
  visual    → 加载 Layout

重构后：
  build-workflow-execute → 保持为通用执行循环框架
    - 切片循环（生成 → 验证 → 记录）
    - 进度跟踪
    - 错误处理

  具体领域技能由 Agent 决定加载：
    software-engineer → 加载 TDD + API + DB
    content-writer    → 加载 Content Writing
    visual-designer   → 加载 Layout
```

**关键变化：** artifact_type 的路由决策从 Skill 层提升到 Agent 层。Command 指定 Agent（software-engineer 或 content-writer），Agent 决定加载哪些 Skills。

---

### 3.3.2 artifact_type 路由逻辑保持策略

**设计决策：** artifact_type 路由保持在 Skill 层（用户确认）。

**文档化要求：**
- 在每个 workflow skill 中明确记录 artifact_type 路由逻辑
- 在本文档提供集中的路由参考表（见 2.4 节）
- 新增 artifact_type 时，需要更新以下 Skill：
  1. define-workflow-refine（External Scan 搜索策略）
  2. build-workflow-plan（依赖图策略）
  3. build-workflow-execute（领域技能加载）
  4. verify-workflow-review（审查策略）
  5. ship-workflow-ship（发布策略）

---

### 3.3.3 Skills 引用 Agents 的规范

**原则：** Skill 不直接引用 Agent。Skill 定义"怎么做"，Agent 定义"谁来做"。

**例外：** 以下 Skill 需要分派 Agent（作为协调者）：
- define-workflow-refine → 分派 Refine Scout Army
- build-workflow-plan → 分派 Plan Review Army
- verify-workflow-review → 分派 Review Army
- ship-workflow-ship → 分派 Ship Audit Army

**规范：**
- Skill 中的 Agent 引用使用 Agent 名称，不使用文件路径
- 分派策略由 Skill 定义（并行 vs 串行）
- Agent 的具体行为由 Agent 文件定义，Skill 不重复

---

## 3.4 文件组织结构

### 重构后的完整目录树

```
unified/
├── CANON.md                          宪法
├── CLAUDE.md                         入口配置
│
├── commands/                         9 命令（重写为编排协议）
│   ├── refine.md                     ← 重写
│   ├── plan.md                       ← 重写
│   ├── build.md                      ← 重写
│   ├── review.md                     ← 重写
│   ├── ship.md                       ← 重写
│   ├── save.md                       ← 重写
│   ├── restore.md                    ← 重写
│   └── learn.md                      ← 重写
│
├── .agents/skills/                    9 命令入口（Codex CLI）
│
├── agents/                           22 审查 + 工程角色
│   ├── README.md                     ← 更新
│   │
│   ├── # 核心工程角色（7 新增）───────────────────
│   ├── requirements-analyst.md       ← 新增
│   ├── task-planner.md               ← 新增
│   ├── software-engineer.md          ← 新增
│   ├── data-architect.md             ← 新增
│   ├── api-designer.md               ← 新增
│   ├── content-writer.md             ← 新增
│   ├── visual-designer.md            ← 新增
│   │
│   ├── # Review Army（4 重命名）─────────────────
│   ├── review-code-reviewer.md       ← 重命名（原 code-reviewer.md）
│   ├── review-security-auditor.md    ← 重命名（原 security-auditor.md）
│   ├── review-test-engineer.md       ← 重命名（原 test-engineer.md）
│   ├── review-accessibility-auditor.md ← 重命名（原 review-accessibility-checker.md）
│   │
│   ├── # Plan Review Army（4 保持）─────────────
│   ├── plan-ceo-reviewer.md          ✓
│   ├── plan-eng-reviewer.md          ✓
│   ├── plan-design-reviewer.md       ✓
│   └── plan-security-reviewer.md     ✓
│   │
│   ├── # Refine Scout Army（3 保持）────────────
│   ├── refine-ceo-scout.md           ✓
│   ├── refine-eng-scout.md           ✓
│   └── refine-design-scout.md        ✓
│   │
│   └── # Ship Audit Army（4 保持）──────────────
│       ├── ship-security-auditor.md      ✓
│       ├── ship-performance-auditor.md   ✓
│       ├── ship-accessibility-auditor.md ✓
│       └── ship-docs-auditor.md          ✓
│
├── skills/                           44 技能（不变）
│   ├── define/  (3)
│   ├── build/   (15)
│   ├── verify/  (11)
│   ├── ship/    (7)
│   ├── maintain/ (5)
│   └── reflect/ (2)
│
├── templates/                        6 文档模板
├── references/                       编排模式参考
├── docs/                             设计文档
│   └── architecture/
│       └── command-agent-skill-architecture.md  ← 本文档
│
└── skills-lock.json                  技能完整性锁文件
```

---

## 3.5 Command-Agent-Skill 调用关系全景图

```
/refine
  Phase 1 → requirements-analyst → define-workflow-refine
  Phase 2 → (subagent)           → define-workflow-refine (External Scan)
  Phase 3 → [refine-ceo-scout, refine-eng-scout, refine-design-scout] (parallel)
  Phase 4 → requirements-analyst → define-workflow-refine (iterate)

/plan
  Phase 1 → task-planner          → build-workflow-plan, build-cognitive-execution-engine
  Phase 2 → [plan-ceo-reviewer, plan-eng-reviewer, plan-design-reviewer, plan-security-reviewer] (parallel)
  Phase 3 → task-planner          → build-workflow-plan (refine)

/build
  Phase 1 → task-planner          → build-cognitive-execution-engine
  Phase 2 → software-engineer    → build-workflow-execute, build-quality-tdd, build-backend-*
           OR content-writer     → build-workflow-execute, build-content-writing
           OR visual-designer    → build-workflow-execute, build-content-layout
  Phase 3 → (主 session)         → verify-workflow-debug, build-quality-tdd

/review
  Phase 1 → (主 session)         → verify-workflow-review (路由)
  Phase 2 → [review-code-reviewer, review-security-auditor,
              review-test-engineer, review-accessibility-auditor] (parallel)
  Phase 3 → (主 session)         → verify-workflow-review (merge)

/ship
  Phase 1 → (主 session)         → ship-workflow-ship (准备)
  Phase 2 → [ship-security-auditor, ship-performance-auditor,
              ship-accessibility-auditor, ship-docs-auditor] (parallel)
  Phase 3 → (主 session)         → ship-workflow-ship (发布)
  Phase 4 → (主 session)         → ship-doc-sync

/save
  Phase 1 → (主 session)         → maintain-workflow-context-save

/restore
  Phase 1 → (主 session)         → maintain-workflow-context-restore

/learn
  Phase 1 → (主 session)         → maintain-workflow-learn
```

---

# 第四部分：迁移实施计划

## 4.1 迁移策略

### 渐进式迁移（Chosen）

**策略：** 分 6 个 Phase，每个 Phase 独立可验证，可以随时停止。

**为什么不选大爆炸式：**
- Unified Skills 通过 symlink 实时生效，破坏性变更会影响并行 session
- 渐进式迁移允许在每个 Phase 后验证功能正确性
- 降低回滚成本

**迁移顺序原则：**
1. 先添加（新增 Agent），不破坏现有结构
2. 再重命名（Review Agents），更新引用
3. 最后重写（Commands），完成架构升级
4. 全程验证，确保功能不退化

---

## 4.2 Phase 1：创建新 Agents（7 个核心工程角色）

### 目标
创建 7 个新的核心工程角色 Agent 文件。

### 文件清单

```
agents/
  requirements-analyst.md       ← 新增
  task-planner.md               ← 新增
  software-engineer.md          ← 新增
  data-architect.md             ← 新增
  api-designer.md               ← 新增
  content-writer.md             ← 新增
  visual-designer.md            ← 新增
```

### 操作步骤

1. 为每个 Agent 创建 `.md` 文件，遵循 3.1.4 节的模板
2. 填写 frontmatter（name, description, phase, invoked_by, skills, output）
3. 编写职责范围、不负责、加载的 Skills、输入/输出、并行安全性
4. 更新 `agents/README.md`，添加"核心工程角色"分组

### 验证

- [ ] 7 个文件已创建
- [ ] 每个文件的 frontmatter 格式正确
- [ ] 每个 Agent 的职责范围明确且无重叠
- [ ] `agents/README.md` 已更新
- [ ] 现有功能不受影响（新文件不影响现有逻辑）

### 回滚

删除新增的 7 个文件，恢复 `agents/README.md`。

---

## 4.3 Phase 2：重命名 Review Agents（4 个）

### 目标
将 4 个 Review Agent 文件重命名为统一的 phase-lens-role 格式。

### 文件操作

```
agents/code-reviewer.md              → agents/review-code-reviewer.md
agents/security-auditor.md           → agents/review-security-auditor.md
agents/test-engineer.md              → agents/review-test-engineer.md
agents/review-accessibility-checker.md → agents/review-accessibility-auditor.md
```

### 操作步骤

1. `mv` 重命名 4 个文件
2. 更新每个文件内部的 `name` 字段
3. 搜索并更新所有引用这些 Agent 的文件：
   - `skills/verify/verify-workflow-review/SKILL.md`
   - `agents/README.md`
   - `load-manifest.json`（如有引用）
   - 其他 skill 文件中的引用

### 受影响的引用搜索

需要搜索以下关键词并更新：
- `code-reviewer` → `review-code-reviewer`
- `security-auditor` → `review-security-auditor`
- `test-engineer` → `review-test-engineer`
- `review-accessibility-checker` → `review-accessibility-auditor`

### 验证

- [ ] 4 个文件已重命名
- [ ] 每个文件的 `name` 字段已更新
- [ ] 所有引用已更新（全局搜索确认无遗漏）
- [ ] `agents/README.md` 已更新
- [ ] 现有 `/review` 功能正常

### 回滚

反向重命名文件，恢复引用。

---

## 4.4 Phase 3：重写 Commands（8 个）

### 目标
将 8 个 Command 文件从"快捷方式模式"重写为"编排协议模式"。

### 文件清单

```
commands/
  refine.md      ← 重写
  plan.md        ← 重写
  build.md       ← 重写
  review.md      ← 重写
  ship.md        ← 重写
  save.md        ← 重写
  restore.md     ← 重写
  learn.md       ← 重写
```

### 操作步骤

1. 备份现有 8 个文件（`cp commands/ commands-backup/`）
2. 按 3.2.3 节的模板重写每个 Command
3. 确保每个 Command 包含：Goal, Phases, Entry/Exit Conditions, Next Steps, Constitutional Rules
4. 确保引用的 Agent 名称与 Phase 1-2 的命名一致

### 验证

- [ ] 8 个文件已重写
- [ ] 每个文件包含完整的 Phase 定义
- [ ] Agent 引用与实际 Agent 文件名一致
- [ ] Skill 引用与实际 Skill 目录名一致
- [ ] Entry/Exit Conditions 明确
- [ ] Constitutional Rules 引用正确

### 回滚

恢复 `commands-backup/` 的备份文件。

---

## 4.5 Phase 4：更新 Skills 引用

### 目标
更新 workflow skills 中对 Agent 的引用，使其使用新名称。

### 受影响的 Skills

```
skills/
  define/define-workflow-refine/SKILL.md    ← 更新 Agent 引用（如有）
  build/build-workflow-plan/SKILL.md        ← 更新 Agent 引用（如有）
  build/build-workflow-execute/SKILL.md     ← 更新 Agent 引用（如有）
  verify/verify-workflow-review/SKILL.md    ← 更新 Agent 引用（Review Army 重命名）
  ship/ship-workflow-ship/SKILL.md          ← 更新 Agent 引用（如有）
```

### 操作步骤

1. 搜索所有 Skill 文件中的旧 Agent 名称
2. 替换为新的 Agent 名称
3. 确认 `build-workflow-execute` 不再包含万能路由逻辑（路由由 Agent 决定）

### 验证

- [ ] 所有 Skill 中的 Agent 引用已更新
- [ ] 全局搜索无遗漏的旧名称引用
- [ ] `build-workflow-execute` 的路由逻辑已简化

### 回滚

使用 git 恢复 Skill 文件的变更。

---

## 4.6 Phase 5：更新 load-manifest.json

### 目标
确保 `load-manifest.json` 中的 Agent 引用使用新名称。

### 操作步骤

1. 搜索 `load-manifest.json` 中的旧 Agent 名称
2. 替换为新的 Agent 名称
3. 添加新 Agent 的加载规则（如需要）

### 验证

- [ ] `load-manifest.json` 中的 Agent 引用已更新
- [ ] 新 Agent 的加载规则已添加（如需要）

### 回滚

使用 git 恢复 `load-manifest.json`。

---

## 4.7 Phase 6：回归测试

### 目标
全面验证重构后的系统功能正确性。

### 测试策略

#### 4.7.1 命名一致性验证

```
验证项：
1. 所有 Agent 文件名遵循 phase-lens-role 格式
2. 所有 Agent 文件的 name 字段与文件名一致
3. 所有 Command 中的 Agent 引用与文件名一致
4. 所有 Skill 中的 Agent 引用与文件名一致
5. agents/README.md 中的 Agent 列表与文件系统一致
```

#### 4.7.2 功能回归测试

```
测试用例：
1. /refine → 需求提炼 → Scout Army 并行审查 → spec 生成
2. /plan   → 任务分解 → Plan Review Army 并行审查 → plan 生成
3. /build  → 软件开发（artifact_type: software）→ TDD 循环 → 产物
4. /build  → 内容创作（artifact_type: document）→ 增量写作 → 产物
5. /review → 五轴审查 → Review Army 并行审查 → review.md
6. /ship   → 发布审计 → Ship Audit Army 并行审计 → ship.md
7. /save   → 上下文保存 → checkpoint 生成
8. /restore → checkpoint 恢复
9. /learn  → 学习记录管理
```

#### 4.7.3 并行执行验证

```
验证项：
1. Review Army 4 个 Agent 可以并行分派
2. Plan Review Army 4 个 Agent 可以并行分派
3. Refine Scout Army 3 个 Agent 可以并行分派
4. Ship Audit Army 4 个 Agent 可以并行分派
5. 每个 Agent 独立上下文运行
6. 反馈合并正确（Blocking / Important / Suggestion 分级）
```

#### 4.7.4 架构一致性验证

```
验证项：
1. Command 不包含执行逻辑（只定义 Phase）
2. Agent 不调用其他 Agent（横向隔离）
3. Skill 不调用其他 Skill（横向隔离）
4. 编排深度不超过 1（Command → Agent → Skill）
5. 每个 Phase 有明确的 Input/Output/Validation
```

### 验证通过标准

- [ ] 命名一致性：5/5 通过
- [ ] 功能回归：9/9 通过
- [ ] 并行执行：6/6 通过
- [ ] 架构一致性：5/5 通过

---

## 4.8 风险与回滚策略

### 风险矩阵

| 风险 | 概率 | 影响 | 缓解策略 |
|------|------|------|---------|
| 重命名导致引用遗漏 | 中 | 高 | 全局搜索 + grep 验证 |
| 新 Agent 职责与现有 Skill 冲突 | 低 | 中 | 3.1 节的职责边界定义 |
| Command 重写改变现有行为 | 中 | 高 | 备份 + 回滚 |
| 并行 session 在迁移期间受影响 | 中 | 中 | 渐进式迁移，每步可验证 |
| load-manifest.json 更新不完整 | 低 | 中 | git diff 验证 |

### 回滚策略

**总体回滚：** 使用 git revert 回到迁移前的 commit。

**分步回滚：**
- Phase 1 回滚：删除新增的 7 个文件
- Phase 2 回滚：反向重命名文件，恢复引用
- Phase 3 回滚：恢复 `commands-backup/`
- Phase 4 回滚：git checkout 恢复 Skill 文件
- Phase 5 回滚：git checkout 恢复 load-manifest.json

**建议：** 每个 Phase 完成后创建 git tag，便于精确回滚：
```
git tag pre-migration
git tag after-phase-1
git tag after-phase-2
...
```

---

# 第五部分：验证与测试

## 5.1 架构一致性验证清单

### 5.1.1 命名规范验证

| # | 验证项 | 预期 | 验证方法 |
|---|--------|------|---------|
| 1 | 所有 Agent 文件名格式 | `phase-lens-role.md` | `ls agents/*.md` |
| 2 | Agent name 字段与文件名一致 | 匹配 | 逐文件检查 frontmatter |
| 3 | Command 中 Agent 引用正确 | 匹配 | grep 搜索 |
| 4 | Skill 中 Agent 引用正确 | 匹配 | grep 搜索 |
| 5 | agents/README.md 与文件系统一致 | 匹配 | diff 对比 |

### 5.1.2 职责边界验证

| # | 验证项 | 预期 | 验证方法 |
|---|--------|------|---------|
| 6 | Command 不包含执行逻辑 | 只定义 Phase | 检查 Command 文件 |
| 7 | Agent 不加载不相关的 Skills | Skills 属于同一领域 | 检查 Agent frontmatter |
| 8 | Skill 不引用具体 Agent | 使用技能名 | grep 搜索 Skill 文件 |
| 9 | 无 Agent 调用 Agent | 横向隔离 | 检查 Agent 文件 |
| 10 | 无 Skill 调用 Skill | 横向隔离 | 检查 Skill 文件 |

### 5.1.3 Phase 结构验证

| # | 验证项 | 预期 | 验证方法 |
|---|--------|------|---------|
| 11 | 每个 Phase 有 Agent 指定 | 非空 | 检查 Command 文件 |
| 12 | 每个 Phase 有 Input | 非空 | 检查 Command 文件 |
| 13 | 每个 Phase 有 Output | 非空 | 检查 Command 文件 |
| 14 | 每个 Phase 有 Validation | 非空 | 检查 Command 文件 |
| 15 | 并行 Phase 明确标注 | (parallel dispatch) | 检查 Command 文件 |

### 5.1.4 Entry/Exit 验证

| # | 验证项 | 预期 | 验证方法 |
|---|--------|------|---------|
| 16 | 每个 Command 有 Entry Conditions | 非空 | 检查 Command 文件 |
| 17 | 每个 Command 有 Exit Conditions | 非空 | 检查 Command 文件 |
| 18 | Entry/Exit 引用的文件路径正确 | 路径存在 | 检查文件系统 |
| 19 | Next Steps 指向正确的 Command | 命令存在 | 检查 commands/ |
| 20 | Constitutional Rules 引用正确的条款 | 条款存在 | 检查 CANON.md |

---

## 5.2 功能回归测试用例

### 测试用例 1：/refine 完整流程

```
前置条件：
  - CANON.md 已加载
  - 用户有一个初始需求描述

测试步骤：
  1. 用户输入 /refine
  2. Phase 1：requirements-analyst 通过 5W1H 澄清需求
  3. Phase 2：External Scan 搜索已有方案
  4. Phase 3：Refine Scout Army 并行审查（3 个 Scouts）
  5. Phase 4：requirements-analyst 根据 feedback 迭代 spec

预期结果：
  - docs/features/YYYYMMDD-<name>/01-spec.md 已生成
  - artifact_type 已声明
  - 3 个 Scouts 的反馈已合并
  - 所有 Blocking issues 已解决
```

### 测试用例 2：/plan 完整流程

```
前置条件：
  - 01-spec.md 已存在且已批准

测试步骤：
  1. 用户输入 /plan
  2. Phase 1：task-planner 分解任务
  3. Phase 2：Plan Review Army 并行审查（4 个 Reviewers）
  4. Phase 3：task-planner 根据 feedback 迭代 plan

预期结果：
  - 02-plan.md 已生成
  - 4 个 Reviewers 的反馈已合并
  - 所有 Blocking issues 已解决
```

### 测试用例 3：/build (software)

```
前置条件：
  - 02-plan.md 已存在且已批准
  - artifact_type: software

测试步骤：
  1. 用户输入 /build
  2. Phase 1：task-planner 选择执行模式
  3. Phase 2：software-engineer 按 TDD 循环开发
  4. Phase 3：运行完整测试套件

预期结果：
  - 代码产物已生成
  - 所有测试通过
  - ADR 已记录（如有架构决策）
```

### 测试用例 4：/build (document)

```
前置条件：
  - 02-plan.md 已存在且已批准
  - artifact_type: document

测试步骤：
  1. 用户输入 /build
  2. Phase 1：task-planner 选择执行模式
  3. Phase 2：content-writer 按章节增量创作
  4. Phase 3：内容完整性检查

预期结果：
  - 文档产物已生成
  - 内容与 plan 一致
```

### 测试用例 5：/review (software)

```
前置条件：
  - /build 已完成
  - 产物为 software

测试步骤：
  1. 用户输入 /review
  2. Phase 1：确定审查策略（五轴审查）
  3. Phase 2：Review Army 并行审查（4 个 Reviewers）
  4. Phase 3：合并反馈生成 review.md

预期结果：
  - review.md 已生成
  - 4 个 Reviewers 的反馈已合并
  - 反馈按严重度分级
```

### 测试用例 6：/ship 完整流程

```
前置条件：
  - /review 已完成
  - 所有 Blocking issues 已修复

测试步骤：
  1. 用户输入 /ship
  2. Phase 1：发布准备
  3. Phase 2：Ship Audit Army 并行审计（4 个 Auditors）
  4. Phase 3：发布/导出
  5. Phase 4：文档同步

预期结果：
  - ship.md 已生成
  - 发布/导出成功
  - README.md 已更新
```

### 测试用例 7-9：/save, /restore, /learn

```
/save:
  1. 用户输入 /save
  2. 生成 checkpoint 文件
  预期：.claude/checkpoints/YYYYMMDD-HHMMSS-{title}.md 存在

/restore:
  1. 用户输入 /restore
  2. 列出可用 checkpoints
  3. 用户选择并恢复
  预期：工作上下文已恢复

/learn:
  1. 用户输入 /learn
  2. 执行学习记录操作
  预期：.claude/learnings.jsonl 已更新
```

---

## 5.3 性能与并行执行验证

### 并行执行效率验证

| 测试场景 | Agent 数量 | 并行模式 | 验证指标 |
|---------|-----------|---------|---------|
| Review Army | 4 | parallel dispatch | 4 个 Agent 同时启动 |
| Plan Review Army | 4 | parallel dispatch | 4 个 Agent 同时启动 |
| Refine Scout Army | 3 | parallel dispatch | 3 个 Agent 同时启动 |
| Ship Audit Army | 4 | parallel dispatch | 4 个 Agent 同时启动 |

**验证方法：**
1. 在 Command 执行时观察 Agent 调用是否在同一个 assistant turn 中发起
2. 确认每个 Agent 的上下文独立性
3. 确认反馈合并的正确性

### 编排深度验证

```
验证：
1. 最大深度 = Command → Agent → Skill（3 层）
2. 不存在 Command → Agent → Sub-Agent → Skill（4 层）
3. 不存在 Skill → Skill 调用链
4. 不存在 Agent → Agent 调用链
```

---

## 5.4 文档完整性检查

### 5.4.1 文档结构检查

| # | 检查项 | 预期 |
|---|--------|------|
| 1 | 5 个部分完整 | 每个部分有实质内容 |
| 2 | 附录 A-E 完整 | 每个附录有实质内容 |
| 3 | 目录与内容一致 | 每个目录项有对应章节 |
| 4 | 交叉引用正确 | 引用的章节号存在 |
| 5 | 示例代码格式统一 | 使用一致的代码块格式 |

### 5.4.2 内容准确性检查

| # | 检查项 | 预期 |
|---|--------|------|
| 6 | Agent 数量正确 | 22 个（7 新增 + 4 重命名 + 11 保留） |
| 7 | Command 数量正确 | 8 个 |
| 8 | Skill 数量正确 | 43 个（不变） |
| 9 | 重命名映射完整 | 4 个旧名 → 4 个新名 |
| 10 | artifact_type 路由表完整 | 覆盖 5 种类型 |

---

# 附录

## 附录 A：完整重命名映射表

### Agent 重命名

| 旧名 | 新名 | Phase |
|------|------|-------|
| `code-reviewer` | `review-code-reviewer` | verify |
| `security-auditor` | `review-security-auditor` | verify |
| `test-engineer` | `review-test-engineer` | verify |
| `review-accessibility-checker` | `review-accessibility-auditor` | verify |

### 文件重命名

```
agents/code-reviewer.md              → agents/review-code-reviewer.md
agents/security-auditor.md           → agents/review-security-auditor.md
agents/test-engineer.md              → agents/review-test-engineer.md
agents/review-accessibility-checker.md → agents/review-accessibility-auditor.md
```

### 引用更新清单

所有包含以下字符串的文件需要更新：

| 旧引用 | 新引用 |
|--------|--------|
| `code-reviewer` | `review-code-reviewer` |
| `security-auditor` | `review-security-auditor` |
| `test-engineer` | `review-test-engineer` |
| `review-accessibility-checker` | `review-accessibility-auditor` |

---

## 附录 B：新 Agent 定义清单

### B.1 requirements-analyst

```yaml
---
name: requirements-analyst
description: 需求分析师——负责需求澄清、5W1H 提问、需求文档生成
phase: define
invoked_by: /refine (Phase 1, Phase 4)
skills:
  - define-workflow-refine
output: docs/features/YYYYMMDD-<name>/01-spec.md
---
```

### B.2 task-planner

```yaml
---
name: task-planner
description: 任务规划师——负责将 spec 转化为可执行的任务分解
phase: build
invoked_by: /plan (Phase 1, Phase 3), /build (Phase 1)
skills:
  - build-workflow-plan
  - build-cognitive-execution-engine
output: docs/features/YYYYMMDD-<name>/02-plan.md
---
```

### B.3 software-engineer

```yaml
---
name: software-engineer
description: 软件工程师——负责软件开发（TDD、API 设计、数据库、前后端）
phase: build
invoked_by: /build (Phase 2, artifact_type: software)
skills:
  - build-quality-tdd
  - build-backend-api-design
  - build-backend-database
  - build-backend-service-patterns
  - build-workflow-execute
  - build-cognitive-execution-engine
  - build-cognitive-decision-record
output: 代码产物 + tests + adr/
---
```

### B.4 data-architect

```yaml
---
name: data-architect
description: 数据架构师——负责数据建模、schema 设计、数据迁移
phase: build
invoked_by: /build (Phase 2, 软件子领域)
skills:
  - build-backend-database
  - build-cognitive-decision-record
output: 数据模型 + schema + 迁移脚本
---
```

### B.5 api-designer

```yaml
---
name: api-designer
description: API 设计师——负责 API 接口设计、契约定义、版本管理
phase: build
invoked_by: /build (Phase 2, 软件子领域)
skills:
  - build-backend-api-design
  - build-cognitive-decision-record
output: API 契约 + OpenAPI spec
---
```

### B.6 content-writer

```yaml
---
name: content-writer
description: 内容创作者——负责文章、文档、PPT 叙事的内容创作
phase: build
invoked_by: /build (Phase 2, artifact_type: document/article/deck)
skills:
  - build-content-writing
  - build-workflow-execute
  - build-cognitive-execution-engine
output: 文档/文章/PPT 内容
---
```

### B.7 visual-designer

```yaml
---
name: visual-designer
description: 视觉设计师——负责版式布局、视觉层级、交互设计
phase: build
invoked_by: /build (Phase 2, artifact_type: visual/deck)
skills:
  - build-content-layout
  - build-workflow-execute
  - build-cognitive-execution-engine
output: 视觉设计稿 / 布局方案
---
```

---

## 附录 C：新 Command 模板清单

### C.1 /refine

```yaml
---
description: 需求提炼 + External Scan + 多角色 Idea Scout 审查
---
# Command: /refine
## Goal: Transform vague idea into structured spec
## Phases: 4 (Clarify → Scan → Scout Review → Iterate)
## Parallel: Phase 3 (3 Scouts)
## Entry: 用户需求描述
## Exit: 01-spec.md (final)
## Next: /plan
```

### C.2 /plan

```yaml
---
description: 从 spec 到详细任务分解 + 多角色计划审查
---
# Command: /plan
## Goal: Transform spec into actionable task plan
## Phases: 3 (Decompose → Plan Review → Refine)
## Parallel: Phase 2 (4 Reviewers)
## Entry: 01-spec.md (approved)
## Exit: 02-plan.md (final)
## Next: /build
```

### C.3 /build

```yaml
---
description: 按计划增量生成产物（软件 TDD / 内容 / 视觉）+ ADR
---
# Command: /build
## Goal: Execute plan incrementally
## Phases: 3 (Load → Build Loop → Verify)
## Parallel: Phase 2 (if parallel_safe tasks)
## Entry: 02-plan.md (approved)
## Exit: Complete artifact
## Next: /review
```

### C.4 /review

```yaml
---
description: 按产物类型审查 + 多角色并行审查
---
# Command: /review
## Goal: Multi-perspective artifact review
## Phases: 3 (Analyze → Review Army → Merge)
## Parallel: Phase 2 (4 Reviewers)
## Entry: Artifact complete
## Exit: review.md
## Next: /ship or /build (fix)
```

### C.5 /ship

```yaml
---
description: 发布准备 + 审计 + 导出/发布
---
# Command: /ship
## Goal: Pre-release audit and publishing
## Phases: 4 (Prepare → Audit → Publish → Sync)
## Parallel: Phase 2 (4 Auditors)
## Entry: review.md (no blocking)
## Exit: ship.md + README.md
## Next: Monitor or deliver
```

### C.6 /save

```yaml
---
description: 保存当前工作上下文为 checkpoint
---
# Command: /save
## Goal: Capture work context
## Phases: 1 (Capture)
## Entry: Active work context
## Exit: Checkpoint file
## Next: Continue or end session
```

### C.7 /restore

```yaml
---
description: 从 checkpoint 恢复工作上下文
---
# Command: /restore
## Goal: Restore work context
## Phases: 1 (Load)
## Entry: Checkpoint file exists
## Exit: Context restored
## Next: Continue work
```

### C.8 /learn

```yaml
---
description: 跨 session 学习记录管理
---
# Command: /learn
## Goal: Manage learning records
## Phases: 1 (Operate)
## Entry: CANON.md loaded
## Exit: Operation complete
## Next: Continue work
```

---

## 附录 D：术语表

| 术语 | 定义 |
|------|------|
| **Command** | 用户入口命令（如 `/plan`），定义工作流的阶段编排 |
| **Agent** | 具有专业责任边界的角色，执行特定领域的任务 |
| **Skill** | 可复用的执行方法论，提供具体的步骤和检查清单 |
| **Phase** | Command 中的一个工作流阶段，指定 Agent、Skills、Input/Output |
| **artifact_type** | 产物类型（software/document/article/deck/visual），决定加载哪些技能 |
| **Parallel Fan-Out** | 在单个 assistant turn 中同时分派多个 Agent |
| **Review Army** | Review 阶段的并行审查角色组（4 个 Reviewers） |
| **Plan Review Army** | Plan 阶段的并行审查角色组（4 个 Reviewers） |
| **Refine Scout Army** | Refine 阶段的并行审查角色组（3 个 Scouts） |
| **Ship Audit Army** | Ship 阶段的并行审计角色组（4 个 Auditors） |
| **phase-lens-role** | Agent 命名规范：阶段-视角-角色（如 plan-ceo-reviewer） |
| **Blocking / Important / Suggestion** | 审查反馈的三级严重度分类 |
| **TDD** | 测试驱动开发（Test-Driven Development） |
| **ADR** | 架构决策记录（Architecture Decision Record） |
| **CANON.md** | Unified Skills 的宪法，定义 10 条不可变规则 |
| **Vertical Slice** | 垂直切片——功能完整的增量交付单元 |
| **External Scan** | 外部扫描——按 artifact_type 搜索已有方案和事实来源 |
| **5W1H** | What/Why/Who/When/Where/How——需求澄清方法论 |
| **Entry/Exit Conditions** | Phase 或 Command 的前置/后置条件 |
| **Validation** | 验收标准——每个 Phase 完成后必须满足的条件 |
| **编排协议** | Command 作为工作流状态机的模式（相对于"快捷方式模式"） |
| **快捷方式模式** | Command 只是 Skill 加载入口的模式（当前现状） |
| **Self-confirming Loop** | 自己提需求、自己实现、自己验收通过的反模式 |
| **横向隔离** | 同层元素不直接调用（Agent 不调用 Agent，Skill 不调用 Skill） |
| **编排深度** | 调用链深度（Command → Agent → Skill 为最大深度 3） |

---

## 附录 E：参考资料

### 内部文档

| 文档 | 路径 | 说明 |
|------|------|------|
| CANON.md | `/CANON.md` | 宪法（10 条不可变规则） |
| CLAUDE.md | `/CLAUDE.md` | 项目入口配置 |
| orchestration-patterns.md | `/references/orchestration-patterns.md` | 编排模式定义 |
| Agents README | `/agents/README.md` | Agent 列表和分组 |
| load-manifest.json | `/load-manifest.json` | 技能自动加载规则 |
| skills-lock.json | `/skills-lock.json` | 技能完整性锁文件 |

### 设计原则参考

| 原则 | 来源 | 在三层架构中的应用 |
|------|------|------------------|
| Separation of Concerns | Edsger Dijkstra, 1974 | Command/Agent/Skill 三层分离 |
| Single Responsibility | Robert C. Martin (SOLID) | 每个 Agent 只代表一种角色 |
| Dependency Inversion | Robert C. Martin (SOLID) | Command 依赖 Agent 抽象 |
| Open-Closed | Bertrand Meyer, 1988 | 扩展而非修改 |
| Parallel Fan-Out | Claude Code Agent SDK | 并行分派多个 Agent |

### 反模式参考

| 反模式 | 定义来源 | 三层架构如何防御 |
|--------|---------|-----------------|
| Router Persona | orchestration-patterns.md | Agent 不根据条件加载完全不同的 Skill 集合 |
| Persona Chaining | orchestration-patterns.md | Agent 不调用 Agent（横向隔离） |
| Sequential Paraphraser | orchestration-patterns.md | 每个 Phase 有明确的 Input/Output/Validation |
| Deep Persona Trees | orchestration-patterns.md | 编排深度最大为 1 |

---

## 文档修订历史

| 版本 | 日期 | 变更说明 |
|------|------|---------|
| 1.0 | 2026-04-25 | 初始版本：完整的三层架构设计文档 |
