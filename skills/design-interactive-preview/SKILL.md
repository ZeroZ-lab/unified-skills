---
name: design-interactive-preview
description: 交互式视觉对比——生成自包含 HTML 页面并通过本地 HTTP 服务在浏览器中并排展示多个设计方向，让用户直观选择
---

# Design Interactive Preview — 交互式视觉对比

## 入口/出口

- **入口**: `02-design.md` 包含 2+ 个 Design Alternatives，且 `artifact_type` 为 `software`(有 UI)、`visual` 或 `deck`
- **出口**: 用户已做出选择，`02-design.md` 已精炼为选定方向，`design-selection.json` 已写入
- **指向**: 选择完成后回到 `design-workflow-design` Step 5 进行最终批准
- **前置加载**: CANON.md + `scripts/design-preview.mjs` + `references/design-best-practices.md` + `references/design-inspiration-catalog.md` + 项目根 `DESIGN.md`（如果存在）
- **输出路径**: 选择完成后回到 `design-workflow-design` Step 5 → 最终批准后进入 `build-content-writing` 或 `build-content-layout`

## 何时不使用

- `artifact_type` 为 `document` / `article`（文本产物，视觉对比价值低）
- `software` 纯后端、纯脚本、纯迁移、纯 CI
- `02-design.md` 只有一个设计方向（没有 alternatives）
- Node.js 不可用且 MCP 浏览器工具也不可用（降级到 CLI 文本对比）

## Iron Law

<HARD-GATE>
视觉对比是决策辅助工具，不替代证据驱动的设计流程。
用户在浏览器中的选择必须回写到工作流——选定方向成为主设计，未选方案必须移入 Alternatives Considered 并记录选择理由。
不因为用户"看起来喜欢"就跳过证据质量检查。
</HARD-GATE>

## 适用 artifact_type 与对比维度

| artifact_type | Round 1 维度 | Round 2+ 维度 |
|---------------|-------------|--------------|
| `software` + UI | 整体布局 + 交互模式 | 布局细化 / 配色 / 字体 / 组件风格 / 状态流转 |
| `visual` | 构图 + 色彩方向 | 色板 / 层级 / 留白 / 视觉元素 |
| `deck` | 叙事结构 + 页面节奏 | 单页排版 / 视觉风格 / 图表方式 |

## 流程

### Step 1：读取 alternatives 并规划对比轮次

读取 `02-design.md` 中的 `## Design Alternatives` 区段：
1. 确认有 2-3 个 alternative
2. 根据 `artifact_type` 确定对比维度和轮次
3. 判断哪些维度值得多轮对比，哪些可以在第一轮中一起定

### Step 2：生成本轮对比 HTML

生成 `design-comparison.html` 到 feature 目录。页面要求：

**结构：**
```
┌─────────────────────────────────────────┐
│  Round Indicator: Step 1 of N           │
│  Dimension: [当前对比维度标签]            │
├───────────┬───────────┬─────────────────┤
│ Alt A     │ Alt B     │ Alt C (可选)     │
│ ┌───────┐ │ ┌───────┐ │ ┌─────────────┐ │
│ │视觉示意│ │ │视觉示意│ │ │视觉示意     │ │
│ └───────┘ │ └───────┘ │ └─────────────┘ │
│ 名称      │ 名称      │ 名称            │
│ 核心差异   │ 核心差异   │ 核心差异        │
│ 设计要点   │ 设计要点   │ 设计要点        │
│ 优势      │ 优势      │ 优势            │
│ 劣势      │ 劣势      │ 劣势            │
│ [Select]  │ [Select]  │ [Select]        │
├───────────┴───────────┴─────────────────┤
│ Already decided: [Round 1 → Alt X]      │
└─────────────────────────────────────────┘
```

**技术要求：**
- 所有 CSS/JS 内联，零外部依赖
- CSS Grid 或 Flexbox 并排布局
- 系统字体栈（`-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`）
- 响应式：桌面 2-3 列，移动端堆叠
- 暗色/亮色均可用（尊重 `prefers-color-scheme`）

