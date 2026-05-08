# 质量保障体系全面改进总结

## 改进动机

基于对 xiaomi-de,p 项目和 Superpowers 的对比分析，发现三个改进方向：

1. **审查流程需要两阶段分离** — 当前 `verify-workflow-review` 的 Correctness 轴混合了"功能完整性检查"（spec compliance）和"代码质量检查"（边界情况、错误处理），缺少 Superpowers 式的两阶段审查门控（Spec Compliance → Code Quality）

2. **Plan 代码示例应该更简洁** — 当前 plan 包含完整代码实现（类似 xiaomi-de,p 的 1500+ 行 plan），这适合单次执行，但不适合 subagent 迭代模式。Superpowers 采用"最小示例 + 注释说明"，给执行 agent 更多推理空间

3. **Plan 自审流程需要更系统** — 当前有 6 项自审检查（spec 覆盖、占位符、类型一致性、subplans 完整性、并行安全性、收口顺序），但缺少对"任务独立性"、"验证步骤完整性"的显式检查

## 实施的变更

### 1. 审查流程两阶段拆分

**新增技能:**
- `verify-workflow-spec-compliance` — 功能完整性检查（268 行）
- `verify-quality-code-quality` — 代码质量检查（342 行）

**新增角色:**
- `review-spec-compliance-auditor` — Spec 合规性审查专家

**重命名角色:**
- `review-code-reviewer` → `review-code-quality-auditor` — 代码质量审查专家

**重构技能:**
- `verify-workflow-review` — 改为两阶段调度器（331 行）
  - Step 3.1: Spec Compliance 审查（第一关）
  - Step 3.2: Code Quality 审查（第二关）
  - 只有通过第一关，才能进入第二关

**更新文档:**
- `commands/review.md` — 增加两阶段审查流程说明
- `skills-index.json` — 注册新技能到 verify 阶段
- `load-manifest.json` — 增加 spec-compliance 和 code-quality 任务类型
- `docs/architecture/review-two-stage-gate.md` — 新增两阶段审查设计文档

**Iron Law 更新:**
```markdown
<HARD-GATE>
审查必须分两阶段：先 Spec Compliance（功能完整性），再 Code Quality（实现质量）。
功能不完整的代码不进入质量审查。
没有两阶段审查证据就不能批准合并。
</HARD-GATE>
```

### 2. Plan 代码示例风格调整

> **历史文档 — 本文反映引入 `03-plan.md` 之前的旧合同。**
>
> 当文中提到 `templates/feature/02-plan.md` 时，请按历史背景理解。当前真相以 `AGENTS.md`、`README.md`、现行模板和现行技能为准；当前计划模板已迁移到 `templates/feature/03-plan.md`。

**修改技能:**
- `build-workflow-plan` — Step 5 增加代码示例风格原则（424 行）

**新增指导原则:**
- 最小示例包含：函数签名、意图注释、边界条件提示、与 spec 的对应关系
- 最小示例不包含：完整实现逻辑、具体算法细节、所有边界情况处理
- 例外情况使用完整代码：复杂算法、精确数据结构、关键安全逻辑、非软件产物

**更新模板:**
- `templates/feature/02-plan.md` — 任务模板改为"最小示例 + 意图注释"风格

**示例对比:**

**旧风格（完整代码）:**
```typescript
function targetFunction(input: InputType): ReturnType {
  if (!input) throw new Error('Invalid input');
  const result = processInput(input);
  return formatResult(result);
}
```

**新风格（最小示例 + 意图注释）:**
```typescript
function targetFunction(input: InputType): ReturnType {
  // 1. 验证输入（null/undefined/边界值）
  // 2. 执行核心逻辑（参考 spec 第 X 节）
  // 3. 返回符合 spec 的结果格式
}
```

### 3. Plan 自审流程强化

**修改技能:**
- `build-workflow-plan` — Step 7 从 6 项扩展到 10 项检查

**新增自审项:**

#### 7.7 任务独立性
- 每个任务有明确的验收标准
- 每个任务有独立的验证步骤（不依赖后续任务）
- 任务之间的依赖关系已明确标注

