# Design Workflow — Visual Generation

本文件是 `design-workflow-design/SKILL.md` 的辅助材料。主技能保留 Step 3.5：Codex 视觉生成 + Token 提取的触发和降级合同；需要执行可选视觉 mockup、图片分析或 token 提取时读取本文件。

## Step 3.5 详细流程

**触发条件**：`codex:codex-rescue` agent 可用，且 `artifact_type` 为 `software`（有 UI）、`visual` 或 `deck`。

1. 将 Step 1 的 spec 约束 + Step 3 扫描结果组装为 Codex prompt：
   - 设计目标描述（产品类型、目标用户、核心交互）
   - 视觉方向关键词（从 Step 3 Adopt 条目提取：色彩策略、字体风格、布局模式、组件样式）
   - 输出要求：生成 2-3 张设计方向 mockup 图（PNG），每张代表一个差异化视觉方向
2. 调用 `codex:codex-rescue` agent。
3. 保存图片到 `docs/features/YYYYMMDD-<name>/assets/`：
   - `mockup-direction-1.png`
   - `mockup-direction-2.png`
   - `mockup-direction-3.png`
4. 用 `analyze_image` 或同等视觉分析能力逐张分析 mockup 图。
5. 保存结构化 token 到 `docs/features/YYYYMMDD-<name>/assets/design-tokens-extracted.json`。
6. Token 数据作为 Pattern Synthesis 的视觉证据进入 Step 4 的 Adopt / Reject。

## Token Schema

```json
{
  "direction": "1",
  "tokens": {
    "colors": { "primary": "#...", "canvas": "#...", "ink": "#...", "accent": "#..." },
    "typography": { "family": "...", "display_weight": 400, "display_tracking": "0px", "body_weight": 400 },
    "spacing": { "base_unit": "8px", "section_gap": "64px", "card_padding": "24px" },
    "rounded": { "cta_radius": "8px", "card_radius": "8px" },
    "components": { "cta_style": "pill|rect|rounded", "card_style": "flat|elevated|bordered", "nav_style": "sidebar|topbar|mixed" }
  },
  "visual_keywords": ["dark-theme", "single-accent"],
  "mood_description": "..."
}
```

## Outputs

- PNG mockups for visual comparison.
- `design-tokens-extracted.json` for structured synthesis and optional `DESIGN.md` sync.

## Degradation

- Codex agent unavailable → record `Codex Visual Generation unavailable`, skip.
- Image generation failed → skip and continue from Step 3 textual evidence.
- Degradation does not block Step 4 when Design Best-Practice Scan evidence is sufficient.

## Applicability

| Type | Trigger | Reason |
|------|---------|--------|
| `software` + UI | yes | validate layout and interaction direction |
| `visual` | yes | visual is the core artifact |
| `deck` | yes | page rhythm benefits from visual reference |
| `document` / `article` | no | no visual mockup need by default |
| `software` pure backend | no | design is skipped |
