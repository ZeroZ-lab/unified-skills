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

## 何时不使用
- `artifact_type` 为 `software` 且需要部署到运行环境（使用 `ship-workflow-ship` 和部署技能）
- 仍处于草稿阶段，内容或视觉审查未通过
- 只做内部临时预览，不准备交付

## Iron Law

交付的是最终文件，不是源文件意图。没有打开最终导出物并记录证据，就不能声明已交付。

## 流程

### Step 1：确认交付规格

从 spec 读取：
- `artifact_type`
- 最终格式：DOCX、PDF、PPTX、PNG、SVG、Markdown、HTML 等
- 文件命名规则
- 交付路径
- 是否需要源文件一起归档

### Step 2：导出

按产物类型导出：
- `document`: DOCX/PDF，必要时保留源 Markdown 或编辑源文件
- `article`: Markdown/HTML/PDF，必要时附封面图或元数据
- `deck`: PPTX/PDF，必要时附 speaker notes
- `visual`: PNG/SVG/PDF，必要时附源文件和尺寸说明

### Step 3：打开最终文件验证

至少检查：
- 文件能打开
- 页数/画布数正确
- 字体、图片、表格、图表没有损坏
- 链接或引用可用
- 文件名和路径符合 spec

### Step 4：记录交付证据

在 `docs/features/<name>/ship.md` 或对应 ship 记录中写入：

```markdown
## Artifact Export
- artifact_type: document
- Source: path/to/source
- Final: path/to/final.pdf
- Format: PDF
- Verification: opened final file, checked pages 1-12, links valid
- Known limitations: none
```

### Step 5：归档

保留：
- 最终交付文件
- 可编辑源文件
- 审查记录
- 导出验证记录

## Artifact Type 指南

| artifact_type | 必查项 |
|---------------|--------|
| `document` | 页码、目录、图表、PDF/DOCX 打开 |
| `article` | 标题、正文、链接、发布格式 |
| `deck` | 页面顺序、speaker notes、投屏/PDF 预览 |
| `visual` | 尺寸、分辨率、透明背景、颜色表现 |

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| 导出文件打不开 | 阻塞，重新导出或修复源文件 |
| 导出格式不符合 spec | 重新导出正确格式，不改 spec 掩盖问题 |
| 字体或图片丢失 | 修复资源引用后重新导出 |
| 文件路径不明确 | 建立明确 final/source/review 路径后再交付 |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "源文件没问题，导出应该也没问题" | 导出是独立风险点。必须打开最终文件。 |
| "先发这个版本，之后补 PDF" | 没有最终格式就没有完成交付。 |
| "文件名随便起" | 交付物需要可追踪，可归档，可复现。 |
| "截图看过了就行" | 截图不能替代打开最终 DOCX/PPTX/PDF。 |

## 红旗 — STOP

- 没有最终导出文件
- 没有打开最终文件验证
- 只交付源文件但 spec 要求 PDF/PPTX/DOCX
- 文件名无法识别版本或用途
- 审查记录和最终文件分离，无法追踪
- 视觉导出尺寸或格式不符合使用场景

## 验证清单

- [ ] artifact_type 已读取
- [ ] 最终格式与 spec 一致
- [ ] 最终文件已打开检查
- [ ] 源文件、最终文件、审查记录路径已记录
- [ ] 导出验证写入 ship 记录
- [ ] 已知限制已记录
- [ ] 交付物可归档、可追踪
