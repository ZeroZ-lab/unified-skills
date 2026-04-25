---
name: ship-workflow-land
description: 合并 PR → 等待 CI → 验证生产。使用 cuando PR 已创建需要合并到主分支并验证部署
---

# Land — 合并 PR 并验证部署


## 入口/出口
- **入口**: 通过 review 的 PR
- **出口**: `docs/features/<name>/deploy-report.md`
- **指向**: 部署成功建议 `ship-workflow-canary` 监控
- **假设已加载**: CANON.md

## Iron Law

```
没有绿色 CI 就不合并。CI 红灯 = 不碰合并按钮。
CI 红灯时合并 = 把已知问题推给下一个发现它的人。
```

## 流程

### Step 1：检测 PR

确认当前 PR 状态：

```bash
gh pr status
gh pr view --json number,title,reviewDecision,statusCheckRollup,mergeable
```

**前置条件：**
- PR 状态为 OPEN
- reviewDecision 为 APPROVED
- mergeable 为 MERGEABLE（无冲突）
- 如不满足，停止并报告具体阻塞项

### Step 2：等 CI 通过

持续监控 CI 状态直到全部绿色或超时：

```bash
# 等待所有 checks 通过，15 分钟超时
gh pr checks --watch 2>/dev/null
# 或手动轮询
timeout 900 bash -c 'while ! gh pr checks 2>/dev/null | grep -q "pass"; do sleep 30; done'
```

**超时处理：**
- 15 分钟超时 → 报告哪些 check 仍在运行
- CI 失败 → **停止。不合并。** 报告失败 check 名称和日志
- 查看失败日志：`gh run view <run-id> --log-failed`

**CI 失败时的唯一允许操作：**
1. 在 PR 分支上修复问题
2. 推送修复 commit
3. 重新等待 CI 全部绿色
4. 绝不在 CI 红灯时合并

### Step 3：合并准备度检查

CI 绿色后，合并前最终确认：

```bash
# 检查 review 是否过期（超过 7 天的 review 需要重新确认）
gh pr view --json reviews --jq '.reviews | .[] | select(.state=="APPROVED") | .submittedAt'

# 检查 PR 分支是否与 base 同步
gh pr view --json behindBy --jq '.behindBy'
```

**检查清单：**
- [ ] CI 全部绿色（不是"大部分绿色"）
- [ ] Review 未过期（7 天内批准）
- [ ] PR body 准确描述了变更
- [ ] 如 PR 分支落后于 base，先 rebase 或 merge base
- [ ] 测试结果在 PR 中可见且通过

**Review 过期处理：** 超过 7 天的 APPROVED review，询问 human partner 是否需要重新确认。

### Step 4：合并 PR

```bash
# Squash merge（默认策略，保持主分支历史清洁）
gh pr merge --squash --delete-branch

# 如果项目约定用 merge commit
gh pr merge --merge --delete-branch
```

**合并后立即验证：**
```bash
# 确认 PR 已关闭
gh pr view <number> --json state --jq '.state'
# 应输出: MERGED
```

**分支清理：** 合并后删除远程分支（`--delete-branch`）。本地分支在确认部署成功后再清理。

### Step 5：检测部署策略

读取项目配置确定部署方式：

```bash
# 1. 读 CLAUDE.md 中的部署配置
# 2. 检测 CI workflow files
ls -la .github/workflows/ 2>/dev/null
ls -la .gitlab-ci.yml 2>/dev/null
ls -la vercel.json netlify.toml fly.toml Dockerfile 2>/dev/null
```

**常见部署策略：**

| 检测到 | 部署方式 | 验证方法 |
|--------|---------|---------|
| `.github/workflows/deploy.yml` | GitHub Actions 自动部署 | `gh run list --workflow=deploy.yml` |
| `vercel.json` / `netlify.toml` | 平台自动部署 | `curl` 部署 URL |
| `fly.toml` | Fly.io | `fly status` |
| `Dockerfile` + K8s 配置 | 容器编排 | `kubectl rollout status` |
| 无自动部署配置 | 手动部署 | 询问 human partner 部署命令 |

### Step 6：等部署完成

根据检测到的部署策略监控部署进度：

