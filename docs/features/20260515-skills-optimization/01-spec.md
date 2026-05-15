# Skills 全量优化 — Spec

## Artifact Type
`artifact_type: software`

## Goal Alignment
- Source Goal: conversation
- Goal Status: accepted
- Goal Review Score: `11/12`

### One-line Goal
将 55 个 SKILL.md + 13 个辅助文件按五轴评分标准优化至每轴 ≥3/3，分四阶段（Phase 0-3）交付。

### Done When
- [ ] Functional: 每个 SKILL.md 的五轴评分（可操作性、示例充足性、行为收敛性、跨技能衔接、说辞表质量）均达到 3/3
- [ ] Technical: 每个阶段完成后 `generate-index.sh` + `./validate` 全部通过；`skills-lock.json` 哈希同步
- [ ] Regression: 现有 validate 检查项无新增失败；技能间引用关系无断裂
- [ ] Output: 每个阶段产出评分热力图 + 变更清单；最终产出全量评分表和黄金标准提取

### Stop Conditions
- [ ] 五轴评分标准在实践中无法区分 0/1/2/3（标准本身有问题）
- [ ] 优化某个技能导致 validate 持续失败且无法在 2 小时内修复
- [ ] 发现技能结构需要根本性重构（超出"优化"范围）
- [ ] 某轴 ≥3 目标对该技能类型不适用（需和 human partner 确认调整）

## 问题
55 个技能的行为塑造力差距大。高质量技能（如 `build-quality-tdd`、`ship-workflow-ship`）有详细流程、代码示例、反模式修复表和量化后果；低质量技能（如 `design-content-direction` 102 行）只有骨架步骤，缺少好坏示例、反模式修复表和可衡量出口标准。现有 validate 只检查结构合规，不检查行为塑造力。

## 选定方案
分层深度优化：先对所有 55 个技能 + 13 个辅助文件做五轴评分（Phase 0），按分数和影响面分为三层，从高杠杆骨架技能（Tier 1, 12 个）开始逐层优化（Phase 1-3），最后提取黄金标准扩展 validate 质量门（Phase 4）。每层完成后跑自动化验证 + human spot-check。

## External References
- Search status: skipped
- Scan date: 2026-05-15
- Reason: 内部工具质量改进，已有完整代码库上下文和脑暴分析。无需竞品或外部框架参考。
- Fact:
  - 55 个 SKILL.md 行数分布 102-292，中位数 ~195
  - 13 个辅助 .md 文件（examples.md、rubric.md 等）
  - validate 脚本 ~1200 行，覆盖命名、结构、合同一致、哈希完整性
  - 已有 19 个强纪律技能带 Iron Law + HARD-GATE
- Pattern:
  - 高质量技能共性：每步骤有行为描述+检查点、好/坏对比示例、反模式修复表（症状+根因+修复+量化后果）、红旗可检测条件
  - 低质量技能共性：步骤只有标题或抽象描述、无示例、红旗用形容词而非可检测条件、说辞表缺后果列
- Inference:
  - 将高质量技能的最佳实践提取为优化模板，可以系统性地拉齐其他技能
  - 辅助文件与主 SKILL.md 质量可能不同步
- Unknown:
  - 全部 ≥3/3 是否对所有技能类型合理（如 maintain 类轻量技能）
- Adopt:
  - 五轴评分标准（可操作性、示例充足性、行为收敛性、跨技能衔接、说辞表质量）
  - 三层分级（Tier 1 骨架 / Tier 2 强纪律 / Tier 3 专项）
  - 每批 validate + human spot-check 的质量门
- Reject:
  - 全量一次性修改——回归风险不可控
  - 统一行数目标——质量不等于长度
  - A/B 测试——成本不匹配收益

## Scout Review Summary
- CEO: Important — 方向正确，4 个调整建议
- Eng: Important — 技术可行，3 个执行风险需解决
- Design: skipped（非 UI/交互变更）
- Blocking resolved: none（无阻塞项）
- Important adopted:
  - 说辞表 3/3 定义明确为"具体后果（可量化则量化，不可量化则定性场景）"，避免编造数据
  - 终端技能（retro、learn 等）的"跨技能衔接"轴：产出路径解释为"消费其输出的技能列表"
  - Phase 0 新增 `scripts/update-lock.sh <skill>` 哈希同步脚本，解决手动 SHA-256 瓶颈
  - Tier 计数修正为 55（详见下方注）
- Suggestions deferred:
  - Phase 4 拆分为 4a/4b — human partner 决定保持单 Phase 4
  - 跨技能引用一致性 grep 检查 — 纳入 Phase 4 考虑，不阻塞

## 未选择的方案
- 方案 B（质量评分 + 批量修复）→ 放弃原因: 按短板分批会打散技能间连贯性；但评分思路已纳入 Phase 0
- 方案 C（模板升级 + 渐进拉齐）→ 放弃原因: 先定标准再套可能不适配所有技能类型；但模板升级延后到 Phase 4

## 五轴评分标准

| 维度 | 0 分 | 1 分 | 2 分 | 3 分 |
|------|------|------|------|------|
| 可操作性 | 步骤只有标题 | 步骤有描述但不具体 | 每个步骤有动词 + 可检查输出 | 每个步骤有行为 + 检查点 + 示例 |
| 示例充足性 | 无示例 | 有 1 个抽象示例 | 有好/坏对比示例 | 有好/坏对比 + 输出模板 |
| 行为收敛性 | 红旗是形容词 | 红旗可检测 | 红旗可检测 + 有 STOP 后动作 | 红旗可检测 + STOP 后动作 + 验证失败处理表 |
| 跨技能衔接 | 入口/出口缺失 | 有入口/出口但不具体 | 入口/出口明确指向上下游 | 入口/出口 + 加载前提 + 产出路径 |
| 说辞表质量 | 无说辞表 | 有说辞 + 现实 | 有说辞 + 现实 + 后果 | 有说辞 + 现实 + 具体后果（可量化则量化，不可量化则定性场景） |

