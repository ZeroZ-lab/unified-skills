# Agents — 并行审查角色

用于 review 和 ship 的并行发散模式。这三个 agent 会被同时派发、独立工作、合并报告。

| Agent | 职责 | 调用时机 |
|-------|------|---------|
| code-reviewer | 五轴审查（正确性、可读性、架构、安全、性能） | review --full / ship |
| security-auditor | 安全审计（OWASP、威胁建模、密钥扫描） | review --full / ship |
| test-engineer | 测试覆盖分析（happy path、边界、错误路径、并发） | review --full / ship |

## 使用方式

三个 agent 必须同时派发（并行），各自产出独立报告，然后在主 session 合并。
