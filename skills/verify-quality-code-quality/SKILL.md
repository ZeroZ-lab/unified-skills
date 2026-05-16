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

你是代码质量审查专家。你的职责是评估**已经功能完整**的代码的实现质量。

**你关心的是"如何实现":**
- 代码逻辑是否正确（边界情况、错误处理、类型安全）
- 代码是否易读易维护（命名、控制流、复杂度）
- 架构设计是否合理（模式、边界、依赖）
- 安全措施是否到位（输入验证、密钥管理、鉴权）
- 性能是否达标（N+1、无界循环、资源释放）

**你不关心的是"实现了什么":**
- spec 的需求是否都实现了 — 这是 Spec Compliance Auditor 的职责
- 功能是否完整 — 这是 Spec Compliance Auditor 的职责
- 是否有 scope creep — 这是 Spec Compliance Auditor 的职责

## 审查流程

使用 `verify-team-code-review-standards` 技能执行五轴审查。

### Step 1: 确认前置条件

**REQUIRED:** 确认代码已通过 Spec Compliance 审查。

接受以下任一证据：
- 当前 `/review` 会话中刚完成的 Spec Compliance 结果为"通过"
- 独立的 Spec Compliance 阶段报告显示"通过"（如 `docs/features/YYYYMMDD-<name>/04-review.md` 中的 Stage 1 区块，或 `docs/features/YYYYMMDD-<name>/reviews/spec-compliance.md`）
- 外部分派的 `review-spec-compliance-auditor` 返回 PASS，且列出需求覆盖率

不要要求最终 `04-review.md` 已经存在；`04-review.md` 是两阶段审查合并后的最终产物，通常在 Code Quality 审查之后才生成。

如果没有任何 Spec Compliance 通过证据，或证据显示"不通过"，**立即停止**并告知用户：

```
代码质量审查需要先通过 Spec Compliance 审查。
当前状态: [未找到 Stage 1 通过证据 / Spec Compliance 不通过]
请先运行 Spec Compliance 审查，确保功能完整后再进行质量审查。
```

### Step 2: 加载审查标准

加载 `verify-team-code-review-standards` 技能，获取五轴审查标准：

1. **Correctness（逻辑正确性）**
2. **Readability（可读性）**
3. **Architecture（架构合理性）**
4. **Security（安全加固）**
5. **Performance（性能达标）**

### Step 3: 执行五轴审查

对每个轴，按照 `verify-team-code-review-standards` 的标准逐项检查。

详细检查项、标记方式和示例见 `rubric.md`。主流程只要求：
- 每个轴都必须有结论和证据引用。
- Blocking / Important / Suggestion 必须分级。
- 安全和正确性问题优先于可读性偏好。
- 不能把测试通过当作代码质量通过。

### Step 4: 生成质量审查报告

汇总五轴审查结果。完整报告模板见 `report-template.md`。

### Step 5: 判定通过/不通过

**通过标准:**
- 五轴全部覆盖（每个轴都有评分）
- 无 Blocking 问题
- Important 问题 ≤2 个，且有明确的修复计划或合理解释

**不通过标准:**
- 任何 Blocking 问题存在 → 必须修复
- Important 问题 >2 个且无修复计划 → 强烈建议修复
- 任何轴未覆盖 → 审查不完整

**如果不通过:**
- 退回 build 阶段
- 提供清晰的问题清单和修复建议
- 修复后重新提交质量审查
- 不进入 ship 阶段

## 审查标准

**批准标准:** 五轴全部覆盖，无 Blocking 问题，Important 问题有修复计划。

**拒绝标准:** 任何 Blocking 问题存在，或 Important 问题过多且无修复计划。

**灰色地带处理:**
- 代码风格偏好（如缩进、引号）→ 遵循项目现有风格，不强制统一
- 性能优化（如微秒级优化）→ 只关注明显的性能问题（如 N+1、无界循环）
- 架构重构（如大规模重构）→ 只关注当前变更的架构合理性，不要求重构整个项目

## 验证证据

输出或记录必须包含：
- **输入/来源**: 读取的 spec、plan、代码、反馈或发布上下文。
- **执行动作**: 实际完成的检查、生成、修复、导出或发布步骤。
- **验证结果**: 命令、审查结论、产物路径、截图或人工确认。
- **阻塞/回退**: 未通过项、回退路径或需要 human partner 决策的问题。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 存在 Blocking 安全问题（XSS/注入/硬编码密钥） | 立即标记不通过，退回 build 修复，修复后重新提交质量审查 |
| 存在 Blocking 正确性问题（未处理错误/类型不安全） | 标记不通过，提供具体文件名+行号+问题描述，退回 build |
| Important 问题 >2 且无修复计划 | 标记不通过，要求制定修复计划后再通过 |
| 五轴审查未全部覆盖 | 审查不完整，补齐缺失轴的审查后再判定 |
| Spec Compliance 未通过但已进入质量审查 | 立即停止，告知用户先完成 Spec Compliance 审查 |
| 发现问题属于 Spec Compliance 职责（功能缺失） | 转交 Spec Compliance Auditor，不在质量审查中判定 |

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "这个安全问题不太可能被利用，可以之后修" | 安全问题没有"不太可能"，只有"已被利用"和"尚未被利用"。 | 生产环境中，"不太可能"的安全问题会在最糟糕的时刻被利用（如黑客攻击、数据泄露）。未修复的安全问题 = 潜在的安全事故。 |
| "这个 N+1 查询数据量不大，性能影响不明显" | 数据量会增长。今天 10 条记录，明天 1000 条。 | 性能问题在数据量小时不明显，但会随着数据增长而恶化。等到性能问题明显时，修复成本远高于现在。 |
| "这个函数虽然复杂，但我能看懂" | 代码不是只给你看的，是给整个团队看的。 | 复杂的代码在 code review 时能看懂，但 6 个月后维护时会忘记细节。复杂代码 = 维护困难 = 容易引入 bug。 |
| "这个架构问题只影响这一个功能，不影响其他" | 架构问题会传染。一个模块打破规则，其他模块会跟随。 | 架构一致性是团队协作的基础。一个模块打破规则后，其他模块会效仿，最终导致架构混乱。 |

