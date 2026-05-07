---
title: 二、架构设计
description: 框架整体架构、目录结构与文件管理
prev:
  text: 一、框架概述
  link: /design/overview
next:
  text: 三、Stub Marker
  link: /design/marker
---

# 二、架构设计

## 2.1 整体架构

![架构总览](/assets/diagrams/architecture-v2.drawio.png)

```
gitlab.huaun.com/rd.huaun/
│
├── h-codeflow-framework/          ★ 框架项目（编排层源）
│   ├── core/                          通用编排文件
│   ├── tools/                         升级脚本
│   ├── templates/                     初始化模板
│   └── docs/                          框架文档
│
├── ai-lingzhi/                        ★ 业务项目 A
│   ├── CLAUDE.md                      项目协作指南
│   ├── .claude/                       执行层（被管理 + 项目自定义）
│   ├── <后端子项目>/
│   │   └── .claude/                   子项目执行层（后端脚手架）
│   └── <前端子项目>/
│       └── .claude/                   子项目执行层（前端脚手架）
│
└── project-x/                         ★ 业务项目 N
    ├── CLAUDE.md
    ├── .claude/
    └── <子项目>/
        └── .claude/
```

**关键关系**：框架项目与业务项目是**同级目录**，通过相对路径引用脚本（`../h-codeflow-framework/tools/upgrade.sh`），零外部依赖。

## 2.2 编排层目录结构

