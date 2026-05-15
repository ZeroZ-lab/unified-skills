---
name: design-experience-interaction
description: 交互设计——关键流程、状态、信息架构、用户路径
---

# Interaction Design — 交互设计

## 入口/出口
- **入口**: `software` 任务需要页面、组件、流程、状态或信息架构设计
- **出口**: 关键流程、页面结构、状态设计和交互边界定稿
- **指向**: 需要视觉方向 → `design-visual-direction`；设计批准后 → `build-workflow-plan`
- **输出路径**: `build-content-writing` 或 `build-content-layout`（下游 build 技能）
- **前置加载**: CANON.md + `design-workflow-design`

## 何时不使用
- 纯后端、脚本、迁移
- 已有不可修改的既定交互规范且本次只做工程实现

## 核心原则

1. **Path Before Pixels** — 先定用户怎样完成任务，再谈样式。
2. **State Completeness** — 默认、加载、空态、错误态、边界态必须成套出现。
3. **One Primary Flow** — 一个设计稿只允许一条主任务路径。
4. **Mental Model Fit** — 概念和结构要贴近用户预期。
5. **Interaction Is a Contract** — 一旦进入实现，流程和状态会变成事实约束。

## 最佳实践输入

先读取 `references/design-best-practices.md` 和 `references/design-inspiration-catalog.md`，并把交互相关证据写入 `02-design.md` 的 `Design References / Pattern Synthesis / Adopt / Reject`。

扫描重点：
- Enterprise Product Patterns: 类似产品的主流程、导航、表单、状态和完成确认模式
- Official Systems / Platform Rules: 平台交互规范、组件行为、无障碍交互规则
- Methods / Theory / Style Schools: 信息架构、心智模型、渐进披露、错误恢复方法
- Anti-patterns / Verification: happy path-only、状态缺失、CTA 优先级混乱、死胡同流程
- Local Project Truth: 现有路由、组件库、用户权限、数据可用性和业务边界；项目根 `DESIGN.md`（如果存在，作为跨 feature 交互约束参考）

没有可回溯证据时，不得把交互流程写成最终决策。

## 流程

### Step 1：定义用户任务
- 用户是谁
- 进入点是什么
- 目标动作是什么
- 完成后如何确认成功
- ✅ 验证点: 用户任务是否能用一句话复述，且不涉及内部实现概念？

### Step 2：画主路径
- 起点
- 决策点
- 关键动作
- 成功出口
- ✅ 验证点: 主路径是否只有一条，且没有分支替代？

### Step 3：补齐状态
- loading
- empty
- error
- edge cases
- permission / disabled / conflict
- ✅ 验证点: 每个主路径节点是否都覆盖了 4 种基础状态（loading / empty / error / normal）？

### Step 4：定义页面/组件结构
- 页面层级
- 区块关系
- 主要 CTA
- 次要路径如何降权
- ✅ 验证点: 页面层级是否只有一个主 CTA，次要路径是否已显式降权？

## 输出契约

写入 `02-design.md`：
- 用户目标
- 关键流程
- 页面 / 组件结构
- 状态设计
- Adopt / Reject（交互模式）
- 不做清单

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 主路径不清 | 删除支线，先只保留一个主路径 |
| 状态缺失 | 补齐状态清单再继续 |
| 页面结构靠实现猜 | 先写结构，再允许工程实现 |
| 用户任务不明确 | 回到 spec 澄清目标用户和成功标准 |
| 交互模式无证据 | 补充 best-practice scan，写清 Adopt / Reject 后再继续 |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| “交互以后再补” | 以后补 = 线上返工。 | 缺失状态和边界 → 生产后每补一个状态平均返工 2-4 小时，且遗漏 error/empty 状态直接影响用户留存 |
| “先把 happy path 做通” | 没有状态设计的 happy path 不是真流程。 | 只做 happy path → 30%+ 用户遇到空态/错误态时无法完成操作，客户投诉率提升 |
| “这个组件很小，不需要交互设计” | 小组件也可能承载关键决策或错误态。 | 省略交互设计 → 小组件在边界条件下行为不可预测，单次 bug 修复 1-3 小时 |

## 好坏示例

### ✅ Good: 证据驱动的交互决策

```
主路径: 用户从 Dashboard → 点击"新建任务" → 填写表单 → 看到确认页 → 返回列表

状态设计:
- Loading: 表单提交时按钮变灰 + Spinner
- Empty: "还没有任务，创建你的第一个" + 行动引导按钮
- Error: "网络异常，请重试" + 重试按钮（不是通用"出错了")
- Permission disabled: "需要管理员权限才能创建任务" + 申请入口

Adopt: 逐步披露表单（参考 Salesforce 模式，Pattern Synthesis 来源 #3）
Reject: 全屏 Modal 表单（与项目侧边栏导航冲突，来源: Local Project Truth）
```

### ❌ Bad: 没有证据的抽象模板

```
主路径: 用户 → 页面 → 操作 → 结果

状态设计: (未写)
交互模式: 看项目情况决定
不做清单: (未写)
→ 没有 best-practice scan，没有 Adopt / Reject，没有具体页面结构
```

## 输出模板

交互设计产出应写入 `02-design.md` 的以下结构：

```markdown
## Interaction Design — [功能名称]

### 用户目标
- 目标用户: [角色]
- 进入点: [从哪里来]
- 成功标准: [完成后看到什么]

### 关键流程
1. [步骤 1] → [步骤 2] → [步骤 3] → [成功出口]
- 决策点: [分支描述]
- 次要路径: [降权描述]

### 状态设计
| 场景 | Loading | Empty | Error | Edge |
|------|---------|-------|-------|------|
| [主路径节点] | [具体 UI] | [具体 UI] | [具体 UI] | [具体 UI] |

### 页面 / 组件结构
- 页面层级: [层级描述]
- 主 CTA: [按钮文案和行为]
- 次要路径降权: [降权方式]

### Adopt / Reject（交互模式）
| 模式 | 来源 | 决定 | 理由 |
|------|------|------|------|
| [模式 A] | [来源层] | Adopt | [具体理由] |
| [模式 B] | [来源层] | Reject | [冲突点] |

### 不做清单
- [不做项 1]
- [不做项 2]
```

## 红旗 — STOP

- 只有 happy path，没有状态设计
- 缺少交互 best-practice scan 或 Adopt / Reject
- 用户目标写成内部实现目标
- 页面结构和 CTA 优先级不清
- 交互设计退化成工程任务清单

## 验证清单

- [ ] 用户目标明确
- [ ] 主路径完整
- [ ] 状态覆盖完整
- [ ] 页面 / 组件结构明确
- [ ] 交互决策已回溯到来源证据或 Local Project Truth
- [ ] 已写入 `02-design.md`
