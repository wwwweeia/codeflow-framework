---
title: 框架反馈
description: 向 HCodeFlow 团队提交 Bug、功能建议、改进意见或使用疑问
prev:
  text: 故障排查
  link: /getting-started/troubleshooting
next: false
---

# 框架反馈

> 使用框架时遇到问题或有改进想法？通过 `/feedback` 命令一键提交给框架团队。

---

## 支持的反馈类型

| 类型 | 触发关键词 | 适用场景 |
|------|-----------|---------|
| **Bug** | `bug` | 框架规则不符合预期、Agent 行为异常、upgrade.sh 出错 |
| **Feature Request** | `feature` | 想要新 Agent、新 Skill、新工作流、新命令 |
| **Improvement** | `improvement` | 现有功能可以更好用的地方 |
| **Question** | `question` | 使用疑问、文档看不懂的地方 |

---

## 使用方式

在 Claude Code 对话中直接输入：

```bash
# 指定类型
/feedback bug
/feedback feature

# 或者不指定，AI 会引导你选择
/feedback
```

也可以用自然语言描述问题，AI 会自动识别类型并引导你完成提交。

### 提交流程

```
你说出问题 ──→ AI 确认类型 ──→ AI 自动收集上下文 ──→ 你补充细节 ──→ 预览确认 ──→ 提交
```

**AI 会自动收集**（无需你手动提供）：

- **项目名称**：从 git 仓库自动提取
- **框架版本**：从 `.claude/` 目录下的 marker 自动读取
- **组件分类**：根据你描述的问题自动推断（agents / rules / skills / workflow / upgrade）

**你需要提供**：

- 一句话标题
- 问题或建议的详细描述
- 如果是 Bug：复现步骤、期望行为、实际行为

### 提交预览

确认前会展示预览：

```
📋 反馈提交预览
─────────────────
类型: Bug
组件: agents
优先级: medium
标题: dev-agent 在处理复杂查询时未生成索引检查
项目: your-project
框架版本: v2.1.0-20260425
提交者: zhangsan
─────────────────
描述:
Dev Agent 生成代码时没有检查数据库索引...
─────────────────
确认提交？(y/n)
```

### 投递方式

反馈通过**双通道**发送给框架团队：

| 通道 | 说明 |
|------|------|
| **GitLab Issue** | 在框架仓库创建 Issue，可追踪处理进度 |
| **飞书群通知** | 即时通知框架维护团队，卡片消息展示详情 |

### 实际效果

提交后，框架团队会同时收到 GitLab Issue 和飞书群通知：

**Bug 类型 → GitLab Issue**

自动创建结构化 Issue，包含复现步骤、期望/实际行为、来源项目与框架版本：

![GitLab Issue 示例](/assets/images/feedback-gitlab-issue.png)

**Feature Request 类型 → 飞书群通知**

即时推送卡片消息，包含类型、优先级、组件分类等关键信息：

![飞书群通知示例](/assets/images/feedback-feishu-card.png)

---

## 环境配置

反馈功能开箱即用，无需额外配置。但完整功能需要安装 glab CLI：

| 状态 | 能力 |
|------|------|
| **未安装 glab** | 只发送飞书通知，不创建 GitLab Issue |
| **已安装 glab** | 飞书通知 + GitLab Issue（推荐） |

### 安装 glab（可选）

```bash
# macOS
brew install glab

# 配置认证（二选一）
glab auth login    # 浏览器登录
glab auth login --token xxx  # Token 登录

# 验证
glab issue list    # 能看到 Issue 列表即配置成功
```

安装后，提交反馈时会自动创建 GitLab Issue 并附上链接，方便你后续追踪。

---

## 常见问题

### 提交后多久会收到回复？

框架团队会通过飞书群即时收到通知，通常在 1-2 个工作日内处理。如果创建了 GitLab Issue，你可以在 Issue 中查看处理进度。

### 反馈内容会包含我的代码吗？

不会。反馈只收集项目名称、框架版本等环境信息，不包含你的业务代码。但描述问题时请注意**不要包含敏感信息**（密码、Token、密钥等）。

### 没有安装 glab 能用吗？

完全可以。未安装 glab 时，反馈仍会通过飞书通知发送给框架团队，只是不会自动创建 GitLab Issue。

---

## 其他反馈渠道

除了 `/feedback` 命令，你也可以通过以下方式联系框架团队：

| 渠道 | 适用场景 |
|------|---------|
| `/feedback` 命令 | 日常使用中的结构化反馈（推荐） |
| 飞书群 | 即时交流、快速问答 |
| GitLab Issue | 直接在框架仓库提 Issue |

> 完整的技能定义和技术细节，参见 [参考手册 → Skills](/reference/skills#框架反馈技能-framework-feedback)。
