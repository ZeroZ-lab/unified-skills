# Skills Five-Axis Scoring Report

> 评分日期: 2026-05-15
> 评分范围: 全部 55 个 SKILL.md + 13 个辅助 .md 文件
> 评分标准: 每轴 0-3，详见下方标准定义

## 评分标准

| 轴 | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| **可操作性** | 只有章节标题 | 有描述但不具体 | 每步有动词+可检查输出 | 每步有动词+检查点+示例 |
| **示例充足性** | 无示例 | 1个抽象示例 | 好/坏对比 | 好/坏对比+输出模板 |
| **行为收敛性** | 红旗用形容词 | 红旗可检测 | 可检测+STOP动作 | 可检测+STOP+验证失败处理表 |
| **跨技能衔接** | 无入口/出口 | 有入口/出口但不具体 | 入口/出口指向上下游 | 入口/出口+前置加载+输出路径 |
| **说辞表质量** | 无说辞表 | 说辞+现实 | 说辞+现实+后果 | 说辞+现实+可量化后果 |

---

## Tier 1 — 骨架技能 (12)

| # | 技能 | 可操作性 | 示例充足性 | 行为收敛性 | 跨技能衔接 | 说辞表质量 | 总分 |
|---|------|---------|-----------|-----------|-----------|-----------|------|
| 1 | define-workflow-refine | 3 | 2 | 3 | 3 | 2 | 13 |
| 2 | define-workflow-spec | 3 | 2 | 2 | 3 | 1 | 11 |
| 3 | define-cognitive-brainstorm | 3 | 2 | 2 | 2 | 1 | 10 |
| 4 | design-workflow-design | 3 | 2 | 3 | 3 | 2 | 13 |
| 5 | build-workflow-plan | 3 | 2 | 3 | 3 | 2 | 13 |
| 6 | build-workflow-execute | 3 | 2 | 3 | 3 | 3 | 14 |
| 7 | build-cognitive-execution-engine | 3 | 2 | 2 | 3 | 2 | 12 |
| 8 | verify-workflow-review | 3 | 2 | 3 | 3 | 2 | 13 |
| 9 | ship-workflow-ship | 3 | 3 | 3 | 3 | 3 | 15 |
| 10 | maintain-workflow-using-unified | 2 | 1 | 2 | 3 | 1 | 9 |
| 11 | maintain-workflow-context-save | 3 | 2 | 2 | 2 | 1 | 10 |
| 12 | maintain-workflow-context-restore | 3 | 2 | 3 | 2 | 1 | 11 |

### Tier 1 Gap Details

**define-workflow-refine** (13/15)
- 示例充足性 [2]: 有好/坏对比和 spec 模板（在 refine-artifacts.md），但主文件无独立输出模板
- 说辞表质量 [2]: 有说辞+现实+后果，部分后果可量化但不是全部

**define-workflow-spec** (11/15)
- 示例充足性 [2]: 有完整 spec 模板作为好示例，缺少坏示例对比
- 行为收敛性 [2]: 红旗可检测+有 STOP 动作，缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**define-cognitive-brainstorm** (10/15)
- 示例充足性 [2]: 有输出模板，缺少好/坏对比
- 行为收敛性 [2]: 红旗可检测+有 STOP 动作，缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 有入口/出口但未指向具体下游技能名

**design-workflow-design** (13/15)
- 示例充足性 [2]: 有 Adopt/Reject 示例，辅助文件有 token 示例，缺少完整好/坏对比
- 说辞表质量 [2]: 有说辞+现实+后果，后果部分可量化

**build-workflow-plan** (13/15)
- 示例充足性 [2]: 辅助文件 task-templates.md 有模板，主文件缺少好/坏对比
- 说辞表质量 [2]: 有说辞+现实+后果，后果部分可量化

**build-workflow-execute** (14/15)
- 示例充足性 [2]: 有验证证据格式，缺少完整好/坏代码对比

