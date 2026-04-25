---
name: spec-templates
description: Spec 文档模板与编写规范。用于 PM/Arch/Dev/FE Agent 撰写规范化的需求、设计、实现文档。
---

# Spec 文档模板 (Spec Templates Skill)

> 本 Skill 由 PM/Arch/Dev/FE Agent 加载，用于指导 Spec 文档的编写与组织。

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

## 01_requirement.md（PM 责任）

### 结构

```markdown
# 需求：[功能名称]

## 背景与目标
- 业务背景：为什么需要这个功能？
- 目标用户：谁会使用这个功能？
- 核心价值：带来什么业务价值？

## 功能描述
- 功能概述：核心功能是什么？
- 业务规则：有哪些业务约束或限制？

## 验收标准（AC）

### AC-1：主流程
- 给定：前置条件
- 当：执行操作
- 则：预期结果

### AC-2：异常场景 1
- 给定：异常条件
- 当：执行操作
- 则：预期错误处理

### AC-3：异常场景 2
- ...

## 范围说明
- 包括：哪些功能点
- 不包括：哪些功能点不在本次范围

## 相关人员
- 需求方：...
- PM：...
```

## 02_technical_design.md（Arch 责任）

### 结构（后端）

```markdown
# 技术设计：[功能名称]

## Part A: API Contract

### 新增 API
- 端点：`POST /api/v1/users`
- 请求：{ name, email, ... }
- 响应：{ code, message, data: { id, name, ... } }
- 错误：{ code: 400, message: "邮箱格式错误" }

### 修改 API
- ...

## Part D: DB Schema

### 新增表
\`\`\`sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ...
);
CREATE INDEX idx_users_email ON users(email);
\`\`\`

### 修改表
\`\`\`sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
\`\`\`

## Part C: 技术风险与注意事项
- 风险 1：...
- 风险 2：...
- 注意事项：...
```

### 结构（前端）

```markdown
# 技术设计：[功能名称]

## Part B: 页面/路由/组件设计

### 路由
- 新增路由：`/user/profile`

### 页面结构
```
UserProfile
  ├─ Header（用户基本信息）
  ├─ Form（编辑表单）
  └─ Actions（提交/取消按钮）
```

### Vuex State
- 新增：`user.profile = { id, name, email, ... }`
- 新增 mutation：`setUserProfile(state, profile)`

### API 字段映射
| 后端字段 | 前端字段 | 说明 |
|---------|---------|------|
| user_id | id | 用户 ID |
| name | name | 用户名 |
| ... | ... | ... |

## Part C: 技术风险与注意事项
- 风险 1：...
- 注意事项：...
```

## 03_impl_backend.md / 03_impl_frontend.md（Dev/FE 责任）

**定位**：执行日志，非计划文档。无需审批，供 QA 审查时参考。

**更新时机**：每个子任务完成后立即追加，而非全部做完再补写。

### 结构

```markdown
# 执行日志：[功能名称] — 后端/前端

## 变更文件清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新增 | src/.../XxxController.java | 新增 CRUD 端点 |
| 修改 | src/.../XxxService.java | 新增 createXxx 方法 |
| 删除 | — | — |

## 关键决策
- [决策]：为什么这样做而非那样做（偏离 02 设计时必须记录原因）

## 问题记录
- **[问题]**：描述 → 处理方式/解决方案
```

## 04_test_plan.md（Dev/FE 责任）

**产出时机**：实现完成、Self-Test 通过后、流转 QA 前。

**核心价值**：可审计、可追溯——从测试用例能反推到需求，也能正推到代码。

### 结构

```markdown
# 测试计划：[功能名称]

## Part A：自动化测试矩阵

| # | 需求溯源 | 场景描述 | 场景来源 | 测试类型 | 测试代码 | 状态 |
|---|---------|---------|---------|---------|---------|------|
| 1 | 01 §X.X | [场景描述] | 02 Part E / Dev 补充 | 单元/集成/边界/错误 | [TestClass#method 或 file path] | PASS/FAIL |

> - 需求溯源：链接到 01 的具体章节号（如 01 §2.1）
> - 场景来源：标注来自 02 Part E（Arch 设计）还是 Dev/FE 实现中补充
> - 测试代码：精确到类名#方法名（后端）或文件路径（前端）

## Part B：全流程测试用例

### 后端（可执行，供 §8 AI 自动验证）

| 步骤 | 操作 | 预期 | 状态 |
|------|------|------|------|
| 1 | `curl -X POST http://localhost:<port>/api/xxx -H 'Content-Type: application/json' -d '{...}'` | 200, {...} | - |
| 2 | `curl http://localhost:<port>/api/xxx/list?pageNumber=1&pageSize=10` | 200, 列表含... | - |

> - 步骤间可引用前序返回值：`{step1.id}`
> - 状态列由主会话 §8 运行验证时填写
> - `<port>` 替换为项目实际端口

### 前端（人工验证清单，供用户浏览器验证）

| # | 场景描述 | 操作步骤 | 预期结果 |
|---|---------|---------|---------|
| 1 | [场景] | [具体操作] | [预期行为] |

## 未覆盖项
- [说明未覆盖的场景及原因，如有]
```

### 边界用例必测清单

> Dev/FE 编写 Part A 时，**必须逐项过一遍**以下清单，判断当前功能是否涉及。涉及的场景必须有对应测试行。

| # | 类别 | 典型场景 | 示例 |
|---|------|---------|------|
| 1 | Null / 空值 | 入参为 null、空字符串、空数组 | `name = null`、`ids = []` |
| 2 | 边界值 | 最小值、最大值、刚好越界 | `pageSize = 0`、`pageSize = Integer.MAX_VALUE` |
| 3 | 非法类型 / 格式 | 类型不匹配、格式错误 | `id = "abc"`、`email = "not-email"` |
| 4 | 错误路径 | 外部依赖失败、网络超时、数据库异常 | Dify API 返回 500、Redis 连接断开 |
| 5 | 并发 / 竞态 | 同一资源被并发修改 | 两个请求同时删除同一 Agent |
| 6 | 大数据量 | 超大分页、批量操作上限 | 一次导入 10000 条记录 |
| 7 | 特殊字符 | Unicode、SQL 注入字符、XSS payload | `name = "'; DROP TABLE--"` |
| 8 | 权限边界 | 无权限、跨租户访问 | 用户 A 访问用户 B 的资源 |

### 编写原则

1. **需求可追溯**：Part A 每行必须链接到 01 的具体章节
2. **场景来源清晰**：标注来自 02 Part E 还是研发补充
3. **代码可定位**：测试代码列精确到类名#方法名或文件路径
4. **全流程可执行**：后端 Part B 的 curl 命令可直接复制执行，包含完整 URL 和请求体

## 最佳实践

1. **清晰的目标**：每个 Spec 都应有明确的业务目标和验收标准
2. **详细的 AC**：至少包括 1 个主流程 AC 和 2+ 个异常场景 AC
3. **完整的设计**：Arch 设计应涵盖 API Contract、DB Schema、前端设计等必要部分
4. **执行日志**：Dev/FE 应在实现过程中实时记录变更、决策和问题
5. **及时更新**：Spec 应在执行过程中及时更新以反映偏差和决策变化

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

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
