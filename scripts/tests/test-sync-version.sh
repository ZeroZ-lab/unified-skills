#!/usr/bin/env bash
set -e

echo "Testing version sync..."

# 设置测试版本
TEST_VERSION="2.15.0-test"

# 备份原文件
backup_files() {
  cp package.json package.json.bak 2>/dev/null || true
  cp .claude-plugin/plugin.json .claude-plugin/plugin.json.bak 2>/dev/null || true
  cp .codex-plugin/plugin.json .codex-plugin/plugin.json.bak 2>/dev/null || true
}

restore_files() {
  mv package.json.bak package.json 2>/dev/null || true
  mv .claude-plugin/plugin.json.bak .claude-plugin/plugin.json 2>/dev/null || true
  mv .codex-plugin/plugin.json.bak .codex-plugin/plugin.json 2>/dev/null || true
}

# 测试结束时恢复文件
trap restore_files EXIT

backup_files

# 测试 1: 正常同步
echo "Test 1: Normal sync"
python3 -c "import json; d=json.load(open('package.json')); d['version']='$TEST_VERSION'; json.dump(d, open('package.json', 'w'), indent=2)"

bash scripts/sync-version.sh

pkg_ver=$(python3 -c "import json; print(json.load(open('package.json'))['version'])")
claude_ver=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
codex_ver=$(python3 -c "import json; print(json.load(open('.codex-plugin/plugin.json'))['version'])")

if [ "$pkg_ver" != "$TEST_VERSION" ] || [ "$claude_ver" != "$TEST_VERSION" ] || [ "$codex_ver" != "$TEST_VERSION" ]; then
  echo "FAIL: Version mismatch"
  echo "  package.json: $pkg_ver (expected $TEST_VERSION)"
  echo "  .claude-plugin: $claude_ver (expected $TEST_VERSION)"
  echo "  .codex-plugin: $codex_ver (expected $TEST_VERSION)"
  exit 1
fi

echo "PASS: Version sync test 1"

# 测试 2: Dry-run 模式
echo "Test 2: Dry-run mode"
python3 -c "import json; d=json.load(open('package.json')); d['version']='2.16.0'; json.dump(d, open('package.json', 'w'), indent=2)"

bash scripts/sync-version.sh --dry-run

# 验证文件未被修改
claude_ver=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
if [ "$claude_ver" != "$TEST_VERSION" ]; then
  echo "FAIL: Dry-run modified files"
  exit 1
fi

echo "PASS: Dry-run test"

# 测试 3: 错误处理
echo "Test 3: Error handling"
if [ -f "package.json" ]; then
  mv package.json package.json.hidden
fi

if bash scripts/sync-version.sh 2>/dev/null; then
  echo "FAIL: Should fail when package.json missing"
  exit 1
fi

mv package.json.hidden package.json

echo "PASS: Error handling test"

echo ""
echo "All tests passed!"
