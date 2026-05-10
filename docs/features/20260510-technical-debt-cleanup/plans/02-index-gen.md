# Subplan 02: 索引生成自动化

## Subplan Contract

- **Owner:** software-engineer
- **Status:** parallel_safe
- **Depends On:** none
- **Write Scope:** `scripts/generate-index.sh`, `scripts/tests/test-generate-index.sh`
- **Read Scope:** `skills/*/SKILL.md`, `skills-index.json`
- **Verification Evidence:** 生成的索引与现有索引一致
- **Merge Checkpoint:** 索引生成脚本能正确生成 skills-index.json

## 任务列表

### Task 2.1: 创建索引生成脚本

**Files:**
- Create: `scripts/generate-index.sh`
- Create: `scripts/tests/test-generate-index.sh`

**依赖:** Task 0（项目初始化）

**复杂度:** 中

**步骤:**

1. 写失败测试
2. 验证测试失败
3. 写最小实现
4. 验证测试通过
5. Commit

**验收标准:**
- [ ] 脚本能扫描所有 skills/*/SKILL.md
- [ ] 脚本能正确解析技能名称（phase-role-skill）
- [ ] 脚本能生成符合 schema 的 skills-index.json
- [ ] 测试覆盖正常流程
- [ ] 测试覆盖错误情况（无效技能名、缺失 SKILL.md）

**技术要点:**
- 遍历 skills/*/SKILL.md 提取技能列表
- 解析技能名称获取 phase 信息
- 按 phase 分组
- 生成 JSON 输出
- 保持与现有 skills-index.json 兼容

**测试策略:**
- 正常流程：运行脚本，验证生成的 JSON 有效
- 一致性：对比生成的索引与现有索引
- 错误情况：添加无效技能目录，验证脚本正确处理

---

## 实现细节

### generate-index.sh 草稿

```bash
#!/usr/bin/env bash
set -e

# 显示帮助信息
show_help() {
  echo "Usage: generate-index.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run    预览模式，不实际写入文件"
  echo "  --verbose    显示详细信息"
  echo "  --help       显示此帮助信息"
  echo ""
  echo "此脚本扫描 skills/ 目录并生成 skills-index.json"
}

DRY_RUN=false
VERBOSE=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# 检查 skills/ 目录是否存在
if [ ! -d "skills" ]; then
  echo "Error: skills/ directory not found"
  exit 1
fi

echo "Scanning skills/ directory..."

# 使用 Python 生成索引
python3 <<'PYTHON'
import json
import re
from pathlib import Path
from collections import defaultdict

# 扫描所有技能
skills = []
for skill_path in sorted(Path("skills").glob("*/SKILL.md")):
    skill_name = skill_path.parent.name

    # 验证技能名称格式
    if not re.match(r'^(define|design|build|verify|ship|maintain|reflect)-', skill_name):
        print(f"Warning: Skipping invalid skill name: {skill_name}")
        continue

    skills.append(skill_name)

if not skills:
    print("Error: No skills found")
    exit(1)

# 按 phase 分组
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

# 设置阶段顺序
phase_order = ["define", "design", "build", "verify", "ship", "maintain", "reflect"]

# 构建 by_phase
for phase in phase_order:
    if phase in by_phase:
        by_phase[phase]["skills"] = sorted(by_phase[phase]["skills"])
        by_phase[phase]["description"] = descriptions.get(phase, "")

# 构建 skill_descriptions
skill_descriptions = {}
for skill in skills:
    # 读取 SKILL.md 获取描述
    skill_file = Path("skills") / skill / "SKILL.md"
    if skill_file.exists():
        try:
            with open(skill_file, 'r', encoding='utf-8') as f:
                content = f.read()
                # 提取 description frontmatter
                match = re.search(r'description:\s*(.+)', content)
                if match:
                    skill_descriptions[skill] = match.group(1).strip()
                else:
                    skill_descriptions[skill] = ""
        except Exception as e:
            print(f"Warning: Failed to read {skill_file}: {e}")
            skill_descriptions[skill] = ""
    else:
        skill_descriptions[skill] = ""

# 生成索引
index = {
    "by_phase": {},
    "skill_descriptions": skill_descriptions
}

# 按 phase_order 添加 by_phase
for phase in phase_order:
    if phase in by_phase:
        index["by_phase"][phase] = by_phase[phase]

# 输出结果
output = json.dumps(index, indent=2, ensure_ascii=False)
print(output)

# 写入文件（非 dry-run 模式）
import os
if not os.environ.get("DRY_RUN"):
    with open("skills-index.json", "w", encoding='utf-8') as f:
        f.write(output)
    print(f"\nGenerated skills-index.json with {len(skills)} skills", file=__import__('sys').stderr)
else:
    print(f"\n[DRY-RUN] Would generate skills-index.json with {len(skills)} skills", file=__import__('sys').stderr)
PYTHON

echo "Index generation complete"
```

