---
name: ship-workflow-ship
description: 发布或导出检查 → Go/No-Go → 归档。使用 cuando 审查通过后需要上线或交付最终产物
---

# Ship — 发布与交付


## 入口/出口
- **入口**: 通过 review 的代码
- **出口**: `docs/features/<name>/ship.md` + `docs/features/<name>/README.md`（事后总结）
- **指向**: 完成后进入 `reflect-team-retro`（可选）
- **假设已加载**: CANON.md + `verify-workflow-review/SKILL.md`

## 何时不使用
- 紧急修复（hotfix）— 使用简化流程，但 Go/No-Go 和回滚计划不可省略
- 纯配置变更（环境变量、DNS）— 可在监控下直接变更
- 功能尚未通过 review — 必须先完成审查
- 依赖尚未就绪（数据库 migration 未审批、第三方服务未配置）

## Iron Law

没有已验证、可交付、可追溯的发布计划就不上线。`software` 需要 Staging、Go/No-Go、回滚计划；非软件产物需要导出验证、最终文件路径、版本归档和验收记录。

## 流程

### Phase A：预发检查

先读取 spec 的 `artifact_type`：
- `software`（默认）→ 执行代码质量、基础设施、Staging、回滚计划
- `document` / `article` / `deck` / `visual` → 加载 `ship-artifact-export`，执行导出、预览、归档和交付检查

逐项运行验证：

**代码质量**
- [ ] 全部测试通过（unit + integration + e2e）
- [ ] 构建成功无警告
- [ ] Lint + type check 通过
- [ ] 没有未解决的 TODO 在代码中
- [ ] 没有 `console.log` 调试语句在生产代码中
- [ ] 错误处理覆盖预期失败模式

**基础设施**
- [ ] 环境变量在生产环境已设置
- [ ] DB migration 已应用或准备应用
- [ ] DNS 和 SSL 已配置
- [ ] 健康检查端点存在并响应
- [ ] 日志和错误报告已配置

**验证命令（必须运行）：**
```bash
npm test
npm run build
npm run lint
npx tsc --noEmit
```

### Phase B：质量门 — Ship Audit Army（发布审计军团）

预发检查通过后，**并行分派** 4 个 auditor 做发布前专项审计：

```
Pre-launch checks (Phase A passed)
    │
    ├── agents/ship-security-auditor.md      → 安全审计: OWASP、输入边界、认证授权、数据暴露、依赖
    ├── agents/ship-performance-auditor.md   → 性能审计: 关键路径、N+1查询、内存资源、Bundle影响、退化
    ├── agents/ship-accessibility-auditor.md → 无障碍审计: WCAG合规、屏幕阅读器、表单错误、动态内容
    └── agents/ship-docs-auditor.md          → 文档审计: CHANGELOG、README、迁移指南、API文档、错误信息
            │
            ▼
    收集审计结果 → 分级合并 → 修正 → 进入 Staging（Phase B.5）
```

每个 auditor 输出 Blocking / Important / Suggestion 三级反馈。

**反馈处理规则：**
- **Blocking** — 必须解决，不上线直到修复
- **Important** — 强烈建议修复，不修复需在 ship 报告中记录风险接受理由
- **Suggestion** — 自主判断，采纳后标注来源

**最少触发条件：**
- 小型变更（单文件、无安全/UI 敏感）→ 可跳过 Audit Army
- 标准变更 → 至少 security + docs 双审计
- 有 UI 变更 → 加 accessibility
- 有性能敏感变更（数据处理、查询、前端 bundle）→ 加 performance
- 用户指定 `--full` → 4 角色全开

**保留向后兼容：** 高风险变更也可加载专项审查技能：
- `verify-quality-security/SKILL.md` — 深度安全专项
- `verify-quality-performance/SKILL.md` — 深度性能专项
- `verify-frontend-accessibility/SKILL.md` — 深度无障碍专项

### Phase B.5：Staging 验证（强制）

上线前必须经过 staging 环境验证：

**验证步骤：**
1. 部署到 staging 环境
2. 运行完整测试套件在 staging 数据上：`npm test`
3. 手动冒烟测试关键路径（用户注册、登录、核心流程）
4. 验证与下游依赖的集成（API mock 关闭，真实调用）
5. 确认数据 migration 向前兼容
6. 确认回滚脚本可用

**staging 不完全 == 不上线。** 所有验证必须全部绿色才能进入 Go/No-Go。

### Phase C：Go/No-Go 决策

文档化：

```
## Go/No-Go
- [ ] 阻塞项：无未解决的 Critical 问题
- [ ] 已知风险：[列出]
- [ ] 回滚计划：已准备（强制！）
```

**回滚计划模板：**

