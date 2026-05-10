# Subplan 01: 版本同步自动化

## Subplan Contract

- **Owner:** software-engineer
- **Status:** parallel_safe
- **Depends On:** none
- **Write Scope:** `scripts/sync-version.sh`, `scripts/tests/test-sync-version.sh`
- **Read Scope:** `package.json`, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`
- **Verification Evidence:** 测试通过 + 手动验证 3 个文件版本号一致
- **Merge Checkpoint:** 版本同步脚本能正确更新所有文件且测试通过

## 任务列表

### Task 1.1: 创建版本同步脚本

**Files:**
- Create: `scripts/sync-version.sh`
- Create: `scripts/tests/test-sync-version.sh`

**依赖:** Task 0（项目初始化）

**复杂度:** 低

**步骤:**

1. 写失败测试
2. 验证测试失败
3. 写最小实现
4. 验证测试通过
5. Commit

**验收标准:**
- [ ] 脚本能从 package.json 读取版本号
- [ ] 脚本能更新 .claude-plugin/plugin.json
- [ ] 脚本能更新 .codex-plugin/plugin.json
- [ ] 测试覆盖正常流程
- [ ] 测试覆盖错误情况（文件不存在、无效 JSON）

**技术要点:**
- 使用 python3 读取和写入 JSON（项目已有依赖）
- 添加错误处理（文件不存在、JSON 格式错误）
- 添加 --dry-run 模式用于预览

**测试策略:**
- 正常流程：修改 package.json 版本，运行脚本，验证其他文件同步
- 错误情况：删除某个文件，验证脚本正确报错
- 边界情况：空版本号、无效版本号格式

---

## 实现细节

### sync-version.sh 草稿

```bash
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
```

### test-sync-version.sh 草稿

```bash
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
```

---

## 验证证据

### 自动验证

```bash
# 运行测试
bash scripts/tests/test-sync-version.sh

# 预期输出：
# Testing version sync...
# Test 1: Normal sync
# PASS: Version sync test 1
# Test 2: Dry-run mode
# PASS: Dry-run test
# Test 3: Error handling
# PASS: Error handling test
#
# All tests passed!
```

### 手动验证

```bash
# 1. 修改 package.json 版本
vim package.json  # 改为 2.15.0

# 2. 运行同步脚本
bash scripts/sync-version.sh

# 3. 验证所有文件版本一致
grep '"version"' package.json .claude-plugin/plugin.json .codex-plugin/plugin.json

# 预期：所有文件显示 "version": "2.15.0"
```

---

## 后续集成

此子计划完成后，将在 Subplan 04 中集成到 validate 脚本。
