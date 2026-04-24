# Skills 内容补齐计划

## 现状

30 个技能当前平均 490 bytes，只有入口/出口/流程摘要，缺少执行细节。目标：每个技能 2-5KB，自包含可执行。

## 来源映射

### Define（3）

| 技能 | 源框架 | 当前状态 | 目标体量 |
|------|--------|---------|---------|
| define-workflow-refine | agent-skills idea-refine + superpowers brainstorming | 971 bytes | 3KB |
| define-workflow-spec | agent-skills spec-driven-development | 531 bytes | 2KB |
| define-cognitive-brainstorm | superpowers brainstorming（发散部分） | 415 bytes | 2KB |

### Build（13）

| 技能 | 源框架 | 当前状态 | 目标体量 |
|------|--------|---------|---------|
| build-workflow-plan | agent-skills planning-and-task-breakdown + superpowers writing-plans | 690 bytes | 3KB |
| build-workflow-execute | agent-skills incremental-implementation | 815 bytes | 3KB |
| build-frontend-ui-engineering | agent-skills frontend-ui-engineering | 382 bytes | 2KB |
| build-frontend-browser-testing | agent-skills browser-testing-with-devtools | 390 bytes | 2KB |
| build-backend-api-design | agent-skills api-and-interface-design | 369 bytes | 2KB |
| build-backend-database | **unified 新增** | 356 bytes | 2KB |
| build-backend-service-patterns | **unified 新增** | 391 bytes | 2KB |
| build-quality-tdd | superpowers TDD Iron Law + agent-skills test-driven-development | 518 bytes | 4KB |
| build-cognitive-context | agent-skills context-engineering | 390 bytes | 2KB |
| build-cognitive-source-driven | agent-skills source-driven-development | 455 bytes | 2KB |
| build-cognitive-execution-engine | superpowers subagent-driven-development + executing-plans | 544 bytes | 4KB |
| build-cognitive-decision-record | **unified 新增** | 403 bytes | 2KB |
| build-infrastructure-git | agent-skills git-workflow-and-versioning + superpowers using-git-worktrees | 397 bytes | 2KB |

### Verify（6）

| 技能 | 源框架 | 当前状态 | 目标体量 |
|------|--------|---------|---------|
| verify-workflow-review | agent-skills code-review-and-quality + superpowers requesting-code-review | 667 bytes | 3KB |
| verify-frontend-accessibility | **unified 新增** | 408 bytes | 2KB |
| verify-quality-integration-testing | **unified 新增** | 378 bytes | 2KB |
| verify-quality-performance | agent-skills performance-optimization | 389 bytes | 2KB |
| verify-quality-security | agent-skills security-and-hardening | 468 bytes | 2KB |
| verify-team-code-review-standards | agent-skills code-review-and-quality（拆分） | 484 bytes | 2KB |

### Ship（3）

| 技能 | 源框架 | 当前状态 | 目标体量 |
|------|--------|---------|---------|
| ship-workflow-ship | agent-skills shipping-and-launch + gstack /ship | 695 bytes | 3KB |
| ship-infrastructure-ci-cd | agent-skills ci-cd-and-automation | 348 bytes | 2KB |
| ship-infrastructure-deploy | agent-skills shipping-and-launch（拆分） | 408 bytes | 2KB |

### Maintain（3）

| 技能 | 源框架 | 当前状态 | 目标体量 |
|------|--------|---------|---------|
| maintain-workflow-debug | superpowers systematic-debugging + agent-skills debugging-and-error-recovery | 859 bytes | 4KB |
| maintain-infrastructure-observability | **unified 新增** | 391 bytes | 2KB |
| maintain-team-deprecation-migration | agent-skills deprecation-and-migration | 383 bytes | 2KB |

### Reflect（2）

