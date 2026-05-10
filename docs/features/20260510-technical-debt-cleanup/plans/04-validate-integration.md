# Subplan 04: 验证脚本集成

## Subplan Contract

- **Owner:** software-engineer
- **Status:** serial
- **Depends On:** 01, 02, 03
- **Write Scope:** `validate`
- **Read Scope:** `scripts/sync-version.sh`, `scripts/generate-index.sh`
- **Verification Evidence:** `./validate` 通过，包含新的自动化检查
- **Merge Checkpoint:** 验证脚本集成新检查且所有测试通过

## 任务列表

### Task 4.1: 集成版本同步检查

**Files:**
- Modify: `validate`

**依赖:** Task 1.1（版本同步脚本）

**复杂度:** 低

**验收标准:**
- [ ] validate 脚本检查版本同步脚本存在
- [ ] validate 脚本检查索引生成脚本存在
- [ ] validate 脚本检查测试目录存在
- [ ] 所有检查通过时显示"通过"

**集成位置:**

在 validate 脚本中，在"检查强纪律技能 Iron Law"章节之前添加：

```bash
printf '\n== 检查自动化脚本 ==\n'

# 检查版本同步脚本
if [ ! -f "scripts/sync-version.sh" ]; then
  fail "缺少版本同步脚本: scripts/sync-version.sh"
else
  [ -x "scripts/sync-version.sh" ] || fail "版本同步脚本不可执行: chmod +x scripts/sync-version.sh"
fi

# 检查索引生成脚本
if [ ! -f "scripts/generate-index.sh" ]; then
  fail "缺少索引生成脚本: scripts/generate-index.sh"
else
  [ -x "scripts/generate-index.sh" ] || fail "索引生成脚本不可执行: chmod +x scripts/generate-index.sh"
fi

# 检查测试目录
if [ ! -d "scripts/tests" ]; then
  fail "缺少脚本测试目录: scripts/tests"
fi

# 检查测试文件
if [ ! -f "scripts/tests/test-sync-version.sh" ]; then
  fail "缺少版本同步测试: scripts/tests/test-sync-version.sh"
fi

if [ ! -f "scripts/tests/test-generate-index.sh" ]; then
  fail "缺少索引生成测试: scripts/tests/test-generate-index.sh"
fi

[ "$status" -eq 0 ] && printf '通过\n'
```

---

### Task 4.2: 添加版本一致性自动检查

**Files:**
- Modify: `validate`

**依赖:** Task 1.1（版本同步脚本）

**复杂度:** 中

**验收标准:**
- [ ] validate 脚本自动运行版本同步检查
- [ ] 发现版本不一致时给出明确的错误提示
- [ ] 提供修复建议（运行 sync-version.sh）

**集成位置:**

在现有的"检查版本号"章节后添加：

```bash
printf '\n== 检查版本一致性 ==\n'

# 运行版本同步脚本（dry-run 模式）
if bash scripts/sync-version.sh --dry-run 2>/dev/null; then
  printf '版本一致性: 通过\n'
else
  fail '版本号不一致。运行 `bash scripts/sync-version.sh` 修复'
fi
```

---

### Task 4.3: 添加索引一致性自动检查

**Files:**
- Modify: `validate`

**依赖:** Task 2.1（索引生成脚本）

**复杂度:** 中

**验收标准:**
- [ ] validate 脚本自动运行索引生成检查
- [ ] 发现索引不一致时给出明确的错误提示
- [ ] 提供修复建议（运行 generate-index.sh）

**集成位置:**

在"检查 skills-index.json"章节后添加：

```bash
printf '\n== 检查索引一致性 ==\n'

# 临时生成索引用于对比
TEMP_INDEX=$(mktemp)
python3 <<'PY' > "$TEMP_INDEX"
import json
from pathlib import Path

# 扫描所有技能
skills = sorted(p.parent.name for p in Path("skills").glob("*/SKILL.md"))

# 按阶段分组
from collections import defaultdict
by_phase = defaultdict(lambda: {"skills": [], "description": ""})

for skill in skills:
    parts = skill.split("-", 1)
    if len(parts) >= 2:
        phase = parts[0]
        by_phase[phase]["skills"].append(skill)

# 生成临时索引
temp_index = {"by_phase": dict(by_phase)}
print(json.dumps(temp_index))
PY

# 对比现有索引
if ! python3 -c "
import json
temp = json.load(open('$TEMP_INDEX'))
current = json.load(open('skills-index.json'))

# 提取技能集合
temp_skills = set()
for phase_data in temp['by_phase'].values():
    temp_skills.update(phase_data.get('skills', []))

current_skills = set()
for phase_data in current['by_phase'].values():
    current_skills.update(phase_data.get('skills', []))

if temp_skills != current_skills:
    missing = sorted(temp_skills - current_skills)
    extra = sorted(current_skills - temp_skills)
    if missing:
        print(f'索引缺少技能: {\", \".join(missing)}')
    if extra:
        print(f'索引多余技能: {\", \".join(extra)}')
    exit(1)
"; then
  rm -f "$TEMP_INDEX"
  fail 'skills-index.json 与技能目录不一致。运行 `bash scripts/generate-index.sh` 修复'
fi

rm -f "$TEMP_INDEX"
printf '索引一致性: 通过\n'
```

---

## 验证证据

### 测试场景 1：正常情况

```bash
# 1. 确保所有脚本存在且可执行
chmod +x scripts/sync-version.sh scripts/generate-index.sh
chmod +x scripts/tests/test-sync-version.sh scripts/tests/test-generate-index.sh

# 2. 运行验证
./validate

# 预期：所有检查通过
```

### 测试场景 2：版本不一致

```bash
# 1. 手动修改某个插件版本号
vim .claude-plugin/plugin.json  # 修改为不同版本

# 2. 运行验证
./validate

# 预期：
# FAIL: 版本号不一致。运行 `bash scripts/sync-version.sh` 修复
```

### 测试场景 3：索引不一致

```bash
# 1. 添加一个新技能目录
mkdir -p skills/test-new-skill
echo "# Test" > skills/test-new-skill/SKILL.md

# 2. 运行验证
./validate

# 预期：
# FAIL: skills-index.json 与技能目录不一致。运行 `bash scripts/generate-index.sh` 修复

# 3. 清理
rm -rf skills/test-new-skill
```

---

## 错误提示设计

### 版本不一致

```
== 检查版本一致性 ==
package.json:         2.15.0
.claude-plugin:       2.14.0  ← 不一致
.codex-plugin:        2.15.0

FAIL: 版本号不一致
修复: bash scripts/sync-version.sh
```

### 索引不一致

```
== 检查索引一致性 ==
索引缺少技能: test-new-skill
索引多余技能: (无)

FAIL: skills-index.json 与技能目录不一致
修复: bash scripts/generate-index.sh
```

### 脚本缺失

```
== 检查自动化脚本 ==
FAIL: 缺少版本同步脚本: scripts/sync-version.sh

请确保以下文件存在且可执行：
  - scripts/sync-version.sh
  - scripts/generate-index.sh
  - scripts/tests/test-sync-version.sh
  - scripts/tests/test-generate-index.sh
```

---

## 集成检查清单

- [ ] 版本同步脚本检查
- [ ] 索引生成脚本检查
- [ ] 测试目录检查
- [ ] 版本一致性自动检查
- [ ] 索引一致性自动检查
- [ ] 所有错误提示清晰且可操作
- [ ] 修复建议准确有效

---

## 后续集成

此子计划完成后，将在 Subplan 05 中更新文档说明这些新的验证检查。
