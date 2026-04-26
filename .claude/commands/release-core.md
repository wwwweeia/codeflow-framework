---
description: 发布框架新版本：更新版本号、CHANGELOG，提交并发送飞书通知
allowed-tools: Bash(cat:*), Bash(git status:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(bash *release.sh:*)
argument-hint: [version]
---

# 发布框架新版本

执行完整的框架发版流程：版本号管理 → CHANGELOG 更新 → Git 提交 → 飞书通知。

## 参数

用户传入的参数：$ARGUMENTS

- 可直接传入版本号（如 `1.8.0`），省略日期部分，日期自动补充为今天
- 不传参数时，根据变更内容建议版本号

## 前置检查

**开始前确认工作区干净**：

```bash
git status
```

若 `core/`、`tools/`、`templates/` 下仍有未提交的变更，提示用户先提交这些内容，再执行发版流程。

## 流程

### 1. 确认当前版本

```bash
cat tools/VERSION
```

展示当前版本号，如 `1.7.0-20260420`。

### 2. 确定新版本号

**优先使用用户传入的 `$ARGUMENTS`**，拼上今天日期：
- 用户传 `1.8.0` → 新版本 `1.8.0-YYYYMMDD`（YYYYMMDD 为今天）

**未传参数时**，询问用户本次变更类型并建议版本号：

| 变更类型 | 示例 | 说明 |
|----------|------|------|
| MAJOR | `2.0.0-YYYYMMDD` | 不向后兼容的破坏性变更 |
| MINOR | `1.8.0-YYYYMMDD` | 新增功能，向后兼容 |
| PATCH | `1.7.1-YYYYMMDD` | Bug 修复、小优化 |

> **同一天多次发版**：只需递增版本号（如 `1.7.1` → `1.7.2`），日期相同完全没问题。

确认版本号后继续。

### 3. 更新 tools/VERSION

将新版本号写入 `tools/VERSION`（仅版本号，无空行）。

### 4. 更新 CHANGELOG.md

先确定变更范围，找到上一个版本 tag 并列出上次发版以来的所有提交：

```bash
# 找到上一个版本 tag
git tag -l 'v*' --sort=-version:refname | head -1

# 列出上次发版以来的所有提交（替换 <TAG> 为上一步输出的 tag）
git log <TAG>..HEAD --oneline
```

> 如果没有上一个 tag，使用 `git log --oneline -30` 并人工判断边界。

根据 `git log <TAG>..HEAD --oneline` 的输出，归纳本次变更，在 `CHANGELOG.md` **顶部**（`# CHANGELOG` 标题下方、上一个版本条目前）插入新版本记录，格式：

```markdown
## [X.Y.Z-YYYYMMDD] - YYYY-MM-DD

### 新增

**功能名称**
- 具体变更描述

### 优化

**功能名称**
- 具体变更描述

### 变更（如有破坏性变更时使用）

**影响范围**
- 具体变更描述

---
```

### 5. 提交版本变更

```bash
git add tools/VERSION CHANGELOG.md
git commit -m "chore(release): 发布 vX.Y.Z-YYYYMMDD"
```

### 6. 预览飞书通知

```bash
bash tools/release.sh
```

展示通知卡片预览，请用户确认内容是否正确。

### 7. 发送通知

用户确认无误后执行：

```bash
bash tools/release.sh --confirm
```

发版完成，告知用户下游项目可执行 `sh ../h-codeflow-framework/tools/upgrade.sh` 升级。

## 约束

- 工作区不干净（有未提交变更）时，**不得**跳过前置检查直接发版
- `release.sh` 会自动拦截 dev 版本（含 `-dev` 标记），无需手动处理
- CHANGELOG 必须在 `git commit` **之前**写好，否则 `release.sh` 校验失败

<!-- h-codeflow-framework:core v1.7.0-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
