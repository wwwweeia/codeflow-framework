---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification
---

# Using Git Worktrees

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

## 本项目约定

- Worktree 目录：`.worktrees/`（已加入 .gitignore）
- 工作流 C 分支命名：
  - 后端 worktree：`.worktrees/feature-<name>-backend`，分支 `feature/<name>-backend`
  - 前端 worktree：`.worktrees/feature-<name>-frontend`，分支 `feature/<name>-frontend`
- 两个 worktree 完成后，由主会话合并到 `feature/<name>` 再推 develop
- 本项目无自动化测试基线，跳过 Verify Clean Baseline 步骤，直接报告 worktree 就绪

## Safety Verification

创建 worktree 前，**必须验证目录已被 .gitignore 忽略**：

```bash
git check-ignore -q .worktrees 2>/dev/null
```

**如果未忽略**：先加入 .gitignore 并提交，再创建 worktree。

## Creation Steps

### 1. Create Worktree

```bash
# 后端 worktree（工作流 C）
git worktree add .worktrees/feature-<name>-backend -b feature/<name>-backend
cd .worktrees/feature-<name>-backend/ai-kg-agent-hub

# 前端 worktree（工作流 C）
git worktree add .worktrees/feature-<name>-frontend -b feature/<name>-frontend
cd .worktrees/feature-<name>-frontend/<目标App目录>
```

### 2. Run Project Setup（仅前端 worktree）

前端 worktree 需要在**目标 App 目录**（非根目录）安装依赖：

```bash
cd .worktrees/feature-<name>-frontend/<目标App目录>
npm install
```

后端 worktree 无需额外 setup（Maven 构建时自动下载依赖）。

### 3. Report Location

```
Worktree ready at <full-path>
Ready to implement <feature-name>
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| `.worktrees/` 不存在 | 创建目录（已在 .gitignore 中） |
| 目录未被 .gitignore 忽略 | 先加入 .gitignore + commit |
| 前端 worktree | 在目标 App 目录跑 npm install |
| 后端 worktree | 无需 setup，直接开始 |
| QA 打回后需重建 | 重新 `git worktree add`，基于 feature/<name> 最新代码 |

## Common Mistakes

### 前端在根目录跑 npm install

- **问题**：monorepo 根目录无 package.json 或安装了错误依赖
- **修正**：必须 cd 到具体 App 目录（如 `h-kg-agent-center/`）再 npm install

### 忘记验证 .gitignore

- **问题**：worktree 内容被 git 跟踪，污染 git status
- **修正**：创建前先 `git check-ignore -q .worktrees`

## Integration

**Called by:**
- **dev-agent** (工作流 C) - REQUIRED before executing backend tasks in parallel
- **fe-agent** (工作流 C) - REQUIRED before executing frontend tasks in parallel
<!-- codeflow-framework:core v1.9.0-20260421 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
