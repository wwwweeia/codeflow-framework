---
name: sql-checker
description: SQL 审查规则与最佳实践。用于后端开发中的数据库操作规范验证。
---

# SQL 审查规则 (SQL Checker Skill)

> 本 Skill 由 Arch/Dev Agent 在处理数据库相关任务时加载，用于指导 SQL 设计与审查。

## 核心原则

1. **禁止拼接**：严禁字符串拼接 SQL，必须使用参数化查询或 ORM
2. **分页必须**：所有列表查询必须分页
3. **复杂查询用 XML**：列表/多表查询必须用 Mapper XML，不在 Java 代码中硬编码
4. **索引优化**：新增字段或查询条件时，评估索引需求
5. **敏感脱敏**：日志中避免打印完整的敏感数据（如 password、token）

## SQL 编写规范

### DDL（表结构定义）

- 使用统一的字段命名规范（如 snake_case）
- 合理设置 NOT NULL、DEFAULT、UNIQUE 约束
- 关键查询字段必须有索引
- 时间戳字段应使用 `created_at`, `updated_at`
- 文本字段应明确指定字符集和排序规则

### DML（数据操作）

- 使用 MyBatis/JPA 等 ORM，禁止拼接 SQL
- 列表查询必须包含 LIMIT offset, count
- UPDATE/DELETE 操作必须有明确的 WHERE 条件（防止全表操作）
- 批量操作考虑性能影响，适当分批处理

### 查询优化

- 避免 SELECT *，明确指定需要的列
- 使用 EXPLAIN PLAN 分析复杂查询的执行计划
- 避免在查询中使用函数操作索引列
- 合理使用 JOIN 而不是子查询（在大数据量场景）

## 代码审查检查表

- [ ] **拼接检查**：是否存在字符串拼接 SQL？
- [ ] **分页检查**：列表查询是否都加了 LIMIT？
- [ ] **参数化**：是否使用了 ? 或命名参数？
- [ ] **日志脱敏**：日志中是否打印了敏感信息？
- [ ] **事务处理**：多表操作是否在同一事务内？
- [ ] **错误处理**：是否妥善捕获和处理数据库异常？

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
