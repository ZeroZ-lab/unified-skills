---
name: define-cognitive-brainstorm
description: 结构化脑暴——发散探索 + 收敛评估。当想法模糊、面临开放性问题或需要方案对比，或提到"脑暴""想法""方案对比""怎么办"
argument-hint: "[模糊想法或开放性问题]"
agents:
  - brainstorm-tech-scout
  - brainstorm-design-scout
  - brainstorm-business-scout
  - brainstorm-content-scout
  - brainstorm-data-scout
  - brainstorm-security-scout
  - brainstorm-outlier-scout
---

# Brainstorm — 结构化脑暴


## 入口/出口
- **入口**: 模糊想法、开放性问题、"我怎么做 X?"、设计方案多选一
- **出口**: `docs/features/YYYYMMDD-<name>/00-brainstorm.md` + 用户批准的方向
- **指向**: 用户批准后建议 `define-workflow-spec`（需求已清晰）或 `define-workflow-refine`（仍需收敛）
- **前置加载**: CANON.md
- **输出路径**: `docs/features/YYYYMMDD-<name>/00-brainstorm.md` → 下游 `define-workflow-refine` 或 `define-workflow-spec`

## 何时不使用
- 用户已经给出明确 spec、验收标准和执行边界
- 只是实现一个已批准计划中的具体任务
- 问题需要事实核查或代码诊断，而不是方案发散

## Iron Law

```
脑暴的价值 = 收敛时的明确性 - 发散时的混乱度。
发散是过程，收敛是目的。
"不做清单"可能是最有价值的部分——集中就是放弃好想法。
```

## Agent Dispatch Contract

`/brainstorm` 使用**按需选座**的多席位并行脑暴模式。

**Phase 1**: 当前 agent 直接执行上下文探索。

**Phase 2**: 根据 `--profile` 或 `--seats` 选择 scout 组合，读取 `commands/brainstorm-menu.json` 后使用 `Agent` 工具并行启动。`/brainstorm` 是 Markdown 阶段协议，不是 shell CLI；参数由 current agent 解释。

**参数与配置规则：**
- `--list-profiles`：只列出 `commands/brainstorm-menu.json` 中 profiles / seats，不启动 scout
- `--profile <name>`：使用 `task_profiles.<name>.seats`
- `--seats a,b,c`：短名规范化为 `brainstorm-<name>-scout`
- 未提供参数：使用 `default_seats`
- `brainstorm-outlier-scout` 默认自动加入；只有用户明确写 `--no-outlier` 才排除
- `commands/brainstorm-menu.json` 缺失或无法解析时 STOP，改用本技能内联 profile 列表，并在输出中标记 fallback

**可用 Scout：**
- `agents/brainstorm-tech-scout.md` — 技术可行性、架构方案、实现路径
- `agents/brainstorm-design-scout.md` — 用户体验、交互路径、情感连接
- `agents/brainstorm-business-scout.md` — 产品价值、市场定位、商业模式
- `agents/brainstorm-content-scout.md` — 叙事结构、受众共鸣、表达方式
- `agents/brainstorm-data-scout.md` — 数据建模、存储策略、查询优化
- `agents/brainstorm-security-scout.md` — 威胁模型、防护策略、合规要求
- `agents/brainstorm-outlier-scout.md` — 边缘视角、激进想法、反向思考（默认参与，用户可显式 `--no-outlier` 排除）

**预设配置（Profile）：**
- `general`: tech + design + business + outlier（默认）
- `tech_architecture`: tech + data + security + outlier
- `product_strategy`: business + design + content + outlier
- `content_marketing`: content + design + business + outlier
- `api_design`: tech + data + security + outlier
- `security_review`: security + tech + data + outlier
- `user_experience`: design + content + business + outlier
- `data_strategy`: data + tech + security + outlier

每个 scout 独立执行，互不干扰，使用各自的专业框架发散。宿主不支持 subagent 时，由 current agent 按 seat 串行模拟并明确标记 fallback；不得假装已经并行。

**Phase 3**: 当前 agent 作为 facilitator，执行交叉 fertilization 和辩论：
- 让 scout 互相阅读报告
- 标注争议点
- 识别合并机会

**Phase 4**: 当前 agent 收敛整合，输出最终推荐。

- 不把其他阶段（refine/plan/build/review）的 agent 提前拉入脑暴阶段。
- 如果脑暴发现需求已经足够清晰，输出推荐方向后交给后续 spec/refine 流程，而不是在本阶段创建实现任务。

## 流程: 发散 → 收敛 → 打磨

### Phase 1: 探索上下文

