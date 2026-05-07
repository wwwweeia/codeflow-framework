---
title: 端到端教程
description: 30 分钟走完一个完整 Feature，从需求到代码合并
prev:
  text: 快速入门
  link: /getting-started/quick-start
next:
  text: 概念详解
  link: /getting-started/concepts
---

# 30 分钟教程：从需求到交付

> 跟着本教程，你将用 HCodeFlow 完成一个真实 Feature 的完整流程。
> 从"提出需求"到"代码合并"，体验 SDD 工作流的全链路。

---

## 前置条件

本教程假设你已经完成了 [快速入门](/getting-started/quick-start)（15 分钟），项目已初始化、CLAUDE.md 已配置。

快速确认：

```bash
# 项目已接入 HCodeFlow
ls .claude/agents .claude/rules .claude/skills
```

> 如果还没有初始化，先去 [快速入门](/getting-started/quick-start) 完成 Step 1-3。

---

## 第 1 步：提一个需求（5 分钟）

在项目目录启动一个新的 Claude 会话（`claude`），输入一个具体需求：

```
给用户列表页增加一个搜索功能，支持按用户名和邮箱搜索
```

**预期交互**：AI 会问你三个问题（Intake 三问）：

```
🎯 目标：要做什么？
   → 在用户列表页增加搜索框，支持按用户名和邮箱模糊搜索

🚧 边界：什么不做？
   → 不改搜索结果排序逻辑，不加高级筛选，不动后端分页

✅ 验收：怎么算完成？
   → 输入关键词后实时过滤列表，空搜索显示全部用户
```

回答完三问后，AI 会根据复杂度自动判断走哪个工作流。这个需求涉及前后端联动，会被路由到 **Workflow C（全栈工作流）**。

::: info
如果你给的是简单需求（如"改个按钮文字"），AI 会自动走 **Q0 轻量模式**，不需要走完整流程。
:::

---

## 第 2 步：Review Spec 并审批（5 分钟）

AI 会自动调度 PM Agent 和 Architect Agent 产出两份文档：

### Spec 01 — 需求文档（PM 产出）

AI 会展示类似这样的内容：

```markdown
## 需求：用户列表搜索功能

### 目标
在用户列表页顶部增加搜索栏，支持按用户名和邮箱进行模糊搜索。

### 功能点
1. 搜索输入框，支持实时搜索（输入即过滤）
2. 搜索维度：用户名 OR 邮箱
3. 空搜索时显示全部用户
4. 搜索结果高亮匹配文字

### 不做的事
- 不做高级筛选（日期、状态等）
- 不改现有排序逻辑
- 不改后端分页方案
```

**你的动作**：阅读确认，有问题就指出，没问题就回复"通过"。

### Spec 02 — 技术设计（Architect 产出）

```markdown
## 技术设计：用户列表搜索功能

### 后端改动
- GET /api/users 新增 query 参数：keyword
- UserService.search(keyword) 新增搜索方法
- 使用 LIKE 模糊查询，搜索 username 和 email 字段

### 前端改动
- UserList.vue 顶部增加 SearchBar 组件
- 使用 watch 监听输入，debounce 300ms
- 搜索结果高亮匹配文字

### 影响范围
- 后端：UserController, UserService, UserMapper
- 前端：UserList.vue, 新增 SearchBar.vue
```

**你的动作**：审查技术方案，确认后回复"通过审批"。

> 💡 **审批是你在 SDD 工作流中最重要的环节**。认真看 Spec，这是你控制质量的关键。

---

## 第 3 步：观察 AI 实现 + Review（10 分钟）

审批通过后，AI 会自动进入实现阶段：

1. **Dev Agent** 实现后端代码（Controller / Service / Mapper）
2. **FE Agent** 实现前端代码（SearchBar 组件 / UserList 改造）
3. **QA Agent** 审查代码质量和规范遵从度

整个过程中，你只需要**观察和等待**。AI 会在完成后给你看结果。

**AI 完成后会展示**：
- 修改了哪些文件
- 每个文件的变更摘要
- QA 审查结论（PASS / 有问题）

**你的动作**：确认结果，回复"确认合并"或提出修改意见。

---

## 你刚刚体验了什么？

回顾整个过程：

```
需求 ──→ Intake(三问) ──→ Spec 01(PM) ──→ Spec 02(Arch) ──→ 你审批
                                                              │
  合并 ←── 你确认 ←── QA审查 ←── AI写代码(Dev/FE) ←──────────┘
```

这就是 **SDD 工作流的核心循环**：

| 你做了什么 | AI 做了什么 |
|-----------|------------|
| 描述需求 | 澄清需求（Intake 三问） |
| 回答三问 | 判断工作流（Q0/A/B/C） |
| 审批 Spec | PM 写需求文档、Arch 写技术设计 |
| 确认结果 | Dev/FE 写代码、QA 审查 |

**你的角色从"写代码"变成了"做决策"。**

---

## 常见问题

### Q: AI 没有走 Intake 三问，直接开始写代码了？

可能是需求太简单被路由到了 Q0 模式，或者是新会话 AI 还没加载项目规则。试试在需求前加上："请先走 Intake 流程"。

### Q: Spec 审批时发现有遗漏怎么办？

直接告诉 AI 要补充什么。比如："验收标准里需要加上搜索结果的排序保持不变"。AI 会更新 Spec 后再让你审批。

### Q: 可以跳过某个 Agent 吗？

一般不需要。但如果确实想简化，可以在审批 Spec 时说明。比如："这个需求前端很简单，不需要 Prototype"。

---

## 下一步

- **想深入理解每一步的原理？** → [概念详解](/getting-started/concepts)
- **完善项目的领域配置？** → [新项目接入](/integration/new-project) Step 3
- **更多练习？** → [动手练习手册](/getting-started/exercises)
