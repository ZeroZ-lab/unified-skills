------
name: build-workflow-plan
description: 把 spec 拆成可执行的任务。当 spec 已批准需要拆分任务，或提到"计划""任务拆分""排期"
argument-hint: "[--parallel-safe | --sequential]"
---

# Plan — 任务分解


## 入口/出口
- **入口**: 已批准 spec（`docs/features/YYYYMMDD-<name>/01-spec.md`）+ 已批准 design（如 required）
- **出口**: `docs/features/<name>/03-plan.md`；大型/并行任务额外产出 `docs/features/<name>/plans/*.md` + 用户批准
- **指向**: 用户批准 plan 后必须调用 `build-workflow-execute`
- **输出路径**: → build-workflow-execute
- **前置加载**: CANON.md
- **辅助参考**: `task-templates.md`（任务模板、Subplan Contract、Parallel Safety 判定、代码示例规则）、`plan-review.md`（Plan Review Army 详细规则）

## 何时不使用
- 变更只涉及 1-2 个文件且 scope 明显
- spec 已经包含明确定义的任务（此时直接进入 build）

## Agent Dispatch Contract

`/plan` 主执行 persona 是 `agents/task-planner.md`。

- Plan Review Army 在 Step 7.5 按 `plan-review.md` 最少触发条件选择 `agents/plan-ceo-reviewer.md`、`agents/plan-eng-reviewer.md`、`agents/plan-design-reviewer.md`、`agents/plan-security-reviewer.md`
- 标准变更至少 CEO + Eng；大型、安全、合规或 `--full` 才全开
- 未被选中的 reviewer 不产出占位反馈；所有已选 reviewer 反馈在 plan 批准前分级处理

## 核心锚点

### Vertical Slicing

每个任务交付一个完整、可独立验证的功能路径。不按技术层水平切片。

**执行规则：**
- Software：一个任务 = 一个用户路径（schema + API + UI），不拆成"建所有 DB → 建所有 API → 建所有 UI"
- Content（document/article）：一个章节 = 一个任务（目标 + 草稿 + 事实核查 + 编辑验证）
- Deck：一组连续页面 = 一个任务（标题 + 内容 + 视觉 + speaker notes）
- 任务标题出现 "and" = 拆分信号

### Plan Topology

按依赖关系和并行需求选择拓扑。

**执行规则：**
- `serial`：有序依赖、共享文件、小任务 → 只写 `03-plan.md`
- `parallel`：无共享文件、无顺序依赖 → `03-plan.md` + 多个 `plans/*.md`，标记 `parallel_safe`
- `gated-parallel`：共享契约先定，后续可并行 → `03-plan.md` + `plans/01-contracts.md` + 后续子计划
- 实现顺序按依赖图自底向上；只有 `Parallel Execution Matrix` 标记 `parallel_safe: yes` 的子计划才能并行

### Bite-sized Tasks

每个任务 3-7 步、≤5 文件、2-5 分钟可执行操作。

**执行规则：**
- Software 任务用 RED → GREEN → REFACTOR 结构；非 software 用产物切片 + 验证证据结构
- 禁止占位符：TBD/TODO/"implement later"/"添加适当的错误处理"（无具体代码）= plan 失败
- 给执行 agent 提供方向和约束，不提供完整实现（复杂算法/安全逻辑/精确产物除外）

## 核心流程

### Step 1：进入只读模式

不写代码。读取 spec、design 和相关代码库，识别模式和依赖。

**单计划 vs 多计划决策门：**
- XS/S 任务：只写 `03-plan.md`
- M/L 或跨子系统：`03-plan.md` 总控 + `plans/*.md` 子计划
- 有共享契约但可拆分：先写 `plans/01-contracts.md`，后续子计划基于契约并行

### Step 2：识别依赖图和 Plan Topology（锚点执行）

先读取 `artifact_type` 选择依赖图模型（software/content/deck/visual），再按 Plan Topology 锚点选择拓扑。

### Step 3：确定文件结构

映射出哪些文件会被创建或修改。每个文件一个明确职责；一起变化的放一起；遵循现有模式。

### Step 4：垂直切片（锚点执行）

### Step 5：写 bite-sized 任务（锚点执行）

任务模板见 `task-templates.md`。

### Step 6：排序、Topology 和检查点

排列任务使依赖满足、系统保持可工作、高风险任务放前面、每 2-3 个任务设验证检查点。

多计划模式下 `03-plan.md` 必须包含：Subplans + Parallel Execution Matrix + Integration Order + Shared Contracts。任何子计划没有 `Write Scope` 不能分派；两个 `parallel_safe` 子计划 Write Scope 不能重叠。

