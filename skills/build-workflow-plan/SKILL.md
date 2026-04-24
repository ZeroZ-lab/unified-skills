---
name: build-workflow-plan
description: 把 spec 拆成可执行的任务。使用 cuando spec 已批准需要拆成可执行任务
---

# Plan — 任务分解


## 入口/出口
- **入口**: 已批准 spec（`docs/features/YYYYMMDD-<name>/01-spec.md`）
- **出口**: `docs/features/<name>/02-plan.md`；大型/并行任务额外产出 `docs/features/<name>/plans/*.md` + 用户批准
- **指向**: 用户批准 plan 后建议调用 `build-workflow-execute`
- **假设已加载**: CANON.md

## 何时不使用
- 变更只涉及 1-2 个文件且 scope 明显
- spec 已经包含明确定义的任务（此时可以直接进入 build）

### Step 1：进入只读模式

写 plan 期间不写代码。搜索、阅读、理解：
- 读取 spec 和相关代码库
- **单计划 vs 多计划决策门** — spec 是否涵盖多个独立子系统、多个产物切片或 3+ 个潜在并行任务？
  - XS/S 任务：只写 `02-plan.md`
  - M/L 任务或跨子系统任务：`02-plan.md` 作为总控计划，额外写 `plans/*.md`
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
| `serial` | 任务有顺序依赖、共享文件或小任务无需拆分 | 只写 `02-plan.md` |
| `parallel` | 2+ 子计划无共享文件、无顺序依赖、验证独立 | `02-plan.md` + 多个 `plans/*.md`，可标记 `parallel_safe` |
| `gated-parallel` | 共享契约必须先定，后续任务可并行 | `02-plan.md` + `plans/01-contracts.md` + 后续子计划 |

拆成多份 plan 不等于自动并行。只有 `02-plan.md` 的 `Parallel Execution Matrix` 明确标记 `parallel_safe: yes` 的子计划，后续 `/build` 才能使用 `build-cognitive-execution-engine` 模式 B fan-out。

### Step 3：确定文件结构

在定义任务前，映射出哪些文件会被创建或修改及各自的职责。这是在锁定分解决策的地方。

- 设计职责清晰、接口明确的单元。每个文件应该有一个明确的职责。
- 你能在上下文中持有的代码越多，推理越可靠。偏好更小、更聚焦的文件。
- 一起变化的文件应该放一起。按职责拆分，不是按技术层。
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
Task 1: 用户可以注册（注册的 schema + API + UI）
Task 2: 用户可以登录（登录的 schema + API + UI）
Task 3: 用户可以创建任务（任务的 schema + API + UI）
Task 4: 用户可以查看任务列表（查询 + API + 列表 UI）
```

每个垂直切片交付可工作的、可测试的功能。

### Step 5：写 bite-sized 任务

任务模板按 `artifact_type` 调整。`software` 使用测试驱动模板；非软件产物使用产物验证模板：

```markdown
### Task N: [产物切片]

**Files:**
- Create/Modify: `path/to/artifact-source`
- Export: `path/to/final-artifact`

- [ ] **Step 1: 明确切片验收标准**
[读者目标、页面目标、视觉目标或导出规格]

- [ ] **Step 2: 生成/修改最小产物**
[写章节、做页面、调整版式或视觉稿]

- [ ] **Step 3: 按类型验证**
[事实核查、逻辑审查、版式检查、导出预览]

- [ ] **Step 4: 记录验证证据**
[审查结论、截图、导出文件路径或人工确认]
```

如果触发多计划模式，先写 `02-plan.md` 总控，再为每个可独立执行的任务包写 `plans/<NN>-<name>.md`。编号表达执行顺序；名称表达职责，不强制固定为 backend/frontend/content。

子计划必须包含：

```markdown
## Subplan Contract
- **Owner:** 主 agent / subagent 名称或角色
- **Status:** serial / parallel_safe / gated
- **Depends On:** `plans/01-contracts.md` 或其他子计划；没有则写 none
- **Write Scope:** 允许创建/修改的文件、目录或产物路径
- **Read Scope:** 需要读取的 spec、契约、现有文件或外部材料
- **Verification Evidence:** 独立验证命令、审查方式、导出预览或人工确认
- **Merge Checkpoint:** 合并前必须满足的条件
```

`Parallel Safety` 判定：
- `parallel_safe: yes` 只允许在无共享文件、无顺序依赖、接口契约已定、验证可独立完成时使用
- 共享 schema、共享 API 契约未定、同一文件写入、迁移/发布/全局样式/全局配置一律 `parallel_safe: no`
- 需要协调时用 `gated`：先完成契约子计划，再并行执行依赖该契约的子计划

每个步骤是 2-5 分钟的一个操作。每个任务包含：

```markdown
### Task N: [组件名]