#### 7.8 验证步骤完整性
- 具体的验证命令（带参数）
- 预期的输出或结果
- 失败时的诊断方法

#### 7.9 代码示例风格
- 没有完整实现逻辑（除非是复杂算法/安全逻辑/非软件产物）
- 有关键步骤的意图注释
- 有边界条件和错误处理的提示

#### 7.10 任务粒度
- 单个任务不超过 5 个文件
- 单个任务的步骤数在 3-7 个之间
- 任务标题中没有 "and"（有则拆分）

## 向后兼容性

- **现有 plan 文档仍然有效** — 完整代码风格仍被接受，新风格是推荐而非强制
- **小型变更可以合并两阶段审查** — <50 行、无安全敏感的变更可以单次审查
- **所有变更遵循 CANON.md 宪法** — 没有放松任何纪律，只是增加了更细粒度的检查

## 验证结果

- ✅ `./validate` 通过
- ✅ 所有技能格式正确
- ✅ 无循环依赖
- ✅ Iron Law 和 HARD-GATE 格式正确
- ✅ 47 个技能哈希校验通过
- ✅ 版本号已更新到 2.10.0

## 技能统计

- **总技能数:** 47 个（新增 2 个）
- **总角色数:** 22 个（新增 1 个，重命名 1 个）
- **总命令数:** 11 个（无变化）
- **总代码行数:** 9823 行

## 改进效果预期

### 1. 审查质量提升
- 功能遗漏在第一阶段被拦截（不进入质量审查）
- 审查反馈更清晰（明确是"功能缺失"还是"质量不达标"）
- 审查者可以专注于单一维度（关注点分离）

### 2. Plan 可执行性提升
- 执行 agent 有更多推理空间（不被完整代码限制）
- Plan 文档更简洁（减少 30-50% 的代码行数）
- 代码示例更关注"方向和约束"而不是"具体实现"

### 3. Plan 质量提升
- 占位符数量减少（自审第 2 项）
- 任务独立性提升（自审第 7 项）
- 验证步骤完整性提升（自审第 8 项）
- 任务粒度更合理（自审第 10 项）

## 实施任务清单

- [x] Task 1: 创建 Spec Compliance 审查技能
- [x] Task 2: 创建 Code Quality 审查技能
- [x] Task 3: 重构 verify-workflow-review 为两阶段调度器
- [x] Task 4: 更新审查命令和索引
- [x] Task 5: 创建两阶段审查设计文档
- [x] Task 6: 调整 build-workflow-plan 的代码示例指导
- [x] Task 7: 更新 Plan 模板示例
- [x] Task 8: 扩展 build-workflow-plan 的自审清单
- [x] Task 9: 更新 CLAUDE.md 文档
- [x] Task 10: 运行完整验证
- [x] Task 11: 创建改进总结文档

## 参考文档

- `docs/architecture/review-two-stage-gate.md` — 两阶段审查设计文档
- `skills/verify-workflow-spec-compliance/SKILL.md` — Spec Compliance 审查技能
- `skills/verify-quality-code-quality/SKILL.md` — Code Quality 审查技能
- `skills/verify-workflow-review/SKILL.md` — 两阶段调度器
- `skills/build-workflow-plan/SKILL.md` — Plan 生成技能（含新自审清单）
- `agents/review-spec-compliance-auditor.md` — Spec 合规性审查角色
- `agents/review-code-quality-auditor.md` — 代码质量审查角色
- `commands/review.md` — /review 命令说明
- `CANON.md` — 宪法（10 条不可变规则）

## 下一步

建议在实际项目中验证改进效果：

1. **创建测试 spec** — 故意遗漏一个功能需求
2. **运行 /plan** — 验证 plan 使用新的代码示例风格
3. **实现部分功能** — 故意不实现遗漏的需求
4. **运行 /review** — 验证第一阶段（Spec Compliance）能拦截遗漏
5. **补齐功能** — 实现遗漏的需求
6. **重新 /review** — 验证第二阶段（Code Quality）正常执行

---

**改进完成日期:** 2026-05-05  
**改进版本:** v2.10.0  
**改进作者:** Unified Skills Team