```markdown
## 回滚计划

### 触发条件
- 错误率 > 2x 基准
- P95 延迟 > [X]ms

### 回滚步骤
1. 禁用 feature flag（如适用）
   或
1. 部署上一版本：`git revert <commit> && git push`
2. 验证回滚：健康检查、错误监控
3. 沟通：通知团队

### 数据库考虑
- Migration [X] 有 rollback
- 新功能插入的数据：[保留 / 清理]

### 回滚时间
- Feature flag: < 1 分钟
- 重部署前一版本: < 5 分钟
- DB rollback: < 15 分钟
```

### Phase D：文档聚合

自动生成 `docs/features/<name>/README.md`，包含：
- 时间线（refine → plan → build → review → ship 日期）
- 决策记录索引（ADR）
- 变更统计（文件数 + 行数）
- 事后总结（功能负责人 + 观察 + 改进项）

### Phase E：发布后闭环（推荐）

发布完成后，建议执行发布后闭环：
- `ship-workflow-canary` — 金丝雀监控，curl 关键端点比对基线
- `ship-workflow-land` — 合并 PR、等 CI、验证生产环境
- `ship-workflow-doc-sync` — 交叉引用变更，同步更新过时文档

## Feature Flag 策略

```typescript
const flags = await getFeatureFlags(userId);
if (flags.newFeature) {
  return <NewFeature />;
}
return <Existing />;
```

**生命周期：**
```
DEPLOY(flag OFF) → ENABLE(团队内测) → GRADUAL(5%→25%→50%→100%) → MONITOR → CLEAN UP
```

**规则：** 每个 flag 有 owner 和过期时间。上线后 2 周内清理。

## 分阶段上线

| 阶段 | 监控要点 | 持续时间 |
|------|---------|---------|
| 团队内测 | 核心流程可用 | 24h |
| 5% canary | 错误率、延迟 | 24-48h |
| 25% → 50% → 100% | 同上→稳步推进 | 每阶段视情况 |
| Full rollout | 持续监控 | 1 周 |

**推进/回滚阈值：**

| 指标 | 推进（绿色） | 观察（黄色） | 回滚（红色） |
|------|-------------|-------------|-------------|
| 错误率 | 在基准 ±10% 内 | 高于基准 10-100% | > 2x 基准 |
| P95 延迟 | 在基准 ±20% 内 | 高于基准 20-50% | > 50% 基准 |
| 客户端 JS 错误 | 无新错误类型 | 新增 < 0.1% session | 新增 > 0.1% session |
| 业务指标 | 正向或中性 | 下降 < 5%（可能噪声） | 下降 > 5% |

## 监控与可观测性

### 应用级指标
```
├── 错误率（总数 + 按端点）
├── 响应时间（p50 / p95 / p99）
├── 请求量
├── 活跃用户
└── 关键业务指标（转化率、参与度）
```

### 上线后验证


上线后 1 小时内：
1. 健康检查 200
2. 错误监控仪表盘（无新错误类型）
3. 延迟仪表盘（无回归）
4. 手动测试关键用户流程
5. 确认日志正常流动
6. 确认回滚机制就绪

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| Staging 测试失败 | 阻塞。修复后重新部署 staging，不可跳过直接上线 |
| Go/No-Go 被否决 | 回到对应阶段修复（review / build），重新走预发检查 |
| 上线后错误率飙升 | 立即回滚（禁用 feature flag 或 revert），不"观察一下" |
| Feature flag 未就绪 | 阻塞。不上线。在 staging 验证 flag 开关功能正常 |
| DB migration 向前不兼容 | 阻塞。修复 migration 使其向前兼容，或拆分为两阶段部署 |
| 回滚计划不完整 | 阻塞。必须补全触发条件和步骤后才可上线 |

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "周五下午了，发了吧" | 周五不发版。 |
| "不需要 feature flag" | 每个功能都需要 kill switch。 |
| "监控是额外的成本" | 没有监控意味着从用户投诉而不是仪表盘发现故障。 |
| "回滚就是承认失败" | 回滚是负责任的工程。发布有问题的功能才是失败。 |

## 红旗

- 没有回滚计划就部署
- 没有监控或错误报告就上线
- 大爆炸式发布（一次性全量，没有 staging）
- Feature flag 没有 owner 或过期时间
- 上线后第一小时无人监控
- 生产环境配置靠记忆而不是代码
- "周五下午了，发了吧"

## 验证清单

上线前：
- [ ] 预发检查清单完成（全部绿色）
- [ ] Feature flag 已配置（如适用）
- [ ] 回滚计划已文档化
- [ ] 团队已通知上线

上线后：
- [ ] 健康检查 200
- [ ] 错误率正常
- [ ] 延迟正常
- [ ] 关键用户流程工作
- [ ] 日志正常流动