**交互逻辑（内联 JS）：**
- 点击 "Select" 按钮 → `POST /api/selection` 发送 `{ round, dimension, selected, alternatives }`
- 成功后：选中卡片高亮（边框变蓝），其他卡片淡出（opacity: 0.5）
- 页面顶部显示 "✓ You selected: [Name]"
- 已选摘要栏更新

**视觉示意（CSS/SVG）：**
- `software + UI`: 用 CSS Grid/Flexbox 模拟线框图（header/nav/main/sidebar/footer 区域用色块表示）
- `visual`: 用内联 SVG 或 CSS 渐变表示构图和色彩方向
- `deck`: 用缩略卡片序列表示页面节奏

### Step 3：启动本地 HTTP 服务

```
node scripts/design-preview.mjs <feature-dir> &
```

- 捕获 `DESIGN_PREVIEW_PORT=<port>` 输出获取端口号
- 如果启动失败，走降级路径

### Step 4：打开浏览器

优先级：
1. `open http://localhost:<port>` （macOS）
2. MCP 浏览器工具 `navigate_page`
3. 手动告知用户 URL

### Step 5：等待用户选择

两种模式（可并用）：

**A. 文件轮询模式：**
- 每 5 秒读取 `design-selection.json`
- 文件存在且包含 `selected` 字段 → 选择完成

**B. CLI 确认模式：**
- 告知用户 "对比页面已在浏览器中打开，请选择后回来确认"
- 用户在 CLI 中回复选择结果

### Step 6：处理选择结果

1. 读取 `design-selection.json`（如果存在）
2. 如有下一轮对比 → 更新 HTML → `POST /api/next-round` → 回到 Step 2
3. 如无下一轮或用户说 "就这个了" → 进入 Step 7

### Step 7：精炼 `02-design.md`

1. 将选定 alternative 的设计决策提升为主设计内容
2. 未选方案移入 `### Alternatives Considered`，附选择理由
3. 在 `### Selection Record` 中记录每轮选择
4. 确保证据链完整——选定方案的所有设计决策仍可追溯到 Adopt 列表

### Step 8：关闭服务

```
kill <server-pid>
```

或 `pkill -f design-preview.mjs`

## 降级路径

| 环境 | 降级方案 |
|------|---------|
| Node.js 不可用 | 用 MCP 浏览器工具直接打开 `file://` URL，`evaluate_script` 读取 `window.__selection` |
| MCP 浏览器不可用（Codex CLI） | CLI 文本对比：`AskUserQuestion` + `preview` 字段渲染 ASCII 对比 |
| 两者都不可用 | 纯文本 `AskUserQuestion` 逐项对比 |

降级时在 `02-design.md` 的 Selection Record 中注明：
```markdown
- Preview mode: degraded (CLI text comparison)
- Reason: Node.js unavailable / browser unavailable
```

## Adopt / Reject

视觉对比页面的生成遵循 `references/design-best-practices.md` 的 4+1 层来源模型：

- **Adopt**: CSS Grid 并排布局 — Source Layer: Enterprise Product Patterns; Reason: 并排对比是成熟产品设计工具的标准交互模式（Figma、InVision 等）
- **Adopt**: 系统字体栈 — Source Layer: Official Systems / Platform Rules; Reason: 不依赖外部字体，保持零外部依赖约束
- **Adopt**: 多轮逐层收窄 — Source Layer: Methods / Theory / Style Schools; Reason: 增量决策（progressive commitment）减少认知负担
- **Reject**: 外部 CSS 框架（Tailwind/Bootstrap）— Source Layer: Enterprise Product Patterns; Reason: 项目零依赖约束，对比页面不应引入 npm 依赖
- **Reject**: 单页全部维度同时对比 — Source Layer: Anti-patterns; Reason: 2-3 个方向 × 3-4 个维度 = 6-12 个卡片，超出用户认知带宽

## Local Project Truth

