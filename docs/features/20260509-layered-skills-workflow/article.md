# 从 Skills 到分层 Workflow：AI Agent 工程化的下一层抽象

很多 AI Agent 项目做到一定阶段，都会开始沉淀 skills。

一开始，这件事很自然：写代码需要 TDD skill，排查问题需要 debug skill，提交前需要 review skill，写文档需要 writing skill。每个 skill 都在解决一个局部问题：让 Agent 在某类任务上更稳定、更专业、更符合团队习惯。

但 skills 变多之后，一个新的问题会出现：**skills 的数量增加，并不必然带来 Agent 行为的稳定性。**

原因很简单。工程工作不是一次技能调用，而是一条连续链路。一个 Agent 不是只需要“会写测试”或“会做 review”，它还要知道什么时候澄清需求、什么时候查外部事实、什么时候先设计、什么时候才能实现、什么时候必须停止、什么时候需要把问题退回上一阶段。

单个 skill 解决的是“怎么做”。真正困难的是：

- 什么时候做？
- 由谁的责任视角来做？
- 做到什么程度算通过？
- 失败时回到哪里？
- 过程证据留在哪里？

这就是我设计 Unified Skills 时真正想解决的问题：**不是再做一组 skills，而是把 skills 组织成一套分层 workflow。**

## Skills Library 的上限

一个普通 skills library 通常会把能力组织成一组可调用提示词：

- 需要写测试时，调用 TDD skill。
- 需要调试时，调用 debug skill。
- 需要审查时，调用 review skill。
- 需要写作时，调用 writing skill。

这种方式有效，但它有明显上限。

第一，Agent 可能跳步骤。它可以直接从一个模糊想法进入实现，然后在最后补一段“已验证”。skill 本身并不会天然阻止这种跳跃。

第二，Agent 可能自证通过。它自己理解需求、自己实现、自己 review，最后得出“没问题”的结论。问题不在于它不努力，而在于同一个认知视角很容易形成 self-confirming loop。

第三，过程不可追踪。一次对话里看起来完成了很多工作，但过几天再回看，很难知道当时的需求边界、设计取舍、实现计划、审查结论和发布判断分别是什么。

第四，skills 之间没有治理关系。TDD skill、review skill、debug skill 都是好的，但如果它们只是平铺在一个目录里，Agent 仍然需要临场决定调用顺序。这个临场判断本身就是不稳定来源。

所以，skills library 可以提升局部能力，但不能单独解决工程工作流的稳定性问题。

## Workflow 是 Skills 的上层组织方式

Unified Skills 的第一层变化，是把 skills 放进明确的阶段流里。

主路径不是“需要什么 skill 就调用什么 skill”，而是：

```text
/refine -> /design -> /plan -> /build -> /review -> /ship
```

这条链路背后的判断是：工程交付需要状态机，而不是自由联想。

`/refine` 负责把模糊想法收敛成可验证规格。它关心的是问题、目标用户、成功标准、约束、产物类型，以及哪些外部事实需要先扫描。

`/design` 负责在实现前完成创作和体验层面的设计定稿。对于 UI、文章、deck、视觉稿这类产物，它不能被 `/build` 偷偷替代。

`/plan` 负责任务拓扑。哪些工作必须串行，哪些工作可以并行，哪些文件或模块是写入范围，都应该在这一阶段说明。

`/build` 才进入实现或内容生产。它消费前面已经批准的 spec、design 和 plan，而不是在实现过程中重新发明目标。

`/review` 不是一句“帮我看看”。它是质量门控，发现 blocking 问题就要退回 `/build`，不能靠口头承诺跳过。

`/ship` 处理发布、导出、文档同步和交付记录。交付不是“代码写完”，而是完成可追踪的收尾动作。

这就是 workflow 对 skills 的第一层约束：**skill 不再是孤立能力，而是阶段协议里的执行单元。**

## 分层 Workflow：不只是阶段流

只做阶段流还不够。真正让 Unified Skills 成为工程系统的，是它有纵向分层。

我把它理解成六层：

