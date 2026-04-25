<div align="center">

# CodeFlow Framework

**确定性优先的 AI 开发框架**

用结构化规范把不确定性消除在执行之前

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Docs-online-brightgreen)](https://wwwweeia.github.io/codeflow-framework/)
[![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)](.github/workflows/deploy-docs.yml)

[English](#overview) · [快速开始](#-快速开始) · [完整文档](https://wwwweeia.github.io/codeflow-framework/) · [架构设计](https://wwwweeia.github.io/codeflow-framework/design/overview)

</div>

---

## Overview

CodeFlow is a **meta-framework** that standardizes AI-assisted software development across multiple projects. It provides:

- **7 Agent Roles** — PM, Architect, Dev, FE, QA, Prototype, E2E — each with clear responsibilities
- **Stub Marker Mechanism** — framework files sync to projects while preserving project customizations
- **Bidirectional Sync** — push framework updates to projects, harvest validated improvements back
- **Spec-Driven Development (SDD)** — structured workflow that enforces "No Spec, No Code"

Designed for teams using Claude Code who need consistency, traceability, and quality assurance across projects.

## 🎯 核心理念

**三铁律**：
1. **No Spec, No Code** — 未形成清晰的 Spec 前，不进入代码实现
2. **Spec is Truth** — Spec 是需求和实现的唯一真相源
3. **No Approval, No Execute** — 未得到明确批准，不执行高风险操作

**七角色协作**：

```
PM（需求） → Architect（设计） → Dev/FE（实现） → QA（验证）← 主会话（调度）
                                                      Prototype（原型）/ E2E（端到端）按需触发
```

**四工作流**：

| 工作流 | 适用场景 | 链路 |
|--------|----------|------|
| Q0 轻量模式 | 单文件改动 / bug fix | 直接编码 |
| 工作流 A | 纯后端 API / 数据库变更 | PM → Arch → Dev → QA |
| 工作流 B | 纯前端页面 / 组件开发 | PM → Arch → FE → QA |
| 工作流 C | 前后端联动（新增业务实体） | PM → Arch → Dev + FE → QA |

## 📦 项目结构

```
codeflow-framework/
├── core/                      # 通用编排层（源）
│   ├── agents/                # 7 个 Agent 定义
│   ├── rules/                 # 工作流规则与合并检查清单
│   ├── skills/                # 知识库技能（18 个）
│   ├── commands/              # Slash 命令
│   └── context/               # 上下文文件
│
├── tools/                     # 核心工具链
│   ├── upgrade.sh             # 框架升级（framework → 项目）
│   ├── harvest.sh             # 变更收割（项目 → framework）
│   ├── release.sh             # 发版脚本（tag + push + 可选通知）
│   ├── doctor.sh              # 环境诊断
│   └── VERSION                # 框架版本
│
├── templates/                 # 项目初始化模板
│   ├── init-project.sh        # 一键初始化脚本
│   └── *.template             # 各类模板文件
│
├── docs/                      # VitePress 文档站
│   ├── guide/                 # 入门指南
│   ├── design/                # 架构详述（9 个章节）
│   └── reference/             # 参考手册（自动生成）
│
└── demo/                      # AI Prompt Lab 演示项目（FastAPI + Vue 3）
```

## 🚀 快速开始

### 初始化新项目

```bash
cd new-project
sh ../codeflow-framework/templates/init-project.sh . "Project Name"
```

脚本会自动创建 `.claude/` 目录结构、复制框架文件（含 marker）、输出初始化清单。

### 现有项目接入

参考 [快速入门](https://wwwweeia.github.io/codeflow-framework/guide/quick-start) 和 [项目接入检查清单](https://wwwweeia.github.io/codeflow-framework/guide/onboarding)。

### 升级框架文件

```bash
cd project
bash ../codeflow-framework/tools/upgrade.sh      # 升级
bash ../codeflow-framework/tools/upgrade.sh --dry-run  # 预览变更
```

## 🔄 Stub Marker 机制

框架管理的文件包含 marker 行：

```markdown
<!-- codeflow-framework:core v2.1.0-20260423 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
```

- **marker 上方**：框架管理内容，升级时自动更新
- **marker 下方**：项目自定义内容，升级时完整保留

这实现了**框架与项目双向扩展**：框架统一更新核心规则，项目自由扩展业务特有内容。

## 🛠️ 核心工具

| 工具 | 方向 | 用途 |
|------|------|------|
| `upgrade.sh` | framework → 项目 | 同步框架内容到下游项目 |
| `harvest.sh` | 项目 → framework | 收割项目中验证过的改进回框架 |
| `release.sh` | — | 创建 tag、推送、可选通知 |
| `doctor.sh` | — | 环境诊断，检查依赖是否就绪 |
| `init-project.sh` | — | 一键初始化新项目 |

## 📚 文档

| 文档 | 说明 |
|------|------|
| [快速入门](https://wwwweeia.github.io/codeflow-framework/guide/quick-start) | 5+15+30 分钟从零到上手 |
| [概念速查表](https://wwwweeia.github.io/codeflow-framework/guide/concepts) | 一页纸核心概念 |
| [架构详述](https://wwwweeia.github.io/codeflow-framework/design/overview) | 9 章节完整架构参考 |
| [Agents 参考](https://wwwweeia.github.io/codeflow-framework/reference/agents) | 7 个 Agent 角色定义 |
| [更新日志](https://wwwweeia.github.io/codeflow-framework/reference/changelog) | 版本更新历史 |

本地预览文档站：

```bash
cd docs && npm install && npm run docs:dev
```

## 🤝 贡献

欢迎贡献！详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 📝 许可证

[MIT License](LICENSE)