- 项目是零依赖 Markdown/JSON/Shell 框架——对比页面的 HTML/CSS/JS 必须全部内联，不引入 npm 包
- `scripts/design-preview.mjs` 是项目中唯一的 JS 文件，使用 Node.js 内置模块——对比页面应保持同等简洁度
- 设计阶段的 Iron Law 规定没有批准的设计不能进入 `/plan`——视觉对比的选择必须回写 `02-design.md`，不能替代批准流程
- `artifact_type` 决定对比维度——`document`/`article` 不适用视觉对比，这已在"何时不使用"中明确

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "浏览器里选了就算批准了" | 错。视觉对比只是方向选择，Phase 5 还要确认证据质量和完整性。 | 跳过证据检查 → 选了一个视觉好看但缺乏证据支撑的方向 → 实施时返工 |
| "不用多轮，一轮就够了" | 可以。用户可在任意轮次说 "就这个了" 跳过后续对比。 | 无后果（这是正确的灵活选择） |
| "HTML 太简陋了不好看" | 对比页面的目的是让用户区分方向差异，不是产出最终 UI。线框级足够。 | 过度打磨对比页面 → 延迟决策 2-3 小时；对比页面不是最终产物 |
| "直接在终端里看就行了" | 对文本产物可以。对 UI/visual/deck，视觉对比比文字描述效率高一个数量级。 | 文字描述方向差异 → 用户误解 → 选错方向 → 实施后重新设计耗时 ×5 |

## 红旗 — STOP

- 用户在浏览器中选了方案但 `design-selection.json` 未写入
- 选定方案的设计决策无法追溯到 Adopt 列表的任何证据
- HTML 生成失败或浏览器无法打开，且降级路径也不可用
- 服务启动后端口无法获取
- 多轮对比陷入循环（超过 5 轮）

## 验证失败处理

| 验证项 | 失败表现 | 处理方式 |
|--------|----------|---------|
| HTTP 服务启动失败 | 端口无法获取或服务无法启动 | 走降级路径：MCP 浏览器打开 file:// URL 或 CLI 文本对比 |
| HTML 生成失败 | design-comparison.html 未生成或渲染错误 | 降级到 CLI 文本对比；在 Selection Record 中注明降级原因 |
| design-selection.json 未写入 | 用户选择后文件未更新 | 检查 POST 路由是否正常；降级到 CLI 确认模式 |
| 证据链断裂 | 选定方案的设计决策无法追溯到 Adopt 列表 | 回到 design-workflow-design 补充证据；不批准无证据的方向 |
| 多轮对比超过 5 轮 | 对比陷入循环 | 强制停止；当前最优方向作为选定方案，记录停止原因 |

## 好坏示例

### Good: 多轮收窄 + 证据回写 + 降级记录
```
Round 1: 整体布局对比 → 用户选 Alt B (侧栏布局)
Round 2: 侧栏布局配色对比 → 用户选 "就这个了" (深色主题)
02-design.md 更新: Alt B 提升为主设计，Alt A 移入 Alternatives Considered
Selection Record: 每轮选择 + 降级模式（如有）
```

### Bad: 选择无回写 + 无证据追踪
```
用户在浏览器选了 Alt B → design-selection.json 未写入
02-design.md 未更新 → 选定方案无证据链
直接进入 build → 没有经过 design-workflow-design 批准
```

## 输出模板

```
交互式视觉对比完成：

对比轮次: [N] 轮
选择结果:
  Round 1: [维度] → 选中 [Alt X]
  Round 2: [维度] → 选中 [Alt Y] / 用户说"就这个了"

02-design.md 更新:
  - 选定方向已提升为主设计: [是/否]
  - 未选方案已移入 Alternatives Considered: [是/否]
  - Selection Record 已写入: [是/否]
  - 证据链完整（每决策 → Adopt 来源）: [是/否]

降级信息:
  - Preview mode: [full / degraded]
  - 降级原因: [无 / Node.js unavailable / browser unavailable]

服务状态: 已关闭
```

## 验证清单

- [ ] HTTP 服务已启动并返回端口号
- [ ] `design-comparison.html` 已生成
- [ ] 页面在浏览器中正确渲染（2-3 列并排）
- [ ] Select 按钮可点击且触发 POST 请求
- [ ] `design-selection.json` 在选择后写入
- [ ] Agent 成功读取选择结果
- [ ] `02-design.md` 已精炼为选定方向
- [ ] 未选方案已移入 Alternatives Considered
- [ ] 服务已关闭
