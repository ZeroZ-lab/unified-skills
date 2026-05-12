---
# Design Tokens — AI agent 可直接引用的 token 系统
# 引用语法：{colors.primary}, {typography.body}, {rounded.pill}, {spacing.md}
# 手动编辑的 token 受保护，自动同步不会覆盖

colors:
  primary: ""                # 主操作色（CTA、链接、选中态）
  primary-soft: ""           # 主色淡化（背景、hover 态）
  ink: ""                    # 正文墨色（非纯黑）
  on-primary: ""             # 主色上的文字色
  canvas: ""                 # 页面底色
  canvas-soft: ""            # 次级表面底色
  hairline: ""               # 分割线、边框色
  success: ""                # 成功态
  warning: ""                # 警告态
  error: ""                  # 错误态

typography:
  display-xl:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""
  display:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""
  heading:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""
  subheading:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""
  body:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""
  body-sm:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""
  caption:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""
  mono:
    fontFamily: ""
    fontSize: ""
    fontWeight: ""
    lineHeight: ""
    letterSpacing: ""

rounded:
  full: "9999px"
  pill: "100px"
  lg: "12px"
  md: "8px"
  sm: "4px"
  xs: "2px"

spacing:
  xxs: "2px"
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "48px"
  section: "64px"

components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: "8px 16px"
  button-secondary:
    backgroundColor: "{colors.canvas-soft}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: "8px 16px"
  card:
    backgroundColor: "{colors.canvas-soft}"
    rounded: "{rounded.lg}"
    padding: "{spacing.md}"
    border: "1px solid {colors.hairline}"
---

# Project Design System

> AI agent 可消费的项目级设计系统。`/design` Phase 2 读取此文件作为 Local Project Truth。
> YAML token 可通过 `{colors.primary}` 语法引用。手动编辑受保护，自动同步条目以注释标注。

## Visual Theme & Atmosphere

<!-- 整体氛围、密度、设计哲学 -->
<!-- 例：极简暗色主题，高信息密度，以渐变 mesh 为唯一装饰元素 -->

## Color Palette & Roles

<!-- 每个 token 的语义角色和使用场景 -->
<!-- 例：primary (#4F46E5) — 主操作色，用于 CTA、链接、选中态 -->

## Typography Rules

<!-- 字体层级表 + 替代字体建议 -->
<!-- 例：display 使用 Geist Sans -2.4px tracking，正文使用系统字体栈 -->

## Component Stylings

<!-- 按组件列出的样式定义，含 hover/focus/disabled 状态 -->
<!-- 例：button-primary hover → backgroundColor 加深 10% -->

## Layout Principles

<!-- 间距阶梯、栅格、留白哲学 -->
<!-- 例：基础单位 4px，页面最大宽度 1200px 居中 -->

## Depth & Elevation

<!-- 阴影系统、表面层级 -->
<!-- 例：elevation-0 = 无阴影 → elevation-4 = 最深层 -->

## Do's and Don'ts

<!-- 设计护栏 -->
<!-- 例：Don't 在 display 标题使用全大写 -->

## Responsive Behavior

<!-- 断点、触摸目标、折叠策略 -->
<!-- 例：sm 640px / md 768px / lg 1024px / xl 1280px -->

## Agent Prompt Guide

<!-- 快速色彩参考 + ready-to-use prompts -->
<!-- 例：Build a hero section using {colors.primary} as accent, {typography.display-xl} for headline -->

## Sync Log

<!-- YYYY-MM-DD | /design <feature-name> | added N entries | updated M entries | source: auto-sync -->
