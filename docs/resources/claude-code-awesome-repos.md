---
title: Claude Code 优质仓库推荐
description: 社区高度认可的 Claude Code 相关仓库推荐
prev: false
next:
  link: /resources/sdd-riper-methodology
---

> 整理日期：2026-04-20
> 本文收录 4 个在社区获得高度认可的 Claude Code 相关仓库，适合团队学习与工程实践参考。

---

## 1. obra/superpowers ⭐ 160k

**仓库地址：** https://github.com/obra/superpowers  
**一句话定位：** 面向 AI 编程代理的完整软件工程方法论框架

### 核心思路
不是让 AI 直接写代码，而是先退一步：通过问题澄清 → 设计确认 → 任务拆解 → 子代理执行 → 自动审查的完整流水线，让 AI 开发过程可预期、可干预。

### 7 阶段强制工作流
| 阶段 | 说明 |
|------|------|
| 头脑风暴 | 写代码前提问细化，分段展示设计供确认 |
| Git Worktree | 设计通过后创建隔离工作分支 |
| 编写计划 | 拆分为 2-5 分钟小任务，含精确文件路径和验证步骤 |
| 子代理执行 | 每个任务独立子代理，配合两阶段代码审查 |
| 测试驱动 (TDD) | 强制 RED-GREEN-REFACTOR，未写测试就写的代码会被删除 |
| 代码审查 | 任务间自动触发，关键问题阻断进度 |
| 完成分支 | 验证后提供合并/PR/保留/丢弃选项 |

### 适用场景
- 追求代码质量和工程规范的团队
- 希望 AI 能长时间自主工作而不偏离计划
- 需要将 TDD、DRY、YAGNI 等实践固化到 AI 行为中

---

## 2. affaan-m/everything-claude-code ⭐ 140k

**仓库地址：** https://github.com/affaan-m/everything-claude-code  
**一句话定位：** 最全的 Claude Code 配置与工具集合，覆盖开发全生命周期

### 规模亮点
- 36 个专用子智能体（agents/）
- 183 个技能模块（skills/）
- 79 个命令（commands/）
- 配套安全审计工具 AgentShield（1282 项测试，98% 覆盖率）

### 核心模块速览
| 模块 | 内容 |
|------|------|
| 子智能体 | 规划、架构、代码审查、安全审查、多语言构建修复等 |
| 技能库 | 前端(React/Next.js)、后端(API/DB/Docker)、AI成本优化、内容运营等 |
| 命令 | `/plan`、`/tdd`、`/code-review`、`/multi-execute` 等完整工作流命令 |
| 钩子 | 会话上下文自动加载/保存、策略性精简、模式提取 |
| 规则 | 编码规范、Git工作流、80%测试覆盖率强制、语言专属规则 |

### 特别值得关注
- **AgentShield**：扫描 CLAUDE.md、MCP 配置、钩子等，检测密钥泄露和注入风险，支持红蓝对抗深度分析
- **持续学习 v2**：基于"本能"的自动学习系统，自动提取和复用开发模式

---

## 3. luongnv89/claude-howto ⭐ 21.8k

**仓库地址：** https://github.com/luongnv89/claude-howto  
**一句话定位：** 带可视化图表和时间预估的 Claude Code 完整学习指南

### 学习路径（10 大模块）
| 模块 | 难度 | 时间 | 核心内容 |
|------|------|------|---------|
| Slash Commands | 初学 | 30分钟 | 手动快捷命令 |
| Memory | 初学+ | 45分钟 | 跨会话记忆（CLAUDE.md）|
| Checkpoints | 中级 | 45分钟 | 会话快照与回退 |
| Skills | 中级 | 1小时 | 可复用自动触发工作流 |
| Hooks | 中级 | 1小时 | 事件驱动自动化（25种事件）|
| MCP | 中级+ | 1小时 | 外部工具与 API 接入 |
| Subagents | 中级+ | 1.5小时 | 专化 AI 助手与任务拆分 |
| Advanced | 高级 | 2-3小时 | 规划模式、后台任务、无头模式 |
| Plugins | 高级 | 2小时 | 打包完整解决方案 |

### 与官方文档的差异
相比官方文档，这个指南最大的价值在于：**带 Mermaid 图表的可视化教程** + **可直接上手的生产级模板** + **自测问答功能** + **支持导出 EPUB 离线阅读**。

---

## 4. Yeachan-Heo/oh-my-claudecode

**仓库地址：** https://github.com/Yeachan-Heo/oh-my-claudecode  
**一句话定位：** 零学习曲线的 Claude Code 多智能体编排系统

### 核心能力
- **Team 模式**：阶段化流水线（plan → prd → exec → verify → fix）
- **32 个专业智能体**：架构、研究、设计、测试、数据科学等
- **智能模型路由**：简单任务 Haiku，复杂推理 Opus，自动选择
- **成本优化**：智能路由节省 30-50% token 消耗

### 7 种执行模式
| 模式 | 特点 | 适用 |
|------|------|------|
| Team | 标准多智能体协作 | 通用开发 |
| Autopilot | 全自动端到端 | 快速出活 |
| Ultrawork | 最大并行化 | 批量修复/重构 |
| Ralph | 持久模式 | 必须完成的长任务 |
| ccg | 三模型并行（Codex+Gemini+Claude） | 复杂任务分解 |

### 上手方式
```bash
# 安装插件
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode

# 初始化
/omc-setup

# 直接用自然语言描述需求即可
autopilot: build a REST API for managing tasks
```

---

## 5. shanraisshan/claude-code-best-practice ⭐ 46.6k

**仓库地址：** https://github.com/shanraisshan/claude-code-best-practice  
**一句话定位：** 从"氛围编程"到"智能体工程"的系统化最佳实践知识库

> 💡 这也是我们团队当前正在使用的参考仓库，已在本地维护了中文导读版（`README-CN.md`）。

### 核心内容
| 目录 | 内容 |
|------|------|
| `best-practice/` | 核心概念文档：Agents、Commands、Skills、Memory、Settings、MCP 完整参考 |
| `tips/` | **82 条**实用技巧，来自 Boris（Claude Code 负责人）、Thariq 等核心人物 |
| `development-workflows/` | 10+ 种主流开发工作流（Plan Everything、Superpowers、Spec Kit 等）|
| `implementation/` | 子代理、命令、技能、Agent 团队的具体实现示例 |
| `orchestration-workflow/` | Command → Agent → Skill 完整编排架构示例 |
| `agent-teams/` | 多 Agent 协作模式 |
| `reports/` | 深度研究报告（工具使用、记忆系统、速率限制等）|

### 特别亮点
- **社区级资源**：整合 Boris Cherny（Claude Code 创建者）、Andrej Karpathy 等核心人物的使用经验
- **82 条技巧分类**：覆盖提示、规划、上下文管理、会话管理、调试、Hooks、工作流等 13 个维度
- **工作流参考**：收录 Superpowers、Spec Kit 等完整工程工作流的设计思路
- **中文版**：本地 `README-CN.md` 已提供完整中文目录导读，可直接上手

---

## 选用建议

| 目标 | 推荐 |
|------|------|
| 想系统学习 Claude Code 核心概念和最佳实践 | **claude-code-best-practice（本仓库）** |
| 想建立规范的 AI 开发工程流程 | **superpowers** |
| 想快速上手 Claude Code 全部特性 | **claude-howto** |
| 想要现成的大型工具集直接用 | **everything-claude-code** |
| 想实现多智能体自动化编排 | **oh-my-claudecode** |
