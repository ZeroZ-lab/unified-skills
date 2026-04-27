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

## Iron Law

<HARD-GATE>
```
每个质量门必须阻塞合并。
CI 红灯 + 合并 = 把已知问题推给下一个人。
没有缓存的 CI 是浪费分钟数。
```
</HARD-GATE>

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

## 好/坏 CI 配置对照

**坏 CI 配置 — 绝不能这样写：**

```yaml
# Bad: 无缓存、允许失败、密钥硬编码、无超时
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout
      - run: npm install
      - run: npm test
        continue-on-error: true  # 测试失败也继续！
      - run: npm run deploy
        env:
          AWS_SECRET_KEY: abc123hardcoded  # 密钥硬编码！
```

**好 CI 配置 — 参照这个标准：**

```yaml
# Good: 缓存、严格失败、密钥安全、超时、分离关注点
jobs:
  lint-and-typecheck:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npm run lint
      - run: npx tsc --noEmit

  test:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v4

  deploy:
    needs: [lint-and-typecheck, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - run: npm run deploy
        env:
          AWS_SECRET_KEY: ${{ secrets.AWS_SECRET_KEY }}
```

## 反模式修复表

| 问题 | 修复 |
|------|------|
| CI 中 `continue-on-error: true` | 删除。CI 的意义就是门控。允许失败 = 没有门。 |
| 无缓存每次全量安装 | 使用 actions/cache 或 setup-node 的 cache 参数 |
| 手动 SSH 到服务器部署 | 用 GitHub Actions / GitLab CI 自动化部署，可审计、可回滚 |
| CI 中跳过安全审计 | 添加 npm audit / Snyk / Trivy 步骤，critical 必须阻塞 |
| 不固定 Action 版本（用 @main） | 固定到 @v4 或 @sha256。@main 可能被供应链攻击。 |
| 所有步骤塞一个 job | 按关注点分离：lint、test、build、deploy 各自独立 job |
| 无超时设置 | 每个 job 设 timeout-minutes。防止挂起消耗资源 |

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
└── 拆分 heavy job (lint + type 并行)
```

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "先跳过 CI 直接部署，太慢了" | 跳过 CI = 把质量检查移到生产。你将在生产发现 CI 能在 5 分钟内发现的问题。 | 跳过 CI 部署到生产 → 引入已知 lint/type/test 问题 → 生产事故回滚成本是 CI 运行时间的 100x。 |
| "这个检查失败没关系" | 每次"没关系"都会变成下次"没关系"。最终 CI 完全被无视。 | 3 个月后 CI 红了没人看 → 所有质量门形同虚设 → 团队失去对 CI 的信任，回归手动流程。 |
| "手动部署更快" | 手动部署 = 步骤可能遗漏、环境可能不对、回滚步骤不确定。一次手动失误 > 所有自动化成本。 | 手动部署遗漏一个环境变量 → 生产 500 错误持续 45 分钟直到有人发现 → 不可回滚、不可审计。 |
| "CI red 先不管，之后修" | CI red 是项目当前唯一真相。Red CI 上继续提交 = 在不确定的基座上继续盖楼。 | Red CI 上继续提交 → 新代码与已有问题混合 → 定位根因耗时 5-10x → "之后修"变成"永远不修"。 |
| "CI 绿了就安全了" | 绿 CI ≠ 好测试。可能测试覆盖不足或有 allow_failure。 | 绿 CI + 低覆盖率 = 虚假安全感。重大 bug 在绿 CI 下照样上线，因为关键路径没有被测试。 |
| "E2E 太慢了不需要" | 关键用户流程必须有 E2E。只跑关键路径，不要全覆盖。 | 没有 E2E 的关键流程（支付/注册/登录）→ 用户在真实浏览器中的第一个动作就失败。 |
| "Flaky test 是别人的问题" | Flaky test 侵蚀团队信任。谁发现谁修，或标记并创建 issue。 | Flaky test 不修 → 团队习惯忽略 CI 失败 → 真实失败被当作 flaky 忽略 → 生产 bug。 |
| "缓存以后再加" | 第一天就加缓存。CI 慢了再加 = 两个月白等。 | 无缓存的 CI 每次 5-10 分钟安装依赖 → 全团队每天累计浪费数小时 → 开发者回避运行 CI。 |
| "手动 QA 比 CI 更靠谱" | 手动 QA 不持久、不可重复、不能 bisect。自动化是基线。 | 手动 QA 无法回归 → 每次 release 前重测全部流程 → 遗漏率 20-30% 且随项目增长恶化。 |
| "安全审计步骤加到 CI 太慢了" | 安全审计在 CI 中并行运行，不增加关键路径时间。 | 不在 CI 中跑安全审计 → 已知 CVE 悄悄进入生产 → 供应链攻击风险持续累积。 |

**违反字面规则就是违反精神。** 没有灰色地带。

## 红旗 — STOP

<HARD-GATE>
以下任何一个出现，立即停止：

- 某个 CI 门被跳过/注释掉/设为 allow_failure
- 密钥直接写在 CI yaml 中（用 GitHub Secrets / Vault）
- CI 中 `npm audit` 有 high/critical 但未处理
- 没有自动回滚机制的手动部署
- E2E 测试在 CI 中被禁用（太慢 → 并行化或给更多 CI 资源，不禁用）
- CI 配置中没有缓存导致每次都重新安装（浪费 CI 分钟数）

**注意来自人类伙伴的信号：**
- "CI 过了吗？" — 你可能没等 CI 结果
- "构建要多久？" — CI 太慢需要优化
- "能不能跳过安全检查就这一次？" — 绝不能。这是红旗。
- "为什么 CI 挂了？" — 你需要读错误日志而不是猜测
</HARD-GATE>

## 验证失败处理

| 失败场景 | 处理方式 |
|---------|---------|
| CI flaky（有时过有时不过） | 标记 flaky test。隔离运行确认。修复非确定性（时序、顺序依赖、外部服务）。 |
| 本地过但 CI 不过 | 检查环境差异（Node 版本、OS、环境变量）。用 CI 相同的 Docker 镜像本地测试。 |
| CI 构建时间 > 30 分钟 | 优先级：加缓存 > 拆分 job 并行 > 减少依赖 > 增量构建。 |
| 安全审计发现 Critical CVE | 阻塞合并。评估实际可利用性。有补丁则立即更新，无补丁则评估替代方案。 |
| E2E 测试超时 | 检查测试等待策略（用 wait-for 而非 sleep）。检查 CI 资源是否足够。 |

## 验证清单

- [ ] 所有质量门在 CI 中启用且必须通过
- [ ] CI 配置文件已提交（无密钥硬编码）
- [ ] 依赖缓存配置（node_modules/.cache）
- [ ] 部署策略明确（Preview / Blue-Green / Staged）
- [ ] 每个部署有回滚方案
- [ ] CI 失败输出包含具体诊断信息
- [ ] Staging 先于生产部署
