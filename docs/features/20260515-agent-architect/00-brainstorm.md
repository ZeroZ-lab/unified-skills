# 设计: Agent 架构重造

## 背景

Unified 的 24 个 agent 定义文件当前只使用 `name` + `description` frontmatter，body 内容过长（最长 172 行），缺少 Claude Code 原生 agent 功能（tools 限制、model 路由、hooks 护栏、isolation），description 不含触发条件导致委派精准度低。本次重造目标是让 agent 从"手工写长 prompt"升级到"结构化 frontmatter + 轻量 body + 技能辅助文件注入"，使每个 agent 更聚焦、更安全、更高效。

## 假设

1. agent 主要被阶段技能统一调度（teammate 模式），而非独立委派——因此 frontmatter `skills` 字段不加入（teammate 场景不生效）
2. body 精简到 <50 行不会丢失关键行为塑造——核心行为（角色 + 核心指令 + 不负责清单）足够，评分表/模板/示例应下沉到技能辅助文件
3. 审计类 agent 不需要写权限——PreToolUse hooks（`agents/hooks/`）+ `tools` allowlist 双重保障
4. `agents/` 目录位置不变（作为插件 `agents/` 目录是正确的）
5. 非标准 frontmatter 字段（`role`, `phase`）应清理——Claude Code 忽略它们
6. 红旗表/常见说辞表保留核心 3-5 条在 body，其余下沉到技能辅助文件

## 方案

### 方案 B: 架构重造（选定方案）

- 做法:
  1. 每个 agent body 精简到 <50 行：角色定义 + 核心行为指令 + 不负责清单 + 输出格式指针（引用辅助文件名而非内联模板）
  2. 评分表、输出模板、审查维度、示例 → 下沉到技能辅助 `.md` 文件，由主 SKILL.md 引用并纳入 `skills-lock.json` 的 `auxiliaryHashes`
  3. frontmatter 补齐：`tools`（审计类只读）、`model`（按角色路由）、`maxTurns`、`description`（触发式）、`isolation: worktree`（写操作类）
  4. 审计类 agent 加 `hooks: PreToolUse`（引用 `agents/hooks/` 共享模板）阻止 Edit/Write/Bash
  5. 清理非标准字段（`role`, `phase`）
  6. 红旗表/常见说辞表保留核心 3-5 条在 body，其余下沉到技能辅助 `.md` 文件
  6. 创建共享 hook 配置模板（`agents/hooks/` 目录，同类 agent 引用而非重复配置）
  7. 分 3 批执行，每批跑 `./validate` + `generate-index.sh`

- 优点:
  - 彻底解决 body 过长问题，agent 更聚焦更可维护
  - 利用 Claude Code 全部原生 agent 能力（tools/model/hooks/isolation）
  - 审计类 agent 有双重安全护栏（tools allowlist + hooks）
  - 评分表和模板在技能辅助文件中独立维护，agent body 不需要同步更新
  - 触发式 description 提高委派精准度

- 缺点:
  - 改动量大（24 个 agent + 多个辅助文件 + hook 模板）
  - 红旗表/常见说辞表保留核心 3-5 条在 body，其余下沉到技能辅助文件——行为塑造核心不丢失，细节独立维护
  - skills frontmatter 在 teammate 场景不生效，知识注入仍依赖阶段技能手动加载

- 风险:
  - 精简 body 可能丢失行为塑造细节（红旗表/常见说辞表的措辞经过设计）——缓解：保留核心 3-5 条在 body
  - 大规模修改可能破坏现有调度逻辑——缓解: 分 3 批执行每批 validate

## 推荐

**选择方案 B** 因为: 从"手工长 prompt"到"结构化 agent"是质变而非量变。渐进补丁（方案 A/C）改动量也不小但只解决了表面问题。B 分批执行风险可控。

## 不做

- 不给 agent 加 `memory` 字段 — 当前 agent 由阶段技能一次性调度，不需要跨 session 记忆
- 不合并重叠 agent — 24 个职责边界清晰，没有需要合并的
- 不搬 `agents/` 到 `.claude/agents/` — 作为插件目录位置正确
- 不加 frontmatter `skills` 字段 — teammate 场景不生效，当前主要场景是技能调度
- 不给所有 agent 加 `background: true` — 审查类需要同步交互

## 已确认决策

1. **Agent 支持 hooks** — 插件 agent 支持 `hooks` frontmatter，审计类 agent 可用 PreToolUse hooks + `tools` allowlist 双重保障
2. **红旗表/常见说辞表** — 保留核心 3-5 条在 body，其余下沉到技能辅助文件
3. **共享 hook 模板位置** — `agents/hooks/` 目录

## 执行计划（3 批）

| 批次 | 范围 | Agent 数 | 关键改动 |
|------|------|----------|---------|
| Batch 1 | 审计类（review-* + ship-*） | 8 | tools 限制 + hooks + model:sonnet + body 精简 |
| Batch 2 | 侦察类（refine-* + plan-*） | 7 | model 路由 + body 精简 + description 触发式 |
| Batch 3 | 核心角色（software-engineer, task-planner 等） | 9 | isolation:worktree + tools + model + body 精简 |