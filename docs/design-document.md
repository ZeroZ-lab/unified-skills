# Unified Skills — 设计文档

> 版本: 1.0
> 生成时间: 2026-04-24
> 融合: agent-skills（广度） + superpowers（纪律） + gstack（编排）

---

## 一、设计理念

### 1.1 为什么要做这套

原三套件各有不可替代的优势，但彼此隔离：

| 套件 | 最强点 | 弱点 |
|------|--------|------|
| agent-skills | 领域广度（20+ 技能覆盖全生命周期） | 纪律偏软、无文档体系 |
| superpowers | TDD Iron Law、4-Phase Debugging、subagent 执行 | 领域技能空白、文档分散 |
| gstack | 并行发散编排（/ship 3 specialist）、slash cmd | 内核与 agent-skills 重复 |

**Unified 的定位：** 不是重写，而是**按领域组织、取各最强、填补空白**。

### 1.2 核心理念

```
1. 每个技能只做一件事，做好
2. 按领域组织，按需加载，不浪费 token
3. 统一宪法（CANON）确保纪律一致性
4. 每个想法留下完整档案（第 9 条宪法）
5. 入口/出口契约连接技能，不依赖硬编码流程
```

---

## 二、架构总览

```
unified/
├── canon/canon.md           ← 宪法（9 条，所有技能引用）
│
├── workflow/                核心管道（7 技能，按序使用）
├── frontend/                前端（3 技能，按需调用）
├── backend/                 后端（3 技能，按需调用）
├── quality/                 质量（4 技能，按需调用）
├── infra/                   基础设施（4 技能，按需调用）
├── team/                    团队协作（4 技能，按需调用）
├── cognitive/               认知工具（5 技能，任意阶段）
│
├── commands/                斜杠命令（6 个入口）
├── agents/                  并行审查角色（3 个）
│
├── templates/               文档模板（8 个）
│   ├── feature/             spec / plan / adr / README
│   └── bug/                 root-cause / fix-plan
│
├── docs/                    文档产出目录
├── CLAUDE.md                配置入口
└── README.md                总览
```

**总计：7 领域 × 26 技能 + 1 宪法 + 6 命令 + 3 agent + 8 模板 = 48 文件**

---

## 三、宪法（CANON）

9 条纪律，所有技能在第一条指令自动引用：

| # | 条款 | 来源 | 一句话 |
|---|------|------|--------|
| 1 | Surface Assumptions | agent-skills | 实现前陈述假设 |
| 2 | Simple First | agent-skills + superpowers | 先问最简单的方案 |
| 3 | Scope Discipline | agent-skills | 只改该改的 |
| 4 | TDD Iron Law | superpowers | 没有测试先失败 = 不存在 |
| 5 | Verify Don't Assume | superpowers | 证据先于声明 |
| 6 | 4-Phase Debugging | superpowers | 根因在前，修复在后 |
| 7 | Push Back | agent-skills | 不做 yes-machine |
| 8 | Manage Confusion | agent-skills | STOP → 命名 → 等待 |
| 9 | Every Feature Leaves a Trace | **新增** | 每个想法留下完整档案 |

第 9 条是 Unified 独有的宪法条款——原三套件都没有强制文档留痕。

---

## 四、技能目录（26 个）

### 4.1 workflow — 核心工作流（7 个）

按序使用。从模糊想法到部署上线的完整管道。

