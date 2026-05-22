---
description: 结构化脑暴——发散探索 + 收敛评估 = 明确方向。当想法模糊、面临开放性问题或需要方案对比，或提到"脑暴""想法""怎么办"
---

# Command: /brainstorm

## Runtime Preflight

本命令是显式 Unified 入口。执行本命令时，先读取 `skills-router.json` 并声明 loading tier（`light` / `standard` / `expanded` / `full`）和选中技能原因。加载本命令必需技能；如 router 命中风险或专项触发，再追加对应 specialist skills。只有 router 无法回答、需要完整库存、或进入 `full` 模式时，才读取 `skills-index.json`。

## Goal

Transform open-ended question or vague idea into 2-3 structured proposals with clear recommendation through **multi-agent parallel brainstorming**.

`/brainstorm` 使用多席位并行脑暴：根据任务类型选择合适的 scout 组合，同时发散探索，然后由 facilitator 收敛整合。

## 使用方式

### 方式 1: 使用预设配置（推荐）
```bash
/brainstorm --profile tech_architecture "如何设计一个高可用的订单系统？"
/brainstorm --profile product_strategy "如何进入中小企业市场？"
/brainstorm --profile content_marketing "如何写一篇有传播力的技术博客？"
```

### 方式 2: 自定义席位
```bash
/brainstorm --seats tech,data,outlier "数据库选型怎么考虑？"
/brainstorm --seats design,content,business "首页改版怎么提升转化率？"
```

### 方式 3: 默认通用脑暴
```bash
/brainstorm "如何提升用户留存率？"
# 使用 general profile: tech + design + business + outlier
```

## 可用配置

运行 `/brainstorm --list-profiles` 查看所有预设配置和 scout 说明。

## 参数解释合同

`/brainstorm` 是 Markdown 阶段协议，不是 shell CLI。执行时由 current agent 解释用户输入中的参数：
- `--list-profiles`：只读取 `commands/brainstorm-menu.json` 并列出 profiles / seats；不启动 scout
- `--profile <name>`：读取 `commands/brainstorm-menu.json`，使用对应 `task_profiles.<name>.seats`
- `--seats a,b,c`：把短名规范化为 `brainstorm-<name>-scout`
- 未提供参数：使用 `commands/brainstorm-menu.json` 的 `default_seats`
- `brainstorm-outlier-scout` 默认自动加入；只有用户明确写 `--no-outlier` 才排除

如果 `commands/brainstorm-menu.json` 缺失或解析失败，STOP 并使用本命令内的 profile 列表作为 fallback，同时在输出中标记配置来源。

## Agents & Roles

**根据选择的 profile 或自定义 seats 动态确定 scout 组合。**

### 可用 Scout
- **brainstorm-tech-scout** — 技术可行性、架构方案、实现路径
- **brainstorm-design-scout** — 用户体验、交互路径、情感连接
- **brainstorm-business-scout** — 产品价值、市场定位、商业模式
- **brainstorm-content-scout** — 叙事结构、受众共鸣、表达方式
- **brainstorm-data-scout** — 数据建模、存储策略、查询优化
- **brainstorm-security-scout** — 威胁模型、防护策略、合规要求
- **brainstorm-outlier-scout** — 边缘视角、激进想法、反向思考（默认参与，可显式 `--no-outlier` 排除）

### Facilitator
- **current agent** — 协调、收敛、整合推荐

## Phases

### Phase 1: Context Exploration

**Agent:** current (facilitator)
**Skills:** define-cognitive-brainstorm（Phase 1）
**Input:** 用户的开放性问题或模糊想法
**Process:**
1. 阅读项目的 AGENTS.md（运行时详细规则在 docs/contracts/ 按需加载）/ spec / plan 了解现状
2. 阅读相关代码——避免脱离代码库的空想
3. 明确约束
**Output:** 上下文摘要 + 约束清单
**Validation:**
- [ ] 项目现状已了解
- [ ] 约束已明确

### Phase 2: Multi-Angle Parallel Brainstorming

**Agent:** 根据 profile/seats 选择的 scouts（并行执行）
**Skills:** define-cognitive-brainstorm（Phase 2）+ 各 scout 的专业视角
**Input:** 上下文摘要 + 约束清单
**Process:**

1. **席位选择**：根据 `--profile` 或 `--seats` 确定参与的 scout
2. **配置读取**：读取 `commands/brainstorm-menu.json`；失败时使用内联 fallback
3. **并行启动**：使用 `Agent` 工具同时启动所有选中的 scout；宿主不支持 subagent 时，由 current agent 按 seat 串行模拟并明确标记 fallback
4. **独立发散**：每个 scout 获得相同的上下文和约束，独立执行：
   - 使用各自的专业框架发散探索
   - Surface Assumptions — 列出假设
   - 输出 2-3 个提案 + Wildcards

**并行执行方式：**
- 使用 `Agent` 工具同时启动所有选中的 scout
- 每个 scout 获得相同的上下文和约束
- 每个 scout 从不同角度发散，互不干扰
- `brainstorm-outlier-scout` 默认参与（除非用户显式 `--no-outlier`）

**Output:** N 份 scout 报告（根据选择的 seats）
**Validation:**
- [ ] 每个 scout 使用了至少 1 个专业框架
- [ ] 每个 scout 输出了 2-3 个提案
- [ ] 每个 scout 有 Wildcards 或激进想法
- [ ] outlier-scout 至少有 1 个"看起来很荒谬"的想法（如果参与）

### Phase 3: Cross-Pollination & Debate

**Agent:** current (facilitator)
**Skills:** define-cognitive-brainstorm（Phase 3）
**Input:** 4 份 scout 报告
**Process:**
1. **Cross-Pollination** — 让 scout 互相阅读报告，找出互补/冲突点
2. **Debate** — 标注争议点，让相关 scout 辩论
3. **Synthesis** — 找出可以合并的方案，找出必须二选一的分歧

**Output:** 交叉 fertilization 报告（互补点/冲突点/合并机会）
**Validation:**
- [ ] scout 之间已互相阅读
- [ ] 争议点已标注
- [ ] 合并机会已识别

### Phase 4: Convergent Evaluation

**Agent:** current (facilitator)
**Skills:** define-cognitive-brainstorm（Phase 4）
**Input:** 交叉 fertilization 报告 + 原始 scout 报告
**Process:**
1. 按评估标准（技术可行性、实现成本、用户体验、维护负担、风险、增长潜力）收敛
2. 输出 2-3 个对比方案（可能是合并后的方案）
3. 给出明确推荐 + 理由
4. 列出"不做清单"
**Output:** 设计文档（决策标准 + 关键假设验证 + 2-3 方案 + 推荐 + 不做清单 + 下一阶段交接）
**Validation:**
- [ ] 2-3 个清晰对比的方案
- [ ] 每个方案有优点、缺点、风险
- [ ] 明确推荐 + 理由
- [ ] "不做清单"有内容
- [ ] 下一阶段交接已写清

---

## Entry Conditions
- [ ] 用户有开放性问题或模糊想法
- [ ] CANON.md 已加载

## Exit Conditions
- [ ] 设计文档已产出
- [ ] 用户已批准方向

## Next Steps
- If approved → `/refine` 或 `define-workflow-spec`（规格化）
- If unclear → 迭代 Phase 2-3

## Constitutional Rules
- CANON.md Clause 1: Surface Assumptions
- CANON.md Clause 7: Push Back

## 实现

加载 CANON.md → 调用 skills/define-cognitive-brainstorm/SKILL.md。
