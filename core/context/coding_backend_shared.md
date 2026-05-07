# 后端编码硬规则 (Backend Coding Rules)

> **这是硬约束**：Claude 必须严格遵守，违反即视为 Bug。
> 本文件是**指令规则**，属于 Claude 的认知约束。
> marker 上方为通用 Java / Spring Boot 编码规范，适用于任何同技术栈项目；marker 下方为项目特有约定。

---

## 1. 分层与职责 (Architecture & Responsibilities)

### 1.1 Controller 层
- 只做参数接收、鉴权、调用 Service、统一返回 `R`
- 入参必须使用 `@Valid` 或显式校验
- **严禁直接调用 Mapper/XML**

### 1.2 Service 层
- 负责核心业务编排、事务边界与一致性保证
- `@Transactional` **仅允许**放在 Service 层
- 双写场景（如数据库+Redis/消息队列）必须定义补偿路径
- **禁止返回语义不明的 `null`**，应抛出明确异常或返回空集合/Optional

### 1.3 Mapper/XML 层
- 简单 CRUD 优先使用 MyBatis-Plus 提供的方法
- 列表查询、分页查询、复杂多表关联**必须使用 XML 编写 SQL**
- **严禁使用字符串拼接的方式构造 SQL**（防止 SQL 注入）

---

## 2. 数据库规范

### 2.1 表设计
- 表名全小写，下划线分隔，建议带业务前缀
- 必须包含审计字段：`create_time`, `update_time`, `create_uname`, `update_uname`
- 字符集统一使用 `utf8mb4`

### 2.2 Entity 定义
- 主键使用 `@TableId(type = IdType.ASSIGN_ID)` 雪花算法
- **禁止使用基本数据类型**（用 Long 替代 long）

### 2.3 分页
- **所有列表接口必须分页**，严禁无界查询
- 配合 MyBatis-Plus 的 `Page<T>` 实现物理分页

---

## 3. 安全规则 (Security)

### 3.1 绝对禁止
- 严禁在日志中打印密钥、Token、用户密码、完整请求体/响应体
- 接口鉴权严禁降级放行
- 禁止在 Java 代码中手动拼接 SQL 字符串

### 3.2 必须执行
- 外部 URL 必须做协议与白名单校验（防止 SSRF）
- 关键权限变更、密钥重置、核心任务执行**必须记录审计日志**

---

## 4. 性能与一致性

- **禁止在循环中调用 Mapper** — 改为批量查询（`IN` 语句）+ 内存组装
- 定时任务、状态同步等后台逻辑必须具备：**可重试、可观测、可回溯**
- 流式处理场景下，**不得将大对象完整落盘或写入日志**
- 双写场景（数据库 + Redis/消息队列）必须定义补偿路径或对账机制

---

## 5. API 规范

### 5.1 返回格式
- 统一使用 `R` 包装对象（包含 `code`, `message`, `data`, `detail`）

### 5.2 异常处理
- 不要在 Controller 中手动 try-catch
- 直接抛出 `CommonException("错误信息")`，由全局处理器转换

---

## 6. 可观测性

- 统一使用 `@Slf4j`，**禁止 `System.out.println`**
- 错误日志必须包含：请求标识、业务主键、外部调用目标
- 定时任务和外部调用记录成功/失败计数与耗时
- 日志中密钥、Token、密码必须脱敏

---

## 7. 测试要求

- 核心逻辑变更至少包含对应的单元测试或集成测试
- 优先覆盖：参数校验失败、鉴权失败、超时/失败、事务回滚、分页边界

---

## 8. Git 与提交

### 8.1 分支规范
- `feature/<description>` - 新功能
- `fix/<issue>` - Bug 修复
- `refactor/<scope>` - 重构

### 8.2 提交规范
- 使用 conventional commits 格式：`feat:`, `fix:`, `refactor:`, `docs:`
- 提交信息应简洁描述变更内容

### 8.3 禁止操作
- 禁止直接推送 `develop` / `main`
- 禁止 force push
- 禁止绕过 Git Hooks

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
