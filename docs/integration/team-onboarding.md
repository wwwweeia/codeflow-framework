---
title: 团队接入
description: 团队决定采用 HCodeFlow 时，负责人需要做的准备工作
prev:
  text: 已有项目
  link: /integration/existing-project
next: false
---

# 团队接入指南

> 当团队决定采用 HCodeFlow 时，负责人按以下步骤推进。

---

## 准备工作

### 1. 框架仓库权限

确保团队成员能访问框架仓库：

```
git@gitlab.huaun.com:rd.huaun/h-codeflow-framework.git
```

### 2. Claude Code 准备

- 每位开发者安装 [Claude Code](https://code.claude.com/docs/zh-CN/quickstart)
- 确认 Claude Code 版本与框架兼容
- 可选：配置 Claude Code 的全局设置（如编辑器集成）

### 3. 项目初始化

负责人完成 [新项目接入](/integration/new-project) 的全部步骤，确保项目可以正常运行。

---

## 团队培训路径

推荐按以下顺序推进，从快到慢、从体验到深入：

### 第 1 步：全员阅读（5 分钟）

发送以下链接给团队：

**→ [认识 SDD](/getting-started/what-is-sdd)**

确保每个人理解：
- SDD 是"先写规格再写代码"
- 工作流有 6 个步骤
- 人的角色是"审批和决策"

### 第 2 步：动手体验（15 分钟）

**→ [快速入门](/getting-started/quick-start)**

每个人在自己的环境跑通 Q0 轻量任务。

### 第 3 步：深入理解（按需）

**→ [概念详解](/getting-started/concepts)**

了解工作流全貌、七角色、Spec 体系、Marker 机制。不要求一次读完，需要时查阅即可。

### 第 4 步：端到端练习（30 分钟）

**→ [端到端教程](/getting-started/tutorial)**

每个人走完一个完整的 Feature，体验 Intake → Spec → Approval → Execute → Review → Merge 全链路。

### 第 5 步：真实任务演练

在真实业务需求中使用 HCodeFlow：
- 先选一个简单需求（纯后端 / 纯前端）
- 逐步过渡到复杂需求（全栈联动）
- 遇到问题时查阅 [故障排查](/getting-started/troubleshooting)

---

## 日常协作约定

### 需求描述

- 描述需求时尽量具体，帮助 AI 做好 Intake
- 明确"做什么"和"不做什么"
- 给出验收标准

### Spec 审批

- 审批 PM 和 Arch 的产出时要**认真看**
- 这是你影响代码质量的关键环节
- 有问题直接指出，AI 会修改后重新提交审批

### 踩坑后写规则

- AI 重复犯同样的错误 → 在编码规范中加一条规则
- 这样下次 AI 就不会再犯

### Marker 规则

提醒团队成员：
- **Marker 上方**：不要手动改（改了也会被 upgrade 覆盖）
- **Marker 下方**：随便改，永久保留

---

## 参考材料

| 内容 | 链接 | 适用场景 |
|------|------|---------|
| 认识 SDD | [5 分钟阅读](/getting-started/what-is-sdd) | 全员必读 |
| 快速入门 | [15 分钟体验](/getting-started/quick-start) | 全员必做 |
| 端到端教程 | [30 分钟练习](/getting-started/tutorial) | 全员练习 |
| 概念详解 | [随时查阅](/getting-started/concepts) | 按需 |
| 术语速查 | [术语表](/getting-started/glossary) | 遇到不认识的词时查 |
| 工具速查 | [工具](/getting-started/tools) | 需要用工具时查 |
| 常见问题 | [FAQ](/getting-started/faq) | 有疑问时查 |
| 故障排查 | [排查指南](/getting-started/troubleshooting) | 遇到问题时查 |

---

## 常见团队问题

### Q: 团队成员必须先学完整套文档吗？

**不需要。** 最低门槛是"认识 SDD + 快速入门"，20 分钟搞定。其他文档按需查阅。

### Q: 不是所有人都有 Claude Code 账号怎么办？

HCodeFlow 的核心价值在 Spec 文档和审批流程。即使不是每个人都用 Claude Code 写代码，Spec 审批环节仍然可以手动参与。

### Q: 团队有不同的技术栈怎么办？

HCodeFlow 工作流是技术栈无关的。不同技术栈的项目各自配置编码规范即可，工作流调度逻辑不需要改。

---

## 下一步

- 开始项目初始化 → [新项目接入](/integration/new-project)
- 遇到问题 → [故障排查](/getting-started/troubleshooting)
