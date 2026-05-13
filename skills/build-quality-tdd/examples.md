# TDD Examples

本文件是 `build-quality-tdd/SKILL.md` 的辅助材料。主技能保留 RED/GREEN/REFACTOR 纪律；需要具体测试写法时读取本文件。

## RED / GREEN

```typescript
// RED: 测试失败，因为 createTask 还没有实现
it('用标题创建任务并设置默认状态', async () => {
  const task = await taskService.createTask({ title: '买菜' });

  expect(task.id).toBeDefined();
  expect(task.title).toBe('买菜');
  expect(task.status).toBe('pending');
});
```

```typescript
// GREEN: 最小实现，只满足当前测试
export async function createTask(input: { title: string }): Promise<Task> {
  const task = {
    id: generateId(),
    title: input.title,
    status: 'pending' as const,
  };
  await db.tasks.insert(task);
  return task;
}
```

## Bug 修复复现

```typescript
// Bug: 完成任务时不更新 completedAt
it('任务完成时设置 completedAt', async () => {
  const task = await taskService.createTask({ title: 'Test' });
  const completed = await taskService.completeTask(task.id);

  expect(completed.status).toBe('completed');
  expect(completed.completedAt).toBeInstanceOf(Date);
});
```

修复后同一测试必须 PASS，并作为回归保护保留。

## 测试状态，不测试交互

```typescript
// Good: 测试行为结果
it('按创建时间倒序返回任务', async () => {
  const tasks = await listTasks({ sortBy: 'createdAt', sortOrder: 'desc' });
  expect(tasks[0].createdAt.getTime())
    .toBeGreaterThan(tasks[1].createdAt.getTime());
});
```

```typescript
// Bad: 锁死内部实现细节
it('调用 db.query 并传入 ORDER BY created_at DESC', async () => {
  await listTasks({ sortBy: 'createdAt', sortOrder: 'desc' });
  expect(db.query).toHaveBeenCalledWith(
    expect.stringContaining('ORDER BY created_at DESC')
  );
});
```

## DAMP 示例

```typescript
it('拒绝空标题的任务', () => {
  expect(() => createTask({ title: '' })).toThrow('标题不能为空');
});

it('去除标题首尾空格', () => {
  const task = createTask({ title: '  买菜  ' });
  expect(task.title).toBe('买菜');
});
```
