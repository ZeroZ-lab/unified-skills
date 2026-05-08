# Design Best-Practice Sources — 设计最佳实践来源

Unified design 使用外部最佳实践证据让创作决策可追溯。本文件定义来源模型，不内置大型静态案例库。

## 来源层

每次 required design 都按以下来源层扫描和记录：

1. **Enterprise Product Patterns**
   - 成熟 SaaS、consumer app、dashboard、form、workflow、deck、visual artifact 的公开模式。
   - 用于产品流程、常见状态、导航、内容密度和受众预期。

2. **Official Systems / Platform Rules**
   - 官方设计系统、平台规范、品牌规则、无障碍规则、媒介和导出约束。
   - 用于交互 affordance、组件行为、字体、色彩、间距、响应式和格式规则。

3. **Methods / Theory / Style Schools**
   - 交互设计、信息设计、字体排版、版式系统、叙事结构、演示导演和风格流派方法。
   - 用于解释为什么某种结构、节奏、层级或风格方向适合当前任务。

4. **Anti-patterns / Verification**
   - 已知失败模式、反模式、检查清单和质量门。
   - 用于拒绝流行但不适合的选择，防止常见低质量模式。

5. **Local Project Truth**
   - 当前 repo、现有 UI、品牌、组件库、内容边界、用户目标、artifact_type 和 human partner 约束。
   - 这一层优先级最高。外部模式不能覆盖本地真实约束。

## 扫描合同

Required design 必须产出：

- **Sources**: 检查过什么，按来源层分组。
- **Patterns**: 多个来源中重复出现的模式。
- **Inferences**: 从模式和本地约束推导出的设计判断。
- **Adopt**: 被采纳进 `02-design.md` 的外部或本地模式，必须写来源层和理由。
- **Reject**: 有吸引力或常见但被拒绝的模式，必须写理由。
- **Unknown**: 证据缺口、不可访问来源或仍未解决的假设。

如果搜索或浏览不可用，记录 `Search unavailable`，并使用 Local Project Truth 和本地 reference。若关键设计决策仍缺证据，design approval 必须停止。

## 轨道映射

- **Interaction**: 产品流程、状态覆盖、信息架构、affordance、心智模型。
- **Visual direction**: 品牌规则、视觉层级、色彩角色、字体排版、组件语言。
- **Layout**: 栅格、密度、阅读路径、构图、媒介/导出约束。
- **Script**: 受众任务、叙事脊柱、消息顺序、证据节奏。
- **Direction**: 揭示顺序、页间推进、speaker load、情绪节奏。

## 批准门槛

`02-design.md` 只有在满足以下条件时才能批准：

- Design references 已按来源层分组。
- Pattern synthesis 说明了哪些模式重复出现，哪些模式相互冲突。
- Design inferences 说明了从模式和本地约束到设计判断的推导。
- Adopt / Reject 决策明确。
- 关键设计决策能回溯到来源证据或 Local Project Truth。
- 外部灵感已适配当前产物，而不是盲目复制。
