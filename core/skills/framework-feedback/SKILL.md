---
name: framework-feedback
description: 向 codeflow-framework 团队提交反馈（Bug、Feature Request、Improvement、Question）。
  Use when user wants to report a framework issue, request a feature, suggest improvements, or ask questions.
argument-hint: "[bug|feature|improvement|question]"
allowed-tools: [Bash, Read, Grep, Glob]
---

# 框架反馈技能 (Framework Feedback)

帮助用户向 codeflow-framework 团队提交结构化反馈。反馈将通过 GitHub Issue + 通知发送给框架维护团队。

> **注意**：此技能执行一次提交后立即返回结果。不重试、不循环、不追问。

## 环境配置

首次使用前，请确保下游项目已完成环境配置。参见 **[SETUP.md](./SETUP.md)**（随技能一同下发）。

快速检查：在项目目录执行 `gh issue list`，能看到 Issue 列表即环境就绪。未配置 gh 时技能仍可工作（仅发送Webhook 通知，不创建 GitHub Issue）。

## 执行流程

### 第 1 步：确认反馈类型

检查 `$ARGUMENTS` 是否包含有效的类型标签。有效值：`bug`、`feature`、`improvement`、`question`。

- 如果 `$ARGUMENTS` 包含有效类型标签，直接使用
- 如果 `$ARGUMENTS` 为空或无效，向用户展示以下选项请其选择：

| 类型 | 标签 | 适用场景 |
|------|------|---------|
| Bug | `bug` | 框架规则不符合预期、Agent 行为异常、upgrade.sh 出错 |
| Feature Request | `feature` | 新 Agent、新 Skill、新工作流、新命令 |
| Improvement | `improvement` | 现有功能的优化建议 |
| Question | `question` | 使用疑问、文档不清晰 |

如果用户输入了自然语言描述（如 "我发现一个 bug"），映射到对应标签。

### 第 2 步：自动收集上下文

无需用户手动提供，自动从当前项目提取以下信息：

**项目名称**：从 `git remote get-url origin` 提取仓库名，或读取 `package.json`/`pom.xml` 中的项目名。

**框架版本**：扫描 `.claude/` 目录下任意包含 `codeflow-framework:core` marker 的文件，从 marker 行提取版本号（格式如 `v1.8.0-20260421`）。

**组件分类**：根据用户反馈内容推断涉及的框架组件：
- `agents` — PM/Arch/Dev/FE/QA/Prototype/E2E Agent 行为
- `rules` — project_rule.md、merge_checklist.md 规则
- `skills` — 知识库（SQL审查、API规范等）
- `workflow` — Intake 确认、Spec 流程等
- `upgrade` — upgrade.sh、harvest.sh 工具链
- `other` — 其他

### 第 3 步：引导用户补充信息

根据反馈类型，向用户收集以下信息：

**所有类型必填**：
- **title**：一句话概括（AI 可从用户描述中提炼，需用户确认）
- **description**：详细描述（用户口述，AI 可帮助结构化）

**所有类型可选**：
- **priority**：low / medium / high（默认 medium，AI 可建议但由用户确认）

**Bug 类型额外字段**（如果是 bug，主动询问）：
- **reproduce_steps**：复现步骤
- **expected_behavior**：期望行为
- **actual_behavior**：实际行为

**收集提示**（引导用户理解每个字段的含义）：

```
请提供以下信息：
📝 标题：一句话概括问题（如 "dev-agent 在处理复杂查询时未生成索引检查"）
📝 描述：详细说明你遇到的情况

[如果是 Bug]
📝 复现步骤：你是怎么触发这个问题的？
📝 期望行为：你觉得应该怎样？
📝 实际行为：实际发生了什么？

优先级：low（不急）/ medium（正常）/ high（阻塞工作）
```

### 第 4 步：确认提交预览

收集完毕后，向用户展示提交预览，格式如下：

```
📋 反馈提交预览
─────────────────
类型: [Bug/Feature/Improvement/Question]
组件: [agents/rules/skills/workflow/upgrade/other]
优先级: [low/medium/high]
标题: [用户提供的标题]
项目: [自动提取的项目名]
框架版本: [自动提取的版本号]
提交者: [git user.name]
─────────────────
描述:
[用户提供的描述]
─────────────────
确认提交？(y/n)
```

用户确认后进入第 5 步。用户拒绝则退出，不提交任何内容。

### 第 5 步：执行提交

构建 JSON 并通过 stdin 传递给提交脚本：

```bash
cat <<'FEEDBACK_JSON' | bash .claude/skills/framework-feedback/scripts/submit-feedback.sh
{
  "type": "bug",
  "component": "agents",
  "priority": "high",
  "title": "用户提供的标题",
  "description": "用户提供的描述",
  "project": "自动提取的项目名",
  "framework_version": "vX.X.X-YYYYMMDD",
  "submitter": "git user.name",
  "reproduce_steps": "复现步骤（bug 时提供）",
  "expected_behavior": "期望行为（bug 时提供）",
  "actual_behavior": "实际行为（bug 时提供）"
}
FEEDBACK_JSON
```

**提交者信息**：从 `git config user.name` 获取。

### 第 6 步：报告结果

根据脚本输出的 JSON 结果向用户反馈：

- **success**：
  - 如果 `github.status` 为 `"success"`：告知用户 "反馈已提交！GitHub Issue 已创建：{github.url}，同时已发送 Webhook 通知。"
  - 如果 `github.status` 为 `"skipped"` 或 `"failed"`：告知用户 "反馈已通过 Webhook 通知发送。GitHub Issue 未创建（gh CLI 不可用），框架团队会尽快处理。"
- **failed**：展示错误信息，建议用户直接联系框架团队或通过其他渠道反馈。

## 约束

- 只执行一次提交，无论成功或失败
- 不修改用户项目中的任何文件
- 不自动重试失败的提交
- 不在反馈中包含敏感信息（密码、Token、密钥等）

<!-- codeflow-framework:core v1.9.0-20260421 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
