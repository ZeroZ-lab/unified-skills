# Unified Skills

> 宪法 + 阶段协议 + 角色责任 + 技能方法论 = 按阶段加载的多产物开发技能套件。支持 Claude Code 和 Codex CLI。

## ⚡ 概要

`AGENTS.md`/`CANON.md` 单入口纪律 · `commands/` 阶段协议 · `skills-router.json` 紧凑路由 · `skills/` 行为技能 · `agents/` 角色责任 · hooks 护栏 · `docs/features/*` 证据链。默认 direct mode；显式进入 `/brainstorm`→`/ship` 等 Unified 阶段时 → 读 compact router → 按 loading tier 选最小必要技能。`/plan` 可产出 `03-plan.md` + `plans/*.md` 子计划；`/design` 可产出 `02-design.md` + `assets/design-tokens-extracted.*`。修改 SKILL.md 或辅助文件 → 同步索引/锁文件 + `./validate`。运行时合同按需加载 → `docs/contracts/{artifact-types,doc-slots,role-escalation,hooks-platform,persona-rules}.md`。贡献指南 → `CONTRIBUTING.md`。

## ⚠ Agent 纪律

Unified 是行为塑造技能——SKILL.md 里的流程、红旗表、常见说辞表经过设计，随意修改会改变 agent 行为。

修改前 → ① 通读技能 ② 读 CANON.md（技能继承宪法 11 条） ③ `./validate` ④ 新技能用 `templates/feature/` 起步 ⑤ diff 给人类 partner 审阅

PR 前 → ① 无 stub 残留 ② 命名 `<phase>-<role>-<skill>/SKILL.md` ③ 含入口/出口条件 + 可操作流程 + 说辞表 + 红旗 + 验证清单；强纪律技能需 Iron Law

## 🖥 终端观察护栏

> 未知输出先限流，复杂信息先采样；终端观察服务判断，不淹没判断。

```bash
# 默认
COMMAND 2>&1 | head -c 4000
# 保留退出码
COMMAND > /tmp/cmd.log 2>&1; rc=$?; head -c 4000 /tmp/cmd.log; exit $rc
```

## 🔄 Runtime（opt-in，hook 失效时仍然适用）

只有以下情况才激活 Unified runtime：

- 显式调用 `/brainstorm|/refine|/design|/plan|/build|/review|/ship|/save|/restore|/learn|/help`
- 明确说"使用 Unified 工作流""按 Unified 来""进入某个阶段"
- 讨论 Unified 本身的启动、路由、技能合同或加载机制

普通 repo 问答、coding、debug 等未提 Unified 的直接任务，不自动进入 router-first 流程。

激活后 → 读 `skills-router.json` → 分析 6 维（阶段·产物·触发词·上下文·风险·tier）→ 声明 tier：

| tier | 加载量 | 触发 |
|------|--------|------|
| `light` | router-only | 默认 |
| `standard` | 1 主 + 1 专项 | — |
| `expanded` | 1 主 + 2 专项 | — |
| `full` | 全部 | `--full`/对抗审核/全身体检/高风险发版/明确要求 |

State Resume → `docs/features/<feature>/state.json`：doc-tracker 更新阶段/文档/下一步/时间；SessionStart 注入恢复提示但不激活 runtime；禁止写本地瞬时状态。`/save` `/restore` 用于 decision-rich checkpoint。

## 📜 宪法

[CANON.md](CANON.md) — 11 条不可变。技能可加纪律，不可放松。

## 📂 结构

```
CANON.md · AGENTS.md · CLAUDE.md · CONTRIBUTING.md
commands/ · skills/ · agents/ · templates/ · references/
docs/contracts/{artifact-types,doc-slots,role-escalation,hooks-platform,persona-rules}.md
docs/features/
```

## 🗺 命令映射

`doc` 基于 `docs/features/YYYYMMDD-<name>/`。spec 必须声明 `artifact_type`（默认 `software`）+ `doc_intent`（默认 `feature_only`）→ 详见 `docs/contracts/artifact-types.md`。

```json
{
  "/brainstorm": {"skill": "define-cognitive-brainstorm", "doc": "00-brainstorm.md"},
  "/refine":     {"skill": "define-workflow-refine",      "doc": "01-spec.md"},
  "/design":     {"skill": "design-workflow-design + artifact技能 + codex-rescue(可选)", "doc": "02-design.md + assets/ + DESIGN.md + assets/design-tokens-extracted.*"},
  "/plan":       {"skill": "build-workflow-plan",          "doc": "03-plan.md + plans/*.md"},
  "/build":      {"skill": "build-workflow-execute + artifact技能", "doc": "adr/"},
  "/review":     {"skill": "verify-workflow-review + artifact审查", "doc": "04-review.md"},
  "/ship":       {"skill": "ship-workflow-ship + artifact-export(非software)", "doc": "05-ship.md"},
  "/save":       {"skill": "maintain-workflow-context-save", "doc": ".claude/checkpoints/"},
  "/restore":    {"skill": "maintain-workflow-context-restore"},
  "/learn":      {"skill": "maintain-workflow-learn",       "doc": ".claude/learnings.jsonl"},
  "/help":       {"skill": null}
}
```

## 📐 约定

```json
{
  "skill_dir": "<phase>-<role>-<skill>/SKILL.md",
  "phases": ["define","design","build","verify","ship","maintain","reflect"],
  "roles": ["workflow","experience","frontend","backend","quality","cognitive","infrastructure","team","content","visual","artifact"],
  "skill_name": "kebab-case 动作描述"
}
```

SKILL.md 必须 → 入口/出口条件 · 何时不使用 · 可操作流程 · 说辞表 · 红旗清单 · 验证清单。强纪律技能 +Iron Law。辅助 `.md` 由主 SKILL.md 引用 + 纳入 `skills-lock.json` auxiliaryHashes。命令 `commands/*.md` 加载技能不重复内容。

## ⊘ 边界

✅ 始终 → 遵循命名规范 · 引用 CANON.md 不重复条款 · 引用技能名不复制内容 · `templates/` 起步 · 通读后调用 · 陈述假设

🚫 绝不 → 空泛建议 · 项目/领域特定技能 · 技能间重复 · 放松宪法 · 盲改红旗/说辞 · 替换 "human partner" · 第三方依赖
