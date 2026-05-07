---
name: part-e-templates
description: 02_technical_design.md Part E 测试场景模板。包含后端 API 场景清单、全流程场景（可执行格式）和前端交互场景清单。供 Arch Agent 撰写 Part E 时参考。
---

# Part E 测试场景模板

> 本 Skill 提供 02_technical_design.md Part E 的标准模板。Arch Agent 撰写技术设计时按此格式编写测试场景清单，Dev/FE 基于此编写测试代码并产出 04_test_plan.md。

## 加载引导

- **必加载场景**：Arch Agent 撰写 02_technical_design.md 时
- **可跳过场景**：其他 Agent 或 Arch 尚未进入 Part E 撰写阶段

---

Part E 写在 `02_technical_design.md` 的末尾（Part C 之后）。

## E-1: 后端 API 场景清单

每个新增/修改的 API 端点必须列出正常、边界、错误三类场景：

```markdown
### E-1: [API 端点名] POST /api/xxx

| # | 场景类型 | 场景描述 | 输入 | 预期输出 |
|---|---------|---------|------|---------|
| 1 | 正常 | 有效参数，操作成功 | `{...}` | `200, {...}` |
| 2 | 边界 | 必填字段为空/null | `{name: ""}` | `400, "名称不能为空"` |
| 3 | 边界 | 字段达到最大/最小长度 | `{name: "a"*100}` | 200 或 400 |
| 4 | 错误 | 业务规则冲突（如重复名称） | `{name: "已存在"}` | `400, "名称已存在"` |
| 5 | 错误 | 引用不存在的关联资源 | `{platformId: 999}` | `400, "平台不存在"` |
```

## E-2: 全流程场景（可执行格式，供 §8 运行验证 AI 自动执行）

```markdown
### E-2: 全流程场景 — [业务流程名]

| 步骤 | 操作 | 预期 |
|------|------|------|
| 1 | `POST /api/xxx {"name":"test"}` | 200, 返回 `{id}` |
| 2 | `GET /api/xxx/list?pageNumber=1&pageSize=10` | 200, 列表含 "test" |
| 3 | `PUT /api/xxx/{step1.id} {"name":"updated"}` | 200 |
| 4 | `DELETE /api/xxx/{step1.id}` | 200 |
| 5 | `GET /api/xxx/{step1.id}` | 404 或 data=null |
```

> `{stepN.id}` 表示引用步骤 N 的返回值，主会话运行验证时自动替换。

## E-3: 前端交互场景清单

```markdown
### E-3: 页面交互场景 — [页面名]

| # | 场景类型 | 场景描述 | 操作 | 预期 |
|---|---------|---------|------|------|
| 1 | 正常 | 表单正常提交 | 填写必填项→点提交 | 成功提示 + 列表刷新 |
| 2 | 边界 | 空表单提交 | 不填→点提交 | 表单校验红框 |
| 3 | 边界 | 列表为空 | 无数据 | 显示空状态占位 |
| 4 | 错误 | API 返回错误 | 触发后端错误 | 错误提示，不影响页面 |
```

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
