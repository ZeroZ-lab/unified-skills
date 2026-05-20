# Contributing to Unified Skills

## 近期复盘：合同漂移修复后的硬经验

- `./validate` 通过不代表合同一致。改动技能、包装、根文档、hooks 行为或产物链时，必须额外检查：
  - `skills-index.json` 是否仍与 `skills/` 中的真实技能集一致
  - 根文档与包装层是否仍引用同一产物路径（如 `05-ship.md`）
  - 安全相关行为说明是否仍与真实 hook 实现一致
- `skills-index.json` 不是说明性文件，而是默认技能发现路径的一部分。新增、重命名、删除技能后，必须同步更新：
  - `by_phase`
  - 其他索引段中的技能引用
  - `skill_descriptions`
- 入口收口后，`AGENTS.md` 是统一项目约束源，`CLAUDE.md` 只保留指针职责。改动入口文档时，不要再把完整合同复制回 `CLAUDE.md`。
- 历史设计文档会反向污染当前合同。旧 spec/plan/优化报告里如果保留过时方案，必须显式标注"历史 / 已过期"，不能让它们继续像当前真相一样表述。
- 改动任何 `SKILL.md` 或技能辅助 `.md` 文件后，除了跑 `./validate`，还要确认 `skills-lock.json` 中 `computedHash` / `auxiliaryHashes` 已同步更新；否则仓库会在最后一步才暴露漂移。

## 自动化工具使用

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
| 版本号不一致 | 手动编辑 package / plugin metadata / router | `sync-version.sh` |
| 索引漂移 | 手动更新 skills-index.json | `generate-index.sh` |
| 技能缺失 | 人工检查 | `validate` 自动检测 |

**何时使用自动化工具：**

- **发版前:** 运行 `sync-version.sh` 确保版本一致
- **修改技能后:** 运行 `generate-index.sh` 更新索引
- **提交前:** 运行 `validate` 确保无漂移
- **CI/CD:** 集成 `validate` 作为质量门控

## 多平台挂载

技能支持多平台挂载：

- **Claude Code**: `commands/` 提供斜杠命令入口，`skills/` 是真实技能目录
- **Codex CLI**: 直接读取 `AGENTS.md` 与 `skills/`，不再维护 repo 内薄包装命令目录

## 修改实时生效

对 SKILL.md 的修改在下一次调用时立即生效。这意味着：
- 重构期间的破坏性变更可能导致并行 session 出错
- 大规模修改前先在隔离环境中测试
