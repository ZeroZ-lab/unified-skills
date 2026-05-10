# Feature Artifacts

`docs/features/` 是 Unified 的标准产物链目录：

```text
docs/features/YYYYMMDD-<name>/
├── 00-brainstorm.md
├── 01-spec.md
├── 02-design.md
├── 03-plan.md
├── plans/*.md
├── adr/*.md
├── 04-review.md
├── 05-ship.md
├── 06-canary-report.md
├── 07-deploy-report.md
└── README.md
```

## 当前目录说明

### 活跃文档
- `20260509-layered-skills-workflow/`：面向 AI Agent 工程实践者的技术文章草稿，解释 Unified Skills 作为分层 skills workflow architecture 的设计逻辑。

## 文档状态说明

Unified 的特性文档分为三类：

### 活跃文档
- 当前正在进行或最近完成的项目
- 包含完整的产物链（spec → design → plan → build → review → ship）
- 代表最新工作流和最佳实践

### 历史样例目录（非活跃项目）

以下目录保留作为格式和演进痕迹，**不是”进行中”的项目**：

- `20260426-minecraft-city/`：Minecraft 项目示例（📜 历史样例）
  - **状态:** 非活跃项目，v2.8.0 时期的功能示例
  - **用途:** 展示标准产物链格式的创造模式项目
  - **参见:** README.md

- `20260427-codex-hooks-commands/`：Codex Hooks 支持（✅ 已完成）
  - **状态:** 已在 v2.13.3 实现
  - **参见:** CHANGELOG.md v2.13.3, README.md

- `20260427-iron-law-injection/`：Iron Law 注入设计（📜 历史设计）
  - **状态:** 历史设计文档
  - **当前:** Iron Law 已在多个技能中实现
  - **参见:** README.md

**重要提醒：**
- ⚠️ 这些**不是**活跃的开发项目
- ⚠️ 请参考 `AGENTS.md` 中的标准流程开始你的项目
- ⚠️ 这些目录保留用于展示历史演进和格式参考

新的工作项应按上面的标准结构创建在新的 `docs/features/YYYYMMDD-<name>/` 目录中。