```
h-codeflow-framework/
├── core/
│   ├── agents/                     7 个 Agent 定义
│   │   ├── pm-agent.md             产品经理：需求结构化 → Spec
│   │   ├── arch-agent.md           架构师：代码调研 → 技术设计
│   │   ├── dev-agent.md            后端开发：编码 + 自测 + 流转 QA
│   │   ├── fe-agent.md             前端开发：编码 + API 对接 + 自测
│   │   ├── qa-agent.md             质量审查：独立 Review + PASS/FAIL
│   │   ├── prototype-agent.md      前端原型：根据 PM Spec 产出可运行原型
│   │   └── e2e-runner.md           E2E 测试：自动化端到端测试执行
│   │
│   ├── commands/                   自定义命令（用户通过 /命令名 触发）
│   │   ├── commit.md               结构化 Git 提交
│   │   ├── deploy.md               部署触发
│   │   ├── fix.md                  快速 bug 修复（Q0 轻量）
│   │   ├── memory.md               记忆管理
│   │   ├── onboard.md              模块快速上手
│   │   ├── push-all.md             暂存+提交+推送
│   │   ├── spec-status.md          Spec 状态查看
│   │   └── upgrade-core.md         框架升级快捷命令
│   │
│   ├── rules/                      工作流规则
│   │   ├── iron-rules.md           框架铁律（所有 Agent 共享的 6 条硬约束）
│   │   ├── project_rule.md         全栈协作调度规则（Intake + 路由 + 验证）
│   │   ├── merge_checklist.md      合并前检查清单（通用 + 后端 + 前端 + 全栈）
│   │   ├── framework_protection.md 框架保护规则（公司级 vs 项目级判断）
│   │   └── knowledge-protocol.md   知识加载协议
│   │
│   ├── skills/                     知识库与工具（24 Skills）
│   │   ├── domain-ontology/        业务词典与领域建模骨架
│   │   ├── sdd-riper-one-light/    Q0 轻量 Spec-Driven 协议
│   │   ├── spec-templates/         Spec 文档模板（渐进式：SKILL.md + 4 个 references）
│   │   ├── sql-checker/            SQL 审查规则
│   │   ├── api-reviewer/           REST API 设计规范
│   │   ├── backend-rules/          后端编码规范（硬规则 + 知识索引）
│   │   ├── frontend-conventions/   前端编码规范（渐进式：SKILL.md + 6 个 references）
│   │   ├── frontend-arch-design/   前端架构设计
│   │   ├── frontend-ui-design/     前端 UI 设计（渐进式：SKILL.md + 6 个 references）
│   │   ├── frontend-create-component/  前端组件创建
│   │   ├── frontend-create-module/     前端模块创建
│   │   ├── frontend-prototype/     前端原型
│   │   ├── frontend-api-integration/   前端 API 对接
│   │   ├── e2e-testing/            E2E 测试（Playwright）
│   │   ├── dev-workflow-common/    Dev/FE 共享工作流步骤
│   │   ├── self-test-checklist/    Dev/FE 两阶段自查清单
│   │   ├── part-e-templates/       Part E 测试场景模板
│   │   ├── qa-review-framework/    QA 审查框架（四/五轴定义）
│   │   ├── jira-task-management/   Jira 任务管理集成
│   │   ├── confluence-doc-sync/    Confluence 文档同步
│   │   ├── framework-feedback/     框架反馈提交（含 submit-feedback.sh）
│   │   └── using-git-worktrees/    Git Worktree 使用指南
│   │
│   ├── codemap/                    代码地图
│   │   └── domains/
│   │       └── HOWTO-generate-codemap.md  Codemap 生成指南
│   │
│   └── context/                    上下文文件
│       ├── branches.md             Git 分支策略
│       ├── codemap-template.md     Codemap 文档模板
│       ├── codemap-vs-specs.md     Codemap 与 Specs 的关系说明
│       ├── coding_backend_shared.md    后端共享编码规范
│       └── coding_frontend_shared.md   前端共享编码规范
│
├── tools/
│   ├── upgrade.sh                  框架升级脚本（framework → 下游）
│   ├── harvest.sh                  变更收割脚本（下游 → framework）
│   ├── release.sh                  发版通知脚本
│   ├── doctor.sh                   环境诊断工具（检查依赖是否就绪）
│   └── VERSION                     版本号：1.10.0-20260422
│
├── templates/
│   ├── init-project.sh             一键初始化脚本（含子项目自动检测）
│   ├── init-subproject.sh          子项目独立初始化脚本
│   ├── CLAUDE.md.template          项目协作指南模板
│   ├── coding_backend.md.template  后端编码规范模板（复制到根 .claude/rules/）
│   ├── coding_frontend_shared.md.template  前端编码规范模板（复制到根 .claude/rules/）
│   ├── domain-ontology.md.template 业务词典模板
│   ├── memory.md.template          协作记忆索引模板
│   ├── mcp-config.json.template    MCP Server 配置模板（Jira/Confluence）
│   └── subproject/                 子项目模板
│       ├── frontend/               前端子项目脚手架模板
│       │   ├── context/            组件清单、路由、状态管理
│       │   ├── rules/              前端编码规则（引用根目录共享规范）
│       │   └── project-memory/     协作记忆
│       └── backend/                后端子项目脚手架模板
│           ├── context/            技术栈、API 约定、场景索引
│           ├── rules/              后端编码规则（引用根目录共享规范）+ scenarios/
│           └── project-memory/     协作记忆
│
├── notify/
│   └── notify-release.py           飞书发版通知（构建卡片消息 + 发送）
│
└── docs/
    └── (文档站)
```

### 三层知识架构

框架内部采用三层分离的知识组织，控制每次任务的上下文占用：

```
┌─────────────────────────────────────────────┐
│  铁律层 (iron-rules.md)                      │
│  6 条不可违反的硬约束，所有 Agent 共享        │
│  ~20 行 | 始终加载                           │
├─────────────────────────────────────────────┤
│  骨架层 (agents/*.md)                        │
│  角色身份 + 特有红线 + 工作流骨架             │
│  每 Agent 50-75 行 | 始终加载                │
├─────────────────────────────────────────────┤
│  知识层 (skills/*/)                          │
│  公共工作流 + 自查清单 + 审查框架 + 领域知识   │
│  按需加载 | 渐进式读取（SKILL.md + refs/）    │
└─────────────────────────────────────────────┘
```

