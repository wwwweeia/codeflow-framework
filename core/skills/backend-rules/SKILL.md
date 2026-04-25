---
name: backend-rules
description: 后端开发知识库，包含本项目特有的代码模板、内部 API 速查和项目约定。
  Use when writing or reviewing Java code, creating Service/Mapper classes, or debugging backend issues.
argument-hint: "[optional: class name or feature]"
allowed-tools: [Read, Grep, Glob]
---

# 后端开发知识库 (Backend Knowledge Base)

> 📚 **按需加载**：本文件是核心速查。按需读取 `templates/` 和 `references/` 获取详细内容。
> 通用语言/框架知识由 AI 自行掌握，不在此赘述。仅记录**项目特有**的约定和模式。

---

## 知识库结构说明

本 Skill 为后端开发提供三层知识：

### 第 1 层：代码模板索引（`templates/`）

存放项目标准代码模板，供 Dev Agent 创建新类时参考。建议至少包含：

| 模板 | 路径 | 用途 |
|------|------|------|
| Controller 模板 | `templates/controller-template.md` | 标准 REST Controller + DTO/Query/VO |
| Service 模板 | `templates/service-template.md` | Service 接口与实现 |
| Mapper XML 模板 | `templates/xml-mapper-template.md` | XML Mapper + 批量操作 |

### 第 2 层：API 参考索引（`references/`）

存放项目使用的框架/中间件的**项目特有配置约定**（通用 API 不在此列）：

| 参考 | 路径 | 用途 |
|------|------|------|
| ORM 项目配置 | `references/orm-config.md` | ORM 配置约定（分页/逻辑删除/自动填充等） |

### 第 3 层：核心速查（本文件 marker 下方）

直接写在 SKILL.md 中的高频代码片段，无需打开子文件即可查阅。建议涵盖：

- **统一响应对象**：项目统一返回值的用法（如 `R.ok()` / `Result.success()` 等）
- **常见异常**：项目自定义异常的抛出方式
- **分页约定**：分页参数命名、分页结果构建模式
- **工具类速查**：项目自定义的常用工具类及其方法
- **审计字段**：创建/更新时间、操作人的设置方式

---

## 填写指引

1. **先建骨架**：按上方索引表创建 `templates/` 和 `references/` 子目录及文件
2. **从现有代码提取**：找到项目中写得最规范的 Controller/Service/Mapper，提取为模板
3. **只记项目特有的**：通用知识（Spring Boot 注解、MyBatis 标签语法等）不需要写，AI 已掌握
4. **保持更新**：项目架构调整时（如统一响应格式变更、新增工具类），同步更新本知识库

---

## 硬规则

> 硬规则定义在后端项目的 `.claude/rules/coding_backend.md`，AI 必须遵守。本 Skill 不重复列举。

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
