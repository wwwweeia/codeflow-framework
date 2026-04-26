---
description: 从下游项目收割验证过的框架变更回 core/
allowed-tools: Bash(sh tools/harvest.sh:*), Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*)
argument-hint: <project-dir> [--apply] [--include-new]
--- 

# 收割下游项目变更

从下游项目的 `.claude/` 中提取 marker 上方的框架内容，与 `core/` 比对差异，确认后写入。

## 参数

用户传入的参数：$ARGUMENTS

- 第一个非 flag 参数为下游项目路径（必填）
- `--apply`：实际写入 core/（默认仅预览）
- `--include-new`：同时处理 core/ 中不存在的新文件

## 工作流

### 1. 预览差异

**始终先执行 dry-run**，即使用户传了 `--apply` 也先预览：

```bash
sh tools/harvest.sh <project-dir>
```

展示差异摘要给用户。

### 2. 审查清单

展示以下检查项，逐一确认：

- [ ] **无项目特有引用**：项目名（如 `ai-lingzhi`）、子项目路径、特定端口/地址
- [ ] **内容是通用的**：可被任意下游项目复用，不含硬编码业务逻辑
- [ ] **结构完整**：YAML frontmatter、章节标题、marker 行均正确

如果发现问题，明确指出哪些内容需要修改，**不要继续执行 apply**。

### 3. 确认写入

审查通过后，请求用户确认，然后执行：

```bash
sh tools/harvest.sh --apply <project-dir>
```

如需包含新文件：

```bash
sh tools/harvest.sh --apply --include-new <project-dir>
```

### 4. 后续步骤

写入完成后，提醒用户：

```
📋 收割完成，后续步骤：
1. git diff core/ — 再次确认变更内容
2. 更新 tools/VERSION（如需发版）
3. 更新 CHANGELOG.md
4. git add + commit
5. sh tools/release.sh — 预览发版
```
