# Codex Hooks Commands - 已完成

> **✅ 已实现**
>
> 本项目已在 **v2.13.3** 完成，参见 CHANGELOG.md。
>
> **状态:** 功能已发布
> **实现版本:** v2.13.3
> **发布日期:** 2026-05-09

## 项目说明

本项目实现 Codex CLI 的 hooks 支持，已在 v2.13.3 发布。
相关配置和使用方法请参考：

- **README.md** - Codex setup 章节
- **.codex/config.toml** - hooks 配置示例
- **.codex/hooks.json** - hooks 定义

## 实现内容

- SessionStart hook - 自动注入宪法和命令上下文
- PreToolUse hook - careful（破坏性命令拦截）和 freeze（编辑范围冻结）
- 平台特定的配置差异处理

## 产物链

- `01-spec.md` - 需求规格
- `02-plan.md` - 任务计划

## 相关变更

参见 CHANGELOG.md v2.13.3：

```
## [2.13.3] - 2026-05-09

### Fixed
- Codex hooks: replace deprecated `[features].codex_hooks` usage with `[features].hooks`
- validate: reject the deprecated Codex hooks flag in config
- historical docs: mark the 2026-04-27 Codex hooks plan/spec as historical
```

**注意:** 这是已完成的项目，保留作为实现记录。
