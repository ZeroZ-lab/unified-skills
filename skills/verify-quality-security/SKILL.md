---
name: verify-quality-security
description: 安全加固——每个外部输入是敌意的，每个密钥是神圣的，每个鉴权检查是强制的。使用 cuando 涉及用户输入、认证、数据存储、或上线前审查
---

# Security — 安全加固


## 入口/出口
- **入口**: 涉及用户输入、认证授权、敏感数据、或 `/review` 和 `/ship` 前
- **出口**: 加固代码 + 安全审查通过
- **指向**: 安全问题修复后重新进入 `/review`
- **假设已加载**: CANON.md

## Iron Law

```
每个外部输入视为敌意。每个密钥视为神圣。每个鉴权检查视为强制。
安全不是"一个阶段"——安全是每行代码的约束。
安全是无条件说"不"的唯一领域。不通过安全审查 = 不能上线。
```

## 三级边界系统

| 级别 | 规则 | 示例 |
|------|------|------|
| **Always Do** | 提交前验证输入、参数化查询、哈希密码、HTTPS only cookies | 输入 sanitization、bcrypt、helmet |
| **Ask First** | 泄露用户数据、改权限模型、引入认证依赖、加密算法选择 | 新 OAuth provider、加密库选型 |
| **Never Do** | 提交密钥、信任客户端验证、`eval()` 用户输入、innerHTML 用户数据、暴露堆栈给用户 | `.env` 在仓库、`dangerouslySetInnerHTML` |

## OWASP Top 10 防御

### 1. 注入 (SQL/NoSQL/Command)

```typescript
// Bad: SQL 拼接
const task = await db.query(`SELECT * FROM tasks WHERE id = '${req.params.id}'`);

// Good: 参数化查询
const task = await db.tasks.findById(req.params.id);

// 命令行参数必须通过 exec/spawn 的参数数组，不拼接字符串
```

### 2. 跨站脚本 (XSS)

```typescript
// Bad: 直接插入用户内容
<div>{user.bio}</div>  // 如果 bio 包含 <script>...

// Good: 框架自动转义 + DOMPurify for rich text
<div>{user.bio}</div>  // React 默认转义
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(richBio) }} />
```

### 3. 敏感数据暴露

```typescript
// Bad: 错误暴露内部信息
catch (err) {
  res.status(500).json({ error: err.message, stack: err.stack });
}

// Good: 用户可见错误不含内部信息
catch (err) {
  logger.error('Task creation failed', { taskId, error: err.message });
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: '处理请求时发生错误' } });
}
```

### 4. 访问控制缺失

```typescript
// Bad: 任何登录用户都能删任何任务
app.delete('/tasks/:id', auth, async (req, res) => {
  await db.tasks.delete(req.params.id);
});

// Good: 验证所有权
app.delete('/tasks/:id', auth, async (req, res) => {
  const task = await db.tasks.findById(req.params.id);
  if (!task) return res.status(404).end();
  if (task.ownerId !== req.user.id) return res.status(403).end();
  await db.tasks.delete(req.params.id);
});
```

### 5. 安全配置错误

```typescript
// 必须: helmet、CORS 白名单、HTTPS 重定向、安全 cookies
app.use(helmet());
app.use(cors({ origin: ALLOWED_ORIGINS }));
app.use(session({ cookie: { secure: true, httpOnly: true, sameSite: 'strict' } }));
```

### 6. 依赖漏洞

```bash
npm audit          # 检查已知 CVE
npm audit fix      # 自动修复兼容补丁
```

**分类:**
- Critical/High → 必须修复（修复或替换依赖）
- Moderate → 评估实际可利用性（仅在特定条件下可能利用）
- Low → 排期但不阻塞上线

## 输入验证

```typescript
import { z } from 'zod';

const CreateTaskSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().max(5000).optional(),
  priority: z.enum(['low', 'medium', 'high']),
  assigneeId: z.string().uuid().optional(),
});
```

**规则:** 所有外部输入在边界（API handler）验证。验证完之后内部信任。

## 密钥管理

```
项目结构:
├── .env.example          # 模板（可提交）
├── .env                  # 真实密钥（在 .gitignore，绝不提交）
└── src/config.ts         # 从环境变量读取

.gitignore 必须包含:
.env
.env.local
*.pem
*.key
credentials.json
```

**检查是否误提交:**
```bash
git log --all --full-history -- '*.env' '*.pem' 'credentials.*'
```

## 常见说辞

| 说辞 | 现实 |
|------|------|
| "只在内部用，不对外开放" | 内网不是信任边界。Dependency confusion、内网横向移动——内部应用仍需要安全加固。 |
| "npm audit 报的都是低风险" | 低风险可能组合成高风险。至少读一遍 audit 报告。 |
| "用户输入在前端验证过了" | 前端验证是 UX 优化，不是安全。攻击者发 curl 直接绕过。 |
| "这是个简单的内部工具" | 简单工具暴露一个未验证输入就被用作内网跳板。 |
| "以后再加强安全" | 安全债和技术债不同——安全债可能导致数据泄露。不能之后补。 |

## 红旗 — STOP

- 用户输入到了 SQL/Shell/HTML 中而未参数化/转义
- 密钥或令牌出现在代码或日志中
- `Authorization: Bearer <token>` 在没有 HTTPS 的连接上
- 用 `<` 或 `>` 字符串比较做权限检查（可绕过）
- 没有速率限制的认证端点（暴力破解）
- `innerHTML`、`dangerouslySetInnerHTML`、`eval()` 含用户数据
- API 返回的 stack trace 包含文件路径或内部库名

## 验证清单

- [ ] 所有用户输入在边界验证（Zod / Yup / Joi）
- [ ] SQL 查询使用参数化（无字符串拼接）
- [ ] HTML 中的用户内容被转义
- [ ] 错误响应不含 stack trace 或内部路径
- [ ] 每个写端点验证了资源所有权
- [ ] 密钥不在代码仓库中
- [ ] `npm audit`（或同等）无 critical/high
- [ ] 安全头设置（helmet、CORS 白名单、secure cookies）
