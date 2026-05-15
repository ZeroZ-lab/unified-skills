---
name: ship-infrastructure-deploy
description: 部署管理——安全、可逆、可观测的上线。当准备上线部署或配置发布策略
---

# Deploy — 部署管理


## 入口/出口
- **入口**: 准备上线、`ship-workflow-ship` 流程的部署阶段
- **出口**: 成功部署 + 上线后验证 + 回滚剧本
- **指向**: 部署完成 → `ship-workflow-canary` 监控
- **前置加载**: CANON.md、`ship-infrastructure-ci-cd/SKILL.md`
- **输出路径**: 部署记录 → `ship-workflow-canary` 金丝雀监控

## 何时不使用
- 还没有通过 review/ship gate，不能进入实际部署
- 只是准备发布清单或导出非软件产物
- 已部署后只需要健康监控或回归观察

## Iron Law

<HARD-GATE>
```
每个上线必须可逆、可观测、渐进式。
大爆炸上线 = 大爆炸回滚。
没有回滚剧本的上线 = 赌博。
```
</HARD-GATE>

## Pre-Launch 检查表

上线前必须逐项确认：

### 代码质量
- [ ] 所有测试通过（unit + integration + E2E）
- [ ] CI/CD 最后构建绿色
- [ ] 代码审查完成（无未解决的 Critical/Important 发现）
- [ ] 没有合并冲突

### 安全
- [ ] `npm audit`（或同等）无 critical/high
- [ ] 无密钥/凭据在代码中
- [ ] 安全头已配置（CSP、HSTS、CORS 白名单）
- [ ] 速率限制已配置

### 性能
- [ ] Lighthouse / Core Web Vitals 达标
- [ ] 数据库迁移在 staging 验证通过
- [ ] 没有 N+1 查询

### 基础设施
- [ ] 迁移脚本有 UP + DOWN（全部可回滚）
- [ ] 环境变量在目标环境中已设置
- [ ] SSL 证书有效（未过期）
- [ ] 数据库备份已完成

### 文档
- [ ] CHANGELOG 已更新
- [ ] API 文档已更新（如果有 API 变更）
- [ ] README 中相关部分已更新

## Feature Flag 策略

**解耦部署（上线代码）和发布（启用功能）。**

```
Flag 生命周期:
  created ──→ enabled (0% → 10% → 50% → 100%) ──→ removed (代码清理)
                │
                └── 出问题 → 立即 0%（关闭 flag）—— 不回滚部署
```

**规则:**
1. 每个 flag 有 owner（谁创建、谁负责移除）
2. 每个 flag 有过期日期（逾期自动移除或提醒）
3. Flag 代码必须简洁——去除 flag 时只删一行，不重构
4. Flag 关闭时用户体验等价于 flag 不存在——不是降级

## 分阶段上线

```
Phase 1: Staging     → 验证所有功能 + 迁移
Phase 2: 金丝雀 (5%)  → 观察 15 分钟。关注核心指标。
Phase 3: 扩大 (25%)   → 观察 30 分钟。比较 canary vs baseline。
Phase 4: 半数 (50%)   → 观察 1 小时。
Phase 5: 全量 (100%)  → 持续观察 24 小时。
```

**推进条件:** 每个阶段的核心指标稳定（错误率、延迟、成功率未比 baseline 差）。任何异常 → 暂停推进 → 调查 → 修复或回滚。

## 回滚触发条件

| 触发条件 | 行动 |
|---------|------|
| 错误率显著上升（> baseline 2x） | 立即回滚或关闭 feature flag |
| P50/P95 延迟显著上升（> baseline 1.5x） | 立即回滚 |
| 关键用户流程断裂（500 on critical pages） | 立即回滚 |
| 数据库迁移失败或数据不一致 | 回滚迁移 + 回滚部署 |
| 安全漏洞被发现 | 立即回滚，后续安全审计后再上线 |

## 回滚剧本

```markdown
## Rollback Plan

### Trigger
- 错误率 > X% for 5 min
- P95 latency > Yms for 5 min
- 关键页面 500 rate > Z%

### Steps
1. [command to revert deployment]
2. [command to rollback migration: npx db:migrate:down]
3. [command to close feature flag: curl -X POST /api/flags/X/disable]

### RTO (Recovery Time Objective)
< 5 min from trigger

### RPO (Recovery Point Objective)
Zero data loss

### Owner
[name / oncall rotation]
```

## 上线后验证

