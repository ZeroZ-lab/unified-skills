# <Feature Name> — Implementation Plan

## Artifact Type
artifact_type: software

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
- [ ] 验收标准: 明确本切片完成条件
- [ ] 生成/实现: 最小可验证产物
- [ ] 验证: software 跑测试；非 software 做内容/视觉/导出检查
- [ ] 调整: 根据验证结果修正
- [ ] COMMIT
