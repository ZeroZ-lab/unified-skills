# 编排模式目录

> 认可模式与反模式清单。主 agent 在选择执行策略时参考此文档。模式来源：`build-cognitive-execution-engine/SKILL.md` 的三种执行模式实践总结。

---

## 认可模式

### 模式 1：直接调用（Direct Invocation）

**结构:** 单一技能，无编排。

```
用户 → 技能 → 输出
```

**适用场景:**
- 单文件修改
- 简单 bug 修复
- 配置变更
- 不需要多角色协作的任务

**优点:** 零编排开销，上下文完整，延迟最低。

**规则:**
- 不要为简单任务引入编排层
- 直接调用时主 agent 保持完整上下文

---

### 模式 2：单角色命令（Single-Role Command）

**结构:** 一个命令加载一个技能 + 一个 persona。

```
用户 → 命令 → 加载技能 + persona → 执行 → 输出
```

**适用场景:**
- `/build` 加载执行技能 + code-reviewer persona
- `/review` 加载审查技能 + 审查 persona
- 需要特定角色视角但不需要并行反馈

**优点:** 角色聚焦，技能与 persona 配合紧密，上下文利用率高。

**规则:**
- 命令只加载一个 persona，不堆叠多个
- persona 提供视角和优先级，技能提供流程

---

### 模式 3：并行扇出 + 合并（Parallel Fan-Out + Merge）

**结构:** 主 agent 同时分派 N 个 persona，收集反馈后合并。

```
              ┌→ Persona A → 反馈 A ─┐
用户 → 主 agent ─┼→ Persona B → 反馈 B ─┼→ 合并 → 统一输出
              └→ Persona C → 反馈 C ─┘
```

**适用场景:**
- `/refine` — CEO Scout + Eng Scout + Design Scout 并行扫描
- `/plan` — CEO Reviewer + Eng Reviewer + Design Reviewer 并行审查
- `/review` — 多维度审查并行执行
- `/ship` — 多专项审计并行跑

**优点:** 延迟等于最慢的 persona，而非所有 persona 之和。各 persona 独立上下文，互不干扰。

**规则:**
- 必须在**单个 assistant turn** 中同时发起多个 Agent tool 调用——分开调用是串行，不是并行
- 每个 subagent 独立上下文，不共享对话历史
- 合并步骤必须在主 agent 上下文中完成——确保合并结果不超过上下文容量
- 分派前确认各 persona 任务无文件重叠、无共享状态

**合并流程:**
1. 收集所有 persona 反馈
2. 去重：相同建议合并为一条
3. 冲突解决：不同 persona 矛盾建议标注冲突，由主 agent 判定
4. 优先级排序：按 persona 职责权重排列
5. 输出统一报告

---

### 模式 4：顺序流水线（Sequential Pipeline）

**结构:** 用户驱动的命令链，每个命令产出是下一个命令的输入。

```
/refine → spec → /plan → 任务计划 → /build → 产物 → /review → 审查报告 → /ship → 发布
```

**适用场景:**
- 完整功能开发生命周期
- 每个阶段需要人类确认或调整

**优点:** 每个阶段有明确的入口/出口条件，人类在阶段间隙保有控制权。阶段间通过文件（而非上下文）传递信息，不丢失保真度。

**规则:**
- 阶段间通过**文件**（spec、plan、review）传递，不通过对话历史
- 每个阶段独立加载所需技能和 persona
- 人类在每个阶段结束时有确认机会
- 不跳过阶段——每个阶段的质量门控保护后续阶段

---

### 模式 5：研究隔离（Research Isolation）

**结构:** subagent 在独立上下文中探索，不污染主 agent 的对话历史。

```
主 agent → 分派研究 subagent（独立上下文）
                │
                ▼
           探索/搜索/阅读
                │
                ▼
           返回结构化摘要
主 agent ← 接收摘要
```

**适用场景:**
- 需要大量阅读代码但不需要保留完整上下文的调研任务
- 探索性搜索（查找文件、理解架构、收集信息）
- 主 agent 上下文接近容量上限时

**优点:** 主 agent 上下文不被大量源代码占满。研究 subagent 可以广泛探索，主 agent 只接收精炼结论。

**规则:**
- subagent 返回**结构化摘要**，不返回原始代码全文
- 摘要格式：发现列表 + 每条发现的文件路径 + 关键行号
- 主 agent 需要细节时再按路径读取特定文件

---

## 反模式

### 反模式 A：路由 Persona（Router Persona）

**表现:** 创建一个"元 agent"，唯一职责是根据输入分派给其他 persona，自己不执行任何实际工作。

```
用户 → 路由 Persona → 分派给 Persona A
                      或分派给 Persona B
                      （路由 persona 自身无产出）
```

**问题:**
- 增加一层无价值的中转——主 agent 本身就具备分派能力
- 浪费 token 在路由决策上
- 引入单点故障——路由错误导致整个流程失败

**替代:** 主 agent 直接分派，不经过路由层。

---

### 反模式 B：Persona 链式调用（Persona Chaining）

**表现:** Persona A 完成任务后调用 Persona B，Persona B 再调用 Persona C。

```
主 agent → Persona A → 调用 Persona B → 调用 Persona C
```

**问题:**
- 每次调用增加延迟（串行累加）
- 上下文逐层衰减——Persona C 只拿到 Persona B 的转述，不是原始信息
- 错误定位困难——某一层出问题时难以追溯到根因
- 违反编排深度限制（见下方规则）

**替代:** 主 agent 并行分派各 persona，各自独立工作，主 agent 合并结果。

---

### 反模式 C：顺序转述器（Sequential Paraphraser）

**表现:** 主 agent 读取 subagent 输出，用自己的话复述，再传给下一个 subagent。

```
Subagent A 输出 → 主 agent 转述 → Subagent B 输入
                                    （信息在转述中丢失）
```

**问题:**
- 每次转述丢失细节——subagent 的具体发现被概括为主 agent 的理解
- 主 agent 成为瓶颈——所有信息经过一次人（模型）工处理
- 保真度不可逆——一旦细节丢失，后续 subagent 无法恢复

**替代:** 通过文件传递信息。Subagent A 将完整发现写入文件，Subagent B 直接读取文件。

---

### 反模式 D：深层 Persona 树（Deep Persona Trees）

**表现:** Persona 生成子 persona，子 persona 再生成孙 persona，形成树状结构。

```
主 agent → Persona A
              └→ Sub-Persona A1
                    └→ Sub-Persona A1a
                          └→ ...
```

**问题:**
- Claude Code 强制最大深度为 1——subagent 不能再分派 sub-subagent
- 每层深度的上下文质量急剧下降
- 调试和错误追踪几乎不可能
- token 消耗指数级增长

**替代:** 保持编排深度为 1。需要多层处理时，由主 agent 串行分派，每次深度为 1。

---

## 规则总结

1. **Persona 不调用其他 persona。** Persona 只做自己的专业工作，编排由主 agent 负责。
2. **编排深度最大为 1。** 主 agent → subagent，到此为止。Subagent 不再分派。
3. **合并步骤必须在主 agent 上下文中完成。** 并行扇出的反馈汇总由主 agent 执行，确保上下文容量足够。
4. **并行扇出必须在单个 assistant turn 中发起。** 多个 Agent tool 调用放在同一条消息中，实现真正的并行执行。
5. **阶段间通过文件传递，不通过对话历史。** 文件是持久化、可验证的信息载体；对话历史是易失的。
