---
name: verify-quality-code-quality
description: 代码质量审查。当需要对已通过 spec compliance 的代码进行质量评估，或提到"代码质量""重构""质量审查"
---

# Code Quality — 代码质量审查

## 入口/出口

- **入口**: 已通过 Spec Compliance 审查的代码（功能完整）
- **出口**: 代码质量审查报告（通过/不通过 + 五轴评分 + 改进建议）
- **指向**: 通过 → ship 阶段；不通过 → 退回 build 修复质量问题
- **前置加载**: CANON.md, verify-team-code-review-standards
- **输出路径**: `docs/features/YYYYMMDD-<name>/04-review.md`（质量审查部分） → ship-workflow-ship（通过时）或 build-workflow-execute（不通过时退回修复质量问题）

## 何时不使用

- 代码尚未通过 Spec Compliance 审查（功能不完整时不进入质量审查）
- 非软件产物（document/article/deck/visual 使用对应的 content-review 或 visual-review）

## Iron Law

<HARD-GATE>
代码质量审查只在 Spec Compliance 通过后进行。
功能不完整的代码不进入质量审查阶段。
质量审查关注"如何实现"，不关注"实现了什么"。
五轴（Correctness/Readability/Architecture/Security/Performance）必须全部覆盖。
</HARD-GATE>

## 核心职责

评估**已经功能完整**的代码的实现质量。关心：逻辑正确性、可读性、架构合理性、安全措施、性能。不关心：spec 需求覆盖（Spec Compliance 职责）、功能完整性（Spec Compliance 职责）、scope creep（Spec Compliance 职责）。

## 审查流程

使用 `verify-team-code-review-standards` 技能执行五轴审查。

### Step 1: 确认前置条件

确认代码已通过 Spec Compliance。接受以下证据：当前 `/review` 中刚完成的结果、`04-review.md` 中的 Stage 1 区块、或外部分派 auditor 的 PASS。不要要求 `04-review.md` 已存在（它通常是两阶段合并后的最终产物）。

无证据或不通过时，立即停止并告知用户先完成 Spec Compliance。

### Step 2: 加载审查标准

加载 `verify-team-code-review-standards`，获取五轴标准：Correctness / Readability / Architecture / Security / Performance。

### Step 3: 执行五轴审查

按 `verify-team-code-review-standards` 逐项检查。详细检查项见 `rubric.md`。要求：
- 每个轴必须有结论和证据引用
- Blocking / Important / Suggestion 必须分级
- 安全和正确性问题优先于可读性偏好
- 不能把测试通过当作代码质量通过

### Step 4: 生成报告 + 判定

汇总五轴审查结果。完整报告模板见 `report-template.md`。

**通过：** 五轴全部覆盖 + 无 Blocking + Important ≤2 且有修复计划。
**不通过：** 有 Blocking 或 Important >2 无修复计划 → 退回 build 修复。
**灰色地带：** 代码风格遵循项目现有风格；性能只关注明显问题（N+1、无界循环）；架构只关注当前变更合理性，不要求重构整个项目。

## 验证证据

输出或记录必须包含：输入/来源、执行动作、验证结果、阻塞/回退。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Blocking 安全问题（XSS/注入/硬编码密钥） | 立即不通过，退回 build 修复 |
| Blocking 正确性问题（未处理错误/类型不安全） | 不通过，提供文件名+行号+问题描述 |
| Important >2 且无修复计划 | 不通过，要求制定修复计划 |
| 五轴未全部覆盖 | 审查不完整，补齐后再判定 |
| Spec Compliance 未通过但已进入质量审查 | 立即停止 |
| 发现问题属于 Spec Compliance 职责 | 转交 Spec Compliance Auditor |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "这个安全问题不太可能被利用" | 安全问题没有"不太可能"，只有"已被利用"和"尚未被利用"。 | 在最糟糕时刻被利用。未修复 = 潜在安全事故 |
| "N+1 查询数据量不大" | 数据量会增长。今天 10 条，明天 1000 条。 | 等性能问题明显时修复成本远高于现在 |
| "这个函数虽然复杂，但我能看懂" | 代码是给整个团队看的。 | 6 个月后维护时忘记细节，复杂代码 = 维护困难 = 容易引入 bug |
| "架构问题只影响这一个功能" | 架构问题会传染。一个模块打破规则，其他会跟随。 | 最终导致架构混乱 |

**违反字面规则就是违反精神。** 没有灰色地带。

## 与 Spec Compliance 的边界

spec 明确要求的 = Spec Compliance；spec 未提及但应该有的 = Code Quality。例："函数没处理 null" → spec 要求 = Spec Compliance；spec 未提及 = Code Quality（Correctness 轴）。

## 红旗

<HARD-GATE>
以下任何一个出现，立即标记为 Blocking：

- 代码中有明显的安全漏洞（XSS、SQL 注入、命令注入、硬编码密钥）
- 代码中有明显的正确性问题（未处理的错误、未验证的边界、类型不安全）
- 代码中有明显的性能问题（N+1 查询、无界循环、资源泄露）
- 审查者跳过某个轴，声称"不适用"
- 审查者在代码未通过 Spec Compliance 时进行质量审查
- 审查者将"功能缺失"标记为质量问题
</HARD-GATE>

## 验证清单

- [ ] 已确认代码通过 Spec Compliance 审查
- [ ] 已执行五轴审查（Correctness/Readability/Architecture/Security/Performance）
- [ ] 已标记所有 Blocking 问题
- [ ] 已标记所有 Important 问题
- [ ] 已提供清晰的修复建议
- [ ] 已生成质量审查报告
- [ ] 已判定通过/不通过

## 审查完成验证清单

- [ ] 五轴每个轴已给出评分（1-5）
- [ ] 每个扣分项有具体的文件名 + 行号 + 问题描述
- [ ] 所有发现已按 Blocking / Important / Suggestion 分级
- [ ] Blocking 问题有明确的修复建议
- [ ] 审查范围与 spec 需求清单一一对应
- [ ] 安全相关发现已转交 verify-quality-security（如有）

## 输出模板

完整报告模板见 `verify-quality-code-quality/report-template.md`。

```markdown
### Code Quality Report — <feature-name>

**五轴评分**:
| 轴 | 评分 (1-5) | 关键发现 |
|----|-----------|---------|
| Correctness | [N] | [具体问题] |
| Readability | [N] | [具体问题] |
| Architecture | [N] | [具体问题] |
| Security | [N] | [具体问题] |
| Performance | [N] | [具体问题] |

**Findings Summary**:
| # | Severity | Category | Description | File:Line | Status |
|---|----------|----------|-------------|-----------|--------|
| 1 | Blocking | [轴] | [问题] | [位置] | Open |

**Verdict**: APPROVED / APPROVED_WITH_CONCERNS / REJECTED
```
