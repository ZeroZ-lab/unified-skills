# 设计: 铁律注射 — 让 Unified 的每个刚性技能更锐利

## 背景

Unified Skills 有 44 个技能覆盖 6 阶段工作流，广度显著领先同类（Superpowers 仅 13 技能）。但对比分析发现，Superpowers 在行为塑造深度上有独特优势——Iron Law、合理化预防、说服科学、CSO 搜索优化、子代理压力测试。研究表明（Meincke et al., 2025, N=28,000），说服原则使 LLM 遵守率从 33% 提升到 72%。

目标：不增加技能数量，而是让每个现有刚性技能在行为塑造层面更锐利。

## 假设

1. 44 技能中约 10 个是"刚性纪律"技能（TDD、Debug、Review、Security、Ship 等），需要 Iron Law 级别的行为塑造
2. 剩余 34 个是"柔性指导"技能，只需保持当前深度
3. CANON.md 的 10 条已经是 Iron Law，但缺乏"合理化预防"层
4. `skills-index.json` 的描述字段可以优化而不破坏加载机制
5. 行为测试可以科学验证技能有效性，但需要基础设施支持

## 方案

### 方案 A: 铁律注射（Iron Law Injection）— 立即执行

**核心思想**：为 10 个刚性技能各添加 Iron Law + 强化合理化反驳表，不改变架构。

**具体做法**：
1. 识别 10 个刚性技能：build-quality-tdd、verify-workflow-debug、verify-workflow-review、verify-quality-security、ship-workflow-ship、ship-infrastructure-ci-cd、ship-infrastructure-deploy、verify-frontend-accessibility、verify-quality-simplify、verify-quality-integration-testing
2. 为每个技能编写一条 Iron Law（一句话绝对规则，无例外）
3. 升级常见说辞表为"合理化反驳表"（借口 → 现实映射）
4. 审计 `<HARD-GATE>` 措辞，应用说服原则（权威、稀缺性、承诺）
5. 优化 `skills-index.json` 描述字段（CSO 原则：纯触发条件，不含工作流摘要）

**优点**：最小侵入、立即可执行、可验证
**缺点**：新技能不自动继承纪律机制
**风险**：低

### 方案 B: 纪律层（Discipline Layer）— A 完成后执行

**核心思想**：创建独立的行为纪律层，刚性技能引用它而非各自重复。

**具体做法**：
1. 创建 `skills/_shared/discipline-layer.md`，包含 Iron Law 模板、通用合理化预防、说服措辞指南
2. 修改 `load-manifest.json` 添加行为检查点
3. 刚性技能引用纪律层而非内联纪律条款
4. 更新 `./validate` 验证刚性技能正确引用纪律层

**优点**：新技能自动继承、单一真相源
**缺点**：间接层增加理解成本
**风险**：中等

### 方案 C: 行为测试（Behavior Testing）— B 完成后执行

**核心思想**：引入 Superpowers 的技能 TDD 方法，用压力场景验证技能行为。

**具体做法**：
1. 创建 `tests/behaviors/` 目录
2. 为每个刚性技能定义 2-3 个压力场景
3. 建立基线（无技能） vs 干预（有技能）对比
4. 纳入 `./validate` 流程

**优点**：科学验证、长期价值
**缺点**：成本高、基础设施待建
**风险**：高

## 推荐

**实施顺序：A → B → C**

1. 先做铁律注射——最小侵入，直接验证效果
2. 如 A 实施后发现 10 个技能的纪律条款有大量重复，抽取共性到纪律层（B）
3. 如需科学验证效果，建立行为测试基础设施（C）

## 不做

- 不给所有 44 个技能加 Iron Law——34 个柔性技能不需要
- 不复制 Superpowers 的视觉伴侣服务器——对核心价值贡献极低
- 不做多平台钩子适配（Cursor/OpenCode）——与本次目标无关
- 不做说服科学的学术引用——结果比论文重要
- 不改变技能命名规范 `<phase>-<role>-<skill>`——当前命名足够好

## 开放问题

- 10 个刚性技能的清单是否完整？是否有遗漏？
- CSO 优化后 `skills-index.json` 的描述格式是否需要同步更新 `load-manifest.json`？
- 行为测试的"基线"如何定义（不同模型/上下文结果不同）？