- **铁律层**：通过 `iron-rules.md` 集中管理，Agent 文件一行引用
- **骨架层**：每个 Agent 仅保留角色身份和行为红线，公共步骤提取为 Skill
- **知识层**：大型 Skill 采用渐进式结构（`SKILL.md` 核心索引 + `references/` 详细参考），按工作流类型选择性加载

## 2.3 执行层目录结构

业务项目接入框架后，`.claude/` 目录的完整结构：

```
项目根目录/
├── CLAUDE.md                          项目协作指南（基于模板，项目自定义）
└── .claude/
    ├── agents/                        ← 被 upgrade.sh 管理
    │   ├── pm-agent.md
    │   ├── arch-agent.md
    │   ├── dev-agent.md
    │   ├── fe-agent.md
    │   ├── qa-agent.md
    │   ├── prototype-agent.md
    │   └── e2e-runner.md
    │
    ├── commands/                      ← 被 upgrade.sh 管理
    │   ├── commit.md
    │   ├── deploy.md
    │   ├── fix.md
    │   ├── memory.md
    │   ├── onboard.md
    │   ├── push-all.md
    │   ├── spec-status.md
    │   └── upgrade-core.md
    │
    ├── rules/                         ← 部分被管理，部分项目自定义
    │   ├── iron-rules.md              被管理（框架铁律，所有 Agent 共享）
    │   ├── project_rule.md            被管理（marker 下方可扩展项目规则）
    │   ├── merge_checklist.md         被管理
    │   ├── framework_protection.md    被管理
    │   ├── knowledge-protocol.md      被管理
    │   ├── coding_backend.md          项目自定义（后端编码规范）
    │   └── coding_frontend.md         项目自定义（前端编码规范）
    │
    ├── skills/                        ← 部分被管理，部分项目自定义
    │   ├── domain-ontology/SKILL.md   被管理（骨架）+ 项目自定义（业务词典）
    │   ├── sdd-riper-one-light/       被管理
    │   ├── spec-templates/            被管理（渐进式：SKILL.md + references/）
    │   ├── sql-checker/               被管理
    │   ├── api-reviewer/              被管理
    │   ├── backend-rules/             被管理
    │   ├── frontend-conventions/      被管理（渐进式：SKILL.md + references/）
    │   ├── frontend-arch-design/      被管理
    │   ├── frontend-ui-design/        被管理（渐进式：SKILL.md + references/）
    │   ├── frontend-create-component/ 被管理
    │   ├── frontend-create-module/    被管理
    │   ├── frontend-prototype/        被管理
    │   ├── frontend-api-integration/  被管理
    │   ├── e2e-testing/               被管理
    │   ├── dev-workflow-common/       被管理（Dev/FE 共享工作流）
    │   ├── self-test-checklist/       被管理（Dev/FE 两阶段自查）
    │   ├── part-e-templates/          被管理（Part E 测试场景模板）
    │   ├── qa-review-framework/       被管理（QA 审查框架）
    │   ├── jira-task-management/      被管理
    │   ├── confluence-doc-sync/       被管理
    │   ├── framework-feedback/        被管理（含 submit-feedback.sh）
    │   └── using-git-worktrees/       被管理
    │
    ├── codemap/                       ← 部分被管理，部分项目自定义
    │   └── domains/
    │       └── HOWTO-generate-codemap.md  被管理
    │
    ├── context/                       ← 部分被管理，部分项目自定义
    │   ├── branches.md                被管理
    │   ├── codemap-template.md        被管理
    │   ├── codemap-vs-specs.md        被管理
    │   ├── coding_backend_shared.md   项目自定义
    │   └── coding_frontend_shared.md  项目自定义
    │
    ├── specs/                         ← 项目自定义（功能 Spec 目录）
    │   └── YYYY-MM-DD_hh-mm_<feature>/
    │       ├── 01_requirement.md
    │       ├── 02_technical_design.md
    │       ├── 03_impl_backend.md
    │       ├── 03_impl_frontend.md
    │       └── evidences/
    │
    └── project-memory/                ← 项目自定义（协作记忆）
        └── MEMORY.md
```

