---
name: design-visual-direction
description: 视觉设计——风格、层级、色彩、组件视觉规则。当需要定义视觉风格或组件视觉规范，或提到"视觉""色彩""风格""visual"
---

# Visual Direction — 视觉方向

## 入口/出口
- **入口**: 需要定义视觉风格、层级、组件外观或对外呈现质感
- **出口**: 视觉方向、风格约束和层级规则定稿
- **指向**: 需要交互主路径 → `design-experience-interaction`；需要排版 → `design-content-layout`
- **输出路径**: `build-content-layout`（下游 build 技能）
- **前置加载**: CANON.md + `design-workflow-design`

## 何时不使用
- 纯文本或纯后端任务
- 用户明确只允许沿用固定品牌模板，且不做方向判断

## Iron Law

视觉方向必须服务理解和气质，不得替代结构和内容本身。

## 核心原则

1. **Hierarchy Before Decoration**
2. **System Before One-off**
3. **Brand Before Personal Taste**
4. **Mood Must Match Task**
5. **Visible Consistency Beats Clever Variation**

## 最佳实践输入

先读取 `references/design-best-practices.md`、`references/design-inspiration-catalog.md` 和 `references/design-pattern-extract.md`，并把视觉相关证据写入 `02-design.md` 的 `Design References / Pattern Synthesis / Adopt / Reject`。

扫描重点：
- Enterprise Product Patterns: 同类产品的视觉密度、信任感、品牌气质和组件语言
- Official Systems / Platform Rules: 品牌规范、设计系统、平台视觉规则、可访问性对比度
- Methods / Theory / Style Schools: 视觉层级、色彩角色、排版体系、风格流派
- Anti-patterns / Verification: 单色调滥用、装饰压过信息、卡片泛滥、品牌混搭冲突
- Local Project Truth: 现有 token、组件库、品牌资产、媒介限制和用户目标；项目根 `DESIGN.md`（如果存在，读取 YAML token 和视觉方向）

流行风格必须经过 Adopt / Reject；不能把“高级”“科技感”“像某品牌”直接写成结论。

## 流程

### Step 1：读取约束
- 品牌色
- 字体约束
- 组件库 / 现有视觉系统
- 媒介与尺寸
- ✅ 验证点: 是否已读取项目根 `DESIGN.md`（如存在）中的 token 定义？

### Step 2：定义视觉目标
- 想传达什么气质
- 第一眼希望看见什么
- 哪些信息必须被降权
- ✅ 验证点: 视觉目标是否用可衡量的层级规则表述，而非仅用形容词？

### Step 3：定视觉系统
- 色彩角色
- 字体层级
- 间距和对齐
- 卡片/按钮/图表/模块的视觉规则
- ✅ 验证点: 每条视觉规则是否可落到具体页面或组件，而非笼统方向？

### Step 4：记录不做清单
- 不使用的风格
- 不采用的视觉套路
- 不允许的冲突元素
- ✅ 验证点: 不做清单中的每一项是否有明确的冲突来源或证据？

## 输出契约

写入 `02-design.md`：
- 视觉方向
- 风格与系统
- 页面视觉层级
- Adopt / Reject（视觉模式）
- 不做清单

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 风格词过于抽象 | 改成可执行的层级、色彩、排版规则 |
| 视觉方向与品牌冲突 | 以品牌约束为准，记录取舍 |
| 视觉方向遮蔽信息层级 | 回退装饰，强化主次层级 |
| 视觉模式无证据 | 补充 best-practice scan，写清来源层和取舍理由 |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| “先做默认样式，后面再美化” | 默认样式会固化成事实设计。 | 默认样式固化 → 后期修改视觉方向需重构 40-60% 的 UI 代码，返工量翻倍 |
| “多加点效果更高级” | 效果不是层级，噪音会吃掉重点。 | 装饰压过信息 → 用户首屏注意力分散 30-50%，关键操作转化率下降 |
| “差不多就行” | 差不多通常意味着没有视觉系统。 | 无视觉系统 → 后续每个页面独立决策，一致性成本逐页累积，项目越大越失控 |

## 好坏示例

### ✅ Good: 证据驱动的视觉决策

```
视觉目标: 传达专业信任感，让数据成为主角

色彩角色:
- 主色: #2563EB（品牌蓝，来源: DESIGN.md → brand.primary）
- 辅色: #64748B（中性灰，数据标签用）
- 强调: #DC2626（仅用于异常指标和 CTA）
- 背景: #F8FAFC → #FFFFFF（层级区分）

字体层级:
- H1: 24px/700（数据标题）
- H2: 18px/600（卡片标题）
- Body: 14px/400（数据值和描述）
- Caption: 12px/400（辅助信息，降权）

Adopt: 单色主色 + 灰层级（参考 Stripe Dashboard，Pattern Synthesis 来源 #2）
Reject: 多色渐变 Hero（与"数据是主角"目标冲突，来源: Anti-patterns）
```

### ❌ Bad: 抽象模板无具体决策

```
视觉目标: 高级、科技感

色彩: 用蓝色系（未定义角色和层级）
字体: 现代无衬线（未定义尺寸层级和对比）
不做清单: (未写)
→ 没有来源证据，没有 Adopt / Reject，无法落地到组件
```

## 输出模板

视觉方向产出应写入 `02-design.md` 的以下结构：

```markdown
## Visual Direction — [功能名称]

### 视觉目标
- 传达气质: [具体描述，非形容词堆砌]
- 首屏焦点: [哪个信息/组件是主角]
- 降权项: [哪些信息必须视觉降权]

### 视觉系统
| 角色 | 具体值 | 来源 |
|------|--------|------|
| 主色 | [色值] | DESIGN.md / 品牌规范 |
| 辅色 | [色值] | ... |
| 强调色 | [色值] | ... |
| 背景 | [色值] | ... |

| 层级 | 字号 | 字重 | 用途 |
|------|------|------|------|
| H1 | [px] | [weight] | [用途] |
| H2 | [px] | [weight] | [用途] |
| Body | [px] | [weight] | [用途] |

间距尺度: [4/8/12/16/24/32px 等]
组件视觉规则: [卡片、按钮、图表等的具体规则]

### Adopt / Reject（视觉模式）
| 模式 | 来源 | 决定 | 理由 |
|------|------|------|------|
| [模式 A] | [来源层] | Adopt | [具体理由] |
| [模式 B] | [来源层] | Reject | [冲突点] |

### 不做清单
- [不做项 1]: [冲突来源或证据]
- [不做项 2]: [冲突来源或证据]
```

## 红旗 — STOP

- 没有品牌或场景约束就开始选风格
- 缺少视觉 best-practice scan 或 Adopt / Reject
- 把视觉方向写成审美形容词堆砌
- 同时追求多个相互冲突的气质
- 视觉规则无法落到页面或组件

## 验证清单

- [ ] 视觉约束明确
- [ ] 视觉目标明确
- [ ] 视觉系统可执行
- [ ] 不做清单明确
- [ ] 视觉决策已回溯到来源证据或 Local Project Truth
- [ ] 已写入 `02-design.md`
