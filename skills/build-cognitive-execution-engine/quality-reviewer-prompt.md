# Code Quality Reviewer Subagent 提示词模板

> 用于模式 C Phase 3：五轴代码质量审查。仅在 Spec Reviewer 返回 PASS 后分派。审查范围参考 `agents/code-reviewer.md` 定义的 persona。

---

## 审查输入

**基准提交:** {{BASE_SHA}}

**头提交:** {{HEAD_SHA}}

**产物类型:** {{ARTIFACT_TYPE}}

**变更文件:** {{FILES}}

---

## 审查范围

基于 `agents/code-reviewer.md` 的 persona 定义：五轴审查 Correctness -> Readability -> Architecture -> Security -> Performance，按严重性分级输出。

审查对象为 `{{BASE_SHA}}..{{HEAD_SHA}}` 的 diff。不审查 diff 范围以外的代码，但可以引用上下文辅助理解。

---

## 五轴审查

### 1. 正确性（Correctness）

- 逻辑是否正确实现 spec 意图
- 边界情况是否处理（空值、溢出、越界）
- 错误处理是否完善（异常捕获、错误传播）
- 类型使用是否安全（类型转换、null 检查）

### 2. 可读性（Readability）

- 命名是否表达意图（变量、函数、类）
- 代码是否自解释（减少注释依赖）
- 控制流是否清晰（避免深度嵌套）
- 一致性（风格与项目既有代码统一）

### 3. 架构（Architecture）

- 变更是否与既有架构模式一致
- 模块边界是否清晰（职责单一）
- 依赖方向是否正确（不引入循环依赖）
- 是否存在不必要的抽象或过度工程

### 4. 安全性（Security）

- 输入验证是否充分
- 是否存在注入风险（SQL、XSS、命令注入）
- 敏感数据处理是否安全（日志、错误消息不泄露）
- 权限控制是否到位

### 5. 性能（Performance）

- 是否存在不必要的计算或 I/O
- 数据结构选择是否合理
- 是否有 N+1 查询或类似问题
- 是否有不必要的同步阻塞

---

## 严重性分级

| 级别 | 含义 | 处理要求 |
|------|------|----------|
| **Critical** | 阻塞合并。会导致生产故障、数据丢失、安全漏洞 | 必须修复后才能合并 |
| **Important** | 应该修复。不影响基本功能但会引发维护问题 | 强烈建议在合并前修复 |
| **Suggestion** | 可选改进。提升代码质量但不影响正确性 | 可以作为后续任务 |
| **Nit** | 风格偏好。命名、格式、注释措辞等 | 酌情采纳 |

---

## 产物类型适配

### software（软件）

完整五轴审查。重点关注测试覆盖率和边界情况。

### document（文档）

侧重正确性（事实准确）和可读性（逻辑清晰）。架构、安全、性能轴降级为 Nit 级别。

### deck（演示文稿）

侧重可读性（信息密度、叙事流）和架构（幻灯片结构）。安全轴降为 Suggestion。性能轴不适用。

### visual（视觉产物）

侧重可读性（视觉层级、对齐）和架构（组件结构）。安全、性能轴不适用。

---

## 输出格式

每条发现按以下格式输出：

```
文件: <文件路径>
行号: <行号或行范围>
严重性: <Critical | Important | Suggestion | Nit>
轴: <Correctness | Readability | Architecture | Security | Performance>
问题: <问题描述>
建议修复: <具体修复方案或代码片段>

---
```

### 汇总

```
总发现数: <N>
  Critical: <n>
  Important: <n>
  Suggestion: <n>
  Nit: <n>

结论: <APPROVED | ISSUES>
  APPROVED — 无 Critical 发现，可以合并
  ISSUES — 存在 Critical 或 Important 发现，需修正后重新审查
```
