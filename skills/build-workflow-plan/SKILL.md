------
name: build-workflow-plan
description: 把 spec 拆成可执行的任务。适用于 spec 已批准、需要拆成可执行任务时
argument-hint: "[--parallel-safe | --sequential]"
---

# Plan — 任务分解


## 入口/出口
- **入口**: 已批准 spec（`docs/features/YYYYMMDD-<name>/01-spec.md`）+ 已批准 design（如 required）
- **出口**: `docs/features/<name>/03-plan.md`；大型/并行任务额外产出 `docs/features/<name>/plans/*.md` + 用户批准
- **指向**: 用户批准 plan 后必须调用 `build-workflow-execute`
- **输出路径**: → build-workflow-execute
- **前置加载**: CANON.md

## 何时不使用
- 变更只涉及 1-2 个文件且 scope 明显
- spec 已经包含明确定义的任务（此时直接进入 build）

## Agent Dispatch Contract

`/plan` 的主执行 persona 是 `agents/task-planner.md`。它负责把已批准 spec/design 转为任务分解、依赖关系、Plan Topology、Parallel Execution Matrix 和执行模式建议。

- Plan Review Army 只在 Step 7.5 按 `plan-review.md` 的最少触发条件选择 `agents/plan-ceo-reviewer.md`、`agents/plan-eng-reviewer.md`、`agents/plan-design-reviewer.md`、`agents/plan-security-reviewer.md`。
- 标准变更至少覆盖 CEO + Eng；大型、安全、合规或 `--full` 才全开。
- 未被选中的 reviewer 不产出占位反馈；所有已选 reviewer 的反馈必须在 plan 批准前分级处理。

## 核心流程

### Step 1：进入只读模式

写 plan 期间不写代码。搜索、阅读、理解：
- 读取 spec、design 和相关代码库
- **单计划 vs 多计划决策门** — spec 是否涵盖多个独立子系统、多个产物切片或 3+ 个潜在并行任务？
  - XS/S 任务：只写 `03-plan.md`
  - M/L 任务或跨子系统任务：`03-plan.md` 作为总控计划，额外写 `plans/*.md`
  - 有共享契约但可拆分：先写 `plans/01-contracts.md`，再让后续子计划基于契约并行
- 识别现有模式和约定
- 映射组件间依赖关系
- 标注风险和未知

**plan 期间的产出是文档，不是实现。**

### Step 2：识别依赖图和 Plan Topology

先读取 spec 的 `artifact_type`：
- `software`（默认）→ 使用软件依赖图、TDD 任务、构建/测试命令
- `document` / `article` → 使用内容依赖图：受众 → 论点 → 结构 → 草稿 → 编辑 → 导出
- `deck` → 使用演示依赖图：受众 → 叙事线 → 页面结构 → 视觉层级 → speaker notes → 导出
- `visual` → 使用视觉依赖图：目标场景 → 信息层级 → 构图 → 样式系统 → 规格导出

画出构建顺序：

```
Database schema
    │
    ├── API models/types
    │       │
    │       ├── API endpoints
    │       │       │
    │       │       └── Frontend API client
    │       │               │
    │       │               └── UI components
    │       │
    │       └── Validation logic
    │
    └── Seed data / migrations
```

实现顺序按依赖图自底向上：先搭好地基。

同时选择 `Plan Topology`：

| Topology | 使用场景 | 产物 |
|----------|----------|------|
| `serial` | 任务有顺序依赖、共享文件或小任务无需拆分 | 只写 `03-plan.md` |
| `parallel` | 2+ 子计划无共享文件、无顺序依赖、验证独立 | `03-plan.md` + 多个 `plans/*.md`，可标记 `parallel_safe` |
| `gated-parallel` | 共享契约必须先定，后续任务可并行 | `03-plan.md` + `plans/01-contracts.md` + 后续子计划 |

拆成多份 plan 不等于自动并行。只有 `03-plan.md` 的 `Parallel Execution Matrix` 明确标记 `parallel_safe: yes` 的子计划，后续 `/build` 才能使用 `build-cognitive-execution-engine` 模式 B fan-out。

