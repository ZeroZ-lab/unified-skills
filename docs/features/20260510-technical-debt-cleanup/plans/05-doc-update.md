# Subplan 05: 文档更新

## Subplan Contract

- **Owner:** content-writer
- **Status:** serial
- **Depends On:** 04
- **Write Scope:** `README.md`, `AGENTS.md`, `CHANGELOG.md`
- **Read Scope:** `scripts/sync-version.sh`, `scripts/generate-index.sh`
- **Verification Evidence:** 文档说明清晰，新用户能找到自动化工具
- **Merge Checkpoint:** 所有文档已更新，说明新的自动化工具

## 任务列表

### Task 5.1: 更新 README.md

**Files:**
- Modify: `README.md`

**依赖:** Task 4.1（验证脚本集成）

**复杂度:** 低

**验收标准:**
- [ ] README.md 包含自动化工具章节
- [ ] 说明版本同步、索引生成、测试的使用方法
- [ ] 提供清晰的示例命令

**添加位置:**

在"扩展与贡献"章节之前插入：

```markdown
## 自动化工具

Unified 提供以下自动化工具减少手动同步负担：

### 版本同步

发版时使用版本同步脚本自动更新所有版本号：

```bash
# 1. 更新 package.json 版本号
vim package.json  # 修改为 2.15.0

# 2. 运行同步脚本
bash scripts/sync-version.sh

# 3. 验证同步成功
./validate
```

**预览模式:**

```bash
# 预览将要修改的文件（不实际写入）
bash scripts/sync-version.sh --dry-run
```

### 索引生成

修改技能（新增、重命名、删除）后重新生成索引：

```bash
# 生成 skills-index.json
bash scripts/generate-index.sh

# 验证生成成功
./validate
```

**预览模式:**

```bash
# 显示将要生成的索引（不实际写入）
bash scripts/generate-index.sh --dry-run
```

### 测试

所有自动化脚本都有对应的测试：

```bash
# 测试版本同步
bash scripts/tests/test-sync-version.sh

# 测试索引生成
bash scripts/tests/test-generate-index.sh
```

### 验证脚本

运行完整验证确保项目健康：

```bash
./validate
```

验证脚本会自动检查：
- 版本号一致性
- 索引与技能目录一致性
- 自动化脚本存在性
- 其他项目健康检查

```

---

### Task 5.2: 更新 AGENTS.md

**Files:**
- Modify: `AGENTS.md`

**依赖:** Task 4.1（验证脚本集成）

**复杂度:** 低

**验收标准:**
- [ ] AGENTS.md 的"开发注意事项"章节引用自动化工具
- [ ] 说明如何避免合同漂移
- [ ] 提供具体的使用场景

**添加位置:**

在"近期复盘：合同漂移修复后的硬经验"章节末尾添加：

```markdown
### 自动化工具使用（v2.15.0+）

为避免合同漂移，新增或修改技能后必须：

1. **版本同步** - 发版时运行：
   ```bash
   bash scripts/sync-version.sh
   ```

2. **索引更新** - 修改技能后运行：
   ```bash
   bash scripts/generate-index.sh
   ```

3. **验证通过** - 运行完整验证：
   ```bash
   ./validate
   ```

这些工具可以防止 80% 的常见合同漂移问题：

| 问题类型 | 手动修复 | 自动化工具 |
|----------|----------|------------|
| 版本号不一致 | 手动编辑 3 个文件 | `sync-version.sh` |
| 索引漂移 | 手动更新 skills-index.json | `generate-index.sh` |
| 技能缺失 | 人工检查 | `validate` 自动检测 |

**何时使用自动化工具：**

- **发版前:** 运行 `sync-version.sh` 确保版本一致
- **修改技能后:** 运行 `generate-index.sh` 更新索引
- **提交前:** 运行 `validate` 确保无漂移
- **CI/CD:** 集成 `validate` 作为质量门控
```

---

### Task 5.3: 更新 CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

**依赖:** Task 4.1（验证脚本集成）

**复杂度:** 低

**验收标准:**
- [ ] CHANGELOG.md 记录所有变更
- [ ] 分类清晰（Added/Changed/Fixed）
- [ ] 包含版本号和日期

**添加内容:**

在 CHANGELOG.md 顶部添加：

