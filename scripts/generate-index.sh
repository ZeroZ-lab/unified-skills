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

# 设置 dry-run 环境变量供 Python 使用
if [ "$DRY_RUN" = true ]; then
  export DRY_RUN=1
fi

# 使用 Python 生成索引
python3 <<'PYTHON'
import json
import re
from pathlib import Path
from collections import defaultdict
import os

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
if not os.environ.get("DRY_RUN"):
    with open("skills-index.json", "w", encoding='utf-8') as f:
        f.write(output)
    print(f"\nGenerated skills-index.json with {len(skills)} skills", file=__import__('sys').stderr)
else:
    print(f"\n[DRY-RUN] Would generate skills-index.json with {len(skills)} skills", file=__import__('sys').stderr)
PYTHON

echo "Index generation complete"
