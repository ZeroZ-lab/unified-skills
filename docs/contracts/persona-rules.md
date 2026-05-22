# Agent Persona 调用规则

> 本文件在阶段技能决定派 persona 时按需加载，不在 CLAUDE.md 中全量引用。

## 调用规则

`agents/` 是 persona / 职责定义层，不是独立路由器。真正的调用时机必须写在对应阶段技能或技能辅助文件中；`commands/` 和 `agents/README.md` 只能镜像阶段技能，不创建额外规则。

- 唯一合法加载链路：`router / command -> stage skill -> current agent 或 persona -> 主 session 汇总`
- `skills` 加载权属于 `router / command / stage skill`
- `agent persona` 只有执行权，没有 `self-load` / `self-route` / `self-expand-scope` 权
- 简单认知型阶段默认可由 current agent 直接执行；`/brainstorm` 例外，阶段技能可按 profile/seats 选择 brainstorm scout persona，并由 current agent 汇总。
- 阶段技能决定是否按 `artifact_type`、canonical 一级交付类、风险或任务性质选择 persona。
- persona 可以声明常用/必需 skills，但不能绕过阶段技能自行扩大 scope。
- `agents/README.md` 中声明有调用时机的 persona，必须能在 `skills/` 中找到对应消费点。

## 类型解释顺序

类型解释顺序固定如下：

1. 先解析 runtime `artifact_type`
2. 再映射 canonical `delivery_class`
3. `artifact_type` 用于实际 skills 路由
4. `delivery_class` 用于角色矩阵、pipeline 语义和项目级真相解释
