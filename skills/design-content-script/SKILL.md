---
name: design-content-script
description: 剧本设计——叙事骨架、段落消息线、讲述顺序和节奏
---

# Script Design — 剧本设计

## 入口/出口
- **入口**: `document` / `article` / `deck` 需要先定叙事再进入产出
- **出口**: 核心主张、故事线、段落/页面消息线和节奏定稿
- **指向**: 需要导演节奏 → `design-content-direction`；需要版式 → `design-content-layout`
- **假设已加载**: CANON.md + `design-workflow-design`

## 何时不使用
- 纯视觉稿且没有文案结构
- 只做已有定稿内容的微调

## Iron Law

先定讲什么、为什么这样讲、按什么顺序讲；再去写正文或做页面。

## 核心原则

1. **Audience Task First**
2. **One Spine**
3. **Message Per Section**
4. **Tension Needs Sequence**
5. **Cut Anything That Does Not Advance the Story**

## 最佳实践输入

先读取 `references/design-best-practices.md`，并把剧本相关证据写入 `02-design.md` 的 `Design References / Pattern Synthesis / Adopt / Reject`。

扫描重点：
- Enterprise Product Patterns: 同类文章、报告、deck 的叙事结构、开场方式、证据节奏
- Official Systems / Platform Rules: 品牌语气、内容规范、媒介长度、引用和合规约束
- Methods / Theory / Style Schools: 信息设计、故事脊柱、金字塔结构、问题-张力-解决路径
- Anti-patterns / Verification: 主题散、标题串不成线、堆材料、每段多消息
- Local Project Truth: 已批准 spec、受众任务、事实材料、禁用话术和项目边界

剧本方向必须由 Pattern Synthesis 收敛，不能只凭“感觉这样讲顺”。

## 流程

### Step 1：定义受众任务
- 读者/观众是谁
- 看完要理解、相信或决定什么

### Step 2：写故事脊柱
- 起点
- 张力
- 转折
- 结论 / 行动

### Step 3：拆消息线
- 每章 / 每页 / 每段只承载一个核心消息
- 标题串起来要能独立读懂

### Step 4：定节奏
- 哪些地方快
- 哪些地方慢
- 哪些信息必须提前
- 哪些信息应延后揭示

## 输出契约

写入 `02-design.md`：
- 核心主张
- 剧本骨架 / 故事线
- 段落节奏 / 页序
- Adopt / Reject（叙事模式）
- 不做清单

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 没有核心主张 | 先降维成一句话主张 |
| 标题串不成线 | 重写消息线，不进入 build |
| 节奏失衡 | 删除或重排冗余段落 |
| 叙事模式无证据 | 补充 best-practice scan，写清 Adopt / Reject |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| “先把内容都写出来再整理” | 没有剧本，后面只会变成清理垃圾。 |
| “PPT 就是文章拆页” | 没有页级消息线的 deck 不是演示。 |
| “之后再调节奏” | 节奏是结构问题，不是润色问题。 |

## 红旗 — STOP

- 没有核心主张
- 缺少剧本 best-practice scan 或 Adopt / Reject
- 标题/页面顺序无法复述故事
- 一段或一页同时想讲多个消息
- 把 build 阶段的写作执行混进剧本设计

## 验证清单

- [ ] 受众任务明确
- [ ] 核心主张明确
- [ ] 故事线完整
- [ ] 段落 / 页序清楚
- [ ] 节奏已定
- [ ] 剧本决策已回溯到来源证据或 Local Project Truth
- [ ] 已写入 `02-design.md`
