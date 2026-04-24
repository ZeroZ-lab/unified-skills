---
name: verify-quality-simplify
description: 系统性代码简化。使用 cuando 代码变得复杂、重复、过度抽象需要简化
---

# Simplify — 系统性代码简化


## 入口/出口
- **入口**: 可编译可测试的代码
- **出口**: 行为不变的简化版本 + 测试验证
- **指向**: 完成后回到 `verify-workflow-review` 或继续 build
- **假设已加载**: CANON.md

## Iron Law

行为不变。简化前后测试必须全部通过。任何测试失败 = 回退。

## 核心理念

- **Chesterton's Fence**: 不理解一段代码为什么存在，就不要删它
- **三个相似代码行 > 一个过早抽象**
- **500 行规则**: 文件超过 500 行 = 简化候选
- **增量简化**: 每步一个改动，每步验证

## Phase 1: 识别简化目标

扫描代码，标记以下类型的简化目标：

### 重复代码
- 同一逻辑出现 3+ 次
- 复制粘贴后仅改了少量参数的代码块

### 过度抽象
- 使用场景 < 3 的抽象层
- 只有 1-2 个实现者的接口或策略模式
- 间接层没有带来复用收益

### 过长函数
- > 50 行的函数
- 函数内有 3+ 个不同层级的抽象

### 过深嵌套
- > 3 层缩进
- 嵌套的 if-else 链可以用 guard clause 消除

### 死代码
- 无引用的导出
- 未使用的变量
- 不可达的分支（`if (false)`、throw 后的代码）

### 冗余注释
- 代码已自解释的注释
- 注释重复了函数名或变量名表达的信息

## Phase 2: 理解上下文

对每个目标，回答以下问题：

- **为什么存在？** 这段代码解决什么问题？是业务需求、技术约束还是历史遗留？
- **谁依赖？** 哪些模块、测试、外部接口依赖它？
- **最近有改动吗？** 活跃修改的代码比稳定代码风险更高。

对每个目标进一步判断：
- 删除/简化这个会不会影响其他模块？
- 有没有测试覆盖这段代码？

**对不确定的目标：先标记，跳过，不要猜。**

## Phase 3: 增量简化

**规则：每次只改一个目标。每次改动后跑测试，全绿才继续。**

### 简化策略

| 目标类型 | 策略 | 触发条件 |
|---------|------|---------|
| 重复代码 | 提取函数 | 仅当第 3+ 次出现 |
| 过度抽象 | 内联回调用处，删除抽象层 | 使用场景 < 3 |
| 过长函数 | 按职责拆分，每个函数一个职责 | > 50 行 |
| 过深嵌套 | 提前返回（guard clause）减少缩进 | > 3 层 |
| 死代码 | 确认无引用后用 `AskUserQuestion` 确认后删除 | 无引用 |
| 冗余注释 | 删除；删除后不够自解释则改善命名 | 代码已自解释 |

### 重复代码 → 提取函数（仅第 3+ 次）

```typescript
// 第 1 次出现：保持内联
// 第 2 次出现：保持内联，可以标记 TODO
// 第 3 次出现：提取为函数
function formatDateForDisplay(date: Date): string {
  // 三个地方都用的逻辑现在集中在一处
}
```

### 过度抽象 → 内联 + 删除

```typescript
// 前：过度抽象（只有 1 个实现）
interface DataProcessor { process(data: Raw): Result }
class DefaultDataProcessor implements DataProcessor { ... }

// 后：直接使用
function processData(data: Raw): Result { ... }
```

### 过长函数 → 按职责拆分

```typescript
// 前：一个函数做 3 件事
function handleRequest(req: Request): Response { /* 80 行 */ }

// 后：每个函数一个职责
function validateRequest(req: Request): Validated { ... }
function transformData(data: Validated): Processed { ... }
function buildResponse(data: Processed): Response { ... }
```

### 过深嵌套 → guard clause

```typescript
// 前：4 层嵌套
function process(user: User) {
  if (user) {
    if (user.isActive) {
      if (user.hasPermission) {
        // 真正的逻辑
      }
    }
  }
}

// 后：提前返回，1 层
function process(user: User) {
  if (!user) return;
  if (!user.isActive) return;
  if (!user.hasPermission) return;
  // 真正的逻辑
}
```

### 死代码 → 确认后删除

```bash
# 确认无引用
grep -r "<symbol>" --include="*.ts" --include="*.tsx" --include="*.js"
```

确认无引用后，使用 `AskUserQuestion` 询问："是否删除 `<symbol>`？代码库中无引用。"

### 冗余注释 → 删除或改善命名

```typescript
// 前：注释多余
// 设置用户名称
user.setName(name);

// 后 A：删除注释
user.setName(name);

// 后 B：如果删注释后不够清晰，改善命名
user.updateDisplayName(name);
```

## Phase 4: 验证

简化完成后，依次验证：

- [ ] 全部测试通过
- [ ] Lint 无新警告
- [ ] 行为不变（关键路径手动验证）
- [ ] 代码行数减少或持平（不应增加）

如果任何一项不满足 → 回退最后一次改动，重新评估。

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "这样更优雅" | 优雅不是目标，简单才是。可读、可维护比聪明重要。 |
| "先重构再说" | 不理解就动手 = 制造 bug。先 Phase 2 理解上下文。 |
| "以后会用到" | YAGNI。等第三个使用场景出现再抽象。 |
| "这段代码太难看了" | 丑但正确 > 漂亮但有 bug。先理解为什么丑。 |
| "抽象一下更干净" | 抽象有成本。使用场景 < 3 的抽象增加理解负担。 |

## 红旗

- 一次改多个目标
- 测试失败后继续改
- 删除不理解的代码（Chesterton's Fence）
- 抽象后行数更多（抽象失败）
- 简化引入新依赖
- 跳过 Phase 2 直接动手
- 简化后代码行为变化（Iron Law 违反）
- 不跑测试就标记完成

## 验证清单

- [ ] 每个目标已理解上下文（Phase 2 完成）
- [ ] 每步改后测试通过
- [ ] 行为不变（Iron Law）
- [ ] 总行数未增加
- [ ] 无新 lint 警告
