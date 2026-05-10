# Subplan 03: 历史文档标记

## Subplan Contract

- **Owner:** content-writer
- **Status:** parallel_safe
- **Depends On:** none
- **Write Scope:** `docs/features/*/README.md`, `docs/architecture/command-agent-skill-architecture.md`
- **Read Scope:** `docs/features/README.md`
- **Verification Evidence:** 所有历史文档都有明确的标记
- **Merge Checkpoint:** 5 个历史文档都有清晰的历史/过期标记

## 任务列表

### Task 3.1: 标记 Minecraft City 示例为历史文档

**Files:**
- Modify: `docs/features/20260426-minecraft-city/README.md`

**依赖:** Task 0（项目初始化）

**复杂度:** 低

**验收标准:**
- [ ] README.md 顶部有"历史样例"标记
- [ ] 说明这不是活跃项目
- [ ] 说明最后更新时间和适用版本

**标记模板:**

```markdown
# Minecraft City - 历史样例

> **⚠️ 历史文档**
>
> 这是 Unified Skills v2.8.0 时期的功能示例，保留作为格式参考。
>
> **状态:** 非活跃项目，仅供格式参考
> **最后更新:** 2026-04-26
> **适用版本:** v2.8.x

## 文档说明

本目录展示 Unified Skills 标准产物链格式的创造模式项目。
只包含 `spec` 和 `plan`，不是完整产物链。
```

---

### Task 3.2: 标记 Codex Hooks Commands 为已完成功能

**Files:**
- Modify: `docs/features/20260427-codex-hooks-commands/README.md`

**依赖:** Task 0（项目初始化）

**复杂度:** 低

**验收标准:**
- [ ] README.md 顶部有"已实现"标记
- [ ] 说明实现版本和发布日期
- [ ] 提供相关文档链接

**标记模板:**

```markdown
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
- README.md - Codex setup 章节
- .codex/config.toml - hooks 配置示例
- .codex/hooks.json - hooks 定义
```

---

### Task 3.3: 标记 Iron Law Injection 为历史设计

**Files:**
- Modify: `docs/features/20260427-iron-law-injection/README.md`

**依赖:** Task 0（项目初始化）

**复杂度:** 低

**验收标准:**
- [ ] README.md 顶部有"历史设计"标记
- [ ] 说明这是早期设计讨论
- [ ] 指向当前实现

**标记模板:**

```markdown
# Iron Law Injection - 历史设计

> **📜 历史设计**
>
> 这是 Unified Skills 早期关于 Iron Law 注入的设计讨论。
>
> **状态:** 历史设计文档
> **讨论日期:** 2026-04-27
> **当前状态:** Iron Law 已在多个技能中实现

## 设计说明

本文档记录了 Iron Law 注入机制的早期设计思路。
当前实现请参考各强纪律技能的 Iron Law 章节：

- build-quality-tdd/SKILL.md
- verify-workflow-debug/SKILL.md
- verify-workflow-review/SKILL.md
- ship-workflow-ship/SKILL.md
- verify-quality-security/SKILL.md
```

---

### Task 3.4: 完善特性文档索引

**Files:**
- Modify: `docs/features/README.md`

**依赖:** Task 3.1, Task 3.2, Task 3.3

**复杂度:** 低

**验收标准:**
- [ ] 清晰区分活跃文档和历史文档
- [ ] 为每个历史文档添加状态说明
- [ ] 提供跳转到相关文档的链接

**更新内容:**

在"当前目录说明"章节后添加：

```markdown
## 文档状态说明

Unified 的特性文档分为三类：

### 活跃文档
- 当前正在进行或最近完成的项目
- 包含完整的产物链（spec → design → plan → build → review → ship）
- 代表最新工作流和最佳实践

### 历史样例目录（非活跃项目）

以下目录保留作为格式和演进痕迹，**不是"进行中"的项目**：

- `20260426-minecraft-city/`：Minecraft 项目示例（非 Unified 功能）
  - **状态:** 📜 历史样例，v2.8.0 时期的功能示例
  - **用途:** 展示标准产物链格式的创造模式项目

- `20260427-codex-hooks-commands/`：Codex Hooks 支持（✅ 已完成）
  - **状态:** 已在 v2.13.3 实现
  - **参见:** CHANGELOG.md v2.13.3

- `20260427-iron-law-injection/`：Iron Law 注入设计（📜 历史设计）
  - **状态:** 历史设计文档
  - **当前:** Iron Law 已在多个技能中实现

### 已完成文档
- 功能已发布并合并到主分支
- 保留作为实现记录和参考
```

---

## 验证证据

### 自动检查

```bash
# 检查所有历史文档都有标记
for dir in docs/features/20260426-* docs/features/20260427-*; do
  if [ -f "$dir/README.md" ]; then
    echo "Checking $dir/README.md..."
    head -30 "$dir/README.md" | grep -E "历史|已实现|已完成|历史样例|历史设计" || {
      echo "WARNING: No historical marker found in $dir/README.md"
    }
  fi
done
```

### 手动验证

```bash
# 1. 查看特性文档索引
cat docs/features/README.md | grep -A 30 "文档状态说明"

# 2. 验证每个历史文档的标记
head -20 docs/features/20260426-minecraft-city/README.md
head -20 docs/features/20260427-codex-hooks-commands/README.md
head -20 docs/features/20260427-iron-law-injection/README.md
```

---

## 文档标记原则

### 标记类型

| 类型 | 图标 | 含义 | 使用场景 |
|------|------|------|----------|
| 历史样例 | 📜 | 早期功能示例，仅供参考 | 版本过时的示例项目 |
| 已完成 | ✅ | 功能已实现并发布 | 已合并的功能开发 |
| 历史设计 | 📜 | 早期设计讨论 | 已实现的设计文档 |
| 进行中 | 🚧 | 正在开发的功能 | 当前活跃项目 |
| 已废弃 | ❌ | 不再推荐使用 | 被新方案替代的功能 |

### 标记位置

所有标记应放在文档顶部，在标题之后，作为第一个章节。

### 标记格式

```markdown
> **<图标> <状态>**
>
> 简短说明（1-2 句话）
>
> **状态:** 详细状态描述
> **版本/日期:** 相关版本或日期信息
> **链接:** 相关文档链接
```

---

## 后续集成

此子计划完成后，将在 Subplan 05 中更新主文档引用这些历史标记。
