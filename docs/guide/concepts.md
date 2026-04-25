---
title: 概念速查表
description: 一页纸速查 codeflow-framework 的核心概念
prev:
  text: 快速入门
  link: /guide/quick-start
next:
  text: 项目接入检查清单
  link: /guide/onboarding
---

# 概念速查卡

> 一页纸速查 codeflow-framework 的核心概念。

---

## 三铁律

| 铁律 | 含义 | 为什么需要 |
|------|------|-----------|
| **No Spec, No Code** | 没文档不动手 | 防止 AI 凭感觉写代码，确保想清楚再动手 |
| **Spec is Truth** | 文档是唯一真相 | 代码以 Spec 为准，不一致时先改 Spec |
| **No Approval, No Execute** | 没批准不执行 | 人掌握关键决策权，AI 不能自作主张 |

---

## 七角色

```
                    ┌─── PM Agent（需求结构化）
                    │        ↓ 产出 01_requirement.md
                    ├─── Prototype Agent（前端原型，按需）
                    │        ↓
                    ├─── Architect Agent（技术设计）
  你 ←→ 主对话 ──→  │        ↓ 产出 02_technical_design.md
  （审批）  （调度） ├─── Dev Agent（后端实现）
                    │   FE Agent（前端实现）
                    │        ↓ 产出 03_impl + 代码
                    ├─── QA Agent（独立审查）→ PASS / FAIL
                    │
                    └─── E2E Runner（端到端测试，按需）
```

你只需要跟**主对话**交互，Agent 调度全自动。

---

## 四工作流

```
需求进来
    ↓
Q0: ≤3 文件 / bug fix / 配置变更？
    ├── 是 → Q0 轻量模式（直接编码，1 个 Agent 搞定）
    └── 否 ↓
    涉及后端（API/DB）？
    ├── 否 → 只改前端？ → 工作流 B（PM → Arch → FE → QA）
    └── 是 ↓
        同时改前端？ → 工作流 C（PM → Arch → Dev + FE 并行 → QA）
        只改后端？   → 工作流 A（PM → Arch → Dev → QA）
```

---

## 确定性空间五要素

| 要素 | 是什么 | 对应位置 | 解决什么问题 |
|------|--------|---------|-------------|
| **Rules** | 编码硬规则 | `.claude/rules/` | 不用每次提醒"别用 var"、"SQL 不能拼接" |
| **Skills** | 领域知识库 | `.claude/skills/` | 按需加载，避免 Context 爆炸 |
| **Specs** | Feature 全链路文档 | `.claude/specs/` | 需求→设计→实现→验证的信息传递载体 |
| **Agents** | 角色定义 + 行为边界 | `.claude/agents/` | 每个 Agent 知道自己该干什么、不该干什么 |
| **Memory** | 跨会话持久记忆 | `.claude/project-memory/` | 项目知识不丢失，下次对话不用重新说 |

---

## 两层分离

```
┌──────────────────────────────────────┐
│  编排层（框架 core/）                │
│  通用的工作流定义，由 upgrade.sh 同步  │
│  你不需要改这里                      │
├──────────────────────────────────────┤
│  执行层（项目 .claude/）             │
│  你的业务规则、编码规范、业务词典      │
│  marker 下方永远属于你               │
└──────────────────────────────────────┘
```

---

## 你每天做什么

1. 打开 Claude Code，描述需求
2. 回答 Intake 三问（目标 / 边界 / 验收标准）
3. 审批 PM 产出的需求文档（01）
4. 审批 Arch 产出的技术设计（02）
5. 等待 AI 自动完成开发 + QA
6. 确认结果，合并代码

**人的角色从"写代码"变成了"审批 Spec"。**
