# Unified Skills — 目录架构设计

> 版本: 2.0
> 目标: 按阶段组织的技能套件，phase-role-skill 三级命名，按需加载

---

## 一、架构总览

```
unified/                          ← 根目录
│
├── CANON.md                      ← 宪法（单文件，根目录）
├── CLAUDE.md                     ← 入口配置
├── README.md                     ← 总览
│
├── skills/                       ← 技能目录（所有技能在此）
│   ├── define-workflow-refine/
│   ├── define-workflow-spec/
│   ├── define-cognitive-brainstorm/
│   ├── build-workflow-plan/
│   ├── build-workflow-execute/
│   │   ...
│   └── reflect-team-documentation/
│
├── commands/                     ← 斜杠命令入口
├── agents/                       ← 并行审查角色
├── templates/                    ← 文档模板
│   ├── feature/
│   └── bug/
├── references/                   ← 编排模式参考文档
│
└── docs/                         ← 项目文档
    ├── design-document.md
    └── directory-architecture.md （本文件）
```

---

## 二、目录设计原则

### 原则 1：根目录只放 3 个文件

```
CANON.md    ← 宪法。根目录 = 最高优先级，一眼看到
CLAUDE.md   ← 入口。Claude 加载的第一个文件
README.md   ← 总览。人类阅读的入口
```

宪法放在根目录而不是子目录中，传递的信号：**宪法高于一切**。

### 原则 2：所有技能在 skills/ 下，采用 phase-role-skill 命名

```
skills/                        ← 容器目录
  define-workflow-refine/      ← <phase>-<role>-<skill>/
    SKILL.md                   ← 标准技能文件（YAML frontmatter + body）
  define-workflow-spec/
    SKILL.md
  define-cognitive-brainstorm/
    SKILL.md
  build-quality-tdd/
    SKILL.md
  ...
```

**Skills 官方标准格式：**
每个技能是一个子目录，内含 `SKILL.md` 文件。YAML frontmatter 包含 `name` 和 `description`。

**命名规范（phase-role-skill）：**

| 段 | 说明 | 可选值 |
|----|------|--------|
| **phase** | 开发阶段 | define, build, verify, ship, maintain, reflect |
| **role** | 角色/领域 | workflow, frontend, backend, quality, cognitive, infrastructure, team |
| **skill** | 具体技能 | refine, spec, tdd, api-design, retro... |

示例：`build-quality-tdd` = "构建阶段 → 质量角色 → TDD 技能"

**为什么不用嵌套目录：**
- 43 个技能无需嵌套，每个目录名已包含完整语义
- `/build` 命令可以 `skills/build-*` glob 加载整个阶段
- `ls skills/` 按阶段自动分组排序（define-* → build-* → verify-* → ship-* → maintain-* → reflect-*）
- 新增技能只需 `skills/<phase>-<role>-<skill>/SKILL.md`，不需要抉择放在哪个领域目录

### 原则 3：命令直接映射到具体技能

```
命令入口             → 加载的 SKILL.md
────────────────────────────────────────────
commands/refine.md  → skills/define-workflow-refine/SKILL.md
commands/plan.md    → skills/build-workflow-plan/SKILL.md
commands/build.md   → skills/build-workflow-execute/SKILL.md
                     + skills/build-quality-tdd/SKILL.md
                     + skills/build-cognitive-execution-engine/SKILL.md
commands/review.md  → skills/verify-workflow-review/SKILL.md
                     + agents/*（并行发散时）
commands/ship.md    → skills/ship-workflow-ship/SKILL.md
```

### 原则 4：技能按阶段分组，不嵌套角色

```
✅ skills/
     build-quality-tdd/SKILL.md       ← 技能目录名自带完整语义
     build-cognitive-context/SKILL.md

❌ skills/
     build/
       quality/
         tdd/
           SKILL.md                   ← 三层嵌套，引用路径过长
```

### 原则 5：文件命名全部 kebab-case

```
✅ accessibility/SKILL.md
✅ build-frontend-ui-engineering/SKILL.md
✅ verify-team-code-review-standards/SKILL.md

❌ a11y/SKILL.md                     ← 不缩写
❌ buildFrontendUI/SKILL.md          ← 不 camelCase
```

---

## 三、技能阶段映射

### 3.1 阶段分布

