# Plan: 技术债清理项目

## Plan Topology

**Topology:** `parallel`
**理由:** 3 个主要任务（版本同步、索引生成、历史文档标记）相互独立，可以并行开发；验证脚本集成依赖所有任务；文档更新在最后。

## Parallel Execution Matrix

| Subplan | Parallel Safe | Depends On | Write Scope |
|---------|---------------|------------|-------------|
| plans/01-version-sync.md | yes | none | scripts/sync-version.sh, tests/* |
| plans/02-index-gen.md | yes | none | scripts/generate-index.sh, tests/* |
| plans/03-historical-docs.md | yes | none | docs/features/*/README.md, docs/architecture/* |
| plans/04-validate-integration.md | no | 01, 02, 03 | validate, tests/* |
| plans/05-doc-update.md | no | 04 | README.md, AGENTS.md, CHANGELOG.md |

## File Structure

```
unified/
├── scripts/
│   ├── sync-version.sh          # 新增：版本同步脚本
│   ├── generate-index.sh        # 新增：索引生成脚本
│   └── tests/                   # 新增：脚本测试目录
│       ├── test-sync-version.sh
│       └── test-generate-index.sh
├── validate                      # 修改：集成新检查
├── docs/features/
│   ├── 20260426-minecraft-city/README.md  # 修改：添加历史标记
│   ├── 20260427-codex-hooks-commands/README.md  # 修改：添加历史标记
│   ├── 20260427-iron-law-injection/README.md  # 修改：添加历史标记
│   └── README.md                # 修改：完善历史文档说明
├── docs/architecture/
│   └── command-agent-skill-architecture.md  # 修改：添加过期章节标记
├── README.md                     # 修改：添加自动化工具说明
├── AGENTS.md                     # 修改：添加自动化工具引用
└── CHANGELOG.md                  # 修改：记录变更
```

## 任务分解

### 总控任务

#### Task 0: 项目初始化

**Files:**
- Create: `scripts/tests/`
- Create: `docs/features/20260510-technical-debt-cleanup/03-plan.md`

**依赖:** none

- [ ] **Step 1: 创建测试目录**
```bash
mkdir -p scripts/tests
```

- [ ] **Step 2: 验证目录创建**
```bash
ls -la scripts/tests/
```

- [ ] **Step 3: 创建本计划文档**
```markdown
# 当前文档
```

- [ ] **Step 4: 记录完成**
```bash
git add scripts/tests/ docs/features/20260510-technical-debt-cleanup/03-plan.md
git commit -m "plan: 技术债清理项目计划"
```

---

## 子计划详情

### plans/01-version-sync.md

**Subplan Contract:**
- **Owner:** software-engineer
- **Status:** parallel_safe
- **Depends On:** none
- **Write Scope:** `scripts/sync-version.sh`, `scripts/tests/test-sync-version.sh`
- **Read Scope:** `package.json`, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`
- **Verification Evidence:** 测试通过 + 手动验证 3 个文件版本号一致
- **Merge Checkpoint:** 版本同步脚本能正确更新所有文件且测试通过

#### Task 1.1: 创建版本同步脚本

**Files:**
- Create: `scripts/sync-version.sh`

**依赖:** Task 0

- [ ] **Step 1: 写失败测试**

```bash
# tests/test-sync-version.sh
#!/usr/bin/env bash
set -e

echo "Testing version sync..."

# 设置测试版本
TEST_VERSION="2.15.0"

# 备份原文件
cp package.json package.json.bak
cp .claude-plugin/plugin.json .claude-plugin/plugin.json.bak
cp .codex-plugin/plugin.json .codex-plugin/plugin.json.bak

# 修改 package.json 版本
python3 -c "import json; d=json.load(open('package.json')); d['version']='$TEST_VERSION'; json.dump(d, open('package.json', 'w'), indent=2)"

# 运行同步脚本
bash scripts/sync-version.sh

# 验证所有文件版本一致
pkg_ver=$(python3 -c "import json; print(json.load(open('package.json'))['version'])")
claude_ver=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
codex_ver=$(python3 -c "import json; print(json.load(open('.codex-plugin/plugin.json'))['version'])")

if [ "$pkg_ver" != "$TEST_VERSION" ] || [ "$claude_ver" != "$TEST_VERSION" ] || [ "$codex_ver" != "$TEST_VERSION" ]; then
  echo "FAIL: Version mismatch"
  exit 1
fi

# 恢复文件
mv package.json.bak package.json
mv .claude-plugin/plugin.json.bak .claude-plugin/plugin.json
mv .codex-plugin/plugin.json.bak .codex-plugin/plugin.json

echo "PASS: Version sync test"
```

- [ ] **Step 2: 验证测试失败**

```bash
bash tests/test-sync-version.sh
# 预期：FAIL - scripts/sync-version.sh 不存在
```

- [ ] **Step 3: 写最小实现**

```bash
# scripts/sync-version.sh
#!/usr/bin/env bash
set -e

# 从 package.json 读取版本号
VERSION=$(python3 -c "import json; print(json.load(open('package.json'))['version'])")

echo "Syncing version to $VERSION..."

# 更新 .claude-plugin/plugin.json
python3 -c "
import json
d = json.load(open('.claude-plugin/plugin.json'))
d['version'] = '$VERSION'
json.dump(d, open('.claude-plugin/plugin.json', 'w'), indent=2)
"

# 更新 .codex-plugin/plugin.json
python3 -c "
import json
d = json.load(open('.codex-plugin/plugin.json'))
d['version'] = '$VERSION'
json.dump(d, open('.codex-plugin/plugin.json', 'w'), indent=2)
"

echo "Version synced to $VERSION"
```

- [ ] **Step 4: 验证测试通过**

```bash
bash tests/test-sync-version.sh
# 预期：PASS
```

- [ ] **Step 5: Commit**

```bash
git add scripts/sync-version.sh scripts/tests/test-sync-version.sh
git commit -m "feat: add version sync script with tests"
```

---

### plans/02-index-gen.md

**Subplan Contract:**
- **Owner:** software-engineer
- **Status:** parallel_safe
- **Depends On:** none
- **Write Scope:** `scripts/generate-index.sh`, `scripts/tests/test-generate-index.sh`
- **Read Scope:** `skills/*/SKILL.md`, `skills-index.json`
- **Verification Evidence:** 生成的索引与现有索引一致
- **Merge Checkpoint:** 索引生成脚本能正确生成 skills-index.json

#### Task 2.1: 创建索引生成脚本

**Files:**
- Create: `scripts/generate-index.sh`
- Create: `scripts/tests/test-generate-index.sh`

**依赖:** Task 0

- [ ] **Step 1: 写失败测试**

```bash
# tests/test-generate-index.sh
#!/usr/bin/env bash
set -e

