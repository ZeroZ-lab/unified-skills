# 设计: Skills + Agents 质量优化

## 背景

Unified 当前有两类行为塑造资产：

- `skills/`: 54 个真实技能，是阶段流程、硬门、红旗、验证证据和上下游合同的主要承载层。
- `agents/`: 24 个 persona 定义文件，加 `agents/README.md` 作为索引；agent 不是独立路由器，调用时机必须由对应阶段技能或技能辅助文件定义。

已有两个相关方向：

- `docs/features/20260515-skills-optimization/`: 聚焦 SKILL.md 的行为塑造力评分和分层优化。
- `docs/features/20260515-agent-architect/`: 聚焦 agent frontmatter、body 精简、工具限制和模型路由。

新问题不是单独优化 skills 或 agents，而是让二者形成同一个质量系统：skill 决定何时加载和硬门，agent 承担被选中后的角色边界，validate 防止合同漂移。

## 假设

1. "优化质量"的核心目标是提升 agent 实际行为，而不是让文档更长。
2. `skills/` 仍是权威流程层；`agents/` 只能定义 persona，不能创建额外路由规则。
3. 现有 `./validate` 能防结构漂移，但不能充分衡量行为塑造质量。
4. 旧文档中的静态数量可能漂移，后续方案应从目录、索引和 validate 动态取数。
5. 大规模一次性改所有 skills + agents 风险过高，必须分批、可验证、可回滚。
6. 质量优化不能放松 CANON、Iron Law、HARD-GATE、"human partner" 等既有行为合同。

## 方案

### 方案 A: 分开优化 Skills 和 Agents

- 做法:
  1. 沿用 `skills-optimization`，先做 SKILL.md 五轴评分和分层优化。
  2. 沿用 `agent-architect`，再做 agent frontmatter 和 body 结构改造。
  3. 每个方向独立产出 spec / plan / build / review。

- 优点:
  - 范围清晰，改动批次容易控制。
  - 可以复用已有文档，启动成本低。
  - 不容易把 skill 流程层和 agent persona 层混在一起。

- 缺点:
  - 两条线可能各自正确，但整体调用链仍然断裂。
  - agent 的输出格式和 skill 的消费合同可能不同步。
  - 旧文档里的静态库存数字已经出现漂移风险。

- 推荐: 否。可作为执行拆分方式，但不应作为总方案。

### 方案 B: 统一质量模型 + 分层改造（推荐）

- 做法:
  1. 先定义统一质量模型，把每个 skill-agent 调用链作为审查单元，而不是只审单个文件。
  2. 对 skills 继续使用五轴评分：可操作性、示例充足性、行为收敛性、跨技能衔接、说辞表质量。
  3. 对 agents 增加五轴评分：职责边界、触发条件、工具/权限边界、输出可消费性、与阶段技能一致性。
  4. 建立调用链矩阵：阶段技能 -> 可选 agent -> 必需 sub-skill -> 输出合同 -> validate 覆盖项。
  5. 先修矩阵中的 Blocking 漏洞，再分批优化低分 skill / agent。
  6. 最后把可客观检测的规则加入 `validate`，主观评分保留为审查表。

- 优点:
  - 能直接发现真正影响行为的漏洞：例如 agent 有能力但 skill 没有消费点，或 skill 要求输出但 agent 模板不产出。
  - 保持 `skills/` 权威层不变，避免把路由逻辑塞回 `agents/`。
  - 可以复用已有两个方向，同时修正它们的边界和静态数量漂移。

- 缺点:
  - Phase 0 审计成本更高，需要先做调用链矩阵。
  - 部分质量项只能人工审查，不能全部自动化。
  - 需要小心区分"结构门禁"和"主观质量评分"，避免把 validate 做成不可维护的规则堆。

- 风险:
  - 风险: agent 改造引入宿主不支持的 frontmatter 字段。
    缓解: 先用最小样本验证宿主实际识别字段，再批量改。
  - 风险: 质量评分诱导所有技能变长。
    缓解: 评分标准只奖励行为清晰和可验证输出，不奖励行数。
  - 风险: 修改技能后忘记同步 `skills-index.json` / `skills-router.json` / `skills-lock.json`。
    缓解: 每批固定运行 `scripts/generate-index.sh`、`scripts/generate-router.sh`、`scripts/update-lock.sh` 和 `./validate`。

- 推荐: 是。它解决的是系统质量，而不是局部文档质量。

