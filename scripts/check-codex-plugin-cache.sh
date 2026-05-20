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

compare_source_file() {
  source_root="$1"
  rel="$2"
  repo_file="$repo_root/$rel"
  source_file="$source_root/$rel"

  if [ ! -f "$source_file" ]; then
    fail "marketplace source 缺少文件: $source_file"
    return
  fi

  if ! cmp -s "$repo_file" "$source_file"; then
    fail "Codex marketplace source stale: $rel differs from repo"
  fi
}

compare_file ".codex-plugin/plugin.json"
compare_file ".claude-plugin/marketplace.json"
compare_file "skills-index.json"
compare_file "skills-router.json"
while IFS= read -r repo_skill; do
  rel="${repo_skill#"$repo_root"/}"
  compare_file "$rel"
done < <(find "$repo_root/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | sort)

python3 "$repo_root/scripts/check-skill-frontmatter.py" "$cache_root" || fail "Codex cache SKILL.md frontmatter 无效"

marketplace_root="${CODEX_UNIFIED_MARKETPLACE_DIR:-$codex_home/.tmp/marketplaces/unified-skills}"
if [ -d "$marketplace_root" ]; then
  printf 'Codex marketplace source: %s\n' "$marketplace_root"
  compare_source_file "$marketplace_root" ".codex-plugin/plugin.json"
  compare_source_file "$marketplace_root" ".claude-plugin/marketplace.json"
  compare_source_file "$marketplace_root" "skills-index.json"
  compare_source_file "$marketplace_root" "skills-router.json"
  while IFS= read -r repo_skill; do
    rel="${repo_skill#"$repo_root"/}"
    compare_source_file "$marketplace_root" "$rel"
  done < <(find "$repo_root/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | sort)

  python3 "$repo_root/scripts/check-skill-frontmatter.py" "$marketplace_root" || fail "Codex marketplace source SKILL.md frontmatter 无效"
fi

python3 - "$cache_root" "$version" <<'PY' || fail "Codex cache 元数据仍含过期版本或动态数量"
import json
import re
import sys
from pathlib import Path

cache_root = Path(sys.argv[1])
version = sys.argv[2]

checks = [
    (cache_root / ".codex-plugin/plugin.json", ("description",)),
    (cache_root / ".codex-plugin/plugin.json", ("interface", "shortDescription")),
    (cache_root / ".claude-plugin/marketplace.json", ("description",)),
    (cache_root / ".claude-plugin/marketplace.json", ("plugins", 0, "description")),
]

errors = []
dynamic_count_re = re.compile(r"(^|[^0-9.])\d+\s*(?:个)?(?:技能|命令|角色|SKILL)")

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
    if dynamic_count_re.search(value):
        errors.append(f"{file_path} {'.'.join(map(str, path))} contains dynamic inventory count")
    if "v2.14.0" in value:
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
