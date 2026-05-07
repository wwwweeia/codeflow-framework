---
title: 快速入门
description: 15 分钟极速体验 HCodeFlow，跑通你的第一个 Q0 轻量任务
prev:
  text: 认识 SDD
  link: /getting-started/what-is-sdd
next:
  text: 端到端教程
  link: /getting-started/tutorial
---

# 快速入门：15 分钟极速体验

> 适合：第一次接触 HCodeFlow 的开发者
> 目标：初始化一个项目，跑通第一个 Q0 轻量任务

---

## 你需要准备什么（3 分钟）

### 1. 框架仓库

```bash
# Clone 框架仓库
git clone git@gitlab.huaun.com:rd.huaun/h-codeflow-framework.git
```

### 2. Claude Code

已安装 [Claude Code](https://code.claude.com/docs/zh-CN/quickstart)（CLI 或 IDE 插件均可）。

### 3. 目录结构

框架仓库和你的业务项目放在同一目录下：

```
workspace/
├── h-codeflow-framework/    ← 框架仓库（刚 clone 的）
└── my-project/              ← 你的业务项目
```

::: warning
如果你的业务项目还没有 Git 仓库，先初始化：
```bash
mkdir my-project && cd my-project
git init
```
:::

---

## 跑起来（10 分钟）

### Step 1：环境检查（2 分钟）

```bash
cd h-codeflow-framework
bash tools/doctor.sh
```

全部 `[OK]` 就可以继续。有 `[FAIL]` 按提示安装缺失依赖。

### Step 2：初始化项目（3 分钟）

在业务项目目录执行：

```bash
cd my-project
bash ../h-codeflow-framework/templates/init-project.sh . "My Project"
```

看到以下输出说明初始化成功：

```
✓ 框架文件已初始化
✓ 初始化清单已生成：.claude/setup-checklist.md
```

### Step 3：完成项目配置（5 分钟）

在项目目录启动 Claude Code 会话：

```bash
cd my-project
claude
```

然后输入 `/init-setup`，AI 会引导你逐步完成配置。

配置分 3 个阶段（P1 基础 → P2 领域 → P3 集成）。Quick Start 只需完成 **P1（T1 CLAUDE.md + T2 升级）** 即可，后续阶段可以稍后执行。

```bash
/init-setup --phase 1  # 直接从 P1 基础阶段开始
/init-setup --skip T6  # 跳过不需要的配置
```

::: warning
配置完成后，**请在项目目录启动一个新的 Claude 会话**再进入 Step 4。
当前会话包含了初始化配置的上下文，新会话能让 SDD 工作流以干净的上下文启动，避免注意力稀释。
剩余阶段可随时用 `/init-setup --phase 2` 继续。完整的 P1-P3 配置说明见 [新项目接入](/integration/new-project) Step 3。
:::

### Step 4：跑一个 Q0 任务（5 分钟）

在新会话中，输入一个简单需求：

```
帮我在首页加一个"Hello Codeflow"的欢迎文字
```

你会看到 AI 执行以下步骤：

1. **Intake 三问** — AI 问你：目标是什么？边界在哪？怎么验收？
2. **判断为 Q0** — 小改动，不需要完整 Spec 流程
3. **简要确认** — AI 展示要改什么，等你同意
4. **执行修改** — 你同意后，AI 改代码
5. **完成** — 改完了，给你看结果

**这就是 Q0 轻量模式。** 从头到尾你只需要：回答三问 → 确认 → 看结果。

---

## 你刚才体验了什么（2 分钟）

刚才走的是 HCodeFlow 中最轻量的 Q0 模式：

```
需求 → Intake(三问) → AI确认方案 → 你同意 → AI改代码 → 完成
```

SDD 工作流还有更完整的模式（A/B/C），走完整的 Intake → Spec → Approval → Execute → Review → Merge 链路。

| 模式 | 适用场景 | 你刚才做的 |
|------|---------|-----------|
| **Q0 轻量** | 改文案、修 bug、调配置 | ← 刚体验的 |
| **A/B/C 正式** | 新功能、新页面、全栈联动 | 下一步 |

---

## 下一步

- **走完一个完整 Feature？** → [端到端教程](/getting-started/tutorial)（30 分钟）
- **理解为什么需要这些步骤？** → [认识 SDD](/getting-started/what-is-sdd)
- **了解所有概念？** → [概念详解](/getting-started/concepts)
- **接入到真实项目？** → [新项目接入](/integration/new-project)
