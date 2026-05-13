---
name: maintain-workflow-goal
description: 目标生命周期管理。当需要创建、追踪、暂停或完成跨 session 的持久化目标时
---

# Goal — 目标生命周期管理


## 入口/出口
- **入口**: 用户请求创建/管理目标，或 workflow 命令完成后需要更新目标状态
- **出口**: Codex goal API 操作完成，目标状态已更新
- **指向**: 目标可关联 `/refine` → `/plan` → `/build` → `/review` → `/ship` 产出
- **假设已加载**: CANON.md

## 何时不使用
- 只是普通任务说明，不需要跨 session 持久目标
- 用户没有要求创建、更新、完成或查看目标
- 目标 API 不可用且用户没有要求替代记录方式

## 前置检测

执行前必须检测 Codex goal API 可用性：

```bash
codex goal status 2>/dev/null
```

- 返回 0 → API 可用，使用 Codex 原生命令
- 返回非 0 → API 不可用，输出提示并退出（不实现 fallback）

## 子命令

### /goal create \<title\>

创建新的活跃目标：

```bash
codex goal create "<title>"
```

可选参数：
- `--phase <phase>` — 关联工作流阶段（refining / planning / building / reviewing / shipping）
- `--spec <path>` — 关联 spec 文件路径
- `--plan <path>` — 关联 plan 文件路径

创建后自动设为活跃目标。

### /goal list

显示所有目标：

```bash
codex goal list
```

输出格式：
```
Goals:
  [active]    #1 "Implement auth system" — phase: building
  [paused]    #2 "Refactor database layer" — phase: planning
  [completed] #3 "Add logging" — phase: shipped
```

### /goal pause \<id\>

暂停目标（保留状态）：

```bash
codex goal pause <id>
```

### /goal resume \<id\>

恢复暂停的目标：

```bash
codex goal resume <id>
```

### /goal complete \<id\>

标记目标完成：

```bash
codex goal complete <id>
```

### /goal clear \<id\>

删除目标：

```bash
codex goal clear <id>
```

### /goal status（默认）

显示当前活跃目标和工作流阶段：

```bash
codex goal status
```

无参数时 `/goal` 等同于 `/goal status`。

## 工作流集成

目标与工作流的关系是 **advisory**（建议性），不是 blocking（阻塞性）：

| 工作流命令 | 目标交互 |
|-----------|---------|
| `/refine` 完成 | 可选：更新目标 phase 为 refining，关联 spec 路径 |
| `/plan` 完成 | 可选：更新目标 phase 为 planning，关联 plan 路径 |
| `/build` 完成 | 可选：更新目标 phase 为 building |
| `/review` 完成 | 可选：更新目标 phase 为 reviewing |
| `/ship` 完成 | 可选：更新目标 phase 为 shipping |

工作流命令 **不依赖** 目标存在。目标是追踪工具，不是流程门禁。

## 与 /save 和 /learn 的关系

| 机制 | 定位 | 生命周期 |
|------|------|---------|
| `/goal` | 持久化意图 | create → pursue → complete → clear |
| `/save` | 时间点快照 | 创建 → 恢复 → 过期 |
| `/learn` | 知识积累 | 追加 → 搜索 → 修剪 |

目标可以引用 checkpoint 和 learning 作为上下文，但三者独立运作。

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "目标记在脑子里就行" | 跨 session 的意图会丢失。一条 goal 避免一次方向偏移就回本。 |
| "用 /save 就够了" | save 是快照，不是意图。快照告诉你"当时在做什么"，goal 告诉你"要达成什么"。 |
| "目标太抽象，不如直接写代码" | 目标是导航仪，不是枷锁。5 秒创建目标，省 50 分钟找回方向。 |
| "我只有一个任务，不需要 goal" | 单任务也有完成标准。goal 迫使你定义"done"是什么。 |
| "Codex API 不可用就没用了" | API 不可用时提示退出，不造轮子。等 API 恢复再用。 |

## 红旗 — STOP

- 目标标题超过 20 个字 — 太模糊。goal 是一句话意图，不是 PRD。拆成多个小目标。
- 同时有超过 3 个活跃目标 — 注意力分散。聚焦最重要的 1-2 个，其余 pause。
- 目标没有关联任何产出 — 纯口号。goal 必须可验证：有 spec？有 plan？有代码？
- 目标创建后从未更新状态 — 僵尸目标。要么推进，要么 clear。
- 尝试用 goal 替代 spec 或 plan — goal 是意图追踪，不是需求文档。需求走 `/refine`。
- API 返回错误但静默忽略 — 必须报告错误，不能假装成功。

## 验证清单

- [ ] API 可用性检测已执行（codex goal status）
- [ ] 子命令名称正确（create/list/pause/resume/complete/clear/status）
- [ ] 目标标题简洁（不超过 20 字）
- [ ] 活跃目标不超过 3 个
- [ ] 操作结果已反馈给用户（成功/失败/状态变更）
- [ ] 未尝试在 API 不可用时实现 fallback