```bash
# GitHub Actions
gh run list --workflow=deploy.yml --limit 1
gh run watch <run-id>

# 通用：轮询健康检查直到新版本上线
timeout 600 bash -c '
  while true; do
    version=$(curl -s https://${HOST}/version 2>/dev/null)
    if echo "$version" | grep -q "<new-version>"; then
      echo "Deploy confirmed: $version"
      break
    fi
    sleep 15
  done
'
```

**超时处理：** 10 分钟超时。超时后不假设部署失败——报告当前状态，让 human partner 决定。

### Step 7：健康验证

部署完成后 curl 健康检查端点：

```bash
# 基础健康检查
for endpoint in /health /api/status /api/readyz /version; do
  echo "--- $endpoint ---"
  start=$(date +%s%N)
  status=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "https://${HOST}${endpoint}")
  end=$(date +%s%N)
  elapsed=$(( (end - start) / 1000000 ))
  echo "status=$status time=${elapsed}ms"
done
```

**通过条件：**
- 所有端点返回预期 status code（通常 200）
- 响应时间 < 5000ms
- `/version` 返回新版本号

**失败时：** 不自动回滚。报告结果，建议 human partner 按回滚计划操作。

### Step 8：回滚能力

确认回滚路径可用：

```bash
# 获取合并 commit SHA
merge_sha=$(gh pr view <number> --json mergeCommit --jq '.mergeCommit.oid')

# 验证 revert 命令可用（dry run）
git log --oneline -1 $merge_sha
```

**回滚剧本（如果需要）：**
```bash
# 1. revert 合并 commit
git revert -m 1 $merge_sha
# 2. 推送到主分支
git push origin main
# 3. 等待自动部署（回到 Step 6-7）
```

**回滚触发条件：**
- 健康检查端点返回 5xx
- 关键业务流程不可用
- human partner 明确要求回滚

### 输出

生成 `docs/features/<name>/deploy-report.md`：

```markdown
# Deploy Report — <name>

## 合并信息
- PR: #<number>
- 合并方式: squash / merge
- 合并 SHA: <sha>
- 合并时间: <timestamp>

## CI 状态
- 全部 checks: PASSED
- CI 耗时: X 分钟

## 部署信息
- 部署策略: <策略>
- 部署耗时: X 分钟
- 新版本: <version>

## 健康验证
| 端点 | Status | 响应时间 | 结果 |
|------|--------|---------|------|
| /health | 200 | 45ms | PASS |
| /api/status | 200 | 120ms | PASS |

## 回滚
- 回滚命令: `git revert -m 1 <sha> && git push origin main`
- 回滚预计耗时: < 5 分钟

## 下一步
- 必须执行 `ship-workflow-canary` 进行持续监控
```

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "CI 红灯但只是 flaky test" | Flaky test 也是问题。修掉 flaky test 或从 CI 移除，但不能忽略红灯。 |
| "先合并再说，CI 跑着" | CI 红灯时合并 = 明知有问题还推进。这不是速度，是赌博。 |
| "不需要等部署，反正有监控" | 不等部署验证 = 把验证推给用户。监控是兜底，不是替代。 |
| "Squash merge 会丢历史" | Squash 保持主分支可读。详细历史在 PR 和分支中完整保留。 |
| "小 PR 不需要健康验证" | 一个字符的配置错误也能让整个服务 500。PR 大小和影响大小无关。 |

## 红旗

- CI 红灯时尝试合并
- 跳过健康验证直接宣布"部署成功"
- 合并后不删除远程分支（分支泄漏）
- 7 天前的 review 未重新确认就合并
- 没有确认部署策略就开始"等部署"
- 部署超时后假设成功
- 没有回滚路径就合并（merge commit 无法 revert）
- 合并后第一小时无人关注

## 验证清单

- [ ] PR review 状态为 APPROVED
- [ ] CI 全部绿色（无一例外）
- [ ] Review 未过期（7 天内）
- [ ] PR body 准确描述变更
- [ ] PR 已成功合并（state=MERGED）
- [ ] 远程分支已清理
- [ ] 部署策略已检测
- [ ] 部署已成功完成
- [ ] 健康检查端点全部通过
- [ ] 新版本号已确认
- [ ] 回滚路径已验证
- [ ] deploy-report.md 已生成
