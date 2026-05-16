---
name: verify-team-skill-quality
description: Skill 质量审查与优化。当创建、修改、审查或压缩 Agent Skill、SKILL.md、技能 description、触发边界、STOP 条件、输出契约、progressive disclosure、trigger eval 或 task eval 时使用；不用于普通业务文档或仅消费现有技能的任务
---

# Skill Quality — Agent Skill 质量审查

## 入口/出口

- **入口**: 新增或修改中的 `SKILL.md`、技能辅助 `.md`、技能路由描述、触发样本或任务样本
- **出口**: 可路由、可加载、可验证、可维护的 Skill 合同；必要时同步 `skills-index.json`、`skills-router.json`、`skills-lock.json`
- **指向**: 通过 → 回到原阶段；不通过 → 退回修改 Skill 合同后重审
- **前置加载**: CANON.md；修改本仓库技能时还必须读取目标技能全文
- **输出路径**: Skill 质量报告可并入 `docs/features/<name>/04-review.md` 或当前任务的验证记录

## 何时不使用

- 用户只是要求解释某个业务概念，不涉及 Skill 创建、修改、路由或审查
- 用户只是要求使用现有 Skill 完成任务，没有发现 Skill 合同问题
- 目标是一般代码质量审查，应使用 `verify-quality-code-quality`
- 目标是项目文档质量，应使用 `reflect-team-documentation` 或内容审查技能

## Iron Law

<HARD-GATE>
Skill 是上下文路由合约，不是长提示词。
任何 Skill 修改必须回答四个问题：什么时候触发、触发后怎么做、什么时候停止、如何判断做对。
没有明确 description 触发边界、STOP 条件、输出契约和验证清单的 Skill 不得批准。
</HARD-GATE>

## 核心锚点

- **Context-Dense Skill**: 每个 token 都必须减少误触发、降低错误路径或提升执行稳定性。
- **Routing Contract**: description 说明何时必须加载和 near-miss 排除边界，不写成简介。
- **Progressive Disclosure**: 高频规则留在 `SKILL.md`；长案例、长 checklist、理论解释放辅助文件；确定性重复逻辑放 scripts。
- **Gotchas First**: 优先写本地规则、反直觉约束、失败案例和红旗，删除模型已知道的通用知识。
- **Output Contract**: 执行型和治理型 Skill 必须稳定输出结构，不能让 agent 自由发挥。
- **Eval-Driven Development**: description 和流程变更必须有 Trigger Eval 与 Task Eval 视角，至少覆盖 near-miss。

## 审查流程

### Step 1：定位 Skill 类型

先判断 Skill 改变哪类行为：

| 类型 | 用途 | 审查重点 |
|------|------|----------|
| 路由型 | 判断是否进入某类任务或分流 | description、near-miss、下一 Skill |
| 设计型 | 输出方案、结构、接口或架构 | 取舍、边界、验收标准 |
| 执行型 | 指导多步骤任务落地 | 步骤、验证点、失败处理 |
| 治理型 | 评审、审计、回归、质量控制 | STOP、评分、输出契约、回归样本 |

如果定位过宽，先收窄。宁可窄而稳，不要宽而虚。

### Step 2：审查 description

description 必须在 body 加载前完成路由判断。检查：

- 是否写明真实用户意图，而不是内部实现机制
- 是否包含典型触发词和隐含意图
- 是否排除 near-miss，例如“设计 API 合同”触发，“实现 API 代码”不触发
- 是否避免 “all backend development” 这类过度承诺

不合格 description 先修 description，再审正文。

### Step 3：删掉低密度内容

逐段提问：没有这段，agent 是否更容易做错？

删除：
- 通用概念解释
- 行业背景
- 重复规则
- 漂亮但不改变行为的原则
- 模型已经知道的基础最佳实践

保留：
- 触发边界
- 本地规则和 gotchas
- 禁止事项
- STOP 条件
- 输出模板
- 验证清单
- 兼容性、权限、回归约束

### Step 4：检查 STOP 与失败处理

Skill 必须说明何时停止：

- 缺少必要输入时停止并说明缺失项
- 范围不匹配时停止并转交相邻 Skill
- 用户只要求评审时不得直接修改
- 涉及生产、部署、删除、发送、支付、提交等副作用时必须有明确确认或阶段门
- 规则冲突时按用户最新指令、项目入口、安全约束和 CANON 裁决
- 无法验证结果时不得声称完成

### Step 5：检查输出契约和 Done When

输出契约至少包含：

```markdown
## 结论
## 判断依据
## 执行结果 / 设计方案 / 评审结果
## 风险与边界
## 验收清单
```

