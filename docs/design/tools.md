---
title: 八、核心工具参考
description: init-project、upgrade、harvest、release 等核心工具详解
prev:
  text: 七、团队协作
  link: /design/collaboration
next:
  text: 九、附录
  link: /design/appendix
---

# 八、核心工具参考

## 8.1 init-project.sh

**用途**：初始化新项目的框架结构。

**语法**：
```bash
bash ../h-codeflow-framework/templates/init-project.sh <项目目录> "<项目名称>"
```

**参数**：

| 参数 | 必填 | 说明 |
|------|------|------|
| 项目目录 | 是 | 目标项目的根目录，通常为 `.` |
| 项目名称 | 是 | 用于模板变量替换 |

**行为**：
1. 验证参数与路径
2. 创建 `.claude/` 完整目录结构（7 个子目录）
3. 复制 `core/` 下所有被管理文件（含 marker）
4. 复制 `templates/` 下的模板文件并替换 `${PROJECT_NAME}`
5. 复制共享编码规范到根 `.claude/rules/`（`coding_frontend_shared.md`、`coding_backend.md`）
6. **自动检测子项目**：扫描子目录，根据 `package.json`（前端）或 `pom.xml`/`build.gradle`（后端）调用 `init-subproject.sh`
7. 输出初始化结果和下一步指导

**注意**：同名文件会被覆盖，已有项目建议先备份再执行。子项目已有 `.claude/` 的会被跳过。

## 8.2 init-subproject.sh

**用途**：初始化单个子项目的 `.claude/` 脚手架目录。可由 `init-project.sh` 自动调用，也可独立使用。

**语法**：
```bash
bash ../h-codeflow-framework/templates/init-subproject.sh <子项目路径> <fe|be> [项目名]
```

**参数**：

| 参数 | 必填 | 说明 |
|------|------|------|
| 子项目路径 | 是 | 子项目的目录路径 |
| 类型 | 是 | `fe`（前端）或 `be`（后端） |
| 项目名称 | 否 | 用于模板变量替换，默认为子项目目录名 |

