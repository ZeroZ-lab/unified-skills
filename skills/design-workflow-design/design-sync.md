# Design Workflow — DESIGN.md Sync

本文件是 `design-workflow-design/SKILL.md` 的辅助材料。主技能保留 Step 6：同步项目级设计约束到 DESIGN.md 的门槛；需要执行 token 提取、合并和冲突处理时读取本文件。

## Step 6 详细流程

读取已批准的 `02-design.md`，提取项目级设计 token 和约束写入项目根 `DESIGN.md`。

## Extraction Rules

- 扫描 Adopt 条目中描述跨 feature 适用模式的条目。
- 扫描 Local Project Truth 中描述项目范围约束的内容（品牌色、组件库、字体系统等）。
- 将视觉决策转化为 YAML token（colors / typography / rounded / spacing / components）。
- 将交互、布局、响应式决策转化为对应 Markdown 章节。
- 不提取 feature-specific 的交互流程、页面结构或功能范围决策。

## Token Example

如果 `02-design.md` 的 Adopt 记录了"项目使用 Indigo 作为主色调"：

```yaml
colors:
  primary: "#4F46E5"
```

Markdown Color Palette 章节追加：

```markdown
primary (#4F46E5) — 主操作色，用于 CTA、链接、选中态
```

## Merge Rules

- `DESIGN.md` 不存在：使用 `templates/root/DESIGN.md` 创建。
- YAML token：已存在的不覆盖（手动优先），新增的追加。
- Markdown 章节：新约束追加到对应章节末尾，标注 `<!-- auto-sync: /design <feature-name> -->`。
- 已有手动内容（无 auto-sync 标注）不覆盖；冲突时保留手动内容并添加 `<!-- conflict-note: ... -->`。
- 更新 `## Sync Log`。

## Skip Conditions

- design required = skipped。
- `02-design.md` 中无项目级约束。
- 本次 feature 只定义局部流程、文档或合同，不产生跨项目视觉/交互 token。