```text
CANON
  -> Command
  -> Agent
  -> Skill
  -> Artifact
  -> Hook / validate
```

每一层解决一个不同的问题。

## CANON：所有 Workflow 的宪法

最上层是 `CANON.md`。

它不是某个具体 skill，也不是项目说明书，而是所有阶段、角色和技能都必须继承的行为宪法。它定义的是全局纪律：先陈述假设、控制范围、验证优先、调试先找根因、不做 yes-machine、遇到矛盾先停止并澄清。

这一层的价值在于，它给所有局部方法论设定了不可放松的底线。

如果没有 CANON，每个 skill 都可能有自己的表达方式和隐含价值观。TDD skill 强调测试，debug skill 强调根因，review skill 强调质量，但它们之间缺少统一的上层约束。

有了 CANON，skill 可以增加纪律，但不能放松纪律。也就是说，局部方法论不能为了方便而绕过全局行为合同。

这是分层 workflow 的第一条原则：**具体能力必须继承全局纪律。**

## Command：把工作拆成阶段协议

Command 层回答的问题是：现在处在哪个阶段？这个阶段读什么、产出什么、通过条件是什么？

在 Unified Skills 里，Command 不是快捷入口。它更接近 workflow controller。

例如 `/plan` 的职责不是“调用一个计划 skill”，而是定义计划阶段的输入、输出和门控。它需要消费已经批准的 spec 和 design，产出 `03-plan.md`，并在大型任务里拆出子计划和并行矩阵。

这和普通 prompt shortcut 有本质区别。

shortcut 的问题是“帮我快点进入某个能力”。Command 的问题是“当前阶段如何合法推进到下一阶段”。

这层存在之后，Agent 不再凭感觉推进任务。每个阶段都有自己的合法输入和合法输出。缺少输入，就不能假装继续；输出不满足通过条件，就不能进入下一阶段。

这是第二条原则：**workflow 需要阶段状态机，而不是能力快捷方式。**

## Agent：责任视角，而不是角色扮演

Agent 层容易被误解。

很多系统引入 agent，是为了让它“扮演”某种角色，比如产品经理、架构师、审查员。这样做如果停留在语气层面，价值并不大，甚至会制造表演感。

Unified Skills 里的 Agent 层更关注责任边界。

需求分析、任务计划、软件实现、规格审查、代码质量审查、发布判断，最好不要全部由同一个视角自证完成。不是因为模型不能同时做这些事，而是因为工程系统不能依赖同一个视角完成提出、执行和验收的闭环。

Agent 层的价值是降低 self-confirming loop。

一个 review agent 不应该重新定义需求；它应该根据已批准的 spec 判断实现是否完整。一个 software engineer agent 不应该替代 plan 阶段决定任务拓扑；它应该在计划约束内实现。一个 design reviewer 不应该只说“视觉不错”；它应该阻断缺少证据来源、模式综合和采纳/拒绝理由的设计稿。

所以 Agent 不是为了热闹，而是为了把责任切开。

这是第三条原则：**Agent 的核心价值是责任分离，不是人格化。**

## Skill：真正执行的方法论单元

Skill 层是最具体的一层。

一个合格的 skill 不能只是一段“请你认真做 X”的提示词。它必须说明：

- 什么时候进入？
- 什么时候退出？
- 具体步骤是什么？
- 哪些说法是常见借口？
- 哪些情况必须停止？
- 怎么验证自己做完了？

这也是为什么 Unified Skills 里的 `SKILL.md` 通常包含入口/出口、流程、常见说辞、红旗和验证清单。强纪律技能还会有 Iron Law。

Skill 解决的是方法论复用问题。比如 TDD、debug、source-driven、content-writing、browser-testing 都是可以跨任务复用的方法论。

但 skill 不应该决定整个工作流。它回答“这一类事情怎么做”，不回答“现在是不是该做这件事”。后者属于 Command 和 Agent 的职责。

这是第四条原则：**Skill 是执行方法论，不是工作流总控。**

## Artifact：把过程变成证据链

如果只看对话，Agent 工作很容易变成一段不可回放的即时表演。