echo "Testing index generation..."

# 备份原文件
cp skills-index.json skills-index.json.bak

# 运行生成脚本
bash scripts/generate-index.sh

# 验证生成的 JSON 有效
python3 -c "import json; json.load(open('skills-index.json'))" || {
  echo "FAIL: Invalid JSON"
  exit 1
}

# 验证所有技能都在索引中
python3 <<'PY'
import json
from pathlib import Path

index = json.load(open("skills-index.json"))
root_skills = sorted(p.parent.name for p in Path("skills").glob("*/SKILL.md"))

phase_refs = set()
for entry in index.get("by_phase", {}).values():
    phase_refs.update(entry.get("skills", []))

root_set = set(root_skills)

if root_set != phase_refs:
    missing = sorted(root_set - phase_refs)
    extra = sorted(phase_refs - root_set)
    if missing:
        print(f"FAIL: Missing skills: {', '.join(missing)}")
        exit(1)
    if extra:
        print(f"FAIL: Extra skills: {', '.join(extra)}")
        exit(1)

print("PASS: Index generation test")
PY

# 恢复文件
mv skills-index.json.bak skills-index.json
```

- [ ] **Step 2: 验证测试失败**

```bash
bash tests/test-generate-index.sh
# 预期：FAIL - scripts/generate-index.sh 不存在
```

- [ ] **Step 3: 写最小实现**

```bash
# scripts/generate-index.sh
#!/usr/bin/env bash
set -e

