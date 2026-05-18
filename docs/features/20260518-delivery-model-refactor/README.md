# 交付模型与角色管线重构

## 时间线
| 阶段 | 日期 | 产出 |
|------|------|------|
| refine | 2026-05-18 | 01-spec.md |
| plan | 2026-05-18 | 03-plan.md |
| build | 2026-05-18 | 4 persona + 合同/模板/技能/命令更新 |
| review | 2026-05-18 | 04-review.md — PASS (0 Blocking) |
| ship | 2026-05-18 | 05-ship.md — GO |

## 变更概要
收敛 `artifact_type` 为 3 个 canonical 一级交付类（software / content / visual），新增 4 个 persona 填补内容/视觉在 refine、review、ship 的角色缺口。

## 决策记录
- 采用 3 类模型而非 5 类并列或 8 类扩编
- 先补 persona reachability，复用现有 skill，不新增顶层 skill
- 命令层保留不变，底层语义收敛
- `data` / `course` 归属延后到第二阶段

## 变更统计
- 修改文件: 15
- 新增文件: 8（4 persona + 4 feature docs）
- 影响技能: define-workflow-refine、verify-workflow-review、ship-workflow-ship
- 新增 persona: refine-content-scout、review-content-auditor、review-visual-auditor、ship-artifact-export-auditor

## 观察
- 管线重构改动面广但写入范围受控（串行执行防止漂移）
- `deck` 归属 content 但 review 叠加 visual 审查，在多文件间保持一致
- templates/04-review.md 和 05-ship.md 属于计划外扩展但改动正确必要

## 改进项
- `delivery_class` 字段可记录默认/回退行为
- persona 文件可声明工具范围以提高安全审计可追溯性
- 第二阶段需决定 `data` / `course` / `media` 的最终归属
