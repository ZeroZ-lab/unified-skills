---
name: ship-workflow-land
description: 合并 PR → 等待 CI → 验证生产。当 PR 已创建需要合并到主分支并验证部署，或提到"合并""merge""PR""land"
---

# Land — 合并 PR 并验证部署


## 入口/出口
- **入口**: 通过 review 的 PR
- **出口**: `docs/features/<name>/07-deploy-report.md`
- **输出路径**: `07-deploy-report.md` → `ship-workflow-canary`
- **指向**: 部署成功建议 `ship-workflow-canary` 监控
- **前置加载**: CANON.md

## 何时不使用
- PR 尚未通过 review 或仍有阻塞问题
- 当前任务只是本地提交、版本 bump 或准备 ship checklist
- 合并已经完成，只需要 canary 或 doc sync

## Iron Law

<HARD-GATE>
没有绿色 CI 就不合并。CI 红灯 = 不碰合并按钮。
CI 红灯时合并 = 把已知问题推给下一个发现它的人。
</HARD-GATE>

## 流程

### Step 1：检测 PR

确认 PR 状态：`gh pr view --json number,title,reviewDecision,statusCheckRollup,mergeable`

前置条件：OPEN + APPROVED + MERGEABLE。不满足时停止并报告阻塞项。

### Step 2：等 CI 通过（Green CI Gate）

持续监控 CI 直到全部绿色或超时（15 分钟）。

**超时处理：** 15 分钟超时 → 报告哪些 check 仍在运行；CI 失败 → 停止，不合并。查看失败日志：`gh run view <run-id> --log-failed`

**CI 失败时唯一允许操作：** 在 PR 分支修复 → 推送 → 重新等待 CI 全绿。绝不在 CI 红灯时合并。

### Step 3：合并准备度检查

CI 绿色后最终确认：
- [ ] CI 全部绿色（不是"大部分绿色"）
- [ ] Review 未过期（7 天内批准，超期需重新确认）
- [ ] PR body 准确描述了变更
- [ ] 如 PR 分支落后于 base，先 rebase 或 merge base

### Step 4：合并 PR

```bash
gh pr merge --squash --delete-branch  # 默认策略
gh pr merge --merge --delete-branch    # 项目约定用 merge commit 时
```

合并后验证：确认 `state=MERGED`。远程分支立即删除；本地分支在部署成功后再清理。

### Step 5：检测部署策略

读取项目配置确定部署方式：

| 检测到 | 部署方式 | 验证方法 |
|--------|---------|---------|
| `.github/workflows/deploy.yml` | GitHub Actions | `gh run list --workflow=deploy.yml` |
| `vercel.json` / `netlify.toml` | 平台自动部署 | `curl` 部署 URL |
| `fly.toml` | Fly.io | `fly status` |
| `Dockerfile` + K8s 配置 | 容器编排 | `kubectl rollout status` |
| 无自动部署配置 | 手动部署 | 询问 human partner |

### Step 6：等部署完成（Readiness Probe）

根据部署策略监控进度。10 分钟超时。超时后不假设失败——报告状态让 human partner 决定。

### Step 7：健康验证

curl 健康检查端点（`/health`、`/api/status`、`/api/readyz`、`/version`）。

通过条件：所有端点返回预期 status + 响应时间 < 5000ms + `/version` 返回新版本号。失败时不自动回滚，报告结果让 human partner 决定。

### Step 8：回滚能力确认

获取合并 commit SHA，验证 revert 命令可用。回滚剧本：`git revert -m 1 <sha>` → `git push origin main` → 等待自动部署。

回滚触发条件：健康检查 5xx、关键业务流程不可用、human partner 要求。

### 输出

生成 `docs/features/<name>/07-deploy-report.md`，包含合并信息、CI 状态、部署信息、健康验证表、回滚命令和下一步（必须执行 canary）。

## 验证证据

输出或记录必须包含：输入/来源、执行动作、验证结果、阻塞/回退。

## 常见说辞

| 说辞 | 现实 | 后果 |
|------|------|------|
| "CI 红灯但只是 flaky test" | Flaky test 也是问题。修掉或移除，不能忽略红灯。 | 团队 CI 信任度在 2 周内归零，真正故障被掩盖 >60% |
| "先合并再说，CI 跑着" | CI 红灯时合并 = 明知有问题还推进。 | 修复成本从 PR 内 30min 升级到主分支 hotfix 2-4h |
| "不需要等部署，反正有监控" | 不等部署验证 = 把验证推给用户。 | 故障在用户侧暴露需 15-30min，影响 500+ 用户 |
| "Squash merge 会丢历史" | Squash 保持主分支可读。详细历史在 PR 中完整保留。 | 不 squash：3 个月后主分支历史膨胀 10x，bisect 效率下降 80% |
| "小 PR 不需要健康验证" | 一个字符的配置错误也能让服务 500。PR 大小和影响大小无关。 | 单字符 typo 导致服务中断，故障发现延迟 30min |

## 红旗

<HARD-GATE>
以下任何一个出现，立即停止：

- CI 红灯时尝试合并
- 跳过健康验证直接宣布"部署成功"
- 合并后不删除远程分支（分支泄漏）
- 7 天前的 review 未重新确认就合并
- 没有确认部署策略就开始"等部署"
- 部署超时后假设成功
- 没有回滚路径就合并
- 合并后第一小时无人关注
</HARD-GATE>

## 验证失败处理

| 失败场景 | 处理方式 |
|----------|----------|
| CI 失败 | 阻塞合并，PR 分支修复后重推，等待全绿 |
| Review 过期（>7 天） | 阻塞合并，请 human partner 重新确认 |
| 合并冲突 | PR 分支 rebase/merge base 解决，重推后等 CI |
| 部署超时 | 不假设失败，报告状态让 human partner 决定 |
| 健康检查 5xx 或超时 | 不自动回滚，报告结果建议按回滚计划操作 |

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
- [ ] 07-deploy-report.md 已生成

## 输出模板

模板起点：`templates/feature/07-deploy-report.md`

```markdown
### Land 交付记录 — <feature-name>

**合并信息**: PR #[N] / squash merge / SHA [hash] / 时间 [timestamp]
**CI 状态**: [全部 PASSED / 具体未通过项] — 耗时 [X min]
**部署策略**: [GitHub Actions / Vercel / Fly.io / 手动]
**新版本**: [版本号 — 已确认 / 未确认]

**健康验证**:
| 端点 | Status | 响应时间 | 结果 |
|------|--------|---------|------|
| /health | [200] | [Xms] | PASS / FAIL |

**回滚**: [命令] — 预计耗时 < 5 min
**下一步**: 必须执行 ship-workflow-canary 进行 [2h / 24h] 持续监控
```