```
skills/
│
├── <define>                         ← 定义阶段：想清楚再动手
│   ├── define-workflow-refine       → 模糊想法→规范 spec
│   ├── define-workflow-spec         → 编写规范 spec
│   └── define-cognitive-brainstorm  → 发散/收敛探索
│
├── <build>                          ← 构建阶段：增量实现
│   ├── build-workflow-plan          → 任务分解与计划
│   ├── build-workflow-execute       → 增量实现
│   ├── build-frontend-ui-engineering
│   ├── build-frontend-browser-testing
│   ├── build-backend-api-design
│   ├── build-backend-database
│   ├── build-backend-service-patterns
│   ├── build-quality-tdd            → TDD 铁律
│   ├── build-content-writing        → 内容写作与结构打磨
│   ├── build-content-layout         → 版式与视觉层级
│   ├── build-cognitive-context
│   ├── build-cognitive-source-driven
│   ├── build-cognitive-execution-engine → 3 种执行模式
│   ├── build-cognitive-decision-record
│   └── build-infrastructure-git
│
├── <verify>                         ← 验证阶段：质量把关
│   ├── verify-workflow-review       → 五轴代码审查
│   ├── verify-workflow-debug        → 4 阶段调试 + Phase 4.5 架构质疑门
│   ├── verify-frontend-accessibility
│   ├── verify-quality-integration-testing
│   ├── verify-quality-performance
│   ├── verify-quality-security
│   ├── verify-team-code-review-standards
│   ├── verify-content-review        → 内容质量审查
│   └── verify-visual-review         → 视觉质量审查
│
├── <ship>                           ← 发布阶段：交付上线
│   ├── ship-workflow-ship           → 预发检查 → Go/No-Go → 回滚计划
│   ├── ship-infrastructure-ci-cd    → CI/CD 管道
│   ├── ship-infrastructure-deploy   → 部署策略
│   └── ship-artifact-export         → 非软件产物导出
│
├── <maintain>                       ← 维护阶段：运维+修复
│   ├── maintain-infrastructure-observability
│   └── maintain-team-deprecation-migration
│
└── <reflect>                        ← 复盘阶段：沉淀知识
    ├── reflect-team-retro            → 回顾与改进
    └── reflect-team-documentation    → 知识与 ADR
```

### 3.2 技能到文档产出的映射

```
技能完成                       → docs/features/YYYYMMDD-<name>/
────────────────────────────────────────────
define-workflow-refine        → 01-spec.md
build-workflow-plan           → 02-plan.md
build-workflow-execute        → adr/<num>-<title>.md（有决策时）
verify-workflow-review        → review.md（可选）
ship-workflow-ship            → ship.md + README.md（事后总结）
```

### 3.3 技能到模板的映射

```
技能                               → 使用的模板
─────────────────────────────────────────────
define-workflow-refine/SKILL.md   → templates/feature/01-spec.md
build-workflow-plan/SKILL.md      → templates/feature/02-plan.md
verify-workflow-debug/SKILL.md  → templates/bug/*
verify-workflow-review/SKILL.md   → 直接产出 docs/features/YYYYMMDD-<name>/review.md
ship-workflow-ship/SKILL.md       → templates/feature/README.md
                                  + 直接产出 docs/features/YYYYMMDD-<name>/ship.md
任意 build 中决策                 → templates/feature/adr/template.md
```

---

## 四、加载策略

### 4.1 按阶段按需加载

```
场景                    → 加载的模式
─────────────────────────────────────────
/refine                 → skills/define-*
/plan                   → skills/build-workflow-plan
/build                  → skills/build-*（按 artifact_type 选择软件或内容/版式技能）
/build + 需要前端       → skills/build-*（已含 build-frontend-*）
/build + 文档/文章/PPT  → skills/build-content-writing + build-content-layout（按需）
/build + 视觉稿         → skills/build-content-layout
/build + 需要安全审查   → skills/verify-* + skills/verify-quality-security
/review --full          → skills/verify-* + agents/*
/build 遇到选型         → skills/build-*（已含 build-cognitive-decision-record）
```

### 4.2 为什么 `skills/build-*` 可以一键加载

构建阶段包含软件和非软件产物的生成技能：前端、后端、数据库、TDD、执行引擎、git、内容写作、版式。当执行 `/build` 命令时，先读取 spec 的 `artifact_type`，再加载对应的 `skills/build-*`。

覆盖范围：15 个 build 技能，涵盖前端/后端/TDD/认知/基础设施/内容/版式。

---

## 五、命名约定速查表

| 类别 | 约定 | 示例 |
|------|------|------|
| 宪法 | 根目录，单文件 | `CANON.md` |
| 入口 | 根目录，单文件 | `CLAUDE.md` |
| 技能目录 | `<phase>-<role>-<skill>` | `build-quality-tdd/` |
| 技能文件 | 固定文件名 | `SKILL.md` |
| 阶段值 | kebab-case | `define`, `build`, `verify`, `ship`, `maintain`, `reflect` |
| 角色值 | kebab-case | `workflow`, `frontend`, `backend`, `quality`, `cognitive`, `infrastructure`, `team`, `content`, `visual`, `artifact` |
| 命令 | kebab-case | `review.md` |
| Agent | kebab-case | `review-code-reviewer.md` |
| 模板 | 数字前缀 + kebab-case | `01-spec.md`, `02-plan.md` |
| 产出文档 | 数字前缀 + kebab-case | `01-spec.md`, `01-root-cause.md` |

---

## 六、完整文件清单