echo "Generating skills-index.json..."

# 使用 Python 生成索引
python3 <<'PYTHON'
import json
from pathlib import Path
from collections import defaultdict

# 扫描所有技能
skills = []
for skill_dir in sorted(Path("skills").glob("*/SKILL.md")):
    skill_name = skill_dir.parent.name
    skills.append(skill_name)

# 解析技能名称（phase-role-skill）
by_phase = defaultdict(lambda: {"skills": [], "description": ""})
for skill in skills:
    parts = skill.split("-", 1)
    if len(parts) >= 2:
        phase = parts[0]
        by_phase[phase]["skills"].append(skill)

# 设置阶段描述
descriptions = {
    "define": "想法模糊、需要方案对比、收敛到规格",
    "design": "证据驱动的创作设计定稿：交互、视觉、排版、剧本、导演",
    "build": "计划、增量实现、TDD、上下文、源文档、工程模式和内容构建",
    "verify": "规格符合性、代码质量、调试、安全、性能、内容、视觉和审查反馈",
    "ship": "发布、CI/CD、部署、导出、金丝雀、落地和文档同步",
    "maintain": "可观测性、迁移、上下文、学习、目标和使用引导",
    "reflect": "回顾与知识沉淀"
}

for phase, data in by_phase.items():
    data["description"] = descriptions.get(phase, "")
    data["skills"] = sorted(data["skills"])

# 构建 skill_descriptions
skill_descriptions = {}
for skill in skills:
    # 这里可以后续添加从 SKILL.md 读取描述的逻辑
    skill_descriptions[skill] = ""

# 生成索引
index = {
    "by_phase": dict(by_phase),
    "skill_descriptions": skill_descriptions
}

# 写入文件
with open("skills-index.json", "w") as f:
    json.dump(index, f, indent=2, ensure_ascii=False)

print(f"Generated index with {len(skills)} skills")
PYTHON

