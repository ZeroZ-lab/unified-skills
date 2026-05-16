------
name: design-workflow-design
description: 证据驱动的创作设计总控。当需要定稿交互、视觉、排版设计，或提到"设计""最佳实践""证据""design"
argument-hint: "[artifact-type: software|document|article|deck|visual]"
---

# Design — 创作设计总控

## 入口/出口
- **入口**: `01-spec.md` 已批准，且任务会产生用户可感知产物
- **出口**: `docs/features/YYYYMMDD-<name>/02-design.md` + 用户批准；项目根 `DESIGN.md` 同步更新；纯后端/脚本/迁移允许 skip
- **指向**: 设计批准后进入 `build-workflow-plan`；设计探索不足时回到 `define-workflow-refine`
- **输出路径**: → build-workflow-plan
- **前置加载**: CANON.md
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

**一定需要 design：** `document` / `article` / `deck` / `visual`；`software` 且涉及页面/组件/交互/视觉/信息架构/用户路径。

**可以 skip：** `software` 纯后端、纯脚本/迁移/CI。Skip 时记录：`Design Status: skipped, Skip Reason: [理由]`。

## 核心边界

`define`：定义问题/目标/范围。`design`：定稿交互/视觉/排版/剧本/导演。`plan`：拆任务/排依赖。`build`：实现产物。设计阶段不写实现代码、不写 Task N、不决定 DB/API/服务架构。

## Agent Dispatch Contract

`/design` 由阶段技能按 `artifact_type` 选择 persona；persona 不能绕过本技能直接进入 plan/build。

- `agents/requirements-analyst.md`：Step 1 的 design required / skipped 判断
- `agents/content-writer.md`：`document` / `article` / `deck` 的剧本、叙事、内容结构设计
- `agents/visual-designer.md`：`software + UI`、`deck`、`visual` 的交互、视觉方向、排版
- `agents/design-reviewer.md`：审查 `02-design.md` 的证据质量、边界和实施前置条件
- `codex:codex-rescue`：可选视觉生成增强，不替代上述 persona 和证据门

## 最佳实践来源模型（4+1 层）

1. **Enterprise Product Patterns** — 成熟产品公开模式。参考 `references/design-inspiration-catalog.md`（按领域索引 73 个真实网站）和 `references/design-pattern-extract.md`（高频设计模式提炼）
2. **Official Systems / Platform Rules** — 官方设计系统、平台规则、品牌规范
3. **Methods / Theory / Style Schools** — 交互、信息设计、排版、视觉、叙事方法
4. **Anti-patterns / Verification** — 反模式、失败模式。`references/design-pattern-extract.md` 的通用 Don'ts 作为验证基线
5. **Local Project Truth** — 当前 repo、品牌、组件库、用户目标。项目根 `DESIGN.md` 是此层载体（Google Stitch token 格式）；优先级最高

外部模式只能作为证据进入 `Adopt`，不能直接变成设计决策。Local 与外部冲突时以 Local 为准，外部写入 `Reject`。

## 流程

### Step 1：读取 spec 并判断是否需要设计

读取 `artifact_type`、目标用户、使用场景、成功标准、Scope 边界。判断是否有用户可感知产物且需要在实现前锁定方向。

### Step 2：选择设计轨道

| 场景 | 需要加载 |
|------|---------|
| `software` + UI | `design-experience-interaction` + `design-visual-direction` |
| `document` / `article` | `design-content-script` + `design-content-layout` |
| `deck` | `design-content-script` + `design-content-direction` + `design-content-layout` |
| `visual` | `design-visual-direction` + `design-content-layout` |

### Step 3：Design Best-Practice Scan

围绕当前轨道执行创作与呈现层扫描：Interaction（流程/状态/信息架构）、Visual direction（品牌/视觉系统/层级）、Layout（栅格/构图/阅读路径）、Script（叙事结构/消息线）、Direction（页序/揭示/节奏）。

**灵感来源优先级：** `design-inspiration-catalog.md` → `design-pattern-extract.md` → 项目根 `DESIGN.md` → Web search 兜底。

固定输出：Design References / Pattern Synthesis / Design Inferences / Adopt / Reject / Design Evidence Quality。检索不可用时记录 `Search unavailable`，关键决策仍缺证据时 STOP。

### Step 3.5：Codex 视觉生成 + Token 提取（可选增强）

`codex:codex-rescue` agent 可用，且 `artifact_type` 为 `software`（有 UI）、`visual` 或 `deck` 时触发。产物包括 mockup PNG 和 `assets/design-tokens-extracted.json`。需要执行时读取 `visual-generation.md`。

