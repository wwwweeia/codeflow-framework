---
name: confluence-doc-sync
description: Confluence 文档同步集成规范。定义各 Agent 如何使用 Confluence MCP 工具读取需求文档和同步技术设计文档。Confluence 集成是可选的、非阻塞的。
---

# Confluence 文档同步集成

## 概述

本 Skill 定义了 SDD 工作流中各 Agent 如何与 Confluence 交互。Confluence 作为外部文档源（需求文档、技术参考）和可选的文档同步目标。集成是**可选的、非阻塞的**——如果 Confluence MCP Server 未配置或工具不可用，所有操作将被静默跳过。

**前提条件**：项目根目录需配置 `.mcp.json`，包含 Confluence MCP Server 的连接信息和凭据。

## 项目配置

`.mcp.json` 中 `confluence` 字段定义项目级 Confluence 默认值，Agent 在创建页面时应优先使用：

```json
{
  "confluence": {
    "spaceKey": "DT",
    "parentPageId": "104497787"
  }
}
```

| 字段 | 必填 | 用途 |
|------|------|------|
| `confluence.spaceKey` | 否 | 默认 Confluence 空间 Key。用于 `confluence_create_page` 的 `spaceKey` 参数 |
| `confluence.parentPageId` | 否 | 新页面的默认父页面 ID。用于 `confluence_create_page` 的 `parentId` 参数 |

**读取方式**：使用 Read 工具读取项目根目录的 `.mcp.json`，提取 `confluence` 对象中的字段。

**配置缺失时的行为**：
- `spaceKey` 未配置时，创建页面前必须向用户确认目标空间
- `parentPageId` 未配置时，创建页面前必须向用户确认父页面（可用 `confluence_get_child_pages` 浏览空间结构辅助确认）

**页面层级策略**：

配置指定一个默认父页面，所有 SDD 产出的新页面（需求文档、技术设计等）创建为其子页面。

```
(parentPageId: 104497787)       ← 配置的默认父页面
├── 需求：XXX 功能                        ← Agent 创建
├── 技术设计：XXX 功能                     ← Agent 创建
└── ...
```

如需按文档类型分目录，团队可在 Confluence 手动创建子分类页面（如"需求文档"、"技术设计"），然后更新 `.mcp.json` 的 `parentPageId` 指向对应分类。Agent 也可通过 `confluence_get_child_pages(parentPageId)` 浏览已有子页面，选择合适的层级创建。

## MCP 工具速查

| 工具名 | 用途 | 关键参数 |
|--------|------|---------|
| `confluence_list_spaces` | 获取空间列表 | `start`, `limit` |
| `confluence_get_page` | 按 ID 获取页面详情（含正文） | `id`(必填), `expand` |
| `confluence_search_content` | CQL 搜索内容 | `cql`(必填), `start`, `limit`, `expand` |
| `confluence_create_page` | 创建页面 | `spaceKey`(必填), `title`(必填), `content`(必填), `parentId` |
| `confluence_update_page` | 更新页面内容 | `id`(必填), `content`(必填), `title`, `version`, `minorEdit`, `message` |
| `confluence_add_comment` | 添加页面评论 | `pageId`(必填), `content`(必填) |
| `confluence_get_child_pages` | 获取子页面列表 | `pageId` 或 `spaceKey`(二选一), `start`, `limit` |

> **工具名前缀**：以上工具在 Claude Code 中以 `mcp__confluence__` 为前缀调用（如 `mcp__confluence__confluence_get_page`）。本 Skill 中简写工具名，Agent 按运行时实际可用名称调用。

## 各 Agent 使用规则

### PM Agent — 需求文档读取

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| Intake 收到 Confluence 页面链接 | `confluence_get_page` | 读取页面完整内容作为需求输入 |
| 按关键词搜索需求文档 | `confluence_search_content` | 使用 CQL 搜索相关文档 |
| 浏览空间结构 | `confluence_list_spaces` + `confluence_get_child_pages` | 了解文档组织方式 |

**使用场景**：用户提到"需求在 Confluence 上"或提供了 Confluence 页面 URL/ID 时，PM 应主动读取页面内容，提取需求信息纳入 Spec。

### Arch Agent — 技术参考与文档同步

**允许的操作**：只读 + 可选写入

| 时机 | 操作 | 说明 |
|------|------|------|
| 需要技术参考 | `confluence_get_page` | 读取已有的技术设计文档、架构说明 |
| 可选：同步技术设计 | `confluence_create_page` | 将 `02_technical_design.md` 内容同步到 Confluence（需项目明确要求）。使用配置的 `spaceKey` 和 `parentId`（来自 `.mcp.json`） |
| 可选：更新已有文档 | `confluence_update_page` | 更新已有的技术文档页面 |

> **写入操作需谨慎**：创建/更新 Confluence 页面前，必须确认用户明确要求同步到 Confluence。默认不要自动写入。

### QA Agent — 验收标准参考

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| 需要补充验收上下文 | `confluence_get_page` | 读取 Confluence 上的验收标准文档 |
| 搜索相关测试文档 | `confluence_search_content` | 查找已有的测试方案或验收记录 |

## CQL 查询模式

常用搜索模板：

```javascript
// 按标题搜索
`title = "需求文档标题"`

// 按空间 + 关键词搜索
`space = "DEV" AND text ~ "关键词"`

// 搜索最近更新的页面
`space = "DEV" AND type = page ORDER BY lastmodified DESC`

// 按标签搜索
`space = "DEV" AND label = "requirements"`

// 搜索特定用户创建的页面
`space = "DEV" AND creator = "username" ORDER BY created DESC`
```

## 内容格式说明

Confluence 使用 **Storage Format (HTML)** 作为页面内容格式。创建或更新页面时，`content` 参数需传入 HTML：

```html
<h1>标题</h1>
<p>段落文本</p>
<ul>
  <li>列表项 1</li>
  <li>列表项 2</li>
</ul>
<table>
  <tr><th>列 1</th><th>列 2</th></tr>
  <tr><td>值 1</td><td>值 2</td></tr>
</table>
```

**Markdown → HTML 转换**：Agent 需要将 Spec 中的 Markdown 内容转换为 Confluence Storage Format HTML 后写入。

## 版本管理

更新 Confluence 页面时的注意事项：
- 服务端会自动递增版本号，通常无需手动指定 `version` 参数
- 如需指定版本，必须大于当前版本号
- `minorEdit: true`（默认）不会触发通知，适合格式调整
- `message` 参数可记录本次更新的说明

## 降级策略

当 Confluence MCP 工具不可用时（未配置 `.mcp.json`、服务未启动、网络不可达）：

- 所有 Agent **静默跳过** Confluence 操作，不产生错误或警告
- 工作流照常进行，需求信息以用户直接提供为准
- 不要因为 Confluence 不可用而中断任何工作流步骤
- 不要在输出中提示"Confluence 连接失败"等信息（避免噪音）
<!-- codeflow-framework:core v1.10.0-20260422 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
