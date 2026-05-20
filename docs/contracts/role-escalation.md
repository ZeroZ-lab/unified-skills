# 角色审查升级 & 默认角色矩阵

> 本文件由 `/refine`、`/plan`、`/review`、`/ship` 阶段技能按需加载，不在 CLAUDE.md 中全量引用。

## Risk-Based Role Escalation

Unified 使用 Risk-Based Role Escalation，而不是所有阶段默认全角色参与：

- 小型变更（单文件、纯配置、无 UI/安全/合规敏感）可跳过 army，只保留当前阶段的自审和验证证据。
- 标准变更使用最小必要角色；例如 `software` 的 `/refine` 和 `/plan` 至少覆盖 CEO + Eng 视角，`content` 的 `/refine` 至少覆盖 CEO + content scout，`/review` 对 `software` 先完成两阶段审查、对非 software 至少完成内容/视觉审查，`/ship` 对 `software` 至少覆盖 security + docs、对非 software 至少覆盖 export QA + docs 审计。
- 高风险变更按风险维度加角色：UI 加 design/accessibility，安全或合规加 security，性能敏感加 performance，测试覆盖不确定加 test。
- 只有大型变更、高风险发版、对抗性审核、全身体检，或用户明确指定 `--full` 时，才开启该阶段全部相关角色。
- 并行只用于已被阶段技能选中的角色；未被选中的角色不需要产出占位反馈。

## 默认角色矩阵

下面这张表描述的是 **默认派工拓扑**，不是固定全员名单。阶段 skill 先被加载，再按 `artifact_type`、canonical 一级交付类、风险和独立性决定是否派这些 persona。

| 阶段 | `software` | `content` | `visual` |
|------|------------|-----------|----------|
| `/refine` | `requirements-analyst` + `refine-ceo-scout` + `refine-eng-scout`；涉及 UI/合规再加 `refine-design-scout` | `requirements-analyst` + `refine-ceo-scout` + `refine-content-scout`；`deck` 涉及明显视觉/版式方向时再加 `refine-design-scout` | `requirements-analyst` + `refine-ceo-scout` + `refine-design-scout` |
| `/plan` | `task-planner` + `plan-ceo-reviewer` + `plan-eng-reviewer`；高风险再加 `plan-design-reviewer` / `plan-security-reviewer` | `task-planner` + `plan-ceo-reviewer` + `plan-eng-reviewer`；`deck` 或设计约束敏感时再加 `plan-design-reviewer` | `task-planner` + `plan-eng-reviewer`；设计约束复杂时加 `plan-design-reviewer` |
| `/build` | `software-engineer`；按子域追加 `api-designer` / `data-architect` | `content-writer`；`deck` 的版式执行由 `visual-designer` 在内容骨架后跟进 | `visual-designer`；涉及文案时按需追加 `content-writer` |
| `/review` | Stage 1: `review-spec-compliance-auditor`；Stage 2: `review-code-quality-auditor`；按风险再加 `review-security-auditor` / `review-test-engineer` / `review-accessibility-auditor` | Stage 1: `review-spec-compliance-auditor`；Stage 2: `review-content-auditor`；`deck` 只有在视觉层级、版式、投屏可读性会影响结论时才叠加 `review-visual-auditor` | Stage 1: `review-spec-compliance-auditor`；Stage 2: `review-visual-auditor` |
| `/ship` | `ship-security-auditor` + `ship-docs-auditor`；按风险再加 `ship-performance-auditor` / `ship-accessibility-auditor` | `ship-artifact-export-auditor` + `ship-docs-auditor` | `ship-artifact-export-auditor` + `ship-docs-auditor` |

## 执行顺序

1. 先进入阶段命令
2. 加载对应 stage skill
3. stage skill 判断需要哪些 persona
4. persona 在该 stage skill 合同内执行
5. 主 session 汇总结果并写阶段产物

## External Scan 分工

`/refine` 使用 Unified 原生 External Scan：按 `artifact_type` 搜索已有方案、事实来源、设计/技术模式；在项目级语义上，再按 canonical 一级交付类（`software / content / visual`）解释应该看哪类模式和风险。结果分层为 Fact / Pattern / Inference / Unknown / Adopt / Reject，再交给 Idea Scout Army 审查。

`/refine` 的 External Scan 不替代 `/design` 的设计扫描。`/design` 使用 `references/design-best-practices.md` 的 4+1 来源模型：Enterprise Product Patterns、Official Systems / Platform Rules、Methods / Theory / Style Schools、Anti-patterns / Verification、Local Project Truth。
