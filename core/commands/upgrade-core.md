---
description: 从框架拉取最新内容，升级当前项目的 .claude/ 托管文件
allowed-tools: Bash(bash *upgrade.sh:*), Bash(ls:*), Bash(git status:*), Bash(git diff:*)
argument-hint: [--dry-run] [--diff]
---

# 升级框架托管文件

从 h-codeflow-framework 拉取最新 core/ 内容，更新当前项目 `.claude/` 下的框架托管文件，保留 marker 下方的项目自定义内容。

## 参数

用户传入的参数：$ARGUMENTS

- `--dry-run`：仅预览变化，不写入（默认）
- `--diff`：显示详细 diff

## 工作流

### 1. 定位框架目录

按以下顺序查找 `h-codeflow-framework`：
1. `../h-codeflow-framework`（最常见的同级目录布局）
2. 用户指定的路径

找不到则提示用户手动指定框架路径。

### 2. 预览变更

**始终先 dry-run**：

```bash
bash ../h-codeflow-framework/tools/upgrade.sh --dry-run --diff
```

展示将要更新的文件列表和差异。

### 3. 确认升级

告知用户：
- 将更新哪些文件
- marker 下方的项目自定义内容会被保留
- 原文件会备份到 `.claude/.backup/`

请求用户输入 `yes` 确认后执行：

```bash
bash ../h-codeflow-framework/tools/upgrade.sh
```

### 4. 验证结果

升级完成后：

```bash
git status   # 查看变更文件
git diff     # 查看具体差异
```

展示摘要：
```
📋 升级完成，后续步骤：
1. git diff .claude/ — 确认变更内容
2. 检查 marker 下方的自定义内容是否完好
3. git add + commit
```

## 指定框架分支

如需使用实验分支（如 `exp/xxx`），提示用户：

```bash
FRAMEWORK_BRANCH=exp/xxx bash ../h-codeflow-framework/tools/upgrade.sh
```

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
