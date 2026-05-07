---
name: spec-templates
description: Spec 文档模板与编写规范。用于 PM/Arch/Dev/FE Agent 撰写规范化的需求、设计、实现文档。
---

# Spec 文档模板 (Spec Templates Skill)

> 本 Skill 由 PM/Arch/Dev/FE Agent 加载，用于指导 Spec 文档的编写与组织。

## 加载引导

- **必加载场景**：PM/Arch/Dev/FE Agent 撰写 Spec 文档时
- **可跳过场景**：不涉及 Spec 撰写的任务
- **渐进式加载**：核心规范在本文件，各文档模板详见 references/ 目录

## 目录结构

每个 Feature/Fix 应创建一个 Spec 目录：

```
.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/
├── 01_requirement.md          # PM 撰写：业务需求与验收标准
├── 02_technical_design.md     # Arch 撰写：技术设计与实现方案
├── 03_impl_backend.md         # Dev 撰写：后端执行日志（如适用）
├── 03_impl_frontend.md        # FE 撰写：前端执行日志（如适用）
├── 04_test_plan.md            # Dev/FE 撰写：测试计划（追溯矩阵 + 全流程用例）
└── evidences/                 # QA 和主会话存放验证证据（含 QA 测试审计结论）
    ├── evidence-qa-review.md
    └── evidence-api-test.md
```

## 模板索引

| 文档 | 产出者 | 模板 |
|------|--------|------|
| 01_requirement.md | PM | [references/01-requirement.md](references/01-requirement.md) |
| 02_technical_design.md | Arch | [references/02-technical-design.md](references/02-technical-design.md) |
| 03_impl_*.md | Dev/FE | [references/03-impl.md](references/03-impl.md) |
| 04_test_plan.md | Dev/FE | [references/04-test-plan.md](references/04-test-plan.md) |

## 列表（分页）接口标准响应结构（硬约定）

> **跨项目契约**：后端分页包装器自动输出以下结构，写 Spec 时**必须**按此模板填充，禁止另行发明字段名。
> 详见后端编码规则的分页约定和前端共享编码规则 §4.1。

**Request**：
```json
{
  "pageNumber": 1,
  "pageSize":   20,
  "...": "业务过滤字段"
}
```

**Response**：
```json
{
  "code": 0,
  "message": "成功",
  "data": {
    "list":       [ /* VO 数组 */ ],
    "pageNumber": 1,
    "pageSize":   20,
    "pageTotal":  5,
    "total":      100
  }
}
```

**禁止**：ORM 框架原生别名（如 MyBatis-Plus 的 `records` / `current` / `size` / `pages`）；`page` / `limit` 等非标准别名。

## 最佳实践

1. **清晰的目标**：每个 Spec 都应有明确的业务目标和验收标准
2. **详细的 AC**：至少包括 1 个主流程 AC 和 2+ 个异常场景 AC
3. **完整的设计**：Arch 设计应涵盖 API Contract、DB Schema、前端设计等必要部分
4. **执行日志**：Dev/FE 应在实现过程中实时记录变更、决策和问题
5. **及时更新**：Spec 应在执行过程中及时更新以反映偏差和决策变化

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
