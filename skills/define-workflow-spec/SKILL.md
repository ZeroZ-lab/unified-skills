---
name: define-workflow-spec
description: 从 refine 产出到结构化 spec。当 refine 完成后需要编写正式 spec，或提到"规格""spec""需求文档"
---

# Spec — 规范编写


## 入口/出口
- **入口**: `define-workflow-refine` 完成，用户已批准方向
- **出口**: `docs/features/YYYYMMDD-<name>/01-spec.md` + 用户批准
- **指向**: 用户批准 spec 后优先调用 `design-workflow-design`；纯后端/脚本/迁移可跳过到 `build-workflow-plan`
- **输出路径**: → design-workflow-design 或 build-workflow-plan（纯后端/脚本/迁移）
- **前置加载**: CANON.md（可选加载 `build-cognitive-decision-record/SKILL.md` — 有架构决策时再加载）

## 何时不使用
- 单行修复、打字错误、需求明确且自包含的变更
- 纯配置变更、依赖升级等无需设计决策的改动

## 流程

### Step 1：Surface Assumptions

写任何 spec 内容前，先列假设：

```
ASSUMPTIONS I'M MAKING:
1. 这是 Web 应用（不是原生移动端）
2. 认证使用 session cookie（不是 JWT）
3. 数据库是 PostgreSQL（基于现有 Prisma schema）
4. 目标现代浏览器（不支持 IE11）
→ 现在纠正我，否则我按这些继续。
```

不要静默填补模糊需求。spec 的全部价值在于**在写代码前**暴露误解。

### Step 2：写 spec 文档

覆盖以下内容：

1. **Objective** — 构建什么、为什么、为谁、成功标准
2. **Artifact Type** — 交付物类型。默认 `software`；可选 `software` / `document` / `article` / `deck` / `visual`
3. **Goal Alignment** — 目标来源、目标质量状态、Done When 和 Stop Conditions。它是 spec 的来源/质量摘要，**不是** `/goal` 生命周期管理的替代品。
4. **Commands / Tools** — 完整可执行命令或产物工具（含参数）：
   ```
   Build: npm run build
   Test: npm test -- --coverage
   Lint: npm run lint --fix
   Dev: npm run dev
   ```
5. **Project Structure / Artifact Paths** — 源码、测试、文档或最终产物路径
6. **Style / Quality Bar** — 代码风格、文风、版式、视觉风格或演示标准
7. **Verification Strategy** — 测试、事实核查、版式检查、导出检查或人工验收方式
8. **Documentation Impact** — 文档槽位和项目级同步意图：
   - `doc_intent: feature_only | feature_plus_project | project_only`
   - `project_truth_changed: yes | no`
   - `affected_project_docs`: 明确列出 `README.md`、`AGENTS.md`、`CHANGELOG.md`、`DESIGN.md` 或 `docs/architecture/*.md`
   - `rationale`: 为什么只写 feature docs，或为什么必须同步 project docs
9. **Boundaries（三级系统）**:
   - **Always do:** 提交前跑测试、遵循命名约定、验证输入
   - **Ask first:** 数据库 schema 变更、加依赖、改 CI 配置
   - **Never do:** 提交密钥、编辑 vendor 目录、未经批准删除失败测试

**spec 模板：**

```markdown
# Spec: [功能名称]

## Objective
[构建什么、为什么。用户故事或验收条件。]

## Artifact Type
artifact_type: software

Allowed: software / document / article / deck / visual

## Goal Alignment
- Source Goal: conversation / `GOAL.md`
- Goal Status: accepted / needs-refinement / blocked
- Goal Review Score: <score>/12

### One-line Goal
[一句话目标]

### Done When
- [ ] Functional:
- [ ] Technical:
- [ ] Regression:
- [ ] Output:

### Stop Conditions
- [ ] Acceptance 无法验证
- [ ] 需要修改明确排除范围
- [ ] 需要改变 API / 权限 / 数据结构 / 生产配置
- [ ] 实际范围明显大于当前 Goal

## Documentation Impact
- doc_intent: feature_only
- project_truth_changed: no
- affected_project_docs:
  - none
- rationale:

## Tech Stack
[software 时填写框架、语言、关键依赖；非 software 时填写工具链、格式、模板或品牌约束]

## Commands / Tools
[Build, test, lint, dev，或 DOCX/PPTX/PDF/PNG/SVG 导出工具与命令]

## Project Structure / Artifact Paths
[目录布局、源文件路径、最终交付物路径]

## Style / Quality Bar
[代码约定，或文风、叙事、版式、视觉标准]

## Verification Strategy
[自动测试、事实核查、人工审查、版式检查、导出验证]

## Documentation Impact
[默认 `feature_only`。当公共 API / CLI / 启动方式 / 部署配置 / 跨 feature 设计约束 / 系统边界 / 监控安全规则变化时，升级为 `feature_plus_project` 或 `project_only`，并明确列出受影响的项目级文档路径。]

## Boundaries
- Always: [...]
- Ask first: [...]
- Never: [...]

## Success Criteria
[如何判定"做完"——具体、可测试的条件]

`Done When` 是 goal 级完成定义；`Success Criteria` 是 spec 级验收标准。两者必须一致，不能出现 Done When 说完成但 Success Criteria 无法验证的情况。

## Risks and Mitigations
| 风险 | 概率 | 影响 | 应对方案 |
|------|------|------|---------|
| [风险] | [高/中/低] | [高/中/低] | [策略] |

## Open Questions
[需要用户输入的未解决问题]
```

### Step 3：把模糊要求转化为验收条件

当接收到模糊需求时，翻译成具体可测试的条件：

```
REQUIREMENT: "让仪表盘更快"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s（4G 网络）
- 初始数据加载 < 500ms
- 加载时无布局偏移（CLS < 0.1）
→ 这些目标对吗？
```

