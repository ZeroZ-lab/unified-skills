---
name: design-workflow-design
description: 证据驱动的创作设计阶段总控——在 plan/build 之前用最佳实践证据定稿交互、视觉、排版、剧本、导演设计
---

# Design — 创作设计总控

## 入口/出口
- **入口**: `01-spec.md` 已批准，且任务会产生用户可感知产物
- **出口**: `docs/features/YYYYMMDD-<name>/02-design.md` + 用户批准；项目根 `DESIGN.md` 同步更新；纯后端/脚本/迁移允许 skip
- **指向**: 设计批准后进入 `build-workflow-plan`；设计探索不足时回到 `define-workflow-refine`
- **假设已加载**: CANON.md
- **需读取**: `references/design-best-practices.md`、`references/design-inspiration-catalog.md`、`references/design-pattern-extract.md`、项目根 `DESIGN.md`（如果存在）

## 何时不使用
- 纯后端接口、数据库迁移、脚本、CI 配置等不产生用户可感知产物
- 单行修复且不影响任何 UI/文档/视觉/叙事呈现

## Iron Law

<HARD-GATE>
没有已批准的创作设计，不得进入 `/plan` 或 `/build` 去拆实现任务或产出用户可见结果。
设计阶段只定创作与呈现决策，不写实现步骤，不写 task breakdown。
设计 required 时，`02-design.md` 必须包含 Sources / Patterns / Adopt / Reject；缺少证据不得批准。
</HARD-GATE>

## 设计适用性判断

### 一定需要 design
- `document` / `article` / `deck` / `visual`
- `software` 且涉及页面、组件、交互、视觉呈现、信息架构、用户路径

### 可以 skip design
- `software` 且纯后端
- 纯脚本、纯迁移、纯 CI / 配置

skip 时必须明确记录：
```markdown
## Design Requirement
- Design Status: skipped
- Skip Reason: pure backend / migration / script / CI only
```

## 核心边界

- `define`：定义问题、目标、范围、成功标准
- `design`：定稿交互、视觉、排版、剧本、导演方案
- `plan`：拆任务、排依赖、定并行策略
- `build`：实现或生成产物

设计阶段不做：
- 不写实现代码
- 不写 Task N
- 不决定数据库/API/服务架构
- 不把像素级微调当成阶段主目标

## 最佳实践来源模型

设计阶段抽象迁移 `cc-design` 的来源分层思想，但不内置其完整 reference 库。每次 required design 都按 4+1 层记录证据：

1. **Enterprise Product Patterns** — 成熟产品、SaaS、consumer app、dashboard、form、workflow、deck、visual 的公开模式。具体参考 `references/design-inspiration-catalog.md`（按领域索引 73 个真实网站设计系统）和 `references/design-pattern-extract.md`（高频设计模式提炼）
2. **Official Systems / Platform Rules** — 官方设计系统、平台规则、品牌规范、媒介和可访问性约束
3. **Methods / Theory / Style Schools** — 交互、信息设计、排版、视觉、叙事、导演和风格流派方法
4. **Anti-patterns / Verification** — 反模式、失败模式、验证清单。`references/design-pattern-extract.md` 的通用 Don'ts 作为验证基线
5. **Local Project Truth** — 当前 repo、现有 UI、品牌、组件库、内容边界、用户目标和媒介约束；项目根 `DESIGN.md` 是此层的结构化载体（Google Stitch token 格式）；优先级最高

外部模式只能作为证据进入 `Adopt`，不能直接变成设计决策。Local Project Truth 与外部模式冲突时，以 Local Project Truth 为准，并把外部模式写入 `Reject` 或约束说明。

## 流程

### Step 1：读取 spec 并判断是否需要设计

读取：
- `artifact_type`
- 目标用户 / 读者 / 观众
- 使用场景
- 成功标准
- Scope 边界

然后判断：
- 是否有用户可感知产物
- 是否需要在实现前锁定创作和呈现方向

### Step 2：选择设计轨道

| 场景 | 需要加载 |
|------|---------|
| `software` + UI | `design-experience-interaction` + `design-visual-direction` |
| `document` / `article` | `design-content-script` + `design-content-layout` |
| `deck` | `design-content-script` + `design-content-direction` + `design-content-layout` |
| `visual` | `design-visual-direction` + `design-content-layout` |

### Step 3：Design Best-Practice Scan

围绕当前轨道执行创作与呈现层扫描：
- **Interaction**: 产品流程、状态覆盖、信息架构、心智模型
- **Visual direction**: 品牌规则、视觉系统、层级、色彩、组件视觉语言
- **Layout**: 栅格、构图、阅读路径、密度、媒介/导出约束
- **Script**: 受众任务、叙事结构、消息线、段落/页级节奏
- **Direction**: 页序推进、揭示顺序、演讲节奏、情绪推进