### Step 7：自审

写完 plan 后对照以下 10 项检查：

- [ ] Spec 覆盖：每条 spec 要求能找到对应任务
- [ ] 占位符扫描：无 TBD/TODO/"implement later"/"添加适当的错误处理"
- [ ] 类型一致性：后续任务的函数签名匹配前面定义的
- [ ] Subplans 完整：每个 `plans/*.md` 存在且有 Subplan Contract
- [ ] 并行安全：`parallel_safe` 子计划无重叠写入
- [ ] 收口顺序：release/ship 类子计划默认串行
- [ ] 任务独立性：每个任务有验收标准、独立验证步骤、依赖已标注
- [ ] 验证完整性：每个验证步骤有具体命令 + 预期输出 + 失败诊断
- [ ] 代码示例风格：最小示例 + 意图注释，无完整实现逻辑
- [ ] 任务粒度：≤5 文件、3-7 步、标题无 "and"

### Step 7.5：Plan Review Army

自审通过后按风险升级执行 Review Army。详见 `plan-review.md`。

### Step 8：用户批准

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 用户拒绝 plan | 问清原因，修改 plan，重新提交 |
| plan 遗漏 spec 需求 | 补充任务；每条 spec 需求必须能找到对应任务 |
| 依赖关系不正确 | 重做依赖图验证 |
| 任务过大 | 分解到 ≤5 文件；标题出现 "and" = 拆分 |
| 验收条件缺失 | 强制补充；无验收条件的任务不能进入 build |
| parallel_safe 写入重叠 | 标记为串行，调整 Integration Order |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "边做边想" | 10 分钟计划节省数小时。 | 无计划遗漏 2-3 个依赖，每个导致 2-4 小时返工 |
| "任务很明显不需要写下来" | 写下来暴露隐藏依赖和边界情况。 | 未记录的"明显"任务隐藏 1-2 个边界，上线后 bug |
| "计划就是开销" | 计划就是任务。没计划的实现只是在打字。 | 无计划 → 依赖混乱 → 集成阶段 >50% 代码需重排 |
| "之后补验收条件" | 没有验收条件就无法判断"做完"。 | 后补验收条件倾向顺应已实现行为，遗漏被永久锁定 |

## 红旗

- 没有书面任务清单就开始实现
- 任务说"实现功能"但没有验收条件
- plan 中没有验证步骤
- 所有任务都是 L 或 XL 大小
- 阶段之间没有检查点
- 依赖顺序没有执行
- plan 中任务标题出现 "and"（= 两个任务）

## 验证清单

- [ ] 每个任务有验收条件和验证步骤
- [ ] 任务依赖已识别并正确排序
- [ ] 没有任务超过 ~5 个文件
- [ ] 主要阶段间设了检查点
- [ ] plan 没有占位符
- [ ] spec 每个需求在 plan 中都有对应任务
- [ ] 多计划任务有 Subplans、Parallel Execution Matrix、Integration Order
- [ ] `parallel_safe` 子计划之间没有重叠写入
- [ ] 用户已审查并批准 plan

## 好坏示例

### Good — 垂直切片 + 验收条件

```
Task 1: 用户注册 — Files: User.ts, register.ts, RegisterForm.tsx
  Step 1: 定义 schema → 验证: prisma validate
  Step 2: 实现 API → 验证: curl POST /api/register → 201
  Step 3: 实现 UI → 验证: 浏览器提交表单 → 成功提示
  Verification: npm test --coverage --grep register > 80%
```

### Bad — 水平切片 + 无验收

```
Task 1: 建数据库（整个 schema）
Task 2: 建所有 API
Task 3: 建所有 UI
→ 水平切片: Task 3 完成前无法验证任何用户路径
→ 无验收条件: "建完"无法判定
→ 依赖链过长: 任何前置阻塞后续全部
```

## 输出模板

```markdown
### Plan — <feature-name>

Plan Topology: [serial / parallel / gated-parallel] | artifact_type: [software/...]

Task 清单:
| Task N | 标题 | 文件数 | 验收条件 | 验证命令 | 依赖 |
|--------|------|-------|---------|---------|------|
| 1 | [标题] | [N] | [条件] | [命令] | [无/Task N] |

子计划索引（如适用）:
| 子计划 | Write Scope | parallel_safe | 依赖 | 验证 |
|--------|------------|--------------|------|------|
| plans/01-*.md | [范围] | [yes/no] | [依赖] | [命令] |

Parallel Execution Matrix（如适用）:
| A | B | safe | 无重叠 |
|---|---|------|--------|
| [1] | [2] | [yes/no] | [✓/✗] |

用户批准: [已批准 / 待批准]
```
