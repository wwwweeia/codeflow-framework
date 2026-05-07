---
title: 术语速查
description: HCodeFlow 核心术语的快速参考，首次遇到不明术语时查这里
prev:
  text: 概念详解
  link: /getting-started/concepts
next:
  text: 设计理念
  link: /getting-started/philosophy
---

# 术语速查

> 遇到不认识的术语，先查这里。每个术语有"一句话解释"和"深入了解"链接。

---

## A-B

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **Agent** | AI Agent | 扮演特定角色（PM、架构师等）的 AI 行为定义 | [概念详解 → 七角色](/getting-started/concepts#七角色) |
| **Arch Agent** | Architect Agent | 负责技术设计，产出 02_technical_design.md | [概念详解 → 七角色](/getting-started/concepts#七角色) |
| **Approval** | Approval 审批 | 人确认 Spec 后，AI 才开始写代码 | [认识 SDD → 工作流](/getting-started/what-is-sdd#sdd-工作流长什么样) |

---

## C-D

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **CLAUDE.md** | — | 项目根目录的配置文件，告诉 AI 项目的基本信息 | [项目接入](/integration/new-project) |
| **Dev Agent** | Developer Agent | 负责后端代码实现 | [概念详解 → 七角色](/getting-started/concepts#七角色) |
| **doctor.sh** | — | 环境诊断工具，检查框架依赖是否就绪 | [工具速查](/getting-started/tools) |
| **Domain Ontology** | 领域本体 / 业务词典 | 项目的核心业务术语和实体关系 | [项目接入 → 配置业务词典](/integration/new-project) |

---

## E-F

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **E2E Runner** | End-to-End Runner | 执行端到端测试的 Agent（按需启用） | [概念详解 → 七角色](/getting-started/concepts#七角色) |
| **Execute** | 执行阶段 | AI 根据 Spec 写代码的阶段 | [认识 SDD → 工作流](/getting-started/what-is-sdd#sdd-工作流长什么样) |
| **FE Agent** | Frontend Agent | 负责前端代码实现 | [概念详解 → 七角色](/getting-started/concepts#七角色) |
| **Feature** | 功能 / 需求 | 一个完整的需求单元，对应一组 Spec 文档 | [概念详解 → Spec 体系](/getting-started/concepts#spec-文档体系) |

---

## G-I

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **harvest.sh** | — | 从下游项目收割验证过的变更回框架 core/ | [已有项目 → 收割](/integration/existing-project) |
| **init-project.sh** | — | 一键初始化脚本，在项目中创建 `.claude/` 结构 | [项目接入 → 初始化](/integration/new-project) |
| **Intake** | Intake 三问 | 需求澄清环节：目标/边界/验收标准 | [认识 SDD → 工作流](/getting-started/what-is-sdd#sdd-工作流长什么样) |

---

## M-P

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **Marker** | Stub Marker | 框架内容与项目自定义内容的分界标记 | [概念详解 → Marker 机制](/getting-started/concepts#marker-机制) |
| **Memory** | 项目记忆 | 跨会话持久化，记录项目知识和经验 | [概念详解 → 确定性空间](/getting-started/concepts#确定性空间五要素) |
| **Merge** | 合并阶段 | 代码通过 Review 后合并到目标分支 | [认识 SDD → 工作流](/getting-started/what-is-sdd#sdd-工作流长什么样) |
| **PM Agent** | Product Manager Agent | 负责需求结构化，产出 01_requirement.md | [概念详解 → 七角色](/getting-started/concepts#七角色) |
| **Prototype Agent** | — | 负责前端原型搭建（按需启用） | [概念详解 → 七角色](/getting-started/concepts#七角色) |

---

## Q-R

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **Q0** | Q0 轻量模式 | 小改动的简化流程，不需要完整 Spec | [概念详解 → 四种工作流](/getting-started/concepts#四种工作流模式) |
| **QA Agent** | Quality Assurance Agent | 独立审查代码质量，输出 PASS/FAIL | [概念详解 → 七角色](/getting-started/concepts#七角色) |
| **Review** | 审查阶段 | QA Agent 检查代码质量和规范遵从度 | [认识 SDD → 工作流](/getting-started/what-is-sdd#sdd-工作流长什么样) |
| **Rules** | 编码规则 | 项目级的硬性编码规范 | [概念详解 → 确定性空间](/getting-started/concepts#确定性空间五要素) |

---

## S

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **SDD** | Spec-Driven Development | 先写规格文档再写代码的开发方式 | [认识 SDD](/getting-started/what-is-sdd) |
| **Skills** | 知识库 / 技能 | 按需加载的领域知识（SQL 审查、API 规范等） | [概念详解 → 确定性空间](/getting-started/concepts#确定性空间五要素) |
| **Spec** | Specification | 结构化的需求/设计文档，AI 按此执行 | [概念详解 → Spec 体系](/getting-started/concepts#spec-文档体系) |
| **Spec 01** | 01_requirement.md | PM 产出的需求文档 | [概念详解 → Spec 体系](/getting-started/concepts#spec-文档体系) |
| **Spec 02** | 02_technical_design.md | Architect 产出的技术设计文档 | [概念详解 → Spec 体系](/getting-started/concepts#spec-文档体系) |
| **Spec 03** | 03_impl_*.md | Dev/FE 产出的实现日志 | [概念详解 → Spec 体系](/getting-started/concepts#spec-文档体系) |
| **Spec 04** | 04_test_plan.md | QA 产出的测试计划 | [概念详解 → Spec 体系](/getting-started/concepts#spec-文档体系) |

---

## T-W

| 术语 | 全称 / 英文 | 一句话解释 | 深入了解 |
|------|------------|-----------|---------|
| **TDD** | Test-Driven Development | 先写测试用例再写实现代码 | [概念详解](/getting-started/concepts) |
| **upgrade.sh** | — | 框架升级脚本，从 core/ 同步到项目的 `.claude/` | [已有项目 → 升级](/integration/existing-project) |
| **Workflow A** | 纯后端工作流 | PM → Arch → Dev → QA | [概念详解 → 四种工作流](/getting-started/concepts#四种工作流模式) |
| **Workflow B** | 纯前端工作流 | PM → Arch → FE → QA | [概念详解 → 四种工作流](/getting-started/concepts#四种工作流模式) |
| **Workflow C** | 全栈工作流 | PM → Arch → Dev + FE 并行 → QA | [概念详解 → 四种工作流](/getting-started/concepts#四种工作流模式) |

---

## 没找到？

如果你遇到了文档中没有解释的术语，可能是我们遗漏了。欢迎反馈：

- 在 Claude Code 中使用 `framework-feedback` 技能提交建议
- 直接联系框架维护者