Done When 必须能被验证，不得写成“看起来合理”“基本完成”。

### Step 6：检查 progressive resources

- `SKILL.md` 放高频规则和硬门
- 辅助 `.md` 只放长模板、长示例、评分表、证据格式，并由主 `SKILL.md` 明确引用
- 重复确定性逻辑进入 scripts，而不是每次让 agent 重新推理
- 本仓库中辅助 `.md` 必须进入 `skills-lock.json` 的 `auxiliaryHashes`

### Step 7：检查 eval 样本

至少从两个角度审查：

- **Trigger Eval**: should-trigger 与 should-not-trigger 都覆盖；重点覆盖 near-miss、短输入、口语输入、隐含意图
- **Task Eval**: 包含 expected behavior、must include、must not include、done when

没有正式 eval 文件时，也必须在审查报告中列出代表性样本和结论。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| description 不能区分 near-miss | 先重写 description；不继续优化正文 |
| 正文主要是背景解释 | 删除低密度段落，改成本地规则、gotcha、流程和检查点 |
| 没有 STOP 条件 | 补缺少输入、范围不匹配、高风险副作用、无法验证四类 STOP |
| 没有输出契约 | 补固定模板和 Done When |
| 长内容塞在 `SKILL.md` | 拆到辅助 `.md`，主文件保留加载建议，并更新 lock |
| 重复机械逻辑靠模型推理 | 抽到 scripts，并实际运行脚本验证 |
| 只测典型触发 | 增加 should-not-trigger 和 near-miss 样本 |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| “写详细一点更安全” | 长不等于稳。低密度内容会挤占任务上下文。 | 触发后上下文膨胀，关键红旗反而被稀释 |
| “description 简短介绍即可” | description 是路由器，不是简介。 | 该触发时漏触发，不该触发时误触发 |
| “这些最佳实践模型都懂” | 模型懂通用知识，但不知道本项目的边界和失败案例。 | Skill 变成百科，无法稳定改变行为 |
| “eval 以后再补” | 没有样本就无法判断 description 是否真的路由准确。 | 每次修改都靠感觉，误触发回归无法发现 |
| “STOP 会让 agent 太保守” | STOP 是避免越权执行和虚假完成的安全边界。 | 缺输入、越范围或无法验证时继续执行，结果不可审计 |

## 红旗

<HARD-GATE>
以下任何一个出现，立即停止并要求修复：

- description 只解释“这个 Skill 是什么”，没有说明何时使用
- description 无法排除相邻 Skill 的 near-miss
- `SKILL.md` 大量解释通用概念，缺少本地规则或 gotchas
- 没有“何时不使用”或 STOP 条件
- 没有输出模板、Done When 或验证清单
- 修改技能后未同步 `skills-index.json`、`skills-router.json` 或 `skills-lock.json`
- 辅助 `.md` 未被主 `SKILL.md` 引用
- 机械重复逻辑没有脚本化，且已出现重复手写
- 无法验证却声称完成
</HARD-GATE>

## 验证清单

- [ ] Skill 类型已明确，范围窄而稳
- [ ] description 写明 should-trigger 和 near-miss 排除边界
- [ ] 低价值解释已删除或下沉到辅助文件
- [ ] 本地规则、gotchas、禁止事项和 STOP 条件清楚
- [ ] 输出契约和 Done When 可执行、可验证
- [ ] progressive disclosure 分层正确，辅助文件被主 `SKILL.md` 引用
- [ ] 重复确定性逻辑已脚本化或明确说明为什么不用脚本
- [ ] Trigger Eval 覆盖 should-trigger、should-not-trigger 和 near-miss
- [ ] Task Eval 覆盖 expected behavior、must include、must not include、done when
- [ ] 本仓库变更已运行 `scripts/generate-index.sh`、`scripts/generate-router.sh`、`scripts/update-lock.sh <skill>` 和 `./validate`；新增技能时 `update-lock.sh` 必须自动创建 lock entry

## 输出模板

```markdown
# Skill Quality Review — <skill-name>

## Verdict
- Status: PASS / FAIL
- Skill type: routing / design / execution / governance

## Routing
- Should trigger:
- Should not trigger:
- Near-miss risks:

## Contract Findings
| Severity | Area | Finding | Fix |
|----------|------|---------|-----|
| Blocking | Description | ... | ... |

## Eval Coverage
- Trigger eval samples:
- Task eval samples:
- Missing coverage:

## Done When
- [ ] description 路由准确
- [ ] STOP / Output Contract / Done When 齐全
- [ ] index / router / lock / validate 同步完成
```
