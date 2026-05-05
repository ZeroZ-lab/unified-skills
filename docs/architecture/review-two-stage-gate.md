# 两阶段审查门控设计

## 动机

Superpowers 的 subagent-driven-development 采用两阶段审查：
1. Spec Reviewer — 验证功能完整性
2. Code Quality Reviewer — 验证实现质量

这种分离有三个优势：
- **关注点分离** — 功能正确性和代码质量是两个独立维度
- **早期拦截** — 功能不完整时不浪费时间做质量审查
- **清晰反馈** — 明确告诉开发者是"功能缺失"还是"质量不达标"

Unified 原有的 `verify-workflow-review` 将功能完整性检查和代码质量检查混合在"Correctness 轴"中，导致：
- 审查者需要同时关注"实现了什么"和"如何实现"
- 功能不完整时仍然进行质量审查，浪费时间
- 反馈不够清晰（功能缺失和质量问题混在一起）

## 设计

### 第一关：Spec Compliance（功能完整性）

**职责:** 验证代码是否实现了 spec 的所有需求。

**检查维度:**
- 功能需求覆盖率 — spec 的每个功能需求都有对应实现
- 边界条件处理 — spec 要求的边界条件都有对应处理逻辑
- 错误场景路径 — spec 要求的错误场景都有对应路径
- 验收标准测试 — spec 的每个验收标准都有对应测试
- Scope Creep 检测 — 识别代码中实现了但 spec 未提及的功能

**通过标准:**
- 所有功能需求都有对应实现（100%）
- 所有边界条件都有对应处理（100%）
- 所有错误场景都有对应路径（100%）
- 所有验收标准都有对应测试（≥90%）
- 无未解释的 Scope Creep

**不通过标准:**
- 任何功能需求缺失 → Blocking
- 任何边界条件缺失 → Blocking
- 任何错误场景缺失 → Important
- 验收标准测试覆盖 <90% → Important
- 有未解释的 Scope Creep → Suggestion

**输出:**
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

**如果不通过:** 退回 build 阶段，补齐缺失功能后重新审查。**不进入第二关。**

---

### 第二关：Code Quality（实现质量）

**前置条件:** 第一关已通过（功能完整）

**职责:** 评估代码的实现质量。

**检查维度（五轴）:**

1. **Correctness（逻辑正确性）**
   - 边界情况处理（null/undefined/空值/边界值）
   - 错误处理（try/catch、错误传播、用户友好的错误消息）
   - 类型安全（TypeScript 类型正确、无 any 滥用）
   - 并发安全（竞态条件、锁机制）

2. **Readability（可读性）**
   - 命名清晰（变量/函数/类名自解释）
   - 控制流简单（嵌套层级 ≤3、提前返回）
   - 函数职责单一
   - 注释恰当（解释"为什么"而不是"是什么"）

3. **Architecture（架构合理性）**
   - 模式选择合理
   - 模块边界清晰
   - 依赖方向正确（无循环依赖）
   - 扩展性良好

4. **Security（安全加固）**
   - 输入验证（所有外部输入都验证）
   - 输出编码（防止 XSS、SQL 注入、命令注入）
   - 密钥管理（无硬编码、使用环境变量）
   - 鉴权检查（权限验证完整、无越权风险）

5. **Performance（性能达标）**
   - 无 N+1 查询
   - 无无界循环
   - 资源正确释放（文件句柄/数据库连接/定时器）
   - 缓存策略合理

**通过标准:**
- 五轴全部覆盖（每个轴都有评分）
- 无 Blocking 问题
- Important 问题 ≤2 个，且有明确的修复计划或合理解释

**不通过标准:**
- 任何 Blocking 问题存在 → 必须修复
- Important 问题 >2 个且无修复计划 → 强烈建议修复
- 任何轴未覆盖 → 审查不完整

**输出:**
```markdown
## Code Quality 审查结果

**状态:** 通过 / 不通过

### 五轴评分
| 轴 | 评分 | 状态 |
|---|------|------|
| Correctness | 9/10 | ✅ 良好 |
| Readability | 8/10 | ✅ 良好 |
| Architecture | 9/10 | ✅ 良好 |
| Security | 10/10 | ✅ 优秀 |
| Performance | 8/10 | ✅ 良好 |

**总体评分: 44/50 (88%)**

### Blocking 问题（如有）
[列出所有必须修复的问题]

### Important 问题（如有）
[列出所有强烈建议修复的问题]
```

**如果不通过:** 退回 build 阶段，修复质量问题后重新审查。

---

## 两阶段的边界

### Spec Compliance 关注"实现了什么"

- spec 的需求是否都实现了？
- 实现的功能是否符合 spec 描述？
- 有没有实现 spec 之外的功能？

### Code Quality 关注"如何实现"

- 实现的代码质量如何？（五轴：Correctness/Readability/Architecture/Security/Performance）
- 代码是否遵循最佳实践？
- 代码是否易于维护？

### 分界线示例

