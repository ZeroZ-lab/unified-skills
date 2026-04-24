---
name: ship-workflow-doc-sync
description: 发布后文档同步。使用 cuando 代码已合并需要同步更新项目文档
---

# Doc Sync — 发布后文档同步


## 入口/出口
- **入口**: 已合并到主分支的变更
- **出口**: 文档一致性报告
- **假设已加载**: CANON.md

## 关键规则

### "不停顿"列表（事实修正，直接做）

以下类型的变更属于事实性更新，**直接执行，不询问**：

- 文件路径变更（重命名、移动）
- 数量变更（API 端点数、组件数、配置项数）
- 版本号更新（依赖版本、项目版本）
- 命令变更（CLI 参数、脚本名称）
- 配置字段增删（环境变量名、配置键名）
- 链接修复（指向已移动或重命名的文件）
- 过时引用删除（引用已删除的文件或函数）
- 拼写/格式修正

### "必须停顿"列表（叙事变更，问 human partner）

以下类型的变更涉及叙述和判断，**必须询问 human partner**：

- 新功能的描述或理由
- 架构决策的解释
- 新增章节或段落
- 变更影响范围的主观评估
- 迁移指南或升级步骤
- 弃用通知的措辞
- README 中的项目定位变更
- 与第三方集成的描述

## 流程

### Step 1：Diff 分析

收集本次变更涉及的文件：

```bash
# 获取合并 commit 的变更文件列表
merge_sha=$(git log --oneline -1 --merges --format='%H')
git diff-tree --no-commit-id --name-only -r $merge_sha

# 或对比 PR 合并前后的 diff
git diff main~1 main --name-only
git diff main~1 main --stat
```

**分类变更：**
- 代码文件（src/、lib/、app/）→ 影响 README、ARCHITECTURE.md、API 文档
- 配置文件（.env.example、config/、docker-compose）→ 影响 README 部署章节
- 依赖文件（package.json、requirements.txt、go.mod）→ 影响安装/部署文档
- 测试文件 → 通常不影响文档
- CI/CD 文件 → 影响 CONTRIBUTING.md 或 CI 文档

### Step 2：逐文档审计

交叉引用变更文件与项目文档：

```bash
# 列出项目文档文件
for doc in README.md CLAUDE.md AGENTS.md ARCHITECTURE.md CHANGELOG.md CONTRIBUTING.md docs/**/*.md; do
  if [ -f "$doc" ]; then
    echo "=== $doc ==="
    # 检查文档中是否引用了变更的文件
    for changed_file in $(git diff main~1 main --name-only); do
      if grep -q "$changed_file" "$doc" 2>/dev/null; then
        echo "  REFERENCES: $changed_file (needs review)"
      fi
    done
  fi
done
```

**审计维度：**

| 文档 | 检查内容 |
|------|---------|
| README.md | 项目描述、安装步骤、快速开始、特性列表 |
| CLAUDE.md | 命令映射、技能列表、项目结构 |
| AGENTS.md | Agent 角色定义、职责描述 |
| ARCHITECTURE.md | 组件关系、数据流、技术栈 |
| CHANGELOG.md | 版本条目、变更类型 |
| CONTRIBUTING.md | 开发流程、PR 规则、CI 说明 |
| API 文档 | 端点列表、请求/响应格式 |

### Step 3：自动更新事实性内容

对 Step 2 中发现的事实性不一致，直接修复：

```bash
# 示例：更新路径引用
sed -i '' 's|old/path|new/path|g' README.md

# 示例：更新版本号
sed -i '' 's|version: 1.2.3|version: 1.3.0|g' README.md

# 示例：更新端点数量
# 旧: "5 API endpoints"
# 新: "6 API endpoints"（检查实际数量后更新）
```

**执行规则：**
- 每处修改都记录到"文档一致性报告"中
- 不修改叙事性内容（描述、理由、解释）
- 不添加新章节或新段落
- 数量变更必须先验证实际数量，不能假设

### Step 4：询问用户叙事性变更

对 Step 2 中发现的叙事性不一致，逐条询问 human partner：

**格式：** 每次只问一个问题（宪法第 9 条）：

```
文档同步发现需要更新的叙事性内容：

文件: README.md
位置: "Features" 章节
当前描述: "支持文件上传功能"
需要更新: 本次变更添加了批量上传支持

请提供更新后的描述（或回复"跳过"保持不变）：
```

**规则：**
- 每个问题包含：文件路径 + 具体位置 + 当前内容 + 变更原因
- human partner 可以提供新内容或选择跳过
- 不替 human partner 写叙事性内容

### Step 5：CHANGELOG 润色

检查 CHANGELOG.md 中的最新条目：

```bash
# 读取 CHANGELOG 顶部条目
head -50 CHANGELOG.md
```

