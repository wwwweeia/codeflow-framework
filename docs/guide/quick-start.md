---
title: 快速入门
description: 从零到第一个 Feature，5 分钟速览 + 15 分钟动手 + 30 分钟深入
prev: false
next:
  text: 概念速查表
  link: /guide/concepts
---

# 快速入门：从零到第一个 Feature

> 适合：第一次接触 codeflow-framework 的开发者
> 预计时间：50 分钟（5 分钟速览 + 15 分钟动手 + 30 分钟深入）

---

## 前置条件

- 已安装 [Claude Code](https://code.claude.com/docs/zh-CN/quickstart)（CLI 或 IDE 插件）
- 框架仓库已 clone 到本地，与业务项目同级目录
- 基本熟悉终端操作

```
workspace/
├── codeflow-framework/    ← 框架仓库（已 clone）
└── my-project/              ← 你的业务项目
```

---

## 5 分钟速览

### 这套框架解决什么问题？

AI Coding 的核心挑战不是"让 AI 写代码"，而是**让 AI 在确定性的边界内高效执行**。这套框架通过结构化的规范和工作流，把不确定性消除在执行之前。

### 核心概念

概念速查详见 [概念速查表](/guide/concepts)，这里只需记住三句话：

1. **三铁律**：No Spec, No Code / Spec is Truth / No Approval, No Execute
2. **七角色**：PM → Arch → Dev/FE → QA，你只需要跟主对话交互，Agent 自动调度
3. **四工作流**：Q0 轻量 → A 纯后端 → B 纯前端 → C 前后端联动

### 确定性空间

```
确定性空间 = Rules + Skills + Specs + Agents + Memory
```

- **Rules**：编码硬规则，不用每次重复提醒
- **Skills**：领域知识库，按需加载
- **Specs**：Feature 的全链路文档，从需求到验证
- **Agents**：角色定义，每个 Agent 知道自己该干什么
- **Memory**：跨会话持久记忆，项目知识不丢失

---

## 15 分钟动手

### Step 1：环境检查（2 分钟）

在框架目录执行诊断工具，确认依赖就绪：

```bash
cd codeflow-framework
bash tools/doctor.sh
```

看到全部 `[OK]` 即可。如果有 `[FAIL]`，按提示安装缺失依赖。

### Step 2：初始化项目（5 分钟）

在你的业务项目目录执行一键初始化：

```bash
cd ../my-project
sh ../codeflow-framework/templates/init-project.sh . "My Project"
```

脚本会自动：
1. 创建 `.claude/` 目录结构（7 个子目录）
2. 复制框架的被管理文件（13 个，含版本标记）
3. 复制项目模板文件（CLAUDE.md、编码规范等）
4. 自动检测子项目（前端/后端）并生成脚手架
5. 生成 `.claude/setup-checklist.md`（初始化配置清单）

### Step 2.5：完成项目配置（10 分钟）

初始化完成后，打开 Claude Code，说：

```
继续初始化
```

AI 会读取 `.claude/setup-checklist.md`，逐步引导你完成配置：
- **T1**：扫描技术栈，帮你填写 `CLAUDE.md`（项目概述、团队信息）
- **T2**：扫描代码中的实体类，帮你建立业务词典
- **T3-T8**：根据初始化级别，按需配置 MCP 集成、编码规范、子项目上下文等

每个任务都是「AI 自动检测 → 展示草稿 → 你补充确认 → 写入 → 标记完成」，跨会话可恢复进度：

```
/init-setup --status   # 查看当前进度
/init-setup --skip T3  # 跳过不需要的任务
```

### Step 3：跑一个轻量任务（8 分钟）

打开 Claude Code，进入你的项目目录，输入一个简单需求：

```
帮我在首页加一个"Hello Codeflow"的欢迎文字
```

你会看到：
1. AI 执行 **Intake 三问**：目标、边界、验收标准
2. 判断为 **Q0 轻量模式**（小改动）
3. 产出简要 Spec → 你审批 → AI 执行代码修改
4. 完成后自动写回 Spec 摘要

这就是最简单的 Q0 轻量流程。你不需要了解任何 Agent 细节，只需要**审批**。

---

## 30 分钟深入

### 理解项目结构

初始化后，你的项目 `.claude/` 目录长这样：

```
.claude/
├── agents/              ← 被 upgrade.sh 管理，不要改 marker 上方
│   ├── pm-agent.md      产品经理 Agent
│   ├── arch-agent.md    架构师 Agent
│   ├── dev-agent.md     后端开发 Agent
│   ├── fe-agent.md      前端开发 Agent
│   ├── qa-agent.md      QA Agent
│   └── ...
├── rules/               ← 工作流规则
│   ├── project_rule.md  调度规则（被管理）
│   ├── merge_checklist.md  合并检查（被管理）
│   ├── coding_backend.md   后端编码规范（你的）
│   └── coding_frontend.md  前端编码规范（你的）
├── skills/              ← 知识库
│   ├── domain-ontology/ 业务词典（你要填充）
│   └── ...
├── specs/               ← Feature 文档（自动创建）
├── codemap/             ← 代码地图（自动创建）
└── project-memory/      ← 项目记忆（自动维护）
```

### Marker 机制

被管理文件包含这样的标记行：

```markdown
<!-- codeflow-framework:core v1.0.0-20260416 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
```

- **marker 上方**：框架内容，`upgrade.sh` 会更新
- **marker 下方**：你的自定义内容，**永远不会被覆盖**

### 四种工作流一览

| 工作流 | 适用场景 | 流程 |
|--------|---------|------|
| **Q0 轻量** | 单文件改动、bug fix、配置变更 | 你 → AI 直接编码 |
| **A 纯后端** | API / 数据库 / 后端逻辑 | PM → Arch → Dev → QA |
| **B 纯前端** | 页面 / 组件 / 交互 | PM → Arch → FE → QA |
| **C 全栈** | 前后端联动（新增业务实体） | PM → Arch → Dev + FE 并行 → QA |

你不需要记住哪个工作流怎么走。**AI 会根据你的需求自动判断路由**。

### 使用 /onboard 快速了解模块

对已有模块不熟悉？用 `/onboard` 命令：

```
/onboard user-management
```

AI 会自动扫描代码、梳理调用链、输出模块概览（核心文件、数据流、关键表、常见坑点）。

---

## 接下来做什么？

1. **配置 CLAUDE.md**：补充项目概述、子项目结构、技术约束
2. **填充业务词典**：编辑 `.claude/skills/domain-ontology/SKILL.md`（marker 下方）
3. **配置编码规范**：编辑 `coding_backend.md` 和 `coding_frontend.md`
4. **试一个正式工作流**：给一个真实需求，体验 PM → Arch → Dev → QA 全流程

详细配置步骤参见 [项目接入检查清单](/guide/onboarding)。

遇到问题先查 [常见问题](/guide/faq) 和 [故障排查指南](/guide/troubleshooting)。

想动手练习？参见 [动手练习手册](/guide/exercises)。
