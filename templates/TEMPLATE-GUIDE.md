# Template Guide

> Unified 模板族总规范。所有新增或修改模板都必须符合本文件定义的企业级约束。

## Purpose

本文件回答三个问题：

1. 什么叫“企业级 template”
2. Unified 的不同模板族各自负责什么
3. reviewer / validate 应该如何判断模板是否达标

## Template Families

| Family | Paths | Responsibility |
|--------|-------|----------------|
| feature | `templates/feature/*.md` | 单次 feature 的证据链模板 |
| bug | `templates/bug/*.md` | 单次问题定位与修复链模板 |
| root | `templates/root/*.md` | 项目根入口文档模板 |
| project | `templates/project/*.md` | 项目长期真相文档模板 |
| maintain | `templates/maintain/*.md` | session / maintenance 辅助模板 |

## Enterprise Template Standard

一个模板要被视为企业级，至少必须满足以下 8 条：

1. **Single Responsibility**
   - 模板只回答一个阶段或一类文档的核心问题
   - 不和相邻模板职责重叠

2. **Scan-First Opening**
   - 首屏必须可快速扫描
   - 至少有 `Status Summary` 或 `Document Status` 一类摘要块

3. **Stable Structure**
   - 章节名稳定，不允许同义标题漂移
   - 相同语义在不同模板中尽量使用同名字段

4. **Reviewable Fields**
   - 关键状态不能只写在 prose 中
   - 应使用显式字段，例如：`Owner`、`Status`、`Artifact Type`、`Verification`、`Risks`

5. **Required vs Conditional**
   - 模板必须清楚哪些区块始终需要
   - 哪些区块仅在特定场景启用

6. **Quality Gate**
   - 模板必须隐含或显式支持批准门
   - reviewer 应能判断“缺什么就不能过”

7. **Boundary Awareness**
   - 模板必须帮助作者理解“不该写什么”
   - 例如 project docs 不承载 feature 历史，review 不承载实现计划

8. **Human + Agent Readability**
   - 模板既要让 human partner 能看懂
   - 也要让 agent / validate 能稳定定位字段

## Common Required Fields

以下字段是企业级模板的默认基线。可根据 family 做裁剪，但不能完全缺失生命周期信息。

### Root / Project Templates
- `Owner`
- `Status`
- `Last reviewed` 或等价更新时间字段
- `Purpose`
- `Related docs` 或等价的导航入口

### Feature / Bug Templates
- `Owner`
- `Date`
- `Status`
- `artifact_type`（适用时）
- `Verification`
- `Risks` 或等价风险字段

## Family-Specific Rules

### Feature Templates
- 重点是变更证据链，不是长期真相
- 必须支持阶段流转：spec → design → plan → review → ship
- 需要时必须显式承载 `Documentation Impact`、`Project Doc Sync Plan`、`Documentation Compliance`、`Documentation Sync`

### Bug Templates
- 重点是 root cause 和 fix plan
- 不要演变成 feature scope 扩张文档

### Root Templates
- 重点是项目入口真相
- 不承载 feature 历史和长篇机制细节

### Project Templates
- 重点是长期有效的 WHY、边界、运行规则
- 必须避免把单次 feature 时间线写进正文

### Maintain Templates
- 重点是恢复、续接、短期运维支持
- 优先最小必要信息集，而不是完整日记

## Anti-Patterns

以下情况视为模板质量问题：

- 一个万能模板包打天下
- 只有 prose，没有结构化字段
- 没有状态块，读者要翻完整文档才知道是否有效
- feature docs 和 project docs 混层
- review / ship 模板缺少 verdict 或 sync 状态
- project template 没有 owner / last reviewed
- 用“后续补充”“视情况而定”代替明确章节职责

## Reviewer Checklist

- [ ] 模板职责是否单一
- [ ] 首屏是否可扫描
- [ ] 关键字段是否显式
- [ ] Required / Conditional 是否清楚
- [ ] 是否支持质量门判断
- [ ] 是否明确了边界
- [ ] 是否适合 human + agent 共同消费
- [ ] 是否与同 family 其他模板保持结构一致

## Validate Contract

`./validate` 至少应能检查：

- 模板文件是否存在
- 关键章节是否存在
- 模板族数量是否与当前合同一致
- 明确字段是否未被删掉
- 无历史过时说法或旧模板路径残留

## Change Policy

- 新增模板时，先更新本文件再新增模板
- 修改模板族数量时，必须同步 `validate`
- 模板结构改动影响技能消费时，必须同步相关 `SKILL.md`
