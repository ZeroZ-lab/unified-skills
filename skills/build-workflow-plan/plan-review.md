# Plan Workflow — Plan Review

本文件是 `build-workflow-plan/SKILL.md` 的辅助材料。主技能保留 Plan Topology、依赖图、任务切片和检查点纪律；需要执行 Plan Review Army 或处理 reviewer 反馈时读取本文件。

## Plan Review Army

自审通过后，按风险升级规则分派 specialist 审查 plan：

```
Plan draft
    │
    ├── agents/plan-ceo-reviewer.md      → CEO 视角: 商业价值、范围、优先级
    ├── agents/plan-eng-reviewer.md      → Eng 视角: 技术可行、架构、实现风险
    ├── agents/plan-design-reviewer.md   → Design 视角: 用户体验、交互、一致性
    └── agents/plan-security-reviewer.md → Security 视角: 数据隐私、攻击面、合规
            │
            ▼
    收集反馈 → 分级合并 → 修改 plan → 用户批准
```

## Minimum Trigger Rules

- 小型变更（1-3 任务、非安全敏感、无 UI）→ 可跳过 Review Army。
- 标准变更 → 至少 CEO + Eng 双视角。
- 大型变更（>10 任务或有安全/合规需求）→ 四视角全开。
- 用户明确 `--full`、对抗性审核或全身体检 → 阶段相关 reviewer 全开。

## Feedback Shape

每个 specialist 输出：

```markdown
## Verdict
Blocking / Important / Suggestion

## Evidence Used
- spec:
- design:
- local:

## Findings
- [Blocking] ...
- [Important] ...
- [Suggestion] ...

## Plan Impact
- adopt:
- reject:
- ask user:
```

## Feedback Handling

- **Blocking** — 必须解决，修改 plan 后再提交批准。
- **Important** — 强烈必须采纳；不采纳需在 plan 中记录原因。
- **Suggestion** — 自主判断，采纳后标注来源。

## Merge Rules

1. 收集所有 reviewer 反馈。
2. 合并重复意见。
3. 标注冲突意见，由主 agent 做判断。
4. 按 Blocking → Important → Suggestion 排序。
5. 修改 plan 或明确记录 reject 理由。
6. 再进入用户批准。
