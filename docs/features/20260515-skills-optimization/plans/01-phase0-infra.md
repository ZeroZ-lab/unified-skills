# Phase 0: 基础设施 + 全量评分

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** none
- **Write Scope:** `scripts/update-lock.sh`, `docs/features/20260515-skills-optimization/scoring/`
- **Read Scope:** `docs/features/20260515-skills-optimization/01-spec.md`, `skills/*/SKILL.md`
- **Parallel Safety:** no（独立 phase）
- **Verification Evidence:** 脚本功能测试 + 评分表覆盖 55+13 文件 + heatmap.md 生成
- **Merge Checkpoint:** `./validate` 通过 + 评分表完整

## Tasks

### Task 0.1: 创建哈希同步脚本

（已在 03-plan.md 中完整展开）

**Files:**
- Create: `scripts/update-lock.sh`

**验收标准:**
- 脚本可执行
- 对有辅助文件的技能（build-quality-tdd）和没有辅助文件的技能都能正确更新 skills-lock.json
- 更新后 `./validate` 通过

---

### Task 0.2: 五轴评分全量技能

（已在 03-plan.md 中完整展开）

**Files:**
- Create: `docs/features/20260515-skills-optimization/scoring/heatmap.md`
- Create: `docs/features/20260515-skills-optimization/scoring/scores.md`

**验收标准:**
- scores.md 覆盖全部 55 个 SKILL.md + 13 个辅助文件
- 每个技能五轴评分（0-3），有缺口描述
- heatmap.md 按 Tier 分组，标注优化优先级
