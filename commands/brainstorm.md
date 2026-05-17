---
description: 结构化脑暴——发散探索 + 收敛评估 = 明确方向。当想法模糊、面临开放性问题或需要方案对比，或提到"脑暴""想法""怎么办"
---

# Command: /brainstorm

## Runtime Preflight

本命令是显式 Unified 入口。执行本命令时，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。


## Goal

Transform open-ended question or vague idea into 2-3 structured proposals with clear recommendation.

`/brainstorm` has no dedicated `agents/*.md` persona. It is a current-agent cognitive workflow: the command loads `define-cognitive-brainstorm`, and the current agent executes the exploration, divergence, convergence, and recommendation loop.

## Phases

### Phase 1: Context Exploration

**Agent:** current
**Skills:** define-cognitive-brainstorm（Phase 1）
**Input:** 用户的开放性问题或模糊想法
**Process:**
1. 阅读项目的 AGENTS.md / spec / plan 了解现状
2. 阅读相关代码——避免脱离代码库的空想
3. 明确约束
**Output:** 上下文摘要 + 约束清单
**Validation:**
- [ ] 项目现状已了解
- [ ] 约束已明确

### Phase 2: Divergent Exploration

**Agent:** current
**Skills:** define-cognitive-brainstorm（Phase 2）
**Input:** 上下文摘要 + 约束清单
**Process:**
1. 使用结构化框架（SCAMPER / HMW / First Principles / JTBD / Constraints / Pre-mortem）发散探索
2. Surface Assumptions — 列出假设
**Output:** 方案候选列表
**Validation:**
- [ ] 使用了至少 1 个结构化框架
- [ ] 假设已列出

### Phase 3: Convergent Evaluation

**Agent:** current
**Skills:** define-cognitive-brainstorm（Phase 3-4）
**Input:** 方案候选列表
**Process:**
1. 按评估标准（技术可行性、实现成本、用户体验、维护负担、风险、增长潜力）收敛
2. 输出 2-3 个对比方案
3. 给出明确推荐 + 理由
4. 列出"不做清单"
**Output:** 设计文档（2-3 方案 + 推荐 + 不做清单）
**Validation:**
- [ ] 2-3 个清晰对比的方案
- [ ] 每个方案有优点、缺点、风险
- [ ] 明确推荐 + 理由
- [ ] "不做清单"有内容

---

## Entry Conditions
- [ ] 用户有开放性问题或模糊想法
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 设计文档已产出
- [ ] 用户已批准方向

## Next Steps
- If approved → `/refine` 或 `define-workflow-spec`（规格化）
- If unclear → 迭代 Phase 2-3

## Constitutional Rules
- CANON.md Clause 1: Surface Assumptions
- CANON.md Clause 7: Push Back

## 实现

加载 CANON.md → 调用 skills/define-cognitive-brainstorm/SKILL.md。