### Step 4：用户审查

spec 写完 → 请用户审查 spec 文件 → 确认或修改 → 用户批准后才进入 plan。

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 用户拒绝 spec | 回到 `define-workflow-refine` Phase 1，获取澄清后重新写 spec。不修改已拒绝的 spec 直接推进。 |
| 用户要求大幅修改 | 直接在 spec 文件上修改，重走用户审查步骤。修改后仍需用户批准。 |
| 需求变更 | 更新 spec，不需要重新 refine。但变更涉及 Goal Alignment 时需重新做 Goal Review。 |
| spec 缺少 Success Criteria | 强制补充具体可测试的验收条件。抽象描述（如"更好""更快")不能替代量化标准。 |
| `project_truth_changed: yes` 但缺少 `affected_project_docs` | 阻塞。必须显式写出要同步的项目级文档路径，不能写“之后补文档”。 |
| Goal Alignment 与 Success Criteria 冲突 | 标记为 Blocking，优先修正 Done When 或 Success Criteria 使其一致。 |
| 隐藏假设未被 Surface Assumptions 列出 | 回到 Step 1 补列假设。不带着未列出的假设进入 spec 编写。 |

## 验证证据

输出或记录必须包含：
- **输入/来源**: 读取的 spec、plan、代码、反馈或发布上下文。
- **执行动作**: 实际完成的检查、生成、修复、导出或发布步骤。
- **验证结果**: 命令、审查结论、产物路径、截图或人工确认。
- **阻塞/回退**: 未通过项、回退路径或需要 human partner 决策的问题。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "这个简单不需要 spec" | 简单任务不需要长 spec，但验收条件仍然需要。两行 spec 就够了。 | 无 spec 的简单任务平均遗漏 1-2 个验收条件，上线后以 bug 形式暴露。 |
| "写代码后再写 spec" | 那是文档，不是规范。spec 的价值在于在写代码前理清需求。 | 事后补写的 spec 会顺应已实现的行为而非需求，遗漏的边界情况被永久锁定。 |
| "spec 会拖慢我们" | 15 分钟 spec 防止数小时返工。15 分钟瀑布比 15 小时调试快。 | 跳过 spec 直接编码的典型返工 1-2 轮，每轮 4-8 小时，总耗时 > spec 流程的 10-20x。 |

## 红旗

- 在 Surface Assumptions 之前就开始写 spec 内容
- spec 缺少 Success Criteria（成功标准不具体=无法验收）
- spec 缺少 Goal Alignment（无法追溯目标来源或完成定义）
- spec 缺少 Documentation Impact（无法判断文档该落哪一层）
- Goal Alignment 与 Success Criteria 冲突
- `project_truth_changed: yes` 但没有 `affected_project_docs`
- "不做清单"没有明确 trade-off
- 用户已批准的 spec 在实现过程中静默变更
- 跳过用户审查直接进入 design / plan
- Architecture decision 没有记录

## 验证清单

- [ ] spec 覆盖全部 9 个核心区域
- [ ] artifact_type 已声明；未声明时明确按 `software` 处理
- [ ] Goal Alignment 已声明，且 Done When 与 Success Criteria 一致
- [ ] Documentation Impact 已声明；需要同步 project docs 时已列出明确路径
- [ ] Stop Conditions 已声明
- [ ] 隐藏假设已列出（Surface Assumptions）
- [ ] 用户已审查并批准 spec
- [ ] 成功标准是具体可测试的
- [ ] Boundaries（Always/Ask First/Never）已定义
- [ ] 风险与应对方案已评估
- [ ] spec 已保存到 `docs/features/YYYYMMDD-<name>/01-spec.md`

## 好坏示例

### Good — 从模糊需求到量化验收

```
用户: "让仪表盘更快"

Step 1 Surface Assumptions:
ASSUMPTIONS I'M MAKING:
1. 当前 LCP > 5s（需验证）
2. 用户主要在 4G 网络使用
3. 首屏数据来自 3 个 API
→ 现在纠正我

Step 3 转化:
REQUIREMENT: "让仪表盘更快"
REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s（4G 网络）
- 初始数据加载 < 500ms
- 加载时无布局偏移（CLS < 0.1）

→ 量化验收条件替代模糊描述，spec 可验证
```

### Bad — 模糊描述直接进入实现

```
用户: "让仪表盘更快"

（跳过 Surface Assumptions，跳过 Step 3 转化）

spec: "优化仪表盘性能，让页面更快"

→ 问题: 没有量化标准 → 无法验收 → "更快"无法判定是否完成
→ 问题: 没有列出假设 → 优化方向基于猜测而非数据 → 可能优化了不重要的瓶颈
→ 问题: Success Criteria 和 Done When 无法一致 → Goal Review 失败
```

## 输出模板

```markdown
### Spec 交付记录 — <feature-name>

**artifact_type**: [software / document / article / deck / visual]
**Goal Alignment**: [来源 / 状态 / 评分]
**Done When**: [具体可验证条件]
**Stop Conditions**: [具体阻断条件]
**Documentation Impact**: [doc_intent / project_truth_changed / affected_project_docs]

**核心区域覆盖**:
- Objective: ✓ / ✗
- Artifact Type: ✓ / ✗
- Goal Alignment: ✓ / ✗
- Documentation Impact: ✓ / ✗
- Commands / Tools: ✓ / ✗
- Project Structure: ✓ / ✗
- Style / Quality Bar: ✓ / ✗
- Verification Strategy: ✓ / ✗
- Boundaries: ✓ / ✗

**Surface Assumptions**: [已列出 / 未列出]
**用户批准**: [已批准 / 待批准]
```
