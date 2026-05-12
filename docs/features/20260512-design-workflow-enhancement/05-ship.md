# Ship Record — 设计工作流增强 v2.16.0

## 变更摘要

v2.16.0 对 `/design` 阶段做了三项系统性增强：

1. **项目级 DESIGN.md** — 新增 Google Stitch token 格式模板，每次 `/design` 批准后自动同步跨 feature 设计约束到项目根 DESIGN.md（Step 6 / Phase 6）
2. **灵感来源增强** — 新增 design-inspiration-catalog.md（20+ 公司索引）+ design-pattern-extract.md（高频模式提炼）+ awesome-design-systems 搜索种子（200+ 设计系统索引）
3. **Codex 视觉生成** — 新增 Step 3.5 / Phase 2.5：codex-rescue agent 生成设计 mockup 图片 → analyze_image 提取结构化 design token（两个产物），可选增强，Codex 不可用时降级

## 变更文件

### 新增
- `templates/root/DESIGN.md` — 项目级设计系统模板
- `references/design-inspiration-catalog.md` — 设计灵感索引
- `references/design-pattern-extract.md` — 高频设计模式提炼

### 修改
- `skills/design-workflow-design/SKILL.md` — Step 3.5 Codex 视觉生成 + Step 6 DESIGN.md 同步 + 灵感来源优先级 + 搜索种子
- `commands/design.md` — Phase 2.5 + Phase 6 + Phase 2 输入更新
- `commands/help.md` — 项目级设计约束说明
- `AGENTS.md` — `/design` 命令映射更新
- `references/design-best-practices.md` — DESIGN.md 角色说明
- `skills/design-*/SKILL.md`（6 个）— catalog/pattern/DESIGN.md 引用
- `validate` — DESIGN.md 模板检查 + Codex 视觉生成检查 + catalog/pattern 存在检查
- `skills-lock.json` — SHA256 哈希更新
- `.claude-plugin/plugin.json` — description UTF-8 编码修复 + 版本 2.16.0

## 审计结果

### 安全审计（ship-security-auditor）

| 级别 | 数量 | 处理 |
|------|------|------|
| Blocking | 0 | 2026-05-12 follow-up 已修复 hook 行为、metadata 漂移和 validate gate 覆盖问题；剩余 preview-server CORS 记录为 Known Debt |
| Important | 4 | I-4 测试数据（淘宝 token）已处理：排除 `20260512-codex-design-test/` 不随发布分发 |
| Suggestion | 6 | S-1 plugin.json description 版本一致性（已修复）、其余为低风险建议，后续迭代处理 |

### 文档审计（ship-docs-auditor）

| 级别 | 数量 | 处理 |
|------|------|------|
| Blocking | 4 | 全部已修复：CHANGELOG v2.16.0 条目已添加；README 新能力已反映 + 重复章节已删除；skills-index.json 已重新生成；validate 模板数已确认 |
| Important | 6 | I-1 Phase/Step 编号错位（设计有意，command 和 skill 层分层抽象）、I-3 模板数已确认、其余为低影响建议 |
| Suggestion | 6 | 后续迭代处理 |

## Go/No-Go

- [x] 安全审计：无本次变更引入的 Blocking
- [x] 文档审计：所有 Blocking 已修复
- [x] validate 全通过（2026-05-12 follow-up 重新运行）
- [x] 测试数据已排除（不随发布分发）

## Known Debt

- `scripts/design-preview.mjs` 仍使用本地预览服务的 `Access-Control-Allow-Origin: *`。当前仅作为 localhost 设计对比工具使用，不阻塞本次合同修复；后续若扩展为共享服务，需要限制 origin、请求体大小和选择 JSON schema。

## 版本

2.16.0