### Step 3：确定文件结构

在定义任务前，映射出哪些文件会被创建或修改及各自的职责。这是在锁定分解决策的地方。

- 设计职责清晰、接口明确的单元。每个文件有一个明确的职责。
- 你能在上下文中持有的代码越多，推理越可靠。偏好更小、更聚焦的文件。
- 一起变化的文件放一起。按职责拆分，不是按技术层。
- 在已有代码库中，遵循现有模式。不要单方面重构。

### Step 4：垂直切片

如果 `artifact_type` 不是 `software`，垂直切片仍然成立，但切片单位变为读者/观众可验证的一段产物：
- `document` / `article`: 一个章节或一个论证单元，包含目标、草稿、事实核查、编辑验证
- `deck`: 一组连续页面或一个叙事段落，包含标题、内容、图表/视觉、演讲备注
- `visual`: 一个使用场景或一个画面版本，包含构图、文案、样式、导出规格

不要先建所有数据库、再建所有 API、最后建所有 UI——一次构建一个完整功能路径：

**Bad（水平切片）：**
```
Task 1: 建整个数据库 schema
Task 2: 建所有 API 端点
Task 3: 建所有 UI 组件
Task 4: 连接所有东西
```

**Good（垂直切片）：**
```
Task 1: 用户注册（注册的 schema + API + UI）
Task 2: 用户登录（登录的 schema + API + UI）
Task 3: 用户创建任务（任务的 schema + API + UI）
Task 4: 用户查看任务列表（查询 + API + 列表 UI）
```

每个垂直切片交付可工作的、可测试的功能。

### Step 5：写 bite-sized 任务

任务模板按 `artifact_type` 调整。`software` 使用测试驱动模板；非软件产物使用产物验证模板。

任务模板、Subplan Contract、Parallel Safety 判定和代码示例规则见 `task-templates.md`。主流程只保留约束：
- 给执行 agent 提供方向和约束，不提供完整实现，除非是复杂算法、安全逻辑或非软件精确产物。
- Software 任务使用 RED → GREEN → REFACTOR 结构；非 software 任务使用产物切片 + 验证证据结构。
- 每个步骤必须是 2-5 分钟可执行操作，并包含明确验证方式。

**禁止占位符：**
每个步骤必须包含实际操作内容。以下都是 plan 失败：
- "TBD"、"TODO"、"implement later"、"fill in details"
- "添加适当的错误处理"/"处理边界情况"（没有具体代码）
- "为以上内容写测试"（没有测试代码）
- "类似 Task N"（重复代码——工程师可能跨顺序阅读任务）
- 引用未在任何任务中定义的类型、函数或方法

### Step 6：排序、Plan Topology 和检查点（强制）

排列任务使：
1. 依赖关系满足（先建基础）
2. 每个任务让系统保持可工作状态
3. 每 2-3 个任务后设验证检查点
4. 高风险任务放前面（快速失败）

多计划模式下，`03-plan.md` 必须包含：
- **Subplans** — 每个 `plans/*.md` 的路径、职责、owner、状态
- **Parallel Execution Matrix** — 哪些子计划可并行，理由是什么
- **Integration Order** — 合并顺序、集成检查点、全量验证命令
- **Shared Contracts** — API/schema/design/content/brand 等共享契约所在子计划

任何子计划如果没有 `Write Scope`，不能分派给 subagent。两个 `parallel_safe` 子计划的 `Write Scope` 不能重叠。

**检查点门：** 每个 checkpoint 的全部项目通过后，才能进入下个阶段。没有全部绿色 = 不能继续。未通过的检查点 → 标记阻塞项 → 回到对应任务修复 → 重新验证。

### Step 7：自审（10 项检查）

写完完整 plan 后，对照 spec 审查：

#### 7.1 Spec 覆盖
逐条检查 spec 的每个要求，能找到对应任务吗？列出任何遗漏。

#### 7.2 占位符扫描
搜索 TBD/TODO/"implement later"/"添加适当的错误处理"等模式，修复。

