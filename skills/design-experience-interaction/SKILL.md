---
name: design-experience-interaction
description: 交互设计——关键流程、状态、信息架构、用户路径
---

# Interaction Design — 交互设计

## 入口/出口
- **入口**: `software` 任务需要页面、组件、流程、状态或信息架构设计
- **出口**: 关键流程、页面结构、状态设计和交互边界定稿
- **指向**: 需要视觉方向 → `design-visual-direction`；设计批准后 → `build-workflow-plan`
- **假设已加载**: CANON.md + `design-workflow-design`

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

### Step 2：画主路径
- 起点
- 决策点
- 关键动作
- 成功出口

### Step 3：补齐状态
- loading
- empty
- error
- edge cases
- permission / disabled / conflict

### Step 4：定义页面/组件结构
- 页面层级
- 区块关系
- 主要 CTA
- 次要路径如何降权

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

| 说辞 | 现实 |
|------|------|
| “交互以后再补” | 以后补 = 线上返工。 |
| “先把 happy path 做通” | 没有状态设计的 happy path 不是真流程。 |
| “这个组件很小，不需要交互设计” | 小组件也可能承载关键决策或错误态。 |

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