| 技能 | 入口 | 做什么 | 出口 | 来源 |
|------|------|--------|------|------|
| **refine** | 模糊想法 | 3 阶段收敛（探索→发散/收敛→写 spec） | `01-spec.md` | superpowers brainstorm + agent-skills idea-refine |
| **spec** | 清晰需求 | 写规范（含未选择方案） | 已批准 spec | agent-skills spec-driven |
| **plan** | 已批准 spec | 拆 5-10min 任务（完整代码、禁止 TBD、标注依赖） | `02-plan.md` | agent-skills planning + superpowers writing-plans |
| **build** | 已批准 plan | 垂直切片增量实现（风险/价值/契约优先策略） | 代码+测试+ADR | agent-skills incremental |
| **debug** | Bug | 4 阶段根因调试 + Phase 4.5 架构质疑门 | 根因记录+复现测试 | superpowers systematic-debugging |
| **review** | 功能完成 | 五轴审阅 + 可选并行发散 | 审查报告 | agent-skills review + gstack parallel |
| **ship** | 通过审查 | 预发检查 → Go/No-Go → 回滚计划 → 文档聚合 | `04-ship.md` + `README.md` | agent-skills ship + gstack /ship |

### 4.2 frontend — 前端（3 个）

| 技能 | 来源 | 说明 |
|------|------|------|
| **ui-engineering** | agent-skills | 设计系统→组件→a11y→响应式→状态覆盖→测试 |
| **browser-testing** | agent-skills | DevTools 运行时验证（Console/DOM/Network/Style） |
| **accessibility** | **新增** | 键盘导航、屏幕阅读器、对比度、WCAG AA/AAA |

### 4.3 backend — 后端（3 个）

| 技能 | 来源 | 说明 |
|------|------|------|
| **api-design** | agent-skills | 契约优先→输入验证→错误模型→版本策略 |
| **database** | **新增** | Schema 设计→迁移(up+down)→查询优化→数据完整性 |
| **service-patterns** | **新增** | 通信模式→服务边界→CQRS/Saga→错误处理 |

### 4.4 quality — 质量（4 个）

| 技能 | 来源 | 说明 |
|------|------|------|
| **tdd** | superpowers（Iron Law） | RED→GREEN→REFACTOR，三级纪律自适应 |
| **integration-testing** | **新增** | 组件交互验证、API 边界、关键流程 |
| **performance** | agent-skills | 先测量→定位瓶颈→一次改一个→重新测量 |
| **security** | agent-skills | 威胁模型→输入清洗→最小权限→密钥→CVE |

### 4.5 infra — 基础设施（4 个）

| 技能 | 来源 | 说明 |
|------|------|------|
| **ci-cd** | agent-skills | 触发条件→构建→测试分层→质量门→部署步骤 |
| **deploy** | agent-skills（从 ship 分离） | 环境配置→发布策略→健康检查→回滚剧本 |
| **observability** | **新增** | 日志→指标(USE/RED)→链路追踪→告警→Dashboard |
| **git** | agent-skills | 原子提交→描述性信息→分支策略 |

### 4.6 team — 团队（4 个）

| 技能 | 来源 | 说明 |
|------|------|------|
| **documentation** | agent-skills（强化） | ADR 流程，强制含"未选择方案" |
| **code-review-standards** | agent-skills | Critical/Important/Suggestion 分级标准 |
| **deprecation-migration** | agent-skills | 弃用公告→兼容层→迁移工具→清理 |
| **retro** | **新增** | 时间线→做得好→可以更好→行动项 |

### 4.7 cognitive — 认知工具（5 个）

| 技能 | 来源 | 说明 |
|------|------|------|
| **brainstorm** | superpowers | 9 步结构化脑暴（探索→澄清→方案→设计→写 doc） |
| **context** | agent-skills | 上下文加载/清理/验证 |
| **source-driven** | agent-skills | 不猜 API 行为，查官方文档 |
| **decision-record** | **新增** | 决策框架（问题→选项→评估→权衡→记录） |
| **execution-engine** | superpowers | 3 种执行模式 + 4 种 subagent 状态处理 |

---

## 五、文档体系（第 9 条宪法）

每个功能完成后 = `docs/features/<name>/` 下完整档案：

