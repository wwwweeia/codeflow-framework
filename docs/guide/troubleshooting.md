---
title: 故障排查指南
description: 按问题域分类的排查步骤和解决方案
prev:
  text: 常见问题
  link: /guide/faq
next: false
---

# 故障排查指南

> 按问题域分类，每个问题有排查步骤和解决方案。

---

## 问题域 1：初始化相关

### init-project.sh 执行失败：Permission denied

**原因**：脚本没有执行权限。

```bash
# 修复
chmod +x ../codeflow-framework/templates/init-project.sh
```

### init-project.sh 执行失败：No such file or directory

**原因**：路径不对。脚本需要在项目目录执行，框架仓库在同级目录。

```bash
# 确认目录结构
ls ../codeflow-framework/templates/init-project.sh

# 正确的执行方式
cd my-project
sh ../codeflow-framework/templates/init-project.sh . "My Project"
```

### 子项目没有被自动检测

**原因**：子目录缺少标识文件。

框架通过以下文件识别子项目类型：
- `package.json` → 前端
- `pom.xml` 或 `build.gradle` → 后端

检查子目录是否包含这些文件。如果没有，可以手动初始化：

```bash
sh ../codeflow-framework/templates/init-subproject.sh ./my-subproject fe "My Project"
```

### CLAUDE.md 模板变量未替换

**原因**：初始化时第二个参数（项目名称）未传递或为空。

重新执行初始化，确保传递项目名称：

```bash
sh ../codeflow-framework/templates/init-project.sh . "My Project Name"
```

---

## 问题域 2：升级相关

### upgrade.sh 找不到 marker

**现象**：脚本输出 "WARNING: no marker found in xxx"。

**原因**：文件中没有 `codeflow-framework:core` 标记行。

**排查步骤**：

1. 打开被警告的文件，搜索 `codeflow-framework`
2. 如果 marker 被意外删除，从框架源文件复制 marker 行并追加到文件末尾
3. 重新执行 upgrade.sh

### marker 格式不对

**正确格式**：

```markdown
<!-- codeflow-framework:core v1.0.0-20260416 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
```

常见错误：
- 版本号格式不对（应为 `X.Y.Z-YYYYMMDD`）
- 多了空格或少了字符
- marker 不是独占一行

### 升级后 marker 下方内容丢失

**不应该发生。** 如果发生了：

1. 检查 `.claude/.backup/` 是否有升级前的备份
2. 从备份恢复：

```bash
cp -r .claude/.backup/upgrade-YYYYMMDD-HHMMSS/* .claude/
```

3. 向框架维护者报告此问题（可能是 upgrade.sh 的 bug）

### 冲突检测报告了冲突

`upgrade.sh` 在升级前会检测下游 marker 上方是否有本地修改。如果有：

| 策略 | 参数 | 适用场景 |
|------|------|---------|
| 默认 | 无 | 备份 `.local` 副本后继续覆盖，最后汇总提示 |
| 保留本地 | `--conflict=preserve` | 跳过冲突文件，保留本地修改 |
| 直接退出 | `--conflict=fail` | CI 环境，有冲突就停 |
| 强制覆盖 | `--force` | 跳过冲突检测，强制覆盖（慎用） |

---

## 问题域 3：工作流相关

### AI 不走 Intake 三问直接改代码

**原因**：`project_rule.md` 未被正确加载，或 AI 跳过了规则。

**排查步骤**：

1. 确认 `.claude/rules/project_rule.md` 存在且非空
2. 确认文件包含 Intake 触发规则章节
3. 重新启动 Claude Code 会话（重新加载规则）
4. 如果仍然跳过，在对话开头显式提醒："请按照 project_rule.md 的规则执行 Intake 三问"

### PM 产出的 Spec 质量差

**常见原因和解决方案**：

| 原因 | 解决方案 |
|------|---------|
| 业务词典为空 | 填充 `.claude/skills/domain-ontology/SKILL.md` |
| 需求描述太模糊 | Intake 三问时给出更具体的回答 |
| CLAUDE.md 缺少项目上下文 | 补充项目概述、技术栈、业务背景 |
| 没有参考已有代码结构 | 确保 CLAUDE.md 中有子项目结构说明 |

