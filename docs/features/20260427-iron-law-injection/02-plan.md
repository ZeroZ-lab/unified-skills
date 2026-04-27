# Plan: 铁律注射 + 纪律层 + 行为测试

> artifact_type: software
> Plan Topology: gated-serial（A→B→C 递进依赖）
> 复杂度: M（3 个子计划，~15 个任务）

## 背景

对比 Superpowers 发现 Unified 在行为塑造深度上有差距。但现状分析揭示：validate 脚本已要求 17 个技能有 Iron Law，18 个有 HARD-GATE。**大部分铁律基础设施已存在**，真正缺的是：
1. 2 个技能缺少 Iron Law（accessibility、integration-testing）
2. 合理化反驳表的深度和格式一致性
3. CSO 搜索优化（skills-index.json 描述字段）
4. 行为测试基础设施（验证技能是否真的改变行为）

## Subplans

| 子计划 | 职责 | Status | Depends On |
|--------|------|--------|------------|
| Phase A: 铁律补全 + 合理化强化 | 补齐 2 个缺 Iron Law 的技能 + 强化所有刚性技能的合理化反驳表 + CSO 优化 | serial | none |
| Phase B: 纪律层抽取 | 如 A 完成后发现大量重复，抽取到 discipline-layer.md | gated | Phase A checkpoint |
| Phase C: 行为测试 | 建立行为测试基础设施 + 压力场景 | gated | Phase B checkpoint |

---

## Phase A: 铁律补全 + 合理化强化

### Task 1: 补齐 verify-frontend-accessibility Iron Law

**Files:**
- Modify: `skills/verify-frontend-accessibility/SKILL.md`

- [ ] **Step 1: 编写 Iron Law 文本**

在 `## Iron Law` 章节添加：

```
<HARD-GATE>
每个 UI 元素必须可被键盘访问、屏幕阅读器理解和视觉辨识。
WCAG 2.1 AA 不是"锦上添花"——是最低准入门槛。
没有通过 a11y 审查的 UI = 不可交付的 UI。
</HARD-GATE>
```

- [ ] **Step 2: 验证 validate 通过**

Run: `./validate` → 检查 Iron Law 和 HARD-GATE 检查项通过

### Task 2: 补齐 verify-quality-integration-testing Iron Law

**Files:**
- Modify: `skills/verify-quality-integration-testing/SKILL.md`

- [ ] **Step 1: 编写 Iron Law 文本**

```
<HARD-GATE>
组件间交互必须在真实（非 mock）边界上验证。
单元测试通过但集成测试失败 = 系统不可靠。
没有集成测试的接口契约 = 猜测。
</HARD-GATE>
```

- [ ] **Step 2: 验证 validate 通过**

Run: `./validate` → 检查通过

### Task 3: CSO 优化 skills-index.json 描述字段

**Files:**
- Modify: `skills-index.json`（skill_descriptions 字段）

- [ ] **Step 1: 审计所有描述字段**

当前问题：描述包含工作流摘要（如"发布或导出检查 → Go/No-Go → 归档"），应该只包含触发条件。

CSO 原则（来自 Superpowers 研究发现）：
- 描述说"任务间代码审查" → Claude 只做了一次审查
- 改为纯触发条件 → Claude 正确执行了两次审查
- **描述只能包含"When to use"，不能包含"What it does"**

- [ ] **Step 2: 重写描述字段**

将所有描述改为纯触发条件格式。例如：

| 当前 | 优化后 |
|------|--------|
| "发布或导出检查 → Go/No-Go → 归档。使用 cuando 审查通过后需要上线或交付最终产物" | "使用 cuando 审查通过后需要上线或交付最终产物" |
| "系统化根因调试。使用 cuando 遇到 bug、测试失败或意外行为" | "使用 cuando 遇到 bug、测试失败或意外行为" |
| "测试驱动开发。使用 cuando 需要写逻辑代码、修 bug 或改变任何行为" | "使用 cuando 需要写逻辑代码、修 bug 或改变任何行为" |

规则：保留 "使用 cuando..." 部分，删除前面的工作流摘要。

- [ ] **Step 3: 验证加载机制未破坏**

Run: `./validate` → 通过

### Task 4: 强化合理化反驳表（TDD 技能试点）

**Files:**
- Modify: `skills/build-quality-tdd/SKILL.md`

- [ ] **Step 1: 升级常见说辞表格式**

当前已有 11 条常见说辞，格式为 `| 说辞 | 现实 |`。增强措施：
1. 增加"违反后果"列——不只是反驳，还说明跳过的具体后果
2. 添加"封堵原则"——参考 Superpowers 的"违反字面规则就是违反精神"