在深入之前：
1. 阅读项目的 AGENTS.md / spec / plan 了解现状；如需 Claude 专属提示，再补读 CLAUDE.md
2. 阅读相关代码——避免脱离代码库的空想
3. 明确约束："技术上 X 已经存在，所以方案不能破坏它"

### Phase 2: 多角度并行发散

读取 `commands/brainstorm-menu.json` 后，使用 `Agent` 工具并行启动已选 scout，每个从不同角度发散：

**Scout 框架分配：**

| Scout | 核心框架 | 产出 |
|-------|----------|------|
| **brainstorm-tech-scout** | First Principles / Constraints / Pre-mortem / Time-travel | 技术提案、架构方案、实现路径、创新机会 |
| **brainstorm-design-scout** | HMW / Crazy 8 / Role-play / Anti-pattern | 设计提案、用户旅程、交互模式、情感设计 |
| **brainstorm-business-scout** | JTBD / Blue Ocean / Business Model Canvas / Pre-mortem | 商业提案、价值主张、市场定位、增长路径 |
| **brainstorm-outlier-scout** | Inversion / 10x Thinking / Constraints → Freedom / 挑战所有假设 | 激进提案、反向思考、黑天鹅事件、跨界借鉴 |

**并行执行要点：**
- 所有 scout 获得相同的上下文和约束
- 每个 scout 输出 2-3 个提案 + Wildcards
- `outlier-scout` 默认参与并必须提出至少 1 个"看起来很荒谬"的想法；用户显式 `--no-outlier` 时必须记录排除理由
- scout 之间互不干扰，完全独立发散

### Phase 3: 交叉 fertilization & 辩论

**Cross-Pollination（交叉授粉）：**
- 让所有 scout 互相阅读报告
- 标注互补点：tech 的创新 + design 的体验 + business 的价值
- 标注冲突点：技术可行性 vs 用户体验 vs 商业价值

**Debate（辩论）：**
- 对争议点，让相关 scout 辩论
- `outlier-scout` 的任务是挑战所有共识
- 目标不是"说服对方"，而是"暴露隐藏假设"

**Synthesis（综合）：**
- 找出可以合并的方案（tech + design + business 的交集）
- 找出必须二选一的分歧（trade-off 清晰化）
- 识别最有潜力的组合方向

### Phase 4: 收敛评估

```
每个方案 vs. 评估标准:
├── 技术可行性: 现有架构能支持吗？
├── 实现成本: 几天？几周？几个月？
├── 用户体验: 用户真的会喜欢吗？还是只是在纸上看起来好？
├── 维护负担: 未来改动的容易度？
├── 风险: 什么可能出错？
└── 增长潜力: 这个方案可扩展吗？
```

收敛三步:
1. **粗筛**: 用 Iron Law（收敛明确性 > 发散混乱度）快速淘汰明显弱于其他方案的选项
2. **分层评估**: 每个幸存方案过六维度 → 标记强项 / 弱项 / 阻塞
3. **Adopt/Reject**: 明确写出每个方案的 Adopt 理由或 Reject 原因（Reject 原因进入"不做清单"）

**输出 2-3 个对比方案**，不是 10+。

### Phase 4: 打磨与推荐

每个方案输出：
```
方案 <名称>
├── 核心思想 (1 句)
├── 具体做法 (3-5 步)
├── 优点
├── 缺点
├── 风险 + 缓解
└── 或不推荐 + 理由
```

**必须给出并说明理由。** 脑暴不是"列出所有选项让你选"。是"我最推荐 X，因为 Y。备选 Z，如果 X 的 C 风险太高"。

## 关键行为

### Surface Assumptions
每个方案前面列出假设。隐藏假设是最常见的规划杀手。

### Push Back
别做 yes-man。如果方案有明确问题——说出来，量化影响。诚实 > 奉承。

### 聚焦
"不做清单"和"做清单"一样重要。5 个方案中放弃 3 个 = 集中力量。

## 脑暴输出模板

模板起点：`templates/feature/00-brainstorm.md`

