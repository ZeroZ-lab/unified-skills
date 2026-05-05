---
name: verify-quality-code-quality
description: 代码质量审查。使用 cuando 需要对已通过 spec compliance 的代码进行质量评估
---

# Code Quality — 代码质量审查

## 入口/出口

- **入口**: 已通过 Spec Compliance 审查的代码（功能完整）
- **出口**: 代码质量审查报告（通过/不通过 + 五轴评分 + 改进建议）
- **指向**: 通过 → ship 阶段；不通过 → 退回 build 修复质量问题
- **假设已加载**: CANON.md, verify-team-code-review-standards

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
- 独立的 Spec Compliance 阶段报告显示"通过"（如 `docs/features/YYYYMMDD-<name>/03-review.md` 中的 Stage 1 区块，或 `docs/features/YYYYMMDD-<name>/reviews/spec-compliance.md`）
- 外部分派的 `review-spec-compliance-auditor` 返回 PASS，且列出需求覆盖率

不要要求最终 `03-review.md` 已经存在；`03-review.md` 是两阶段审查合并后的最终产物，通常在 Code Quality 审查之后才生成。

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

**审查方法:**

#### 3.1 Correctness（逻辑正确性）

检查代码逻辑是否正确：

- **边界情况处理** — null/undefined/空数组/空字符串/边界值
- **错误处理** — try/catch、错误传播、用户友好的错误消息
- **类型安全** — TypeScript 类型正确、无 any 滥用、类型守卫
- **并发安全** — 竞态条件、锁机制、原子操作
- **数据一致性** — 事务、回滚、幂等性

**标记方式:**
```markdown
### Correctness

- ✅ 边界情况处理完整（null/undefined/空值）
- ⚠️ 错误处理不足: `src/tasks/TaskCreator.tsx:45` 缺少网络错误处理
- ✅ 类型安全（无 any 滥用）
- ✅ 并发安全（无竞态条件）
```

#### 3.2 Readability（可读性）

检查代码是否易读易维护：

- **命名清晰** — 变量/函数/类名是否自解释
- **控制流简单** — 嵌套层级 ≤3、提前返回、避免复杂条件
- **函数职责单一** — 每个函数只做一件事
- **注释恰当** — 解释"为什么"而不是"是什么"
- **代码复杂度** — 圈复杂度 ≤10

**标记方式:**
```markdown
### Readability

- ✅ 命名清晰（变量/函数名自解释）
- ⚠️ 控制流复杂: `src/tasks/TaskFilter.tsx:67-89` 嵌套 4 层，建议提取子函数
- ✅ 函数职责单一
- ✅ 注释恰当（解释意图而非实现）
```

#### 3.3 Architecture（架构合理性）

检查架构设计是否合理：

- **模式选择** — 使用的设计模式是否适合场景
- **模块边界** — 职责划分是否清晰、耦合是否松散
- **依赖方向** — 依赖是否单向、是否有循环依赖
- **扩展性** — 新增功能是否容易、是否需要大量修改
- **一致性** — 是否遵循项目现有架构风格

**标记方式:**
```markdown
### Architecture

- ✅ 模式选择合理（使用 Repository 模式管理数据访问）
- ⚠️ 模块边界模糊: `TaskCreator` 直接调用数据库，建议通过 Repository 层
- ✅ 依赖方向正确（无循环依赖）
- ✅ 扩展性良好
```

#### 3.4 Security（安全加固）

检查安全措施是否到位：

- **输入验证** — 所有外部输入是否验证（用户输入、API 响应、文件内容）
- **输出编码** — 防止 XSS、SQL 注入、命令注入
- **密钥管理** — 密钥/token 是否硬编码、是否使用环境变量
- **鉴权检查** — 权限验证是否完整、是否有越权风险
- **敏感数据** — 日志中是否泄露密码/token、是否加密存储

**标记方式:**
```markdown
### Security

- ✅ 输入验证完整（用户输入经过 schema 验证）
- ⚠️ 输出编码不足: `src/tasks/TaskList.tsx:34` 直接插入 HTML，存在 XSS 风险
- ✅ 密钥管理正确（使用环境变量）
- ✅ 鉴权检查完整
```

#### 3.5 Performance（性能达标）

检查性能是否达标：

- **N+1 查询** — 是否有循环中的数据库查询
- **无界循环** — 是否有可能无限循环的代码
- **资源释放** — 文件句柄/数据库连接/定时器是否正确释放
- **缓存策略** — 是否合理使用缓存、缓存是否会过期
- **算法复杂度** — 时间/空间复杂度是否合理