| 技能 | 源框架 | 当前状态 | 目标体量 |
|------|--------|---------|---------|
| reflect-team-retro | gstack /retro | 363 bytes | 2KB |
| reflect-team-documentation | agent-skills documentation-and-adrs | 467 bytes | 2KB |

---

## 执行批次

### 第一批：核心工作流（7 个高优先级）

技能覆盖整个核心执行链路，内容最重、复用最多。

- [x] define-workflow-refine
- [x] define-workflow-spec
- [x] build-workflow-plan
- [x] build-workflow-execute
- [x] maintain-workflow-debug
- [x] verify-workflow-review
- [x] ship-workflow-ship

### 第二批：质量 + 认知（10 个中优先级）

构建/验证阶段的关键约束技能，频繁使用。

- [ ] build-quality-tdd
- [ ] build-cognitive-execution-engine
- [ ] build-cognitive-decision-record
- [ ] build-cognitive-context
- [ ] build-cognitive-source-driven
- [ ] verify-quality-security
- [ ] verify-quality-performance
- [ ] verify-quality-integration-testing
- [ ] verify-team-code-review-standards
- [ ] verify-frontend-accessibility

### 第三批：基础设施 + 团队 + 新增（13 个按需补齐）

使用频率相对较低，或内容较轻。

- [ ] build-frontend-ui-engineering
- [ ] build-frontend-browser-testing
- [ ] build-backend-api-design
- [ ] build-backend-database
- [ ] build-backend-service-patterns
- [ ] build-infrastructure-git
- [ ] ship-infrastructure-ci-cd
- [ ] ship-infrastructure-deploy
- [ ] maintain-infrastructure-observability
- [ ] maintain-team-deprecation-migration
- [ ] reflect-team-retro
- [ ] reflect-team-documentation
- [ ] define-cognitive-brainstorm

---

## 每个技能的内容模板

```
---
name: <phase-role-skill>
description: <一句话说明，含使用触发条件>
---

# <标题>

> 来源: <源框架> | 宪法: <引用的宪法条款>

## 入口/出口
- **入口**: <什么场景触发>
- **出口**: <完成时产出什么>
- **指向**: <完成后建议调用的下一个技能>

## 流程
<分步骤的完整流程，每个步骤包含具体操作和验证>

## 规则
<该技能特有的纪律/约束>

## 红旗
<常见错误做法>

## 快速参考
<关键命令/清单>
```

---

## 进度追踪

| 批次 | 总技能数 | 已补齐 | 未开始 |
|------|---------|-------|-------|
| 第一批 | 7 | 7 ✅ | 0 |
| 第二批 | 10 | 0 | 10 |
| 第三批 | 13 | 0 | 13 |

### 第一批完成明细

| 技能 | 大小 | 关键改进 |
|------|------|---------|
| define-workflow-refine | 4.6KB | 3 阶段完整流程、HARD GATE、方案对比框架、验证失败处理、红旗、验证清单 |
| define-workflow-spec | 4.2KB | Surface Assumptions、6 区域 spec 模板、模糊需求→验收条件转化、验证失败处理、常见说辞 |
| build-workflow-plan | 5.9KB | 只读模式、依赖图、文件结构、垂直切片、bite-sized 任务、禁止占位符、自审、检查点门强制、验证失败处理 |
| build-workflow-execute | 5.8KB | 增量循环、6 条纪律规则、切片策略、按需加载领域技能、任务偏离处理、验证失败处理 |
| maintain-workflow-debug | 5.9KB | 4 阶段完整流程、Iron Law、多组件诊断、Phase 4.5 架构质疑门、红旗、验证失败处理 |
| verify-workflow-review | 5.8KB | 五轴审查、标准/并行两种模式、意见分级、审查标准、分歧处理层级、验证失败处理 |
| ship-workflow-ship | 5.6KB | 预发检查、Staging 验证强制门、Go/No-Go、回滚计划强制、Feature Flag、分阶段上线、事后聚合、何时不使用、验证失败处理 |