今天看起来它澄清了需求、做了设计、写了计划、完成了实现、通过了 review。但过几天回看时，很多关键信息会消失：

- 当时的需求边界是什么？
- 哪些外部资料被采纳，哪些被拒绝？
- 哪些设计方案被放弃？
- 计划里哪些任务允许并行？
- review 到底检查了功能完整性，还是只看了代码风格？
- ship 时有没有留下回滚或导出记录？

所以 Unified Skills 把 artifact 作为 workflow 的一层，而不是附属品。

`01-spec.md`、`02-design.md`、`03-plan.md`、`04-review.md`、`05-ship.md` 这些文件不是文档洁癖。它们是 Agent 行为的审计轨迹。

artifact 的作用不是让流程变重，而是让过程可追踪、可复盘、可迁移。

这也是多产物 workflow 必须有 `artifact_type` 的原因。软件、文档、文章、deck、视觉稿需要不同的设计、构建、审查和导出路径。没有 artifact_type，workflow 很容易用软件工程的方式处理所有产物，或者用内容创作的方式跳过软件质量门控。

这是第五条原则：**没有 artifact，workflow 就缺少可审计证据。**

## Hook / Validate：把约定变成护栏

只靠提示词约束 Agent 是不稳定的。

提示词可以提醒 Agent 不要做破坏性操作，但运行时 hook 才能拦截破坏性命令。文档可以要求技能命名规范，但 validate 才能发现索引、锁文件、技能数量和根文档之间是否漂移。

这也是 Unified Skills 里 hooks 和 `./validate` 的位置。

它们不负责替代思考，也不负责替代 review。它们负责把一部分纪律从“应该遵守”变成“违反就会暴露”。

这个经验很重要：`./validate` 通过不代表合同完全一致，但没有 validate，合同漂移会更难被发现。

技能系统最容易发生的腐蚀，不是某个 prompt 写错了，而是多个合同表面慢慢不一致：README 说一套，AGENTS 说一套，skills-index 还是旧的，hooks 实现又是另一套。等这些漂移积累起来，Agent 就会在不同入口读到不同真相。

所以 Hook / validate 层解决的是运行时和维护期治理问题。

这是第六条原则：**高层纪律必须有低层护栏，否则只是建议。**

## 两阶段 Review：一个具体的门控例子

Unified Skills 里的 review 不是单阶段“代码看起来怎么样”。

它拆成两关：

第一关是 Spec Compliance，检查实现是否覆盖了 spec 的功能需求、边界条件、错误路径和验收标准。它关心的是“实现了什么”。

第二关是 Code Quality，只有在第一关通过后才进入。它检查 correctness、readability、architecture、security、performance 等质量维度。它关心的是“如何实现”。

这个拆分看似简单，但对 Agent workflow 很关键。

如果功能都没实现完整，就急着讨论代码风格，审查资源会被浪费。如果功能缺失和质量问题混在一起，反馈也会变得含糊。两阶段 review 把问题类型切开：先确认做没做对，再确认做得好不好。

这就是分层 workflow 的实际价值：它不是抽象地要求 Agent “认真审查”，而是把审查变成有顺序、有边界、有退回路径的门控。

## 从 Prompt 到 Workflow，再到治理结构

回到最开始的问题：AI Agent 工程化到底需要什么？

更长的 prompt 有用，但不够。

更多的 skills 有用，但也不够。

真正需要设计的是 skills 之间的组织关系。也就是：

- 用 CANON 定义不可放松的全局纪律。
- 用 Command 定义阶段状态机。
- 用 Agent 定义责任视角。
- 用 Skill 承载可复用方法论。
- 用 Artifact 留下过程证据。
- 用 Hook / validate 把规则变成护栏。

这套结构的目标不是让 Agent 显得更复杂，而是让它在复杂任务里更可控。

prompt 是表达。

skill 是方法。

workflow 是制度。

layered workflow 是治理结构。

这就是 Unified Skills 想表达的核心判断：**AI Agent 的下一层抽象，不是 skills library，而是分层 skills workflow。**