```
docs/features/<name>/
├── 01-spec.md        ← refine 产出（含未选择方案 + scope 边界）
├── 02-plan.md        ← plan 产出（依赖顺序 + 完整代码 + 禁止 TBD）
├── adr/              ← build 中决策时创建
│   ├── 01-xxx.md     ← 含"未选择的方案 + 放弃原因"
│   └── 02-xxx.md
├── 03-review.md      ← review 产出（可选）
├── 04-ship.md        ← ship 产出（预发检查 + 回滚计划）
└── README.md         ← ship 完成时自动聚合
    （时间线 + 关键决策 + 变更统计 + 事后总结）
```

Bug 文档：

```
docs/bugs/<name>/
├── 01-root-cause.md  ← debug 产出
├── 02-fix-plan.md    ← 修复方案
└── 03-verification.md ← 验证记录
```

**关键设计决策：** 每份文档都有明确的"被翻阅场景"，保证不会变成僵尸文档。

---

## 六、执行引擎

三种执行模式，按任务复杂度自动选择：

| 模式 | 适用 | 机制 |
|------|------|------|
| **Inline** | 1-2 文件、简单变更 | 当前会话按序执行 |
| **Subagent** | 复杂功能、5+ 文件 | 每个任务派发独立 agent + 两阶段审阅 |
| **Parallel** | 独立子任务 | 多个 agent 同时执行（需 plan 标注 independence） |

Subagent 状态处理：

| 状态 | 含义 | 处理 |
|------|------|------|
| DONE | 完成 | 进入审阅 |
| DONE_WITH_CONCERNS | 完成但有疑虑 | 评估 concern 后决定 |
| NEEDS_CONTEXT | 缺上下文 | 补充后重发 |
| BLOCKED | 阻塞 | 调整任务或计划 |

两阶段审阅：每个 subagent 完成后，先做 **spec 合规审阅**（代码是否匹配 spec，无多余功能），再做 **代码质量审阅**。

---

## 七、核心工作流（完整流程图）

```
用户: "我有个想法"
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ workflow/refine                                                  │
│ Phase 1: 探索（问题/现状/约束/成功标准/上下文）                   │
│ Phase 2: 发散→收敛（2-3 方案 + 推荐 + scope 确认）               │
│ Phase 3: 写 01-spec.md → 自审 → 用户批准                          │
└────────────────────────────────┬────────────────────────────────┘
                                 │ 用户批准 spec
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ workflow/spec                                                    │
│ 完善规范文档（细化验收标准、架构、未选择方案）                     │
└────────────────────────────────┬────────────────────────────────┘
                                 │ spec 定稿
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ workflow/plan                                                    │
│ Step 1: 确认文件结构 + 依赖顺序（标注可并行）                     │
│ Step 2: 拆 5-10min 任务（完整代码+测试，禁止 TBD/TODO）           │
│ Step 3: 自审（spec 覆盖/占位符/类型签名一致性）                    │
│ Step 4: 用户批准 → 选择执行模式                                   │
└────────────────────────────────┬────────────────────────────────┘
                                 │ 用户批准 plan
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ workflow/build + cognitive/execution-engine + quality/tdd        │
│                                                                  │
│ 选择执行模式: inline / subagent / parallel                       │
│                                                                  │
│ 对每个切片:                                                      │
│   RED: 写测试 → 验证 FAIL                                        │
│   GREEN: 写最小代码 → 验证 PASS                                   │
│   REFACTOR: 保持绿色改进代码                                      │
│   COMMIT: 原子提交                                               │
│                                                                  │
│   ├── 遇到决策 → team/documentation → 写 ADR                     │
│   ├── 需要 UI → frontend/ui-engineering                          │
│   ├── 需要 API → backend/api-design                              │
│   ├── 需要安全 → quality/security                                │
│   ├── 需要性能 → quality/performance                             │
│   └── 遇到 Bug → workflow/debug                                  │
│                                                                  │
│  Subagent 模式: 每个任务后经两阶段审阅                             │
│  Phase A: spec 合规审阅                                          │
│  Phase B: 代码质量审阅                                            │
└────────────────────────────────┬────────────────────────────────┘
                                 │ 所有切片完成
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ workflow/review                                                  │
│                                                                  │
│ 标准模式: 五轴审阅（Correctness/Readability/Architecture/        │
│           Security/Performance）                                  │
│                                                                  │
│ 并行发散模式（高风险）:                                           │
│   同时派发: code-reviewer + security-auditor + test-engineer      │
│   合并报告 → 分级输出（Critical/Important/Suggestion）            │
│                                                                  │
│ 产出: 03-review.md（可选）                                        │
└────────────────────────────────┬────────────────────────────────┘
                                 │ 审阅通过
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ workflow/ship                                                    │
│                                                                  │
│ Phase A: 预发检查清单（逐项运行验证，不靠感觉）                   │
│ Phase B: 可选并行质量门                                           │
│ Phase C: Go/No-Go 决策 + 强制回滚计划                             │
│ Phase D: 聚合文档                                                 │
│   产出: 04-ship.md                                               │
│   产出: README.md（时间线+决策+变更统计+事后总结）                │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
                        ✅ 功能完成
              完整档案在 docs/features/<name>/
```

