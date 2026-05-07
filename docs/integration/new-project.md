---
title: 新项目接入
description: 将 HCodeFlow 接入到你的业务项目 — 无论项目是否已有代码
prev: false
next:
  text: 已有项目
  link: /integration/existing-project
---

# 新项目接入

> "新项目" = 还没有接入 HCodeFlow 的项目。
> 无论你的项目是全新创建还是已有代码，只要还没用过 HCodeFlow，都从这里开始。

**适用场景**：
- 全新项目（还没有写代码）
- 已有项目但还没用 HCodeFlow
- 已有项目想从其他 AI 编码工作流切换过来

---

## 前置条件

```bash
# 1. Clone 框架仓库
git clone git@github.com:wwwweeia/codeflow-framework.git

# 2. 确认 Claude Code 已安装
# 参考 https://code.claude.com/docs/zh-CN/quickstart

# 3. 确认目录结构：框架和项目在同一层级
```

```
workspace/
├── h-codeflow-framework/    ← 框架仓库
└── your-project/            ← 你的业务项目
```

::: tip
如果你的业务项目还没有 Git 仓库，先 `mkdir your-project && cd your-project && git init`。
:::

---

## Step 1：环境检查（2 分钟）

```bash
cd h-codeflow-framework
bash tools/doctor.sh
```

看到全部 `[OK]` 即可。有 `[FAIL]` 按提示安装缺失依赖（常见：bash、git、python3）。

---

## Step 2：一键初始化（3 分钟）

在你的业务项目目录执行：

```bash
cd your-project
bash ../h-codeflow-framework/templates/init-project.sh . "项目名称"
```

**脚本会自动**：
1. 创建 `.claude/` 目录结构（7 个子目录）
2. 复制框架管理文件（13+ 个，含版本标记 Marker）
3. 复制项目模板（CLAUDE.md、编码规范等）
4. 检测子项目（前端/后端）并生成脚手架
5. 生成 `.claude/setup-checklist.md`（初始化配置清单）

**验证**：

```bash
# 确认目录结构
ls -la .claude/{agents,rules,skills,context,specs,codemap,project-memory}

# 确认被管理文件数量（应该 ≥13）
grep -rl "h-codeflow-framework:core" .claude/ | wc -l
```

---

## Step 3：完成项目配置（10 分钟）

在项目目录启动 Claude Code 会话：

```bash
cd your-project
claude
```

然后输入 `/init-setup`。

AI 会读取 `.claude/setup-checklist.md`，展示 3 个阶段的进度概览，让你选择从哪个阶段开始。

配置分 3 个阶段，建议分阶段、分会话完成：

| 阶段 | 任务 | 主题 | 说明 |
|------|------|------|------|
| **P1 基础** | T1, T2 | 项目能跑起来 | 全部必需，首次必须完成 |
| **P2 领域** | T3, T4, T5 | AI 理解你的代码 | 代码扫描类 |
| **P3 集成** | T6, T7, T8, T9 | 可选增强 | 全部 optional，按需 |

### P1 基础（必需）

#### T1：填写 CLAUDE.md

AI 会自动扫描项目结构，帮你生成 CLAUDE.md 的草稿。你需要补充：
- 项目概述（业务背景、目标）
- 子项目结构（各子目录说明）
- 技术栈（语言、框架、数据库）
- 技术约束（部署环境、特殊依赖）

**验证标准**：让一个不了解项目的人读完 CLAUDE.md 后，能说清楚项目是做什么的。

#### T2：执行框架升级

确认框架文件同步到最新版本。AI 会先用 `--dry-run --diff` 预览变更，你确认后执行。

### P2 领域（建议完成）

#### T3：填充业务词典

编辑 `.claude/skills/domain-ontology/SKILL.md`（**只改 Marker 下方**），补充：
- 核心实体（用户、订单、渠道等）
- 术语定义（行业中容易混淆的概念）
- 实体关系（A 属于 B，C 引用 D）

**验证标准**：PM Agent 产出 Spec 时，能正确使用业务术语。

#### T4：自定义编码规范（按需）

