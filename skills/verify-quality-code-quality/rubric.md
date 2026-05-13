# Code Quality Rubric

本文件是 `verify-quality-code-quality/SKILL.md` 的辅助材料。主技能保留审查流程；需要逐轴检查项和标记示例时读取本文件。

## Correctness

检查：
- 边界情况：null、undefined、空数组、空字符串、边界值
- 错误处理：try/catch、错误传播、用户友好错误
- 类型安全：无 any 滥用、类型守卫明确
- 并发安全：竞态、锁、原子操作
- 数据一致性：事务、回滚、幂等

```markdown
### Correctness
- ✅ 边界情况处理完整
- ⚠️ 错误处理不足: `path/file.ts:45` 缺少网络错误处理
- ✅ 类型安全
```

## Readability

检查：
- 命名是否自解释
- 控制流是否直白，嵌套是否过深
- 函数是否职责单一
- 注释是否解释 why
- 复杂度是否可维护

## Architecture

检查：
- 模式选择是否适合场景
- 模块边界是否清晰
- 依赖方向是否单向
- 扩展是否需要大量改动
- 是否遵循项目现有架构

## Security

检查：
- 外部输入是否验证
- 输出是否编码，是否防 XSS / SQL 注入 / 命令注入
- 密钥和 token 是否硬编码
- 鉴权检查是否完整
- 日志是否泄露敏感数据

## Performance

检查：
- N+1 查询
- 无界循环
- 资源释放
- 缓存策略
- 时间/空间复杂度
