---
title: 五、新项目接入指南
description: 一键初始化、子项目自动检测与接入后配置
prev:
  text: 四、工作流体系
  link: /design/workflow
next:
  text: 六、更新与维护
  link: /design/maintenance
---

# 五、新项目接入指南

## 5.1 前置条件

- 框架仓库已 clone 到本地，与业务项目同级目录
- 业务项目已初始化 Git 仓库
- 项目结构清晰（后端/前端子目录已建立）

```
ai/                              ← 同级目录
├── codeflow-framework/    ← 框架（已 clone）
└── my-new-project/              ← 业务项目
```

## 5.2 一键初始化

```bash
cd my-new-project
sh ../codeflow-framework/templates/init-project.sh . "My Project"
```

脚本自动完成：

| 步骤 | 操作 | 产出 |
|------|------|------|
| 1 | 创建 `.claude/` 完整目录结构 | `agents/`、`rules/`、`skills/`、`context/`、`specs/`、`codemap/`、`project-memory/` |
| 2 | 复制框架被管理文件（含 marker） | 13 个被管理文件 |
| 3 | 复制模板文件并替换项目名称 | `CLAUDE.md`、共享编码规范等 |
| 4 | 复制共享编码规范到根 `.claude/rules/` | `coding_frontend_shared.md`、`coding_backend.md` |
| 5 | **自动检测子项目并初始化** | 按类型生成子项目 `.claude/` 脚手架 |
| 6 | 生成初始化配置清单 | `.claude/setup-checklist.md` |

**子项目自动检测规则**：

| 检测条件 | 识别类型 | 生成的脚手架 |
|---------|---------|------------|
| 子目录含 `package.json` | 前端 (fe) | context（组件/路由/状态管理）+ rules + project-memory |
| 子目录含 `pom.xml` 或 `build.gradle` | 后端 (be) | context（技术栈/API约定/场景索引）+ rules + scenarios + project-memory |
| 子目录已有 `.claude/` | 跳过 | 不覆盖已有配置 |
| 隐藏目录（`.`开头） | 跳过 | — |

**初始化日志示例**（ai-crawlers 项目，含 3 个前端 + 1 个后端子项目）：

```
[OK]  目录结构已创建（7 个子目录）
[OK]  已复制 13 个框架文件（含 marker）
[OK]  已创建 CLAUDE.md + 共享编码规范
[OK]  已初始化 4 个子项目（3 fe + 1 be）
✓ 框架文件已初始化
```

脚本完成后会在 `.claude/setup-checklist.md` 生成结构化的初始化清单，终端输出引导提示：

```
✓ 初始化清单已生成：.claude/setup-checklist.md

下一步：在新会话中执行 /init-setup 或说「继续初始化」
         AI 将逐步自动完成项目配置（能检测的自动填，需要输入的主动问）
```

**幂等性**：重复执行时，已初始化的子项目自动跳过，不会覆盖。

## 5.3 初始化后的必要配置

初始化完成后，在 Claude Code 中说「继续初始化」，AI 会自动驱动 `/init-setup` 命令逐步完成配置：

| 任务 | AI 自动做 | 需用户提供 |
|------|----------|-----------|
| T1 填充 CLAUDE.md | 扫描技术栈和目录结构，生成草稿 | 项目定位、团队信息、部署环境 |
| T2 填充业务词典 | 扫描 Entity/Model/API 提取术语 | 中文名、业务规则 |
| T3 配置 MCP | 检查文件状态 | Jira/Confluence 凭据 |
| T4 自定义编码规范 | 采样代码检测风格 | 确认或补充约定 |
| T5 执行 upgrade.sh | 检查框架版本 | 确认执行 |
| T6 完善子项目上下文 | 扫描路由/组件/API | 确认结果 |

**详细的任务验证标准，参见 [项目接入检查清单](/guide/onboarding)。**

手动添加新子项目（初始化时未检测到的）：

```bash
sh ../codeflow-framework/templates/init-subproject.sh ./new-frontend-app fe "My Project"
sh ../codeflow-framework/templates/init-subproject.sh ./new-backend-service be "My Project"
```

## 5.4 接入验证清单

初始化并配置完成后的验证步骤，详见 [项目接入检查清单](/guide/onboarding) Phase 3。

## 5.5 完整操作示例

```bash
# 1. 进入项目目录（框架仓库需在同级目录）
cd my-new-project && git init

# 2. 一键初始化（自动检测并初始化子项目）
sh ../codeflow-framework/templates/init-project.sh . "My New Project"

# 3. 验证结构 + 升级脚本可用
ls -la .claude/{agents,rules,skills,context,specs,codemap,project-memory}
sh ../codeflow-framework/tools/upgrade.sh

# 4. 编辑项目配置（CLAUDE.md、业务词典、编码规范...）
# 5. 提交
git add . && git commit -m "chore: init codeflow framework structure"
```
