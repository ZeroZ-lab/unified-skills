# Unified Docs

`docs/` 只保留 3 类内容，避免当前合同和运行产物混在一起：

## 目录约定

| 目录 | 用途 | 当前规则 |
|------|------|----------|
| `architecture/` | 仍可被当前实现引用的架构/机制文档 | 允许作为设计背景，但合同真相仍以 `AGENTS.md`、`README.md`、`skills/`、`./validate` 为准 |
| `features/` | 工作流产物链：`00-brainstorm.md` → `05-ship.md` | 新产物按 `docs/features/YYYYMMDD-<name>/` 落盘 |
| 顶层单文件 | 少量长期入口文档 | 只保留跨目录导航价值高的文档 |

## 当前入口

- `architecture/README.md`：当前可参考的架构文档索引。
- `features/README.md`：产物链规则和现有目录状态表。
- `assets/`：项目级共享资源。

## 整理原则

1. `features/` 只放具体工作项产物，不放通用机制设计。
2. 已完成或不再有参考价值的历史产物直接清理，不保留归档目录。
3. 如果文档仍被 `validate`、根文档或技能合同直接引用，优先保留路径稳定，只补索引和状态说明。