**build-cognitive-execution-engine** (12/15)
- 示例充足性 [2]: 辅助文件有详细提示词模板和输出格式，主文件缺少好/坏执行对比
- 行为收敛性 [2]: 红旗可检测+有 STOP 动作，缺少验证失败处理表
- 说辞表质量 [2]: 有说辞+现实+后果，后果描述具体但未量化

**verify-workflow-review** (13/15)
- 示例充足性 [2]: 辅助文件 review-guidance.md 有拆分策略和反模式示例，主文件缺少输出模板
- 说辞表质量 [2]: 有说辞+现实+后果，后果部分可量化

**ship-workflow-ship** (15/15)
- 满分。每步有动词+检查点+示例；好/坏对比+回滚计划模板；红旗+STOP+验证失败处理表；完整上下游衔接；说辞+现实+可量化后果

**maintain-workflow-using-unified** (9/15)
- 可操作性 [2]: 有发现流程但步骤缺少具体检查点
- 示例充足性 [1]: 辅助文件 skill-reference.md 是技能列表，无好/坏对比
- 行为收敛性 [2]: 红旗可检测+有 STOP 动作，缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**maintain-workflow-context-save** (10/15)
- 示例充足性 [2]: 有完整 checkpoint 模板作为好示例，缺少坏示例
- 行为收敛性 [2]: 红旗可检测+STOP（Hard Gate），缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 有入口/出口指向 context-restore，缺少前置加载声明

**maintain-workflow-context-restore** (11/15)
- 示例充足性 [2]: 有完整 checkpoint 示例和选择流程图，缺少坏示例
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 有入口/出口，缺少前置加载声明

---

## Tier 2 — 强纪律技能 (19)

| # | 技能 | 可操作性 | 示例充足性 | 行为收敛性 | 跨技能衔接 | 说辞表质量 | 总分 |
|---|------|---------|-----------|-----------|-----------|-----------|------|
| 1 | build-quality-tdd | 3 | 3 | 3 | 3 | 3 | 15 |
| 2 | build-infrastructure-git | 2 | 2 | 2 | 2 | 1 | 9 |
| 3 | build-frontend-browser-testing | 2 | 2 | 2 | 2 | 1 | 9 |
| 4 | verify-workflow-debug | 3 | 2 | 3 | 3 | 3 | 14 |
| 5 | verify-workflow-spec-compliance | 3 | 3 | 2 | 2 | 3 | 13 |
| 6 | verify-quality-code-quality | 3 | 2 | 2 | 3 | 2 | 12 |
| 7 | verify-quality-security | 3 | 2 | 3 | 2 | 2 | 12 |
| 8 | verify-quality-performance | 2 | 2 | 2 | 2 | 1 | 9 |
| 9 | verify-quality-simplify | 3 | 2 | 3 | 2 | 2 | 12 |
| 10 | verify-team-code-review-standards | 3 | 2 | 2 | 2 | 2 | 11 |
| 11 | verify-frontend-accessibility | 3 | 2 | 2 | 2 | 2 | 11 |
| 12 | verify-quality-integration-testing | 2 | 2 | 2 | 2 | 2 | 10 |
| 13 | verify-content-review | 3 | 2 | 3 | 2 | 1 | 11 |
| 14 | verify-visual-review | 3 | 2 | 3 | 2 | 1 | 11 |
| 15 | verify-workflow-receiving-review | 3 | 2 | 3 | 2 | 2 | 12 |
| 16 | ship-infrastructure-deploy | 2 | 2 | 2 | 2 | 1 | 9 |
| 17 | ship-infrastructure-ci-cd | 3 | 3 | 3 | 2 | 2 | 13 |
| 18 | ship-workflow-canary | 3 | 2 | 2 | 2 | 1 | 10 |
| 19 | ship-workflow-land | 3 | 2 | 2 | 2 | 1 | 10 |

### Tier 2 Gap Details

**build-quality-tdd** (15/15)
- 满分。RED/GREEN/REFACTOR 每步有动词+检查点；辅助文件 examples.md 有好/坏对比；红旗+STOP+验证失败处理表；上下游完整；说辞+现实+可量化后果

