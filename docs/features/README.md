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

## 当前目录及状态

| 目录 | 状态 | 说明 | 产物链进度 |
|------|------|------|-----------|
| `20260509-layered-skills-workflow/` | 📝 草稿 | 技术文章草稿（artifact_type: article），有 spec 和文章稿 | spec → article |
| `20260510-technical-debt-cleanup/` | 🔄 部分完成 | 技术债清理（已完成 spec+plan+review，缺 design 和 ship） | spec → plan → review |
| `20260512-design-workflow-enhancement/` | ✅ 已完成 | v2.16.0 设计工作流增强（只有 ship 记录） | ship |
| `20260515-context-runtime/` | 🔄 进行中 | Context Runtime 重构（当前活跃工作项） | spec → design → plan |

新的工作项应按上面的标准结构创建在新的 `docs/features/YYYYMMDD-<name>/` 目录中。