---
name: design-visual-direction
description: 视觉设计——风格、层级、色彩、组件视觉规则
---

# Visual Direction — 视觉方向

## 入口/出口
- **入口**: 需要定义视觉风格、层级、组件外观或对外呈现质感
- **出口**: 视觉方向、风格约束和层级规则定稿
- **指向**: 需要交互主路径 → `design-experience-interaction`；需要排版 → `design-content-layout`
- **假设已加载**: CANON.md + `design-workflow-design`

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

### Step 2：定义视觉目标
- 想传达什么气质
- 第一眼希望看见什么
- 哪些信息必须被降权

### Step 3：定视觉系统
- 色彩角色
- 字体层级
- 间距和对齐
- 卡片/按钮/图表/模块的视觉规则

### Step 4：记录不做清单
- 不使用的风格
- 不采用的视觉套路
- 不允许的冲突元素

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

| 说辞 | 现实 |
|------|------|
| “先做默认样式，后面再美化” | 默认样式会固化成事实设计。 |
| “多加点效果更高级” | 效果不是层级，噪音会吃掉重点。 |
| “差不多就行” | 差不多通常意味着没有视觉系统。 |

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
