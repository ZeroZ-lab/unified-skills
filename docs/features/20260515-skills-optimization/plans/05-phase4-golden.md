# Phase 4: 黄金标准提取 + 全量验证

## Subplan Contract
- **Owner:** main agent
- **Status:** serial
- **Depends On:** `plans/04-phase3-tier3.md`
- **Write Scope:** `docs/features/20260515-skills-optimization/`（评分 + 黄金标准文档）
- **Read Scope:** 所有 55 个已优化 SKILL.md + 辅助文件
- **Parallel Safety:** no（收尾 phase）
- **Verification Evidence:** 全量评分表 + 黄金标准文档 + `./validate` 通过
- **Merge Checkpoint:** 55 个技能五轴全 ≥3/3 + validate 通过 + 黄金标准文档完成

## Tasks

### Task 4.1: 全量终评 + 评分表产出

**Files:**
- Create: `docs/features/20260515-skills-optimization/scoring/final-scores.md`

**依赖:** Phase 3 完成

- [ ] 对所有 55 个 SKILL.md + 13 个辅助文件重新五轴评分
- [ ] 确认全部 ≥3/3
- [ ] 如有未达标的，回到对应 phase 修复
- [ ] 产出终评表，包含每轴评分和优化前后对比

**验收标准:** 55 个技能全部五轴 ≥3/3，评分表无遗漏

---

### Task 4.2: 提取黄金标准

**Files:**
- Create: `docs/features/20260515-skills-optimization/golden-standard.md`

**依赖:** Task 4.1

- [ ] 从全部 3/3 技能中提取共性结构模式
- [ ] 按轴总结每个 3/3 的具体表现特征
- [ ] 产出黄金标准文档，包含:
  - 可操作性 3/3 的特征模式
  - 示例充足性 3/3 的特征模式
  - 行为收敛性 3/3 的特征模式
  - 跨技能衔接 3/3 的特征模式
  - 说辞表质量 3/3 的特征模式
  - 辅助文件与主文件同步标准
- [ ] 标注哪些模式可结构化检查（为未来 validate 扩展准备）

**验收标准:** 黄金标准文档覆盖五轴，每个轴有 ≥3 个具体特征示例

---

### Task 4.3: 最终验证 + 文档聚合

**Files:**
- Create: `docs/features/20260515-skills-optimization/README.md`

**依赖:** Task 4.2

- [ ] 运行完整验证链: `bash scripts/generate-index.sh && ./validate`
- [ ] 产出项目 README 聚合:
  - 时间线（Phase 0 → 1 → 2 → 3 → 4）
  - 变更统计（修改的文件数 + 行数变化）
  - 评分改善前后对比
  - 黄金标准引用
- [ ] Human partner 最终批准

**验收标准:** validate 通过 + README 聚合完成 + human partner 批准

---

## Phase 4 Checkpoint

- [ ] 55 个技能终评全部五轴 ≥3/3
- [ ] 黄金标准文档已提取
- [ ] `./validate` 通过
- [ ] `skills-lock.json` 哈希同步
- [ ] README 聚合完成
- [ ] Human partner 最终批准
