---
name: design-workflow-design
description: 创作设计阶段总控——在 plan/build 之前定稿交互、视觉、排版、剧本、导演设计
---

# Design — 创作设计总控

## 入口/出口
- **入口**: `01-spec.md` 已批准，且任务会产生用户可感知产物
- **出口**: `docs/features/YYYYMMDD-<name>/02-design.md` + 用户批准；纯后端/脚本/迁移允许 skip
- **指向**: 设计批准后进入 `build-workflow-plan`；设计探索不足时回到 `define-workflow-refine`
- **假设已加载**: CANON.md

## 何时不使用
- 纯后端接口、数据库迁移、脚本、CI 配置等不产生用户可感知产物
- 单行修复且不影响任何 UI/文档/视觉/叙事呈现

## Iron Law

<HARD-GATE>
没有已批准的创作设计，不得进入 `/plan` 或 `/build` 去拆实现任务或产出用户可见结果。
设计阶段只定创作与呈现决策，不写实现步骤，不写 task breakdown。
</HARD-GATE>

## 设计适用性判断

### 一定需要 design
- `document` / `article` / `deck` / `visual`
- `software` 且涉及页面、组件、交互、视觉呈现、信息架构、用户路径

### 可以 skip design
- `software` 且纯后端
- 纯脚本、纯迁移、纯 CI / 配置

skip 时必须明确记录：
```markdown
## Design Requirement
- Design Status: skipped
- Skip Reason: pure backend / migration / script / CI only
```

## 核心边界

- `define`：定义问题、目标、范围、成功标准
- `design`：定稿交互、视觉、排版、剧本、导演方案
- `plan`：拆任务、排依赖、定并行策略
- `build`：实现或生成产物

设计阶段不做：
- 不写实现代码
- 不写 Task N
- 不决定数据库/API/服务架构
- 不把像素级微调当成阶段主目标

## 流程

### Step 1：读取 spec 并判断是否需要设计

读取：
- `artifact_type`
- 目标用户 / 读者 / 观众
- 使用场景
- 成功标准
- Scope 边界

然后判断：
- 是否有用户可感知产物
- 是否需要在实现前锁定创作和呈现方向

### Step 2：选择设计轨道

| 场景 | 需要加载 |
|------|---------|
| `software` + UI | `design-experience-interaction` + `design-visual-direction` |
| `document` / `article` | `design-content-script` + `design-content-layout` |
| `deck` | `design-content-script` + `design-content-direction` + `design-content-layout` |
| `visual` | `design-visual-direction` + `design-content-layout` |

### Step 3：产出 `02-design.md`

必须包含：
- 设计目标
- 关键决策
- 设计边界
- 设计批准标准
- 实施前置条件
- 按类型的设计内容

### Step 4：用户批准

向 human partner 展示设计稿，逐项确认：
- 方向是否对
- 是否仍缺关键状态/节奏/构图
- 是否有不做项需要调整

没有批准不得进入 `/plan`。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 设计目标和 spec 冲突 | 回到 `define-workflow-refine` 修正目标或边界 |
| 无法判断是否需要 design | 以保守方式处理：需要 design |
| 设计稿开始写实现步骤 | 删除实现步骤，回到创作决策层 |
| 用户认为方向不对 | 保留已有判断，修改 `02-design.md` 后重新审查 |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| “先把代码写出来再调设计” | 这会把创作决策伪装成实现细节，返工更贵。 |
| “排版/剧本/交互都可以在 build 里顺手做” | 顺手做意味着没有阶段门，也没有定稿依据。 |
| “这只是小 UI，不需要设计” | 只要用户看得见、用得到，就可能需要先定主路径和状态。 |
| “设计就是把实现写详细一点” | 错。设计定方向，plan 才拆任务，build 才落实现。 |

## 红旗 — STOP

- 在没有批准 design 时开始拆 Task N
- 在 `02-design.md` 里写测试步骤、实现步骤或提交命令
- 把 API / schema / 服务架构决策塞进设计阶段
- 只讨论“好不好看”，不讨论用户路径、节奏、层级
- software 的 UI 任务没有任何设计稿就直接进 `/plan`

## 验证清单

- [ ] 已判断 design required / skipped
- [ ] required 时已生成 `02-design.md`
- [ ] `02-design.md` 包含 5 个固定章节
- [ ] 没有实现步骤或任务分解
- [ ] 用户已批准 design，或 skip 理由已明确记录
