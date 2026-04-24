---
name: define-workflow-spec
description: 从 refine 产出到结构化 spec。使用 cuando refine 完成后需要编写正式 spec
---

# Spec — 规范编写


## 入口/出口
- **入口**: `define-workflow-refine` 完成，用户已批准方向
- **出口**: `docs/features/<name>/01-spec.md` + 用户批准
- **指向**: 用户批准 spec 后建议调用 `build-workflow-plan`
- **假设已加载**: CANON.md（可选加载 `build-cognitive-decision-record/SKILL.md` — 有架构决策时再加载）

## 何时不使用
- 单行修复、打字错误、需求明确且自包含的变更
- 纯配置变更、依赖升级等无需设计决策的改动

## 流程

### Step 1：Surface Assumptions

写任何 spec 内容前，先列假设：

```
ASSUMPTIONS I'M MAKING:
1. 这是 Web 应用（不是原生移动端）
2. 认证使用 session cookie（不是 JWT）
3. 数据库是 PostgreSQL（基于现有 Prisma schema）
4. 目标现代浏览器（不支持 IE11）
→ 现在纠正我，否则我按这些继续。
```

不要静默填补模糊需求。spec 的全部价值在于**在写代码前**暴露误解。

### Step 2：写 spec 文档

覆盖以下内容：

1. **Objective** — 构建什么、为什么、为谁、成功标准
2. **Commands** — 完整可执行命令（含参数）：
   ```
   Build: npm run build
   Test: npm test -- --coverage
   Lint: npm run lint --fix
   Dev: npm run dev
   ```
3. **Project Structure** — 源码路径、测试路径、文档路径
4. **Code Style** — 一个真实代码片段比三段描述更有效。包含命名约定、格式化规则
5. **Testing Strategy** — 框架、测试路径、覆盖率要求
6. **Boundaries（三级系统）**:
   - **Always do:** 提交前跑测试、遵循命名约定、验证输入
   - **Ask first:** 数据库 schema 变更、加依赖、改 CI 配置
   - **Never do:** 提交密钥、编辑 vendor 目录、未经批准删除失败测试

**spec 模板：**

```markdown
# Spec: [功能名称]

## Objective
[构建什么、为什么。用户故事或验收条件。]

## Tech Stack
[框架、语言、关键依赖及版本]

## Commands
[Build, test, lint, dev — 完整命令]

## Project Structure
[目录布局及说明]

## Code Style
[示例代码 + 关键约定]

## Testing Strategy
[框架、测试位置、覆盖率要求、测试层级]

## Boundaries
- Always: [...]
- Ask first: [...]
- Never: [...]

## Success Criteria
[如何判定"做完"——具体、可测试的条件]

## Risks and Mitigations
| 风险 | 概率 | 影响 | 应对方案 |
|------|------|------|---------|
| [风险] | [高/中/低] | [高/中/低] | [策略] |

## Open Questions
[需要用户输入的未解决问题]
```

### Step 3：把模糊要求转化为验收条件

当接收到模糊需求时，翻译成具体可测试的条件：

```
REQUIREMENT: "让仪表盘更快"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s（4G 网络）
- 初始数据加载 < 500ms
- 加载时无布局偏移（CLS < 0.1）
→ 这些目标对吗？
```

### Step 4：用户审查

spec 写完 → 请用户审查 spec 文件 → 确认或修改 → 用户批准后才进入 plan。

## 验证失败处理

- 用户拒绝 spec → 回到 `define-workflow-refine` Phase 1，获取澄清后重新写 spec
- 用户要求大幅修改 → 直接在 spec 文件上修改，重走用户审查步骤
- 需求变更 → 更新 spec，不需要重新 refine

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "这个简单不需要 spec" | 简单任务不需要长 spec，但验收条件仍然需要。两行 spec 就够了。 |
| "写代码后再写 spec" | 那是文档，不是规范。spec 的价值在于在写代码前理清需求。 |
| "spec 会拖慢我们" | 15 分钟 spec 防止数小时返工。15 分钟瀑布比 15 小时调试快。 |

## 红旗

- 在 Surface Assumptions 之前就开始写 spec 内容
- spec 缺少 Success Criteria（成功标准不具体=无法验收）
- "不做清单"没有明确 trade-off
- 用户已批准的 spec 在实现过程中静默变更
- 跳过用户审查直接进入 plan
- Architecture decision 没有记录

## 验证清单

- [ ] spec 覆盖全部 6 个核心区域
- [ ] 隐藏假设已列出（Surface Assumptions）
- [ ] 用户已审查并批准 spec
- [ ] 成功标准是具体可测试的
- [ ] Boundaries（Always/Ask First/Never）已定义
- [ ] 风险与应对方案已评估
- [ ] spec 已保存到 `docs/features/<name>/01-spec.md`
