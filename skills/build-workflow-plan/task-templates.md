# Plan Task Templates

本文件是 `build-workflow-plan/SKILL.md` 的辅助材料。主技能只保留决策流程；需要写具体任务或子计划时读取本文件。

## 代码示例风格

给执行 agent 提供方向和约束，而不是完整实现。

最小示例包含：
- 函数签名、参数类型、返回类型
- 关键步骤的意图注释
- 边界条件和错误处理提示
- 与 spec 的对应关系

最小示例不包含：
- 完整实现逻辑
- 未经 spec 要求的算法细节
- 所有可能边界分支

只有复杂算法、精确 schema、安全关键逻辑、非软件精确产物可以提供完整代码。

## Software 任务模板

```markdown
### Task N: <功能描述>

**Files:**
- Create/Modify: `src/path/to/file.ts`
- Test: `tests/path/to/test.ts`

**Depends On:** Task N-1 / none

- [ ] **Step 1: 写失败测试**
  - 测试 spec 中的验收标准。
  - Run: `<targeted test command>` -> FAIL

- [ ] **Step 2: 写最小实现**
  - 验证输入。
  - 执行核心逻辑。
  - 返回符合 spec 的结果。

- [ ] **Step 3: 验证测试通过**
  - Run: `<targeted test command>` -> PASS

- [ ] **Step 4: 记录验证证据**
  - 测试命令、结果、失败修复记录。
```

## 非 Software 任务模板

```markdown
### Task N: <产物切片>

**Files:**
- Create/Modify: `path/to/source`
- Export: `path/to/final-artifact`

- [ ] **Step 1: 明确切片验收标准**
  - 读者目标、页面目标、视觉目标或导出规格。

- [ ] **Step 2: 生成/修改最小产物**
  - 写章节、做页面、调整版式或视觉稿。

- [ ] **Step 3: 按类型验证**
  - 事实核查、逻辑审查、版式检查、导出预览。

- [ ] **Step 4: 记录验证证据**
  - 审查结论、截图、导出路径或人工确认。
```

## Subplan Contract

```markdown
## Subplan Contract
- **Owner:** 主 agent / subagent 名称或角色
- **Status:** serial / parallel_safe / gated
- **Depends On:** `plans/01-contracts.md` 或其他子计划；没有则写 none
- **Write Scope:** 允许创建/修改的文件、目录或产物路径
- **Read Scope:** 需要读取的 spec、契约、现有文件或外部材料
- **Verification Evidence:** 独立验证命令、审查方式、导出预览或人工确认
- **Merge Checkpoint:** 合并前必须满足的条件
```

## Parallel Safety

`parallel_safe: yes` 只允许在同时满足以下条件时使用：
- 无共享文件
- 无顺序依赖
- 接口契约已定
- 验证可独立完成

共享 schema、共享 API 契约未定、同一文件写入、迁移、发布、全局样式、全局配置默认 `parallel_safe: no`。