```
1. 错误追踪 → 实时查看错误率
2. 关键页面 → 手动验证核心用户流程
3. 性能 Dashboard → 对比上线前后
4. 健康检查端点 → /health 返回 OK
5. SSL → 证书未过期
6. 迁移 → 验证数据完整性
```

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "只是小改动，不用分阶段" | 小改动也能引发大问题。金丝雀部署花 15 分钟，比完全回滚花 2 小时便宜。 | 小改动不分阶段 → 影响全部用户 → 出问题时全部用户同时受影响 → 回滚 2 小时 vs 金丝雀 15 分钟发现。 |
| "回滚剧本以后写" | 上线中出问题时没有时间"以后写"。回滚必须是肌肉记忆。 | 无回滚剧本 → 出问题时慌乱猜测回滚步骤 → 平均回滚时间 > 30 分钟 vs 有剧本 < 5 分钟。 |
| "Feature flag 太复杂" | 一个 if/else 条件。比紧急回滚部署简单。 | 无 flag → 出问题时只能回滚整个部署 → 全部用户受影响 vs flag 关闭 → < 1 分钟恢复，只影响新功能用户。 |
| "先在周五下午上线" | 周五下午上线 = 如果出问题，周末没人维护。周二/周三上午上线。 | 周五上线 → 出问题 → 周末无人响应 → 用户受影响 48-72 小时 vs 周二上线 → 出问题 → 立即响应。 |

## 红旗 — STOP

<HARD-GATE>
以下任何一个出现，立即停止部署：

- 没有回滚方案就要上线
- Feature flag 没有过期日期和 owner
- 所有流量一次性切换到新版本（无金丝雀）
- 数据库迁移有 UP 但没有 DOWN
- 上线后没有立即看 Dashboard/错误率
- Secrets/环境变量未在生产配置
</HARD-GATE>

## 验证清单

- [ ] Pre-Launch 检查表全部通过
- [ ] 回滚剧本清晰、可执行
- [ ] Feature flags 有 owner + 过期日期
- [ ] 金丝雀部署验证通过
- [ ] 上线后核心指标与 baseline 无显著恶化
- [ ] 上线后手动验证关键用户流程
- [ ] CHANGELOG 已更新

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Pre-Launch 检查未全部通过 | STOP。补齐缺失项后再上线。不接受"大部分通过"。 |
| 金丝雀阶段指标恶化 | 暂停推进 → 调查根因 → 修复后重新金丝雀或回滚。不强行扩大流量比例。 |
| 数据库迁移失败 | 回滚迁移（DOWN script）+ 回滚部署。修复迁移脚本后再试。 |
| 上线后关键用户流程断裂 | 立即回滚或关闭 feature flag。不先调试再决策——先恢复服务再调查。 |
| 回滚剧本不可执行 | STOP。重写回滚剧本，确保每步有具体命令和验证方式。无剧本不上线。 |

## 好坏示例

### Good — 有回滚剧本的分阶段上线

```markdown
Phase 1: Staging → 全部验证通过 ✅
Phase 2: 金丝雀 5% → 15 分钟观察 → 错误率正常 ✅
Phase 3: 25% → 30 分钟 → P95 无恶化 ✅
Phase 4: 全量 → 持续监控

回滚剧本:
1. kubectl rollout undo deployment/app
2. npx db:migrate:down
3. curl -X POST /api/flags/notification/disable
RTO: < 5 min
```

### Bad — 大爆炸上线无回滚

```
（直接全量切换，不分阶段，无回滚剧本）

→ 问题: 全量切换 → 5% 用户遇到 500 也影响全部
→ 问题: 无回滚剧本 → 出问题后慌乱猜测步骤 → 回滚 > 30 分钟
→ 问题: 无 feature flag → 不能快速关闭新功能 → 必须回滚整个部署
```

## 输出模板

```markdown
### Deploy 交付记录 — <feature-name>

**部署策略**: [staging → canary → staged rollout / blue-green / rolling update]
**回滚剧本**: [具体命令] — RTO: < 5 min
**Feature Flags**: [flag名 / owner / 过期日期]

**Pre-Launch 检查**:
- 代码质量: [全部通过 / 具体未通过项]
- 安全: [全部通过 / 具体未通过项]
- 性能: [全部通过 / 具体未通过项]
- 基础设施: [全部通过 / 具体未通过项]
- 文档: [全部通过 / 具体未通过项]

**分阶段上线记录**:
| Phase | 流量比例 | 观察时长 | 核心指标 | 结果 |
|-------|---------|---------|---------|------|
| Staging | 100% | [时长] | [指标] | ✅ / ❌ |
| Canary | 5% | 15min | [指标] | ✅ / ❌ |

**健康验证**: [端点状态 + 响应时间 — PASS/FAIL]
```
