------
name: verify-workflow-review
description: 按产物类型审查。当软件、文档、文章、PPT 或视觉稿完成后需要质量把关，或提到"审查""review""质量检查"
argument-hint: "[--full | --focus: spec|code-quality|security|performance]"
---

# Review — 产物审查


## 入口/出口
- **入口**: 已完成的功能代码、即将合并的 PR
- **出口**: `docs/features/<name>/04-review.md` 审查报告
- **指向**: 通过 → `ship-workflow-ship`；有问题 → 退回 build 修复后重审
- **输出路径**: → ship-workflow-ship
- **前置加载**: CANON.md

## 何时不使用
- 代码在私有分支中还没准备好合入主分支
- 已有等价两阶段审查报告，且包含 Spec Compliance、质量评估和验证证据

## Iron Law

<HARD-GATE>
审查必须分两阶段：先 Spec Compliance（功能完整性），再 Code Quality（实现质量）。
功能不完整的代码不进入质量审查。
没有两阶段审查证据就不能批准合并。
`software` 必须覆盖 Spec Compliance + 五轴质量评估；非软件产物必须覆盖目标受众、内容/视觉质量、完整性和导出证据。
spec 或 plan 要求同步 project docs 时，`04-review.md` 必须显式记录 `Documentation Compliance`。项目级文档合同未兑现，不得批准合并。
实现者与审查者默认独立。除非命中 `trivial exemption`，否则标准变更起 Stage 2 必须由独立 reviewer persona 执行；高风险或 `--full` 时 Stage 1 和 Stage 2 都必须独立于 build implementer。
</HARD-GATE>

## Agent Dispatch Contract

`/review` 按独立性分为三档，阶段顺序不能被 persona 选择改变。

- `trivial exemption`：仅限单文件、纯文案/格式/注释或机械性重命名、无 UI/安全/schema/public API 风险的微小变更；允许 current agent 完成两阶段，但必须在 `04-review.md` 记录 `Exemption reason`
- `standard`：Stage 1 可由 current agent 或 `agents/review-spec-compliance-auditor.md` 执行；Stage 2 必须由独立的 `agents/review-code-quality-auditor.md` 执行
- `high-risk/full`：Stage 1 必须由 `agents/review-spec-compliance-auditor.md` 执行；Stage 2 必须由独立的 `agents/review-code-quality-auditor.md` 执行
- 如果当前 session 在本 feature 的 `/build` 中承担过 implementer，则除 `trivial exemption` 外，不能同时完成 Stage 1 和 Stage 2
- Stage 1 Spec Compliance：必须加载 `verify-workflow-spec-compliance`
- Stage 2 Code Quality：Stage 1 通过后执行；必须加载 `verify-quality-code-quality`
- 安全敏感追加 `agents/review-security-auditor.md`；测试覆盖不确定追加 `agents/review-test-engineer.md`；UI/a11y 风险追加 `agents/review-accessibility-auditor.md`
- 未被选中的 reviewer 不产出占位反馈；所有已选 reviewer 输出 Blocking / Important / Suggestion

## 流程

### Step 1：理解上下文

看代码前先理解意图：变更要达成什么？对应 spec/plan 的哪个部分？预期的行为变化是什么？

### Step 2：先看测试

测试揭示意图和覆盖：有测试吗？测行为不是实现细节？边界覆盖了？测试名称描述性？代码改了测试能捕获回归吗？

### Step 3：两阶段审查

先读取 spec 的 `artifact_type`：
- `software`（默认）→ 执行两阶段审查
- `document` / `article` / `deck` → 加载 `verify-content-review`
- `visual` → 加载 `verify-visual-review`

再判定独立性档位：
- `trivial exemption`：必须满足 Agent Dispatch Contract 的全部条件，并记录豁免理由
- `standard`：默认档位
- `high-risk/full`：敏感数据、认证授权、UI/a11y、公共 API、schema/migration、发布前审查或用户指定 `--full`