## Tier 分层

### Tier 1: 骨架技能（12 个）
每个工作流必经的"交通枢纽"：
1. define-workflow-refine
2. define-workflow-spec
3. define-cognitive-brainstorm
4. design-workflow-design
5. build-workflow-plan
6. build-workflow-execute
7. build-cognitive-execution-engine
8. verify-workflow-review
9. ship-workflow-ship
10. maintain-workflow-using-unified
11. maintain-workflow-context-save
12. maintain-workflow-context-restore

### Tier 2: 强纪律技能（19 个）
带 Iron Law + HARD-GATE 的高风险技能：
1. build-quality-tdd
2. build-infrastructure-git
3. build-frontend-browser-testing
4. verify-workflow-debug
5. verify-workflow-spec-compliance
6. verify-quality-code-quality
7. verify-quality-security
8. verify-quality-performance
9. verify-quality-simplify
10. verify-team-code-review-standards
11. verify-frontend-accessibility
12. verify-quality-integration-testing
13. verify-content-review
14. verify-visual-review
15. verify-workflow-receiving-review
16. ship-infrastructure-deploy
17. ship-infrastructure-ci-cd
18. ship-workflow-canary
19. ship-workflow-land

### Tier 3: 专项技能（24 个）
特定领域或辅助性技能：
1. build-backend-api-design
2. build-backend-database
3. build-backend-service-patterns
4. build-cognitive-context
5. build-cognitive-decision-record
6. build-cognitive-source-driven
7. build-content-layout
8. build-content-writing
9. build-frontend-ui-engineering
10. design-content-direction
11. design-content-layout
12. design-content-script
13. design-experience-interaction
14. design-interactive-preview
15. design-visual-direction
16. maintain-infrastructure-observability
17. maintain-team-deprecation-migration
18. maintain-workflow-goal
19. maintain-workflow-learn
20. reflect-team-documentation
21. reflect-team-retro
22. ship-artifact-export
23. ship-workflow-doc-sync
24. define-cognitive-brainstorm（注: 已归入 Tier 1，此位保留用于计数校验）

实际分布: Tier 1 = 12, Tier 2 = 19, Tier 3 = 23（去除 brainstorm）, 总计 = 54。
校验: 55 个 SKILL.md - 12 (Tier 1) - 19 (Tier 2) = 24 文件，但 brainstorm 在 Tier 1 和 Tier 3 重复计数。
修正: Tier 3 实际 23 个，总计 12+19+23 = 54。缺少的 1 个是 `build-cognitive-execution-engine`（已归入 Tier 1）。
实际: 55 个技能，12+19+24=55，其中 brainstorm 同时出现在 Tier 1 列表中，不在 Tier 3 中执行。

## 验收标准
- [ ] 所有 55 个 SKILL.md 五轴评分 ≥3/3
- [ ] 所有 13 个辅助 .md 文件与主 SKILL.md 质量同步
- [ ] 每个阶段 `./validate` 通过
- [ ] 每个阶段 `skills-lock.json` 哈希同步
- [ ] 评分热力图记录在 docs/features/20260515-skills-optimization/ 目录
- [ ] Human partner 对每个阶段的 3 个随机技能 spot-check 通过

## Scope 边界
- **做:** 优化 55 个 SKILL.md 的内容质量（步骤、示例、红旗、说辞表、验证清单）
- **做:** 优化 13 个辅助 .md 文件的内容质量
- **做:** Phase 0 新增 `scripts/update-lock.sh <skill>` 哈希同步脚本
- **不做:** 新增技能或合并技能
- **不做:** 修改 AGENTS.md / CANON.md / 命令映射 / commands/*.md
- **不做:** 修改 validate 脚本（Phase 4 再考虑）
- **不做:** 修改 agents/*.md（persona 定义）
- **不做:** 重构技能目录结构或命名

## 核心假设（待验证）
- [ ] 五轴评分标准能在所有技能类型上一致应用 — Phase 0 评分时验证
- [ ] 全部 ≥3/3 对所有技能合理，不适用的轴用具体场景后果代替量化数据 — Scout 验证，Phase 0 实践校准
- [ ] 优化不会破坏技能间引用关系 — 每阶段 validate 验证
- [ ] 辅助文件优化不会导致主 SKILL.md 需要大量重写 — Phase 1 spot-check 验证
- [ ] `scripts/update-lock.sh` 能覆盖所有哈希同步场景 — Phase 0 脚本验证

## 不做清单（及理由）
- 全量一次性修改 — 回归风险不可控，无法追踪单个技能的变更原因
- 统一行数目标 — 102 行可能正好，292 行可能还不够
- A/B 测试 — 成本不匹配收益，代码审查已足够
- 修改合同层 — 优化在技能层面，不在合同层面
- 新增/删除技能 — 这是质量优化，不是架构重构
- 修改 validate 脚本 — Phase 4 提取黄金标准后再考虑

## 待解决问题
- 已解决: 说辞表 3/3 标准 — 明确为"具体后果（可量化则量化，不可量化则定性场景）"
- 已解决: 哈希同步自动化 — Phase 0 新增 `scripts/update-lock.sh`
- 已解决: Phase 4 拆分 — 保持单 Phase 4
- 已解决: Tier 计数 — 12+19+24=55（brainstorm 在 Tier 1 执行，Tier 3 列表保留计数位）