---

## 八、入口/出口契约

所有技能都有明确的入口和出口，技能之间通过契约连接，不依赖硬编码顺序：

```
workflow/refine
  入口: 模糊想法
  出口: 01-spec.md + 用户批准
  指向: workflow/spec

workflow/spec
  入口: refine 产出或已有清晰需求
  出口: 已批准的正式 spec
  指向: workflow/plan

workflow/plan
  入口: 已批准 spec
  出口: 02-plan.md + 用户批准
  指向: workflow/build

workflow/build
  入口: 已批准 plan
  出口: 功能代码 + 测试 + ADR
  指向: workflow/review
  分支: 遇到 Bug → workflow/debug

workflow/debug
  入口: Bug 报告 / 测试失败
  出口: 复现测试通过 + 根因记录
  指向: 回到原流程

workflow/review
  入口: 已完成的功能代码
  出口: 审查报告
  指向: workflow/ship（通过）或 修复后重审

workflow/ship
  入口: 通过 review 的代码
  出口: 04-ship.md + README.md
```

---

## 九、与原三套件对比

### 9.1 整体架构

| 维度 | agent-skills | superpowers | gstack | **Unified** |
|------|-------------|-------------|--------|-------------|
| 技能数 | 20+ | 14 | ~21 | **26** |
| 领域分组 | 流水线 | 无 | 流水线 | **7 领域** |
| 按需加载 | ⚠️ 全量加载 | ⚠️ 全量加载 | ⚠️ 全量加载 | **✅ 按领域加载** |
| 宪法 | 6 条操作行为（分散） | 验证+TDD Iron Law | 无 | **9 条统一宪法** |
| 文档体系 | 无 | 有但分散 | 对话级别 | **✅ 按想法聚合** |
| 新增领域 | - | - | - | **accessibility/database/service-patterns/observability/retro/decision-record** |

### 9.2 Subagent 和 Plan 能力

| 能力 | agent-skills | superpowers | gstack | **Unified** |
|------|-------------|-------------|--------|-------------|
| Subagent 派发 | ❌ 无 | ✅ 每个任务独立 subagent | ⚠️ 仅 /ship 并行发散 | **✅ 3 种模式** |
| Subagent 模式数 | 0 | 2 | 1 | **3（inline/subagent/parallel）** |
| Subagent 状态反馈 | ❌ | ✅ 4 态 | ❌ | **✅ 4 态 + 处理策略** |
| Plan 任务粒度 | 任务级 | **2-5 分钟** | 任务级 | **5-10 分钟** |
| Plan 完整代码 | ❌ TBD 允许 | ✅ 完整代码 | ❌ TBD 允许 | **✅ 完整代码，禁止 TBD** |
| Plan 依赖顺序 | 可选 | 无 | 无 | **✅ 强制标注** |
| Plan 自审 | 无 | 有 | 无 | **✅ spec 覆盖+占位符+签名** |