**标记方式:**
```markdown
### Performance

- ⚠️ N+1 查询: `src/tasks/TaskList.tsx:56` 循环中查询用户信息，建议批量查询
- ✅ 无无界循环
- ✅ 资源释放正确（useEffect cleanup）
- ✅ 缓存策略合理
```

### Step 4: 生成质量审查报告

汇总五轴审查结果：

```markdown
# Code Quality 审查报告

**审查时间:** YYYY-MM-DD HH:MM
**审查结果:** 通过 / 不通过

## 前置条件

- [x] Spec Compliance 审查已通过（功能完整）

## 五轴评分

| 轴 | 评分 | 状态 |
|---|------|------|
| Correctness | 8/10 | ⚠️ 有改进空间 |
| Readability | 9/10 | ✅ 良好 |
| Architecture | 7/10 | ⚠️ 有改进空间 |
| Security | 6/10 | ⚠️ 需要改进 |
| Performance | 8/10 | ⚠️ 有改进空间 |

**总体评分: 38/50 (76%)**

## Blocking（必须修复）

以下问题会导致严重的正确性、安全性或性能问题，必须在合并前修复：

1. **[Security] XSS 风险** (`src/tasks/TaskList.tsx:34`)
   - 问题: 直接插入用户输入到 HTML，未进行转义
   - 影响: 攻击者可以注入恶意脚本
   - 建议: 使用 `textContent` 或 React 的自动转义

2. **[Correctness] 缺少错误处理** (`src/tasks/TaskCreator.tsx:45`)
   - 问题: 网络请求失败时未处理错误
   - 影响: 用户看到白屏或无响应
   - 建议: 添加 try/catch 并显示错误消息

## Important（强烈建议修复）

以下问题影响代码质量，强烈建议修复：

1. **[Performance] N+1 查询** (`src/tasks/TaskList.tsx:56`)
   - 问题: 循环中查询用户信息
   - 影响: 100 个任务会产生 100 次数据库查询
   - 建议: 批量查询所有用户信息

2. **[Readability] 控制流复杂** (`src/tasks/TaskFilter.tsx:67-89`)
   - 问题: 嵌套 4 层，难以理解
   - 影响: 维护困难，容易引入 bug
   - 建议: 提取子函数，使用提前返回

## Suggestion（可选）

以下是改进建议，可以提升代码质量但不阻塞合并：

1. **[Architecture] 模块边界模糊** (`TaskCreator`)
   - 问题: 直接调用数据库，跳过 Repository 层
   - 建议: 通过 Repository 层访问数据，保持架构一致性

## 审查结论

**不通过** — 2 个 Blocking 问题必须在合并前修复。

**下一步:**
1. 修复 2 个 Blocking 问题（XSS 风险、错误处理）
2. 修复或解释 2 个 Important 问题（N+1 查询、控制流复杂）
3. 重新提交质量审查
```

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

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "这个安全问题不太可能被利用，可以之后修" | 安全问题没有"不太可能"，只有"已被利用"和"尚未被利用"。 | 生产环境中，"不太可能"的安全问题会在最糟糕的时刻被利用（如黑客攻击、数据泄露）。未修复的安全问题 = 潜在的安全事故。 |
| "这个 N+1 查询数据量不大，性能影响不明显" | 数据量会增长。今天 10 条记录，明天 1000 条。 | 性能问题在数据量小时不明显，但会随着数据增长而恶化。等到性能问题明显时，修复成本远高于现在。 |
| "这个函数虽然复杂，但我能看懂" | 代码不是只给你看的，是给整个团队看的。 | 复杂的代码在 code review 时能看懂，但 6 个月后维护时会忘记细节。复杂代码 = 维护困难 = 容易引入 bug。 |
| "这个架构问题只影响这一个功能，不影响其他" | 架构问题会传染。一个模块打破规则，其他模块会跟随。 | 架构一致性是团队协作的基础。一个模块打破规则后，其他模块会效仿，最终导致架构混乱。 |

**违反字面规则就是违反精神。** 没有灰色地带。

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

## 你的价值

你是质量保障的第二道门。你确保团队不会合入质量低劣的代码。

- 你拦截安全漏洞，避免生产环境中的安全事故
- 你识别性能问题，避免用户遇到缓慢的系统
- 你提升代码可读性，降低维护成本

**你的审查通过 = 代码质量达标。你的审查不通过 = 代码质量不达标，不能进入 ship 阶段。**