### Step 4：产出 `02-design.md`

必须包含：设计来源证据、模式综合、设计推导、Adopt / Reject、证据质量、设计目标、关键决策、设计边界、设计批准标准、实施前置条件、按类型的设计内容。

**多方案（visual comparison applicable）：** `software`(有 UI)、`visual`、`deck` 时产出 2-3 个设计方向，各方向在最有影响力的维度差异化，独立记录后进入 Step 4.5 交互式对比。不适用时产出单一草案，跳过 Step 4.5。

### Step 4.5：交互式视觉对比（conditional）

仅当 Step 4 产出 alternatives 时执行。调用 `design-interactive-preview`：启动本地 HTTP 服务 → 生成对比 HTML → 多轮对比 → 捕获选择 → 精炼 `02-design.md` → 关闭服务。

### Step 5：用户批准

向 human partner 展示设计稿，确认方向、证据、Adopt / Reject、缺失项、不做清单。没有批准不得进入 `/plan`。

### Step 6：同步项目级设计约束到 DESIGN.md

读取已批准的 `02-design.md`，提取跨 feature 的项目级设计 token 写入 `DESIGN.md`。详细合并规则见 `design-sync.md`。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 设计目标和 spec 冲突 | 回到 `define-workflow-refine` 修正目标或边界 |
| 无法判断是否需要 design | 保守处理：需要 design |
| 缺少 best-practice scan | 补扫并写入 Design References / Adopt / Reject |
| 关键决策缺证据 | STOP，补证据或降级设计决策 |
| 设计稿写实现步骤 | 删除实现步骤，回到创作决策层 |
| 用户认为方向不对 | 保留已有判断，修改后重新审查 |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "先把代码写出来再调设计" | 创作决策伪装成实现细节，返工更贵。 | 交互路径被实现锁定 → 改方向重写 UI >50% |
| "排版/剧本/交互都可以 build 里顺手做" | 顺手做 = 没有阶段门，没有定稿依据。 | 每位开发者自由发挥 → 视觉/交互不一致 |
| "只是小 UI，不需要设计" | 用户看得见/用得到，就可能需要先定主路径和状态。 | 跳过设计 → 遗漏空态/错误态/加载态 → 上线后用户看到空白 |
| "设计就是把实现写详细一点" | 设计定方向，plan 拆任务，build 才落实现。 | 混淆创作决策和技术执行 → 审查失效 |
| "参考几个案例就够了" | 案例必须转成 Pattern / Adopt / Reject。 | 灵感堆砌 → 无证据链 → 关键决策无法回溯 |

## 红旗 — STOP

- 在没有批准 design 时开始拆 Task N
- design required 但缺少 Sources / Patterns / Adopt / Reject
- 来源没有分层，或关键决策无法回溯到证据
- 把流行风格或个人审美直接写成设计结论
- 在 `02-design.md` 里写测试/实现步骤或提交命令
- 把 API / schema / 服务架构决策塞进设计阶段
- 只讨论"好不好看"，不讨论用户路径、节奏、层级
- software UI 任务没有设计稿就进 `/plan`

## 验证清单

- [ ] 已判断 design required / skipped
- [ ] required 时已生成 `02-design.md`
- [ ] required 时已完成 Design Best-Practice Scan
- [ ] `02-design.md` 包含 Design References / Pattern Synthesis / Design Inferences / Adopt-Reject / Evidence Quality
- [ ] 关键决策能回溯到来源证据或 Local Project Truth
- [ ] 没有实现步骤或任务分解
- [ ] 用户已批准 design，或 skip 理由已明确记录
- [ ] required 时：DESIGN.md 已同步

## 输出模板

```markdown
### Design 交付记录 — <feature-name>

**Design Status**: [required / skipped — 跳过原因]
**artifact_type**: [software / document / article / deck / visual]
**设计轨道**: [交互 / 视觉方向 / 排版 / 剧本 / 导演]

**Design Best-Practice Scan**:
- Design References: [来源列表]
- Pattern Synthesis: [综合模式]
- Adopt / Reject: [采纳/拒绝清单 + 理由]
- Evidence Quality: [评分 / 来源数]

**关键决策**: [决策1 / 决策2 / ...]
**设计边界**: [不做清单 + trade-off]
**实施前置条件**: [前提条件列表]
**用户批准**: [已批准 / 待批准]
**DESIGN.md 同步**: [已同步 / 未同步]
```