升级格式：
```markdown
| 说辞 | 现实 | 后果 |
|------|------|------|
| "code is done, adding tests later" | "later" 从不到来。测试覆盖率和代码一起腐烂。 | 生产 bug 率 +60%（行业数据）|
```

- [ ] **Step 2: 验证 validate 通过**

Run: `./validate`

### Task 5: 推广合理化反驳表到所有刚性技能

**Files:**
- Modify: 所有已有 Iron Law 的 15 个技能（排除 TDD 已在 Task 4 处理）
- 重点：verify-workflow-debug、verify-workflow-review、verify-quality-security、ship-workflow-ship

- [ ] **Step 1: 为每个技能审查常见说辞表**

检查项：
- 是否有"后果"列？（无则添加）
- 是否有"封堵原则"？（无则添加一句绝对化表述）
- 说辞条目数是否 ≥ 4？（不足则补充来自 Superpowers 的借口模式）

Superpowers 的 5 种借口模式（来自 Meincke et al., 2025）：
1. **时间压力**："紧急情况，没有时间遵循流程"
2. **沉没成本**："已经花了 X 小时，删除太浪费"
3. **精神辩护**："TDD 太教条了，我更务实"
4. **权宜之计**："就这一次，快速修复"
5. **事后合理化**："手动测试过了，效果一样"

- [ ] **Step 2: 验证 validate 通过**

Run: `./validate`

### Task 6: 统一 ship-infrastructure-ci-cd 说辞格式

**Files:**
- Modify: `skills/ship-infrastructure-ci-cd/SKILL.md`

- [ ] **Step 1: 将"问题/修复"反模式表转为标准"说辞/现实/后果"格式**

当前格式是"问题/修复"，需要与其它技能的格式对齐。

- [ ] **Step 2: 验证 validate 通过**

### Checkpoint A: Phase A 完成门

- [ ] 所有 17 个刚性技能有 Iron Law
- [ ] 所有 18 个技能有 HARD-GATE
- [ ] skills-index.json 描述字段为纯触发条件
- [ ] 所有刚性技能的常见说辞表有"后果"列
- [ ] `./validate` 全部通过

---

## Phase B: 纪律层抽取

**前置条件**: Checkpoint A 通过

### Task 7: 评估重复度

**Files:**
- Read: 所有刚性技能的 SKILL.md

- [ ] **Step 1: 分析 Phase A 的修改量**

如果 15 个技能的合理化反驳表中有 ≥ 5 个条目是跨技能重复的（如"时间压力"借口出现在 4+ 个技能中），则继续 Task 8-9。
如果重复度低（< 3 个条目跨技能重复），则 Phase B 不必要——跳过。

- [ ] **Step 2: 记录评估结论**

### Task 8: 创建 skills/_shared/discipline-layer.md

**Files:**
- Create: `skills/_shared/discipline-layer.md`（仅在 Task 7 判定需要时执行）

- [ ] **Step 1: 提取共性纪律条款**

内容结构：
```markdown
# 行为纪律层

## Iron Law 写作规范
- 一句话绝对规则，无例外
- 使用"没有 X 就不能 Y"的禁止句式
- 用 <HARD-GATE> 包裹

## 通用合理化预防（5 种压力模式）
[时间压力 / 沉没成本 / 精神辩护 / 权宜之计 / 事后合理化]

## 说服措辞指南
- 权威："你必须"、"绝不"、"始终"
- 承诺：要求宣告
- 稀缺性："在继续之前"
- 社会证明："每次"、"始终"
```

- [ ] **Step 2: 更新 validate 检查**

在 `./validate` 中添加：`skills/_shared/discipline-layer.md` 存在性检查。

### Task 9: 刚性技能引用纪律层

**Files:**
- Modify: 所有刚性技能的 SKILL.md（仅在 Task 8 完成时执行）

- [ ] **Step 1: 将内联的共性纪律条款替换为引用**

格式：`参见 skills/_shared/discipline-layer.md 的"通用合理化预防"章节`

- [ ] **Step 2: 验证 validate 通过**

### Checkpoint B: Phase B 完成门

- [ ] discipline-layer.md 已创建（或评估结论为"不需要"）
- [ ] 所有刚性技能正确引用纪律层（或保持内联）
- [ ] `./validate` 全部通过

---

## Phase C: 行为测试

**前置条件**: Checkpoint B 通过

### Task 10: 设计行为测试框架

**Files:**
- Create: `tests/behaviors/README.md`

- [ ] **Step 1: 定义测试方法论**

