---
name: verify-workflow-spec-compliance
description: 功能完整性审查。当需要验证代码是否实现了 spec 的所有需求，或提到"spec compliance""功能完整性""需求覆盖"
---

# Spec Compliance — 功能完整性审查

## 入口/出口
- **入口**: 已完成的功能代码、即将合并的 PR、对应的 spec 文档
- **出口**: spec 合规性审查报告（通过/不通过 + 遗漏清单）
- **指向**: 通过 → `verify-quality-code-quality`；不通过 → 退回 build 补齐功能
- **前置加载**: CANON.md
- **输出路径**: `docs/features/YYYYMMDD-<name>/04-review.md`（合规性部分） → verify-quality-code-quality（通过时）或 build-workflow-execute（不通过时退回补齐）
- **辅助参考**: `references/spec-compliance-examples.md`（需求提取示例、验证标记示例、完整虚构报告、边界判断说明）

## 何时不使用
- 没有对应 spec 文档的代码变更（无法验证功能完整性）
- 代码还在开发中，未声称完成（不应进入审查阶段）

## Iron Law

<HARD-GATE>
spec 中的每个需求必须在代码中找到对应实现。
spec 中的每个验收标准必须有对应测试。
未实现的需求 = 不完整的功能 = 不能通过审查。
实现了 spec 之外的功能 = scope creep = 需要解释或退回。
100% 覆盖率是通过的唯一标准。
</HARD-GATE>

## 核心锚点

### Traceability Matrix

每个 spec 需求必须建立 spec 行号 → 代码实现 → 测试 的可追溯链。

**执行规则：**
- 需求分四类提取：功能需求（"系统应该"）、边界条件（"当…时"）、错误场景（"失败时"）、验收标准（"验证…确保…"）
- 每条需求标记 `[spec:LXX]` + 实现文件路径 + 测试文件路径
- 完整示例见 `references/spec-compliance-examples.md` §1-2

### Coverage-Gated Review

100% 覆盖是通过的唯一标准。任何缺口 = 不通过。

**执行规则：**
- 功能需求缺失 → Critical，必须修复
- 边界条件缺失 → Critical，必须修复
- 错误场景缺失 → Important，强烈建议修复
- 验收标准缺少测试 → Critical，必须修复
- 不通过时退回 build，提供遗漏清单和修复建议，不进入 code quality

### Scope Creep Detection

任何代码中实现但 spec 未提及的用户可见功能 = scope creep。

**执行规则：**
- 检查范围：新增 API 端点、UI 组件、数据库表/字段、配置选项
- 合理扩展（内部工具函数、辅助类型）→ 标记通过
- Scope Creep（用户可见功能）→ 要求 human partner 判断：必要则修改 spec 收入，不必要则移除

### Spec-Code Boundary

spec 明确要求的 = Spec Compliance（本技能）；spec 未提及但应该有的 = Code Quality（`verify-quality-code-quality`）。

**执行规则：**
- "函数没处理 null" → spec 要求处理 null = Spec Compliance；spec 未提及 = Code Quality
- 灰色地带（实现方式与 spec 不一致但效果相同、spec 描述模糊）→ 标记差异，由 human partner 判断

## 流程

### Step 1：定位 spec 文档

标准路径：`docs/features/YYYYMMDD-<name>/01-spec.md`；Bug 修复：`docs/bugs/<name>/01-root-cause.md` + `02-fix-plan.md`。找不到 spec 时询问用户或要求先创建 spec。

Checkpoint：spec 文档已定位。

### Step 2：提取需求清单（Traceability Matrix）

逐行读取 spec，按四类提取所有需求，每条标记 `[spec:LXX]`。

Checkpoint：所有功能需求、边界条件、错误场景、验收标准已提取，无遗漏。

### Step 3：逐项验证实现

对每个需求在代码中查找对应实现。功能需求搜函数/组件/API；边界条件查 if/guard；错误场景查 try/catch；验收标准查测试。

Checkpoint：每条需求已标记 实现路径 + 测试路径。

### Step 4：Scope Creep 检查

检查代码中 spec 未提及的用户可见功能。

Checkpoint：每个 scope creep 项已标记 + 判断理由。

### Step 5：生成报告 + 判定

汇总覆盖率，按 Coverage-Gated Review 判定通过/不通过。

Checkpoint：报告已生成，判定结果明确，不通过时有遗漏清单和修复建议。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "功能基本实现了，细节之后补" | "基本实现"= 不完整。spec 是契约。 | "之后补"平均 = 永不；用户遇到缺失功能时紧急修复成本 10x |
| "边界情况很少见，可以不处理" | 边界条件是 spec 明确要求的。 | "很少见"的边界在最糟时刻爆发（演示、发布） |
| "测试之后补，先合代码" | 没有测试 = 无法验证正确性。 | "之后补测试"的代码 90% 永远不会有测试 |
| "spec 没写但用户肯定需要" | 未经批准的功能 = scope creep。 | 可能与产品方向冲突；合入后移除成本远高于合入前讨论 |

## 红旗 — STOP

<HARD-GATE>
- spec 的功能需求在代码中找不到对应实现
- spec 的边界条件在代码中没有处理逻辑
- spec 的验收标准没有对应测试
- 代码实现了 spec 未提及的用户可见功能，且无解释
- 审查者声称"功能基本实现"但实际有遗漏
- 审查者跳过某些需求，声称"不重要"或"之后补"
</HARD-GATE>

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 功能需求覆盖率 < 100% | 退回 build，提供遗漏清单和修复建议 |
| 边界条件缺失 | Critical — 必须在合并前实现 |
| 验收标准缺少测试 | Critical — 补写测试后才可通过 |
| Scope Creep 未解释 | human partner 判断：收入 spec 或移除代码 |
| spec 描述模糊无法验证 | 暂停审查，澄清 spec 后再继续 |
| 实现方式与 spec 不一致 | 标记差异，human partner 判断 |

## 好坏示例

### Good — 结构化合规清单 + spec→代码映射

逐条提取 spec 需求，每条标注 spec 行号、代码实现位置、测试位置。覆盖率 100% 才通过；遗漏项有修复建议和影响说明。

### Bad — "代码能跑就行"

跳过逐条对照，声称"功能基本实现"但实际有遗漏。无 spec→代码映射，无覆盖率计算，遗漏的边界条件和验收标准在生产以 bug 形式爆发。

完整虚构报告示例见 `references/spec-compliance-examples.md` §4。

## 输出模板

```markdown
### Spec Compliance — <feature-name>

**Spec**: [01-spec.md 路径] | **时间**: [YYYY-MM-DD] | **结果**: PASS / FAIL

**覆盖率**: 功能 [X/Y] | 边界 [X/Y] | 错误 [X/Y] | 验收 [X/Y] | **总 [X/Y]**

**遗漏（Critical）**:
| # | spec 行号 | 需求 | 状态 | 影响 | 建议 |
|---|----------|------|------|------|------|
| 1 | [L12] | [需求] | [缺失] | [影响] | [建议] |

**Scope Creep**: [列表 / 无] | **测试缺口**: [列表 / 无]
**下一步**: [通过 → code quality / 不通过 → 回 build 补齐]
```

## 验证清单

- [ ] spec 文档已定位
- [ ] 所有需求（功能/边界/错误/验收）已提取并标记行号
- [ ] 每条需求已验证代码实现和测试
- [ ] Scope Creep 已检查并判断
- [ ] 覆盖率已计算（目标 100%）
- [ ] 合规性报告已生成
- [ ] 通过/不通过已判定；不通过时遗漏清单和修复建议已提供
