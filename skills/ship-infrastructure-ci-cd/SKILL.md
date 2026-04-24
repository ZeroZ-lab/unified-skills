---
name: ship-infrastructure-ci-cd
description: CI/CD 管道——自动化质量门和部署流水线。使用 cuando 需要设置或修改 CI/CD 管道、构建流程或自动化部署
---

# CI/CD — 持续集成与持续部署


## 入口/出口
- **入口**: 新项目需要 CI、现有 CI 需要修改、部署自动化配置
- **出口**: 工作管道定义 + 所有质量门通过
- **指向**: CI/CD 配置完成后继续 `/ship` 流程
- **假设已加载**: CANON.md

## 核心原则

### Shift Left
**问题越早发现成本越低。** 在 PR 中捕获比在 staging 捕获便宜 10x，比在生产捕获便宜 100x。

### Faster is Safer
**更小批次 + 更频繁发布 = 风险更低。** 大爆炸发布 = 大爆炸回滚。

## Quality Gate 流水线

```
Lint ──→ Type Check ──→ Unit Tests ──→ Build ──→ Integration Tests ──→ E2E Tests ──→ Security Audit ──→ Bundle Size
  │          │              │            │             │                  │                │                │
  ▼          ▼              ▼            ▼             ▼                  ▼                ▼                ▼
 代码风格  类型安全    单元行为    可构建    跨组件交互    关键用户流程    OWASP/CVE        不超过预算

任何门失败 → 管道停止 → 反馈给开发者
```

**不设可跳过的门。** 每道门都必须通过才能到下一道。

## GitHub Actions 配置

```yaml
name: CI
on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test -- --coverage
      - run: npm run build

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm audit --audit-level=high  # 有 high/critical → 失败
```

## CI 失败的反馈循环

CI 失败 → 输出必须告诉开发者：
1. **什么失败了**（Lint？Type？Test？）
2. **哪一行/哪个文件**
3. **怎么修复**（命令提示）

```yaml
# CI 配置加：失败时跑特定诊断
- name: Debug test failures
  if: failure()
  run: cat test-results.xml | grep -A 5 "failure"
```

## 部署策略

| 策略 | 风险 | 适用 |
|------|------|------|
| **Preview Deploy** (per PR) | 极低 | 每个 PR 独立环境，审查者可直接体验 |
| **Blue/Green** | 低 | 两套完整环境，瞬时切换，瞬时回滚 |
| **Staged Rollout** (10% → 50% → 100%) | 低-中 | 大流量服务，逐步减少风险 |
| **Rolling Update** | 中 | 逐个实例更新，标准 K8s/ECS |

**最低要求:**
- 每个部署必须有对应的回滚方案（命令或一键按钮）
- Staging 部署必须在生产部署之前
- Feature Flag 用于解耦部署（上线代码）和发布（启用功能）

## CI 优化

```
CI 慢 (>10 min)？
├── 缓存 node_modules (.npm / actions/cache)
├── 测试并行 (按模块分 job)
├── 使用本地 CI runner (而非 GitHub hosted)
├── 仅跑受影响的测试 (test impact analysis)
└── 拆分 heavy job (lint + type 可以并行)
```

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "先跳过 CI 直接部署，太慢了" | 跳过 CI = 把质量检查移到生产。你将在生产发现 CI 能在 5 分钟内发现的问题。 |
| "这个检查失败没关系" | 每次"没关系"都会变成下次"没关系"。最终 CI 完全被无视。 |
| "手动部署更快" | 手动部署 = 步骤可能遗漏、环境可能不对、回滚步骤不确定。一次手动失误 > 所有自动化成本。 |
| "CI red 先不管，之后修" | CI red 是项目当前唯一真相。Red CI 上继续提交 = 在不确定的基座上继续盖楼。 |

## 红旗 — STOP

- 某个 CI 门被跳过/注释掉/设为 allow_failure
- 密钥直接写在 CI yaml 中（用 GitHub Secrets / Vault）
- CI 中 `npm audit` 有 high/critical 但未处理
- 没有自动回滚机制的手动部署
- E2E 测试在 CI 中被禁用（太慢 → 并行化或给更多 CI 资源，不禁用）
- CI 配置中没有缓存导致每次都重新安装（浪费 CI 分钟数）

## 验证清单

- [ ] 所有质量门在 CI 中启用且必须通过
- [ ] CI 配置文件已提交（无密钥硬编码）
- [ ] 依赖缓存配置（node_modules/.cache）
- [ ] 部署策略明确（Preview / Blue-Green / Staged）
- [ ] 每个部署有回滚方案
- [ ] CI 失败输出包含具体诊断信息
- [ ] Staging 先于生产部署
