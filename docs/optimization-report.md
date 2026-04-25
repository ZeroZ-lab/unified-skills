# Unified Skills 优化报告

## 执行时间
2025-01-XX

## 目标
将 Unified Skills 从被动匹配系统升级为主动发现 + 强制执行系统

## 实施内容

### 第一波：主动发现机制

#### 1. skills-index.json
创建 5 维度结构化索引：
- `by_phase` — 按工作流阶段（define/build/verify/ship/maintain/reflect）
- `by_artifact_type` — 按产物类型（software/document/article/deck/visual）
- `by_trigger.user_says` — 按用户关键词触发
- `by_trigger.context_signals` — 按上下文信号触发
- `by_risk` — 按风险因素触发
- `skill_descriptions` — 每个技能的一句话描述

#### 2. maintain-workflow-using-unified 引导技能
创建 Session 启动引导技能，包含：
- 5 步主动发现流程（读索引 → 分析特征 → 查询技能 → 决策加载 → 宣告执行）
- Red Flags 表（9 条常见跳过发现流程的想法）
- 决策流程图
- 技能分类速查（43 个技能按阶段分组）

#### 3. CLAUDE.md 启动协议
在 CLAUDE.md 顶部添加：
- `<CRITICAL>` Session 启动协议 — 必须先调用引导技能
- 每个任务的发现协议 — 5 步非可选流程

#### 4. load-manifest.json 默认加载
在 defaults 层添加 `maintain-workflow-using-unified`，确保每个 session 自动加载

#### 5. Codex CLI 包装器
创建 `.agents/skills/using-unified/SKILL.md` 支持 Codex CLI

### 第二波：强制执行语言

为 5 个关键技能添加 `<HARD-GATE>` 标签：

#### 1. build-quality-tdd
- Iron Law: "没有测试先失败的代码 = 不存在的代码"
- 红旗: 9 条 TDD 违规行为

#### 2. verify-workflow-debug
- Iron Law: "根因调查在前，修复在后"
- 红旗: 8 条猜测式调试行为

#### 3. verify-workflow-review
- Iron Law: "没有对应产物类型的审查证据就不能批准"
- 红旗: 8 条审查跳过行为

#### 4. define-workflow-refine
- HARD GATE: "在用户批准设计之前，禁止调用任何实现技能"
- 红旗: 7 条跳过设计的行为

#### 5. ship-workflow-ship
- Iron Law: "没有已验证、可交付、可追溯的发布计划就不上线"
- 红旗: 8 条发布跳过行为

### 第三波：批量语言升级

创建 `scripts/upgrade-language.py` 自动化脚本，批量转换：

**转换规则：**
- 被动 → 主动："建议" → "必须"，"推荐" → 直接动词
- 弱化词移除："尽量"、"尽可能"、"如果可能"
- 条件句 → 指令句："可以做" → "做"，"应该做" → "做"

**执行结果：**
- 处理 44 个技能
- 升级 34 个技能
- 修改 124 行，删除 90 行弱语言

**示例转换：**
```diff
- 建议调用 build-workflow-execute
+ 必须调用 build-workflow-execute

- 可以直接进入 build
+ 直接进入 build

- 应该放一起
+ 放一起

- 用户可以注册
+ 用户注册

- 强烈建议采纳
+ 强烈必须采纳
```

## 验证结果

### 机制验证
✅ skills-index.json 有效 JSON  
✅ 5 个技能包含 HARD-GATE 标签  
✅ CLAUDE.md 包含 CRITICAL 启动协议  
✅ 引导技能包含 3 处 EXTREMELY-IMPORTANT 标签  
✅ load-manifest.json 默认加载引导技能  
✅ 34/44 技能语言已升级  

### 文件变更统计
```
34 files changed, 124 insertions(+), 90 deletions(-)
```

## 核心差异对比

### 优化前（Superpowers 风格）
```markdown
## When to Use
Use this when you need to...

## Steps
1. Consider doing X
2. You might want to Y
3. It's recommended to Z
```

### 优化后（Unified 强制风格）
```markdown
<EXTREMELY-IMPORTANT>
在响应用户消息或采取任何行动之前，你必须执行技能发现流程。
IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
</EXTREMELY-IMPORTANT>

## 流程（必须按序）
1. 读取 skills-index.json
2. 分析任务特征（5 个维度）
3. 查询相关技能
4. 加载所有 required 技能
5. 宣告并执行

<HARD-GATE>
以下任何一个出现，立即停止：
- [具体违规行为列表]
</HARD-GATE>
```

## 预期效果

### 主动发现
- Agent 不再依赖"记住"技能存在
- 每个任务自动查询 skills-index.json
- 5 维度匹配确保覆盖率

### 强制执行
- `<HARD-GATE>` 标签创建心理停止点
- Red Flags 表预判跳过行为
- 强制性语言消除"可选"解读空间

### 语言强度
- 被动建议 → 主动指令
- 弱化词移除
- 条件句转换为祈使句

## 后续建议

1. **监控效果** — 观察 Agent 是否主动查询索引
2. **迭代 Red Flags** — 收集新的跳过模式并添加
3. **扩展索引** — 添加更多触发维度（如 by_file_type, by_error_pattern）
4. **A/B 测试** — 对比优化前后的技能使用率

## 文件清单

### 新增文件
- `skills-index.json`
- `skills/maintain-workflow-using-unified/SKILL.md`
- `.agents/skills/using-unified/SKILL.md`
- `scripts/upgrade-language.py`

### 修改文件
- `CLAUDE.md` — 添加启动协议
- `load-manifest.json` — 添加默认技能
- 34 个技能文件 — 语言升级
- 5 个关键技能 — 添加 HARD-GATE

## 总结

通过三波优化，Unified Skills 从被动匹配系统升级为主动发现 + 强制执行系统：

1. **主动发现** — 结构化索引 + 5 步流程 + 自动查询
2. **强制执行** — HARD-GATE 标签 + Red Flags 表 + 心理停止点
3. **语言强度** — 被动 → 主动，建议 → 指令，可选 → 必须

核心理念：**IF A SKILL APPLIES, YOU MUST USE IT. NO CHOICE.**
