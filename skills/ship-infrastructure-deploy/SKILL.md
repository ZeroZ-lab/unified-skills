---
name: ship-infrastructure-deploy
description: 部署管理——安全、可逆、可观测的上线。使用 cuando 准备上线部署或配置发布策略
---

# Deploy — 部署管理

> 来源: agent-skills shipping-and-launch + gstack ship deploy pipeline | 宪法: 第 5 条（Verify Don't Assume）

## 入口/出口
- **入口**: 准备上线、`/ship` 流程的部署阶段
- **出口**: 成功部署 + 上线后验证 + 回滚剧本
- **指向**: 部署完成 → 监控（`maintain-infrastructure-observability`）
- **假设已加载**: CANON.md + `ship-infrastructure-ci-cd/SKILL.md`

## Iron Law

```
每个上线必须可逆、可观测、渐进式。
大爆炸上线 = 大爆炸回滚。
没有回滚剧本的上线 = 赌博。
```

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

| 说辞 | 现实 |
|------|------|
| "只是小改动，不用分阶段" | 小改动也能引发大问题。金丝雀部署花 15 分钟，比完全回滚花 2 小时便宜。 |
| "回滚剧本以后写" | 上线中出问题时没有时间"以后写"。回滚必须是肌肉记忆。 |
| "Feature flag 太复杂" | 一个 if/else 条件。比紧急回滚部署简单。 |
| "先在周五下午上线" | 周五下午上线 = 如果出问题，周末没人维护。周二/周三上午上线。 |

## 红旗 — STOP

- 没有回滚方案就要上线
- Feature flag 没有过期日期和 owner
- 所有流量一次性切换到新版本（无金丝雀）
- 数据库迁移有 UP 但没有 DOWN
- 上线后没有立即看 Dashboard/错误率
- Secrets/环境变量未在生产配置

## 验证清单

- [ ] Pre-Launch 检查表全部通过
- [ ] 回滚剧本清晰、可执行
- [ ] Feature flags 有 owner + 过期日期
- [ ] 金丝雀部署验证通过
- [ ] 上线后核心指标与 baseline 无显著恶化
- [ ] 上线后手动验证关键用户流程
- [ ] CHANGELOG 已更新