| 问题 | 归属 | 原因 |
|------|------|------|
| "spec 要求的任务过滤功能没有实现" | Spec Compliance | 功能缺失 |
| "任务过滤的实现代码可读性差" | Code Quality | 实现质量 |
| "spec 要求处理空标题，但代码中没有验证逻辑" | Spec Compliance | spec 明确要求的边界条件 |
| "空标题验证逻辑应该用更优雅的方式实现" | Code Quality | 实现方式 |
| "这个函数没有处理 null 输入" | 取决于 spec | 如果 spec 要求处理 null → Spec Compliance；如果 spec 未提及 → Code Quality（Correctness 轴） |

**原则:** spec 明确要求的 = Spec Compliance；spec 未提及但应该有的 = Code Quality。

---

## 实现

### 技能结构

```
verify-workflow-review (调度器)
├── verify-workflow-spec-compliance (第一关)
│   └── agents/review-spec-compliance-auditor.md
└── verify-quality-code-quality (第二关)
    └── agents/review-code-quality-auditor.md
```

### 调用流程

```
/review 命令
  ↓
verify-workflow-review
  ↓
Step 3.1: Spec Compliance 审查
  ↓ (如果通过)
Step 3.2: Code Quality 审查
  ↓ (如果通过)
生成最终审查报告
```

### 审查报告结构

```markdown
# 审查报告

## Spec Compliance 审查结果

**状态:** 通过

### 需求覆盖率
- 功能需求: 10/10 (100%)
- 边界条件: 5/5 (100%)
- 错误场景: 3/3 (100%)
- 验收标准: 8/8 (100%)

**总体覆盖率: 26/26 (100%)**

---

## Code Quality 审查结果

**状态:** 通过

### 五轴评分
| 轴 | 评分 | 状态 |
|---|------|------|
| Correctness | 9/10 | ✅ 良好 |
| Readability | 8/10 | ✅ 良好 |
| Architecture | 9/10 | ✅ 良好 |
| Security | 10/10 | ✅ 优秀 |
| Performance | 8/10 | ✅ 良好 |

**总体评分: 44/50 (88%)**

---

## 最终结论

**审查结果:** 通过

**下一步:** 可以进入 ship 阶段
```

---

## 与现有流程的兼容性

### 小型变更（<50 行、无安全敏感）

可以合并两阶段为单次审查：
- 快速检查功能完整性（口头确认）
- 重点关注代码质量（五轴）
- 生成简化的审查报告

### 标准变更

必须执行两阶段：
1. 先执行 Spec Compliance 审查
2. 通过后执行 Code Quality 审查
3. 生成完整的审查报告

### 大型变更（>300 行）

建议使用并行发散模式：
- Spec Compliance Auditor（1 个 subagent）
- Code Quality Auditor（1 个 subagent）
- Security Auditor（1 个 subagent，安全敏感时）
- Accessibility Auditor（1 个 subagent，有 UI 变更时）

---

## 优势

### 1. 关注点分离

审查者可以专注于单一维度：
- Spec Compliance Auditor 只关心"实现了什么"
- Code Quality Auditor 只关心"如何实现"

### 2. 早期拦截

功能不完整时，立即退回 build 阶段：
- 不浪费时间做质量审查
- 开发者明确知道问题是"功能缺失"

### 3. 清晰反馈

审查报告分为两部分：
- Spec Compliance 结果 — 功能完整性
- Code Quality 结果 — 实现质量

开发者可以清楚地知道：
- 是功能不完整？还是质量不达标？
- 需要补齐哪些功能？还是需要改进哪些质量问题？

### 4. 可扩展性

两阶段设计为未来扩展留下空间：
- 可以增加更多专业审查角色（如 Performance Auditor、Architecture Auditor）
- 可以为不同产物类型定制审查流程（如 document、visual）

---

## 常见问题

### Q: 为什么不能跳过 Spec Compliance 直接进入 Code Quality？

A: 功能不完整时做质量审查是浪费时间。代码质量再好，功能不完整也无法合并。

### Q: 小型变更也需要两阶段审查吗？

A: 小型变更（<50 行、无安全敏感）可以合并两阶段为单次审查，但仍需要检查功能完整性和代码质量。

### Q: 如果 spec 没有明确要求某个边界条件，但代码中应该处理，算 Spec Compliance 还是 Code Quality？

A: 算 Code Quality（Correctness 轴）。Spec Compliance 只检查 spec 明确要求的内容。

### Q: 两阶段审查会增加审查时间吗？

A: 不会。两阶段审查只是将原有的审查流程拆分为两个阶段，总时间不变。但可以早期拦截功能不完整的代码，避免浪费时间做质量审查。

---

## 参考

- `skills/verify-workflow-review/SKILL.md` — 两阶段调度器
- `skills/verify-workflow-spec-compliance/SKILL.md` — Spec Compliance 审查技能
- `skills/verify-quality-code-quality/SKILL.md` — Code Quality 审查技能
- `agents/review-spec-compliance-auditor.md` — Spec Compliance 审查角色
- `agents/review-code-quality-auditor.md` — Code Quality 审查角色
- `commands/review.md` — /review 命令说明