### 9.3 TDD 纪律

| 维度 | agent-skills | superpowers | gstack | **Unified** |
|------|-------------|-------------|--------|-------------|
| 纪律强度 | 强烈建议 | **Iron Law（删除重来）** | 建议 | **Iron Law + 自适应三级** |
| 自适应级别 | 一档 | 一档 | 一档 | **强制/跳过/原型标注** |

### 9.4 Debug 能力

| 维度 | agent-skills | superpowers | gstack | **Unified** |
|------|-------------|-------------|--------|-------------|
| 阶段数 | 标准 | **4 阶段** | 无独立 | **4 阶段 + Phase 4.5** |
| 架构质疑门 | ❌ | ✅ | ❌ | **✅ 3 次失败→质疑架构** |
| 复现测试强制 | 建议 | **强制** | 建议 | **强制** |

### 9.5 并行审查

| 维度 | agent-skills | superpowers | gstack | **Unified** |
|------|-------------|-------------|--------|-------------|
| 五轴审阅 | ✅ | ❌ | ✅ | **✅** |
| 并行发散 | ❌ | ❌ | ✅ 仅 /ship | **✅ review + ship 均可选** |
| 触发条件 | 无 | 无 | 无 | **50行+/敏感/用户指定** |

### 9.6 文档留痕

| 能力 | agent-skills | superpowers | gstack | **Unified** |
|------|-------------|-------------|--------|-------------|
| 按想法聚合 | ❌ | ⚠️ 分散 | ❌ | **✅ 1 目录 6 文件** |
| ADR 含未选择方案 | ❌ | ❌ | ❌ | **✅ 强制** |
| 事后总结 | ❌ | ❌ | ❌ | **✅ 自动聚合** |
| 3 个月后可回顾 | ❌ | ⚠️ 可找回 | ❌ | **✅ 5 分钟理解全貌** |

---

## 十、Unified 从各套件取了什么

| 套件 | 贡献 | 具体技能/能力 |
|------|------|-------------|
| **agent-skills** | 领域广度 | ui-engineering、browser-testing、api-design、ci-cd、git、documentation、security、performance、deprecation-migration、context、source-driven、spec、planning、code-review-standards、shipping + 6 条操作行为 |
| **superpowers** | 纪律硬度 | TDD Iron Law、4-Phase Debugging（含 Phase 4.5）、verify-before-completion、subagent-driven-development、executing-plans、brainstorming、writing-plans（极端细节） |
| **gstack** | 编排层 | 并行发散模式（/ship 3 specialist）、slash cmd 入口、回滚计划强制 |

## 十一、Unified 新增了什么

| 新增项 | 位置 | 说明 |
|--------|------|------|
| 宪法第 9 条 | canon/canon.md | "每个想法留下完整档案" |
| 领域分组 | 全目录结构 | 7 领域按需加载 |
| accessibility | frontend/ | 键盘导航、屏幕阅读器、WCAG |
| database | backend/ | Schema、迁移、查询优化 |
| service-patterns | backend/ | 通信模式、服务边界、CQRS |
| observability | infra/ | 日志/指标/追踪/告警 |
| retro | team/ | 事后回顾流程 |
| decision-record | cognitive/ | 标准化决策框架 |
| ADR 强制"未选择方案" | team/documentation、templates/adr | 防止重复决策 |
| Ship 自动聚合 README | workflow/ship、templates/feature/README | 事后总结自动化 |
| 文档体系 | docs/feature/*、templates/* | 8 个模板覆盖完整生命周期 |

---

## 十二、技能加载策略

按领域按需加载，不浪费 token：

```
每次会话起始 → 只加载 canon/canon.md

根据任务类型加载对应领域：

/refine 或 /plan     → workflow/*（核心管道）
/build 中需要 UI     → frontend/* 按需加
/build 中需要 API    → backend/* 按需加
/review --full        → agents/*（并行审阅时加载）
/cognitive/*          → 任意阶段单独加载
```
