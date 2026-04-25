#!/usr/bin/env python3
"""
语言强制性升级脚本
将被动、建议性语言转换为主动、指令性语言
"""

import re
import sys
from pathlib import Path

# 语言模式转换规则
PATTERNS = [
    # 被动 → 主动
    (r'建议(\w+)', r'必须\1'),
    (r'推荐(\w+)', r'\1'),
    (r'可以考虑', r'执行'),
    (r'应该(\w+)', r'\1'),
    (r'最好(\w+)', r'\1'),

    # 弱化词 → 强化词
    (r'尽量', r''),
    (r'尽可能', r''),
    (r'如果可能', r''),
    (r'考虑', r'执行'),

    # 条件句 → 指令句
    (r'可以(\w+)', r'\1'),
    (r'能够(\w+)', r'\1'),

    # 保留特定上下文的例外
    # 这些模式在特定上下文中是合理的，不转换
]

# 需要保留的上下文（不转换）
PRESERVE_CONTEXTS = [
    r'可以\w+也可以',  # "可以 A 也可以 B" 表示选项
    r'如果.*可以',      # 条件句中的"可以"
    r'建议.*或',        # "建议 A 或 B" 表示选项
]

def should_preserve(line: str) -> bool:
    """检查是否应该保留原文"""
    for pattern in PRESERVE_CONTEXTS:
        if re.search(pattern, line):
            return True
    return False

def upgrade_language(content: str) -> str:
    """升级语言强制性"""
    lines = content.split('\n')
    upgraded = []

    for line in lines:
        if should_preserve(line):
            upgraded.append(line)
            continue

        # 应用转换规则
        new_line = line
        for pattern, replacement in PATTERNS:
            new_line = re.sub(pattern, replacement, new_line)

        upgraded.append(new_line)

    return '\n'.join(upgraded)

def process_skill(skill_path: Path) -> bool:
    """处理单个技能文件"""
    try:
        content = skill_path.read_text(encoding='utf-8')
        upgraded = upgrade_language(content)

        if content != upgraded:
            skill_path.write_text(upgraded, encoding='utf-8')
            return True
        return False
    except Exception as e:
        print(f"Error processing {skill_path}: {e}", file=sys.stderr)
        return False

def main():
    skills_dir = Path('skills')
    if not skills_dir.exists():
        print("Error: skills/ directory not found", file=sys.stderr)
        sys.exit(1)

    skill_files = list(skills_dir.glob('*/SKILL.md'))
    print(f"Found {len(skill_files)} skills to process")

    upgraded_count = 0
    for skill_file in skill_files:
        if process_skill(skill_file):
            upgraded_count += 1
            print(f"✓ {skill_file.parent.name}")

    print(f"\nUpgraded {upgraded_count}/{len(skill_files)} skills")

if __name__ == '__main__':
    main()
