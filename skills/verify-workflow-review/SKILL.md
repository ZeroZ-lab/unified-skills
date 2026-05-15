------
name: verify-workflow-review
description: 按产物类型审查。当软件、文档、文章、PPT 或视觉稿完成后需要质量把关
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
</HARD-GATE>

## Agent Dispatch Contract

`/review` 默认由 current agent 直接执行两阶段审查；高风险或 `--full` 时才分派 reviewer persona。阶段顺序不能被 persona 选择改变。

- Stage 1 Spec Compliance 可由 current agent 或 `agents/review-spec-compliance-auditor.md` 执行；必须加载 `verify-workflow-spec-compliance`。
- Stage 2 Code Quality 只能在 Stage 1 通过后执行，可由 current agent 或 `agents/review-code-quality-auditor.md` 执行；必须加载 `verify-quality-code-quality`。
- 安全敏感时追加 `agents/review-security-auditor.md`；测试覆盖不确定时追加 `agents/review-test-engineer.md`；UI/a11y 风险时追加 `agents/review-accessibility-auditor.md`。
- 未被风险规则选中的 reviewer 不产出占位反馈；所有已选 reviewer 输出 Blocking / Important / Suggestion。

### Step 1：理解上下文

看代码前先理解意图：
- 这个变更要达成什么？
- 对应 spec/plan 的哪个部分？
- 预期的行为变化是什么？

### Step 2：先看测试

测试揭示意图和覆盖：
- 有测试吗？
- 测试行为（不是实现细节）？
- 边界情况覆盖了？
- 测试名称描述性？
- 如果代码改了，测试能捕获回归吗？

### Step 3：两阶段审查

先读取 spec 的 `artifact_type`：
- `software`（默认）→ 执行下方两阶段审查
- `document` / `article` / `deck` → 加载 `verify-content-review`
- `visual` → 加载 `verify-visual-review`
- `deck` 若视觉复杂，同时加载 `verify-visual-review`

**对 software 产物，必须执行两阶段审查：**

#### Step 3.1: Spec Compliance 审查（第一关）

**REQUIRED SUB-SKILL:** 使用 `verify-workflow-spec-compliance`

检查功能完整性：
- spec 的每个需求都实现了吗？
- spec 的每个验收标准都有测试吗？
- 有没有实现 spec 之外的功能（scope creep）？

**出口条件:** 所有 spec 需求都有对应实现，且没有 Blocking 级别的遗漏。

**如果不通过:** 退回 build 阶段，补齐缺失功能后重新审查。**不进入 Step 3.2。**

**审查输出示例:**
```markdown
## Spec Compliance 审查结果

**状态:** 通过 / 不通过

### 需求覆盖率
- 功能需求: 10/10 (100%)
- 边界条件: 5/5 (100%)
- 错误场景: 3/3 (100%)
- 验收标准: 8/8 (100%)

**总体覆盖率: 26/26 (100%)**

### 遗漏需求（如有）
[列出所有 Blocking 和 Important 级别的遗漏]
```

---

#### Step 3.2: Code Quality 审查（第二关）

**前置条件:** Step 3.1 已通过（spec compliance ✅）

**REQUIRED SUB-SKILL:** 
- `artifact_type: software` → 使用 `verify-quality-code-quality`
- `artifact_type: document/article/deck` → 使用 `verify-content-review`
- `artifact_type: visual` → 使用 `verify-visual-review`

对 software 产物执行五轴审查：

1. **Correctness（逻辑正确性）**
   - 边界情况处理了？（null、空值、边界值）
   - 错误路径处理了？
   - 测试在测正确的东西？

2. **Readability（可读性）**
   - 命名描述性且一致？
   - 控制流直白？
   - 抽象值得其复杂度？

3. **Architecture（架构）**
   - 遵循现有模式或新模式有理由？
   - 保持模块边界清晰？
   - 没有循环依赖？

4. **Security（安全）**
   - 输入验证和转义？
   - 密钥没有留在代码/日志中？
   - Auth 检查到位？
   - SQL 参数化？

5. **Performance（性能）**
   - N+1 查询模式？
   - 无界循环或不受控数据获取？
   - 列表端点有分页？

**出口条件:** 五轴全部覆盖，无 Blocking 问题，Important 问题 ≤2 个。

**审查输出示例:**
完整模板见 `verify-quality-code-quality/report-template.md`。

### Step 4：分类意见

| 前缀 | 含义 | 要求 |
|------|------|------|
| 无前缀 | 必须改 | 合并前必须处理 |
| **Critical:** | 阻塞合并 | 安全漏洞、数据丢失、功能崩溃 |
| **Nit:** | 可选 | 风格偏好，忽略 |
| **Consider:** | 建议 | 值得执行但不强制 |
| **FYI** | 仅供参考 | 不需要操作 |

防止作者把所有反馈当作强制要求。

### Step 5：验证验证者

检查提交者的验证证据：
- 跑了什么测试？
- 构建通过了吗？
- UI 变更截图了？
- 前后对比？

## 两种审查模式

### 标准模式（默认）
当前会话中直接执行两阶段审查。产出审查报告到 `docs/features/<name>/04-review.md`。

**两阶段流程:**
1. 先执行 Spec Compliance 审查（功能完整性）
2. 只有通过第一阶段，才进入 Code Quality 审查（实现质量）
3. 两阶段都通过后，生成最终审查报告

### 并行发散模式（高风险 --full）

