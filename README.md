# codeflow-framework

> **全栈协作框架** — 一套完整的 Spec-Driven Development (SDD) 工作流规范和工具，用于多项目、跨团队的高效协作。

## 🎯 核心理念

**三铁律**：
1. **No Spec, No Code** — 未形成清晰的 Spec 前，不进入代码实现
2. **Spec is Truth** — Spec 是需求和实现的唯一真相源
3. **No Approval, No Execute** — 未得到明确批准，不执行高风险操作

**七角色**：PM（需求） → Architect（设计） → Dev/FE（实现） → QA（验证）← 主会话（调度）｜Prototype（原型）、E2E（端到端测试）按需触发

**四工作流**：
- **Q0 轻量模式**：单文件改动 / bug fix → 直接编码
- **工作流 A**：纯后端 API / 数据库变更
- **工作流 B**：纯前端页面 / 组件开发
- **工作流 C**：前后端联动（新增业务实体）

## 📦 项目结构

```
codeflow-framework/
├── core/                      # 通用编排层（源）
│   ├── agents/                # 7 个 Agent 定义（PM/Arch/Dev/FE/QA/Prototype/E2E）
│   ├── rules/                 # 工作流规则与合并检查清单
│   ├── skills/                # Skill 文件（domain-ontology, sdd-riper-one-light, 等）
│   └── context/               # 上下文文件（如 branches.md）
│
├── tools/                     # 工具脚本
│   ├── upgrade.sh             # 框架升级脚本（更新项目中的托管文件）
│   ├── harvest.sh             # 变更收割脚本（下游验证过的内容回框架）
│   ├── release.sh             # 发版脚本（更新版本号 + Webhook 通知）
│   ├── doctor.sh              # 环境诊断工具（检查依赖是否就绪）
│   └── VERSION                # 框架版本
│
├── templates/                 # 项目初始化模板
│   ├── init-project.sh        # 一键初始化脚本
│   ├── CLAUDE.md.template     # 项目协作指南模板
│   ├── coding_backend.md.template
│   ├── coding_frontend_shared.md.template
│   ├── domain-ontology.md.template
│   └── memory.md.template
│
├── docs/                      # VitePress 文档站
│   ├── .vitepress/             # VitePress 配置
│   ├── guide/                  # 入门指南（快速入门、概念、接入、FAQ 等）
│   ├── design/                 # 架构详述（9 个章节，拆自原 03-框架设计文档）
│   ├── reference/              # 参考手册（Agents/Skills/Commands/Rules/Changelog）
│   └── package.json            # VitePress 依赖
│
└── examples/                  # 示例项目结构
```

## 🚀 快速开始

### 初始化新项目

在新项目目录下执行：

```bash
cd new-project
sh ../codeflow-framework/templates/init-project.sh . "Project Name"
```

脚本会自动：
1. 创建 `.claude/` 目录结构
2. 复制框架的被管理文件（含 marker）
3. 复制项目模板文件并调整项目名称
4. 输出初始化清单和下一步指导

### 现有项目接入

对于已有的项目，参考 [快速入门](docs/guide/quick-start.md) 和 [项目接入检查清单](docs/guide/onboarding.md) 进行接入。

### 升级框架文件

在项目目录执行，保留项目自定义内容：

```bash
sh ../codeflow-framework/tools/upgrade.sh
```

升级脚本会：
1. 扫描项目 `.claude/` 下所有包含 `codeflow-framework:core` marker 的文件
2. 更新 marker 上方的框架内容
3. 保留 marker 下方的项目自定义内容
4. 备份原文件

## 📋 工作流概览

### 工作流 A：纯后端

```
Intake → PM → Arch → Dev → QA → 合并 + 部署
```

涉及：API 设计、数据库变更、后端业务逻辑。

### 工作流 B：纯前端

```
Intake → PM → Arch → FE → QA → 合并 + 部署
```

涉及：页面开发、组件开发、前端交互。

### 工作流 C：前后端联动

```
Intake → PM → Arch → Dev + FE → QA → 合并 + 部署
```