**灵感来源优先级：**
1. 读取 `references/design-inspiration-catalog.md`，按当前 artifact_type 和目标领域匹配 2-3 个参考公司
2. 读取 `references/design-pattern-extract.md`，提取与当前设计轨道匹配的高频模式
3. 读取项目根 `DESIGN.md`（如存在），获取已有项目级设计 token
4. Web search 兜底：搜索 `best <domain> website design`、`<company> design system`、`<feature> UI pattern` 补充证据；扩展种子来源为 [awesome-design-systems](https://github.com/alexpate/awesome-design-systems)（200+ 设计系统索引），当目录覆盖不足时从中选取同领域公司逐一搜索

固定输出：
```markdown
## Design References
## Pattern Synthesis
## Design Inferences
## Adopt / Reject
## Design Evidence Quality
```

如果 web/browser/doc 检索不可用，记录 `Search unavailable`，继续使用 Local Project Truth 和本地 references。关键设计决策仍缺证据时 STOP，不得批准。

### Step 3.5：Codex 视觉生成 + Token 提取（可选增强）

触发摘要：`codex:codex-rescue` agent 可用，且 `artifact_type` 为 `software`（有 UI）、`visual` 或 `deck`。产物包括 mockup PNG 和 `assets/design-tokens-extracted.json`。

默认不读取详细流程。需要实际执行视觉生成、图片分析或 token 提取时，读取 `visual-generation.md`。

### Step 4：产出 `02-design.md`

必须包含：
- 设计来源证据
- 模式综合
- 设计推导
- Adopt / Reject
- 证据质量
- 设计目标
- 关键决策
- 设计边界
- 设计批准标准
- 实施前置条件
- 按类型的设计内容

**条件：多方案产出（visual comparison applicable 时）**

当 `artifact_type` 为 `software`(有 UI)、`visual` 或 `deck` 时，产出 2-3 个设计方向而非单一草案：

- 每个方向在 `## Design Alternatives` 区段中独立记录
- 各方向在最有影响力的维度上差异化：
  - `software + UI`: 不同布局结构 + 交互模式组合
  - `visual`: 不同构图 / 色彩方向 / 风格
  - `deck`: 不同叙事结构 / 页面节奏
- 每个方向仍需独立的设计目标、关键决策和 Adopt 证据链
- 产出后进入 Step 4.5 进行交互式视觉对比

不适用多方案的场景（`document` / `article` / 纯后端）：产出单一草案，跳过 Step 4.5。

### Step 4.5：交互式视觉对比（conditional）

**仅当** Step 4 产出了 2-3 个 alternatives 时执行。

调用 `design-interactive-preview` 技能：
1. 启动本地 HTTP 服务 (`scripts/design-preview.mjs`)
2. 生成对比 HTML 并在浏览器中展示
3. 多轮对比：先整体方向，再按维度细化
4. 捕获用户选择
5. 精炼 `02-design.md`：选定方向成为主设计，未选方案移入 Alternatives Considered
6. 关闭服务

选择完成后，`02-design.md` 从多方案精炼为单一方向，继续进入 Step 5。

### Step 5：用户批准

向 human partner 展示设计稿，逐项确认：
- 方向是否对
- 证据是否足够
- Adopt / Reject 是否符合项目目标
- 是否仍缺关键状态/节奏/构图
- 是否有不做项需要调整

**注**: 如果经过 Step 4.5 视觉对比，用户已确认方向选择，此处批准可聚焦证据质量、完整性和不做清单，无需重复讨论方向。

没有批准不得进入 `/plan`。

### Step 6：同步项目级设计约束到 DESIGN.md

读取已批准的 `02-design.md`，仅提取跨 feature 适用的项目级设计 token 和约束写入项目根 `DESIGN.md`；feature-specific 流程和功能范围不写入。

默认不读取详细合并规则。需要创建、合并或处理 `DESIGN.md` 冲突时，读取 `design-sync.md`。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 设计目标和 spec 冲突 | 回到 `define-workflow-refine` 修正目标或边界 |
| 无法判断是否需要 design | 以保守方式处理：需要 design |
| 缺少 best-practice scan | 补扫并写入 Design References / Adopt / Reject |
| 关键设计决策缺证据 | STOP，补证据或降级设计决策 |
| 设计稿开始写实现步骤 | 删除实现步骤，回到创作决策层 |
| 用户认为方向不对 | 保留已有判断，修改 `02-design.md` 后重新审查 |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| “先把代码写出来再调设计” | 这会把创作决策伪装成实现细节，返工更贵。 |
| “排版/剧本/交互都可以在 build 里顺手做” | 顺手做意味着没有阶段门，也没有定稿依据。 |
| “这只是小 UI，不需要设计” | 只要用户看得见、用得到，就可能需要先定主路径和状态。 |
| “设计就是把实现写详细一点” | 错。设计定方向，plan 才拆任务，build 才落实现。 |
| “参考几个案例就够了” | 案例必须转成 Pattern / Adopt / Reject，否则只是灵感堆砌。 |

## 红旗 — STOP

- 在没有批准 design 时开始拆 Task N
- design required 但缺少 Sources / Patterns / Adopt / Reject
- 来源没有分层，或关键决策无法回溯到证据
- 把流行风格、品牌模仿或个人审美直接写成设计结论
- 在 `02-design.md` 里写测试步骤、实现步骤或提交命令
- 把 API / schema / 服务架构决策塞进设计阶段
- 只讨论“好不好看”，不讨论用户路径、节奏、层级
- software 的 UI 任务没有任何设计稿就直接进 `/plan`

## 验证清单

- [ ] 已判断 design required / skipped
- [ ] required 时已生成 `02-design.md`
- [ ] required 时已完成 Design Best-Practice Scan
- [ ] `02-design.md` 包含 Design References / Pattern Synthesis / Design Inferences / Adopt-Reject / Evidence Quality
- [ ] 关键决策能回溯到来源证据或 Local Project Truth
- [ ] 没有实现步骤或任务分解
- [ ] 用户已批准 design，或 skip 理由已明确记录
- [ ] required 时：DESIGN.md 已同步（创建或更新）
