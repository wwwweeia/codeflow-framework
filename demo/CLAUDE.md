# AI Prompt Lab 协作指南

> 本文件为项目级别的 Claude Code 协作约定。

## 项目概述

**AI Prompt Lab** 是一个 [项目类型] 项目。

| 维度 | 说明 |
|------|------|
| 技术栈 | [Java/Vue/Python etc.] |
| 主要模块 | [module1, module2, ...] |
| 开发团队 | [team member names] |
| 部署环境 | [dev/staging/prod] |

## 核心协作规则

> 遵循 h-codeflow-framework 定义的全栈协作规则。

### 三铁律

1. **No Spec, No Code** — 未形成清晰的 Spec 前，不进入代码实现
2. **Spec is Truth** — Spec 是需求和实现的唯一真相源
3. **No Approval, No Execute** — 未得到明确批准，不执行高风险操作

### 工作流规范

- **轻量改动**（Q0）：单文件修改、小 bug 修复、配置变更 → 直接编码
- **纯后端**（工作流 A）：新增/修改 API、数据库变更 → PM → Arch → Dev → QA
- **纯前端**（工作流 B）：页面/组件开发 → PM → Arch → FE → QA
- **前后端联动**（工作流 C）：新增业务实体 → PM → Arch → Dev + FE → QA

详见 `.claude/rules/project_rule.md`。

## 项目特定约定

### 分支策略

- 主分支：`main`（生产就绪）
- 开发分支：`develop`（集成测试）
- Feature 分支：`feature/YYYY-MM-DD_name`
- Bug 修复：`fix/YYYY-MM-DD_issue-name`

### Spec 目录

所有 Feature/Fix 的 Spec 存放于 `.claude/specs/YYYY-MM-DD_hh-mm_<name>/`

### 关键约束

[补充项目特定的技术约束、安全要求、性能指标等]

## 快速开始

1. 阅读 `.claude/rules/project_rule.md`（全栈协作规则）
2. 阅读 `.claude/skills/domain-ontology/SKILL.md`（业务术语）
3. 阅读 `CLAUDE.md`（本文件）

## 常见命令

```bash
# 更新框架文件（保留项目自定义内容）
bash ../h-codeflow-framework/tools/upgrade.sh
```

## 联系方式

[补充项目负责人、技术负责人等联系方式]

