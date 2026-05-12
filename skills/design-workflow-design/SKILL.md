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

**触发条件**：`codex:codex-rescue` agent 可用 且 `artifact_type` 为 `software`(有 UI)、`visual` 或 `deck`

**流程：**

1. 将 Step 1 的 spec 约束 + Step 3 扫描结果（Adopt 模式 + 参考公司视觉特征）组装为 Codex prompt
2. 调用 `codex:codex-rescue` agent，prompt 包含：
   - 设计目标描述（产品类型、目标用户、核心交互）
   - 视觉方向关键词（从 Step 3 Adopt 条目提取：色彩策略、字体风格、布局模式、组件样式）
   - 输出要求：生成 2-3 张设计方向 mockup 图（PNG），每张代表一个差异化视觉方向
3. Codex 产出图片 → 保存到 `docs/features/YYYYMMDD-<name>/assets/` 目录：
   - `mockup-direction-1.png`、`mockup-direction-2.png`、`mockup-direction-3.png`
4. 用 `analyze_image`（或同等视觉分析能力）逐张分析 mockup 图，提取结构化 token：
   ```json
   {
     "direction": "1",
     "tokens": {
       "colors": { "primary": "#...", "canvas": "#...", "ink": "#...", "accent": "#..." },
       "typography": { "family": "...", "display_weight": ..., "display_tracking": "...px", "body_weight": ... },
       "spacing": { "base_unit": "...px", "section_gap": "...px", "card_padding": "...px" },
       "rounded": { "cta_radius": "...px", "card_radius": "...px" },
       "components": { "cta_style": "pill|rect|rounded", "card_style": "flat|elevated|bordered", "nav_style": "sidebar|topbar|mixed" }
     },
     "visual_keywords": ["dark-theme", "single-accent", "negative-tracking", ...],
     "mood_description": "..."
   }
   ```
5. 提取的 token 保存到 `docs/features/YYYYMMDD-<name>/assets/design-tokens-extracted.json`
6. Token 数据作为 **Pattern Synthesis 的视觉证据** 进入 Step 4 的 Adopt / Reject

**两个产物：**
- 设计参考图（PNG mockup）→ 可用于 Step 4.5 交互式视觉对比的辅助素材
- design-tokens-extracted.json → 结构化 token，供 Step 4 和 Step 6 消费

**降级规则：**
- Codex agent 不可用（额度耗尽 / 网络不通 / 未配置）→ 记录 `Codex Visual Generation unavailable`，跳过此步
- Codex 可用但图片生成失败 → 跳过此步，继续使用 Step 3 的文字证据
- 降级不影响后续步骤，Step 4 仍基于 Step 3 的 Best-Practice Scan 产出

**适用 artifact_type：**

| 类型 | 是否触发 | 理由 |
|------|----------|------|
| `software` + UI | 是 | 需要视觉 mockup 验证布局和交互方向 |
| `visual` | 是 | 核心产出就是视觉 |
| `deck` | 是 | 需要页面视觉节奏参考 |
| `document` / `article` | 否 | 无视觉 mockup 需求 |
| `software` 纯后端 | 否 | design 已 skipped |

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

读取已批准的 `02-design.md`，提取项目级设计 token 和约束写入项目根 `DESIGN.md`。

**提取规则：**
- 扫描 Adopt 条目中描述跨 feature 适用模式的条目
- 扫描 Local Project Truth 中描述项目范围约束的内容（品牌色、组件库、字体系统等）
- 将视觉决策转化为 YAML token（colors / typography / rounded / spacing / components）
- 将交互/布局/响应式决策转化为对应 Markdown 章节
- 不提取 feature-specific 的交互流程、页面结构或功能范围决策

**Token 提取示例：**
如果 02-design.md 的 Adopt 记录了"项目使用 Indigo 作为主色调"：
  → 写入 YAML: `colors.primary: "#4F46E5"`
  → 写入 Markdown Color Palette 章节: `primary (#4F46E5) — 主操作色，用于 CTA、链接、选中态`

**合并规则：**
- DESIGN.md 不存在：使用 `templates/root/DESIGN.md` 创建
- YAML token：已存在的不覆盖（手动优先），新增的追加
- Markdown 章节：新约束追加到对应章节末尾，标注 `<!-- auto-sync: /design <feature-name> -->`
- 已有手动内容（无 auto-sync 标注）不覆盖；冲突时保留手动内容并添加 `<!-- conflict-note: ... -->`
- 更新 `## Sync Log`

**跳过条件：**
- design required = skipped 时不执行同步
- 02-design.md 中无项目级约束时不写入

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