敏感数据、UI 变更、>50 行变更、>2 文件变更或用户指定 `--full` 时，可以派发专业审查 agent。具体触发条件、角色和反馈处理规则见 `review-guidance.md`。

## 审查标准

**批准标准：** 变更明确了改进了整体代码健康度，即使不完美。完美代码不存在——目标是持续改进。

变更大小、拆分策略、Dead Code、提交描述和依赖审查的详细指南见 `review-guidance.md`。

## 审查分歧处理

当审查者和作者有分歧时，按此顺序裁决：

1. **技术事实和数据** > 个人偏好和意见
2. **风格指南** > 风格问题上的绝对权威
3. **软件设计原则** > 个人偏好，不是个人品味
4. **代码库一致性** > 如果一致性不降低整体健康度，可以接受

**不接受 "之后清理"。** 经验表明延期的清理很少发生。合入前要求清理，除非是真正的紧急情况。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Critical 问题未解决 | 阻塞合并。标记为不可通过，退回 build 阶段修复后重审 |
| 审查者与作者有分歧 | 按分歧处理层级裁决：技术事实 > 风格指南 > 设计原则 > 一致性 |
| 变更过大（>1000行） | 要求作者拆分为多个 PR，先审查第一个切片 |
| 作者拒绝修改 | 升级到技术主管。审查者不妥协，也不放任问题合入 |
| 测试不充分 | 要求补充边界情况测试、错误路径测试后再审查 |
| 验证证据不足 | 要求补全测试结果、构建输出、UI 截图等证据 |

## 验证证据

输出或记录必须包含：
- **输入/来源**: 读取的 spec、plan、代码、反馈或发布上下文。
- **执行动作**: 实际完成的检查、生成、修复、导出或发布步骤。
- **验证结果**: 命令、审查结论、产物路径、截图或人工确认。
- **阻塞/回退**: 未通过项、回退路径或需要 human partner 决策的问题。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "它能跑就够了" | 能跑但不可读/不安全/架构错误的代码创造复利债务。 | 技术债按复利增长：6 个月后修改同一模块的时间从 1 小时膨胀到 1 天，团队速度持续下降。 |
| "AI 生成的代码大概没问题" | AI 代码需要更多审查，不是更少。自信且合理，即使错了。 | AI 生成的 bug 隐蔽性高——代码看起来合理但逻辑错误。未审查的 AI 代码线上故障率比人工代码高 2-3x。 |
| "测试过了所以是好的" | 测试不捕获架构问题、安全问题或可读性问题。 | 安全漏洞和架构腐化在测试通过的前提下悄然积累，累积到被发现时修复成本已 10x+。 |
| "之后清理" | 之后永远不会来。审查就是质量门。 | "之后"平均 = 永不。合入主干的代码 90% 不会再被主动清理，每轮迭代技术债增量沉淀。 |

**违反字面规则就是违反精神。** 没有灰色地带。

## 红旗

<HARD-GATE>
以下任何一个出现，立即停止并要求修复：

- PR 未经审查就合入
- 跳过 Spec Compliance 审查直接进入 Code Quality 审查
- 功能不完整时进行质量审查
- 审查只检查测试是否通过（忽略其他维度）
- LGTM 而没有实际审查证据
- 安全敏感变更没有安全审查
- PR 太大无法审好（要求拆分）
- Bug fix PR 没有回归测试
- 审查意见没有严重级别标签→作者无法区分必须改 vs 可选
- 接受"之后清理"
</HARD-GATE>

## 验证清单

- [ ] 理解变更意图
- [ ] 已执行 Spec Compliance 审查（第一阶段）
- [ ] Spec Compliance 审查通过后，已执行 Code Quality 审查（第二阶段）
- [ ] 非 software 产物已按 artifact_type 加载内容/视觉审查技能
- [ ] Blocking 问题已解决
- [ ] 测试通过
- [ ] 构建成功
- [ ] 验证故事已记录
- [ ] 审查产出存到 `docs/features/<name>/04-review.md`

## 好坏示例

### Good — 结构化两阶段审查 + 发现表
Stage 1 Spec Compliance：逐条检查 spec 需求覆盖率 100% ✓ → Stage 2 Code Quality：五轴审查产出 Findings Summary 表（Blocking/Important/Suggestion 分级，每条有文件:行号）。审查有证据，作者能按严重性排序修复。

### Bad — "看起来没问题" 无证据
"LGTM，代码写得挺清楚的。" — 没有 Spec Compliance 检查、没有五轴审查、没有发现表、没有严重性分级。作者无法区分必须改 vs 可选改，后续合并可能引入已知问题。

## 输出模板

审查完成后，`04-review.md` 必须包含以下结构（完整模板见 `verify-quality-code-quality/report-template.md`）：

```markdown
# [功能名称] — Review

## Artifact Type
artifact_type: [software/document/article/deck/visual]

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
| 2 | Important | Correctness | Missing null check | src/utils.ts:15 | Open |
| 3 | Suggestion | Readability | Variable name unclear | src/db.ts:28 | Deferred |

## Verdict
- Overall: APPROVED / APPROVED_WITH_CONCERNS / REJECTED
- Blocking issues: [count]
- Important issues: [count]
- Merge condition: [all Blocking resolved + ≤2 Important remaining]
```

## 审查反馈后处理

审查完成后，实施反馈时参考 `verify-workflow-receiving-review` 技能，确保反馈被正确理解、分类和实施，而非盲目接受或无视。
