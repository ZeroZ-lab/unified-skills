# <Feature Name> — Implementation Plan

## 依赖顺序
```
Task 1（独立）
  ├── Task 2（依赖 1）
  └── Task 3（依赖 1，可与 2 并行）
Task 4（依赖 2 + 3）
```

### Task N: <名称>
**文件:** 创建/修改/测试路径
**依赖:** Task N-1
- [ ] RED: 测试代码 → 验证 FAIL
- [ ] GREEN: 实现代码 → 验证 PASS
- [ ] REFACTOR: [具体操作]
- [ ] COMMIT