#### Step 3.1: Spec Compliance（第一关）

**REQUIRED SUB-SKILL:** `verify-workflow-spec-compliance`

检查：spec 每个需求都实现了吗？每个验收标准都有测试吗？有 scope creep 吗？

出口：所有 spec 需求有对应实现，无 Blocking 遗漏。不通过 → 退回 build，**不进入 Step 3.2**。

#### Step 3.2: Code Quality（第二关）

**前置：** Step 3.1 通过。

**REQUIRED SUB-SKILL:**
- `software` → `verify-quality-code-quality`
- `document/article/deck` → `verify-content-review`
- `visual` → `verify-visual-review`

Software 执行五轴审查：Correctness / Readability / Architecture / Security / Performance。详细标准见 `verify-team-code-review-standards`。出口：五轴全部覆盖，无 Blocking，Important ≤2。
build 阶段产生的 pre-review / implementation gate 结果只能作为输入线索，不能替代本阶段正式 Stage 1 / Stage 2 证据。

### Step 4：分类意见

| 前缀 | 含义 | 要求 |
|------|------|------|
| 无前缀 | 必须改 | 合并前必须处理 |
| **Critical:** | 阻塞合并 | 安全漏洞、数据丢失、功能崩溃 |
| **Nit:** | 可选 | 风格偏好，忽略 |
| **Consider:** | 建议 | 值得执行但不强制 |
| **FYI** | 仅供参考 | 不需要操作 |

### Step 5：验证验证者

检查提交者的验证证据：跑了什么测试？构建通过了吗？UI 变更截图了？前后对比？

### Step 5.2：检查审查独立性

在 `04-review.md` 明确记录：
- `Built by`
- `Stage 1 reviewed by`
- `Stage 2 reviewed by`
- `Independence status`
- `Exemption reason`

判定规则：
- `PASS`：满足当前独立性档位要求
- `FAIL`：标准或高风险变更未满足独立性要求
- `EXEMPT`：命中 `trivial exemption`，且理由具体可审计

### Step 5.5：检查文档合同兑现

如果 `01-spec.md` 的 `Documentation Impact` 声明 `project_truth_changed: yes` 或 `doc_intent != feature_only`：

- 检查 `03-plan.md` 是否包含 `Project Doc Sync Plan`
- 检查受影响的项目级文档是否已更新，或是否有明确的 defer 理由
- 在 `04-review.md` 写 `Documentation Compliance`
- `Required project docs updated: FAIL` 时，整体 verdict 不能是 APPROVED

## 两种审查模式

### 标准模式（默认）
按独立性档位执行两阶段审查。标准变更默认由 current agent 执行 Stage 1，再由独立 reviewer persona 执行 Stage 2。产出 `docs/features/<name>/04-review.md`。

### 并行发散模式（高风险 --full）
敏感数据、UI 变更、>50 行变更或 `--full` 时分派独立的 Spec / Quality / specialist reviewer。详细规则见 `review-guidance.md`。

## 审查标准

**批准：** 变更明确了改进了整体代码健康度，即使不完美。详细指南见 `review-guidance.md`。

## 审查分歧处理