### 方案 C: 先做自动化质量门，再反推内容优化

- 做法:
  1. 先扩展 `validate`，加入更多 agent/skill 结构检查。
  2. 让失败项驱动内容修改。
  3. 所有无法自动检测的主观质量暂时不处理。

- 优点:
  - 自动化收益明确，回归防护强。
  - 可以快速消灭明显结构漏洞。

- 缺点:
  - 容易优化成"通过检查"而不是"行为变好"。
  - 很多关键质量点无法安全自动判断，例如常见说辞是否真的改变 agent 行为。
  - 过早扩展 validate 会把尚未成熟的主观标准固化。

- 推荐: 否。自动化应该放在后段沉淀，不应作为起点。

## 推荐

**选择方案 B: 统一质量模型 + 分层改造。**

原因:

1. 这个仓库的真实风险不是缺少单个好 skill 或好 agent，而是 skill、agent、router、index、validate 之间的合同漂移。
2. AGENTS 已明确 `agents/` 不是路由器，所以质量优化必须从阶段技能的消费点出发。
3. 已有 `skills-optimization` 和 `agent-architect` 两份文档可以复用，但必须先合并到一个统一模型，避免两条线分别演进后互相打架。

建议执行路径:

| Phase | 内容 | 产出 | 验证 |
|------|------|------|------|
| Phase 0 | 盘点调用链矩阵和质量评分标准 | `quality-matrix.md` + 评分表 | 当前目录、索引、router、validate 对齐 |
| Phase 1 | 修 Blocking 漏洞 | skill-agent 消费合同一致 | `./validate` + targeted grep |
| Phase 2 | 优化 Tier 1 阶段技能和对应 agent | 高杠杆流程质量提升 | spot-check 3 条端到端阶段路径 |
| Phase 3 | 优化 Tier 2/3 skills 和剩余 agents | 长尾质量拉齐 | 每批 update lock + validate |
| Phase 4 | 沉淀自动化门禁 | validate 增量规则 + 文档更新 | validate 能捕获已修过的漂移类型 |

## 统一评分模型

### Skill 五轴

| 维度 | 目标 |
|------|------|
| 可操作性 | 每个步骤都有具体动作、输入、输出和检查点 |
| 示例充足性 | 至少有好/坏示例或输出模板 |
| 行为收敛性 | 红旗可检测，STOP 后动作明确 |
| 跨技能衔接 | 入口、出口、加载前提、产物路径明确 |
| 说辞表质量 | 说辞、现实、后果能推动 agent 改变行为 |

### Agent 五轴

| 维度 | 目标 |
|------|------|
| 职责边界 | 负责/不负责清晰，不能越过阶段技能 |
| 触发条件 | description 和 README 调用时机与 skill 消费点一致 |
| 工具/权限边界 | 写作型、实现型、审计型 agent 的权限不同，不能默认全能 |
| 输出可消费性 | 输出格式能被主 session 或对应 skill 直接合并 |
| 阶段一致性 | agent 的行为不能改变阶段顺序、硬门或风险升级规则 |

### 调用链矩阵字段

每条调用链至少记录:

- 阶段技能
- 触发条件
- 可选/必需 agent
- agent 必需读取的输入
- agent 必需加载或遵循的 sub-skill
- 输出格式
- 风险升级条件
- validate 是否覆盖
- 未覆盖风险

## 不做

- 不把 `agents/` 变成独立路由层；路由仍由 router + stage skill 控制。
- 不一次性重写所有 SKILL.md 和 agent 文件；质量优化必须分批。
- 不用固定库存数字写进长期文档；数量从目录、索引或 validate 动态获得。
- 不追求统一行数；短但明确的技能优于长但空泛的技能。
- 不先扩展大量 validate 主观规则；先通过审计证明规则稳定。
- 不替换 "human partner" 措辞。
- 不恢复 repo-local `.agents/skills/*` 薄包装模型。

## 开放问题

1. 这次优化是否要覆盖 `commands/`，还是只覆盖 `skills/` + `agents/`？
2. agent frontmatter 的目标宿主能力需要先做实测，还是只按当前插件规范设计？
3. Phase 0 的评分表是否作为正式产物进入 `docs/features/20260515-skill-agent-quality/`？
4. 旧的 `skills-optimization` 和 `agent-architect` 是否标注为被本方案 supersede，还是保留为子方向材料？
