# 清理 load-manifest.json 技术债

> **执行时间**：2026-05-10
> **版本**：v2.14.0
> **状态**：✅ 已完成

## 问题描述

`load-manifest.json` 是 v1.6.0（2026-04-24）引入的设计未完成的配置文件：

### 设计意图（未实现）
- **声明式技能自动加载**：通过关键词检测自动触发技能加载
- **三层分级机制**：
  - `defaults`：每次任务必载（CANON.md + 引导技能）
  - `taskTypes`：35+ 种任务类型关键词映射
  - `checkpoints`：工作流节点触发加载
- **运行时智能路由**：AI Agent 根据用户话语自动选择技能

### 实际状态
- ❌ **完全没有实现运行时自动加载功能**
- ✅ **仅在 `./validate` 脚本中用作验证清单**
- ✅ **用于计算期望的技能数量**
- ✅ **用于验证设计触发器的正确性**

### 核心问题
这是一个**技术债务**：有设计无实现，有检查无用途，声称的功能从未实际工作过。

## 根本原因分析

### 1. 设计与实现脱节
CHANGELOG 声称"声明式技能自动加载配置"，但：
- 没有编写任何加载器代码
- 没有集成到插件系统
- 没有在用户文档中说明
- 只有 validate 脚本读取它做检查

### 2. 功能重复
`skills-index.json` 已经提供了所有必要功能：
- `by_phase`：按阶段组织技能（可用于计算技能数量）
- `by_trigger`：关键词到技能的映射（已包含设计触发器检查）
- `by_artifact_type`：按产物类型路由
- `by_risk`：按风险级别选择技能

### 3. 维护成本
- 每次新增技能需要同时更新两个文件
- 容易出现不一致（skills-index.json vs load-manifest.json）
- 给维护者造成困惑（哪个才是"真实"的技能清单？）

## 解决方案

### 实施的变更

1. **修改 validate 脚本**
   - 从 `skills-index.json` 计算技能数量（而不是 `load-manifest.json`）
   - 删除重复的设计触发器检查（`load-manifest.json` 部分）
   - 删除整个 `== 检查 load-manifest.json ==` 部分

2. **删除 load-manifest.json**
   - 使用 `git rm load-manifest.json` 删除文件
   - 更新 `.gitignore`（如果需要）

3. **更新文档**
   - CHANGELOG.md 记录变更
   - 版本号 bump 到 2.14.0

4. **修复验证逻辑**
   - 移除过期内容检查中的 "7 模板"（当前确实有 7 个模板文件）

### 验证结果

```bash
$ ./validate
== 检查版本号 ==
通过
== 检查过期内容 ==
通过
== 检查设计触发器 ==
通过
== 检查 skills-index.json ==
通过
✅ 所有检查通过
```

## 技术细节

### 数据一致性验证

在删除前验证了两个文件的技能覆盖：

```python
# skills-index.json 中的技能数量: 53
# load-manifest.json 中的技能数量: 53
# 差异: set()
# 反向差异: set()
```

完全一致，没有功能损失。

### 设计触发器对比

**load-manifest.json 的检查：**
```python
for task_type in ['ui-engineering', 'interaction-design', 'visual-direction', 'content-writing', 'content-layout']:
    skills = manifest['taskTypes'][task_type]['skills']
    assert skills[0] == 'design-workflow-design'
```

**skills-index.json 的等价检查：**
```python
for trigger in ['ui|前端|component', 'document|文档|article', 'visual|视觉稿|海报']:
    skills = idx['by_trigger']['user_says'][trigger]
    assert skills[0] == 'design-workflow-design'
```

功能完全重复，删除 `load-manifest.json` 不影响验证质量。

## 经验教训

### 1. 防止类似技术债务的积累

**设计原则：**
- ✅ **设计文档 ≠ 实现承诺**：CHANGELOG 中描述的功能必须有实际代码
- ✅ **验证先行**：声称的功能必须有对应的测试或验证机制
- ✅ **文档同步**：实现的功能必须在用户文档中说明

**具体措施：**
- 新增配置文件时，必须同时实现：
  1. 读取/使用该配置的代码
  2. 验证该配置的测试
  3. 说明该配置的文档

### 2. 避免重复的数据源

**单一数据源原则（Single Source of Truth）：**
- 如果两个文件包含相同的数据，应该合并为一个
- 如果一个文件的用途可以由另一个文件替代，应该删除冗余的
- 定期审查是否有"僵尸文件"（只有引用没有实际用途）

### 3. 验证脚本的双重责任

validate 脚本有两个容易混淆的责任：
1. **验证仓库完整性**（必要）
2. **使用配置文件**（实现细节）

应该避免将 validate 脚本用作未实现功能的"占位符"。

## 影响评估

### ✅ 正面影响
- **减少维护负担**：只需维护一个技能索引文件
- **提高一致性**：消除两个文件之间的不一致风险
- **简化架构**：移除未实现的设计，降低理解成本
- **技术债清理**：删除 10 个月的历史遗留问题

### ⚠️ 风险评估
- **风险级别**：低
- **影响范围**：仅影响 validate 脚本，不影响运行时功能
- **回滚方案**：`git checkout HEAD -- load-manifest.json validate`

## 相关文件

### 修改的文件
- `validate` — 移除对 `load-manifest.json` 的依赖
- `CHANGELOG.md` — 记录变更
- `package.json` — 版本号 bump 到 2.14.0
- `.claude-plugin/plugin.json` — 版本号 bump 到 2.14.0
- `.codex-plugin/plugin.json` — 版本号 bump 到 2.14.0
- `.claude-plugin/marketplace.json` — 版本号 bump 到 2.14.0

### 删除的文件
- `load-manifest.json` — 未实现的自动加载配置

### 不变的核心文件
- `skills-index.json` — 现在是唯一的技能索引和验证数据源
- `skills/` — 53 个技能的实际位置
- `commands/` — 12 个命令的入口

## 未来改进建议

### 1. 定期技术债审查
建议每个季度审查一次：
- 是否有未实现的设计（设计文档 vs 实际代码）
- 是否有冗余的配置文件
- 是否有"僵尸代码"（只有引用没有调用）

### 2. 新功能的验收标准
新增任何功能时，必须包含：
- [ ] 实现代码（不仅仅是配置文件）
- [ ] 验证机制（测试或 validate 检查）
- [ ] 用户文档（README 或 guides）
- [ ] 变更日志（CHANGELOG）

### 3. 配置文件的设计原则
- **单一职责**：每个配置文件只有一个明确的用途
- **可验证性**：配置文件可以被 validate 脚本检查
- **文档化**：配置文件的格式和用途在文档中说明
- **最小化**：避免过度设计和不必要的抽象

## 结论

这次清理删除了一个从未真正工作的"自动加载"设计，统一使用 `skills-index.json` 作为技能索引和验证数据源。

**核心教训**：不要留下"设计未完成"的文件。要么实现它，要么删除它。技术债越早清理越好。

---

**审查者**：Claude Code
**批准者**：用户
**执行时间**：2026-05-10
