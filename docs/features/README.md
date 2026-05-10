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

### 历史样例目录（非活跃项目）

以下目录保留作为格式和演进痕迹，**不是”进行中”的项目**：

- `20260426-minecraft-city/`：**Minecraft 项目示例**（非 Unified 功能）  
  展示 Unified Skills 标准产物链格式的创造模式项目。只包含 `spec` 和 `plan`，不是完整产物链。
  
- `20260427-codex-hooks-commands/`：**早期 Codex 兼容方案记录**  
  记录 v2.6.0 之前的 Codex hooks 兼容方案。当前实现已使用不同方案（参见 `docs/history/20260505-quality-assurance-enhancement.md`）。
  
- `20260427-iron-law-injection/`：**早期设计讨论记录**  
  记录关于强制执行语言（Iron Law）的 brainstorming 和 plan 讨论。相关功能已在后续版本实现。

**重要提醒：**
- ⚠️ 这些**不是**活跃的开发项目
- ⚠️ 请参考 `AGENTS.md` 中的标准流程开始你的项目
- ⚠️ 这些目录保留用于展示历史演进和格式参考

新的工作项应按上面的标准结构创建在新的 `docs/features/YYYYMMDD-<name>/` 目录中。
