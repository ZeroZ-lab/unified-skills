---
name: build-frontend-ui-engineering
description: 前端 UI 工程——构建可生产、可访问、视觉精良的用户界面。当需要构建或修改用户界面组件
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

- 负责：把已批准的交互和视觉方向工程化为可运行 UI
- 不负责：在 build 阶段重新决定主流程、视觉方向、信息架构
- 如缺少已批准设计：STOP，回到 `design-workflow-design`

## 组件架构

### 文件结构

```
components/
├── TaskList/
│   ├── TaskList.tsx          # 主组件
│   ├── TaskList.test.tsx     # 组件测试
│   ├── TaskList.module.css   # 隔离样式
│   └── TaskItem.tsx          # 子组件（仅当不被复用）
```

### 核心模式

**组合优于配置:**
```tsx
// Good: 组合
<TaskCard>
  <TaskTitle>{task.title}</TaskTitle>
  <TaskActions>
    <CompleteButton />
    <DeleteButton />
  </TaskActions>
</TaskCard>

// Bad: 配置爆炸
<TaskCard showTitle showActions actions={['complete', 'delete']} />
```

**关注点分离:** UI 逻辑（渲染、事件）≠ 业务逻辑（数据获取、验证）。组件只管 UI。

## 状态管理 — 从简单开始

```
简单度层次:
1. useState           → 单组件本地状态
2. useReducer         → 多子状态、状态转换复杂
3. Context            → 跨层传递、避免 prop drilling
4. Zustand / Jotai    → 全局共享、跨路由
5. Redux / MobX       → 仅大型应用、多人团队、复杂中间件需求时

永远从 1 开始。按需上升。不从 5 开始。
```

## 避免 AI 审美 — 别做这些

| 反模式 | 修复 |
|--------|------|
| 紫色/靛蓝贯穿全站 | 用**项目的**品牌色。读 tailwind.config 或设计系统的颜色定义。 |
| 过量渐变（按钮、Hero、卡片） | 用纯色背景。渐变用于强调（最多一处）。 |
| 所有圆角 16px+ | 按钮/输入框 6-8px、卡片 8-12px。不全部超大圆角。 |
| 通用 Hero Section | 具体化。展示产品截图/数据/客户 logo，不用占位符插图。 |
| Lorem ipsum 文案 | 用真实内容。没内容就用包含具体信息的占位符。 |
| 过大内边距（py-24, py-32） | 不同 section 用不同间距。建立间距尺度。 |
| 影子过度 | 一个层级：sm(卡片)、md(下拉)、lg(模态框)、xl(极少)。不创造第 6 级阴影。 |
| 三列图标卡片网格 | 最常见的 AI 生成模式 = 最容易被识别为 AI。用非对称布局、表格、或时间线替代。 |

**原则:** 看项目的现有 UI 决定风格。新项目 → 简洁 > 花哨。

## 可访问性 — WCAG 2.1 AA（强制）

### 键盘导航
```tsx
// 每个交互元素可通过键盘访问
<button onClick={handleClick}>操作</button>  // button 自动有键盘支持
<div onClick={handleClick}>操作</div>        // div 没有！必须加 tabIndex + onKeyDown
```

### ARIA 标签
```tsx
// 图标按钮必须有可访问名称
<button aria-label="关闭对话框">
  <XIcon />
</button>
```

### 焦点管理
```tsx
// 模态框打开 → 焦点进入模态框
// 模态框关闭 → 焦点回到触发按钮
// Tab 在模态框内循环，不逃逸到背景
```

### 有意义的空/错误/加载状态

**绝不只有这三种状态:** Normal、Hover、Active。必须覆盖：
- **Loading**: Skeleton / Spinner（不是白屏）
- **Empty**: 友好信息 + 行动引导（"还没有任务，创建一个吧"）
- **Error**: 具体错误信息 + 重试按钮（不是通用"出错了"）
- **Edge cases**: 超长文本、0 值、null 值

## 响应式设计

### 移动优先
```css
/* Base: 移动端 */
.container { padding: 1rem; }

/* 逐步增强 */
@media (min-width: 768px) { .container { padding: 2rem; } }
@media (min-width: 1024px) { .container { max-width: 1200px; margin: 0 auto; } }
```

### 断点参考

| 断点 | 目标设备 |
|------|---------|
| < 640px | 手机 |
| 640-768px | 大屏手机 / 小平板 |
| 768-1024px | 平板 |
| 1024-1280px | 小桌面 |
| > 1280px | 桌面 |

**通用响应式规则:**
- 图片: `max-width: 100%; height: auto`
- 表格: 小屏幕横向滚动
- 触摸目标: 最小 44x44px（WCAG 要求）

## Loading 与过渡

### Skeleton 优于 Spinner

```tsx
// Good: Skeleton 保持布局稳定
{loading ? <TaskListSkeleton /> : <TaskList tasks={tasks} />}

// Avoid: Spinner + 内容跳入（CLS）
{loading ? <Spinner /> : <TaskList tasks={tasks} />}
```

### 乐观更新