涉及：新增业务实体、API 变更 + 前端适配。

### Q0 轻量模式

单文件改动、小 bug 修复等，直接编码，无需多角色协同。

## 📖 核心文档

### 被管理文件（通过 upgrade.sh 同步）

| 文件 | 来源 | 说明 |
|------|------|------|
| `.claude/agents/*.md` | `core/agents/` | 7 个 Agent 定义 |
| `.claude/rules/project_rule.md` | `core/rules/` | 工作流规则 |
| `.claude/rules/merge_checklist.md` | `core/rules/` | 合并检查清单 |
| `.claude/skills/*/SKILL.md` | `core/skills/` | Skill 文件 |
| `.claude/context/branches.md` | `core/context/` | 分支策略 |

### 项目自定义文件

| 文件 | 说明 |
|------|------|
| `CLAUDE.md` | 项目协作指南（项目级） |
| `.claude/rules/coding_backend.md` | 后端编码规范（项目级） |
| `.claude/context/coding_frontend_shared.md` | 前端编码规范（项目级） |
| `.claude/skills/domain-ontology/SKILL.md` | 业务词典（项目级） |
| `.claude/project-memory/MEMORY.md` | 协作历史与记忆索引 |

## 🔄 Stub 标记与自动管理

### Marker 格式

```markdown
<!-- codeflow-framework:core v1.0.0-YYYYMMDD — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
```

### 工作原理

1. 被管理文件在第 3 行（YAML frontmatter 之后）包含 marker
2. `upgrade.sh` 扫描并更新 marker **上方**的内容
3. marker **下方**的内容由项目团队维护（自动保留）
4. 允许项目自定义扩展，无需担心升级时丢失

## 🛠️ 核心工具

### upgrade.sh

升级项目中的框架托管文件，保留项目自定义内容。

```bash
cd project
sh ../codeflow-framework/tools/upgrade.sh
```

### init-project.sh

初始化新项目的框架结构。

```bash
cd new-project
sh ../codeflow-framework/templates/init-project.sh . "Project Name"
```

### doctor.sh

环境诊断工具，一键检查框架运行所需的外部依赖是否就绪。新团队接入或遇到命令报错时运行。

```bash
# 在框架目录 — 检查基础设施
bash tools/doctor.sh

# 在项目目录 — 检查基础设施 + 项目构建工具 + 可选集成
cd project
bash ../codeflow-framework/tools/doctor.sh

# 只显示有问题的项
bash tools/doctor.sh --quiet

# JSON 格式输出（CI 集成）
bash tools/doctor.sh --json
```

检查项分三层：

| 层级 | 检查内容 | 说明 |
|------|----------|------|
| 框架基础设施 | bash, git, shasum/sha256sum, python3 | 框架脚本运行必需 |
| 项目构建工具 | node/npm/pnpm, mvn/gradle, npm scripts | 按 package.json/pom.xml 自动探测 |
| 可选集成 | gh CLI, MCP 配置 | Jira/Confluence 集成等 |

## 📚 文档

文档站基于 VitePress 搭建，本地预览：

```bash
cd docs && npm install && npm run docs:dev
```

| 文档 | 说明 |
|------|------|
| [快速入门](docs/guide/quick-start.md) | 5+15+30 分钟从零到上手 |
| [概念速查表](docs/guide/concepts.md) | 一页纸核心概念 |
| [架构详述](docs/design/overview.md) | 9 章节完整架构参考 |
| [Agents 参考](docs/reference/agents.md) | 7 个 Agent 角色定义（自动生成） |
| [更新日志](docs/reference/changelog.md) | 版本更新历史 |
| 各项目的 `CLAUDE.md` | 项目特定的协作约定 |

## 🤝 贡献与反馈

框架持续演进，欢迎：
- 问题报告：记录框架的不合理之处
- 最佳实践分享：补充项目级的成功案例
- 新工具建议：简化重复工作的新脚本

## 📝 许可证

内部使用。

---

**版本**：1.10.0-20260422 | **Maintainer**: your-name | **更新日期**：2026-04-22