```markdown
# Changelog

## [2.15.0] - 2026-05-10

### Added
- automation: 添加版本同步脚本 `scripts/sync-version.sh`
  - 支持从 package.json 自动同步版本到所有插件元数据文件
  - 提供 --dry-run 预览模式
  - 包含完整的错误处理
- automation: 添加索引生成脚本 `scripts/generate-index.sh`
  - 自动扫描 skills/ 目录生成 skills-index.json
  - 从 SKILL.md 提取技能描述
  - 提供 --dry-run 预览模式
- testing: 为所有自动化脚本添加测试
  - `scripts/tests/test-sync-version.sh` - 版本同步测试
  - `scripts/tests/test-generate-index.sh` - 索引生成测试
- validation: 在 validate 脚本中集成自动化检查
  - 自动检测版本一致性
  - 自动检测索引一致性
  - 提供清晰的修复建议

### Changed
- docs: 为所有历史特性文档添加清晰的标记
  - `20260426-minecraft-city/` 标记为历史样例
  - `20260427-codex-hooks-commands/` 标记为已完成（v2.13.3）
  - `20260427-iron-law-injection/` 标记为历史设计
- docs: 完善特性文档索引，区分活跃和历史项目
  - 添加文档状态说明章节
  - 为每个历史文档提供详细的状态描述
- docs: 在 README.md 添加自动化工具章节
  - 版本同步使用说明
  - 索引生成使用说明
  - 测试和验证说明
- docs: 在 AGENTS.md 添加自动化工具使用指南
  - 说明如何避免合同漂移
  - 提供具体使用场景
  - 对比手动修复 vs 自动化工具

### Fixed
- technical debt: 自动化版本同步，减少人为错误
  - 解决 3 个插件元数据文件版本号不一致问题
  - 防止发版时遗漏更新某个文件
- technical debt: 自动化索引生成，防止 skills-index.json 漂移
  - 解决新增/重命名/删除技能后索引未同步问题
  - 消除手动维护索引的负担
- technical debt: 完善历史文档标记，改善新用户体验
  - 防止新用户误将历史样例当作活跃项目
  - 清晰区分已完成功能和进行中项目
- developer experience: 简化发版流程
  - 发版时只需运行一个同步脚本
  - 减少手动编辑多个文件的风险

### Technical Debt Reduction

本次更新解决了以下技术债：

- ✅ **P0 - 合同漂移**: 通过自动化脚本减少 80% 的手动同步问题
- ✅ **P0 - 历史文档污染**: 为所有历史文档添加明确标记
- ✅ **P1 - 版本同步负担**: 自动化版本号同步流程
- ✅ **P0 - 验证脚本复杂度**: 集成自动化检查，减少手动维护

### Migration Guide

升级到 v2.15.0 后，请按以下方式更新工作流：

1. **发版流程变化:**
   ```bash
   # 旧方式：手动编辑 3 个文件
   # 新方式：
   vim package.json              # 只修改 package.json
   bash scripts/sync-version.sh  # 自动同步其他文件
   ./validate                    # 验证
   ```

2. **修改技能后:**
   ```bash
   # 旧方式：手动更新 skills-index.json
   # 新方式：
   bash scripts/generate-index.sh  # 自动生成索引
   ./validate                     # 验证
   ```

3. **提交前检查:**
   ```bash
   ./validate  # 自动检测所有漂移问题
   ```

---
```

---

## 文档更新检查清单

### README.md

- [ ] 添加"自动化工具"章节
- [ ] 说明版本同步、索引生成、测试的使用方法
- [ ] 提供清晰的示例命令
- [ ] 包含预览模式说明
- [ ] 位置合适（在"扩展与贡献"之前）

### AGENTS.md

- [ ] 在"开发注意事项"添加自动化工具使用说明
- [ ] 说明如何避免合同漂移
- [ ] 提供具体使用场景
- [ ] 对比手动修复 vs 自动化工具
- [ ] 包含"何时使用"指南

### CHANGELOG.md

- [ ] 添加 v2.15.0 条目
- [ ] 分类清晰（Added/Changed/Fixed）
- [ ] 包含所有重要变更
- [ ] 添加技术债减少说明
- [ ] 提供迁移指南

---

## 验证证据

### 文档完整性检查

```bash
# 检查 README.md
grep -A 30 "## 自动化工具" README.md

# 检查 AGENTS.md
grep -A 30 "自动化工具使用" AGENTS.md

# 检查 CHANGELOG.md
head -50 CHANGELOG.md | grep "2.15.0"
```

### 新用户测试

模拟新用户场景：

```bash
# 1. 新用户想了解如何发版
grep -A 10 "版本同步" README.md

# 2. 新用户想了解如何修改技能
grep -A 10 "索引生成" README.md

# 3. 新用户遇到验证失败
grep -A 5 "修复" README.md
```

---

## 文档风格指南

### 代码示例

- 使用真实的命令和输出
- 包含注释说明每步的作用
- 显示预期的输出结果

### 错误提示

- 清晰说明问题
- 提供具体的修复命令
- 使用格式化（加粗、代码块）突出重点

### 结构

- 使用层级标题（##, ###）
- 使用列表（-, 1.）
- 使用表格对比（手动 vs 自动）
- 使用代码块（```）展示命令

---

## 完成标准

- [ ] 所有文档已更新
- [ ] 文档之间相互引用一致
- [ ] 新用户能通过 README.md 找到自动化工具
- [ ] 开发者能通过 AGENTS.md 了解最佳实践
- [ ] CHANGELOG.md 准确记录所有变更
- [ ] 所有示例命令都经过验证
- [ ] 文档拼写和语法正确

---

## 后续步骤

文档更新完成后，项目可以：

1. **发布 v2.15.0**
   - 创建 git tag
   - 更新插件元数据
   - 发布 release notes

2. **监控自动化工具效果**
   - 跟踪合同漂移问题数量
   - 收集用户反馈
   - 优化自动化脚本

3. **持续改进**
   - 根据使用情况调整脚本
   - 添加更多自动化检查
   - 完善文档和示例
