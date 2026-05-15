---
name: ship-workflow-canary
description: 发布后健康监控。当代码已部署需要持续验证生产健康
---

# Canary — 发布后健康监控


## 入口/出口
- **入口**: 通过 review 且已部署的代码
- **出口**: `docs/features/<name>/05-canary-report.md`
- **输出路径**: `05-canary-report.md` → `reflect-workflow-retro`
- **指向**: 监控稳定后建议 `/retro`
- **前置加载**: CANON.md

## 何时不使用
- 代码尚未部署，仍在 review/ship/deploy 前
- 没有生产或可观测环境可验证
- 只是本地 smoke test 或一次性手动检查

## Iron Law

<HARD-GATE>
```
没有基线就不能监控。先采集基线再上线。
没有基线的监控等于闭着眼睛开车——你以为在监控，实际上只是在看噪声。
```
</HARD-GATE>

## 流程

### Phase 1：基线采集

部署前（或部署后立即）采集健康基线：

```bash
# 对每个关键端点采集基线
for endpoint in /health /api/status /api/readyz; do
  echo "--- $endpoint ---"
  start=$(date +%s%N)
  status=$(curl -s -o /dev/null -w '%{http_code}' "https://${HOST}${endpoint}")
  end=$(date +%s%N)
  elapsed=$(( (end - start) / 1000000 ))
  body_hash=$(curl -s "https://${HOST}${endpoint}" | shasum -a 256 | cut -d' ' -f1)
  echo "{\"endpoint\":\"$endpoint\",\"status\":$status,\"response_ms\":$elapsed,\"body_hash\":\"$body_hash\"}"
done
```

输出 `baseline.json`：
```json
{
  "collected_at": "2025-01-15T10:00:00Z",
  "endpoints": [
    {
      "endpoint": "/health",
      "status_code": 200,
      "response_ms": 45,
      "body_hash": "a1b2c3..."
    }
  ]
}
```

**基线规则：**
- 每个端点至少采集 3 次，取中位数
- 记录 status code + response time + body hash
- 基线采集失败 = 阻塞。不能在不知道"正常是什么样"的情况下开始监控

### Phase 2：循环监控

每 60 秒轮询端点，比对基线：

```bash
# 单次检查脚本
check_endpoint() {
  local endpoint=$1 baseline_status=$2 baseline_ms=$3
  local start status elapsed

  start=$(date +%s%N)
  status=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "https://${HOST}${endpoint}")
  end=$(date +%s%N)
  elapsed=$(( (end - start) / 1000000 ))

  # 分级判定
  if [ "$status" = "000" ]; then
    echo "CRITICAL|$endpoint|不可达"
  elif [ "$status" != "$baseline_status" ] && [ "$status" -ge 500 ]; then
    echo "CRITICAL|$endpoint|新5xx:$status"
  elif [ "$status" != "$baseline_status" ] && [ "$status" -ge 400 ]; then
    echo "HIGH|$endpoint|新错误码:$status(基线:$baseline_status)"
  elif [ "$elapsed" -gt $((baseline_ms * 2)) ]; then
    echo "MEDIUM|$endpoint|响应时间${elapsed}ms>2x基线${baseline_ms}ms"
  elif [ "$status" != "$baseline_status" ] && [ "$status" -ge 300 ]; then
    echo "LOW|$endpoint|新重定向:$status(基线:$baseline_status)"
  else
    echo "OK|$endpoint|status=$status time=${elapsed}ms"
  fi
}
```

**告警分级：**

| 级别 | 条件 | 含义 |
|------|------|------|
| CRITICAL | 端点不可达（curl 超时/连接拒绝） | 服务挂了 |
| HIGH | 新的 4xx/5xx 错误码 | 功能损坏 |
| MEDIUM | 响应时间 > 2x 基线 | 性能退化 |
| LOW | 新的重定向 | 可能的配置变更 |

**防抖规则：** 连续 2+ 次检测到同一级别异常才触发告警。单次异常记录为 `TRANSIENT`，不告警。

**监控持续时间：**
- 小型变更：30 分钟
- 标准变更：2 小时
- 重大变更（核心路径/数据库 migration）：24 小时

### Phase 3：健康报告

监控结束后生成端点健康状态摘要：

| 状态 | 定义 |
|------|------|
| HEALTHY | 全部检查 OK，无 TRANSIENT |
| DEGRADED | 有 LOW/MEDIUM 级别异常，但无 HIGH/CRITICAL |
| BROKEN | 有 HIGH/CRITICAL 级别异常 |

输出 `docs/features/<name>/05-canary-report.md`：

```markdown
# Canary Report — <name>

## 摘要
- 监控时长: X 小时
- 检查次数: N
- 结果: HEALTHY / DEGRADED / BROKEN

## 端点状态

| 端点 | 状态 | 基线响应 | 平均响应 | 异常次数 |
|------|------|---------|---------|---------|
| /health | HEALTHY | 45ms | 48ms | 0 |
| /api/status | DEGRADED | 120ms | 310ms | 3 (MEDIUM) |

## 异常详情
[按时间线列出所有非 OK 检查]

## 建议
- HEALTHY → 更新基线，必须进入 /retro
- DEGRADED → 继续监控，调查退化端点
- BROKEN → 立即回滚，参考回滚计划
```

### Phase 4：基线更新

当所有端点均为 HEALTHY 时，可选更新基线：

```bash
# 用最新数据覆盖 baseline.json
mv current-round.json baseline.json
```

**规则：**
- 只有全部端点 HEALTHY 才更新
- DEGRADED 或 BROKEN 时不更新——基线代表"已知良好状态"
- 更新前保存旧基线为 `baseline-$(date +%Y%m%d).json`

