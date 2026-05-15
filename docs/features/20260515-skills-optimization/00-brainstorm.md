# 设计: Skills 全量优化

## 背景

55 个技能，行数 102–292（中位数 ~195），13 个辅助文件。`validate` 检查覆盖命名、结构、合同一致、哈希完整性——但这些是"不破损"的门槛，不是"高质量"的保证。

核心问题: 每个技能在行为塑造力上差距很大。`build-quality-tdd`（261 行）有详细流程、代码示例、反模式表、Prove-It Pattern；`design-content-direction`（102 行）只有骨架步骤，缺少好坏示例、反模式修复表和可衡量的出口标准。

## 假设

1. "优化" = 提升行为塑造力（让 agent 读完后行为更好），不是增加字数
2. 全量一次性修改风险太高——会破坏 `skills-lock.json`、散布隐性回归
3. 用户时间和精力有限，方案必须分批可执行
4. 现有 validate 通过 = 结构合规，但结构合规 ≠ 质量高
5. 辅助文件（examples.md、rubric.md 等）与主 SKILL.md 同等重要，一并优化
6. 不引入 A/B 测试——基于代码审查和评分驱动

## 方案

### 方案 A: 分层深度优化（推荐）

按影响面和风险分层，先优化高杠杆技能，后优化低频技能。

- Tier 1（骨架技能, ~12 个）: workflow 类总控技能。优化标准：每个步骤有可操作行为、好坏示例、出口量化标准。
- Tier 2（强纪律技能, ~19 个）: 带 Iron Law + HARD-GATE 的技能。优化标准：反模式修复表完整、验证证据模板具体、常见说辞后果量化。
- Tier 3（专项技能, ~24 个）: 专项领域技能。最低标准：流程可操作、示例充足、红旗可检测。

- 推荐: 是
- 理由: ROI 最高，分层逻辑符合项目已有的 Risk-Based Role Escalation 思路

### 方案 B: 质量评分 + 批量修复

先定义评分标准，审计所有技能打分，按短板集中批量修复。

- 推荐: 否，但评分思路纳入方案 A
- 理由: 评分可用于 Tier 内排序，但按短板分批会打散技能间连贯性

### 方案 C: 模板升级 + 渐进式拉齐

提取高质量技能的最佳实践作为升级模板，逐个拉齐到新标准。

- 推荐: 否，但模板升级思路延后到 Phase 4
- 理由: 先有优化实践再提取标准，而非先定标准再套

## 推荐

**选方案 A（分层深度优化），借鉴方案 B 的评分思路和方案 C 的模板升级。**

执行路径:

| 阶段 | 内容 | 产出 |
|------|------|------|
| Phase 0 | 评分所有 55 个技能（五轴 0-3），含 13 个辅助文件 | 评分表 + 优化优先级 |
| Phase 1 | 优化 Tier 1 骨架技能（12 个）+ 辅助文件 | 提升每个工作流枢纽的行为塑造力 |
| Phase 2 | 优化 Tier 2 强纪律技能（19 个）+ 辅助文件 | 补全反模式修复表和量化后果 |
| Phase 3 | 优化 Tier 3 专项技能（24 个）+ 辅助文件 | 确保最低可操作性标准 |
| Phase 4 | 提取黄金标准 → 扩展 validate 质量门 | 自动防退化 |

每个 Phase 结束: `generate-index.sh` → `./validate` → human partner spot-check

### 评分维度（五轴 0-3）

| 维度 | 0 分 | 1 分 | 2 分 | 3 分 |
|------|------|------|------|------|
| 可操作性 | 步骤只有标题 | 步骤有描述但不具体 | 每个步骤有动词 + 可检查输出 | 每个步骤有行为 + 检查点 + 示例 |
| 示例充足性 | 无示例 | 有 1 个抽象示例 | 有好/坏对比示例 | 有好/坏对比 + 输出模板 |
| 行为收敛性 | 红旗是形容词 | 红旗可检测 | 红旗可检测 + 有 STOP 后动作 | 红旗可检测 + STOP 后动作 + 验证失败处理表 |
| 跨技能衔接 | 入口/出口缺失 | 有入口/出口但不具体 | 入口/出口明确指向上下游 | 入口/出口 + 加载前提 + 产出路径 |
| 说辞表质量 | 无说辞表 | 有说辞 + 现实 | 有说辞 + 现实 + 后果 | 有说辞 + 现实 + 量化后果 |

### Tier 分层

**Tier 1 骨架技能（12 个）:**
- define-workflow-refine
- define-workflow-spec
- define-cognitive-brainstorm
- design-workflow-design
- build-workflow-plan
- build-workflow-execute
- build-cognitive-execution-engine
- verify-workflow-review
- ship-workflow-ship
- maintain-workflow-using-unified
- maintain-workflow-context-save
- maintain-workflow-context-restore

**Tier 2 强纪律技能（19 个）:**
- build-quality-tdd
- verify-workflow-debug
- verify-workflow-spec-compliance
- verify-quality-code-quality
- verify-quality-security
- verify-quality-performance
- verify-quality-simplify
- verify-team-code-review-standards
- verify-frontend-accessibility
- verify-quality-integration-testing
- verify-content-review
- verify-visual-review
- verify-workflow-receiving-review
- ship-infrastructure-deploy
- ship-infrastructure-ci-cd
- ship-workflow-canary
- ship-workflow-land
- build-infrastructure-git
- build-frontend-browser-testing

**Tier 3 专项技能（24 个）:**
- build-backend-api-design
- build-backend-database
- build-backend-service-patterns
- build-cognitive-context
- build-cognitive-decision-record
- build-cognitive-source-driven
- build-content-layout
- build-content-writing
- build-frontend-ui-engineering
- design-content-direction
- design-content-layout
- design-content-script
- design-experience-interaction
- design-interactive-preview
- design-visual-direction
- maintain-infrastructure-observability
- maintain-team-deprecation-migration
- maintain-workflow-goal
- maintain-workflow-learn
- reflect-team-documentation
- reflect-team-retro
- ship-artifact-export
- ship-workflow-doc-sync
- define-cognitive-brainstorm（如已在 Tier 1 则跳过）

注: define-cognitive-brainstorm 归入 Tier 1；实际 Tier 3 为 23 个。

## 不做

- 全量一次性修改——55 个文件同时改 = 不可追踪的回归风险
- 统一行数目标——102 行可能正好，261 行可能还不够
- 重写 validate 为质量评分器——它当前角色是合同守护，不应承担主观评分
- 新增技能或合并技能——这是优化，不是重构
- 修改 AGENTS.md / CANON.md / 命令映射——优化在技能层面，不在合同层面
- 引入 A/B 测试——成本不匹配收益

## 开放问题

- [已解决] 评分标准: 五轴 0-3 已确认
- [已解决] A/B 测试: 不需要
- [已解决] 辅助文件: 一并优化
