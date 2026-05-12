---
name: design-content-layout
description: 排版设计——版式系统、构图、页面层级、媒介适配
---

# Layout Design — 排版设计

## 入口/出口
- **入口**: 需要在实现前锁定版式方向、构图或页面层级
- **出口**: 版式系统、构图原则、页面层级和导出约束定稿
- **指向**: 需要视觉风格 → `design-visual-direction`；执行落地 → `build-content-layout`
- **假设已加载**: CANON.md + `design-workflow-design`

## 何时不使用
- 只有内容微调，不改版式
- 已有不可修改模板且本次只做填充

## Iron Law

排版设计先解决阅读路径和版式系统，再进入具体页面落地。

## 核心原则

1. **Structure Before Surface**
2. **One Reading Path**
3. **Layout Must Fit the Medium**
4. **Consistency Enables Speed**
5. **Export Constraints Are Design Constraints**

## 最佳实践输入

先读取 `references/design-best-practices.md` 和 `references/design-pattern-extract.md`，并把排版相关证据写入 `02-design.md` 的 `Design References / Pattern Synthesis / Adopt / Reject`。

扫描重点：
- Enterprise Product Patterns: 同类文档、deck、visual 的密度、构图、阅读路径和媒介约定
- Official Systems / Platform Rules: 品牌版式、平台尺寸、打印/投屏/导出规范、可读性规则
- Methods / Theory / Style Schools: 栅格、层级、留白、对齐、信息设计方法
- Anti-patterns / Verification: card 套 card、随机间距、多主焦点、强行 bento、导出错位
- Local Project Truth: 当前模板、素材比例、内容长度、输出格式和安全边距；项目根 `DESIGN.md`（如果存在，读取 spacing/rounded/layout token）

版式决策必须有来源层或本地约束支撑；不能只写审美词。

## 流程

### Step 1：读取媒介约束
- 阅读 / 投屏 / 打印 / 社媒
- 尺寸、比例、页边距
- 字体、品牌、模板限制

### Step 2：定义版式系统
- 栅格
- 对齐线
- 间距尺度
- 标题 / 正文 / 注释层级

### Step 3：定义构图
- 主焦点
- 分组关系
- 页面密度
- 关键信息如何占位

### Step 4：记录导出约束
- 预览方式
- 安全边距
- 可能错位风险

## 输出契约

写入 `02-design.md`：
- 排版方向
- 页面视觉层级
- 构图 / 导出规格
- Adopt / Reject（排版模式）
- 不做清单

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 版式方向只有审美词 | 改写成栅格、层级、密度和对齐规则 |
| 没有导出约束 | 停止，先明确媒介和尺寸 |
| 多个主焦点竞争 | 回退到单主焦点版式 |
| 排版模式无证据 | 补充 best-practice scan，写清 Adopt / Reject |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| “排版最后再调” | 版式系统最后补，通常已经来不及。 |
| “先把内容塞进去” | 靠塞内容会把结构问题隐藏起来。 |
| “导出错了再说” | 导出约束不提前处理，返工最大。 |

## 红旗 — STOP

- 没有画布或媒介约束
- 缺少排版 best-practice scan 或 Adopt / Reject
- 没有栅格或层级规则
- 构图中存在多个主焦点
- 导出规格完全未定义

## 验证清单

- [ ] 媒介约束明确
- [ ] 版式系统明确
- [ ] 构图明确
- [ ] 导出约束明确
- [ ] 排版决策已回溯到来源证据或 Local Project Truth
- [ ] 已写入 `02-design.md`
