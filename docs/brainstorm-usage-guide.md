# 脑暴席位使用指南

## 概述

`/brainstorm` 现在支持**按需选座**，根据任务类型自动选择最合适的 scout 组合，告别"一刀切"的固定席位。

## 快速开始

### 方式 1: 使用预设配置（推荐）

```bash
# 技术架构讨论
/brainstorm --profile tech_architecture "如何设计一个高可用的订单系统？"

# 产品战略讨论
/brainstorm --profile product_strategy "如何进入中小企业市场？"

# 内容营销脑暴
/brainstorm --profile content_marketing "如何写一篇有传播力的技术博客？"

# API 设计讨论
/brainstorm --profile api_design "REST API 的版本策略怎么设计？"

# 默认通用脑暴
/brainstorm "如何提升用户留存率？"
```

### 方式 2: 自定义席位

```bash
# 只关注技术和数据
/brainstorm --seats tech,data,outlier "数据库选型怎么考虑？"

# 关注设计和内容
/brainstorm --seats design,content,business,outlier "首页改版怎么提升转化率？"

# 关注安全和合规
/brainstorm --seats security,tech,data,outlier "如何满足 GDPR 合规要求？"
```

### 方式 3: 查看可用配置

```bash
/brainstorm --list-profiles
```

## 可用预设配置

| 配置名称 | 包含 Scout | 适用场景 |
|---------|-----------|---------|
| `general` | tech + design + business + outlier | 通用产品/功能讨论（默认） |
| `tech_architecture` | tech + data + security + outlier | 系统架构、技术选型、数据库设计 |
| `product_strategy` | business + design + content + outlier | 产品定位、市场策略、用户增长 |
| `content_marketing` | content + design + business + outlier | 营销文案、内容策略、传播方案 |
| `api_design` | tech + data + security + outlier | API 设计、接口契约、版本策略 |
| `security_review` | security + tech + data + outlier | 安全架构、威胁模型、合规策略 |
| `user_experience` | design + content + business + outlier | 交互设计、用户旅程、体验优化 |
| `data_strategy` | data + tech + security + outlier | 数据建模、存储策略、数据治理 |

## 可用 Scout

| Scout | 专业视角 | 核心框架 |
|-------|---------|---------|
| **tech-scout** | 架构方案、技术选型、实现路径 | First Principles, Constraints, Pre-mortem, Time-travel |
| **design-scout** | 用户旅程、交互模式、情感设计 | HMW, Crazy 8, Role-play, Anti-pattern |
| **business-scout** | 价值主张、市场定位、商业模式 | JTBD, Blue Ocean, Business Model Canvas, Pre-mortem |
| **content-scout** | 叙事结构、受众共鸣、表达方式 | Audience Journey, Message Hierarchy, Format Experiment, Viral Mechanics |
| **data-scout** | 数据建模、存储策略、查询优化 | Data Flow, Access Patterns, CAP Theorem, Data Mesh |
| **security-scout** | 威胁模型、攻击面、防护策略 | STRIDE, CIA Triad, OWASP Top 10, Attack Trees |
| **outlier-scout** | 反向思考、黑天鹅事件、挑战假设 | Inversion, 10x Thinking, Constraints → Freedom, 质疑所有共识 |

**注意**: `outlier-scout` 默认自动加入，确保多样性和挑战思维定式；只有显式 `--no-outlier` 时才排除。

## 实战示例

### 示例 1: 技术架构讨论

```bash
/brainstorm --profile tech_architecture "订单系统如何支持双 11 十亿级流量？"
```

**参与 Scout**: tech + data + security + outlier

**预期产出**:
- tech-scout: 微服务架构、消息队列、缓存策略、弹性伸缩
- data-scout: 分库分表、读写分离、冷热数据分离、数据一致性
- security-scout: 防刷、风控、数据加密、合规审计
- outlier-scout: "如果不用数据库呢？"（全内存架构？Event Sourcing？）

### 示例 2: 产品战略讨论

```bash
/brainstorm --profile product_strategy "如何从 C 端扩展到 B 端市场？"
```

**参与 Scout**: business + design + content + outlier

**预期产出**:
- business-scout: PLG 模式、定价策略、销售渠道、合作伙伴
- design-scout: B 端用户体验、管理员界面、权限设计、工作流
- content-scout: 白皮书、案例研究、行业术语、信任建立
- outlier-scout: "如果先做 B 端再倒推 C 端呢？"（反向策略？）

### 示例 3: 自定义席位

```bash
/brainstorm --seats tech,security,outlier "如何防御 API 滥用？"
```

**参与 Scout**: tech + security + outlier

**预期产出**:
- tech-scout: 限流算法、熔断机制、缓存、CDN
- security-scout: API 认证、风险评估、异常检测、WAF
- outlier-scout: "如果 API 完全开放呢？"（ freemium 模式？社区 API？）

## 最佳实践

1. **优先使用预设配置** — 预设配置经过优化，覆盖大多数场景
2. **关注 scout 数量** — 3-5 个 scout 是最佳数量，太多会导致收敛困难
3. **不要排除 outlier** — 除非非常确定不需要"疯狂"想法
4. **根据问题类型选择** — 技术问题用 tech_architecture，商业问题用 product_strategy
5. **信任配置** — 预设配置已经考虑了 scout 之间的互补性

## 对比：固定席位 vs 按需选座

### 旧版（固定席位）
```bash
/brainstorm "如何设计订单系统？"
# 固定: tech + design + business + outlier
# 问题: 缺少 data-scout 和 security-scout，对于订单系统不够全面
```

### 新版（按需选座）
```bash
/brainstorm --profile tech_architecture "如何设计订单系统？"
# 智能: tech + data + security + outlier
# 优势: 针对技术架构问题，自动选择最相关的视角
```

## 技术细节

配置文件：`commands/brainstorm-menu.json`

如果需要添加新的预设配置或自定义 scout，可以编辑该文件。