**Files:**
- Create: `src/path/to/file.ts`
- Modify: `src/path/to/existing.ts:123-145`
- Test: `tests/path/to/test.ts`

- [ ] **Step 1: 写失败测试**

```typescript
test('特定行为', () => {
  const result = function(input);
  assert.equal(result, expected);
});
```

- [ ] **Step 2: 验证测试失败**

Run: `npm test -- --grep "特定行为"` → FAIL

- [ ] **Step 3: 写最小实现**

```typescript
function function(input) {
  return expected;
}
```

- [ ] **Step 4: 验证测试通过**

Run: `npm test -- --grep "特定行为"` → PASS
```

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

多计划模式下，`02-plan.md` 必须包含：
- **Subplans** — 每个 `plans/*.md` 的路径、职责、owner、状态
- **Parallel Execution Matrix** — 哪些子计划可并行，理由是什么
- **Integration Order** — 合并顺序、集成检查点、全量验证命令
- **Shared Contracts** — API/schema/design/content/brand 等共享契约所在子计划

任何子计划如果没有 `Write Scope`，不能分派给 subagent。两个 `parallel_safe` 子计划的 `Write Scope` 不能重叠。

**检查点门：** 每个 checkpoint 的全部项目通过后，才能进入下个阶段。没有全部绿色 = 不能继续。未通过的检查点 → 标记阻塞项 → 回到对应任务修复 → 重新验证。

### Step 7：自审

写完完整 plan 后，对照 spec 审查：
1. **Spec 覆盖** — 逐条检查 spec 的每个要求，能找到对应任务吗？
2. **占位符扫描** — 搜索 TBD/TODO//"implement later" 模式，修复
3. **类型一致性** — 后面的任务中的函数签名和属性名是否匹配前面定义的？
4. **Subplans 完整性** — `02-plan.md` 中列出的每个 `plans/*.md` 都存在，并有 `Write Scope`、`Dependencies`、`Parallel Safety`、`Verification Evidence`
5. **并行安全性** — 任意两个 `parallel_safe` 子计划没有重叠写入范围；共享契约已经由 contracts 子计划定义
6. **收口顺序** — release/export/ship 类子计划默认串行收口，不能标为 `parallel_safe`

### Step 7.5：Plan Review Army（计划审查军团）

自审通过后，**并行分派** 4 个 specialist 审查 plan：

```
Plan draft
    │
    ├── agents/plan-ceo-reviewer.md     → CEO 视角: 商业价值、范围、优先级
    ├── agents/plan-eng-reviewer.md     → Eng 视角: 技术可行、架构、实现风险
    ├── agents/plan-design-reviewer.md  → Design 视角: 用户体验、交互、一致性
    └── agents/plan-security-reviewer.md → Security 视角: 数据隐私、攻击面、合规
            │
            ▼
    收集反馈 → 分级合并 → 修改 plan → 进入 Step 8
```

每个 specialist 输出 Blocking / Important / Suggestion 三级反馈。

**反馈处理规则：**
- **Blocking** — 必须解决，修改 plan 后再提交批准
- **Important** — 强烈建议采纳，不采纳需在 plan 中记录原因
- **Suggestion** — 自主判断，采纳后标注来源

**最少触发条件：**
- 小型变更（1-3 任务、非安全敏感、无 UI）→ 可跳过 Review Army
- 标准变更 → 至少 CEO + Eng 双视角
- 大型变更（>10 任务或有安全/合规需求）→ 四视角全开

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

- 用户拒绝 plan → 问清原因，修改 plan，重新提交审查
- 发现 plan 遗漏 spec 需求 → 补充对应任务，更新 plan
- 计划的依赖关系不正确 → 调整任务顺序，重新做 Step 2
- 任务过大无法估计 → 进一步分解，直到每个任务 < 5 文件

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "边做边想" | 那正是产生混乱和返工的方式。10 分钟计划节省数小时。 |
| "任务很明显不需要写下来" | 写下来暴露隐藏依赖和被遗忘的边界情况。 |
| "计划就是开销" | 计划就是任务。没计划的实现只是在打字。 |
| "我脑子里装得下" | 上下文窗口有限。书面计划跨越 session 边界和压缩。 |
| "之后再来补验收条件" | 没有验收条件就无法判断"做完"。先定义再做。 |

## 红旗

- 没有书面任务清单就开始实现
- 任务说"实现功能"但没有验收条件
- plan 中没有验证步骤
- 所有任务都是 L 或 XL 大小
- 阶段之间没有检查点
- 依赖顺序没有考虑
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
