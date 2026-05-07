---
name: backend-rules
description: 后端开发知识库，包含本项目特有的代码模板、内部 API 速查和项目约定。
  Use when writing or reviewing Java code, creating Service/Mapper classes, or debugging backend issues.
argument-hint: "[optional: class name or feature]"
allowed-tools: [Read, Grep, Glob]
---

# 后端开发知识库 (Backend Knowledge Base)

> **按需加载**：本文件是核心速查。按需读取 `templates/` 和 `references/` 获取详细内容。
> 通用语言/框架知识由 AI 自行掌握，不在此赘述。仅记录**项目特有**的约定和模式。

## 加载引导

- **必加载场景**：Dev/QA Agent 涉及后端代码时
- **可跳过场景**：纯前端任务

## 知识索引

| 层级 | 目录 | 内容 |
|------|------|------|
| 代码模板 | `templates/` | Controller / Service / Mapper 标准模板 |
| API 参考 | `references/` | ORM 配置约定等项目特有配置 |
| 核心速查 | 本文件 marker 下方 | 高频代码片段（统一响应对象、异常、分页等） |

## 硬规则

> 硬规则定义在后端项目的 `.claude/rules/coding_backend.md`，AI 必须遵守。本 Skill 不重复列举。

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
