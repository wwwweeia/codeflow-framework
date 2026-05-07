---
title: 工具速查
description: 日常使用中会用到的所有工具和命令，一行命令快速上手
prev:
  text: 设计理念
  link: /getting-started/philosophy
next:
  text: 动手练习
  link: /getting-started/exercises
---

# 工具速查

> 面向日常使用者，只讲"什么时候用 / 怎么用"。
> 完整参数和原理见 [架构详述 → 核心工具参考](/design/tools)。

---

## Shell 脚本

### `init-project.sh` — 初始化新项目

**什么时候用**：新项目首次接入框架

```bash
cd my-project
bash ../h-codeflow-framework/templates/init-project.sh . "项目名称"
```

自动创建 `.claude/` 目录结构、复制框架文件、检测并初始化前后端子项目。

### `upgrade.sh` — 升级框架文件

**什么时候用**：框架发布新版本后，同步到项目

```bash
cd my-project

# 先预览，不写入
bash ../h-codeflow-framework/tools/upgrade.sh --dry-run

# 正式升级
bash ../h-codeflow-framework/tools/upgrade.sh

# 看详细变更
bash ../h-codeflow-framework/tools/upgrade.sh --diff

# 指定实验分支
FRAMEWORK_BRANCH=exp/xxx bash ../h-codeflow-framework/tools/upgrade.sh
```

**核心保证**：marker 下方的项目自定义内容永远不会被覆盖。

### `harvest.sh` — 收割下游改进

**什么时候用**：在下游项目中验证过的改进，需要沉淀回框架

```bash
cd h-codeflow-framework

# 先看 diff
bash tools/harvest.sh ../your-project

# 确认后写入
bash tools/harvest.sh --apply ../your-project
```

### `release.sh` — 发版通知

**什么时候用**：框架变更需要发布新版本

```bash
# 预览通知内容（不发）
bash tools/release.sh

# 正式发送飞书群通知
bash tools/release.sh --confirm
```

发版前必须：更新 `tools/VERSION` + 在 `CHANGELOG.md` 顶部添加记录。

### `doctor.sh` — 环境诊断

**什么时候用**：新团队接入或命令报错时

```bash
bash tools/doctor.sh              # 完整检查
bash tools/doctor.sh --quiet      # 只显示问题项
bash tools/doctor.sh --json       # CI 集成
```

---

## Claude Code 命令

在 Claude Code 对话中输入 `/命令名` 触发。命令定义在 `.claude/commands/` 目录，通过 `upgrade.sh` 自动同步。

### `/commit` — 结构化提交

```bash
/commit              # 自动分析变更，生成 conventional commit
/commit feat: 新增XX  # 指定提交信息
```

自动分析 `git diff`，生成带上下文的提交信息。

### `/fix` — 快速 Bug 修复

```bash
/fix                  # 跳过完整 Intake，直接定位修复
```

轻量流程：跳过三问，进入结构化根因分析 → 微型 Spec → 修复。

### `/deploy` — 快速部署

```bash
/deploy               # 自动检测项目类型，构建推送
```

非阻塞，自动执行澄清 → 构建 → 推送镜像。服务器端由 Watchtower 异步拉取。

### `/onboard <模块名>` — 模块快速上手

```bash
/onboard user-management
```

AI 自动扫描代码，输出：架构概览、核心文件、数据流、常见坑点。

### `/push-all` — 一键推送

```bash
/push-all             # 暂存 + 提交 + 推送
```

自动检查敏感文件，跳过 `.env` 等。谨慎使用。

### `/spec-status` — Spec 状态总览

```bash
/spec-status          # 扫描所有 Spec 目录，输出状态
```

查看哪些 Feature 在进行中、哪些已完成。

### `/memory` — 更新项目记忆

```bash
/memory               # 回顾本次会话决策，更新长期记忆
```

将关键决策、踩坑经验写入 `project-memory/`，下次对话自动加载。

### `/upgrade-core` — 框架升级快捷命令

```bash
/upgrade-core                  # 执行升级
/upgrade-core --dry-run        # 预览
/upgrade-core --diff           # 显示详细变更
```

等价于手动执行 `upgrade.sh`，但在对话中一键完成。