**build-infrastructure-git** (9/15)
- 可操作性 [2]: 有原则+模式，步骤缺少具体检查点
- 示例充足性 [2]: 有好/坏 commit 示例，缺少输出模板
- 行为收敛性 [2]: 红旗可检测+STOP，缺少验证失败处理表
- 跨技能衔接 [2]: 有入口/出口但上下游指向不具体
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-frontend-browser-testing** (9/15)
- 可操作性 [2]: 有 REPRODUCE→INSPECT→DIAGNOSE→FIX→VERIFY 流程，但步骤不够具体
- 示例充足性 [2]: 有 Playwright 代码片段，但缺少好/坏对比和输出模板
- 行为收敛性 [2]: 红旗可检测+STOP，缺少验证失败处理表
- 跨技能衔接 [2]: 有入口/出口，上下游指向不具体
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**verify-workflow-debug** (14/15)
- 示例充足性 [2]: 有 Phase 4.5 architecture gate 示例，缺少完整好/坏对比

**verify-workflow-spec-compliance** (13/15)
- 行为收敛性 [2]: 有红旗+STOP，缺少验证失败处理表（虽隐含在流程中但未显式成表）
- 跨技能衔接 [2]: 有入口指向 review/code-quality，但未声明前置加载

**verify-quality-code-quality** (12/15)
- 示例充足性 [2]: 辅助文件 rubric.md 有详细检查项，report-template.md 有输出模板，主文件缺少好/坏代码对比
- 行为收敛性 [2]: 红旗可检测+STOP，缺少验证失败处理表

**verify-quality-security** (12/15)
- 示例充足性 [2]: 有好/坏代码示例，缺少输出模板
- 跨技能衔接 [2]: 有入口指向 review/ship，未声明前置加载

**verify-quality-performance** (9/15)
- 可操作性 [2]: MEASURE→IDENTIFY→FIX→VERIFY→GUARD 流程清晰，但缺少每步检查点
- 行为收敛性 [2]: 红旗可检测+STOP，缺少验证失败处理表
- 跨技能衔接 [2]: 入口/出口不具体
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**verify-quality-simplify** (12/15)
- 示例充足性 [2]: 每个策略有好/坏代码对比，缺少输出模板
- 跨技能衔接 [2]: 指向 review 但未声明前置加载

**verify-team-code-review-standards** (11/15)
- 示例充足性 [2]: 有 review army 模式，缺少好/坏对比
- 行为收敛性 [2]: 红旗+STOP，缺少验证失败处理表
- 跨技能衔接 [2]: 入口/出口指向不具体

**verify-frontend-accessibility** (11/15)
- 示例充足性 [2]: 有好/坏代码示例，缺少输出模板
- 行为收敛性 [2]: 红旗+STOP，缺少验证失败处理表
- 跨技能衔接 [2]: 入口/出口指向不具体

**verify-quality-integration-testing** (10/15)
- 可操作性 [2]: 有集成测试模式，缺少每步检查点
- 示例充足性 [2]: 有好/坏代码示例，缺少输出模板
- 行为收敛性 [2]: 红旗+STOP，缺少验证失败处理表
- 跨技能衔接 [2]: 入口/出口指向不具体

**verify-content-review** (11/15)
- 示例充足性 [2]: 有好/坏示例，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 入口/出口指向不具体

**verify-visual-review** (11/15)
- 示例充足性 [2]: 有好/坏示例，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 入口/出口指向不具体

**verify-workflow-receiving-review** (12/15)
- 示例充足性 [2]: 有 YAGNI 检查和 prohibited response 示例，缺少完整好/坏对比
- 跨技能衔接 [2]: 入口/出口指向不具体

**ship-infrastructure-deploy** (9/15)
- 可操作性 [2]: 有预发检查清单和回滚 playbook 模板，但流程步骤缺少具体检查点
- 行为收敛性 [2]: 红旗+STOP，缺少验证失败处理表
- 跨技能衔接 [2]: 入口/出口指向不具体
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**ship-infrastructure-ci-cd** (13/15)
- 示例充足性 [3]: 有好/坏 CI 配置对比+反模式表+输出模板
- 跨技能衔接 [2]: 入口/出口指向不具体
- 说辞表质量 [2]: 有说辞+现实+后果，后果部分可量化