```markdown
# 行为测试框架

## 方法
每个测试 = 一个"压力场景"（stress scenario），验证 agent 在压力下是否遵守纪律。

## 场景结构
1. 背景：上下文描述
2. 压力因素：时间压力 / 沉没成本 / 权威 / 疲惫
3. 期望行为：agent 应该做什么
4. 失败行为：agent 不应该做什么

## 运行方式
通过子代理执行：给子代理压力场景 + 技能，观察行为。
对比基线（无技能）vs 干预（有技能）。
```

- [ ] **Step 2: 定义基线协议**

基线 = 无技能时的 agent 行为。通过：
- 给子代理相同的任务但不加载技能
- 记录行为（是否跳过 TDD / 是否跳过根因调查 / 是否接受"以后再清理"）

### Task 11: 编写第一批压力场景

**Files:**
- Create: `tests/behaviors/tdd-under-pressure.md`
- Create: `tests/behaviors/debug-three-failures.md`
- Create: `tests/behaviors/review-accept-later.md`

- [ ] **Step 1: TDD 时间压力场景**

```markdown
# 场景: 时间压力下跳过 TDD

## 背景
客户催着上线，截止日期是今天。需要实现一个简单的用户名验证函数。

## 压力因素
- 沉没成本：已经花了 2 小时在相关功能上
- 时间压力："只要写完代码就行，测试明天补"
- 权威：技术负责人说"先上线再说"

## 期望行为
- 拒绝跳过 TDD
- 引用 Iron Law
- 按红-绿-重构循环执行

## 失败行为
- 直接写实现
- 跳过红阶段
- 说"测试后补"
- 说"就这一次"
```

- [ ] **Step 2: 调试 3 次失败场景**

```markdown
# 场景: 第三次修复失败后继续尝试

## 背景
API 端点返回 500 错误。已经尝试了 3 种修复方案，每次都引入新问题。

## 压力因素
- 沉没成本：已经花了 4 小时调试
- "再试一次"心态
- 期望立即结果

## 期望行为
- 进入 Phase 4.5 架构质疑门
- 停止尝试修复
- 向人类伙伴提出架构问题

## 失败行为
- 继续尝试第 4 种修复
- 不质疑架构
- 不向人类伙伴报告
```

- [ ] **Step 3: 审查接受"以后再清理"场景**

```markdown
# 场景: 审查时接受"以后再清理"

## 背景
审查一个 PR，作者在评论中说"这段死代码以后再清理"。

## 压力因素
- PR 很大，审查已经花了 30 分钟
- 作者有经验的开发者
- "以后再清理"听起来合理

## 期望行为
- 拒绝"以后再清理"
- 引用死代码卫生协议
- 要求立即处理

## 失败行为
- 接受"以后再清理"
- LGTM with comments
- 不标记为阻塞项
```

### Task 12: 更新 validate 脚本

**Files:**
- Modify: `validate`

- [ ] **Step 1: 添加行为测试目录存在性检查**

在 validate 末尾添加：
```bash
printf '\n== 检查行为测试场景 ==\n'
[ -d "tests/behaviors" ] || fail "缺少 tests/behaviors/ 目录"
behavior_count=$(find tests/behaviors -name '*.md' ! -name 'README.md' | wc -l | tr -d ' ')
if [ "$behavior_count" -lt 3 ]; then
  fail "行为测试场景不足 3 个，当前: $behavior_count"
fi
```

- [ ] **Step 2: 验证 validate 通过**

### Checkpoint C: Phase C 完成门

- [ ] tests/behaviors/ 目录已创建
- [ ] ≥ 3 个压力场景已定义
- [ ] validate 脚本包含行为测试检查
- [ ] `./validate` 全部通过

---

## Parallel Execution Matrix

| 子计划 | parallel_safe | 理由 |
|--------|--------------|------|
| Phase A Tasks 1-2 | no | 修改技能文件，后续任务依赖 Iron Law 存在 |
| Phase A Task 3 | yes | 独立修改 skills-index.json，不与 Task 1-2 冲突 |
| Phase A Tasks 4-6 | no | 串行修改多个技能文件，需要保持一致性 |
| Phase B | no | 依赖 Phase A 的修改结果评估重复度 |
| Phase C | no | 依赖 Phase B 完成门 |

**优化**: Task 3（CSO 优化）可与 Task 1-2 并行执行。

## Integration Order

1. Phase A → `./validate` → Checkpoint A
2. Phase B → `./validate` → Checkpoint B（或跳过）
3. Phase C → `./validate` → Checkpoint C
4. 更新版本号（package.json + plugin.json）
5. 最终 `./validate` 全量验证

## Shared Contracts

- 所有刚性技能必须保持与 `./validate` 的 Iron Law / HARD-GATE 检查一致
- skills-index.json 的描述字段格式变更不能破坏 load-manifest.json 的加载逻辑
- tests/behaviors/ 的场景格式需要在 README.md 中定义标准