echo "Index generated successfully"
```

- [ ] **Step 4: 验证测试通过**

```bash
bash tests/test-generate-index.sh
# 预期：PASS
```

- [ ] **Step 5: Commit**

```bash
git add scripts/generate-index.sh scripts/tests/test-generate-index.sh
git commit -m "feat: add skills index generation script with tests"
```

---

### plans/03-historical-docs.md

**Subplan Contract:**
- **Owner:** content-writer
- **Status:** parallel_safe
- **Depends On:** none
- **Write Scope:** `docs/features/*/README.md`, `docs/architecture/command-agent-skill-architecture.md`
- **Read Scope:** `docs/features/README.md`
- **Verification Evidence:** 所有历史文档都有明确的标记
- **Merge Checkpoint:** 5 个历史文档都有清晰的历史/过期标记

#### Task 3.1: 标记 Minecraft City 示例为历史文档

**Files:**
- Modify: `docs/features/20260426-minecraft-city/README.md`

**依赖:** Task 0

- [ ] **Step 1: 明确验收标准**
README.md 顶部有清晰的"历史样例"标记，说明这不是活跃项目

- [ ] **Step 2: 添加历史标记**

```markdown
# Minecraft City - 历史样例

> **⚠️ 历史文档**
>
> 这是 Unified Skills v2.8.0 时期的功能示例，保留作为格式参考。
>
> **状态:** 非活跃项目，仅供格式参考
> **最后更新:** 2026-04-26
> **适用版本:** v2.8.x

## 文档说明

本目录展示 Unified Skills 标准产物链格式的创造模式项目。
只包含 `spec` 和 `plan`，不是完整产物链。
```

- [ ] **Step 3: 验证标记清晰**
```bash
head -20 docs/features/20260426-minecraft-city/README.md | grep -E "历史|历史文档|非活跃"
```

- [ ] **Step 4: 记录完成**
```bash
git add docs/features/20260426-minecraft-city/README.md
git commit -m "docs: mark minecraft-city as historical sample"
```

#### Task 3.2: 标记 Codex Hooks Commands 为历史文档

**Files:**
- Modify: `docs/features/20260427-codex-hooks-commands/README.md`

**依赖:** Task 0

- [ ] **Step 1: 明确验收标准**
README.md 顶部有清晰的"已实现"标记，说明功能已在 v2.13.3 实现

- [ ] **Step 2:添加完成标记**

```markdown
# Codex Hooks Commands - 已完成

> **✅ 已实现**
>
> 本项目已在 **v2.13.3** 完成，参见 CHANGELOG.md。
>
> **状态:** 功能已发布
> **实现版本:** v2.13.3
> **发布日期:** 2026-05-09

## 项目说明

本项目实现 Codex CLI 的 hooks 支持，已在 v2.13.3 发布。
相关配置和使用方法请参考：
- README.md - Codex setup 章节
- .codex/config.toml - hooks 配置示例
- .codex/hooks.json - hooks 定义
```

- [ ] **Step 3: 验证标记清晰**
```bash
head -20 docs/features/20260427-codex-hooks-commands/README.md | grep -E "已实现|已完成|v2.13.3"
```

- [ ] **Step 4: 记录完成**
```bash
git add docs/features/20260427-codex-hooks-commands/README.md
git commit -m "docs: mark codex-hooks-commands as implemented in v2.13.3"
```

#### Task 3.3: 标记 Iron Law Injection 为历史文档

**Files:**
- Modify: `docs/features/20260427-iron-law-injection/README.md`

**依赖:** Task 0

- [ ] **Step 1: 明确验收标准**
README.md 顶部有清晰的"历史设计"标记

- [ ] **Step 2: 添加历史标记**

```markdown
# Iron Law Injection - 历史设计

> **📜 历史设计**
>
> 这是 Unified Skills 早期关于 Iron Law 注入的设计讨论。
>
> **状态:** 历史设计文档
> **讨论日期:** 2026-04-27
> **当前状态:** Iron Law 已在多个技能中实现

## 设计说明

本文档记录了 Iron Law 注入机制的早期设计思路。
当前实现请参考各强纪律技能的 Iron Law 章节。
```

- [ ] **Step 3: 验证标记清晰**
```bash
head -20 docs/features/20260427-iron-law-injection/README.md | grep -E "历史设计|历史"
```

- [ ] **Step 4: 记录完成**
```bash
git add docs/features/20260427-iron-law-injection/README.md
git commit -m "docs: mark iron-law-injection as historical design"
```

#### Task 3.4: 完善特性文档索引

**Files:**
- Modify: `docs/features/README.md`

**依赖:** Task 3.1, Task 3.2, Task 3.3

- [ ] **Step 1: 明确验收标准**
README.md 清晰区分活跃文档和历史文档

- [ ] **Step 2: 更新文档分类**

在"当前目录说明"章节补充：

```markdown
### 历史样例目录（非活跃项目）

以下目录保留作为格式和演进痕迹，**不是"进行中"的项目**：

- `20260426-minecraft-city/`：Minecraft 项目示例（非 Unified 功能）
  - **状态:** 历史样例，v2.8.0 时期的功能示例
  - **用途:** 展示标准产物链格式的创造模式项目

- `20260427-codex-hooks-commands/`：Codex Hooks 支持（✅ 已完成）
  - **状态:** 已在 v2.13.3 实现
  - **参见:** CHANGELOG.md v2.13.3

- `20260427-iron-law-injection/`：Iron Law 注入设计（📜 历史设计）
  - **状态:** 历史设计文档
  - **当前:** Iron Law 已在多个技能中实现
```

- [ ] **Step 3: 验证分类清晰**
```bash
grep -A 20 "历史样例目录" docs/features/README.md | grep -E "minecraft-city|codex-hooks|iron-law"
```

- [ ] **Step 4: 记录完成**
```bash
git add docs/features/README.md
git commit -m "docs: improve features index with clear historical markers"
```

---

### plans/04-validate-integration.md

**Subplan Contract:**
- **Owner:** software-engineer
- **Status:** serial
- **Depends On:** 01, 02, 03
- **Write Scope:** `validate`
- **Read Scope:** `scripts/sync-version.sh`, `scripts/generate-index.sh`
- **Verification Evidence:** `./validate` 通过，包含新的自动化检查
- **Merge Checkpoint:** 验证脚本集成新检查且所有测试通过

#### Task 4.1: 集成版本同步检查

**Files:**
- Modify: `validate`

**依赖:** Task 1.1

- [ ] **Step 1: 写失败测试**

```bash
# 测试验证脚本能检测版本不一致
# 手动修改 .claude-plugin/plugin.json 版本号为 2.14.0
# 运行 ./validate
# 预期：FAIL - 版本号不一致
```

- [ ] **Step 2: 添加版本同步检查**

在 validate 脚本的版本号检查章节后添加：

```bash
printf '\n== 检查自动化脚本 ==\n'

# 检查版本同步脚本是否存在且可执行
if [ ! -f "scripts/sync-version.sh" ]; then
  fail "缺少版本同步脚本: scripts/sync-version.sh"
else
  [ -x "scripts/sync-version.sh" ] || fail "版本同步脚本不可执行"
fi

# 检查索引生成脚本是否存在且可执行
if [ ! -f "scripts/generate-index.sh" ]; then
  fail "缺少索引生成脚本: scripts/generate-index.sh"
else
  [ -x "scripts/generate-index.sh" ] || fail "索引生成脚本不可执行"
fi

# 检查测试目录
if [ ! -d "scripts/tests" ]; then
  fail "缺少脚本测试目录: scripts/tests"
fi

[ "$status" -eq 0 ] && printf '通过\n'
```

- [ ] **Step 3: 验证检查生效**

```bash
./validate
# 预期：PASS - 所有脚本存在且可执行
```

- [ ] **Step 4: 记录完成**
```bash
git add validate
git commit -m "feat: integrate automation script checks in validate"
```

---

### plans/05-doc-update.md

**Subplan Contract:**
- **Owner:** content-writer
- **Status:** serial
- **Depends On:** 04
- **Write Scope:** `README.md`, `AGENTS.md`, `CHANGELOG.md`
- **Read Scope:** `scripts/sync-version.sh`, `scripts/generate-index.sh`
- **Verification Evidence:** 文档说明清晰，新用户能找到自动化工具
- **Merge Checkpoint:** 所有文档已更新，说明新的自动化工具

#### Task 5.1: 更新 README.md

**Files:**
- Modify: `README.md`

**依赖:** Task 4.1

- [ ] **Step 1: 明确验收标准**
README.md 包含自动化工具的使用说明

- [ ] **Step 2: 添加自动化工具章节**

在"扩展与贡献"章节后添加：

```markdown
## 自动化工具

Unified 提供以下自动化工具减少手动同步负担：

### 版本同步

发版时使用版本同步脚本自动更新所有版本号：

```bash
# 1. 更新 package.json 版本号
# 2. 运行同步脚本
bash scripts/sync-version.sh

# 3. 验证同步成功
./validate
```

### 索引生成

修改技能后重新生成索引：

```bash
# 生成 skills-index.json
bash scripts/generate-index.sh

# 验证生成成功
./validate
```

### 测试

所有自动化脚本都有对应的测试：

```bash
# 测试版本同步
bash scripts/tests/test-sync-version.sh

# 测试索引生成
bash scripts/tests/test-generate-index.sh
```
```

- [ ] **Step 3: 验证文档清晰**
```bash
grep -A 30 "自动化工具" README.md | grep -E "版本同步|索引生成|测试"
```

- [ ] **Step 4: 记录完成**
```bash
git add README.md
git commit -m "docs: add automation tools section to README"
```

#### Task 5.2: 更新 AGENTS.md

**Files:**
- Modify: `AGENTS.md`

**依赖:** Task 4.1

- [ ] **Step 1: 明确验收标准**
AGENTS.md 的"开发注意事项"章节引用自动化工具

- [ ] **Step 2: 更新注意事项章节**

在"近期复盘：合同漂移修复后的硬经验"章节添加：

```markdown
### 自动化工具使用

为避免合同漂移，新增或修改技能后必须：

1. **版本同步** - 发版时运行 `bash scripts/sync-version.sh`
2. **索引更新** - 修改技能后运行 `bash scripts/generate-index.sh`
3. **验证通过** - 运行 `./validate` 确保无漂移

这些工具可以防止 80% 的常见合同漂移问题。
```

- [ ] **Step 3: 验证引用正确**
```bash
grep -A 10 "自动化工具使用" AGENTS.md | grep -E "sync-version|generate-index"
```

- [ ] **Step 4: 记录完成**
```bash
git add AGENTS.md
git commit -m "docs: add automation tools usage to AGENTS"
```

#### Task 5.3: 更新 CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

**依赖:** Task 4.1

- [ ] **Step 1: 明确验收标准**
CHANGELOG.md 记录所有变更

- [ ] **Step 2: 添加 v2.15.0 条目**

```markdown
## [2.15.0] - 2026-05-10

### Added
- automation: 添加版本同步脚本 `scripts/sync-version.sh`
- automation: 添加索引生成脚本 `scripts/generate-index.sh`
- testing: 为所有自动化脚本添加测试

### Changed
- docs: 为所有历史特性文档添加清晰的标记
- docs: 完善特性文档索引，区分活跃和历史项目
- docs: 在 README.md 和 AGENTS.md 中添加自动化工具说明

### Fixed
- technical debt: 自动化版本同步，减少人为错误
- technical debt: 自动化索引生成，防止 skills-index.json 漂移
- technical debt: 完善历史文档标记，改善新用户体验
```

- [ ] **Step 3: 验证格式正确**
```bash
head -30 CHANGELOG.md | grep -E "2.15.0|automation|technical debt"
```

- [ ] **Step 4: 记录完成**
```bash
git add CHANGELOG.md
git commit -m "docs: add v2.15.0 changelog entry"
```

---

## 验收标准总结

### P0 问题（必须解决）

- [ ] 版本同步脚本能正确更新所有 3 个插件元数据文件
- [ ] skills-index.json 生成脚本能正确提取所有技能信息
- [ ] 所有历史文档都有明确的"历史 / 已过期"标记
- [ ] validate 脚本集成新的自动化检查

### 质量保障

- [ ] 所有脚本都有对应的测试
- [ ] 测试覆盖正常流程和错误情况
- [ ] 文档已更新，说明新的自动化工具使用方法
- [ ] `./validate` 通过

### 文档完整性

- [ ] 5 个历史特性文档都有清晰标记
- [ ] README.md 包含自动化工具章节
- [ ] AGENTS.md 引用自动化工具
- [ ] CHANGELOG.md 记录所有变更

---

## 风险与缓解

### 风险 1：自动化脚本错误

**风险等级:** 中
**影响:** 可能导致错误的版本号或索引
**缓解措施:**
- 完善的测试覆盖
- 人工验证步骤
- 保留现有手动检查作为备份

### 风险 2：文档标记混淆

**风险等级:** 低
**影响:** 可能误标记活跃文档为历史
**缓解措施:**
- 人工审核所有标记
- 在 PR review 中重点检查

### 风险 3：验证脚本破坏

**风险等级:** 低
**影响:** 可能破坏现有验证
**缓解措施:**
- 只添加新检查，不修改现有检查
- 在集成前运行完整验证

---

## 时间估算

- **Task 0:** 5 分钟
- **Subplan 01 (版本同步):** 30 分钟
- **Subplan 02 (索引生成):** 45 分钟
- **Subplan 03 (历史文档):** 30 分钟
- **Subplan 04 (验证集成):** 20 分钟
- **Subplan 05 (文档更新):** 30 分钟

**总计:** 约 2.5-3 小时

---

## 下一步

批准本计划后，使用 `/build` 开始实施。

实施顺序：
1. 先并行完成 Task 1.1, 2.1, 3.1-3.4
2. 再完成 Task 4.1（集成）
3. 最后完成 Task 5.1-5.3（文档更新）
