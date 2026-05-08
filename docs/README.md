# Unified Docs

`docs/` 只保留 4 类内容，避免当前合同、历史方案和运行产物混在一起：

## 目录约定

| 目录 | 用途 | 当前规则 |
|------|------|----------|
| `architecture/` | 仍可被当前实现引用的架构/机制文档 | 允许作为设计背景，但合同真相仍以 `AGENTS.md`、`README.md`、`skills/`、`./validate` 为准 |
| `features/` | 工作流产物链：`00-brainstorm.md` → `05-ship.md` | 新产物按 `docs/features/YYYYMMDD-<name>/` 落盘 |
| `history/` | 已完成的优化总结、历史设计稿、迁移记录 | 必须显式标注历史性质，不能伪装成当前真相 |
| 顶层单文件 | 少量长期入口文档 | 只保留跨目录导航价值高的文档 |

## 当前入口

- `directory-architecture.md`：目录模型设计说明。当前仍被校验脚本和根文档引用，因此保留在顶层。
- `architecture/README.md`：当前可参考的架构文档索引。
- `features/README.md`：产物链规则和现有样例说明。
- `history/README.md`：历史资料入口。

## 整理原则

1. 当前合同和历史方案分离。历史文档统一放入 `history/`，并保留“历史 / 已过期”提示。
2. `features/` 只放具体工作项产物，不放通用机制设计。
3. 如果文档仍被 `validate`、根文档或技能合同直接引用，优先保留路径稳定，只补索引和状态说明。
