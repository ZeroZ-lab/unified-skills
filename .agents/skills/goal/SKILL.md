---
name: goal
description: 目标生命周期管理。使用 cuando 需要创建、追踪、暂停或完成跨 session 的持久化目标时
---

# Goal — 目标生命周期管理

加载 `maintain-workflow-goal/SKILL.md` 执行目标管理。

## 流程

1. 检测 Codex goal API 可用性（`codex goal status`）
2. 解析子命令：create / list / pause / resume / complete / clear / status
3. 调用对应的 `codex goal <subcommand>` 命令
4. 输出操作结果

## 产出

Codex goal API 的操作结果。目标状态持久化在 Codex 服务端。

## 同时加载

- `CANON.md` — 宪法第 2 条（Simple First）和第 9 条（Structured Questions）
