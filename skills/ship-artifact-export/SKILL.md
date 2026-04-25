---
name: ship-artifact-export
description: 非软件产物导出与交付。使用 cuando artifact_type 为 document、article、deck、visual，或需要导出 PDF/DOCX/PPTX/PNG/SVG 并记录验证证据时
---

# Artifact Export — 产物导出

## 入口/出口
- **入口**: 非软件产物通过内容或视觉审查，准备交付
- **出口**: 最终导出文件、预览验证、版本归档和交付记录
- **指向**: 完成后 → `reflect-team-retro` 或 `reflect-team-documentation`
- **假设已加载**: CANON.md + 对应 review 技能

## 角色定位

你是制片和交付 QA，负责把“源文件里看起来完成”变成“接收方能打开、能使用、能追踪的最终交付物”。

你的责任包括确认交付规格、导出最终格式、打开最终文件验证、记录 source/final/format/verification/known limitations，并把可编辑源文件和最终文件一起归档。

## 何时不使用
- `artifact_type` 为 `software` 且需要部署到运行环境（使用 `ship-workflow-ship` 和部署技能）
- 仍处于草稿阶段，内容或视觉审查未通过
- 只做内部临时预览，不准备交付

## Iron Law

最终导出物才是交付物。验证分两层，两层都通过才能声明已交付：

1. **源文件验证**（agent 负责）：结构完整性、frontmatter、链接可达、元数据齐全、格式一致性
2. **导出验证**（human partner 或 CI 负责）：打开 PDF/PPTX/DOCX 看排版、字体、图片、投屏效果

agent 负责源文件验证并将导出验证标记为 human partner 待办。human partner 完成导出验证后，交付才算完成。

## 核心原则

1. **source 和 final 分离**: 源文件用于编辑，最终文件用于交付；两者都要可追踪。
2. **格式契约优先**: 交付格式由 spec 和接收场景决定，不能用方便导出的格式替代。
3. **最终文件必须验证**: 导出过程会引入字体、图片、分页、链接、裁切、透明背景等风险。源文件验证由 agent 执行，导出验证由 human partner 或 CI 执行。
4. **归档要能复现**: 后续维护者应能找到源文件、最终文件、审查记录和导出记录。
5. **限制必须显式记录**: 已知限制不等于失败，但隐瞒限制会破坏交付可信度。
6. **命名承载上下文**: 文件名应表达产物、用途、版本或日期，避免“final_final”式不可追踪命名。

## 决策框架

1. **确认最终格式**: DOCX、PDF、PPTX、PNG、SVG、Markdown、HTML 或组合格式。
2. **确认 source of truth**: 哪个文件是后续编辑的唯一源头？是否需要一起归档？
3. **执行导出**: 按 spec 导出最终文件，不把预览截图当正式交付。
4. **源文件验证 + 导出验证**: 源文件验证（agent）检查结构、链接、元数据、格式一致性；导出验证（human partner/CI）检查打开后的排版、字体、图片、投屏效果。
5. **记录证据**: 写明 Source、Final、Format、Verification、Known limitations。
6. **归档交付包**: 把 source、final、review、ship record 放到可追踪位置。
7. **Go/No-Go**: final 可打开、格式正确、证据完整 → Go；否则 No-Go。

### Artifact Type 判断

| artifact_type | 最终交付判断 |
|---------------|--------------|
| `document` | DOCX/PDF 能打开，页码、目录、图表、链接、打印/PDF 预览正确 |
| `article` | Markdown/HTML/PDF 或发布包完整，标题、正文、链接、元数据可用 |
| `deck` | PPTX/PDF 能打开，页序、speaker notes、字体、图片、投屏预览正确 |
| `visual` | PNG/SVG/PDF 尺寸、分辨率、透明背景、颜色和裁切符合使用场景 |

## 流程

### Step 1：确认交付规格

从 spec 读取：
- `artifact_type`
- 最终格式
- 文件命名规则
- 交付路径
- 是否需要源文件一起归档
- 已通过的内容/视觉审查记录

### Step 2：导出最终文件

按产物类型导出：
- `document`: DOCX/PDF，必要时保留源 Markdown 或编辑源文件
- `article`: Markdown/HTML/PDF，必要时附封面图或元数据
- `deck`: PPTX/PDF，必要时附 speaker notes
- `visual`: PNG/SVG/PDF，必要时附源文件和尺寸说明

### Step 3a：源文件验证（agent 负责）

在导出前验证源文件本身：
- 结构完整性：章节、标题层级无断裂
- frontmatter 字段齐全（artifact_type、版本、日期）
- 内部链接可达、图片引用无缺失
- 元数据（标题、作者、日期）完整
- 格式与 spec 一致

### Step 3b：导出验证（human partner 或 CI 负责）