## 2.4 子项目执行层结构

对于包含多个前端/后端子项目的 monorepo，每个子项目拥有独立的 `.claude/` 目录。这些文件是**一次性脚手架**，由 `init-project.sh` 自动检测生成或通过 `init-subproject.sh` 手动创建，之后由项目团队独立维护。

**前端子项目**（通过 `package.json` 自动识别）：

```
<前端子项目>/
└── .claude/
    ├── context/
    │   ├── components.md          组件清单（含 AI 行为指令，可自动填充）
    │   ├── routes.md              路由结构
    │   └── stores.md              状态管理
    ├── rules/
    │   └── frontend_coding.md     引用根目录共享规范 + 子项目特有规则
    └── project-memory/
        └── MEMORY.md              子项目协作记忆
```

**后端子项目**（通过 `pom.xml` / `build.gradle` 自动识别）：

```
<后端子项目>/
└── .claude/
    ├── context/
    │   ├── tech-stack.md          技术栈（含 AI 行为指令，可自动填充）
    │   ├── api-conventions.md     API 约定
    │   └── scenario-index.md      场景规则索引
    ├── rules/
    │   ├── coding_backend.md      引用根目录共享规范 + 子项目特有规则
    │   └── scenarios/             场景化规则目录（预留）
    └── project-memory/
        └── MEMORY.md              子项目协作记忆
```

**规则引用模式**：子项目的编码规则采用轻量引用，指向根目录 `.claude/rules/` 下的共享规范，自身仅存放子项目特有的补充约束。

```markdown
# Frontend Coding Rules (h-kg-claw 特有规则)

> 共享编码规范见根目录 `.claude/rules/coding_frontend_shared.md`，本文件仅记录 h-kg-claw 子应用的特有约束。

## 项目特有规则
[子项目特有的编码约束...]
```

**AI 行为指令模式**：context 文件内嵌 HTML 注释形式的 AI 行为指令，Agent 首次使用时可根据指令自动扫描项目并填充内容。

```markdown
<!--
[AI Behavior Instruction]
如果本文件为空或不完整：
1. 扫描 components/ 目录下的 .vue 文件
2. 按子目录分组，记录每个组件的名称和职责
-->
```

> **关键设计决策**：子项目 `.claude/` 文件不包含框架 marker，`upgrade.sh` 不会触碰它们。这些文件是项目特有的上下文（组件清单、技术栈、场景规则），需要团队根据实际情况维护。

## 2.5 被管理文件清单

