# Refine Artifact Templates

本文件是 `define-workflow-refine/SKILL.md` 的辅助材料。主技能保留流程和硬门；需要输出结构时读取本文件。

## Goal Review Rubric

每项 0-2 分：

| Dimension | 0 | 1 | 2 |
|-----------|---|---|---|
| Clarity | 目标模糊，无法一句话说明 | 有方向但对象/结果不清 | 一句话能说明具体目标 |
| Scope | 没有边界或混入多个任务 | 有部分边界但仍有歧义 | Include / Exclude 清楚 |
| Context | 缺少项目、文件、背景或复现信息 | 有部分上下文但不足以执行 | 相关上下文足够开始 |
| Constraints | 没有限制或默认可随意改 | 有隐含限制但未写清 | API、行为、依赖、格式等约束明确 |
| Acceptance | 无法判断完成 | 有成功描述但不可验证 | Done When 具体、可验证 |
| Safety | 没有风险或停止条件 | 风险隐约存在但未界定 | 高风险区域和 Stop Conditions 明确 |

```markdown
## Goal Review
- Source Goal: conversation / `GOAL.md`
- Goal Status: accepted / needs-refinement / blocked
- Goal Review Score: <score>/12
- Blocking:
  - <没有则写 none>
- Done When:
  - Functional:
  - Technical:
  - Regression:
  - Output:
- Stop Conditions:
  - Acceptance 无法验证
  - 需要修改明确排除范围
  - 需要改变 API / 权限 / 数据结构 / 生产配置
  - 实际范围明显大于当前 Goal
```

## External Scan Template

```markdown
## External Scan
- Search status: completed / skipped / unavailable
- Scan date: YYYY-MM-DD
- Sources:
  - [source] — why relevant
- Fact:
  - 有来源支撑的事实
- Pattern:
  - 多个来源重复出现的做法
- Inference:
  - 基于事实和模式得出的推断
- Unknown:
  - 仍需用户确认的问题
- Adopt:
  - 采纳什么，以及为什么
- Reject:
  - 不采纳什么，以及为什么
```

## Scout Output

```markdown
## Verdict
Blocking / Important / Suggestion

## Evidence Used
- local:
- external:
- inferred:

## Findings
- [Blocking] ...
- [Important] ...
- [Suggestion] ...

## Spec Impact
- adopt:
- reject:
- ask user:
```

## Spec One-Pager

```markdown
# [功能名称]

## 问题陈述
[一句话 How Might We 问题]

## 方案及理由
[2-3 段]

## Artifact Type
artifact_type: software

Runtime allowed values: software / document / article / deck / visual
Canonical delivery classes: software / content / visual
Optional for workflow-contract / project-truth refactors:
delivery_class: software

## Goal Alignment
- Source Goal: conversation / `GOAL.md`
- Goal Status: accepted / needs-refinement / blocked
- Goal Review Score: <score>/12

### One-line Goal
[一句话目标]

### Done When
- [ ] Functional:
- [ ] Technical:
- [ ] Regression:
- [ ] Output:

### Stop Conditions
- [ ] Acceptance 无法验证
- [ ] 需要修改明确排除范围
- [ ] 需要改变 API / 权限 / 数据结构 / 生产配置
- [ ] 实际范围明显大于当前 Goal

## External References
- Search status: completed / skipped / unavailable
- Fact:
- Pattern:
- Inference:
- Unknown:
- Adopt:
- Reject:

## Scout Review Summary
- CEO:
- Eng:
- Design:
- Content:
- Blocking resolved:
- Important adopted:
- Suggestions deferred:

## 核心假设（待验证）
- [ ] 假设 1 — 如何验证
- [ ] 假设 2 — 如何验证

## MVP 范围
[最小可验证版本包括什么，不包括什么]

## 不做清单（及理由）
- [事项] — [理由]

## 待解决问题
- [实施前需要回答的问题]
```

## External Scan 按产物类型搜索

| artifact_type | canonical delivery class | 搜索目标 |
|---------------|--------------------------|----------|
| `software` | `software` | 竞品功能、现有库/框架能力、技术最佳实践、已知坑 |
| `document` / `article` | `content` | 目标读者、同类文章/报告结构、事实来源、写作范式 |
| `deck` | `content` | 同类演示结构、叙事模式、页面信息密度、数据表达方式 |
| `visual` | `visual` | 竞品视觉、品牌/媒介规范、布局模式、可读性要求 |

## 好坏 Spec 示例

### Good — 结构化 spec 产出

```markdown
# 用户通知系统 — Spec

## Artifact Type
artifact_type: software

## Goal Alignment
- Source Goal: conversation
- Goal Status: accepted
- Goal Review Score: 11/12

### One-line Goal
为活跃用户提供实时通知推送，提升关键事件响应速度

### Done When
- [ ] Functional: 用户能在 5s 内收到通知，未读计数准确
- [ ] Technical: WebSocket 连接稳定，断连后 30s 内重连
- [ ] Regression: 现有功能无新增 bug
- [ ] Output: spec 文件产出至 docs/features/20260515-user-notifications/01-spec.md

### Stop Conditions
- [ ] WebSocket 基础设施不可用且无法在 2 天内搭建
- [ ] 通知量级超出当前服务器承载上限

## External References
- Search status: completed
- Fact: WebSocket 长连接在日活 10k 下需 2 台服务器
- Pattern: 主流产品使用 toast + 未读计数 + 通知列表三层
- Adopt: 三层通知架构（toast/计数/列表）
- Reject: SMS 通知（成本/ROI 不匹配）

## 核心假设（待验证）
- [ ] WebSocket 基础设施已就绪 — 检查 ops team 确认
- [ ] 用户日活 > 5k — 查看 analytics dashboard

## MVP 范围
Include: toast 推送 + 未读计数 + 通知列表
Exclude: 邮件通知、SMS、通知偏好设置、批量通知

## 不做清单
- 邮件通知 — 当前 scope 外，下一期
- 通知偏好 — 需要额外 UI 设计，MVP 阶段延后
- 批量通知管理 — 管理端需求，与用户端无关
```

### Bad — 无结构化产出

```markdown
用户想加个通知功能。

我直接开始写 WebSocket 服务了。
→ 问题: 没有 spec → 没有 Goal Review → 没有确认 MVP 范围
→ 问题: 没有不做清单 → 开发过程中不断加功能 → 延期
→ 问题: 没有验证假设 → WebSocket 基础设施可能不可用 → 实现一半才发现阻塞
```