AI 会采样源文件检测代码风格，生成编码规范草稿。你确认后写入 `.claude/rules/` 下的规范文件。

#### T5：生成 Domain Codemap（可选）

AI 会采样源文件检测代码风格，生成编码规范草稿。你确认后写入 `.claude/rules/` 下的规范文件。

如果你在接入一个**已有代码**的项目，强烈建议为核心业务域生成代码地图（Codemap）：
- AI 会扫描项目源码，按业务域生成 `.claude/codemap/domains/domain-<业务域>.md`
- Codemap 记录已有代码的分层结构、调用链、数据结构，是后续 Feature 开发的导航索引
- 新项目（还没写代码）可以跳过，后续 Feature 开发时 arch-agent 会按需生成

### P3 集成（按需）

- **T6**：MCP 集成（Jira/Confluence 等，可跳过）
- **T7**：子项目上下文增强

  T7 会额外扫描代码中可沉淀的知识场景：
  - 对于**已有代码**的项目：AI 检测外部集成、补偿模式、复杂交互等场景，建议创建 cookbook（实操指南）
  - **新项目**可以跳过，后续 Feature 开发时 Agent 会按 knowledge-protocol 自动沉淀

- **T8**：确认 Spec 目录结构（仅说明，无需填写）
- **T9**：E2E 测试基础设施（Playwright，可跳过）

### 管理配置进度

```bash
/init-setup              # 展示阶段概览，选择从哪个阶段开始
/init-setup --status     # 查看当前进度（按阶段分组）
/init-setup --phase 2    # 直接跳到指定阶段
/init-setup --skip T6    # 跳过不需要的任务
```

::: warning
建议**分阶段、分会话**完成配置。每个阶段完成后，`/init-setup` 会提示你是否 `/clear` 开始新会话。
分阶段执行能保持每个会话的注意力聚焦，进度保存在 checklist 文件中，断点续做不会丢失。

全部配置完成后，**务必在项目目录启动一个新的 Claude 会话**（`cd your-project && claude`），再进入 Step 4。
:::

---

## Step 4：跑一个 Q0 验证（5 分钟）

::: tip
如果你刚完成 [快速入门](/getting-started/quick-start)，这一步已经验证过了，可以跳到 Step 5。
:::

在新会话中，给一个简单需求测试：

```
帮我在首页加一个"Hello Codeflow"的欢迎文字
```

**确认清单**：
- [ ] AI 执行了 Intake 三问
- [ ] AI 判断为 Q0 轻量模式
- [ ] 你审批后 AI 才改代码
- [ ] 修改完成，功能正常

---

## Step 5：跑一个正式工作流（可选）

给一个真实需求（新 API / 新页面 / 全栈功能），确认完整流程。完整体验见 [端到端教程](/getting-started/tutorial)。
- [ ] AI 正确路由到 A/B/C 工作流
- [ ] PM 产出 01，你审批
- [ ] Arch 产出 02，你审批
- [ ] Dev/FE 实现，QA 审查
- [ ] Spec 链完整（01 → 02 → 03 → evidences）

---

## Step 6：提交并通知团队

```bash
git add .claude/ CLAUDE.md
git commit -m "chore: init h-codeflow framework"
```

**团队同步要点**：
- 确保 `.claude/` 目录被 Git 追踪
- 分享 [快速入门](/getting-started/quick-start) 给团队成员
- 提醒：Marker 上方的内容不要手动改（改了也会被 upgrade 覆盖）

---

## 如果遇到问题

| 问题 | 去哪里 |
|------|--------|
| 初始化脚本报错 | [故障排查 → 初始化](/getting-started/troubleshooting) |
| AI 不走 Intake 流程 | [故障排查 → 工作流](/getting-started/troubleshooting) |
| 不知道怎么填 CLAUDE.md | [端到端教程](/getting-started/tutorial) 有示例 |
| 更多问题 | [常见问题](/getting-started/faq) |

---

## 下一步

- **日常使用** → [已有项目管理](/integration/existing-project)
- **团队培训** → [团队接入指南](/integration/team-onboarding)
- **深入理解** → [概念详解](/getting-started/concepts)
