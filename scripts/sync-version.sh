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

if [ "$DRY_RUN" = true ]; then
  echo "[DRY-RUN] Would update .claude-plugin/plugin.json"
  echo "[DRY-RUN] Would update .codex-plugin/plugin.json"
  exit 0
fi

# 更新 .claude-plugin/plugin.json
if [ -f ".claude-plugin/plugin.json" ]; then
  python3 -c "
import json
try:
    with open('.claude-plugin/plugin.json', 'r') as f:
        data = json.load(f)
    data['version'] = '$VERSION'
    with open('.claude-plugin/plugin.json', 'w') as f:
        json.dump(data, f, indent=2)
    print('Updated .claude-plugin/plugin.json')
except Exception as e:
    print(f'Error updating .claude-plugin/plugin.json: {e}')
    exit(1)
"
else
  echo "Warning: .claude-plugin/plugin.json not found, skipping"
fi

# 更新 .codex-plugin/plugin.json
if [ -f ".codex-plugin/plugin.json" ]; then
  python3 -c "
import json
try:
    with open('.codex-plugin/plugin.json', 'r') as f:
        data = json.load(f)
    data['version'] = '$VERSION'
    with open('.codex-plugin/plugin.json', 'w') as f:
        json.dump(data, f, indent=2)
    print('Updated .codex-plugin/plugin.json')
except Exception as e:
    print(f'Error updating .codex-plugin/plugin.json: {e}')
    exit(1)
"
else
  echo "Warning: .codex-plugin/plugin.json not found, skipping"
fi

echo "Version synced to $VERSION"
