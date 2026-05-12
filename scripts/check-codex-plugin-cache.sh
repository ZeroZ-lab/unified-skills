#!/usr/bin/env bash
set -u

status=0

fail() {
  printf 'FAIL: %s\n' "$1"
  status=1
}

repo_root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
codex_home="${CODEX_HOME:-$HOME/.codex}"

version=$(cd "$repo_root" && python3 -c 'import json; print(json.load(open("package.json"))["version"])' 2>/dev/null)
if [ -z "$version" ]; then
  fail "无法从 package.json 解析版本号"
  exit "$status"
fi

cache_root="${CODEX_UNIFIED_CACHE_DIR:-$codex_home/plugins/cache/unified-skills/unified/$version}"

printf 'Codex cache: %s\n' "$cache_root"

if [ ! -d "$cache_root" ]; then
  fail "缺少 Codex 插件 cache: $cache_root"
  exit "$status"
fi

repo_skill_count=$(find "$repo_root/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')
cache_skill_count=$(find "$cache_root/skills" -mindepth 2 -maxdepth 2 -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$repo_skill_count" != "$cache_skill_count" ]; then
  fail "技能数量不一致: repo=$repo_skill_count cache=$cache_skill_count"
fi

compare_file() {
  rel="$1"
  repo_file="$repo_root/$rel"
  cache_file="$cache_root/$rel"

  if [ ! -f "$cache_file" ]; then
    fail "cache 缺少文件: $cache_file"
    return
  fi

  if ! cmp -s "$repo_file" "$cache_file"; then
    fail "Codex cache stale: $rel differs from repo"
  fi
}

compare_file ".codex-plugin/plugin.json"
compare_file ".claude-plugin/marketplace.json"
compare_file "skills-index.json"
compare_file "skills/maintain-workflow-using-unified/SKILL.md"

python3 - "$cache_root" "$version" "$repo_skill_count" <<'PY' || fail "Codex cache 元数据仍含过期版本或技能数量"
import json
import sys
from pathlib import Path

cache_root = Path(sys.argv[1])
version = sys.argv[2]
skill_count = sys.argv[3]

checks = [
    (cache_root / ".codex-plugin/plugin.json", ("description",)),
    (cache_root / ".codex-plugin/plugin.json", ("interface", "shortDescription")),
    (cache_root / ".claude-plugin/marketplace.json", ("description",)),
    (cache_root / ".claude-plugin/marketplace.json", ("plugins", 0, "description")),
]

errors = []

def get(data, path):
    current = data
    for key in path:
        current = current[key]
    return current

for file_path, path in checks:
    try:
        value = get(json.loads(file_path.read_text(encoding="utf-8")), path)
    except Exception as exc:
        errors.append(f"{file_path} missing {'.'.join(map(str, path))}: {exc}")
        continue
    if f"{skill_count} 技能" not in value:
        errors.append(f"{file_path} {'.'.join(map(str, path))} missing {skill_count} 技能")
    if "53 技能" in value or "53 个技能" in value or "v2.14.0" in value:
        errors.append(f"{file_path} {'.'.join(map(str, path))} contains stale metadata")
    if path[-1] == "description" and not value.startswith(f"v{version}"):
        errors.append(f"{file_path} {'.'.join(map(str, path))} must start with v{version}")

if errors:
    raise SystemExit("\n".join(errors))
PY

if [ "$status" -eq 0 ]; then
  printf 'Codex cache matches repo metadata, skills-index, and loading guide.\n'
fi

exit "$status"