### QA 打回后流程卡住

**排查步骤**：

1. 查看 QA 的 FAIL 报告（在 evidences/ 下）
2. 根据报告中的问题，决定修复方案
3. 告诉主对话"修复 QA 发现的问题"，AI 会调度 Dev/FE 修复
4. 修复完成后 QA 会自动重新审查

### AI 加载了错误的上下文（前端任务加载后端规则或反之）

这不应该发生。如果发生：

1. 检查 `.claude/rules/project_rule.md` 中的禁止事项章节
2. 确认禁止规则存在："前端任务不加载 coding_backend.md；后端任务不加载 coding_frontend_shared.md"
3. 在对话中提醒 AI："这是前端/后端任务，请加载对应的编码规范"

---

## 问题域 4：环境相关

### Claude Code 无法启动或连接异常

1. 确认 Claude Code 已正确安装（`claude --version`）
2. 确认网络连通性
3. 确认认证有效（重新登录：`claude login`）
4. 参考 [Claude Code 官方文档](https://code.claude.com/docs/zh-CN/overview)

### doctor.sh 各检查项修复方案

| 检查项 | 修复命令 |
|--------|---------|
| bash | macOS/Linux 自带 |
| git | `brew install git` 或 `apt install git` |
| shasum/sha256sum | macOS 自带 shasum；Linux: `apt install coreutils` |
| python3 | `brew install python3` 或 `apt install python3` |
| node/npm | `brew install node` 或 `nvm install node` |
| mvn | `brew install maven` 或下载安装 |
| gh CLI | `brew install gh` |

### MCP Server 配置问题

如果使用 Jira/Confluence 集成：

1. 确认项目根目录有 `.mcp.json`
2. 确认配置格式正确（参考 `templates/mcp-config.json.template`）
3. 确认网络可以访问 Jira/Confluence 服务
4. MCP 不可用时框架**会自动降级**，不影响正常工作流

### 性能问题：AI 响应慢

可能原因：
- 上下文文件太多（检查 `.claude/` 下是否有多余的大文件）
- 项目代码量太大（Codemap 可以帮助聚焦）
- 网络延迟

优化建议：
- 保持 `domain-ontology` 精简（只放核心术语）
- 定期清理过时的 Spec 目录
- 使用 `/onboard` 聚焦到具体模块，减少全局加载

---

## 问题域 5：Windows 环境

框架工具脚本基于 bash 编写，Windows 环境需要通过 **Git for Windows** 自带的 Git Bash 运行。

### 安装 Git for Windows

1. 下载安装 [Git for Windows](https://git-scm.com/download/win)
2. 安装时建议勾选 **"Git Bash Here"**（右键菜单快捷方式）
3. 安装完成后打开 **Git Bash**（不是 CMD / PowerShell）

### 用 Git Bash 执行脚本

所有框架脚本必须在 Git Bash 中运行：

```bash
# 在 Git Bash 中操作
cd /d/my-project                    # Git Bash 用 Unix 风格路径（D: → /d/）
bash ../codeflow-framework/tools/upgrade.sh --dry-run --diff
bash ../codeflow-framework/tools/doctor.sh
```

::: tip 路径转换
Git Bash 中访问 Windows 路径：`C:\Users\xxx` → `/c/Users/xxx`
:::

### 常见问题

**脚本报 `$'\r': command not found`**

CRLF 换行符问题。框架已配置 `.gitattributes` 强制 `.sh` 文件使用 LF。如果仍然遇到：

```bash
# Git Bash 中修复
git config --global core.autocrlf input
git checkout -- *.sh
```

**`shasum` 命令找不到**

框架脚本已自动兼容 `shasum`（macOS）和 `sha256sum`（Git Bash/Linux），不需要手动处理。如果仍然报错，运行 `bash tools/doctor.sh` 查看诊断结果。

**`diff` 命令行为异常**

Git Bash 自带的 `diff` 与 GNU diff 行为一致，通常不会有问题。如果遇到差异，升级 Git for Windows 到最新版本。
