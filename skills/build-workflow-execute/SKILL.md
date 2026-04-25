---
name: build-workflow-execute
description: 按计划增量生成软件或内容产物。使用 cuando plan 已批准需要开始实现或生成交付物
---

# Execute — 增量生成


## 入口/出口
- **入口**: 已批准 plan（`docs/features/<name>/02-plan.md` + 可选 `docs/features/<name>/plans/*.md`）
- **出口**: 软件代码或内容产物 + 验证证据 + ADR（如有决策）
- **指向**: 完成 → `verify-workflow-review`；遇到 Bug → `verify-workflow-debug`
- **假设已加载**: CANON.md + `build-quality-tdd/SKILL.md` + `build-cognitive-execution-engine/SKILL.md`

## 何时不使用
- 探索性原型（标注 `// UNTESTED` 可跳过 TDD，但受 HARD GATE 约束）
- 纯配置变更（加环境变量、改 CI 配置）— 直接提交，不需要增量循环

## 前置
先读取计划拓扑，再调用 `build-cognitive-execution-engine` 选择执行模式。

读取顺序：
1. 读取 `docs/features/<name>/02-plan.md` 总控计划
2. 如果存在 `docs/features/<name>/plans/*.md`，按文件编号逐份读取子计划
3. 从总控计划确认 `Plan Topology`、`Subplans`、`Parallel Execution Matrix`、`Integration Order`
4. 验证每个子计划都有 `Write Scope`、`Read Scope`、`Parallel Safety`、`Verification Evidence`、`Merge Checkpoint`

执行模式：
- **inline** — 当前会话直接执行
- **subagent** — 每任务或每个复杂子计划一个新 subagent + 两阶段审查
- **parallel** — 仅对 `parallel_safe` 子计划并行 subagent

没有 `Parallel Execution Matrix` 或没有 `parallel_safe` 证据时，降级为 `serial` 执行。降级原因必须写入 build 记录。

再读取 spec 的 `artifact_type`：
- `software`（默认）→ 加载 `build-quality-tdd` 以及需要的 frontend/backend/database 技能
- `document` / `article` → 按需加载 `build-content-writing`；涉及版式时加载 `build-content-layout`
- `deck` → **先**加载 `build-content-writing` 完成叙事骨架和逐页标题 → **再**加载 `build-content-layout` 做页面视觉层级。两者顺序执行，不并行。
- `visual` → 加载 `build-content-layout`，涉及文案时加载 `build-content-writing`

deck 的 writing → layout 顺序高于并行优化。即使计划拆成多个子计划，也不能把同一页面组的叙事骨架和版式实现并行。

## Plan Topology 执行规则

### `serial`

- 只读 `02-plan.md` 时，按任务顺序直接执行
- 存在 `plans/*.md` 时，按文件编号顺序执行子计划
- 不分派并行 subagent，除非后续用户明确要求重新规划

### `gated-parallel`

1. 先串行执行 `contracts` / `serial` / `gated` 子计划
2. 验证共享契约通过：API、schema、design、content、brand 或导出规格已经稳定
3. 读取依赖这些契约的 `parallel_safe` 子计划
4. 确认 Write Scope 不重叠后，调用 `build-cognitive-execution-engine` 模式 B fan-out
5. 并行子计划全部完成并通过验证后，按 `Integration Order` 串行合并和全量验证

### `parallel`

只有同时满足以下条件，才允许 fan-out：
- `Parallel Execution Matrix` 明确列出这些子计划之间 `parallel_safe: yes`
- 每个子计划 `Depends On` 为 none 或依赖已完成
- 每个子计划有明确 `Write Scope`
- 任意两个 `parallel_safe` 子计划的 `Write Scope` 不重叠
- 验证方式可独立完成

不满足任一条件时，STOP 或降级串行：
- 缺少 `Write Scope` → STOP，回到 `/plan` 修补
- 共享写入范围 → 降级串行或回到 `/plan` 重新切分
- release/export/ship 子计划标为 `parallel_safe` → STOP，这类收口任务必须串行
- 共享契约未完成 → 按 `gated-parallel` 先执行契约

## 增量循环

```
每个切片：实现 → 测试 → 验证 → 提交 → 下一个切片
```

### Step 1：选切片策略

- **计划拓扑优先** — 如果 `02-plan.md` 定义了 `Plan Topology`，按拓扑执行，不重新发明执行顺序
- **垂直切片（推荐）** — 一次建一条完整路径：DB + API + UI
  ```
  切片 1: 用户注册（注册的 schema + API + UI）→ 测试通过
  切片 2: 用户登录（auth schema + API + UI）→ 测试通过
  ```
- **风险优先切片** — 最难/最不确定的部分先做
- **契约优先切片** — 先定接口契约，前后端并行

### Step 2：实现最小功能

实现让测试通过的最小代码。不提前抽象、不加未要求的功能。

### Step 3：测试

每个切片后跑对应验证：
- `software`: 跑完整测试套件。先 TDD（调用 `build-quality-tdd`）
- `document` / `article`: 做事实核查、逻辑链检查、语气一致性检查
- `deck`: 做叙事线、页面信息密度、speaker notes、导出预览检查
- `visual`: 做视觉层级、对齐、对比度、规格导出检查

### Step 4：验证

- `software`: 测试全部通过、构建成功、类型检查通过、Lint 通过、新功能按预期工作
- 非软件产物: 对应产物的 review 证据齐全，最终导出物能打开且符合 spec

### Step 5：提交

用描述性信息提交。一个提交一个逻辑变更。

### Step 6：循环

进入下一个切片，不要重新开始。

