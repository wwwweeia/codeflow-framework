---
name: dev-workflow-common
description: Dev/FE 共享的工作流步骤（Research → Execute → 落盘 → Self-Test → 04 → Handoff）、异常处理流程、落盘规范。被 dev-agent 和 fe-agent 引用。
---

# Dev/FE 公共工作流

> 本 Skill 定义 Dev 和 FE Agent 共享的工作流步骤。各 Agent 的特有执行细节（如 TDD 节奏、lint 验证等）在各自定义文件中描述。

## 加载引导

- **必加载场景**：Dev 或 FE Agent 启动时
- **可跳过场景**：其他 Agent

---

## 1. Research（调研）

查清代码现状，锁定事实，每个结论附代码出处（文件路径:行号）。

**必读文件**（按顺序）：
1. CLAUDE.md — 了解项目结构和目标项目位置
2. `01_requirement.md` 和 `02_technical_design.md` — 确认理解范围
3. 目标项目的编码规则文件（`coding_backend.md` 或 `coding_frontend_shared.md`）
4. 目标项目的 `.claude/context/` — 了解现状
5. 按知识加载协议检查目标项目知识体系

**复杂场景额外产出**（改动涉及 2+ package、外部集成、调用链超 3 层）：
- 产出 `<目标项目目录>/.claude/codemap/<feature>.md`

## 2. Execute（执行）

按子任务逐步实现并立即验证。

**Jira 状态流转**（可选）：如 01 头部标注了 Jira Issue Key 且 Jira MCP 可用，开始编码前使用 `jira_get_transitions` + `jira_transition_issue` 将 Issue 流转到 "In Progress"。

**分支策略**：
- 工作流 A/B：普通分支模式（`git checkout -b feature/<spec-name>`）
- 工作流 C：使用 using-git-worktrees skill 创建隔离工作区

**知识应用**：如已按知识加载协议加载 cookbook，实现中必须参考其数据流和关键点；如发现 cookbook 与实际代码不一致，记录到 03 执行日志并上报主对话。

## 3. 落盘（03 执行日志）

**实时更新**，每个子任务完成后追加，而非全部做完再补写：

| 字段 | 说明 |
|------|------|
| 变更文件清单 | 操作类型 + 文件路径 + 简要说明 |
| 关键决策 | 偏离设计时必须说明原因 |
| 问题记录 | 遇到的问题及处理方式 |

## 4. Self-Test（两阶段自查）

按 `self-test-checklist` skill 执行。完成后才能流转 QA。

## 5. 产出测试计划（04_test_plan.md）

在 Spec 目录产出测试计划文档（**流转 QA 前**）：
- **Part A：自动化测试矩阵** — 需求溯源 + 场景描述 + 场景来源 + 测试类型 + 测试代码位置 + 状态
- **Part B**：后端为可执行 curl 命令序列；前端为人工验证清单
- 模板详见 `spec-templates` Skill

## 6. Handoff（流转 QA）

Self-Test 通过、04 已产出后：
1. 主动呼叫 @qa-agent 进行独立验收
2. 如关联了 Jira Issue 且 Jira MCP 可用，使用 `jira_add_comment` 添加评论：实现完成，等待 QA 验证

## 异常处理

执行中遇到以下情况必须**立即停止**，不要尝试自行变通：
- Spec 描述的业务规则有矛盾或遗漏
- 02 设计的方案无法在现有架构上实现
- 发现设计文档与现有代码有未预见的冲突

停止后：
1. 将问题详细记录到 03 执行日志的「问题记录」章节
2. 上报主对话：`⚠️ 执行中断：[问题描述]，详见 03_impl_xxx.md`

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