## 验证证据

输出或记录必须包含：
- **输入/来源**: 读取的 spec、plan、代码、反馈或发布上下文。
- **执行动作**: 实际完成的检查、生成、修复、导出或发布步骤。
- **验证结果**: 命令、审查结论、产物路径、截图或人工确认。
- **阻塞/回退**: 未通过项、回退路径或需要 human partner 决策的问题。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "部署完就没事了" | 部署只是上线的一半。上线后第一个小时的监控决定用户是否受影响。 | 不监控的上线：故障平均 15 分钟由用户投诉发现，影响 100+ 用户，信任损失修复需 1-2 周。 |
| "不需要基线，看日志就行" | 日志告诉你"发生了什么"，基线告诉你"这正不正常"。没有基线，所有数据都是噪声。 | 无基线监控：每次告警需 20-40 分钟人工判断是否正常，MTTR 从 5 分钟延长到 45+ 分钟。 |
| "60 秒检查太频繁了" | 60 秒能在 2 分钟内发现故障（防抖后）。用户发现故障平均需要 15 分钟。 | 5 分钟间隔检查：故障检测延迟从 2 分钟增加到 10+ 分钟，每分钟影响 50-200 活跃用户。 |
| "出问题再看" | 出问题时你已经损失了用户。主动监控把发现时间从"用户投诉"缩短到"分钟级"。 | 被动等待投诉：故障暴露延迟 30-60 分钟，客户流失率提升 3-5%，每次事故直接损失 ¥5K-¥50K。 |
| "只要 200 就行" | 200 但响应时间从 50ms 涨到 5000ms = 用户已经无法使用。Status code 不是健康的全部。 | 只看 status code：慢响应 5 秒的用户体验等同于服务中断，转化率下降 20-40%，10% 用户直接离开。 |

## 红旗

<HARD-GATE>
以下任何一个出现，立即停止：

- 没有基线就开始监控
- 只检查 status code 不检查响应时间
- 单次异常就告警（没有防抖）
- 监控 5 分钟就宣布"稳定"
- 基线采集失败但仍然继续部署
- BROKEN 状态但没有触发回滚
- 监控期间无人值守（重大变更的 24 小时监控需要 oncall）
- 关键业务端点不在监控列表中
</HARD-GATE>

## 好/坏示例

### 坏：只看 status code

```markdown
Canary 结果: 所有端点返回 200，部署成功。
```

问题：没有基线对比、没有响应时间数据、没有异常详情。200 可能伴随 10x 响应时间退化。

### 好：证据驱动的 canary 报告

```markdown
Canary Report — payment-v2

## 摘要
- 监控时长: 2 小时
- 检查次数: 120
- 结果: DEGRADED

## 端点状态
| 端点 | 状态 | 基线响应 | 平均响应 | 异常次数 |
|------|------|---------|---------|---------|
| /health | HEALTHY | 45ms | 48ms | 0 |
| /api/payments/process | DEGRADED | 320ms | 780ms | 8 (MEDIUM) |

## 异常详情
- 14:05 /api/payments/process 响应 780ms (2.4x 基线 320ms)
- 14:06 /api/payments/process 响应 810ms (2.5x 基线)
- 连续 8 次超过 2x 基线，防抖确认 MEDIUM

## 建议
- /health HEALTHY → 可更新基线
- /api/payments/process DEGRADED → 继续监控 30 分钟，排查支付服务慢查询
- 如 30 分钟后仍 DEGRADED → 建议回滚
```

优点：有基线对比、量化退化程度、防抖确认、明确下一步行动。

## 输出模板

```markdown
### Canary Report 交付记录 — <feature-name>

**监控时长**: [X 小时]
**检查次数**: [N]
**变更规模**: [小型 30min / 标准 2h / 重大 24h]

**端点状态**:
| 端点 | 状态 | 基线响应 | 平均响应 | 异常次数 |
|------|------|---------|---------|---------|
| /health | HEALTHY / DEGRADED / BROKEN | [Xms] | [Yms] | [N] |

**异常详情**: [时间线 — 所有非 OK 检查 + 防抖确认]
**基线更新**: [全部 HEALTHY → 已更新 / 有 DEGRADED → 未更新]
**下一步**: [HEALTHY → /retro / DEGRADED → 继续监控 / BROKEN → 回滚]
```

## 验证失败处理

| 失败场景 | 处理方式 |
|----------|----------|
| 基线采集失败（端点不可达） | 阻塞部署，修复端点或排除后重新采集，不得在没有基线的情况下开始监控 |
| 连续 2+ 次 CRITICAL 告警 | 立即触发回滚，按回滚计划执行，通知 human partner |
| 响应时间 >2x 基线持续 10 分钟 | 降级为 DEGRADED，继续监控 30 分钟；若持续退化则建议回滚 |
| 监控 30 分钟内出现 TRANSIENT >5 次 | 延长监控至 2 小时，排查抖动根因，不宣布 HEALTHY |
| 监控结束时仍有 DEGRADED 端点 | 不更新基线，输出报告中标注退化端点，建议 human partner 决定是否继续或回滚 |

## 验证清单

- [ ] baseline.json 已采集（至少 3 次取中位数）
- [ ] 所有关键端点在监控列表中
- [ ] 防抖机制生效（连续 2+ 次才告警）
- [ ] 监控持续时间与变更规模匹配
- [ ] 05-canary-report.md 已生成
- [ ] 所有端点状态为 HEALTHY（或 DEGRADED/BROKEN 有对应行动）
- [ ] HEALTHY 端点基线已更新