```tsx
// 操作立即反映，后台同步
const handleComplete = async (taskId: string) => {
  setCompleted(taskId);  // 立即 UI 更新
  try {
    await api.completeTask(taskId);  // 后台确认
  } catch {
    rollback(taskId);  // 失败回退
  }
};
```

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "可访问性最后加" | 最后加 = 不会加。从第一个组件做起。 | 可访问性后补 → 平均每个组件需额外 2-4 小时修复，且遗漏 ARIA 标签导致 15-20% 用户无法操作 |
| "这个渐变看起来很棒" | "AI 审美"会降低信任。项目色 > 花哨特效。 | AI 审美 → 产品被识别为 AI 生成，用户信任度下降；后续统一品牌色需重构 50-70% 样式代码 |
| "不用测 loading/error 状态" | 用户遇到空状态和错误状态的频率远超理想状态。 | 遗漏状态 → 30%+ 用户遇到白屏或无反馈操作，客户投诉率提升，Core Web Vitals CLS 分数下降 |
| "PC 端先做，手机之后适配" | 移动优先 CSS 更简洁。先做 PC 再向下适配很难。 | PC 优先 → 向下适配时需重写 40-60% CSS 响应式规则，等于做两遍 |
| "骨架屏太麻烦，用个转圈就行" | 转圈 + 内容跳入 = CLS = 用户体验差 + Core Web Vitals 降分。 | Spinner 代替 Skeleton → CLS 分数增加 0.1-0.3，Lighthouse 评分下降 5-15 分 |

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 使用了项目调色板外的颜色 | 立即替换为项目品牌色，读取 tailwind.config 或 DESIGN.md 中的色值 |
| 交互元素无键盘访问 | 添加 tabIndex + onKeyDown 或改用 `<button>`，不允许 div onClick 无键盘支持 |
| 缺少 Loading / Empty / Error 状态 | 停止前进，先补齐三个基础状态的 UI 和逻辑，再继续主功能 |
| 颜色作为唯一状态指示器 | 添加图标、文字或形状作为辅助信息通道，确保色盲用户可识别 |
| 移动端布局溢出 | 检查 max-width、触摸目标尺寸和横向滚动，320px 宽度下必须无溢出 |

## 好坏示例

### ✅ Good: 项目色 + 完整状态 + 可访问性

```tsx
// 项目品牌色（来源: tailwind.config → brand.primary = #2563EB）
<Button className="bg-brand-primary text-white rounded-md px-4 py-2">
  创建任务
</Button>

// 图标按钮有 aria-label
<button aria-label="关闭对话框" onClick={handleClose}>
  <XIcon className="w-4 h-4" />
</button>

// 完整状态覆盖
{loading ? <TaskListSkeleton /> : (
  tasks.length === 0 ? (
    <EmptyState message="还没有任务" actionLabel="创建第一个" onAction={handleCreate} />
  ) : error ? (
    <ErrorState message={error.message} onRetry={handleRetry} />
  ) : (
    <TaskList tasks={tasks} />
  )
)}
```

### ❌ Bad: AI 审美 + 遗漏状态 + 不可访问

```tsx
// AI 审美——靛蓝渐变 + 超大圆角
<Button className="bg-gradient-to-r from-indigo-500 to-purple-600 rounded-2xl px-8 py-6">
  创建任务
</Button>

// div onClick 无键盘支持
<div onClick={handleClose}>✕</div>

// 只有正常状态，无 loading / empty / error
<TaskList tasks={tasks} />  // 白屏或崩溃时用户无任何反馈
```

## 红旗 — STOP

- 自己发明颜色而不是用项目调色板
- 没有键盘访问的 onClick div（不用 button）
- 颜色作为唯一状态指示器（色盲用户看不到）
- 缺少任何一个状态（Loading / Empty / Error）
- 无 alt 文本的图像
- 图片不设宽高（CLS 隐患）
- 移动端弹窗无法滚动
- `px-8 py-24` 的 Hero Section 配通用插图 = AI 审美警报

## 输出模板

UI 工程完成后，应在组件文件或相关 ADR 中记录以下结构：

```markdown
## UI Component — [组件名称]

### 设计来源
- 交互设计: `02-design.md` → [交互流程描述]
- 视觉方向: `02-design.md` → [视觉层级和色值]
- 项目 token: DESIGN.md → [使用的 spacing / color / rounded 值]

### 状态覆盖
| 状态 | UI 表现 | 数据条件 |
|------|---------|---------|
| Normal | [正常渲染] | data.length > 0 && !error |
| Loading | [Skeleton / Spinner] | isLoading === true |
| Empty | [空态文案 + 行动引导] | data.length === 0 && !isLoading |
| Error | [错误信息 + 重试按钮] | error !== null |

### 可访问性
- 键盘导航: [Tab / Enter / Escape 路径]
- ARIA: [aria-label / aria-role 清单]
- 焦点管理: [模态框焦点循环 / 关闭后回退]
- 色盲兼容: [颜色 + 图标/文字双通道]

### 响应式
- 移动端 (< 640px): [布局变化]
- 平板 (768-1024px): [布局变化]
- 桌面 (> 1280px): [布局变化]

### 组合模式
- 父组件: [包裹方式]
- 子组件: [拆分方式]
- 配置项: [仅必要配置，避免配置爆炸]
```

## 验证清单

- [ ] 每个交互元素可通过键盘访问 (Tab / Enter / Escape)
- [ ] 图标/图像有适当的 alt 或 aria-label
- [ ] Color 不是唯一信息传达方式
- [ ] 有 Loading / Empty / Error 状态
- [ ] 移动端 (320px) 可正常使用，横向不溢出
- [ ] 使用项目颜色/间距体系（不是自己发明）
- [ ] 图片有显式 width/height