| 文件路径 | 框架源 | 说明 |
|---------|--------|------|
| **Agents（7）** | | |
| `.claude/agents/pm-agent.md` | `core/agents/` | 产品经理 Agent |
| `.claude/agents/arch-agent.md` | `core/agents/` | 架构师 Agent |
| `.claude/agents/dev-agent.md` | `core/agents/` | 后端开发 Agent |
| `.claude/agents/fe-agent.md` | `core/agents/` | 前端开发 Agent |
| `.claude/agents/qa-agent.md` | `core/agents/` | QA Agent |
| `.claude/agents/prototype-agent.md` | `core/agents/` | 前端原型 Agent |
| `.claude/agents/e2e-runner.md` | `core/agents/` | E2E 测试 Agent |
| **Commands（8）** | | |
| `.claude/commands/commit.md` | `core/commands/` | 结构化 Git 提交 |
| `.claude/commands/deploy.md` | `core/commands/` | 部署触发 |
| `.claude/commands/fix.md` | `core/commands/` | 快速 bug 修复 |
| `.claude/commands/memory.md` | `core/commands/` | 记忆管理 |
| `.claude/commands/onboard.md` | `core/commands/` | 模块快速上手 |
| `.claude/commands/push-all.md` | `core/commands/` | 暂存+提交+推送 |
| `.claude/commands/spec-status.md` | `core/commands/` | Spec 状态查看 |
| `.claude/commands/upgrade-core.md` | `core/commands/` | 框架升级快捷命令 |
| **Rules（4）** | | |
| `.claude/rules/iron-rules.md` | `core/rules/` | 框架铁律（所有 Agent 共享） |
| `.claude/rules/project_rule.md` | `core/rules/` | 工作流调度规则 |
| `.claude/rules/merge_checklist.md` | `core/rules/` | 合并检查清单 |
| `.claude/rules/framework_protection.md` | `core/rules/` | 框架保护规则 |
| **Skills（24）** | | |
| `.claude/skills/domain-ontology/SKILL.md` | `core/skills/` | 业务词典骨架 |
| `.claude/skills/sdd-riper-one-light/SKILL.md` | `core/skills/` | 轻量流程协议 |
| `.claude/skills/spec-templates/SKILL.md` | `core/skills/` | Spec 文档模板（渐进式） |
| `.claude/skills/sql-checker/SKILL.md` | `core/skills/` | SQL 审查规则 |
| `.claude/skills/api-reviewer/SKILL.md` | `core/skills/` | API 设计规范 |
| `.claude/skills/backend-rules/SKILL.md` | `core/skills/` | 后端编码规范 |
| `.claude/skills/frontend-conventions/SKILL.md` | `core/skills/` | 前端编码规范（渐进式） |
| `.claude/skills/frontend-arch-design/SKILL.md` | `core/skills/` | 前端架构设计 |
| `.claude/skills/frontend-ui-design/SKILL.md` | `core/skills/` | 前端 UI 设计（渐进式） |
| `.claude/skills/frontend-create-component/SKILL.md` | `core/skills/` | 前端组件创建 |
| `.claude/skills/frontend-create-module/SKILL.md` | `core/skills/` | 前端模块创建 |
| `.claude/skills/frontend-prototype/SKILL.md` | `core/skills/` | 前端原型 |
| `.claude/skills/frontend-api-integration/SKILL.md` | `core/skills/` | 前端 API 对接 |
| `.claude/skills/e2e-testing/SKILL.md` | `core/skills/` | E2E 测试 |
| `.claude/skills/dev-workflow-common/SKILL.md` | `core/skills/` | Dev/FE 共享工作流 |
| `.claude/skills/self-test-checklist/SKILL.md` | `core/skills/` | Dev/FE 两阶段自查 |
| `.claude/skills/part-e-templates/SKILL.md` | `core/skills/` | Part E 测试场景模板 |
| `.claude/skills/qa-review-framework/SKILL.md` | `core/skills/` | QA 审查框架 |
| `.claude/skills/jira-task-management/SKILL.md` | `core/skills/` | Jira 任务管理 |
| `.claude/skills/confluence-doc-sync/SKILL.md` | `core/skills/` | Confluence 文档同步 |
| `.claude/skills/framework-feedback/SKILL.md` | `core/skills/` | 框架反馈提交 |
| `.claude/skills/using-git-worktrees/SKILL.md` | `core/skills/` | Git Worktree 使用指南 |
| **Context（4）** | | |
| `.claude/context/branches.md` | `core/context/` | 分支策略 |
| `.claude/context/codemap-template.md` | `core/context/` | Codemap 文档模板 |
| `.claude/context/codemap-vs-specs.md` | `core/context/` | Codemap 与 Specs 关系 |
| `.claude/context/coding_frontend_shared.md` | `core/context/` | 前端共享编码规范 |
| **Codemap（1）** | | |
| `.claude/codemap/domains/HOWTO-generate-codemap.md` | `core/codemap/` | Codemap 生成指南 |