**ship-workflow-canary** (10/15)
- 示例充足性 [2]: 有 baseline 脚本和 alert grading，缺少好/坏对比
- 行为收敛性 [2]: 红旗+STOP，缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 入口/出口指向不具体

**ship-workflow-land** (10/15)
- 示例充足性 [2]: 有详细 bash 命令，缺少好/坏对比
- 行为收敛性 [2]: 红旗+STOP，缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 入口/出口指向不具体

---

## Tier 3 — 专项技能 (24)

| # | 技能 | 可操作性 | 示例充足性 | 行为收敛性 | 跨技能衔接 | 说辞表质量 | 总分 |
|---|------|---------|-----------|-----------|-----------|-----------|------|
| 1 | build-cognitive-context | 2 | 1 | 2 | 2 | 1 | 8 |
| 2 | build-cognitive-source-driven | 3 | 2 | 3 | 2 | 1 | 11 |
| 3 | build-cognitive-decision-record | 3 | 2 | 2 | 2 | 1 | 10 |
| 4 | build-frontend-ui-engineering | 2 | 2 | 2 | 2 | 1 | 9 |
| 5 | build-backend-api-design | 3 | 2 | 2 | 2 | 1 | 10 |
| 6 | build-backend-database | 3 | 2 | 2 | 2 | 1 | 10 |
| 7 | build-backend-service-patterns | 2 | 2 | 2 | 2 | 1 | 9 |
| 8 | build-content-writing | 3 | 2 | 3 | 2 | 1 | 11 |
| 9 | build-content-layout | 3 | 2 | 3 | 2 | 1 | 11 |
| 10 | design-experience-interaction | 2 | 1 | 2 | 2 | 1 | 8 |
| 11 | design-visual-direction | 2 | 1 | 2 | 2 | 1 | 8 |
| 12 | design-content-script | 2 | 1 | 2 | 2 | 1 | 8 |
| 13 | design-content-direction | 2 | 1 | 2 | 2 | 1 | 8 |
| 14 | design-content-layout | 2 | 1 | 2 | 2 | 1 | 8 |
| 15 | design-interactive-preview | 3 | 2 | 2 | 2 | 1 | 10 |
| 16 | ship-artifact-export | 3 | 2 | 3 | 2 | 1 | 11 |
| 17 | ship-workflow-doc-sync | 3 | 2 | 2 | 2 | 1 | 10 |
| 18 | maintain-infrastructure-observability | 2 | 2 | 2 | 2 | 1 | 9 |
| 19 | maintain-team-deprecation-migration | 3 | 2 | 3 | 2 | 1 | 11 |
| 20 | maintain-workflow-learn | 3 | 2 | 2 | 2 | 1 | 10 |
| 21 | maintain-workflow-goal | 2 | 1 | 2 | 2 | 1 | 8 |
| 22 | reflect-team-retro | 2 | 1 | 2 | 2 | 1 | 8 |
| 23 | reflect-team-documentation | 3 | 2 | 2 | 2 | 1 | 10 |
| 24 | maintain-workflow-context-save | — | — | — | — | — | (Tier 1) |

### Tier 3 Gap Details

**build-cognitive-context** (8/15)
- 可操作性 [2]: 5 层上下文模型有结构但缺少具体检查点
- 示例充足性 [1]: 无好/坏对比，只有抽象描述
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-cognitive-source-driven** (11/15)
- 示例充足性 [2]: 有好/坏代码对比+反模式表，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列
- 跨技能衔接 [2]: 入口/出口指向不具体

