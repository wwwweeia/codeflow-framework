---
title: 一、框架概述
description: h-codeflow-framework 定位、核心理念与设计原则
prev: false
next:
  text: 二、架构设计
  link: /design/architecture
---

# 一、框架概述

> 本章节详细阐述框架的内部设计与实现原理。如果你是首次了解 HCodeFlow，建议先阅读 [概念详解](/getting-started/concepts)。

| 章节 | 内容 |
|------|------|
| [二、架构设计](/design/architecture) | 目录结构、编排层/执行层、被管理文件清单 |
| [三、Stub Marker](/design/marker) | Marker 机制原理、升级/收割流程 |
| [四、工作流体系](/design/workflow) | 四种工作流的路由规则与阶段定义 |
| [五、新项目接入指南](/design/integration) | init-project.sh 工作原理 |
| [六、更新与维护](/design/maintenance) | upgrade.sh / harvest.sh 双向同步 |
| [七、团队协作](/design/collaboration) | 框架迭代工作流 |
| [八、核心工具参考](/design/tools) | 脚本参数、行为、退出码 |

---

## 1.1 定位

h-codeflow-framework 是一个**元框架项目**（不是应用项目），为公司所有业务项目提供统一的 **Spec-Driven Development (SDD)** 工作流规范、Agent 定义、质量检查规则和知识库。多个下游业务项目通过 `upgrade.sh` 从本仓库同步框架文件，确保所有接入项目遵循一致的协作标准。

![架构总览](/assets/diagrams/architecture-v2.drawio.png)

## 1.2 核心理念

**三铁律**：

| 铁律 | 含义 | 约束 |
|------|------|------|
| **No Spec, No Code** | 未形成清晰 Spec 前，禁止进入代码实现 | 所有功能变更必须先产出需求/设计文档 |
| **Spec is Truth** | Spec 是需求和实现的唯一真相源 | 发现 Spec 与代码不一致时，先修 Spec 再改代码 |
| **No Approval, No Execute** | 未得到明确批准，禁止执行高风险操作 | 每个阶段产出物需用户确认后才进入下一阶段 |

**七角色**：

![七角色协作](/assets/diagrams/agent-collaboration-v2.drawio.png)

**四工作流**：

| 模式 | 适用场景 | Spec 级别 | 流程 |
|------|---------|----------|------|
| **Q0 轻量** | 单文件改动、bug fix | 简要确认 | 你 → AI 直接改 |
| **A 纯后端** | API / 数据库 / 后端逻辑 | 01 + 02(后端) | PM → Arch → Dev → QA |
| **B 纯前端** | 页面 / 组件 / 交互 | 01 + 02(前端) | PM → Arch → FE → QA |
| **C 全栈** | 前后端联动 | 01 + 02(全) | PM → Arch → Dev+FE → QA |

![工作流路由](/assets/diagrams/workflow-routing-v2.drawio.png)

## 1.3 两层分离架构

框架与业务项目是**同级目录**，通过相对路径引用脚本（`../h-codeflow-framework/tools/upgrade.sh`），零外部依赖：

- **编排层**（`core/`）：通用的工作流定义，由框架脚本管理，版本化发布
- **执行层**（各项目 `.claude/`）：项目特有的业务规则、知识库、记忆，框架升级时自动保留 marker 下方内容

## 1.4 四种文件类型

| 类型 | 管理方式 | 框架触碰 | 示例 |
|------|---------|---------|------|
| **被管理文件** | `upgrade.sh` 自动更新（含 stub marker） | marker 上方 | `agents/*.md`、`rules/project_rule.md` |
| **模板文件** | 初始化时复制到项目，之后独立维护 | 仅 init 时 | `CLAUDE.md`、`coding_backend.md` |
| **子项目脚手架** | init 时按类型（前端/后端）自动生成 | 仅 init 时 | 子项目 `.claude/context/`、`.claude/rules/` |
| **项目自定义** | 项目团队完全自主创建和维护 | 从不 | `specs/`、`codemap/`、`project-memory/` |
