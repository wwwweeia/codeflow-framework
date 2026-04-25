---
title: 三、Stub Marker 自动管理
description: Marker 格式、位置规则、工作原理与项目自定义空间
prev:
  text: 二、架构设计
  link: /design/architecture
next:
  text: 四、工作流体系
  link: /design/workflow
---

# 三、Stub Marker 自动管理机制

## 3.1 Marker 格式

```markdown
<!-- codeflow-framework:core v1.0.0-20260416 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
```

每个被管理文件都包含此 marker，它是框架内容与项目自定义内容的**分界线**。

## 3.2 位置规则

**统一规则**：所有被管理文件的 marker 放在**文件末尾**（框架内容的最后一行），marker 下方为项目可扩展区域。

```markdown
---
name: pm-agent                    ← YAML frontmatter（如有）
description: 产品经理 Agent
tools: [Read, Glob, Grep, Write, Edit]
model: sonnet
---

[框架定义的完整内容...]           ← upgrade.sh 全量替换此区域

<!-- codeflow-framework:core v1.0.0-20260416 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->

## 项目特定扩展                    ← 项目团队自由扩展，升级时永远保留

[项目团队自行添加的内容]
```

**唯一例外** — `domain-ontology/SKILL.md`，marker 在**文件中部**：

```markdown
[框架定义的格式说明与填写规范...]   ← 框架维护的"骨架"
[加载指导、维护说明...]

<!-- codeflow-framework:core v1.0.0-20260416 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->

## 项目业务词典                    ← 项目团队按格式填充实际业务定义

### Section 1: 核心术语库
| 术语 | 英文 | 定义 | ... |
```

> **设计原因**：domain-ontology 的特殊性在于框架提供"格式骨架"，项目填充"业务内容"。marker 放中部既能让框架更新格式定义，又能保留项目已填充的业务词典。

## 3.3 工作原理

升级时，`upgrade.sh` 对每个被管理文件执行以下操作：

```
┌──────────────────────────┐     ┌──────────────────────────┐
│   框架源文件 (core/)      │     │   项目目标文件 (.claude/) │
│                          │     │                          │
│  [框架新内容]             │     │  [框架旧内容]             │
│  ── marker ──            │     │  ── marker ──            │
│  (框架源没有下方内容)      │     │  [项目自定义内容]         │
└──────────────────────────┘     └──────────────────────────┘
              │                               │
              │         upgrade.sh            │
              └──────────┬────────────────────┘
                         ▼
          ┌──────────────────────────┐
          │   合并后的目标文件        │
          │                          │
          │  [框架新内容]   ← 来自源  │
          │  ── marker ──            │
          │  [项目自定义内容] ← 保留  │
          └──────────────────────────┘
```

**核心保证**：marker 下方的项目自定义内容在升级时**永远不会被覆盖**。

## 3.4 项目自定义空间

项目团队可以在 marker 下方自由扩展：

| 文件 | 可扩展内容示例 |
|------|--------------|
| `project_rule.md` | 项目特有的工作流规则、审批流程 |
| `merge_checklist.md` | 项目特有的合并检查项 |
| `domain-ontology/SKILL.md` | 项目的业务术语、实体关系 |
| `agents/*.md` | 项目特有的 Agent 行为指导 |
| `branches.md` | 项目特有的分支命名规则 |