### test-generate-index.sh 草稿

```bash
#!/usr/bin/env bash
set -e

echo "Testing index generation..."

# 备份原文件
cp skills-index.json skills-index.json.bak

# 测试结束时恢复文件
trap "mv skills-index.json.bak skills-index.json" EXIT

# 测试 1: 正常生成
echo "Test 1: Normal generation"

bash scripts/generate-index.sh

# 验证生成的 JSON 有效
python3 -c "import json; json.load(open('skills-index.json'))" || {
  echo "FAIL: Invalid JSON"
  exit 1
}

echo "PASS: Valid JSON generated"

# 测试 2: 技能完整性
echo "Test 2: Skill completeness"

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

print(f"PASS: All {len(root_skills)} skills indexed correctly")
PY

# 测试 3: Schema 验证
echo "Test 3: Schema validation"

python3 <<'PY'
import json

index = json.load(open("skills-index.json"))

# 验证顶级键
required_keys = ["by_phase", "skill_descriptions"]
for key in required_keys:
    if key not in index:
        print(f"FAIL: Missing required key: {key}")
        exit(1)

# 验证 by_phase 结构
by_phase = index["by_phase"]
expected_phases = ["define", "design", "build", "verify", "ship", "maintain", "reflect"]
for phase in expected_phases:
    if phase not in by_phase:
        print(f"FAIL: Missing phase: {phase}")
        exit(1)

    phase_data = by_phase[phase]
    if "skills" not in phase_data:
        print(f"FAIL: Missing skills in phase: {phase}")
        exit(1)

    if "description" not in phase_data:
        print(f"FAIL: Missing description in phase: {phase}")
        exit(1)

    if not isinstance(phase_data["skills"], list):
        print(f"FAIL: skills should be a list in phase: {phase}")
        exit(1)

# 验证 skill_descriptions
skill_descriptions = index["skill_descriptions"]
if not isinstance(skill_descriptions, dict):
    print("FAIL: skill_descriptions should be a dict")
    exit(1)

print("PASS: Schema validation")
PY

# 测试 4: Dry-run 模式
echo "Test 4: Dry-run mode"

# 恢复备份
mv skills-index.json.bak skills-index.json
cp skills-index.json skills-index.json.bak

DRY_RUN=1 bash scripts/generate-index.sh --dry-run

# 验证文件未被修改
if ! diff -q skills-index.json skills-index.json.bak > /dev/null; then
  echo "FAIL: Dry-run modified file"
  exit 1
fi

echo "PASS: Dry-run test"

echo ""
echo "All tests passed!"
```

---

## 验证证据

### 自动验证

```bash
# 运行测试
bash scripts/tests/test-generate-index.sh

# 预期输出：
# Testing index generation...
# Test 1: Normal generation
# PASS: Valid JSON generated
# Test 2: Skill completeness
# PASS: All 53 skills indexed correctly
# Test 3: Schema validation
# PASS: Schema validation
# Test 4: Dry-run mode
# PASS: Dry-run test
#
# All tests passed!
```

### 手动验证

```bash
# 1. 运行生成脚本
bash scripts/generate-index.sh

# 2. 验证生成的索引
python3 -c "import json; import pprint; pprint.pprint(json.load(open('skills-index.json')))"

# 3. 对比现有索引
diff skills-index.json.bak skills-index.json
```

---

## 后续集成

此子计划完成后，将在 Subplan 04 中集成到 validate 脚本。
