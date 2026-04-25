---
name: api-reviewer
description: REST API 设计与审查规则。用于后端 API 端点的设计与实现验证。
---

# API 审查规则 (API Reviewer Skill)

> 本 Skill 由 Arch/Dev Agent 在处理 API 相关任务时加载，用于指导 REST API 设计与审查。

## API 设计原则

### 1. 端点规范

- 使用 RESTful 路径：资源名词而非动词（如 `/api/users` 而非 `/api/getUsers`）
- 版本控制：支持多版本共存（`/api/v1/`, `/api/v2/` 等）
- 命名一致：使用 snake_case（路径）、camelCase（JSON 字段）
- 资源路由：`POST /users`（创建）, `GET /users/:id`（获取）, `PUT /users/:id`（更新）, `DELETE /users/:id`（删除）

### 2. 请求与响应

- **Request**：明确定义请求参数、类型、必填字段、验证规则
- **Response**：统一使用通用响应格式（如 `{ code, message, data, detail }`）
- **Error Handling**：明确定义错误代码和错误信息，避免返回语义不明的 null

### 3. 认证与授权

- 实现统一的身份认证（Token/JWT/Session）
- 鉴权检查应在 Controller 或 Filter 层实现
- 避免硬编码权限检查

### 4. 性能与可靠性

- 列表接口必须分页
- 避免过度关联查询（SELECT N+1 问题）
- 考虑缓存策略（Redis/本地缓存）
- 实现幂等性（重复请求不产生重复影响）

## API 审查检查表

### 设计阶段

- [ ] **HTTP 方法**：是否使用了正确的 HTTP 方法（GET/POST/PUT/DELETE）？
- [ ] **路径规范**：是否遵循 RESTful 命名规范？
- [ ] **版本控制**：新 API 是否明确了版本号？
- [ ] **请求体**：是否明确定义了请求参数和验证规则？
- [ ] **响应格式**：是否使用了项目统一的响应格式？
- [ ] **错误处理**：是否定义了错误代码和错误信息？
- [ ] **幂等性**：幂等操作是否有实现策略？

### 实现阶段

- [ ] **参数验证**：Controller 是否验证了所有输入参数？
- [ ] **权限检查**：是否进行了鉴权和授权检查？
- [ ] **异常处理**：是否捕获和妥善处理了所有异常？
- [ ] **日志记录**：关键操作是否有适当的日志记录？
- [ ] **敏感信息**：日志中是否避免了打印敏感信息？
- [ ] **分页实现**：列表接口是否正确实现了分页？

### 文档阶段

- [ ] **文档完整**：是否为每个端点编写了清晰的文档？
- [ ] **示例提供**：是否提供了请求和响应的完整示例？
- [ ] **版本说明**：是否说明了不同版本的差异？

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