**build-cognitive-decision-record** (10/15)
- 示例充足性 [2]: 有完整 ADR 示例，缺少坏示例对比
- 行为收敛性 [2]: 红旗可检测但缺少 STOP 动作和验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-frontend-ui-engineering** (9/15)
- 可操作性 [2]: 有组件模式但步骤缺少具体检查点
- 示例充足性 [2]: 有反模式表（AI aesthetic），缺少好/坏代码对比
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-backend-api-design** (10/15)
- 示例充足性 [2]: 有好/坏代码示例，缺少输出模板
- 行为收敛性 [2]: 红旗可检测，缺少 STOP 和验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-backend-database** (10/15)
- 示例充足性 [2]: 有好/坏 SQL 示例，缺少输出模板
- 行为收敛性 [2]: 红旗可检测，缺少 STOP 和验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-backend-service-patterns** (9/15)
- 可操作性 [2]: 有代码示例和模式，但流程步骤缺少检查点
- 示例充足性 [2]: 有弹性代码示例，缺少好/坏对比
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-content-writing** (11/15)
- 示例充足性 [2]: 有好/坏示例+反模式表，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**build-content-layout** (11/15)
- 示例充足性 [2]: 有好/坏示例+反模式表，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**design-experience-interaction** (8/15)
- 可操作性 [2]: 有 best-practice scan 要求，但步骤过短缺少检查点
- 示例充足性 [1]: 无好/坏对比，只有抽象模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**design-visual-direction** (8/15)
- 可操作性 [2]: 有 best-practice scan 要求，但步骤过短缺少检查点
- 示例充足性 [1]: 无好/坏对比，只有抽象模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**design-content-script** (8/15)
- 可操作性 [2]: 有 best-practice scan 要求，但步骤过短缺少检查点
- 示例充足性 [1]: 无好/坏对比，只有抽象模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**design-content-direction** (8/15)
- 可操作性 [2]: 有 best-practice scan 要求，但步骤过短缺少检查点
- 示例充足性 [1]: 无好/坏对比，只有抽象模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**design-content-layout** (8/15)
- 可操作性 [2]: 有 best-practice scan 要求，但步骤过短缺少检查点
- 示例充足性 [1]: 无好/坏对比，只有抽象模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**design-interactive-preview** (10/15)
- 示例充足性 [2]: 有 HTML 模板和 Adopt/Reject 示例，缺少好/坏对比
- 行为收敛性 [2]: 红旗可检测，缺少 STOP 和验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**ship-artifact-export** (11/15)
- 示例充足性 [2]: 有好/坏示例+反模式表，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**ship-workflow-doc-sync** (10/15)
- 示例充足性 [2]: 有 bash 命令示例，缺少好/坏对比
- 行为收敛性 [2]: 红旗可检测+STOP，缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**maintain-infrastructure-observability** (9/15)
- 可操作性 [2]: 三支柱模型有结构但步骤缺少检查点
- 示例充足性 [2]: 有好/坏日志示例，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**maintain-team-deprecation-migration** (11/15)
- 示例充足性 [2]: 有好/坏废弃通知+反模式表，缺少输出模板
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**maintain-workflow-learn** (10/15)
- 示例充足性 [2]: 有 JSONL 格式和子命令示例，缺少好/坏对比
- 行为收敛性 [2]: 红旗可检测+STOP，缺少验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**maintain-workflow-goal** (8/15)
- 可操作性 [2]: 子命令清晰但流程缺少检查点
- 示例充足性 [1]: 只有命令示例和输出格式，无好/坏对比
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**reflect-team-retro** (8/15)
- 可操作性 [2]: 有回顾模板和 5-Why，但步骤缺少检查点
- 示例充足性 [1]: 有模板但无好/坏对比
- 说辞表质量 [1]: 只有说辞+现实，无后果列

**reflect-team-documentation** (10/15)
- 示例充足性 [2]: 有内联文档示例和 ADR 生命周期，缺少好/坏对比
- 行为收敛性 [2]: 红旗可检测，缺少 STOP 和验证失败处理表
- 说辞表质量 [1]: 只有说辞+现实，无后果列

---

## 辅助文件质量同步检查