#### 7.3 类型一致性
后面任务中的函数签名和属性名是否匹配前面定义的？

#### 7.4 Subplans 完整性
`03-plan.md` 中列出的每个 `plans/*.md` 都存在，并有完整的 Subplan Contract。

#### 7.5 并行安全性
任意两个 `parallel_safe` 子计划没有重叠写入范围。

#### 7.6 收口顺序
release/export/ship 类子计划默认串行收口，不能标为 `parallel_safe`。

#### 7.7 任务独立性（新增）
每个任务是否可以独立验证？检查：
- [ ] 每个任务有明确的验收标准
- [ ] 每个任务有独立的验证步骤（不依赖后续任务）
- [ ] 任务之间的依赖关系已明确标注

#### 7.8 验证步骤完整性（新增）
每个任务的验证步骤是否包含：
- [ ] 具体的验证命令（带参数）
- [ ] 预期的输出或结果
- [ ] 失败时的诊断方法

#### 7.9 代码示例风格（新增）
检查代码示例是否符合"最小示例 + 意图注释"原则：
- [ ] 没有完整实现逻辑（除非是复杂算法/安全逻辑/非软件产物）
- [ ] 有关键步骤的意图注释
- [ ] 有边界条件和错误处理的提示

#### 7.10 任务粒度（新增）
检查任务大小是否合理：
- [ ] 单个任务不超过 5 个文件
- [ ] 单个任务的步骤数在 3-7 个之间
- [ ] 任务标题中没有 "and"（有则拆分）

### Step 7.5：Plan Review Army（计划审查军团）

自审通过后，按风险升级规则执行 Plan Review Army。默认标准变更至少覆盖 CEO + Eng；`--full`、大型变更或高风险任务才全开。

详细 reviewer 列表、最小触发规则、反馈模板和合并规则见 `plan-review.md`。

### Step 8：用户批准

请用户审查 plan 文件和 Review Army 反馈 → 确认或修改 → 批准后才进入 build。

## 任务大小指南

| 大小 | 文件数 | 示例 |
|------|-------|------|
| XS | 1 | 单个配置变更 |
| S | 1-2 | 一个组件或端点 |
| M | 3-5 | 一个功能切片 |
| L | 5-8 | **过大——继续分解** |

如果任务出现 "and" 在标题中——这是一个信号表明它其实是两个任务。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 用户拒绝 plan | 问清原因，修改 plan，重新提交审查。不推进已拒绝的 plan。 |
| plan 遗漏 spec 需求 | 补充对应任务，更新 plan。每条 spec 需求必须能找到对应任务。 |
| 依赖关系不正确 | 调整任务顺序，重做 Step 2 依赖图。不靠猜测修正，必须重新画图验证。 |
| 任务过大无法估计 | 进一步分解，直到每个任务 < 5 文件。标题出现"and"= 拆分信号。 |
| 验收条件缺失 | 强制补充。无验收条件的任务不能进入 build，因为"做完"无法判定。 |
| parallel_safe 子计划写入重叠 | 标记为串行，调整 Integration Order。重叠写入是并行安全的天敌。 |

## 验证证据

输出或记录必须包含：
- **输入/来源**: 读取的 spec、plan、代码、反馈或发布上下文。
- **执行动作**: 实际完成的检查、生成、修复、导出或发布步骤。
- **验证结果**: 命令、审查结论、产物路径、截图或人工确认。
- **阻塞/回退**: 未通过项、回退路径或需要 human partner 决策的问题。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "边做边想" | 那正是产生混乱和返工的方式。10 分钟计划节省数小时。 | 无计划的实现典型遗漏 2-3 个依赖关系，每个遗漏导致 2-4 小时返工。 |
| "任务很明显不需要写下来" | 写下来暴露隐藏依赖和被遗忘的边界情况。 | 未记录的"明显"任务平均隐藏 1-2 个边界情况，上线后以 bug 爆发。 |
| "计划就是开销" | 计划就是任务。没计划的实现只是在打字。 | 无计划直接编码 → 任务间依赖混乱 → 集成阶段 >50% 代码需要重排或重写。 |
| "我脑子里装得下" | 上下文窗口有限。书面计划跨越 session 边界和压缩。 | 口头计划在 session 切换后丢失 70%+ 细节，后续执行者只能猜测原始意图。 |
| "之后再来补验收条件" | 没有验收条件就无法判断"做完"。先定义再做。 | 后补验收条件倾向顺应已实现行为而非原始需求，遗漏的边界被永久锁定。 |

