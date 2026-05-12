---
name: design-content-direction
description: 导演设计——镜头/页面切换意图、情绪推进、演示节奏和呈现编排
---

# Direction Design — 导演设计

## 入口/出口
- **入口**: `deck` 或强呈现导向内容需要定义演示推进和场面调度
- **出口**: 页面切换意图、情绪推进、演讲节奏和呈现编排定稿
- **指向**: 剧本主线 → `design-content-script`；页面落地 → `design-content-layout`
- **假设已加载**: CANON.md + `design-workflow-design`

## 何时不使用
- 普通长文阅读材料
- 只做静态版式、不涉及讲述推进的视觉稿

## 核心原则

1. **Sequence Creates Meaning**
2. **Reveal Is a Design Decision**
3. **Emotion Needs Control**
4. **Speaker Load Matters**
5. **Every Transition Must Earn Its Keep**

## 最佳实践输入

先读取 `references/design-best-practices.md` 和 `references/design-inspiration-catalog.md`，并把导演相关证据写入 `02-design.md` 的 `Design References / Pattern Synthesis / Adopt / Reject`。

扫描重点：
- Enterprise Product Patterns: pitch deck、发布会、产品演示、汇报材料的页序和揭示模式
- Official Systems / Platform Rules: 演示媒介、时长、品牌语气、动画/导出限制
- Methods / Theory / Style Schools: 戏剧张力、揭示顺序、节奏控制、speaker load 管理
- Anti-patterns / Verification: 每页平均用力、无转折、动画代替叙事、一页多功能
- Local Project Truth: 观众任务、现场/异步阅读场景、页数限制、演讲者能力和素材边界；项目根 `DESIGN.md`（如果存在，作为导演约束参考）

导演设计必须说明为什么这样推进；不能把页序写成材料清单。

## 流程

### Step 1：定义演示目标
- 观众在每个阶段应该感受到什么
- 什么时候建立张力
- 什么时候交付结论

### Step 2：规划推进
- 页与页之间如何接力
- 哪些内容应该单独成页
- 哪些内容必须成组出现

### Step 3：控制节奏
- 快切还是停顿
- 哪里需要解释空间
- 哪里只给结论不展开

### Step 4：记录呈现约束
- speaker notes 是否承担细节
- 页面是否需要动画/渐进披露
- 现场阅读 vs 投屏演讲

## 输出契约

写入 `02-design.md`：
- 演讲节奏
- 页序 / 段落推进
- 情绪推进 / 转折点
- Adopt / Reject（导演模式）
- 不做清单

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 页序只是在平铺信息 | 重写推进逻辑，增加转折和揭示顺序 |
| 节奏过密 | 拆页或让 speaker notes 承担细节 |
| 节奏过散 | 合并页面，强化主线 |
| 推进模式无证据 | 补充 best-practice scan，写清 Adopt / Reject |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| “把页做出来就有节奏了” | 没有导演设计的页序只是在排材料。 |
| “动画以后再说” | 是否渐进披露会影响叙事结构。 |
| “每页都讲一点” | 平均分配信息通常等于没有重点。 |

## 红旗 — STOP

- 没有推进逻辑就开始做 deck
- 缺少导演 best-practice scan 或 Adopt / Reject
- 情绪推进和故事线相互打架
- 一页承担多个阶段性功能
- 把导演设计退化成“加不加动画”

## 验证清单

- [ ] 演示目标明确
- [ ] 页序推进合理
- [ ] 节奏控制明确
- [ ] 呈现约束明确
- [ ] 导演决策已回溯到来源证据或 Local Project Truth
- [ ] 已写入 `02-design.md`