**行为**：验证目录 → 检查幂等性（`.claude/` 已存在则跳过）→ 复制对应模板（`templates/subproject/frontend/` 或 `backend/`）→ 替换占位符 → 创建目录和文件。各类型子项目的生成结构详见 [二、架构设计](/design/architecture#_2-4-子项目执行层结构)。

**使用示例**：
```bash
# 手动初始化前端子项目
bash ../h-codeflow-framework/templates/init-subproject.sh ./my-frontend fe "My Project"

# 手动初始化后端子项目
bash ../h-codeflow-framework/templates/init-subproject.sh ./my-backend be "My Project"
```

## 8.3 upgrade.sh

**用途**：升级项目中的框架托管文件，保留项目自定义内容。

**语法**：
```bash
cd <项目目录>
bash ../h-codeflow-framework/tools/upgrade.sh

# 指定框架分支（用于试验场模式）
FRAMEWORK_BRANCH=exp/xxx bash ../h-codeflow-framework/tools/upgrade.sh
```

**前提条件**：
- 在项目根目录执行（不是框架目录）
- 框架仓库与项目为同级目录
- 项目 `.claude/` 下的文件包含正确格式的 marker

**环境变量**：

| 变量 | 说明 |
|------|------|
| `FRAMEWORK_BRANCH` | 指定框架分支（默认使用当前分支），用于拉取实验分支的内容 |

**行为**：
1. 自动定位框架 `core/` 目录
2. 如设置了 `FRAMEWORK_BRANCH`，先切换到指定分支
3. 自动 `git pull` 拉取框架最新代码
4. 扫描项目 `.claude/` 下所有包含 marker 的文件
5. 备份每个目标文件
6. 用框架源文件更新 marker 上方内容
7. 保留 marker 下方的项目自定义内容
8. 同步新增的 skills 目录
9. 输出更新结果和回滚指令

## 8.4 harvest.sh

**用途**：从下游项目收割验证过的框架变更回 `core/`（`upgrade.sh` 的逆操作）。

**语法**：
```bash
cd h-codeflow-framework
bash tools/harvest.sh [--apply] [--include-new] <下游项目目录>
```

**参数**：

| 参数 | 必填 | 说明 |
|------|------|------|
| 下游项目目录 | 是 | 目标下游项目的根目录，如 `../your-project` |
| `--apply` | 否 | 实际写入 core/（默认 dry-run 只看 diff） |
| `--include-new` | 否 | 处理下游新增的、core/ 中不存在的文件 |

**行为**：提取下游文件 marker 行及以上内容 → 更新版本号 → 与 `core/` 做 diff。默认 dry-run 只看 diff，`--apply` 才写入（自动备份到 `core/.backup/`）。工作原理和完整流程详见 [六、更新与维护](/design/maintenance#_6-4-试验场工作流双向同步)。

**使用示例**：
```bash
# 预览差异
bash tools/harvest.sh ../your-project

# 实际写入（写入前自动备份到 core/.backup/）
bash tools/harvest.sh --apply ../your-project

# 含新增文件
bash tools/harvest.sh --apply --include-new ../your-project
```

## 8.5 release.sh

**用途**：框架发版通知，校验版本号与 CHANGELOG 一致性，发送飞书群通知。

**语法**：
```bash
cd h-codeflow-framework
bash tools/release.sh            # 预览模式（dry-run）
bash tools/release.sh --confirm  # 正式发送飞书通知
```

**校验项**：
- VERSION 文件存在且不为空
- VERSION 不含 `-dev` 标记（实验版本不能发布）
- CHANGELOG.md 中存在对应版本的记录

## 8.6 VERSION

**路径**：`tools/VERSION`

**格式**：`MAJOR.MINOR.PATCH-YYYYMMDD`

**当前版本**：`1.10.0-20260422`

此文件由框架维护者在发版时更新，`upgrade.sh` 读取此文件确定框架版本。

## 8.7 doctor.sh

**用途**：环境诊断工具，一键检查框架运行所需的外部依赖是否就绪。

**语法**：
```bash
# 在框架目录 — 检查基础设施
bash tools/doctor.sh

# 在项目目录 — 检查基础设施 + 项目构建工具 + 可选集成
cd project
bash ../h-codeflow-framework/tools/doctor.sh

# 只显示有问题的项
bash tools/doctor.sh --quiet

# JSON 格式输出（CI 集成）
bash tools/doctor.sh --json
```

**检查项分三层**：

| 层级 | 检查内容 | 说明 |
|------|----------|------|
| 框架基础设施 | bash, git, shasum/sha256sum, python3 | 框架脚本运行必需 |
| 项目构建工具 | node/npm/pnpm, mvn/gradle, npm scripts | 按 package.json/pom.xml 自动探测 |
| 可选集成 | gh CLI, MCP 配置 | Jira/Confluence 集成等 |

## 8.8 Commands 系统

框架提供 8 个自定义命令，用户在 Claude Code 中通过 `/命令名` 触发：

| 命令 | 用途 |
|------|------|
| `/commit` | 结构化 Git 提交（自动分析变更、生成提交信息） |
| `/deploy` | 触发部署（构建脚本 + 推送镜像） |
| `/fix` | 快速 bug 修复（Q0 轻量模式） |
| `/memory` | 记忆管理（查看/清理项目记忆） |
| `/onboard <模块名>` | 模块快速上手（自动扫描代码、输出概览） |
| `/push-all` | 暂存所有变更 + 提交 + 推送 |
| `/spec-status` | 查看 Spec 状态（哪些 Feature 在进行中） |
| `/upgrade-core` | 框架升级快捷命令 |

这些命令定义在 `core/commands/` 目录下，通过 `upgrade.sh` 同步到项目。

## 8.9 Codemap 系统

Codemap 是项目的代码知识图谱，与 Specs 互补：

| 资产 | 定位 | 更新时机 |
|------|------|---------|
| **Codemap** | 现状导航："代码现在长什么样" | 代码结构变化时更新 |
| **Specs** | 开发档案："这个功能是怎么做的" | 每次 Feature 开发时创建 |

- 模板和关系说明：`core/context/codemap-template.md` 和 `core/context/codemap-vs-specs.md`
- 生成指南：`core/codemap/domains/HOWTO-generate-codemap.md`
- 使用 `/onboard` 命令时，AI 会优先查阅 Codemap