## 红旗

- 没有书面任务清单就开始实现
- 任务说"实现功能"但没有验收条件
- plan 中没有验证步骤
- 所有任务都是 L 或 XL 大小
- 阶段之间没有检查点
- 依赖顺序没有执行
- plan 中任务出现 "and" 在标题里（= 两个任务）

## 并行化机会

- **安全并行:** `parallel_safe: yes` 的独立功能切片、已有功能的测试、独立文档/章节/页面组
- **必须串行:** 数据库迁移、共享状态变更、依赖链、发布/导出/合并收口、全局配置
- **需要协调:** 共享 API/schema/design/content/brand 契约的功能；先定义 contracts 子计划，再并行实现
- **执行对齐:** 后续 `/build` 只有在 `Parallel Execution Matrix` 证明无共享写入时，才能使用 `build-cognitive-execution-engine` 模式 B

## 验证清单

- [ ] 每个任务有验收条件
- [ ] 每个任务有验证步骤
- [ ] 任务依赖已识别并正确排序
- [ ] 没有任务超过 ~5 个文件
- [ ] 主要阶段间设了检查点
- [ ] plan 没有占位符（TBD/TODO）
- [ ] spec 的每个需求在 plan 中都有对应任务
- [ ] 多计划任务有 `plans/*.md` 子计划索引
- [ ] 每个子计划有 Write Scope、Dependencies、Parallel Safety、Verification Evidence
- [ ] `parallel_safe` 子计划之间没有重叠写入范围
- [ ] 用户已审查并批准 plan

## 好坏示例

### Good — 垂直切片 + 验收条件

```markdown
### Task 1: 用户注册

**Files:** `src/models/User.ts`, `src/api/register.ts`, `src/components/RegisterForm.tsx`

**Steps:**
1. 定义 User model schema — 验证: `npx prisma validate` 通过
2. 实现 register API endpoint — 验证: `curl -X POST /api/register` 返回 201
3. 实现 RegisterForm component — 验证: 浏览器渲染表单，提交后显示成功

**Verification:** `npm test -- --coverage --grep register` 覆盖率 > 80%

→ 每步有动词+验证命令，垂直切片交付可工作功能
```

### Bad — 水平切片 + 无验收

```markdown
### Task 1: 建数据库
建整个数据库 schema。

### Task 2: 建所有 API
建所有 API 端点。

### Task 3: 建所有 UI
建所有 UI 组件。

→ 问题: 水平切片 → Task 3 完成前无法验证任何用户路径
→ 问题: 无验收条件 → "建完"无法判定
→ 问题: 依赖链过长 → 任何前置任务阻塞后续全部任务
```

## 输出模板

```markdown
### Plan 交付记录 — <feature-name>

**Plan Topology**: [serial / parallel / gated-parallel]
**artifact_type**: [software / document / article / deck / visual]

**Task 清单**:
| Task N | 标题 | 文件数 | 验收条件 | 验证命令 | 依赖 |
|--------|------|-------|---------|---------|------|
| Task 1 | [标题] | [N] | [条件] | [命令] | [无 / Task N] |

**子计划索引**（如适用）:
| 子计划 | Write Scope | parallel_safe | 依赖 | 验证证据 |
|--------|------------|--------------|------|---------|
| plans/01-contracts.md | [范围] | [yes/no] | [依赖] | [命令] |

**Parallel Execution Matrix**（如适用）:
| 子计划 A | 子计划 B | parallel_safe | Write Scope 不重叠 |
|----------|----------|--------------|-------------------|
| [子计划1] | [子计划2] | [yes/no] | [✓/✗] |

**用户批准**: [已批准 / 待批准]
```
