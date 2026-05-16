---
name: build-frontend-ui-engineering
description: 前端 UI 工程——构建可访问、视觉精良的用户界面。当需要构建或修改 UI 组件、页面布局，或提到"组件""页面""前端""UI"
---

# UI Engineering — 前端界面工程


## 入口/出口
- **入口**: build 中需要 UI 组件或页面
- **出口**: 可生产、通过可访问性检查的 UI 组件 + 测试
- **指向**: 前端变更完成 → `build-frontend-browser-testing` 进行浏览器验证
- **输出路径**: `verify-frontend-accessibility`（下游验证技能）
- **前置加载**: CANON.md + `build-quality-tdd/SKILL.md`

## 何时不使用
- 只做产品/视觉/交互决策，尚未进入工程实现
- 纯后端、脚本、CI 或数据迁移变更
- UI 已实现，只需要浏览器截图、交互验证或可访问性审查

## 职责边界

把已批准的交互和视觉方向工程化为可运行 UI。不在 build 阶段重新决定主流程/视觉方向/信息架构。缺少已批准设计 → STOP，回到 `design-workflow-design`。

## 组件架构

**文件结构：** 一个组件一个目录（主组件 + 测试 + 样式 + 仅本组件用子组件）。

**组合优于配置：** 用 children 组合（`<Card><Title/><Actions/></Card>`），不用 props 配置爆炸（`<Card showTitle showActions actions={[...]}`）。

**关注点分离：** UI 逻辑（渲染、事件）≠ 业务逻辑（数据获取、验证）。组件只管 UI。

## 状态管理 — 从简单开始

useState → useReducer → Context → Zustand/Jotai → Redux/MobX。永远从 1 开始，按需上升，不从 5 开始。

## 避免 AI 审美

| 反模式 | 修复 |
|--------|------|
| 紫色/靛蓝贯穿全站 | 用项目品牌色。读 tailwind.config 或设计系统 |
| 过量渐变 | 纯色背景。渐变最多一处强调 |
| 所有圆角 16px+ | 按钮 6-8px、卡片 8-12px |
| 通用 Hero Section | 展示产品截图/数据/logo，不用占位符 |
| Lorem ipsum 文案 | 用包含具体信息的占位符 |
| 过大内边距（py-24/32） | 不同 section 用不同间距，建立间距尺度 |
| 影子过度 | sm(卡片)、md(下拉)、lg(模态框)。不创造第 6 级 |
| 三列图标卡片网格 | 最常见 AI 生成模式。用非对称布局/表格/时间线 |

**原则：** 看项目现有 UI 决定风格。新项目 → 简洁 > 花哨。

## 可访问性 — WCAG 2.1 AA（强制）

**键盘导航：** 每个交互元素可通过键盘访问。`<button>` 自动有支持，`<div onClick>` 必须加 tabIndex + onKeyDown。

**ARIA 标签：** 图标按钮必须有 `aria-label`。

**焦点管理：** 模态框打开 → 焦点进入；关闭 → 回到触发按钮；Tab 在模态框内循环不逃逸。

**有意义的空/错误/加载状态：** Loading 用 Skeleton（不是白屏）；Empty 用友好信息 + 行动引导；Error 用具体信息 + 重试按钮；Edge cases：超长文本、0 值、null。

## 响应式设计

**移动优先：** Base 样式 = 移动端，逐步增强。

**断点：** <640px 手机 | 640-768 大屏手机/小平板 | 768-1024 平板 | 1024-1280 小桌面 | >1280 桌面。

**通用规则：** 图片 `max-width: 100%; height: auto`；表格小屏幕横向滚动；触摸目标最小 44x44px。

## Loading 与过渡

**Skeleton 优于 Spinner：** Skeleton 保持布局稳定（低 CLS），Spinner + 内容跳入破坏 CLS。

**乐观更新：** 操作立即反映 UI → 后台同步 → 失败回退。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "可访问性最后加" | 最后加 = 不会加。从第一个组件做起。 | 每个组件额外 2-4h 修复，遗漏 ARIA 致 15-20% 用户无法操作 |
| "这个渐变看起来很棒" | AI 审美降低信任。项目色 > 花哨特效。 | 产品被识别为 AI 生成，后续统一品牌色需重构 50-70% 样式 |
| "不用测 loading/error" | 用户遇空态/错误态频率远超理想态。 | 30%+ 用户遇白屏，CLS 分数下降 |
| "PC 先做，手机之后适配" | 移动优先 CSS 更简洁。先 PC 再向下很难。 | 向下适配需重写 40-60% CSS |
| "骨架屏太麻烦，用转圈" | 转圈 + 跳入 = CLS = 体验差。 | CLS 增加 0.1-0.3，Lighthouse 下降 5-15 分 |

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 用了调色板外颜色 | 替换为项目品牌色 |
| 交互元素无键盘访问 | 加 tabIndex + onKeyDown 或改用 `<button>` |
| 缺 Loading / Empty / Error 状态 | 先补齐三状态再继续 |
| 颜色作唯一状态指示 | 加图标/文字辅助通道 |
| 移动端布局溢出 | 检查 max-width、触摸目标，320px 下无溢出 |

## 红旗 — STOP

- 自己发明颜色而不是用项目调色板
- 没有键盘访问的 onClick div
- 颜色作为唯一状态指示器
- 缺少 Loading / Empty / Error 任何一个
- 无 alt 文本的图像
- 图片不设宽高（CLS 隐患）
- 移动端弹窗无法滚动
- `px-8 py-24` Hero + 通用插图 = AI 审美警报

## 验证清单

- [ ] 每个交互元素可通过键盘访问
- [ ] 图标/图像有 alt 或 aria-label
- [ ] Color 不是唯一信息传达方式
- [ ] 有 Loading / Empty / Error 状态
- [ ] 移动端 (320px) 可正常使用，不溢出
- [ ] 使用项目颜色/间距体系
- [ ] 图片有显式 width/height

## 输出模板

```markdown
## UI Component — [组件名称]

### 设计来源
- 交互设计: `02-design.md` → [描述]
- 视觉方向: `02-design.md` → [层级和色值]
- 项目 token: DESIGN.md → [spacing / color / rounded]

### 状态覆盖
| 状态 | UI 表现 | 数据条件 |
|------|---------|---------|
| Normal | [渲染] | data.length > 0 && !error |
| Loading | [Skeleton] | isLoading |
| Empty | [文案 + 引导] | data.length === 0 && !isLoading |
| Error | [信息 + 重试] | error !== null |

### 可访问性
- 键盘: [Tab / Enter / Escape 路径]
- ARIA: [清单]
- 焦点: [模态框循环 / 回退]
- 色盲: [颜色 + 图标双通道]

### 响应式
- 移动 (<640px): [变化]
- 平板 (768-1024px): [变化]
- 桌面 (>1280px): [变化]
```
