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

Allowed: software / document / article / deck / visual

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