导出后由 human partner 打开最终文件检查：
- 文件能打开
- 页数、画布数、页面顺序或尺寸正确
- 字体、图片、表格、图表没有损坏
- 链接、引用、speaker notes 或元数据可用
- 文件名和路径符合 spec

agent 在 ship 记录中标记 `Export verification: pending human partner review`，提示 human partner 验证上述项目。human partner 确认后标记 `Export verification: passed`。

### Step 4：记录交付证据

在 `docs/features/<name>/ship.md` 或对应 ship 记录中写入：

```markdown
## Artifact Export
- artifact_type: document
- Source: path/to/source
- Final: path/to/final.pdf
- Format: PDF
- Verification: source verified (structure, links, metadata OK); export verified by human partner (pages 1-12, links valid)
- Known limitations: none
```

### Step 5：归档

保留：
- 最终交付文件
- 可编辑源文件
- 内容/视觉审查记录
- 导出验证记录
- 已知限制和版本说明

## 反模式修复表

| 反模式 | 判断方式 | 修复动作 |
|--------|----------|----------|
| 只交源文件 | spec 要 final，但只有可编辑文件 | 导出 final，并把 source 一起归档 |
| 导出物打不开 | 接收方路径或本地预览无法打开 | 阻塞，重新导出或修复源文件 |
| 格式错配 | 需要 PDF/PPTX/DOCX，却交了截图或源稿 | 按 spec 重新导出，不改 spec 掩盖问题 |
| 字体/图片丢失 | final 中字体替换、图片缺失或模糊 | 修复资源引用，重新导出并复验 |
| 文件名不可追踪 | `final2.pdf`、`new.pptx` 无上下文 | 按命名规则加入产物、用途、版本/日期 |
| 缺少限制说明 | 已知问题只在口头说明 | 写入 Known limitations |
| 审查和交付分离 | 找不到通过审查的版本对应哪个 final | 在 ship 记录中链接 source、review、final |

## 好/坏示例

### 坏：声明式交付

```markdown
已导出 PDF，文件在 output 目录。
```

问题：没有 source、final、格式、打开验证、限制说明，后续无法追踪。

### 好：可复核交付记录

```markdown
## Artifact Export
- artifact_type: deck
- Source: docs/features/q2-review/q2-review.pptx
- Final: docs/features/q2-review/final/q2-review-v1.pdf
- Format: PDF
- Verification: source verified; opened PDF, checked 18 slides, charts readable at 100%, links valid, speaker notes retained in source PPTX
- Known limitations: embedded video exported as static poster frame
```

优点：接收方和维护者都能知道交付物是什么、从哪里来、怎么验证过、还有什么限制。

## 验证证据

ship 记录至少包含：

```markdown
## Artifact Export
- artifact_type:
- Source:
- Final:
- Format:
- Verification:
- Known limitations:
- Archived with:
```

## 与其他技能配合
- 内容未通过 → `verify-content-review`
- 视觉未通过 → `verify-visual-review`
- 版式需要修复 → `build-content-layout`
- 软件发布 → `ship-workflow-ship`

## 验证失败处理

| 失败场景 | 处理方式 |
|----------|----------|
| 导出文件打不开 | 阻塞，重新导出或修复源文件 |
| 导出格式不符合 spec | 重新导出正确格式，不改 spec 掩盖问题 |
| 字体或图片丢失 | 修复资源引用后重新导出 |
| 文件路径不明确 | 建立明确 final/source/review 路径后再交付 |
| 已知限制未记录 | 写入 Known limitations 后重新做 Go/No-Go |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "源文件没问题，导出也没问题" | 导出是独立风险点。agent 做源文件验证，human partner 做导出验证。 |
| "先发这个版本，之后补 PDF" | 没有最终格式就没有完成交付。 |
| "文件名随便起" | 交付物需要可追踪、可归档、可复现。 |
| "截图看过了就行" | 截图不能替代打开最终 DOCX/PPTX/PDF。 |

## 红旗 — STOP

- 没有最终导出文件
- 没有源文件验证记录
- 导出验证标记为 pending 但已声明交付完成
- 只交付源文件但 spec 要求 PDF/PPTX/DOCX
- 文件名无法识别版本或用途
- 审查记录和最终文件分离，无法追踪
- 视觉导出尺寸或格式不符合使用场景
- Known limitations 空缺但实际存在限制

## 验证清单

- [ ] artifact_type 已读取
- [ ] 最终格式与 spec 一致
- [ ] 源文件验证已完成（agent）
- [ ] 导出验证已完成（human partner 或 CI）
- [ ] 源文件、最终文件、审查记录路径已记录
- [ ] 导出验证写入 ship 记录
- [ ] 已知限制已记录
- [ ] 交付物可归档、可追踪