```markdown
# 设计: [主题]

## 背景
[为什么现在做、什么约束、谁需要这个]

## 假设
[列出要验证的关键假设]

## 决策标准
- 必须满足:
- 优先优化:
- 可以牺牲:
- 明确不能:

## 关键假设验证
| 假设 | 风险 | 验证方式 | 通过标准 |
|------|------|----------|----------|
| <假设> | 高/中/低 | <如何验证> | <什么结果算通过> |

## 方案

### 方案 A: [名称]
- 做法:
- 优点:
- 缺点:
- 风险:
- 推荐: [是/否] 因为...

### 方案 B: [名称]
...

## 推荐
**选择方案 X** 因为: [理由]
备选方案 Y 如果: [什么条件下备选变成首选]

## 不做
- [放弃的方向 + 原因]
- [放弃的方向 + 原因]

## 开放问题
[需要用户输入才能继续的]

## 下一阶段交接
- 推荐进入: `/refine` / `define-workflow-spec`
- 已锁定决策:
- 下游必须继续验证:
- 不允许下游重新打开:
```

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "方案很明显不需要脑暴" | 多花 10 分钟列出"不做清单"和隐藏假设的价值远超跳过。 | 跳过脑暴直接实现，3 天后发现方向错误，返工成本 > 脑暴 10 分钟的 50-100x。 |
| "这个太简单不需要设计" | "这是一行代码"是真的不需要设计。"这是一个按钮"需要执行位置、状态、label、a11y。 | 简单假设导致遗漏边界情况，上线后以 bug 形式爆发。 |
| "列出所有选项给你选" | 这就是放弃判断。你是技术伙伴——给出和理由。 | 10 个选项无推荐 = 用户无法决策，讨论停滞，浪费所有参与者时间。 |
| "方案 X 完美" | 没有完美方案。每个方案都有缺点——不说缺点 = 没想透。 | 隐藏的缺点在实现阶段暴露，返工时才发现根因在方案选择，修复成本 10x。 |

## 红旗 — STOP

- 方案数 > 5（发散未收敛——先收缩再推荐）
- 没写假设就开始设计
- 脱离代码库的空想（说得天花乱坠但技术上不可能）
- 不做清单为空（太照顾所有想法 = 没做取舍）
- 没有给出推荐——只是"A 好 B 好 C 好"（没有判断）
- 用户明确表达了约束但方案忽视它（不听的脑暴 = 浪费时间）

## 验证清单

- [ ] 相关代码和 CLAUDE.md 已阅读
- [ ] 假设已列出
- [ ] 决策标准已列出
- [ ] 关键假设有验证方式和通过标准
- [ ] 2-3 个清晰对比的方案
- [ ] 每个方案有优点、缺点、风险
- [ ] 明确推荐 + 理由
- [ ] "不做清单"有内容
- [ ] 下一阶段交接已写清
- [ ] 用户已批准方向后进入 spec 阶段

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 发散后方案数 > 5 | 先收缩再推荐。合并相似方案，删除明显弱于其他方案的选项。输出 2-3 个。 |
| 收敛后"不做清单"为空 | 强制要求列出至少 2 个放弃的方向 + 原因。不做清单和做清单一样重要。 |
| 用户约束被方案忽视 | 标记为 Blocking，回到 Phase 1 重新理解约束。 |
| 所有方案风险都很高 | 诚实告知 human partner，推荐"不做"或"先降低风险再决策"。不推荐高风险方案。 |
| 无法给出明确推荐 | 列出推荐的阻塞问题，请 human partner 决策。不能以"都行"结束脑暴。 |

## 好坏示例

### Good — 结构化脑暴

```markdown
# 设计: 用户通知系统

## 假设
- 用户日活 > 10k，通知量级需要考虑
- 已有 WebSocket 基础设施

## 方案

### 方案 A: 实时推送（推荐）
- 做法: WebSocket + 消息队列 + 前端 toast
- 优点: 即时性强，用户体验好
- 缺点: 连接管理复杂，服务器成本高
- 风险: WebSocket 断连时需 fallback → 缓解: 30s 轮询兜底

### 方案 B: 轮询 + 缓存
- 做法: 前端每 30s 请求未读计数 API
- 优点: 实现简单，服务器成本低
- 缺点: 延迟 30s，高并发时 API 压力大
- 风险: 用户错过时效性通知

## 推荐: 方案 A — 即时性对通知系统是核心价值
备选 B: 如果 WebSocket 基础设施不成熟

## 不做
- 邮件通知（当前阶段 scope 外）
- SMS 通知（成本过高，ROI 不匹配）
```

### Bad — 无收敛脑暴

```
# 设计: 用户通知系统

## 方案
方案 A: WebSocket
方案 B: 长轮询
方案 C: SSE
方案 D: 邮件
方案 E: 推送通知
方案 F: 短轮询
（没有假设、没有评估标准、没有推荐、不做清单为空）

-> 问题: 方案 > 5 个，发散未收敛（红旗 #1）
-> 问题: 没有假设就开始设计方案（红旗 #2）
-> 问题: 不做清单为空 = 没做取舍（红旗 #5）
-> 问题: 没有推荐 = 放弃判断（红旗 #6，常见说辞"列出所有选项给你选"）
```
