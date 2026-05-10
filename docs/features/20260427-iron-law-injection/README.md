# Iron Law Injection - 历史设计

> **📜 历史设计**
>
> 这是 Unified Skills 早期关于 Iron Law 注入的设计讨论。
>
> **状态:** 历史设计文档
> **讨论日期:** 2026-04-27
> **当前状态:** Iron Law 已在多个技能中实现

## 设计说明

本文档记录了 Iron Law 注入机制的早期设计思路。
当前实现请参考各强纪律技能的 Iron Law 章节：

### 已实现 Iron Law 的技能

- **build-quality-tdd** - TDD Iron Law：没有测试先失败的代码 = 不存在的代码
- **verify-workflow-debug** - 调试 Iron Law：根因在前，修复在后
- **verify-workflow-review** - 审查 Iron Law：不能自证通过
- **ship-workflow-ship** - 发布 Iron Law：Go/No-Go 门控
- **verify-quality-security** - 安全 Iron Law：每个外部输入是敌意的
- **ship-infrastructure-deploy** - 部署 Iron Law：安全、可逆、可观测
- **verify-quality-performance** - 性能 Iron Law：先测量、再优化
- **build-infrastructure-git** - Git Iron Law：原子提交
- **ship-infrastructure-ci-cd** - CI/CD Iron Law：自动化质量门
- **ship-workflow-canary** - 金丝雀 Iron Law：持续验证
- **ship-workflow-land** - 合并 Iron Law：验证生产
- **verify-content-review** - 内容审查 Iron Law：读者任务先于表达
- **verify-quality-simplify** - 简化 Iron Law：三次出现原则
- **verify-team-code-review-standards** - 审查标准 Iron Law：五轴审查
- **verify-visual-review** - 视觉审查 Iron Law：证据驱动的视觉决策
- **verify-workflow-receiving-review** - 接收审查 Iron Law：不能 yes-machine
- **build-frontend-browser-testing** - 浏览器测试 Iron Law：真实浏览器验证
- **verify-frontend-accessibility** - 可访问性 Iron Law：WCAG 2.1 AA
- **verify-quality-integration-testing** - 集成测试 Iron Law：组件间交互验证

## 产物链

- `00-brainstorm.md` - 结构化脑暴
- `02-plan.md` - 任务计划

## 设计价值

虽然这是一个历史设计文档，但它记录了 Iron Law 机制的设计思考过程。
当前实现保留了这些核心原则，并在各个技能中具体化了 Iron Law 的要求。

**注意:** 这是历史设计文档，当前实现已在此基础上演进。
