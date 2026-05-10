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

bash scripts/generate-index.sh --dry-run > /dev/null

# 验证文件未被修改
if ! diff -q skills-index.json skills-index.json.bak > /dev/null; then
  echo "FAIL: Dry-run modified file"
  exit 1
fi

echo "PASS: Dry-run test"

echo ""
echo "All tests passed!"