当审查者和作者有分歧时：技术事实 > 风格指南 > 设计原则 > 代码库一致性。**不接受"之后清理"** — 合入前要求清理，除非真正紧急。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Critical 问题未解决 | 阻塞合并，退回 build 修复后重审 |
| 审查者与作者有分歧 | 按分歧层级裁决 |
| 变更过大（>1000行） | 要求拆分为多个 PR |
| 作者拒绝修改 | 升级到技术主管 |
| 测试不充分 | 要求补充边界/错误路径测试后再审 |
| 验证证据不足 | 要求补全测试结果、构建输出、UI 截图 |
| 独立性不满足 | `04-review.md` 标记 FAIL，补派独立 reviewer 后重审 |
| spec 要求同步 project docs 但未兑现 | 阻塞合并；回到 build 或 ship 前同步文档并重审 |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "它能跑就够了" | 能跑但不可读/不安全/架构错误的代码创造复利债务。 | 6 个月后修改同一模块从 1h 膨胀到 1 天 |
| "AI 生成的代码大概没问题" | AI 代码需要更多审查，不是更少。 | AI bug 隐蔽性高，未审查 AI 代码线上故障率高 2-3x |
| "测试过了所以是好的" | 测试不捕获架构/安全/可读性问题。 | 安全漏洞和架构腐化在测试通过前提下悄然积累 |
| "之后清理" | 之后永远不会来。 | 合入主干代码 90% 不会再被主动清理 |

**违反字面规则就是违反精神。** 没有灰色地带。

## 红旗

<HARD-GATE>
以下任何一个出现，立即停止并要求修复：

- PR 未经审查就合入
- 跳过 Spec Compliance 直接进入 Code Quality
- 功能不完整时进行质量审查
- 审查只检查测试是否通过（忽略其他维度）
- LGTM 而没有实际审查证据
- 安全敏感变更没有安全审查
- PR 太大无法审好（要求拆分）
- Bug fix PR 没有回归测试
- 审查意见没有严重级别标签
- 接受"之后清理"
- spec 说要同步 project docs，但 `04-review.md` 没有 `Documentation Compliance`
- 标准变更由 build implementer 独自完成 formal review 两阶段
</HARD-GATE>

## 验证清单

- [ ] 理解变更意图
- [ ] 已执行 Spec Compliance 审查（第一阶段）
- [ ] Spec Compliance 通过后已执行 Code Quality 审查（第二阶段）
- [ ] 非 software 产物已按 artifact_type 加载内容/视觉审查技能
- [ ] Blocking 问题已解决
- [ ] 测试通过
- [ ] 构建成功
- [ ] 审查独立性已记录；非 trivial exemption 时满足独立 reviewer 要求
- [ ] 文档同步合同已检查；需要同步 project docs 时已写 `Documentation Compliance`
- [ ] 验证故事已记录
- [ ] 审查产出存到 `docs/features/<name>/04-review.md`

## 输出模板

审查完成后，`04-review.md` 必须包含：

模板起点：`templates/feature/04-review.md`

```markdown
# [功能名称] — Review

## Artifact Type
artifact_type: [software/document/article/deck/visual]

## Review Independence
- Built by: [session / agent / person]
- Stage 1 reviewed by: [session / agent / person]
- Stage 2 reviewed by: [session / agent / person]
- Independence status: PASS / FAIL / EXEMPT
- Exemption reason: [specific reason or n/a]

## Stage 1: Spec Compliance
- Status: PASS / FAIL
- Coverage: [X/Y] requirements covered
- Blocking gaps: [list or none]

## Stage 2: Code Quality (if Stage 1 PASS)
- Correctness: [findings]
- Readability: [findings]
- Architecture: [findings]
- Security: [findings]
- Performance: [findings]

## Findings Summary
| # | Severity | Category | Description | File:Line | Status |
|---|----------|----------|-------------|-----------|--------|
| 1 | Blocking | Security | SQL injection in query | src/api.ts:42 | Open |

## Documentation Compliance
- Feature artifact chain complete: PASS / FAIL
- Project doc sync required by spec: yes / no
- Required project docs updated: PASS / FAIL
- Missing sync: [list or none]

## Verdict
- Overall: APPROVED / APPROVED_WITH_CONCERNS / REJECTED
- Blocking issues: [count]
- Important issues: [count]
- Merge condition: [all Blocking resolved + ≤2 Important remaining]
```

## 审查反馈后处理

审查完成后，实施反馈时参考 `verify-workflow-receiving-review` 技能，确保反馈被正确理解、分类和实施。
