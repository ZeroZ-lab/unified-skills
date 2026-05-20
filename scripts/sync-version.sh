#!/usr/bin/env bash
set -e

# 显示帮助信息
show_help() {
  echo "Usage: sync-version.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run    预览模式，不实际修改文件"
  echo "  --help       显示此帮助信息"
  echo ""
  echo "此脚本从 package.json 读取版本号，并同步到："
  echo "  - .claude-plugin/plugin.json"
  echo "  - .codex-plugin/plugin.json"
  echo "  - .claude-plugin/marketplace.json"
  echo "  - skills-router.json"
}

DRY_RUN=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
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

# 检查 package.json 是否存在
if [ ! -f "package.json" ]; then
  echo "Error: package.json not found"
  exit 1
fi

# 从 package.json 读取版本号
VERSION=$(python3 -c "import json, sys; print(json.load(open('package.json'))['version'])" 2>/dev/null || true)

if [ -z "$VERSION" ]; then
  echo "Error: Failed to read version from package.json"
  exit 1
fi

echo "Syncing version to $VERSION..."

SKILL_COUNT=$(python3 -c "
import json
idx = json.load(open('skills-index.json'))
skills = set()
for phase in idx['by_phase'].values():
    skills.update(phase['skills'])
print(len(skills))
" 2>/dev/null || true)

if [ -z "$SKILL_COUNT" ]; then
  echo "Error: Failed to read skill count from skills-index.json"
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  echo "[DRY-RUN] Would update .claude-plugin/plugin.json"
  echo "[DRY-RUN] Would update .codex-plugin/plugin.json"
  echo "[DRY-RUN] Would update .claude-plugin/marketplace.json"
  echo "[DRY-RUN] Would regenerate skills-router.json"
  exit 0
fi

# 更新插件元数据
VERSION="$VERSION" SKILL_COUNT="$SKILL_COUNT" python3 <<'PY'
import json
import os
import re
from pathlib import Path

version = os.environ["VERSION"]
skill_count = os.environ["SKILL_COUNT"]

def sync_text(text):
    text = re.sub(r"v\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?", f"v{version}", text)
    text = re.sub(r"\d+\s*技能", f"{skill_count} 技能", text)
    return text

def update_json(path, updater):
    file = Path(path)
    if not file.exists():
        print(f"Warning: {path} not found, skipping")
        return
    try:
        data = json.loads(file.read_text(encoding="utf-8"))
        updater(data)
        file.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"Updated {path}")
    except Exception as exc:
        raise SystemExit(f"Error updating {path}: {exc}")

def update_plugin(data):
    data["version"] = version
    if isinstance(data.get("description"), str):
        data["description"] = sync_text(data["description"])
    interface = data.get("interface")
    if isinstance(interface, dict) and isinstance(interface.get("shortDescription"), str):
        interface["shortDescription"] = sync_text(interface["shortDescription"])

def update_marketplace(data):
    if isinstance(data.get("description"), str):
        data["description"] = sync_text(data["description"])
    for plugin in data.get("plugins", []):
        if isinstance(plugin, dict) and isinstance(plugin.get("description"), str):
            plugin["description"] = sync_text(plugin["description"])

update_json(".claude-plugin/plugin.json", update_plugin)
update_json(".codex-plugin/plugin.json", update_plugin)
update_json(".claude-plugin/marketplace.json", update_marketplace)
PY

if [ -f "scripts/generate-router.sh" ]; then
  bash scripts/generate-router.sh
else
  echo "Warning: scripts/generate-router.sh not found, skipping skills-router.json"
fi

echo "Version synced to $VERSION"