**润色规则：**
- 绝不覆盖或删除已有条目
- 只润色最新条目的措辞（更清晰、更一致）
- 保持条目格式与已有条目一致
- 变更类型分类：Added / Changed / Fixed / Deprecated / Removed / Security
- 每条变更以动词开头

**禁止操作：**
- 不重写历史条目
- 不调整条目顺序
- 不合并或拆分已有条目

### Step 6：跨文档一致性检查

验证同一事实在所有文档中表述一致：

```bash
# 交叉验证版本号
echo "=== 版本号一致性 ==="
grep -r "version" README.md package.json CLAUDE.md 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+'

# 交叉验证特性列表
echo "=== 特性列表一致性 ==="
grep -A 20 "## Features" README.md
grep -A 20 "features" CLAUDE.md

# 交叉验证组件列表
echo "=== 组件列表一致性 ==="
grep -A 10 "components" ARCHITECTURE.md
grep -A 10 "components" README.md
```

**检查维度：**

| 维度 | 检查方法 |
|------|---------|
| 版本号 | 所有文件中的版本号一致 |
| 特性列表 | README 与 CLAUDE.md 中列出的特性一致 |
| 组件列表 | ARCHITECTURE.md 与 CLAUDE.md 中项目结构一致 |
| 命令列表 | README 与 CLAUDE.md 中可用命令一致 |
| API 端点 | API 文档与实际代码路由一致 |

**不一致时：** 以代码为真实来源（source of truth），更新文档匹配代码。

### Step 7：可发现性检查

确认每个文档都能从入口点到达：

```bash
# 检查 README 是否链接到其他文档
echo "=== README 链接 ==="
grep -o '\[.*\](.*)' README.md

# 检查 CLAUDE.md 是否引用了所有技能
echo "=== CLAUDE.md 技能引用 ==="
ls skills/*/SKILL.md | while read f; do
  skill_name=$(grep '^name:' "$f" | cut -d' ' -f2)
  if ! grep -q "$skill_name" CLAUDE.md 2>/dev/null; then
    echo "  MISSING: $skill_name not referenced in CLAUDE.md"
  fi
done
```

**规则：**
- 每个文档必须从 README.md 或 CLAUDE.md 通过链接可达
- 孤立文档（无法从入口点发现）需要添加引用
- 引用应出现在逻辑相关的章节中，不是简单堆砌

## 输出

生成文档一致性报告（输出到终端，不创建文件，除非 human partner 要求）：

```
文档同步完成：

事实性更新（已自动执行）：
  - README.md: 更新路径 old/path → new/path
  - ARCHITECTURE.md: 组件数量 12 → 13
  - CLAUDE.md: 版本号 1.2.0 → 1.3.0

叙事性更新（已询问 human partner）：
  - README.md "Features" 章节: 已更新 (user provided)
  - ARCHITECTURE.md "Data Flow" 章节: 跳过 (user declined)

CHANGELOG:
  - 最新条目措辞已润色，未修改历史条目

一致性检查:
  - 版本号: 一致
  - 特性列表: 一致
  - 组件列表: 不一致 (ARCHITECTURE.md 缺少 Widget 组件 → 已修复)
  - 命令列表: 一致

可发现性:
  - docs/api.md: 无法从 README 到达 → 已在 README 添加链接
  - 所有其他文档: 可达
```

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "文档以后再更新" | "以后"永远不会来。代码变更时同步更新文档成本最低。事后补文档 = 重新理解代码。 |
| "CHANGELOG 自己写就行" | AI 可以润色措辞，但变更的业务意义只有 human partner 知道。AI 不替人写叙事。 |
| "README 不需要那么详细" | README 是新人的第一个文件。少一个步骤 = 新人多花一小时摸索。 |
| "这个文档没人看" | 没人看是因为过时了。保持准确的文档会被人发现和使用。 |
| "自动更新就行，不用问" | 事实可以自动更新。叙事、判断、理由不能。混淆两者 = 文档失去人的视角。 |

## 红旗

- 不区分事实性更新和叙事性变更，全部自动修改
- 修改或删除 CHANGELOG 中的历史条目
- 不验证实际数量就更新文档中的数字
- 添加 human partner 不知道的新章节
- 跳过跨文档一致性检查
- 文档中有无法从入口点到达的孤立页面
- 以"文档不重要"为由跳过整个同步流程
- 在 Step 4 中一次列出多个问题让 human partner 批量回答

## 验证清单

- [ ] 所有变更文件已识别并分类
- [ ] 事实性更新已自动执行并记录
- [ ] 叙事性变更已逐条询问 human partner
- [ ] CHANGELOG 仅润色最新条目，历史未动
- [ ] 版本号跨文档一致
- [ ] 特性列表跨文档一致
- [ ] 组件列表跨文档一致
- [ ] 所有文档可从入口点到达
- [ ] 文档一致性报告已输出
