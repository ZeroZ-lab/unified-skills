---
name: verify-frontend-accessibility
description: 可访问性保障——WCAG 2.1 AA 合规。使用 cuando 构建 UI 组件、表单、导航或交互元素
---

# Accessibility — 可访问性保障


## 入口/出口
- **入口**: 构建 UI 组件、表单、导航、或交互元素
- **出口**: 通过 a11y 检查的组件
- **指向**: a11y 验证通过后继续 build 或进入 `/review`
- **假设已加载**: CANON.md + `build-frontend-ui-engineering/SKILL.md`

## Iron Law

<HARD-GATE>
```
每个 UI 元素必须可被键盘访问、屏幕阅读器理解和视觉辨识。
WCAG 2.1 AA 是最低准入门槛，不是锦上添花。
没有通过 a11y 审查的 UI = 不可交付的 UI。
```
</HARD-GATE>

## 目标: WCAG 2.1 AA

AA 是达到的最低商业标准。AAA 在特定方面努力但不作为全局要求。

## 三大支柱

### 1. 键盘导航

```
每个交互元素必须通过键盘可达和可操作:
├── Tab → 进入元素
├── Shift+Tab → 离开元素（回到上一个）
├── Enter / Space → 激活按钮/链接
├── Escape → 关闭模态框/下拉
├── Arrow Keys → 在选项间移动（菜单、tabs、单选组）
└── 焦点顺序 → 逻辑顺序（DOM 顺序匹配视觉顺序）
```

```tsx
// Bad: div 不可通过键盘操作
<div onClick={handleClick}>删除</div>

// Good: button 自动有键盘支持
<button onClick={handleClick}>删除</button>
```

**焦点陷阱:** 模态框打开 → 焦点困在模态框内（Tab 循环不逃逸）。模态框关闭 → 焦点回到触发元素。

### 2. 屏幕阅读器

```tsx
// 图像: 始终有 alt
<img src="logo.png" alt="Company Name" />
// 装饰性图像: alt="" (空，不是缺失)

// 图标按钮: aria-label
<button aria-label="关闭对话框">
  <XIcon />
</button>

// 表单: label 和 input 关联
<label htmlFor="task-title">任务标题</label>
<input id="task-title" type="text" />

// 错误关联
<input id="email" aria-describedby="email-error" />
<span id="email-error" role="alert">请输入有效的邮箱地址</span>
```

**ARIA 规则:** 原生 HTML 元素（`<button>`、`<input>`、`<a>`）已有隐式 ARIA。不需要加 `role="button"` 到 `<button>`。ARIA 仅在不使用原生元素时才需要。

### 3. 视觉

```
对比度 (WCAG AA):
├── 普通文本: ≥ 4.5:1
├── 大文本 (≥18px bold 或 ≥24px): ≥ 3:1
└── UI 组件/图形: ≥ 3:1

颜色不是唯一的信息传达方式:
├── 错误状态: 红色边框 + 图标 + 文字
├── 成功状态: 绿色边框 + 图标 + 文字
├── 链接: 下划线（不仅仅是颜色）
└── 图表: 图案/纹理 + 颜色
```

## 关键检查

### 表单
- [ ] 每个 input 有 label
- [ ] 必填字段有指示（星号 + "required" 文字，非仅颜色）
- [ ] 错误信息关联到对应 input（`aria-describedby`）
- [ ] 提交前验证错误焦点跳转到第一个错误字段

### 图像
- [ ] 内容图像有描述性 `alt`
- [ ] 装饰性图像有 `alt=""`
- [ ] SVG 图标有 `aria-label` 或用 `aria-hidden="true"` 隐藏

### 导航
- [ ] 页面有 skip-to-content 链接
- [ ] 当前页面/位置有 `aria-current="page"`
- [ ] 主导航有 `<nav>` landmark

### 页面结构
- [ ] 有语义标题层次（h1 → h2 → h3，不跳级）
- [ ] 有 `<main>`、`<header>`、`<footer>` landmarks
- [ ] 信息不依赖纯视觉呈现（"右侧面板"、"绿色按钮"）

### 动态内容
- [ ] Toast/通知有 `role="alert"` 或 `aria-live`
- [ ] 加载状态被宣告（`aria-busy` 或加载提示）
- [ ] 模态框打开时焦点移到模态框内

## 测试工具

```bash
# 自动检查
npx axe-core          # 静态分析
npx pa11y-ci          # CI 集成
npx lighthouse        # Chrome DevTools 中的 Accessibility 审计

# 手动测试
Tab 遍历页面          # 键盘导航是否有逻辑顺序？
VoiceOver / NVDA     # 屏幕阅读器能否理解页面？
```

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "可访问性最后加" | 从第一个组件做起。最后加 = 永远不会加 = 重新写一遍。 | 最后加 = 全局 DOM 结构不支持键盘导航和 ARIA，改造工作量 = 重写前端 40-60%。项目永远不会做。 |
| "用户基本没有残障人士" | 可访问性也服务所有人：键盘用户、移动端、慢网络、临时障碍（手臂骨折）。（可访问性提升所有用户的体验） | 全球 ~15% 人口有某种形式的残障。忽略 a11y = 排除 15% 潜在用户 + 法律合规风险（ADA 诉讼平均赔偿 $50K+）。 |
| "自动检查通过了就行" | aXe 能检测 ~30% 的问题。键盘手动测试和屏幕阅读器手动测试不可替代。 | 自动工具遗漏的 70% 包括焦点陷阱、语义结构、屏幕阅读器体验——这些是真实用户的日常障碍。 |
| "用 div 比用 button 方便" | div 没有键盘操作、没有 ARIA role、没有焦点管理。用 button。 | div 做的按钮对键盘用户完全不可操作，对屏幕阅读器用户完全不可见——功能对他们来说不存在。 |
| "颜色区分足够" | ~8% 的男性有某种形式的色弱。信息永远不只通过颜色传达。 | 色弱用户看不到红色错误提示 → 提交错误数据 → 业务流程中断。纯颜色区分 = 对 8% 用户功能失效。 |

**违反字面规则就是违反精神。** 没有灰色地带。

## 红旗 — STOP

- 只用颜色（红/绿）指示状态 —— 没文字、没图标
- 表单 input 没有 label（或 placeholder 作为唯一标签）
- 模态框打开后焦点没有移动进去
- Tab 顺序在视觉和逻辑上不一致
- 图像没有 alt（且不是装饰性的）
- 视频没有字幕
- `onClick` div 充当按钮（用 `<button>`）

## 验证清单

- [ ] Tab 顺序有逻辑性，所有交互元素可达
- [ ] 模态框焦点管理正确（进入+关回）
- [ ] 所有内容图像有 `alt`
- [ ] 颜色不是唯一信息传达方式
- [ ] 表单有 label、错误关联、必填指示
- [ ] aXe / Lighthouse Accessibility 审计通过（得分 ≥ 90）
- [ ] 键盘能完成主要用户流程
