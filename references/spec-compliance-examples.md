# Spec Compliance References — 补充材料

> `verify-workflow-spec-compliance` 的辅助参考。完整虚构示例和边界判断说明。

---

## 1. 需求提取示例

### Spec 原文片段

```
用户可以创建新任务，包含标题、描述和截止日期。
标题为空时显示错误提示。截止日期早于当前时间时警告用户。
网络请求失败时显示重试按钮。
创建任务后列表自动刷新。
```

### 提取结果

```markdown
### 功能需求
- [ ] [spec:L12] 用户可以创建新任务
- [ ] [spec:L34] 任务支持标题、描述、截止日期三个字段
- [ ] [spec:L56] 任务列表按创建时间倒序排列

### 边界条件
- [ ] [spec:L78] 标题为空时显示错误提示
- [ ] [spec:L90] 截止日期早于当前时间时警告用户

### 错误场景
- [ ] [spec:L102] 网络请求失败时显示重试按钮

### 验收标准
- [ ] [spec:L146] 创建任务后列表自动刷新
```

---

## 2. 逐项验证标记示例

```markdown
- [x] [spec:L12] 用户可以创建新任务
  → 实现: `src/tasks/TaskCreator.tsx:45-67`
  → 测试: `tests/tasks/TaskCreator.test.tsx:12-24`

- [ ] [spec:L34] 任务支持标题、描述、截止日期三个字段
  → 实现: `src/tasks/Task.ts:8-12` ⚠️ 缺少截止日期字段
  → 测试: 无对应测试

- [x] [spec:L56] 任务列表按创建时间倒序排列
  → 实现: `src/tasks/TaskList.tsx:89-91`
  → 测试: `tests/tasks/TaskList.test.tsx:34-42`
```

---

## 3. Scope Creep 标记示例

```markdown
- ⚠️ `src/tasks/TaskFilter.tsx` — spec 未提及任务过滤功能
  → 需要解释：这是必要的吗？还是应该移除？

- ✅ `src/tasks/utils/validateTask.ts` — 内部验证工具，支持 spec:L78 边界条件
  → 合理扩展
```

判断标准：
- **合理扩展** — 实现 spec 需求的必要支撑（内部工具函数、辅助类型）
- **Scope Creep** — spec 未要求的用户可见功能

---

## 4. 完复合规性报告示例（虚构 task-app）

```markdown
# Spec Compliance 审查报告

**Spec 文档:** `docs/features/20260501-task-app/01-spec.md`
**审查时间:** 2026-05-16 14:30
**审查结果:** 不通过

## 需求覆盖率

- 功能需求: 8/10 (80%)
- 边界条件: 4/5 (80%)
- 错误场景: 2/3 (67%)
- 验收标准: 6/8 (75%)

**总体覆盖率: 20/26 (77%)**

## 遗漏需求（Critical）

1. **[spec:L34] 任务支持截止日期字段**
   - 当前状态: Task 类型只有 title 和 description
   - 影响: 用户无法设置任务截止日期
   - 建议: 在 `src/tasks/Task.ts` 添加 `dueDate?: Date` 字段

2. **[spec:L90] 截止日期早于当前时间时警告用户**
   - 当前状态: 无对应验证逻辑
   - 影响: 用户可能设置过期的截止日期而不自知
   - 建议: 在 `src/tasks/TaskCreator.tsx` 添加日期验证

3. **[spec:L102] 网络请求失败时显示重试按钮**
   - 当前状态: 只显示错误消息，无重试机制
   - 影响: 用户遇到临时网络问题时需要刷新页面
   - 建议: 在 `src/tasks/TaskList.tsx` 添加重试按钮

## Scope Creep

1. **任务过滤功能** (`src/tasks/TaskFilter.tsx`)
   - 允许用户按状态、标签过滤任务
   - 问题: spec 未要求此功能，是否必要？

## 测试覆盖缺口

- [spec:L34] 任务支持三个字段 — 无测试
- [spec:L90] 截止日期验证 — 无测试
- [spec:L168] 200ms 响应时间 — 无性能测试

## 审查结论

**不通过** — 3 个 Critical 遗漏需求必须在合并前实现。

**下一步:**
1. 补齐遗漏的 3 个功能需求
2. 为所有验收标准添加测试
3. 解释或移除 Scope Creep 功能
4. 重新提交审查
```

---

## 5. Spec Compliance vs Code Quality 边界

| 问题 | 属于哪个审查 | 判断规则 |
|------|------------|---------|
| 函数没有处理 null 输入 | spec 要求 → Spec Compliance；未提及 → Code Quality | 是否在 spec 中 |
| 变量命名不清晰 | Code Quality（Readability 轴）| 与 spec 无关 |
| 功能缺少错误处理 | spec 要求 → Spec Compliance；未提及 → Code Quality | 是否在 spec 中 |
| 代码重复 | Code Quality（Architecture 轴）| 与 spec 无关 |

**原则**：spec 明确要求的 = Spec Compliance；spec 未提及但应该有的 = Code Quality。