多计划模式下，循环单位是子计划：
- 子计划内按任务切片循环
- 子计划结束时记录 changed_files / artifact_paths / test_results
- 主 agent 按 `Integration Order` 合并子计划结果
- 合并后跑全量验证，确认跨子计划影响

## 任务偏离处理

**当发现任务比预计难时（不要硬撑）：**
- **阻塞（外部依赖缺失、API key、服务不可用）** → 记录阻塞项，跳过当前切片，切到下一个独立切片。不要空等。
- **技术障碍（设计方案不 work）** → STOP。回到 `build-cognitive-decision-record` 记录问题，执行备选方案。可能需要更新 spec 或 plan。
- **scope creep（发现 "顺便" 多做一个功能）** → 记录为 "NOTED"，不移出当前任务范围。Scope Discipline > 效率假象。
- **预计耗时翻倍** → 和用户沟通："这个任务比预期复杂，预计需要 X 时间，OK 吗？"

## 纪律规则

### Rule 0：Simple First
写任何代码前问："最简单的能工作的方法是什么？"
```
✗ 为一个通知建 EventBus + middleware pipeline
✓ 简单函数调用

✗ 抽象工厂模式给两个类似组件
✓ 两个直白的组件 + 共享工具函数

✗ 配置驱动表单生成器给三个表单
✓ 三个表单组件
```
三个相似的代码行 > 一个过早的抽象。

### Rule 0.5：Scope Discipline
只改该改的。不改相邻代码、不重构未改文件的 import、不删不理解的内容。
看到值得改进但不相关的内容 → 记录，不改：
```
NOTICED BUT NOT TOUCHING:
- src/utils/format.ts 有个未使用的 import（和本任务无关）
→ 要我为这些创建任务吗？
```

### Rule 1：一次只改一件事
一个提交 = 一个逻辑变更。不混重构和新功能。

### Rule 2：保持可编译
每个切片后项目必须能构建，已有测试必须通过。

### Rule 3：不完整功能用 feature flag
```typescript
const ENABLE_FEATURE = process.env.FEATURE_X === 'true';
```

### Rule 4：安全默认
新代码默认保守行为，opt-in 而非 opt-out。

### Rule 5：可回滚友好
- 新增文件容易回滚
- 修改最小化且聚焦
- 数据库 migration 要有对应 rollback
- 删除和替换不在同一个提交

## 遇到架构决策 → 写 ADR
调用 `build-cognitive-decision-record/SKILL.md`，产出到 `docs/features/<name>/adr/<num>-<title>.md`。

## 遇到领域专精 → 按需加载相关技能
```
需要前端 → build-frontend-*
需要 API  → build-backend-api-design
需要 DB   → build-backend-database
需要模式  → build-backend-service-patterns
需要 TDD  → build-quality-tdd
需要文案/论证 → build-content-writing
需要版式/视觉层级 → build-content-layout
需要 Git  → build-infrastructure-git
```

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 测试失败 | 如果是新代码 → 修复代码直到测试通过；如果是已有测试 → 检查是否回归，修复回归 |
| 构建失败 | 检查错误信息，修复编译/类型错误，不跳过构建直接继续 |
| 检查点门未通过 | STOP。标记未通过项目 → 回到对应任务修复 → 重新运行检查点 → 全部绿色才继续 |
| 子计划缺 Write Scope | STOP。不能分派 subagent，回到 `/plan` 修补 |
| 两个 parallel_safe 子计划写同一路径 | 降级串行或回到 `/plan` 重新切分 |
| release/export/ship 标 parallel_safe | STOP。收口任务必须串行 |
| 切片比预期复杂 | 评估是否需分解切片。预计耗时翻倍时与用户沟通 |
| 架构决策（ADR）阻塞 | 停止实现，记录 ADR，执行备选方案，可能需要更新 plan |
| Scope creep | 记录为 "NOTED"，不移出当前范围。Scope Discipline > 效率假象 |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "先写代码，测试最后一起跑" | Bug 叠加。切片 1 的 bug 让切片 2-5 都错。 |
| "一次做完更快" | 感觉更快直到 500 行改了之后找不到哪行出的问题。 |
| "这个改动太小不需要单独提交" | 小提交没成本。大提交隐藏 bug 并让回滚困难。 |
| "之后加 feature flag" | 功能不完整就不暴露给用户。现在加 flag。 |
| "顺便重构一下" | 重构混在新功能里让审查和回滚都更难。分开提交。 |

## 红旗
- 写了超过 100 行还没有跑测试
- 一个切片里包含多个不相关的变更
- 未读取 `plans/*.md` 就开始执行多计划任务
- 没有 `Parallel Execution Matrix` 却并行分派 subagent
- subagent 修改超出子计划 Write Scope 的文件
- `parallel_safe` 子计划之间出现 changed_files 冲突
- "让我快速加这个" scope 膨胀
- 跳过测试/验证以加快速度
- 切片之间构建失败或测试中断
- 累积大量未提交变更
- 在第三个使用场景出现前就建抽象
- 为一次性操作建工具文件

## 验证清单

每个切片后：
- [ ] 变更做了一件事且做完整了
- [ ] 所有测试通过
- [ ] 构建成功
- [ ] 类型检查通过
- [ ] Lint 通过
- [ ] 新功能按预期工作
- [ ] 已用描述性信息提交

多计划任务额外检查：
- [ ] 已读取 `02-plan.md` 和所有 `plans/*.md`
- [ ] `Plan Topology` 已决定执行模式
- [ ] `Parallel Execution Matrix` 支持所有 fan-out 决策
- [ ] 每个 subagent 的 changed_files 没有越过 Write Scope
- [ ] 合并后全量验证通过
