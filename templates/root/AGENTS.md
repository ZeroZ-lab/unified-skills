# AGENTS.md Template

## AI Agent Warning
- 先读 `CANON.md`
- 再读本文件
- 修改技能前必须理解行为塑造意图

## Context Runtime
- 先读 `skills-router.json`
- 声明 loading tier
- 只按需加载 `SKILL.md`
- 运行时详细规则在 `docs/contracts/` 按需加载

## 终端观察护栏｜Terminal Observation Guardrail
Agent 在终端中执行命令时，必须保护上下文预算。终端输出会进入模型上下文，任何大规模、重复、无关或不可控输出，都会污染后续推理。

核心原则：

> 未知输出先限流，复杂信息先采样；终端观察要服务判断，而不是淹没判断。

任何输出规模未知、递归型、日志型、测试型、构建型、生成型或可能产生大量文本的命令，都必须默认限制输出：

```bash
COMMAND 2>&1 | head -c 4000
```

只有已确认输出很小、需要完整结构化结果，或验证命令本身依赖完整 stdout/stderr 时，才不截断。

## Workflow Contract
- `/refine` → `01-spec.md`
- `/design` → `02-design.md`
- `/plan` → `03-plan.md`
- `/review` → `04-review.md`
- `/ship` → `05-ship.md`

## Documentation Slots
- `root docs`
- `project docs`
- `feature docs`
- `bug docs`

## Project-Level Truth
- `README.md`
- `AGENTS.md`
- `CHANGELOG.md`
- `DESIGN.md`
- `docs/architecture/*.md`

## Verification
- `./validate`
- skill/index/lock sync rules
- release truth surfaces

## Hard Boundaries
- Always do:
- Ask first:
- Never do:

## Editing Skills
- 用 `templates/` 作为起点
- 更新 `skills-lock.json`
- 必要时更新 `skills-index.json`
- 提交前跑 `./validate`