| 辅助文件 | 父技能 | 质量同步 | 问题 |
|---------|--------|---------|------|
| build-quality-tdd/examples.md | build-quality-tdd | **同步** | 有好/坏对比，与主文件 RED/GREEN/REFACTOR 流程对齐 |
| build-cognitive-execution-engine/implementer-prompt.md | build-cognitive-execution-engine | **同步** | 产物类型适配完整，输出格式清晰，与主文件模式 C 对齐 |
| build-cognitive-execution-engine/quality-reviewer-prompt.md | build-cognitive-execution-engine | **同步** | 五轴审查+严重性分级+产物适配，与主文件 Phase 3 对齐 |
| build-cognitive-execution-engine/spec-reviewer-prompt.md | build-cognitive-execution-engine | **同步** | 对抗性立场+MISSING/EXTRA/MISUNDERSTOOD 分类，与主文件 Phase 2 对齐 |
| build-workflow-plan/plan-review.md | build-workflow-plan | **同步** | Plan Review Army+触发规则+反馈处理，与主文件 Step 7 对齐 |
| build-workflow-plan/task-templates.md | build-workflow-plan | **同步** | Software/非 Software 模板+Subplan Contract，与主文件任务切片对齐 |
| define-workflow-refine/refine-artifacts.md | define-workflow-refine | **同步** | Goal Review Rubric+External Scan+Scout Output+Spec One-Pager，与主文件 Phase 2-3 对齐 |
| design-workflow-design/design-sync.md | design-workflow-design | **同步** | Token 提取规则+合并规则+跳过条件，与主文件 Step 6 对齐 |
| design-workflow-design/visual-generation.md | design-workflow-design | **同步** | Token Schema+降级策略+适用性表，与主文件 Step 3.5 对齐 |
| maintain-workflow-using-unified/skill-reference.md | maintain-workflow-using-unified | **同步但质量低于主文件** | 技能列表完整但无好/坏对比或决策树，是参考目录不是行为指南 |
| verify-quality-code-quality/report-template.md | verify-quality-code-quality | **同步** | 五轴报告模板+Blocking/Important/Suggestion 分级，与主文件审查流程对齐 |
| verify-quality-code-quality/rubric.md | verify-quality-code-quality | **同步** | 五轴检查项+标记示例，与主文件审查轴对齐 |
| verify-workflow-review/review-guidance.md | verify-workflow-review | **同步** | 并行发散+变更大小+拆分策略+卫生规则，与主文件两阶段审查对齐 |

---

## 汇总统计

### 按轴分布

| 轴 | 3分 | 2分 | 1分 | 0分 | 平均 |
|---|-----|-----|-----|-----|------|
| 可操作性 | 37 (67%) | 18 (33%) | 0 | 0 | 2.67 |
| 示例充足性 | 3 (5%) | 49 (89%) | 3 (5%) | 0 | 2.00 |
| 行为收敛性 | 14 (25%) | 41 (75%) | 0 | 0 | 2.25 |
| 跨技能衔接 | 7 (13%) | 48 (87%) | 0 | 0 | 2.13 |
| 说辞表质量 | 2 (4%) | 18 (33%) | 35 (64%) | 0 | 1.40 |

### 按Tier平均分

| Tier | 技能数 | 总分范围 | 平均总分 | 满分占比 |
|------|--------|---------|---------|---------|
| Tier 1 | 12 | 9-15 | 12.0 | 2/12 (17%) |
| Tier 2 | 19 | 9-15 | 11.3 | 1/19 (5%) |
| Tier 3 | 24 | 8-11 | 9.5 | 0/24 (0%) |

### 关键发现

1. **说辞表质量是最大短板**: 64% 的技能只有说辞+现实两列，缺少后果列。只有 `ship-workflow-ship` 和 `build-quality-tdd` 达到 3 分。
2. **示例充足性普遍偏弱**: 89% 停在 2 分——有好/坏对比但缺输出模板。5 个 design 专项技能只有 1 分。
3. **跨技能衔接入口/出口完整但前置声明不足**: 87% 停在 2 分——有入口/出口指向但不声明前置加载。
4. **行为收敛性红旗普遍可检测**: 但 75% 缺少验证失败处理表。
5. **辅助文件质量同步良好**: 13 个辅助文件全部与主文件对齐，只有 `skill-reference.md` 质量低于主文件。
