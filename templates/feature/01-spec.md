# <Feature Name> — Spec

## Artifact Type
`artifact_type: software`

可选值：`software` / `document` / `article` / `deck` / `visual`。默认 `software`。

## Goal Alignment
- Source Goal: conversation / `GOAL.md`
- Goal Status: accepted / needs-refinement / blocked
- Goal Review Score: `<score>/12`

### One-line Goal
[用一句话写清本次目标。必须具体、可执行、可验证。]

### Done When
- [ ] Functional: <用户可观察的结果>
- [ ] Technical: <测试、构建、导出或质量门>
- [ ] Regression: <不应被破坏的旧行为>
- [ ] Output: <最终需要交付的说明、文件或证据>

### Stop Conditions
- [ ] Acceptance 无法验证
- [ ] 需要修改明确排除范围
- [ ] 需要改变 API / 权限 / 数据结构 / 生产配置
- [ ] 实际范围明显大于当前 Goal

## 问题
[为什么要做？解决了什么痛点？现状是什么？]

## 选定方案
[架构概览、核心思路，约 200 字]

## External References
- Search status: completed / skipped / unavailable
- Scan date: YYYY-MM-DD
- Fact:
  - <有来源支撑的事实>
- Pattern:
  - <多个来源重复出现的模式>
- Inference:
  - <基于事实和模式得出的推断>
- Unknown:
  - <仍需用户确认的问题>
- Adopt:
  - <采纳什么，以及为什么>
- Reject:
  - <不采纳什么，以及为什么>

## Scout Review Summary
- CEO:
- Eng:
- Design:
- Blocking resolved:
- Important adopted:
- Suggestions deferred:

## 未选择的方案
- 方案 A: <描述> → 放弃原因
- 方案 B: <描述> → 放弃原因

## 验收标准
- [ ] 可验证的标准 1
- [ ] 可验证的标准 2

## Scope 边界
- **做:** 功能 A、功能 B
- **不做:** 功能 C（留给未来）、功能 D（超出范围）
