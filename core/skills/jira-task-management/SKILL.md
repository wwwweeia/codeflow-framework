---
name: jira-task-management
description: Jira 任务管理集成规范。定义各 Agent 在 SDD 工作流中如何使用 Jira MCP 工具进行需求关联、状态同步和缺陷管理。Jira 集成是可选的、非阻塞的。
---

# Jira 任务管理集成

## 概述

本 Skill 定义了 SDD 工作流中各 Agent 如何与 Jira 交互。Jira 集成是**可选的、非阻塞的**——如果 Jira MCP Server 未配置或工具不可用，所有 Jira 操作将被静默跳过，不影响正常工作流。

**前提条件**：项目根目录需配置 `.mcp.json`，包含 Jira MCP Server 的连接信息和凭据。

## 项目配置

`.mcp.json` 中 `jira` 字段定义项目级 Jira 默认值，Agent 在创建 Issue 或构建 JQL 时应优先使用：

```json
{
  "jira": {
    "projectKey": "AINATIVE"
  }
}
```

| 字段 | 必填 | 用途 |
|------|------|------|
| `jira.projectKey` | 否 | 默认 Jira 项目 Key。用于 `jira_create_issue` 的 `fields.project.key`、JQL 查询的 `project = {projectKey}` 限定 |

**读取方式**：使用 Read 工具读取项目根目录的 `.mcp.json`，提取 `jira` 对象中的字段。

**配置缺失时的行为**：
- `projectKey` 未配置时，创建 Issue 前必须向用户确认目标项目 Key
- JQL 查询不受影响（可跨项目搜索），但推荐按配置项目限定范围

## MCP 工具速查

| 工具名 | 用途 | 关键参数 |
|--------|------|---------|
| `jira_get_projects` | 获取项目列表 | 无 |
| `jira_search_issues` | JQL 查询 Issue | `jql`(必填), `startAt`, `maxResults` |
| `jira_create_issue` | 创建 Issue | `fields`(必填): 含 project, summary, issuetype |
| `jira_update_issue` | 更新 Issue 字段 | `issueIdOrKey`(必填), `fields`(必填) |
| `jira_add_comment` | 添加评论 | `issueIdOrKey`(必填), `body`(必填) |
| `jira_get_transitions` | 获取可用状态流转 | `issueIdOrKey`(必填) |
| `jira_transition_issue` | 执行状态流转 | `issueIdOrKey`(必填), `transitionId`(必填) |
| `jira_get_fields` | 获取字段定义和自定义字段映射 | 无 |
| `jira_get_createmeta` | 获取 Issue 创建元数据 | `projectKeys`(必填) |

> **工具名前缀**：以上工具在 Claude Code 中以 `mcp__jira__` 为前缀调用（如 `mcp__jira__jira_search_issues`）。本 Skill 中简写工具名，Agent 按运行时实际可用名称调用。

## 各 Agent 使用规则

### PM Agent — 需求关联

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| Intake 收到 Jira Issue Key | `jira_search_issues` | 按 Key 查询，提取描述、验收标准、优先级、当前状态 |
| Intake 收到模糊需求描述 | `jira_search_issues` | 按关键词搜索相关 Issue，默认限定 `project = {projectKey}` |
| 需要了解项目 Issue 类型 | `jira_get_createmeta` | 获取项目支持的 Issue Type 和必填字段 |

**产出要求**：如果关联了 Jira Issue，在 `01_requirement.md` 头部添加：

```markdown
> **Jira Issue**: [YOURPROJECT-1234](https://jira.example.com/browse/YOURPROJECT-1234)
> **Issue Type**: Story | **Priority**: High | **Status**: To Do
```

### Arch Agent — 技术设计上下文

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| 开始技术设计 | `jira_search_issues` | 读取关联 Issue 的完整描述和评论，补充业务上下文 |
| 需要了解关联任务 | `jira_search_issues` | 查询 Epic 下的子任务，了解全貌 |

### Dev / FE Agent — 状态流转

**允许的操作**：状态流转 + 评论

| 时机 | 操作 | 说明 |
|------|------|------|
| 开始编码实现 | `jira_transition_issue` | 流转到 "In Progress"（需先 `jira_get_transitions` 获取 transitionId） |
| 实现完成，交接 QA | `jira_add_comment` | 添加评论：实现摘要 + 等待 QA 验证 |

**状态流转流程**：
1. 调用 `jira_get_transitions` 获取当前 Issue 可用的流转列表
2. 找到目标状态（如 "In Progress"）对应的 `transitionId`
3. 调用 `jira_transition_issue` 执行流转

> **注意**：不同项目的 Jira 工作流可能不同，transitionId 不固定。必须先查询再流转。

### QA Agent — 审查反馈

**允许的操作**：评论 + 创建缺陷

| 时机 | 操作 | 说明 |
|------|------|------|
| Review PASS | `jira_add_comment` | 添加审查通过评论：QA Review PASS + 审查摘要 |
| Review FAIL | `jira_add_comment` | 添加审查不通过评论：QA Review FAIL + 阻碍点列表 |
| 发现新缺陷（可选） | `jira_create_issue` | 创建 Bug 类型 Issue，`fields.project.key` 使用配置的 `projectKey`，关联到原 Story |

**QA 评论格式**：

```
## QA Review: PASS

- 审查模式：后端 / 前端 / 全栈
- Spec 达成率：100%
- 代码一致性：符合技术设计
- 代码质量：通过
- 审查时间：YYYY-MM-DD HH:mm
```

### 主会话 — 首尾协调

**允许的操作**：读取 + 状态流转

| 时机 | 操作 | 说明 |
|------|------|------|
| Intake 阶段 | `jira_search_issues` | 检测到 Issue Key 时读取详情 |
| 合并完成、收尾 | `jira_transition_issue` | 流转到 "Done" / "Closed" |

## JQL 查询模式

常用查询模板（`{projectKey}` 从 `.mcp.json` 的 `jira.projectKey` 读取，如未配置则替换为实际项目 Key）：

```javascript
// 按 Issue Key 精确查询（不受 projectKey 限制）
`key = AINATIVE-1234`

// 查询项目的进行中任务
`project = {projectKey} AND status = "In Progress" ORDER BY updated DESC`

// 查询 Epic 下的子任务
`parent = {projectKey}-1000 ORDER BY rank ASC`

// 查询指派给某人的待办
`assignee = currentUser() AND project = {projectKey} AND status != Done ORDER BY priority DESC`

// 按关键词搜索
`project = {projectKey} AND summary ~ "关键词" ORDER BY created DESC`
```

## 状态流转协议

```
典型流转路径（因项目而异）：
To Do → In Progress → In Review → Done
                         ↑           │
                         └───────────┘ (QA FAIL 打回)
```

**规则**：
1. 流转前**必须**先调用 `jira_get_transitions` 获取可用的 transitionId
2. 不同项目的 Jira 工作流不同，不要硬编码状态名或 transitionId
3. 只有 Dev/FE 可将 Issue 流转到 "In Progress"
4. 只有主会话可在合并完成后将 Issue 流转到 "Done"/"Closed"
5. QA 不直接流转状态，只添加评论，由主会话协调后续流转

## 降级策略

当 Jira MCP 工具不可用时（未配置 `.mcp.json`、服务未启动、网络不可达）：

- 所有 Agent **静默跳过** Jira 操作，不产生错误或警告
- 工作流照常进行，Spec 文档中的 Jira Issue 字段留空
- 不要因为 Jira 不可用而中断任何工作流步骤
- 不要在输出中提示"Jira 连接失败"等信息（避免噪音）
<!-- codeflow-framework:core v1.10.0-20260422 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
