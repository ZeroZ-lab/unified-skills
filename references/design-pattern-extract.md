# Design Pattern Extract — 高频设计模式

从 73 个真实网站 DESIGN.md（[awesome-design-md](https://github.com/voltagent/awesome-design-md)）中提炼的高频设计模式。

Phase 2 扫描时作为 Enterprise Product Patterns 和 Methods / Theory 层的具体来源引用。每条模式包含适用场景和具体 token 示例。

---

## 色彩策略（Color Strategies）

### Pattern A: 单一强调色 + 单色基底（~80%）

一个品牌色 + ink + canvas + 1-2 个辅助色。强调色只用于 CTA、链接和品牌标记。

| 公司 | 强调色 | 墨色 | 底色 |
|------|--------|------|------|
| Stripe | `#533afd` indigo | `#0d253d` deep navy | `#f6f9fc` cool off-white |
| Coinbase | `#0052ff` blue | `#0a0b0d` | `#ffffff` |
| Linear | `#5e6ad2` lavender | `#f7f8f8` on dark | `#010102` near-black |
| Supabase | `#3ecf8e` emerald | `#171717` | `#ffffff` |
| Airbnb | `#ff385c` Rausch | `#222222` | `#ffffff` |

适用：SaaS、金融、工具类产品。一个 chromatic moment per viewport。

### Pattern B: 暗色 Canvas + Surface Ladder（~40%）

接近纯黑底色 + 3-5 个表面层级 + hairline 边框。暗色表面不用阴影，用 surface-color 对比传达层级。

```
Surface ladder 示例（Linear）:
canvas:    #010102
surface-1: #0f1011
surface-2: #141516
surface-3: #18191a
surface-4: #191a1b
hairline:  rgba(255,255,255,0.06)
```

适用：开发者工具、音乐/媒体播放器、暗色模式产品。

### Pattern C: 双 Canvas / 双轨系统（~20%）

暗色轨道用于情感/电影感，亮色轨道用于信息/交易。

| 公司 | 暗色轨道 | 亮色轨道 |
|------|---------|---------|
| Shopify | cinematic black | cream-mint transactional |
| Coinbase | dark hero band | white editorial |
| Apple | dark product tiles | white/parchment tiles |

适用：电商、消费品、需要同时传达品牌感和功能性的产品。

### Pattern D: Gradient Mesh 氛围深度（~25%）

渐变 mesh 占据 hero 区域，作为深度/发光效果而非字面阴影。通常用 SVG 实现。

- Stripe: cream/orange/lavender/indigo/ruby mesh
- Vercel: cyan/blue/magenta/amber mesh
- Slack: cream-lavender pastel mesh

适用：需要情感/氛围层的营销页面。不适用于数据密集的功能界面。

### Pattern E: 温暖 Canvas / Off-White（~15%）

刻意温暖的 off-white 传达 editorial 温暖感。

- PostHog: `#eeefe9` cream
- Shopify: `#fbfbf5` cream
- Apple: `#f5f5f7` parchment

---

## 排版策略（Typography Strategies）

### Pattern A: 负 Letter-Spacing Display（~85%）

所有顶级品牌都在 display 字号使用负 tracking。规律：tracking ≈ -(1% to 4% of font-size)。

| 公司 | 字号 | Tracking | 字重 |
|------|------|----------|------|
| Linear | 80px | -3.0px | 500 |
| Vercel | 48px | -2.4px | 600 |
| Coinbase | 80px | -2.0px | 400 |
| Notion | 80px | -2.0px | 600 |
| Stripe | 56px | -1.4px | 300 |
| Figma | 86px | -1.72px | 340 |

### Pattern B: 细/轻 Display 字重（~50%）

顶级品牌偏向 300-400 而非 700+ 作为 display 字重，传达 editorial calm。

- Stripe: weight 300
- Shopify: weight 330
- Figma: weight 340
- Coinbase: weight 400

### Pattern C: 自定义 Display Font + Inter/System Body（~70%）

品牌字体仅用于 display，正文使用 Inter、system-ui 或 -apple-system。

### Pattern D: OpenType Stylistic Sets（~30%）

- ss01: Stripe, Meta（全局应用）
- ss03: Shopify, Raycast（全局应用）
- 组合: Raycast 使用 ss03 + calt + kern + liga

### Pattern E: Tabular/Monospace 金融数字（~60% 金融类）

- Stripe: `tnum` on all money cells
- Coinbase: CoinbaseMono on all numbers
- 原则：金融 DNA 通过微排版细节表达

---

## 组件策略（Component Strategies）

### Pattern A: Pill 形 CTA 按钮（~75%）

- 标准：9999px 或 90-100px radius，8-16px 纵向 padding
- 例外：Linear 故意使用 8px rounded-md buttons（品牌差异化）
- 次要按钮：outline/ghost 样式

### Pattern B: 定价卡网格 + 突出层级（~60%）

3-4 列网格，一个突出层级使用视觉反转（暗色表面或强调色填充）。

### Pattern C: 产品 UI 截图作为 Hero（~65%）

"Show the product" 替代装饰性插画。Linear、Stripe、Coinbase、Vercel、Supabase 均采用。

### Pattern D: 顶部导航 Logo + Links + 双 CTA（~80%）

Logo 左，导航链接中，sign-in + primary CTA 右。双 CTA：次要（outline）+ 主要（filled pill）。

### Pattern E: 特性卡在提升表面（~70%）

2-3 列网格，12-16px border radius，24-32px 内部 padding，1px hairline border 或微妙阴影。

---

## 布局策略（Layout Strategies）

### Pattern A: 8px 基础间距单位（~75%）

子 token：2, 4, 12, 16, 24, 32, 48, 64, 96px。营销页面 section padding: 64-96px。

### Pattern B: ~1200px 内容最大宽度（~70%）

Hero 摄影/渐变全 bleed 超出容器，正文阅读列 720-840px。

### Pattern C: 响应式断点（~90%）

Desktop >= 1024px, Tablet 768-1023px, Mobile < 768px。
卡网格：3-up → 2-up → 1-up。Display 字号阶梯递减。

### Pattern D: Content Over Chrome（~80%）

摄影、产品截图或内容占视觉优先。导航、边框、UI 元素退居其次。Section 间 64-96px 间距。

---

## 通用 Do's

1. 品牌色只用于 CTA 和链接——不做正文或背景填充
2. Display 排版使用负 letter-spacing
3. CTA 使用 pill/rounded 形状
4. Hero 配产品 UI 或摄影——show, don't tell
5. 强调色克制——每屏一到两个 chromatic moment
6. Section padding 慷慨（64-96px）——留白即品牌
7. 保持一致的 border radius 阶梯
8. 全局启用 OpenType 特性（ss01/ss03/kern）
9. 数字使用 monospace/tabular figures

## 通用 Don'ts

1. 不引入超出文档调色板的第二强调色
2. Display 字重不超过品牌规范（thinness = identity）
3. 品牌色不做正文文字色
4. 不混用按钮形状（要么全 pill 要么全 rounded-rect）
5. 不留白 canvas hero 不加 gradient/摄影——atmospheric depth 是必需的
6. 按钮 padding 不低于品牌最低值（touch target 40-44px）
7. 暗色表面不加装饰性阴影——用 surface ladder
8. 不用 body 排版替代 display 排版——双层分裂是结构性的
9. 不用纯 #000000 黑做白底文字——ink 色略带暖调（#1d1d1f, #222222, #171717）
