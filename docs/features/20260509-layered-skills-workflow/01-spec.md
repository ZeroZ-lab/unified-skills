# 分层 Skills Workflow 技术文章

## 问题陈述

如何向 AI Agent 工程实践者解释 Unified Skills 的核心价值不是 skills 数量，而是把 skills 组织成一套分层、可治理、可审查、可复现的 workflow architecture？

## Artifact Type

artifact_type: article

## Goal Alignment

- Source Goal: conversation
- Goal Status: accepted
- Goal Review Score: 11/12

### One-line Goal

写一篇面向 AI Agent 工程实践者的技术文章，讲清 Unified Skills 的分层 workflow 设计逻辑。

### Done When

- [ ] Functional: 读者能理解 Unified Skills 不是 skills library，而是 layered skills workflow architecture。
- [ ] Technical: 文章讲清 CANON / Command / Agent / Skill / Artifact / Hooks 的层次关系。
- [ ] Regression: 不退化为 README 扩写、安装教程或 skills 清单。
- [ ] Output: 产出一篇可发布的 Markdown 技术文章。

### Stop Conditions

- [ ] 文章主线变成“53 个 skills 功能大全”。
- [ ] 文章只复述目录结构，没有解释工程问题。
- [ ] 文章缺少分层 workflow 的核心判断。
- [ ] 文章面向普通 AI 工具用户而不是 AI Agent 工程实践者。

## External References

- Search status: skipped
- Reason: 文章主题是当前项目架构解释，事实依据来自本仓库当前合同文档。
- Fact:
  - README 将 Unified Skills 定义为面向 AI Agent 的工作制度架构。
  - AGENTS.md 约定主工作流为 `/refine -> /design -> /plan -> /build -> /review -> /ship`。
  - CANON.md 定义所有技能继承的全局行为纪律。
  - docs/architecture/review-two-stage-gate.md 描述 Spec Compliance 与 Code Quality 的两阶段审查。
- Pattern:
  - 项目用分层合同约束 Agent 行为，而不是只提供一组松散 prompt。
- Inference:
  - 技术文章应强调“skills workflow 的组织层次”，而不是“skills 数量”。
- Unknown:
  - 具体发布平台和篇幅要求尚未指定。
- Adopt:
  - 采用架构观点文路线，主张 workflow 是 skills 的上层组织方式。
- Reject:
  - 不写安装教程、功能清单或 README 扩写。

## 核心假设（待验证）

- [ ] 目标读者已经熟悉 prompt、skill、agent 等基本概念。
- [ ] 读者关心的是 Agent 工程稳定性、可治理性和质量门控，而不是入门教程。

## MVP 范围

包括：
- skills library 的上限。
- 分层 workflow 的六层结构。
- Command / Agent / Skill 的职责边界。
- Artifact 与 Hook / validate 的治理价值。
- 两阶段 review 作为门控样例。

不包括：
- 安装教程。
- 完整命令手册。
- 每个 skill 的逐项说明。
- 与其他框架的横向评测。

## 不做清单（及理由）

- 不写“53 个 skills 介绍” — 这会把项目误读成 prompt collection。
- 不写“如何安装 Unified Skills” — 安装不是本文的核心技术判断。
- 不把 Claude Code / Codex 平台适配作为主线 — 平台适配是落地细节，不是抽象核心。
- 不宣称 Agent “更聪明” — 文章重点是更可控、更可审查、更可复现。