```
unified/
├── CANON.md
├── CLAUDE.md
├── README.md
│
├── skills/
│   ├── define-workflow-refine/
│   │   └── SKILL.md
│   ├── define-workflow-spec/
│   │   └── SKILL.md
│   ├── define-cognitive-brainstorm/
│   │   └── SKILL.md
│   │
│   ├── build-workflow-plan/
│   │   └── SKILL.md
│   ├── build-workflow-execute/
│   │   └── SKILL.md
│   ├── build-frontend-ui-engineering/
│   │   └── SKILL.md
│   ├── build-frontend-browser-testing/
│   │   └── SKILL.md
│   ├── build-backend-api-design/
│   │   └── SKILL.md
│   ├── build-backend-database/
│   │   └── SKILL.md
│   ├── build-backend-service-patterns/
│   │   └── SKILL.md
│   ├── build-quality-tdd/
│   │   └── SKILL.md
│   ├── build-cognitive-context/
│   │   └── SKILL.md
│   ├── build-cognitive-source-driven/
│   │   └── SKILL.md
│   ├── build-cognitive-execution-engine/
│   │   └── SKILL.md
│   ├── build-cognitive-decision-record/
│   │   └── SKILL.md
│   ├── build-infrastructure-git/
│   │   └── SKILL.md
│   │
│   ├── build-content-writing/
│   │   └── SKILL.md
│   ├── build-content-layout/
│   │   └── SKILL.md
│   │
│   ├── verify-workflow-review/
│   │   └── SKILL.md
│   ├── verify-workflow-debug/
│   │   └── SKILL.md
│   ├── verify-workflow-receiving-review/
│   │   └── SKILL.md
│   ├── verify-frontend-accessibility/
│   │   └── SKILL.md
│   ├── verify-quality-integration-testing/
│   │   └── SKILL.md
│   ├── verify-quality-performance/
│   │   └── SKILL.md
│   ├── verify-quality-security/
│   │   └── SKILL.md
│   ├── verify-team-code-review-standards/
│   │   └── SKILL.md
│   ├── verify-content-review/
│   │   └── SKILL.md
│   ├── verify-visual-review/
│   │   └── SKILL.md
│   ├── verify-quality-simplify/
│   │   └── SKILL.md
│   │
│   ├── ship-workflow-ship/
│   │   └── SKILL.md
│   ├── ship-workflow-canary/
│   │   └── SKILL.md
│   ├── ship-workflow-land/
│   │   └── SKILL.md
│   ├── ship-workflow-doc-sync/
│   │   └── SKILL.md
│   ├── ship-infrastructure-ci-cd/
│   │   └── SKILL.md
│   ├── ship-infrastructure-deploy/
│   │   └── SKILL.md
│   ├── ship-artifact-export/
│   │   └── SKILL.md
│   │
│   ├── maintain-workflow-context-save/
│   │   └── SKILL.md
│   ├── maintain-workflow-context-restore/
│   │   └── SKILL.md
│   ├── maintain-workflow-learn/
│   │   └── SKILL.md
│   ├── maintain-infrastructure-observability/
│   │   └── SKILL.md
│   ├── maintain-team-deprecation-migration/
│   │   └── SKILL.md
│   │
│   └── reflect-team-retro/
│       └── SKILL.md
│   └── reflect-team-documentation/
│       └── SKILL.md
│
├── commands/
│   ├── refine.md
│   ├── plan.md
│   ├── build.md
│   ├── review.md
│   ├── ship.md
│   ├── save.md
│   ├── restore.md
│   └── learn.md
│
├── agents/
│   ├── README.md
│   ├── review-code-reviewer.md
│   ├── review-security-auditor.md
│   ├── review-test-engineer.md
│   ├── plan-ceo-reviewer.md
│   ├── plan-eng-reviewer.md
│   ├── plan-design-reviewer.md
│   ├── plan-security-reviewer.md
│   ├── refine-ceo-scout.md
│   ├── refine-eng-scout.md
│   ├── refine-design-scout.md
│   ├── review-accessibility-auditor.md
│   ├── ship-security-auditor.md
│   ├── ship-performance-auditor.md
│   ├── ship-accessibility-auditor.md
│   └── ship-docs-auditor.md
│
├── templates/
│   ├── feature/
│   │   ├── 01-spec.md
│   │   ├── 02-plan.md
│   │   ├── adr/
│   │   │   └── template.md
│   │   └── README.md
│   └── bug/
│       ├── 01-root-cause.md
│       └── 02-fix-plan.md
│
└── docs/
    ├── design-document.md
    └── directory-architecture.md

├── references/
│   └── orchestration-patterns.md
│
├── skills-lock.json             ← 技能完整性锁文件（SHA-256）

核心资产: 3 根文件 + 44 技能（44 SKILL.md） + 9 命令 + 15 审查角色 + 6 模板 + 2 设计文档 + 1 参考文档 + 1 锁文件。平台包装入口（如 `.agents/skills/`）单独计数，避免安装目标变化导致统计漂移。
```