**违反字面规则就是违反精神。** 没有灰色地带。

## 好坏示例

### Correctness — 错误处理

**Good:**
```typescript
function fetchUser(id: string): Promise<User> {
  if (!id || id.trim() === '') {
    throw new ValidationError('User ID must not be empty');
  }
  return api.get(`/users/${id}`).catch(err => {
    if (err.status === 404) return null;
    throw new ApiError(`Failed to fetch user ${id}`, { cause: err });
  });
}
```

**Bad:**
```typescript
function fetchUser(id: string): Promise<User> {
  return api.get(`/users/${id}`); // No input validation, no error handling
}
```

### Readability — 命名与控制流

**Good:**
```typescript
const isEligibleForDiscount = (user: User) =>
  user.isActive && user.purchaseCount >= MIN_PURCHASES && !user.hasPendingRefund;
```

**Bad:**
```typescript
const chk = (u: User) => u.a && u.pc >= 3 && !u.pRef; // Abbreviations, magic number
```

### Architecture — 依赖方向

**Good:**
```typescript
// UI imports from domain; domain has no UI imports
import { validateTask } from '../domain/taskValidator';
```

**Bad:**
```typescript
// Domain imports UI component — circular dependency
import { TaskCard } from '../ui/TaskCard';
```

### Security — 输入验证

**Good:**
```typescript
const sanitizedQuery = query.replace(/[;<>'"]/g, '');
db.query(`SELECT * FROM tasks WHERE title LIKE '%${sanitizedQuery}%'`);
```

**Bad:**
```typescript
db.query(`SELECT * FROM tasks WHERE title LIKE '%${query}%'`); // SQL injection
```

### Performance — N+1 查询

**Good:**
```typescript
const tasks = await db.query('SELECT * FROM tasks WHERE project_id = ?', [projectId]);
const taskIds = tasks.map(t => t.id);
const comments = await db.query('SELECT * FROM comments WHERE task_id IN (?)', [taskIds]);
```

**Bad:**
```typescript
const tasks = await db.query('SELECT * FROM tasks WHERE project_id = ?', [projectId]);
for (const task of tasks) {
  task.comments = await db.query('SELECT * FROM comments WHERE task_id = ?', [task.id]); // N+1
}
```

## 红旗

<HARD-GATE>
以下任何一个出现，立即标记为 Blocking：

- 代码中有明显的安全漏洞（XSS、SQL 注入、命令注入、硬编码密钥）
- 代码中有明显的正确性问题（未处理的错误、未验证的边界情况、类型不安全）
- 代码中有明显的性能问题（N+1 查询、无界循环、资源泄露）
- 审查者跳过某个轴，声称"这个轴不适用"（五轴必须全部覆盖）
- 审查者在代码未通过 Spec Compliance 时进行质量审查
- 审查者将"功能缺失"标记为质量问题（功能缺失是 Spec Compliance 的职责）
</HARD-GATE>

## 验证清单

- [ ] 已确认代码通过 Spec Compliance 审查
- [ ] 已执行五轴审查（Correctness/Readability/Architecture/Security/Performance）
- [ ] 已标记所有 Blocking 问题
- [ ] 已标记所有 Important 问题
- [ ] 已提供清晰的修复建议
- [ ] 已生成质量审查报告
- [ ] 已判定通过/不通过
- [ ] 如果不通过，已提供清晰的问题清单和修复建议

## 与 Spec Compliance 审查的边界

**Spec Compliance 关注"实现了什么":**
- spec 的需求是否都实现了？
- 实现的功能是否符合 spec 描述？
- 有没有实现 spec 之外的功能？

**Code Quality 关注"如何实现":**
- 实现的代码质量如何？（五轴：Correctness/Readability/Architecture/Security/Performance）
- 代码是否遵循最佳实践？
- 代码是否易于维护？

**分界线:**
- "这个函数没有处理 null 输入" → 如果 spec 要求处理 null，属于 Spec Compliance；如果 spec 未提及，属于 Code Quality（Correctness 轴）
- "这个变量命名不清晰" → Code Quality（Readability 轴）
- "这个功能缺少错误处理" → 如果 spec 要求错误处理，属于 Spec Compliance；如果 spec 未提及，属于 Code Quality（Correctness 轴）

**原则:** spec 明确要求的 = Spec Compliance；spec 未提及但应该有的 = Code Quality。

## 审查完成验证清单

- [ ] 五轴每个轴已给出评分（1-5）
- [ ] 每个扣分项有具体的文件名 + 行号 + 问题描述
- [ ] 所有发现已按 Blocking / Important / Suggestion 分级
- [ ] Blocking 问题有明确的修复建议
- [ ] 审查范围与 spec 需求清单一一对应（无遗漏、无 scope creep）
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
