---
title: Skills 参考
description: 框架提供的 20+ 领域知识库与工具
outline:
  level: [2, 2]
---

# Skills 参考

> Skills 是按需加载的领域知识库，Agent 在执行任务时会根据需要自动引用。
> 每个 Skill 以目录形式组织，核心定义在 `SKILL.md` 文件中。

## API 审查规则 (API Reviewer Skill)

> 目录：`core/skills/api-reviewer/`

REST API 设计与审查规则。用于后端 API 端点的设计与实现验证。

> 本 Skill 由 Arch/Dev Agent 在处理 API 相关任务时加载，用于指导 REST API 设计与审查。

::: details 查看完整定义


**API 审查规则 (API Reviewer Skill)**

> 本 Skill 由 Arch/Dev Agent 在处理 API 相关任务时加载，用于指导 REST API 设计与审查。

**API 设计原则**

**1. 端点规范**

- 使用 RESTful 路径：资源名词而非动词（如 `/api/users` 而非 `/api/getUsers`）
- 版本控制：支持多版本共存（`/api/v1/`, `/api/v2/` 等）
- 命名一致：使用 snake_case（路径）、camelCase（JSON 字段）
- 资源路由：`POST /users`（创建）, `GET /users/:id`（获取）, `PUT /users/:id`（更新）, `DELETE /users/:id`（删除）

**2. 请求与响应**

- **Request**：明确定义请求参数、类型、必填字段、验证规则
- **Response**：统一使用通用响应格式（如 `{ code, message, data, detail }`）
- **Error Handling**：明确定义错误代码和错误信息，避免返回语义不明的 null

**3. 认证与授权**

- 实现统一的身份认证（Token/JWT/Session）
- 鉴权检查应在 Controller 或 Filter 层实现
- 避免硬编码权限检查

**4. 性能与可靠性**

- 列表接口必须分页
- 避免过度关联查询（SELECT N+1 问题）
- 考虑缓存策略（Redis/本地缓存）
- 实现幂等性（重复请求不产生重复影响）

**API 审查检查表**

**设计阶段**

- [ ] **HTTP 方法**：是否使用了正确的 HTTP 方法（GET/POST/PUT/DELETE）？
- [ ] **路径规范**：是否遵循 RESTful 命名规范？
- [ ] **版本控制**：新 API 是否明确了版本号？
- [ ] **请求体**：是否明确定义了请求参数和验证规则？
- [ ] **响应格式**：是否使用了项目统一的响应格式？
- [ ] **错误处理**：是否定义了错误代码和错误信息？
- [ ] **幂等性**：幂等操作是否有实现策略？

**实现阶段**

- [ ] **参数验证**：Controller 是否验证了所有输入参数？
- [ ] **权限检查**：是否进行了鉴权和授权检查？
- [ ] **异常处理**：是否捕获和妥善处理了所有异常？
- [ ] **日志记录**：关键操作是否有适当的日志记录？
- [ ] **敏感信息**：日志中是否避免了打印敏感信息？
- [ ] **分页实现**：列表接口是否正确实现了分页？

**文档阶段**

- [ ] **文档完整**：是否为每个端点编写了清晰的文档？
- [ ] **示例提供**：是否提供了请求和响应的完整示例？
- [ ] **版本说明**：是否说明了不同版本的差异？

:::

## 后端开发知识库 (Backend Knowledge Base)

> 目录：`core/skills/backend-rules/`

后端开发知识库，包含本项目特有的代码模板、内部 API 速查和项目约定。 Use when writing or reviewing Java code, creating Service/Mapper classes, or debugging backend issues.

> **按需加载**：本文件是核心速查。按需读取 `templates/` 和 `references/` 获取详细内容。
> 通用语言/框架知识由 AI 自行掌握，不在此赘述。仅记录**项目特有**的约定和模式。

::: details 查看完整定义


**后端开发知识库 (Backend Knowledge Base)**

> **按需加载**：本文件是核心速查。按需读取 `templates/` 和 `references/` 获取详细内容。
> 通用语言/框架知识由 AI 自行掌握，不在此赘述。仅记录**项目特有**的约定和模式。

**加载引导**

- **必加载场景**：Dev/QA Agent 涉及后端代码时
- **可跳过场景**：纯前端任务

**知识索引**

| 层级 | 目录 | 内容 |
|------|------|------|
| 代码模板 | `templates/` | Controller / Service / Mapper 标准模板 |
| API 参考 | `references/` | ORM 配置约定等项目特有配置 |
| 核心速查 | 本文件 marker 下方 | 高频代码片段（统一响应对象、异常、分页等） |

**硬规则**

> 硬规则定义在后端项目的 `.claude/rules/coding_backend.md`，AI 必须遵守。本 Skill 不重复列举。

:::

## Confluence 文档同步集成

> 目录：`core/skills/confluence-doc-sync/`

Confluence 文档同步集成规范。定义各 Agent 如何使用 Confluence MCP 工具读取需求文档和同步技术设计文档。Confluence 集成是可选的、非阻塞的。

本 Skill 定义了 SDD 工作流中各 Agent 如何与 Confluence 交互。Confluence 作为外部文档源（需求文档、技术参考）和可选的文档同步目标。集成是**可选的、非阻塞的**——如果 Confluence MCP Server 未配置或工具不可用，所有操作将被静默跳过。

::: details 查看完整定义


**Confluence 文档同步集成**

**概述**

本 Skill 定义了 SDD 工作流中各 Agent 如何与 Confluence 交互。Confluence 作为外部文档源（需求文档、技术参考）和可选的文档同步目标。集成是**可选的、非阻塞的**——如果 Confluence MCP Server 未配置或工具不可用，所有操作将被静默跳过。

**前提条件**：项目根目录需配置 `.mcp.json`，包含 Confluence MCP Server 的连接信息和凭据。

**项目配置**

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
灵智 AI (parentPageId: 104497787)       ← 配置的默认父页面
├── 需求：XXX 功能                        ← Agent 创建
├── 技术设计：XXX 功能                     ← Agent 创建
└── ...
```

如需按文档类型分目录，团队可在 Confluence 手动创建子分类页面（如"需求文档"、"技术设计"），然后更新 `.mcp.json` 的 `parentPageId` 指向对应分类。Agent 也可通过 `confluence_get_child_pages(parentPageId)` 浏览已有子页面，选择合适的层级创建。

**MCP 工具速查**

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

**各 Agent 使用规则**

**PM Agent — 需求文档读取**

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| Intake 收到 Confluence 页面链接 | `confluence_get_page` | 读取页面完整内容作为需求输入 |
| 按关键词搜索需求文档 | `confluence_search_content` | 使用 CQL 搜索相关文档 |
| 浏览空间结构 | `confluence_list_spaces` + `confluence_get_child_pages` | 了解文档组织方式 |

**使用场景**：用户提到"需求在 Confluence 上"或提供了 Confluence 页面 URL/ID 时，PM 应主动读取页面内容，提取需求信息纳入 Spec。

**Arch Agent — 技术参考与文档同步**

**允许的操作**：只读 + 可选写入

| 时机 | 操作 | 说明 |
|------|------|------|
| 需要技术参考 | `confluence_get_page` | 读取已有的技术设计文档、架构说明 |
| 可选：同步技术设计 | `confluence_create_page` | 将 `02_technical_design.md` 内容同步到 Confluence（需项目明确要求）。使用配置的 `spaceKey` 和 `parentId`（来自 `.mcp.json`） |
| 可选：更新已有文档 | `confluence_update_page` | 更新已有的技术文档页面 |

> **写入操作需谨慎**：创建/更新 Confluence 页面前，必须确认用户明确要求同步到 Confluence。默认不要自动写入。

**QA Agent — 验收标准参考**

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| 需要补充验收上下文 | `confluence_get_page` | 读取 Confluence 上的验收标准文档 |
| 搜索相关测试文档 | `confluence_search_content` | 查找已有的测试方案或验收记录 |

**CQL 查询模式**

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

**内容格式说明**

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

**版本管理**

更新 Confluence 页面时的注意事项：
- 服务端会自动递增版本号，通常无需手动指定 `version` 参数
- 如需指定版本，必须大于当前版本号
- `minorEdit: true`（默认）不会触发通知，适合格式调整
- `message` 参数可记录本次更新的说明

**降级策略**

当 Confluence MCP 工具不可用时（未配置 `.mcp.json`、服务未启动、网络不可达）：

- 所有 Agent **静默跳过** Confluence 操作，不产生错误或警告
- 工作流照常进行，需求信息以用户直接提供为准
- 不要因为 Confluence 不可用而中断任何工作流步骤
- 不要在输出中提示"Confluence 连接失败"等信息（避免噪音）

:::

## Dev/FE 公共工作流

> 目录：`core/skills/dev-workflow-common/`

Dev/FE 共享的工作流步骤（Research → Execute → 落盘 → Self-Test → 04 → Handoff）、异常处理流程、落盘规范。被 dev-agent 和 fe-agent 引用。

> 本 Skill 定义 Dev 和 FE Agent 共享的工作流步骤。各 Agent 的特有执行细节（如 TDD 节奏、lint 验证等）在各自定义文件中描述。

::: details 查看完整定义


**Dev/FE 公共工作流**

> 本 Skill 定义 Dev 和 FE Agent 共享的工作流步骤。各 Agent 的特有执行细节（如 TDD 节奏、lint 验证等）在各自定义文件中描述。

**加载引导**

- **必加载场景**：Dev 或 FE Agent 启动时
- **可跳过场景**：其他 Agent

---

**1. Research（调研）**

查清代码现状，锁定事实，每个结论附代码出处（文件路径:行号）。

**必读文件**（按顺序）：
1. CLAUDE.md — 了解项目结构和目标项目位置
2. `01_requirement.md` 和 `02_technical_design.md` — 确认理解范围
3. 目标项目的编码规则文件（`coding_backend.md` 或 `coding_frontend_shared.md`）
4. 目标项目的 `.claude/context/` — 了解现状
5. 按知识加载协议检查目标项目知识体系

**复杂场景额外产出**（改动涉及 2+ package、外部集成、调用链超 3 层）：
- 产出 `<目标项目目录>/.claude/codemap/<feature>.md`

**2. Execute（执行）**

按子任务逐步实现并立即验证。

**Jira 状态流转**（可选）：如 01 头部标注了 Jira Issue Key 且 Jira MCP 可用，开始编码前使用 `jira_get_transitions` + `jira_transition_issue` 将 Issue 流转到 "In Progress"。

**分支策略**：
- 工作流 A/B：普通分支模式（`git checkout -b feature/<spec-name>`）
- 工作流 C：使用 using-git-worktrees skill 创建隔离工作区

**知识应用**：如已按知识加载协议加载 cookbook，实现中必须参考其数据流和关键点；如发现 cookbook 与实际代码不一致，记录到 03 执行日志并上报主对话。

**3. 落盘（03 执行日志）**

**实时更新**，每个子任务完成后追加，而非全部做完再补写：

| 字段 | 说明 |
|------|------|
| 变更文件清单 | 操作类型 + 文件路径 + 简要说明 |
| 关键决策 | 偏离设计时必须说明原因 |
| 问题记录 | 遇到的问题及处理方式 |

**4. Self-Test（两阶段自查）**

按 `self-test-checklist` skill 执行。完成后才能流转 QA。

**5. 产出测试计划（04_test_plan.md）**

在 Spec 目录产出测试计划文档（**流转 QA 前**）：
- **Part A：自动化测试矩阵** — 需求溯源 + 场景描述 + 场景来源 + 测试类型 + 测试代码位置 + 状态
- **Part B**：后端为可执行 curl 命令序列；前端为人工验证清单
- 模板详见 `spec-templates` Skill

**6. Handoff（流转 QA）**

Self-Test 通过、04 已产出后：
1. 主动呼叫 @qa-agent 进行独立验收
2. 如关联了 Jira Issue 且 Jira MCP 可用，使用 `jira_add_comment` 添加评论：实现完成，等待 QA 验证

**异常处理**

执行中遇到以下情况必须**立即停止**，不要尝试自行变通：
- Spec 描述的业务规则有矛盾或遗漏
- 02 设计的方案无法在现有架构上实现
- 发现设计文档与现有代码有未预见的冲突

停止后：
1. 将问题详细记录到 03 执行日志的「问题记录」章节
2. 上报主对话：`⚠️ 执行中断：[问题描述]，详见 03_impl_xxx.md`

:::

## 业务词典与领域建模 (Domain Ontology Skill)

> 目录：`core/skills/domain-ontology/`

业务词典与领域建模知识库。统一项目术语、梳理业务实体关系、指导需求分析。触发场景：Intake 三问前主会话加载以精准提问、PM Agent 撰写需求时确保术语规范、Arch Agent 技术设计时对齐数据模型与业务术语、Dev/FE Agent 编码时确保命名与术语一致。即使用户没有明确提到"业务词典"，只要涉及业务术语澄清、实体关系梳理、需求翻译为数据模型，就应加载本 Skill。

> 本 Skill 由主会话（Intake 阶段）和 PM/Arch/Dev/FE Agent 加载，用于统一项目术语、梳理业务实体关系、指导需求分析和编码实现。

::: details 查看完整定义


**业务词典与领域建模 (Domain Ontology Skill)**

> 本 Skill 由主会话（Intake 阶段）和 PM/Arch/Dev/FE Agent 加载，用于统一项目术语、梳理业务实体关系、指导需求分析和编码实现。

**核心职责**

1. **术语规范**：确保跨团队沟通使用统一的业务术语
2. **实体关系**：绘制核心业务实体的依赖图和状态流转
3. **需求翻译**：将业务需求翻译为清晰的数据模型和 API 结构

---

**术语铁律**

1. **术语唯一来源**：所有 Spec 文档中的业务术语必须来自本 Skill 已定义的术语，不得自行发明或使用近义词替代
2. **无定义不使用**：需要使用新术语时，必须先在本 Skill 的核心术语库中定义（含中文名、英文、定义、举例），再在 Spec 中使用
3. **生命周期即边界**：描述实体操作时，只能使用该实体生命周期中明确定义的动作和状态转换，不得推测或编造操作
4. **PM Agent 自检**：完成 01-requirements Spec 后，逐条核对文档中出现的业务术语是否均在 domain-ontology 中有定义；发现未定义术语应先补充定义再继续

---

**填写格式说明**

以下 Section 1–4 定义了业务词典的标准结构。项目团队在 marker 下方按此格式填写项目的实际业务定义。

**Section 1: 核心术语库**

每个术语应包含：

| 字段 | 说明 |
|------|------|
| **术语（中文）** | 业务术语的中文名 |
| **英文** | 术语的英文对应（用于代码命名） |
| **定义** | 术语的精确定义 |
| **举例** | 实际使用场景 |
| **关联术语** | 相关的其他术语 |

**Section 2: 核心业务实体**

每个实体应包含：
- **定义**：实体的业务含义
- **关键属性**：核心字段列表
- **与其他实体的关系**：一对多/多对多等
- **生命周期**：创建 → 启用 → 停用 → 删除

建议使用文本形式绘制实体关系图。

**Section 3: 业务规则**

明确关键的业务约束，如实体间的数量关系、状态流转条件、权限约束等。

**Section 4: 常见场景与流程**

梳理关键业务流程（如新实体创建流程、审批流程等），帮助开发理解业务上下文。

---

**加载指导**

- **主会话**：在 Intake 三问前加载，以便精准提问时引用已有业务术语和实体定义
- **PM Agent**：在撰写需求时加载，确保需求描述使用规范术语
- **Arch Agent**：在技术设计时加载，确保数据模型与业务术语对齐
- **Dev/FE Agent**：在编码时参考，确保代码中的变量名、方法名与术语一致

---

**维护与更新**

- 新增业务术语或实体时，由 PM 或项目负责人补充
- 术语定义变化时，应更新所有相关文档
- 使用 `git blame` 或备注说明术语变化的上下文

:::

## E2E 测试知识库

> 目录：`core/skills/e2e-testing/`

E2E 测试知识库。当需要为项目新 Feature 编写/运行 Playwright E2E 测试时加载。包含认证机制、选择器模式、POM 模板、项目结构约定、运行命令等关键知识。

本 Skill 封装了 E2E 测试的全部关键技术决策和踩坑经验。适用于：
- e2e-runner Agent 执行测试时参考
- 主会话调度 E2E 测试时参考

::: details 查看完整定义


**E2E 测试知识库**

本 Skill 封装了 E2E 测试的全部关键技术决策和踩坑经验。适用于：
- e2e-runner Agent 执行测试时参考
- 主会话调度 E2E 测试时参考
- 新 Feature 编写 E2E 测试时的模板

---

**§1 认证机制与 Setup 模式**

**核心决策：API 直接登录（不走浏览器）**

灵智 AI 登录需要验证码（OCR 不稳定），因此 **auth.setup.ts 使用 Node.js HTTP API 直接调用登录接口**，避免浏览器渲染。

**流程**：
```
auth.setup.ts:
  1. GET /api/uias-service/oauth/captcha?uuid=xxx → 验证码图片（二进制）
  2. Swift OCR 脚本识别 → 验证码文本（重试 < 1s/次）
  3. POST /api/uias-service/oauth/token → { token, userInfo, resourceTree, ... }
  4. AES-128-CBC 加密各字段 → 写入 .auth/session-storage.json
  5. page.evaluate() 注入 sessionStorage
  6. context.storageState() 保存 cookies（兼容 Playwright 机制）
```

**登录 API 参数**（multipart/form-data）：

| 参数 | 值 |
|------|------|
| username | 环境变量（默认 aikg） |
| password | MD5 哈希后的值 |
| captcha | OCR 识别结果 |
| uuid | 与验证码请求一致的 UUID |
| appCode | ai-kg |
| loginType | user |
| client_id | browser |
| client_secret | browser |
| tenantKey | 3a57a9ab730e40ae181533ebb703512c |

**响应结构**：`{ code: 0, data: { token, userInfo, resourceTree, orgTree, agentInfo, agentFunctionEnable } }`

**AES-128-CBC 加密参数**

前端用 AES 加密后存入 sessionStorage（`ai-kg-front/plugins/encrytion.js`）：

```
Key: (storageKey + "9vApxLk5G3PAsJrM").slice(0, 16)
IV:  "FnJL7EDzjqWjcaY9"（硬编码）
模式: aes-128-cbc
输出: hex 字符串
```

加密后的 sessionStorage 键：

| 键名 | 加密前内容 |
|------|-----------|
| authUser | `JSON.stringify(token)` |
| permission | `JSON.stringify(resourceTree)` |
| info | `JSON.stringify(userInfo)` |
| org | `JSON.stringify(orgTree)` |
| agentInfo | `JSON.stringify(agentInfo)` |
| agentFunctionEnable | `String(boolean)`（未加密） |

**加密工具已封装在** `e2e/utils/encryption.ts`，API 登录已封装在 `e2e/utils/api-login.ts`。

**测试文件中的 Session 注入**

**关键：必须用 `page.addInitScript()` 在页面 JS 执行前注入，不能用 `page.evaluate()` 后注入。**

原因：Vue app 的 auth middleware 在页面加载时立即检查 sessionStorage。如果注入太晚，页面已经重定向到 `/login`。

```typescript
// tests/*.spec.ts
test.beforeEach(async ({ page }) => {
  const sessionData = JSON.parse(fs.readFileSync(SESSION_FILE, 'utf-8'))
  await page.addInitScript((data) => {
    for (const [key, value] of Object.entries(data)) {
      sessionStorage.setItem(key, value as string)
    }
  }, sessionData)
})
```

---

**§2 技术栈特定选择器模式**

**Element UI + qiankun 微前端**

| 陷阱 | 正确做法 |
|------|---------|
| 表格操作列有 `fixed="right"` | 操作按钮在 `.el-table__fixed-right` 中，常规 tbody 里的按钮是 **hidden** |
| `getByText('编辑')` 匹配到单元格数据 | 用 `getByRole('button', { name: '编辑' })` 精确匹配按钮，避免匹配包含"编辑"的文本 |
| loading mask 有多个 | `page.locator('.el-loading-mask').first()` 避免 strict mode |
| Dialog 关闭有动画 | 用 `await expect(dialog).not.toBeVisible({ timeout: 5000 })` 而非 `isDialogVisible()` |
| 子应用路由格式 | `/agentCenter/preset-questions`（注意大小写） |

**Operation 组件按钮文本**

h-kg-agent-center 的 `<Operation>` 组件按钮文本**不是**常见语义：

| Operation flag | 实际文本 | 常见误写 |
|---------------|---------|---------|
| isAdd | **新建** | ~~新增~~ |
| isDel | **删除** | |
| isImport | **导入** | |
| isExport | **导出** | |

**SearchForm 组件按钮文本**

| 按钮 | 实际文本 | 常见误写 |
|------|---------|---------|
| 提交 | **检索** | ~~搜索~~ |
| 重置 | **重置** | |

**表格 fixed 列选择器模板**

```typescript
// 操作按钮在 fixed-right 区域
private getFixedRow(rowIndex: number) {
  return this.table.locator(
    '.el-table__fixed-right .el-table__fixed-body-wrapper tbody tr'
  ).nth(rowIndex)
}

async clickEdit(rowIndex: number) {
  const btn = this.getFixedRow(rowIndex).getByText('编辑')
  await btn.waitFor({ state: 'visible', timeout: 10_000 })
  await btn.click()
}
```

---

**§3 POM 模板与约定**

**BasePage 已封装方法**

`e2e/pages/base.page.ts` 提供：

| 方法 | 用途 |
|------|------|
| `waitForSubApp(path)` | 等待 qiankun 子应用加载 |
| `waitForLoadingDismiss()` | 等待 Element UI loading 消失 |
| `waitForMessage(text)` | 等待 Element UI 消息提示 |
| `confirmMessageBox()` | 点击确认弹窗的确定按钮 |
| `screenshot(name)` | 截图保存为 evidence |

**新 POM 模板**

```typescript
import { Page, Locator, expect } from '@playwright/test'
import { BasePage } from './base.page'

export class XxxPage extends BasePage {
  readonly table: Locator
  readonly tableRows: Locator
  readonly pagination: Locator
  readonly dialog: Locator
  readonly dialogConfirmBtn: Locator

  constructor(page: Page) {
    super(page)
    this.table = page.locator('.xxx-page .el-table')
    this.tableRows = this.table.locator('tbody tr')
    this.pagination = page.locator('.xxx-page .el-pagination')
    this.dialog = page.locator('.el-dialog:visible').last()
    this.dialogConfirmBtn = this.dialog.locator('.el-button--primary')
  }

  async goto() {
    await this.page.goto('/agentCenter/xxx')
    await this.page.waitForLoadState('networkidle')
    await expect(this.table).toBeVisible({ timeout: 15_000 })
  }

  // fixed 列操作按钮
  private getFixedRow(rowIndex: number) {
    return this.table.locator(
      '.el-table__fixed-right .el-table__fixed-body-wrapper tbody tr'
    ).nth(rowIndex)
  }

  async clickAdd() {
    await this.page.getByText('新建').first().click()
    await expect(this.dialog).toBeVisible()
  }

  async clickEdit(rowIndex: number) {
    const btn = this.getFixedRow(rowIndex).getByRole('button', { name: '编辑' })
    await btn.waitFor({ state: 'visible', timeout: 10_000 })
    await btn.click()
    await expect(this.dialog).toBeVisible()
  }

  async submitDialog() {
    await this.dialogConfirmBtn.click()
  }

  async searchByKeyword(keyword: string) {
    const input = this.page.getByPlaceholder(/关键词/)
    await input.fill(keyword)
    await this.page.getByText('检索').first().click()
    await this.waitForLoadingDismiss()
  }
}
```

**选择器优先级**

1. `data-testid` — 最稳定（需前端配合添加）
2. `getByText()` / `getByRole()` — 语义化，较稳定
3. `.el-form-item` + `filter({ hasText: '标签名' })` — Element UI 表单定位
4. CSS 选择器 — 最后手段

---

**§4 运行命令**

**环境变量**

| 变量 | 默认值 | 说明 |
|------|--------|------|
| E2E_BASE_URL | https://192.168.104.125 | 被测服务器地址 |
| E2E_USERNAME | aikg | 登录用户名 |
| E2E_PASSWORD | admin123 | 登录密码 |
| E2E_HEADLESS | true | 是否无头模式 |
| E2E_MAX_OCR_ATTEMPTS | 10 | OCR 最大重试次数 |

**执行命令**

```bash
cd e2e

**全量执行**
npx playwright test

**带 UI 可见浏览器**
npx playwright test --headed

**只跑某个文件**
npx playwright test tests/xxx.spec.ts

**只跑 setup（重新登录）**
npx playwright test --project=setup --headed

**查看 HTML 报告**
npx playwright show-report
```

**Playwright 配置要点**

- `workers: 1` — 串行执行（sessionStorage 不支持并行）
- `ignoreHTTPSErrors: true` — 内网 HTTPS 证书
- 两个 project：`setup`（登录） → `authenticated`（测试，依赖 setup）
- `authenticated` 使用 `storageState: '.auth/user.json'`

---

**§5 踩坑记录（避坑指南）**

| 坑 | 原因 | 解决 |
|----|------|------|
| 页面总是跳转到 /login | `page.evaluate()` 注入 sessionStorage 太晚 | 用 `page.addInitScript()` 在 JS 执行前注入 |
| 编辑/删除按钮 found but not visible | Element UI `fixed="right"` 列有独立 DOM | 用 `.el-table__fixed-right` 选择器 |
| `strict mode violation: .el-loading-mask` | 页面同时存在多个 loading mask | 用 `.first()` |
| Dialog 关闭检测失败 | Dialog 有关闭动画，`isVisible()` 瞬间仍为 true | 用 `expect(dialog).not.toBeVisible({ timeout: 5000 })` |
| "新增"按钮找不到 | Operation 组件的添加按钮文本是 "新建" | 查看实际组件源码确认按钮文本 |
| "搜索"按钮找不到 | SearchForm 组件的搜索按钮文本是 "检索" | 同上 |
| `getByText('编辑')` 匹配到 `E2E编辑_xxx` | getByText 做子串匹配，单元格数据含"编辑" | 用 `getByRole('button', { name: '编辑' })` 精确匹配 |

---

**§6 故障分类与处理策略**

测试失败时先分类再行动：

**A 类：E2E 技术问题（自行修复）**

选择器不匹配、等待超时、Session 注入时机、OCR 登录失败、Element UI 组件交互模式等。

→ 参考 §2/§3 修复测试代码，重跑。**不上报主会话。**

**B 类：业务/应用问题（上报主会话）**

| 症状 | 根因 | 上报 |
|------|------|------|
| API 返回非预期格式 | 前后端接口约定不一致 | 接口 URL + 期望 vs 实际 |
| API 500 / 超时 | 后端 bug / 性能 | 接口 URL + 错误信息 |
| 提交后数据未变 | 后端逻辑 bug | 请求体 + 响应体 |
| 按钮存在但无响应 | 前端事件缺失 | 组件路径 |
| 非预期验证失败 | 校验规则不一致 | 字段名 + 期望 vs 实际 |
| 缺少 UI 元素 | 功能未实现 | AC 编号 |
| 权限不足 | 用户缺权限 | resourceCode |

→ **不修改应用代码**，记录 evidence 后上报主会话，附截图 + 分类 + 修复方向。主会话派发 dev-agent 或 fe-agent 处理。

---

**§7 项目结构约定**

**目录布局**

```
e2e/
├── tests/
│   ├── auth.setup.ts             # 认证 setup（框架模板提供）
│   ├── smoke/
│   │   └── smoke.spec.ts         # 烟雾测试
│   └── {feature-name}/           # 按 feature/spec 组织（项目特有）
│       └── {scenario}.spec.ts
├── pages/
│   ├── base.page.ts              # 通用基类（框架模板提供）
│   ├── login.page.ts             # 登录页（框架模板提供）
│   └── {page-name}.page.ts       # 业务页面 POM（项目特有）
├── fixtures/
│   └── auth.fixture.ts           # 认证 fixture（框架模板提供）
├── utils/
│   ├── api-login.ts              # API 登录（框架模板提供）
│   └── encryption.ts             # AES 加密（框架模板提供）
├── scripts/
│   └── read_captcha.swift        # OCR 脚本（框架模板提供）
├── .auth/                        # 认证产物（gitignore）
├── .evidence/{feature}/          # 运行时截图（gitignore）
├── playwright.config.ts
├── package.json
└── tsconfig.json
```

**Spec 到测试的映射规则**

每个包含 Part E 的 Spec 对应 `e2e/tests/` 下的一个 feature 目录：

| Spec 目录 | Feature 名称 | 测试目录 |
|-----------|-------------|---------|
| `.claude/specs/test-preset-questions/` | `preset-questions` | `e2e/tests/preset-questions/` |
| `.claude/specs/feature-channel-mgmt/` | `channel-mgmt` | `e2e/tests/channel-mgmt/` |
| `.claude/specs/preset-question-import-export/` | `preset-question-import-export` | `e2e/tests/preset-question-import-export/` |

命名规则：去掉 spec 目录的 `test-` / `feature-` 前缀。

**证据放置规则**

| 类型 | 路径 | 说明 |
|------|------|------|
| 运行时截图 | `e2e/.evidence/{feature}/` | 已 gitignore，不提交到仓库 |
| 最终报告 | `.claude/specs/{spec-dir}/evidences/evidence-e2e.md` | 提交到仓库，长期存档 |
| 关键截图 | `.claude/specs/{spec-dir}/evidences/` | e2e-runner 复制关键截图到此目录 |

**截图方法**

`BasePage.screenshot(feature, name)` 将截图保存到 `.evidence/{feature}/{name}.png`：

```typescript
// 使用示例
await pqPage.screenshot('preset-questions', 'ac01')  // → .evidence/preset-questions/ac01.png
```

**测试文件 import 路径**

由于测试文件在 `tests/{feature}/` 子目录中，相对路径需要多退一层：

```typescript
// tests/preset-questions/crud.spec.ts
import { XxxPage } from '../../pages/xxx.page'
const SESSION_FILE = path.join(__dirname, '..', '..', '.auth', 'session-storage.json')
```

:::

## 框架反馈技能 (Framework Feedback)

> 目录：`core/skills/framework-feedback/`

向 h-codeflow-framework 团队提交反馈（Bug、Feature Request、Improvement、Question）。 Use when user wants to report a framework issue, request a feature, suggest improvements, or ask questions.

帮助用户向 h-codeflow-framework 团队提交结构化反馈。反馈将通过 GitLab Issue + 飞书群通知发送给框架维护团队。

::: details 查看完整定义


**框架反馈技能 (Framework Feedback)**

帮助用户向 h-codeflow-framework 团队提交结构化反馈。反馈将通过 GitLab Issue + 飞书群通知发送给框架维护团队。

> **注意**：此技能执行一次提交后立即返回结果。不重试、不循环、不追问。

**环境配置**

首次使用前，请确保下游项目已完成环境配置。参见 **[SETUP.md](./SETUP.md)**（随技能一同下发）。

快速检查：在项目目录执行 `glab issue list`，能看到 Issue 列表即环境就绪。未配置 glab 时技能仍可工作（仅发送飞书通知，不创建 GitLab Issue）。

**执行流程**

**第 1 步：确认反馈类型**

检查 `$ARGUMENTS` 是否包含有效的类型标签。有效值：`bug`、`feature`、`improvement`、`question`。

- 如果 `$ARGUMENTS` 包含有效类型标签，直接使用
- 如果 `$ARGUMENTS` 为空或无效，向用户展示以下选项请其选择：

| 类型 | 标签 | 适用场景 |
|------|------|---------|
| Bug | `bug` | 框架规则不符合预期、Agent 行为异常、upgrade.sh 出错 |
| Feature Request | `feature` | 新 Agent、新 Skill、新工作流、新命令 |
| Improvement | `improvement` | 现有功能的优化建议 |
| Question | `question` | 使用疑问、文档不清晰 |

如果用户输入了自然语言描述（如 "我发现一个 bug"），映射到对应标签。

**第 2 步：自动收集上下文**

无需用户手动提供，自动从当前项目提取以下信息：

**项目名称**：从 `git remote get-url origin` 提取仓库名，或读取 `package.json`/`pom.xml` 中的项目名。

**框架版本**：扫描 `.claude/` 目录下任意包含 `h-codeflow-framework:core` marker 的文件，从 marker 行提取版本号（格式如 `v1.8.0-20260421`）。

**组件分类**：根据用户反馈内容推断涉及的框架组件：
- `agents` — PM/Arch/Dev/FE/QA/Prototype/E2E Agent 行为
- `rules` — project_rule.md、merge_checklist.md 规则
- `skills` — 知识库（SQL审查、API规范等）
- `workflow` — Intake 确认、Spec 流程等
- `upgrade` — upgrade.sh、harvest.sh 工具链
- `other` — 其他

**第 3 步：引导用户补充信息**

根据反馈类型，向用户收集以下信息：

**所有类型必填**：
- **title**：一句话概括（AI 可从用户描述中提炼，需用户确认）
- **description**：详细描述（用户口述，AI 可帮助结构化）

**所有类型可选**：
- **priority**：low / medium / high（默认 medium，AI 可建议但由用户确认）

**Bug 类型额外字段**（如果是 bug，主动询问）：
- **reproduce_steps**：复现步骤
- **expected_behavior**：期望行为
- **actual_behavior**：实际行为

**收集提示**（引导用户理解每个字段的含义）：

```
请提供以下信息：
📝 标题：一句话概括问题（如 "dev-agent 在处理复杂查询时未生成索引检查"）
📝 描述：详细说明你遇到的情况

[如果是 Bug]
📝 复现步骤：你是怎么触发这个问题的？
📝 期望行为：你觉得应该怎样？
📝 实际行为：实际发生了什么？

优先级：low（不急）/ medium（正常）/ high（阻塞工作）
```

**第 4 步：确认提交预览**

收集完毕后，向用户展示提交预览，格式如下：

```
📋 反馈提交预览
─────────────────
类型: [Bug/Feature/Improvement/Question]
组件: [agents/rules/skills/workflow/upgrade/other]
优先级: [low/medium/high]
标题: [用户提供的标题]
项目: [自动提取的项目名]
框架版本: [自动提取的版本号]
提交者: [git user.name]
─────────────────
描述:
[用户提供的描述]
─────────────────
确认提交？(y/n)
```

用户确认后进入第 5 步。用户拒绝则退出，不提交任何内容。

**第 5 步：执行提交**

构建 JSON 并通过 stdin 传递给提交脚本：

```bash
cat <<'FEEDBACK_JSON' | bash .claude/skills/framework-feedback/scripts/submit-feedback.sh
{
  "type": "bug",
  "component": "agents",
  "priority": "high",
  "title": "用户提供的标题",
  "description": "用户提供的描述",
  "project": "自动提取的项目名",
  "framework_version": "vX.X.X-YYYYMMDD",
  "submitter": "git user.name",
  "reproduce_steps": "复现步骤（bug 时提供）",
  "expected_behavior": "期望行为（bug 时提供）",
  "actual_behavior": "实际行为（bug 时提供）"
}
FEEDBACK_JSON
```

**提交者信息**：从 `git config user.name` 获取。

**第 6 步：报告结果**

根据脚本输出的 JSON 结果向用户反馈：

- **success**：
  - 如果 `gitlab.status` 为 `"success"`：告知用户 "反馈已提交！GitLab Issue 已创建：{gitlab.url}，同时已发送飞书通知。"
  - 如果 `gitlab.status` 为 `"skipped"` 或 `"failed"`：告知用户 "反馈已通过飞书通知发送。GitLab Issue 未创建（glab CLI 不可用），框架团队会尽快处理。"
- **failed**：展示错误信息，建议用户直接联系框架团队或通过其他渠道反馈。

**约束**

- 只执行一次提交，无论成功或失败
- 不修改用户项目中的任何文件
- 不自动重试失败的提交
- 不在反馈中包含敏感信息（密码、Token、密钥等）

:::

## 前端 API 对接技能

> 目录：`core/skills/frontend-api-integration/`

前端 API 对接技能。适用于 Nuxt 2 / Vue 2 前端应用中新增 Vuex Store Action 和接口调用。

- 用户要求在前端项目中对接后端接口
- 需要新增 Vuex Store Action 或修改已有接口调用

::: details 查看完整定义


**前端 API 对接技能**

**触发条件**
- 用户要求在前端项目中对接后端接口
- 需要新增 Vuex Store Action 或修改已有接口调用

**Store Action 编写规范**

> 完整命名约定与 HTTP 方法规则见 **frontend-conventions §2.2**，Action 模板见 **frontend-conventions §2.3**。

所有 API 调用必须放在 `store/` 的 action 中，统一使用 `this.$axios`，直接返回 Promise。URL 必须使用 `state.service` 前缀，**禁止硬编码路径**。

```javascript
// store/channel.js
const state = () => ({
  service: '<service-prefix>',  // API 路径前缀，取自项目特定配置
})

const actions = {
  // 列表查询：POST + /list 后缀
  async getChannelList({ state }, params) {
    return await this.$axios({
      method: 'post',
      url: `${state.service}/channels/list`,
      data: params,
    })
  },

  // 新增：POST 到资源路径
  async createChannel({ state }, data) {
    return await this.$axios({
      method: 'post',
      url: `${state.service}/channels`,
      data,
    })
  },
}
```

**组件中调用**

```javascript
async loadData() {
  this.loading = true
  try {
    const { code, data } = await this.$store.dispatch('channel/getChannelList', this.params)
    if (code === 0) {
      this.list = data
    }
  } finally {
    this.loading = false
  }
}
```

**关键规则**

1. **禁止重复弹错误提示**：全局 axios 拦截器（`plugins/axios.js`）已统一处理所有接口错误，业务层禁止 `catch` 后手动 `Message.error`
2. **成功提示**：仅在写操作（创建/编辑/删除）成功后调用 `this.$message.success()`
3. **Token 注入**：`plugins/axios.js` 自动注入 Authorization，禁止手动设置
4. **表格场景**：若接口用于封装表格组件加载数据，Store Action 须能接收 `pageNumber` / `pageSize` 参数，通过 `tableConfig.uri` 配置（格式为 `{module}/{action}`，不是 HTTP 路径）

:::

## 前端架构设计产出规范（Part B）

> 目录：`core/skills/frontend-arch-design/`

前端架构设计产出规范。供 arch-agent 设计 02_technical_design.md Part B 时使用，定义 B-1~B-7 各节的产出格式与 Checklist。底层规范引用 frontend-conventions。

> 本 Skill 面向 **arch-agent**，用于设计阶段产出 `02_technical_design.md` Part B。
> 底层规范（路由结构、Store 模式、权限命名、API 调用规则、组件树）见 **frontend-conventions**。
> 前端 UI 设计规范（组件选型策略、Token、页面模板、交互规范）见 **frontend-ui-design** Skill。

::: details 查看完整定义


**前端架构设计产出规范（Part B）**

> 本 Skill 面向 **arch-agent**，用于设计阶段产出 `02_technical_design.md` Part B。
> 底层规范（路由结构、Store 模式、权限命名、API 调用规则、组件树）见 **frontend-conventions**。
> 前端 UI 设计规范（组件选型策略、Token、页面模板、交互规范）见 **frontend-ui-design** Skill。
> 本 Skill 专注于 **Part B 的产出格式和 Checklist**。

---

**1. Part B 各节产出格式**

**B-1：路由注册**

在 `<App>/router/routes.js` 中，在 `<相邻模块>` 路由块之后追加：

```markdown
| 路由 name | path | 页面组件 |
|----------|------|--------|
| `<module>` | `<module>` | `<module>/index.vue` |
| `<module>/list` | `''` | `<module>/list.vue` |
| `<module>/add` | `add` | `<module>/add.vue` |
```

> 路由 name 和嵌套结构必须遵循 frontend-conventions §1 的三层约定。

**B-2：页面文件结构**

```
pages/<module>/index.vue    ← 壳页面（nuxt-child + keep-alive）
pages/<module>/list.vue     ← 列表主体
pages/<module>/add.vue      ← 新增/编辑（共用，query.id 区分）
pages/<module>/detail.vue   ← 详情页（按需）
```

**B-3：Vuex Store 模块**

新建文件：`<App>/store/<module>.js`

**State**：
- `service`：`'<service-prefix>'`（见 conventions 项目特定配置）
- `keepList`：`[]`

**Actions**（按 conventions §2.2 命名）：

```markdown
| Action | HTTP | 路径 |
|--------|------|------|
| `getXxxList` | POST | `/xxx/list` |
| `addXxx` | POST | `/xxx` |
| `updateXxx` | PUT | `/xxx/:id` |
| `deleteXxx` | DELETE | `/xxx?ids=...` |
```

**B-4：API 字段映射表**

**列表展示（后端 Response → 前端表格）**

```markdown
| 后端字段 | 类型 | 前端展示 | 说明 |
|---------|------|--------|------|
| `id` | Long | 不展示 | 主键，用于编辑/删除 |
| `name` | String | vul-text-tooltip 截断 | 名称 |
| `isActive` | Integer | 状态点：1=启用/0=禁用 | — |
| `updateTime` | DateTime | YYYY-MM-DD HH:mm | 支持列排序 |
```

**弹窗表单（前端 dialogForm → 后端 Request）**

```markdown
| dialogForm 字段 | 后端字段 | 必填 |
|----------------|---------|------|
| `name` | `name` | 是 |
| `isActive` | `isActive` | 是 |
```

**关联对象处理**：
- 一对多关联 → `multiCell` 组件渲染标签列表
- 枚举值 → 在列 `render` 或 `slot-scope` 中映射转换
- 长文本 → `vul-text-tooltip` 包裹

**B-5：组件树**

列出每个页面的三层结构（Page → Section → Component），标注组件选型决策。

> 组件树结构和选型原则参考 frontend-conventions §6。

示例：

```markdown
**pages/<module>/list.vue（列表主体）**
- search-form
  - 搜索字段：name（input）/ status（select）
- operation
  - operationObj: { isAdd, isDel }
- el-table（带 selection、sortable:custom 列）
  - 列：名称 / 分类 / 优先级 / 状态 / 更新时间 / 操作
- el-pagination（total 来自后端）
- el-dialog（新增/编辑弹窗）
  - el-form：name / type / priority / isActive
```

**B-6：API 调用清单**

```markdown
| 接口 | Action | Method | Path | Request 示例 | Response 示例 |
|------|--------|--------|------|-------------|---------------|
| 分页列表 | `getXxxList` | POST | `/xxx/list` | `{ pageNumber, pageSize, ... }` | `{ code:0, data:{ list, total, ... } }` |
| 新增 | `addXxx` | POST | `/xxx` | `{ name, ... }` | `{ code:0, message:"新增成功" }` |
```

> ⚠️ Response 示例**必须**使用项目约定的字段名（参考 frontend-conventions 项目特定配置中的分页响应格式），**禁止**使用 ORM 默认格式。

**B-7：权限配置清单**

```markdown
| 按钮 | resourceCode | resourceType |
|------|-------------|-------------|
| 菜单 | `<app>-<module>` | 1（菜单） |
| 新增 | `<app>-<module>-add` | 2（按钮） |
| 编辑 | `<app>-<module>-edit` | 2（按钮） |
| 删除 | `<app>-<module>-delete` | 2（按钮） |
```

> resourceCode 命名规则见 frontend-conventions §3。

---

**2. Part B 完整产出 Checklist**

撰写 `02_technical_design.md` Part B 时，必须输出以下所有部分：

| 节 | 内容 | 关键检查项 |
|----|------|-----------|
| B-1 | 路由注册 | 嵌套结构正确，name 命名规范 |
| B-2 | 页面文件结构 | index.vue / list.vue / add.vue 说明 |
| B-3 | Vuex Store 模块 | state 模板、actions 完整列出 |
| B-4 | API 字段映射表 | 后端字段 ↔ 前端字段，**特别标注分页响应字段名** |
| B-5 | 组件树 | 三层结构，组件选型说明 |
| B-6 | API 调用清单 | 所有接口的 Action/Method/Path/Request/Response |
| B-7 | 权限配置清单 | resourceCode 命名格式，菜单节点+按钮节点均列出 |

:::

## 前端共享惯例知识库

> 目录：`core/skills/frontend-conventions/`

前端共享惯例知识库（唯一权威源）。路由三层结构、Store 设计模式、权限规范、API 调用规则、组件规范、页面组件树——Arch/FE/Prototype 三个角色共同引用，消除知识重复。

> **Single Source of Truth**：本 Skill 定义前端路由、Store、权限、API 调用、组件的共享规范。
> `frontend-arch-design`（Arch 产出格式）、`frontend-create-module`（FE 执行步骤）、`frontend-prototype`（原型设计）均引用本文件。
> 任何规范变更只需修改此处，三个角色自动对齐。

::: details 查看完整定义


**前端共享惯例知识库**

> **Single Source of Truth**：本 Skill 定义前端路由、Store、权限、API 调用、组件的共享规范。
> `frontend-arch-design`（Arch 产出格式）、`frontend-create-module`（FE 执行步骤）、`frontend-prototype`（原型设计）均引用本文件。
> 任何规范变更只需修改此处，三个角色自动对齐。
>
> **UI 设计规范**：组件选型策略（vul-ui 优先三层决策）、设计 Token（色彩/字体/间距/圆角/阴影）、组件使用规范、交互与反馈规范、页面模板、业务组件开发规范、合规检查清单——详见 **frontend-ui-design** Skill。
> 本文件（frontend-conventions）聚焦路由/Store/权限/API 调用/组件树的架构规范。

---

**加载引导**

- **必加载场景**：Arch/FE/Prototype Agent 涉及前端工作时
- **可跳过场景**：纯后端任务
- **渐进式加载**：核心规范在本文件，详细参考见 `references/` 目录（按需读取）

**规范索引**

| 规范 | 速查 | 详情 |
|------|------|------|
| 路由设计 | 三层嵌套 + 壳页面写法 | → references/routing.md |
| Store 设计 | State 模板 + Actions 命名 + 编写模板 | → references/store-patterns.md |
| 权限配置 | resourceCode 命名 + resourceType 枚举 | → references/permission.md |
| API 调用 | 5 条规则 + 组件调用模式 | → references/api-calling.md |
| 组件规范 | 样式隔离 + 深度选择器 + Options API + 命名 + 通信 | → references/component-standards.md |
| 页面模板 | 列表页 + 编辑页 + 组件分层 + 性能优化 | → references/page-template.md |

**组件通用规范（速查）**

- **样式隔离**：必须加 `<style scoped>`，微前端环境下未隔离的样式会污染其他应用
- **深度选择器**：统一使用 `:deep(.class-name)`，禁用 `::v-deep`、`>>>`、`/deep/`
- **Options API**：使用 `data()`、`computed`、`methods`、`watch`，禁止 Composition API
- **命名**：文件名 PascalCase（如 `ConversationHistory.vue`），模板引用 kebab-case（如 `<conversation-history>`）
- **组件通信**：父子 `props + $emit`，跨组件 Vuex，微前端跨应用 `CustomEvent`（`beforeDestroy` 中必须 `removeEventListener`）
- **页面根容器**：背景色 `#fff`

:::

## 前端组件封装技能

> 目录：`core/skills/frontend-create-component/`

前端组件封装技能。适用于 Nuxt 2 / Vue 2 前端应用中新建 Vue 2 组件。

- 用户要求在前端项目中新建 Vue 组件
- 需要封装可复用的 UI 模式（卡片、弹窗、表单片段等）

::: details 查看完整定义


**前端组件封装技能**

**触发条件**
- 用户要求在前端项目中新建 Vue 组件
- 需要封装可复用的 UI 模式（卡片、弹窗、表单片段等）

**组件目录约定**

| 类型 | 推荐位置 | 说明 |
|------|---------|------|
| 通用组件 | `components/Common/` | 跨模块复用的基础组件 |
| 业务组件 | `components/<Domain>/` 或 `pages/<module>/` 子目录 | 特定业务域的组件 |

> 具体目录结构以项目 `.claude/context/components.md` 为准。

**组件模板**

```vue
<template>
  <div class="component-name">
    <!-- 内容 -->
  </div>
</template>

<script>
export default {
  name: 'ComponentName',
  props: {
    value: {
      type: [String, Number],
      default: '',
    },
  },
  data() {
    return {}
  },
  methods: {},
}
</script>

<style lang="scss" scoped>
.component-name {
}
</style>
```

**关键规则**

> 以下规则以 **frontend-conventions §5** 为权威源，本文件仅作快速参考。

1. **命名**：文件名 `PascalCase`（如 `ConversationHistory.vue`），模板引用 `kebab-case`（如 `<conversation-history>`）
2. **样式隔离**：必须加 `scoped`，微前端环境下未隔离的样式会污染其他应用
3. **深度选择器**：统一使用 `:deep(.class-name)`，禁用 `::v-deep`、`>>>`、`/deep/`
4. **组件通信**：
   - 父子通信：`props` + `$emit`
   - 跨组件共享状态：Vuex
   - 微前端跨应用通信（如适用）：`window.dispatchEvent(new CustomEvent(...))`，必须在 `beforeDestroy` 中 `removeEventListener`
5. **Options API**：使用 `data()`、`computed`、`methods`、`watch`，禁止 Composition API
6. **UI 规范合规**：新建组件必须遵循 `frontend-ui-design` §8 业务组件开发规范（特别是 §8.3 风格一致性 6 项硬约束），提交前通过 §10 合规检查清单自检

:::

## 前端模块创建技能

> 目录：`core/skills/frontend-create-module/`

前端模块创建技能。适用于 Nuxt 2 / Vue 2 前端应用中新增业务模块（路由 + Store + 页面）。

- 用户要求在前端项目中新增业务模块
- 需要新增路由 + Store + 列表/表单页面的完整模块

::: details 查看完整定义


**前端模块创建技能**

**触发条件**
- 用户要求在前端项目中新增业务模块
- 需要新增路由 + Store + 列表/表单页面的完整模块

**模块创建差异（微前端场景）**

| 步骤 | 宿主应用 | 子应用 |
|------|---------|--------|
| 路由 | 按宿主路由机制注册（可能是动态注册或 `pages/` 文件路由） | `router/routes.js` 中添加路由配置 |
| Store | `store/moduleName.js` | `store/moduleName.js` |
| 布局 | 需兼容全局侧边栏/抽屉推挤效果（如适用） | 标准布局 |

> 具体差异以各项目 `.claude/context/routes.md` 和 `.claude/context/stores.md` 为准。

**Store 模块模板**

> Action 命名约定与 HTTP 方法规则见 **frontend-conventions §2.2**。

```javascript
const state = () => ({
  service: '<service-prefix>',  // API 路径前缀，见项目特定配置 / frontend-conventions §2.1
  list: [],
  loading: false,
})

const mutations = {
  SET_LIST(state, list) {
    state.list = list
  },
}

const actions = {
  // 列表查询：POST + /list 后缀（见 frontend-conventions §2.2）
  async getXxxList({ state }, params = {}) {
    return await this.$axios({
      method: 'post',
      url: `${state.service}/xxx/list`,
      data: params,
    })
  },

  async addXxx({ state }, data) {
    return await this.$axios({ method: 'post', url: `${state.service}/xxx`, data })
  },

  async updateXxx({ state }, data) {
    return await this.$axios({ method: 'put', url: `${state.service}/xxx/${data.id}`, data })
  },

  async deleteXxx({ state }, ids) {
    return await this.$axios({ method: 'delete', url: `${state.service}/xxx?ids=${ids}` })
  },
}

export default { namespaced: true, state, mutations, actions }
```

**列表页标准套件（封装表格模式）**

```vue
<template>
  <div class="xxx-center">
    <search-form :form-list="commonSearch" :my-form="tableConfig.params"
      @changeForm="getList" @resetForm="resetForm" />
    <div class="grid-content">
      <operation :operation="operationObj" @operations="operationsFun" />
      <vul-table v-if="showTable" ref="table" v-bind="tableConfig"
        @selection-change="handleSelect" />
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      showTable: true,
      tableConfig: {
        uri: 'moduleName/getXxxList',  // Vuex dispatch 路径，不是 HTTP 路径
        params: {},
        columns: [
          { type: 'selection', width: 55 },
          { prop: 'name', label: '名称', minWidth: 150 },
          { prop: 'createTime', label: '创建时间', width: 180 },
        ],
      },
    }
  },
}
</script>
```

> 表格组件名和搜索组件名以项目实际封装为准，上述为常见模式。

**完成检查**
- [ ] 路由已在对应配置文件中注册
- [ ] Store 模块名为单数、与接口分类对齐
- [ ] 时间字段使用 `createTime` / `updateTime`
- [ ] 列表页使用封装表格 + `tableConfig.uri` 模式
- [ ] 接口失败未在业务层弹 `Message.error`
- [ ] 样式加了 `scoped`
- [ ] 组件选型已按 `frontend-ui-design` §2 三层决策树判定（vul-ui → Element UI → 自封装）
- [ ] 自检清单（`frontend-ui-design` §10）已通过

:::

## 前端原型设计知识库

> 目录：`core/skills/frontend-prototype/`

前端原型设计知识库。包含通用原型规范和页面模式骨架，供 prototype-agent 生成可运行的 Vue 原型页面。项目特有的组件 API 在 marker 下方填充。

> 本 Skill 为 prototype-agent 提供原型设计规范和页面模式参考。
> - marker 上方：框架通用规范（适用于所有项目）
> - marker 下方：项目特有的组件 API、色彩变量、参考页面索引（各项目自行填充）

::: details 查看完整定义


**前端原型设计知识库**

> 本 Skill 为 prototype-agent 提供原型设计规范和页面模式参考。
> - marker 上方：框架通用规范（适用于所有项目）
> - marker 下方：项目特有的组件 API、色彩变量、参考页面索引（各项目自行填充）

---

**1. 原型设计通用规范**

**1.1 原型的定位**

原型页面是**需求确认工具**，不是正式代码。目标是让用户在浏览器中直观看到页面结构、字段布局和交互流程，在正式开发前达成共识。

**1.2 文件存放与路由**

- 存放目录：`<目标App>/pages/prototype/<feature-name>.vue`
- 框架自动生成路由：`/prototype/<feature-name>`
- 多页面时可使用子目录：`pages/prototype/<feature>/list.vue`、`pages/prototype/<feature>/add.vue`
- 分支命名：`prototype/<feature-name>`

**1.3 Mock 数据策略**

原型使用静态 mock 数据，不依赖后端 API 或 Store：

```javascript
data() {
  return {
    // 列表 mock：填充 3-5 条有代表性的数据
    mockList: [
      { id: 1, name: '示例数据 1', status: 'active', createTime: '2026-01-01 10:00:00' },
      { id: 2, name: '示例数据 2', status: 'inactive', createTime: '2026-01-02 14:30:00' },
      { id: 3, name: '示例数据较长的名称用于测试溢出', status: 'active', createTime: '2026-01-03 09:15:00' },
    ],
    // 详情 mock
    mockDetail: { id: 1, name: '示例详情', description: '描述文本', status: 'active' },
    // 表单初始值
    form: { name: '', type: '', description: '' },
  }
}
```

**注意**：
- mock 数据的字段名和类型必须与需求 Spec 一致
- 包含边界数据（长文本、空值、特殊状态）以测试布局稳定性
- 如果项目的表格组件依赖 Store，原型中改用基础表格组件 + 静态数据

**1.4 交互占位**

```javascript
methods: {
  handleEdit(row) {
    console.log('[原型] 编辑', row)
    this.$message.info('编辑功能 - 待实现')
  },
  handleDelete(row) {
    console.log('[原型] 删除', row)
    this.$message.info('删除功能 - 待实现')
  },
  handleSubmit() {
    console.log('[原型] 提交表单', this.form)
    this.$message.success('提交成功 - 模拟')
  },
}
```

**1.5 从原型到正式代码的迁移**

FE Agent 在原型基础上直接修改（不重写）：

1. 将页面从 `pages/prototype/` 移动到正式目录
2. 替换基础表格为项目高级表格组件，接入真实数据源
3. 替换 mock 数据为 Store Action 调用
4. 补充交互逻辑（表单验证、API 调用、错误处理）
5. 删除 `console.log` 占位

---

**2. 四种标准页面模式（骨架）**

> 以下为通用骨架结构。具体组件名称和 API 参考 marker 下方的项目填充部分。

**模式 A：列表管理页**

```
┌────────────────────────────────────┐
│  搜索区（搜索表单组件）              │
├────────────────────────────────────┤
│  操作区（新建/删除/导入/导出按钮）    │
├────────────────────────────────────┤
│  表格区（数据表格 + 分页）           │
│  ┌──┬────────┬──────┬──────┬────┐ │
│  │☐ │ 名称   │ 状态  │ 时间  │操作│ │
│  ├──┼────────┼──────┼──────┼────┤ │
│  │☐ │ xxx    │ 启用  │ ...  │编辑│ │
│  └──┴────────┴──────┴──────┴────┘ │
│  共 X 条  < 1 2 3 ... >           │
└────────────────────────────────────┘
```

**关键要素**：搜索条件区 → 操作按钮组 → 数据表格（含选择框、排序、操作列）→ 分页

**模式 B：表单编辑页**

```
┌────────────────────────────────────┐
│  表单区（label-width 对齐）          │
│    名称：  [__________________]     │
│    类型：  [下拉选择 ▾]             │
│    描述：  [                  ]     │
│            [    多行文本       ]     │
│    标签：  [tag1] [tag2] [+]       │
├────────────────────────────────────┤
│           [取消]  [保存]  ← 吸底栏  │
└────────────────────────────────────┘
```

**关键要素**：表单字段区（可滚动）→ 底部操作栏（吸底定位）

**模式 C：弹窗表单**

```
┌─────── 弹窗标题 ──────── × ┐
│                              │
│  名称：  [______________]    │
│  类型：  [下拉选择 ▾]       │
│                              │
├──────────────────────────────┤
│         [取消]  [保存]       │
└──────────────────────────────┘
```

**关键要素**：Dialog + 内嵌表单 + 关闭时重置

**模式 D：详情页**

```
┌────────────────────────────────────┐
│  ← 返回   标题    [状态标签]        │
│  ─────────────────────────────────  │
│  ■ 基本信息                         │
│    名称：xxx     状态：启用          │
│    创建时间：xxx  更新时间：xxx       │
│  ─────────────────────────────────  │
│  ■ 描述                             │
│    详情文本内容...                   │
│  ─────────────────────────────────  │
│  [Tab1] [Tab2]                     │
│  关联数据表格...                     │
└────────────────────────────────────┘
```

**关键要素**：标题区（含状态标签）→ 信息卡片（grid 布局）→ Tab 切换区

---

**3. 样式通用规范**

- 页面根容器背景：白色（`#fff`）
- 必须使用 `<style scoped>`，防止样式污染
- 深度选择器按项目约定使用（如 `:deep()`）
- 间距、字体优先使用项目 SCSS 变量，不硬编码
- 设计 Token（色彩/字体/间距/圆角/阴影）必须引用 `frontend-ui-design` §3 定义，禁止硬编码
- 组件命名使用 PascalCase

---

**4. 填写指引**

marker 下方应由各项目填充以下内容（参考现有代码提取）：

**建议填充项**

1. **技术栈概览**：Vue 版本、UI 组件库名称和版本
2. **色彩与样式变量**：主色、功能色、文字色等
3. **核心组件 API**：搜索表单组件、操作按钮组件、表格组件、标签组件等的 Props/Events/用法
4. **完整页面模式代码**：基于骨架填充具体组件和样式
5. **参考页面索引**：现有代表性页面路径（按类型分类）

**提取方法**

1. 在项目 pages/ 目录中找到写得最规范的列表页、表单页、详情页
2. 提取其模板结构、组件用法、样式写法
3. 查看 components/ 目录中的公共组件，记录 Props 和 Events
4. 查看 assets/css/variables.scss（或等价文件），提取色彩变量

:::

## UI 设计规范（vul-ui 体系）

> 目录：`core/skills/frontend-ui-design/`

前端 UI 设计与组件选型规范（vul-ui / Element UI 体系）。涵盖组件选型三层决策树、设计 Token（色彩/字号/间距/圆角/阴影）、vul-ui 组件使用规范与视觉规格、交互反馈模式、页面模板、业务组件封装规范、合规检查清单。触发场景：写任何 .vue 文件、选组件、写样式、新建页面/路由/业务组件、重构页面 UI、不确定用哪个 Element UI 组件、不确定按钮/弹窗/表格怎么写、颜色间距字号该用什么值。即使用户没有明确提到"设计规范"，只要涉及前端 UI 编码决策就应阅读本规范。

> 版本：v1.8
> 适用范围：本仓库所有 Nuxt / Vue 2 前端，及未来新建子应用、新增页面、新建业务组件
> 基础组件库：**vul-ui**（基于 Element UI Vue 2 定制，包路径 `@huaun/vul-ui`）

::: details 查看完整定义


**UI 设计规范（vul-ui 体系）**

> 版本：v1.8
> 适用范围：本仓库所有 Nuxt / Vue 2 前端，及未来新建子应用、新增页面、新建业务组件
> 基础组件库：**vul-ui**（基于 Element UI Vue 2 定制，包路径 `@huaun/vul-ui`）
> Token 权威源：**公司 MasterGo 设计规范**（fileId=`87356408089452`）；各前端 `assets/css/variables.scss` 仅是实现侧落地参考，新项目无 variables.scss 时仍以设计稿为准
> 配套文档：[`element-ui-components.md`](./references/element-ui-components.md)

---

**序章：前端开发的强制约束（Hard Gate）**

**任何前端 Agent / 开发者在开始以下工作前必须完整阅读本文件**：

- 新建页面 / 路由
- 新建业务组件（`components/` 下任何 `.vue` 新文件）
- 重构现有页面 UI 结构
- 新接入子应用（含搭骨架）

阅读完成后才能进入：

- 调用 `frontend-create-component` / `frontend-create-module` 等技能
- 撰写 `03_impl_frontend.md`
- 落盘任何 `.vue` 文件

**冲突处理**：发现本规范与已有页面冲突时，**遵循本规范，旧页面进待重构清单**，严禁反向降低标准。

**前端 Agent 行为铁律**：

1. 接到任务先 `Read` 本文件 → 再读对应 App 的 `frontend_coding.md` → 再写代码
2. 选型必须先按 §2 的三层优先级走 vul-ui，禁止跳过
3. 自检清单未通过不得交付（→ Read [`references/checklist.md`](./references/checklist.md)）

---

**详细规范文件索引**

本规范采用**渐进式加载**：SKILL.md 是决策入口，详细规范按需读取。

| 当你需要… | 读取 |
|-----------|------|
| 色彩/字号/间距/圆角/阴影等 Token 值 | [`references/design-tokens.md`](./references/design-tokens.md) |
| 某个组件怎么用（Button/Form/Table/Dialog/Tag…）及视觉规格 | [`references/component-specs.md`](./references/component-specs.md) |
| 交互反馈模式、通用交互硬约束（按钮联动/删除确认/文字省略等） | [`references/interaction-patterns.md`](./references/interaction-patterns.md) |
| 封装业务组件的规则、代码目录规范 | [`references/component-development.md`](./references/component-development.md) |
| 提交前合规检查清单 | [`references/checklist.md`](./references/checklist.md) |
| Element UI 完整组件清单 | [`references/element-ui-components.md`](./references/element-ui-components.md) |
| 设计稿同步映射、变更记录 | [`references/design-sync-mapping.md`](./references/design-sync-mapping.md) |

---

**0. 规范定位与使用方式**

**定位**：本规范是**新建项目骨架、新页面、新业务组件**的硬约束。设计前必读 §1–§2，编码时对照详细规范文件。

**何时必须遵守**：

| 场景 | 是否强制 |
|------|---------|
| 新建子应用 / 新业务模块 | 强制 |
| 新建页面（路由级） | 强制 |
| 新建业务组件 | 强制 |
| 已有页面整页重构 | 强制 |
| 已有页面小修小补（文案 / 单字段调整） | 推荐遵守，不阻断 |
| Bug 修复（不涉及结构调整） | 不强制 |

---

**1. 设计原则**

1. **vul-ui 优先**：能用 vul-ui 解决的，禁止自造（详见 §2）。
2. **一致性优于创新**：同一仓库同类操作只用一种表达；按钮 / 链接二选一，不混用。
3. **少就是多**：高频操作上靠右，破坏性操作单独出挑，避免按钮堆叠。
4. **清晰可预期**：状态、反馈、加载、空态、错误态都必须显性，不允许白屏。
5. **可达性（A11y）**：交互元素必须可键盘操作，色彩对比度 ≥ 4.5:1，图标必须有 `aria-label` 或 `tooltip`。

---

**2. 组件选型策略（vul-ui 优先）**

**2.1 vul-ui 是什么**

- **vul-ui** 是公司内部基于 **Element UI**（Vue 2）定制的组件库
- 包路径：`@huaun/vul-ui`
- **API 与 Element UI 99% 一致**，标签名 `<el-button>` / `<el-form>` / `<el-table>` 等完全相同
- 主要差异（见附录 B）：
  - Primary 主色 `#1890ff`（非 Element 默认 `#409EFF`）
  - 字体族追加 `'PingFang SC'` / `'微软雅黑'`
  - 主文字色 `#00182e`、正文色 `rgba(60,84,113,1)`
  - 部分组件默认值微调（间距 / 圆角 / 阴影对齐本规范 Token）
- 文档：公司内网（无公开链接），实操参考已落地的页面 + Element UI 官方文档

**2.2 三层选型决策**

收到 UI 需求时，**按以下顺序判定组件来源**，禁止跳级：

```
① vul-ui 现有组件能完成？
   ├─ 是 → 直接使用，禁止重写、禁止 copy 源码改名
   └─ 否
       ↓
② Element UI 官方有同类组件？
   ├─ 是 → 用 Element UI 同名组件（vul-ui 通常已透传，无需额外引入）
   └─ 否
       ↓
③ 按 business component 规范自行封装
   - 内部必须用 vul-ui / Element UI 基础组件组合
   - Token、字体、间距、圆角、阴影必须沿用 Token 规范
   → Read references/component-development.md
```

**2.3 关键禁忌**

| 禁忌 | 替代做法 |
|------|---------|
| 引入第三方 UI 库（Ant Design Vue / Vant / Naive UI 等） | 用 vul-ui / Element UI |
| Copy vul-ui / Element UI 源码改名 | 用 slot + props 包装扩展 |
| 用 `div` + 手写样式模拟已有组件（自写 Modal / Dropdown / Popover） | 必用 vul-ui 提供的对应组件 |
| 锁死 vul-ui 小版本 | 跟随仓库统一升级 |
| 同一交互在不同页面用不同组件实现 | 统一选型，写入本规范 |

**2.4 自封装业务组件的硬约束**

当走到第 ③ 步时（vul-ui + Element UI 都没有），自封装的组件必须：

- **结构层**：内部用 vul-ui / Element UI 基础组件拼装，禁止从零写 DOM 模拟
- **样式层**：颜色 / 字体 / 间距 / 圆角 / 阴影 100% 取自 Token 规范，禁止裸 hex / 裸 px
- **行为层**：交互模式与同类型 vul-ui 组件保持一致
- **API 层**：props 命名沿用 Element UI 习惯（如 `size` / `type` / `disabled` / `v-model`）

详见 [`references/component-development.md`](./references/component-development.md)。

---

**3. 布局规范**

**3.1 栅格**

- 桌面端基准宽度 1440px，最小支持 1280px
- 使用 `<el-row :gutter="16">` + `<el-col :span="...">`
- 同一区块 `gutter` 保持一致（16 或 24）

**3.2 通用页面结构**

```
┌──────────────────────────────────┐
│  顶部导航（宿主提供，子应用不重复画） │  固定 60px
├────┬─────────────────────────────┤
│侧栏 │  面包屑                      │  48px
│    ├─────────────────────────────┤
│240 │  页面标题 + 页头操作         │  64px
│px  ├─────────────────────────────┤
│    │                              │
│    │  内容主区（白底）             │  flex-1
│    │                              │
└────┴─────────────────────────────┘
```

**3.3 页面根容器（硬约束）**

```vue
<template>
  <div class="page-xxx">
    <!-- 页面内容 -->
  </div>
</template>
<style lang="scss" scoped>
.page-xxx {
  min-height: 100%;
  padding: 20px 24px;
  background: #fff; /* ← 必须白色，禁止 #f5f7fa */
}
</style>
```

> **页面最外层背景必须白色**是 vul-ui 体系的硬约束。嵌套的分区块 / 卡片允许使用 `#f8f9fa`。

**3.4 微前端 / 宿主-子应用协作（如适用）**

仅在仓库使用 qiankun 或类似微前端方案时遵守：

- 子应用不重复绘制全局顶栏 / 侧栏
- 宿主主区因 AI 抽屉等开关产生右边距推挤时，大区域组件必须兼容 `margin-right` 动画
- 跨应用通信走 `window.dispatchEvent('huaun:xxx')`，禁止跨应用直接操作 DOM

---

**4. 页面模板**

**4.1 列表页（最常见）**

```
[面包屑]
[页面标题]                              [新建按钮]
─────────────────────────────────────────
[搜索 / 筛选条]
─────────────────────────────────────────
[表格]  ← 斑马 + 边框，行操作固定右
─────────────────────────────────────────
                                 [分页]
```

结构约束：
- 筛选条字段 ≤ 5，超出用"高级筛选"折叠
- 批量操作栏只在有选中时显示
- 列表必须有默认排序

**4.2 详情页**

```
[面包屑]
[页面标题 + 状态 Tag]                   [编辑] [更多操作]
─────────────────────────────────────────
[Descriptions 基本信息]
─────────────────────────────────────────
[Tabs: 详情 | 关联数据 | 操作日志]
```

**4.3 表单页**

- 新建 / 编辑独立路由或 Drawer（弹层选型 → Read [`references/component-specs.md`](./references/component-specs.md) §4）
- 分组用 `<el-divider content-position="left">分组标题</el-divider>`
- 字段 > 15 必须分组

**4.4 向导 / 多步流程**

- 使用 `<el-steps>` + 内容区 + 底部"上一步 / 下一步 / 完成"
- 每步必须可返回修改，不丢数据
- 最后一步显示完成页（Result 组件）

---

**附录 A：快速查表**

> Agent 最常用的入口。大多数场景查这张表就够了，需要详细规格时再读对应的 reference 文件。

| 我要做… | 用什么 | 详细规格 |
|--------|--------|---------|
| 显示一条成功提示 | `this.$message.success('…')` | component-specs.md §5 |
| 确认删除 | `el-popconfirm`（行内） / `this.$msgbox.confirm`（页级） | interaction-patterns.md §5.3 |
| 列表页 | Table + Pagination + Empty | component-specs.md §3 + §9 |
| 表单（8 字段以内） | Dialog + Form | component-specs.md §4 + §2 |
| 详情查看 / 长表单 | Drawer + Form / Descriptions | component-specs.md §4 |
| 多步操作 | Drawer + Steps | component-specs.md §4 |
| 空状态 | `el-empty` + 引导按钮 | interaction-patterns.md §3 |
| 加载态 | Skeleton（首屏） / Loading（局部） | interaction-patterns.md §2 |
| 标注属性（状态 / 分类） | Tag | component-specs.md §7 |
| 点击操作 | Button（不要用 Tag） | component-specs.md §1 |
| 树 + 多选 + 输入框 | vul-ui `ElementSelectTree`（不要自拼） | component-specs.md §6 |
| 业务组件兜底 | 自封装 + 6 项硬约束 | component-development.md |
| 查色值 / 间距 / 字号 | Token 表 | design-tokens.md |
| 提交前自检 | 合规检查清单 | checklist.md |

**附录 B：vul-ui 与 Element UI 官方默认差异**

| 项 | Element UI 默认 | vul-ui（本规范遵循） |
|----|----------------|--------------------|
| Primary 色 | `#409EFF` | `#1890ff` |
| Danger 色 | `#F56C6C` | `#FF4C4C`（2026-04 对齐设计稿，原 vul-ui 历史值 `#F1382A`） |
| 页面背景 | 允许 `#f5f7fa` | 必须 `#fff` |
| 字体族 | 官方默认 | 追加 `'PingFang SC'`, `'微软雅黑'` |
| 主文字色 | `#303133` | `#00182e` |
| 正文色 | `#606266` | `rgba(60,84,113,1)` |
| 复合树选择 | 无 | 扩展 `ElementSelectTree` |

> 差异来源：`@huaun/vul-ui` 定制。上表用于设计稿与实现对齐时参考。

**附录 C：前端 Agent 阅读路径**

针对 fe-agent / prototype-agent / arch-agent 的快速摘要：

| Agent / 角色 | 任务前必读 | 不可跳过的硬约束 |
|-------------|-----------|----------------|
| **arch-agent**（前端模式） | 本文件 + references/component-specs.md | §2.2 决策树、component-specs.md |
| **prototype-agent** | 本文件 + references/design-tokens.md | §2.2 决策树、design-tokens.md、component-specs.md |
| **fe-agent** | 本文件 + 按需读取所有 references/ | §2 选型、Token、白底、业务组件、checklist.md |
| **qa-agent**（前端 Review） | 本文件 + references/checklist.md | 用 checklist.md 作为 Review Checklist |

**最小接入示例**（在各 Agent 的 SKILL.md 顶部加一句）：

```markdown
> **开始任何前端任务前，必须 Read `core/skills/frontend-ui-design/SKILL.md`**
> - 设计 / 原型阶段至少读完 SKILL.md + references/design-tokens.md
> - 实现阶段按 SKILL.md 末尾的文件索引按需读取
> - 提交前必须按 references/checklist.md 逐项核对
```

:::

## Jira 任务管理集成

> 目录：`core/skills/jira-task-management/`

Jira 任务管理集成规范。定义各 Agent 在 SDD 工作流中如何使用 Jira MCP 工具进行需求关联、状态同步和缺陷管理。Jira 集成是可选的、非阻塞的。

本 Skill 定义了 SDD 工作流中各 Agent 如何与 Jira 交互。Jira 集成是**可选的、非阻塞的**——如果 Jira MCP Server 未配置或工具不可用，所有 Jira 操作将被静默跳过，不影响正常工作流。

::: details 查看完整定义


**Jira 任务管理集成**

**概述**

本 Skill 定义了 SDD 工作流中各 Agent 如何与 Jira 交互。Jira 集成是**可选的、非阻塞的**——如果 Jira MCP Server 未配置或工具不可用，所有 Jira 操作将被静默跳过，不影响正常工作流。

**前提条件**：项目根目录需配置 `.mcp.json`，包含 Jira MCP Server 的连接信息和凭据。

**项目配置**

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

**MCP 工具速查**

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

**各 Agent 使用规则**

**PM Agent — 需求关联**

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| Intake 收到 Jira Issue Key | `jira_search_issues` | 按 Key 查询，提取描述、验收标准、优先级、当前状态 |
| Intake 收到模糊需求描述 | `jira_search_issues` | 按关键词搜索相关 Issue，默认限定 `project = {projectKey}` |
| 需要了解项目 Issue 类型 | `jira_get_createmeta` | 获取项目支持的 Issue Type 和必填字段 |

**产出要求**：如果关联了 Jira Issue，在 `01_requirement.md` 头部添加：

```markdown
> **Jira Issue**: [SAIKG-1234](https://jira.huaun.com/browse/SAIKG-1234)
> **Issue Type**: Story | **Priority**: High | **Status**: To Do
```

**Arch Agent — 技术设计上下文**

**允许的操作**：只读

| 时机 | 操作 | 说明 |
|------|------|------|
| 开始技术设计 | `jira_search_issues` | 读取关联 Issue 的完整描述和评论，补充业务上下文 |
| 需要了解关联任务 | `jira_search_issues` | 查询 Epic 下的子任务，了解全貌 |

**Dev / FE Agent — 状态流转**

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

**QA Agent — 审查反馈**

**允许的操作**：评论 + 创建缺陷

| 时机 | 操作 | 说明 |
|------|------|------|
| Review PASS | `jira_add_comment` | 添加审查通过评论：QA Review PASS + 审查摘要 |
| Review FAIL | `jira_add_comment` | 添加审查不通过评论：QA Review FAIL + 阻碍点列表 |
| 发现新缺陷（可选） | `jira_create_issue` | 创建 Bug 类型 Issue，`fields.project.key` 使用配置的 `projectKey`，关联到原 Story |

**QA 评论格式**：

```
**QA Review: PASS**

- 审查模式：后端 / 前端 / 全栈
- Spec 达成率：100%
- 代码一致性：符合技术设计
- 代码质量：通过
- 审查时间：YYYY-MM-DD HH:mm
```

**主会话 — 首尾协调**

**允许的操作**：读取 + 状态流转

| 时机 | 操作 | 说明 |
|------|------|------|
| Intake 阶段 | `jira_search_issues` | 检测到 Issue Key 时读取详情 |
| 合并完成、收尾 | `jira_transition_issue` | 流转到 "Done" / "Closed" |

**JQL 查询模式**

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

**状态流转协议**

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

**降级策略**

当 Jira MCP 工具不可用时（未配置 `.mcp.json`、服务未启动、网络不可达）：

- 所有 Agent **静默跳过** Jira 操作，不产生错误或警告
- 工作流照常进行，Spec 文档中的 Jira Issue 字段留空
- 不要因为 Jira 不可用而中断任何工作流步骤
- 不要在输出中提示"Jira 连接失败"等信息（避免噪音）

:::

## Part E 测试场景模板

> 目录：`core/skills/part-e-templates/`

02_technical_design.md Part E 测试场景模板。包含后端 API 场景清单、全流程场景（可执行格式）和前端交互场景清单。供 Arch Agent 撰写 Part E 时参考。

> 本 Skill 提供 02_technical_design.md Part E 的标准模板。Arch Agent 撰写技术设计时按此格式编写测试场景清单，Dev/FE 基于此编写测试代码并产出 04_test_plan.md。

::: details 查看完整定义


**Part E 测试场景模板**

> 本 Skill 提供 02_technical_design.md Part E 的标准模板。Arch Agent 撰写技术设计时按此格式编写测试场景清单，Dev/FE 基于此编写测试代码并产出 04_test_plan.md。

**加载引导**

- **必加载场景**：Arch Agent 撰写 02_technical_design.md 时
- **可跳过场景**：其他 Agent 或 Arch 尚未进入 Part E 撰写阶段

---

Part E 写在 `02_technical_design.md` 的末尾（Part C 之后）。

**E-1: 后端 API 场景清单**

每个新增/修改的 API 端点必须列出正常、边界、错误三类场景：

```markdown
**E-1: [API 端点名] POST /api/xxx**

| # | 场景类型 | 场景描述 | 输入 | 预期输出 |
|---|---------|---------|------|---------|
| 1 | 正常 | 有效参数，操作成功 | `{...}` | `200, {...}` |
| 2 | 边界 | 必填字段为空/null | `{name: ""}` | `400, "名称不能为空"` |
| 3 | 边界 | 字段达到最大/最小长度 | `{name: "a"*100}` | 200 或 400 |
| 4 | 错误 | 业务规则冲突（如重复名称） | `{name: "已存在"}` | `400, "名称已存在"` |
| 5 | 错误 | 引用不存在的关联资源 | `{platformId: 999}` | `400, "平台不存在"` |
```

**E-2: 全流程场景（可执行格式，供 §8 运行验证 AI 自动执行）**

```markdown
**E-2: 全流程场景 — [业务流程名]**

| 步骤 | 操作 | 预期 |
|------|------|------|
| 1 | `POST /api/xxx {"name":"test"}` | 200, 返回 `{id}` |
| 2 | `GET /api/xxx/list?pageNumber=1&pageSize=10` | 200, 列表含 "test" |
| 3 | `PUT /api/xxx/{step1.id} {"name":"updated"}` | 200 |
| 4 | `DELETE /api/xxx/{step1.id}` | 200 |
| 5 | `GET /api/xxx/{step1.id}` | 404 或 data=null |
```

> `{stepN.id}` 表示引用步骤 N 的返回值，主会话运行验证时自动替换。

**E-3: 前端交互场景清单**

```markdown
**E-3: 页面交互场景 — [页面名]**

| # | 场景类型 | 场景描述 | 操作 | 预期 |
|---|---------|---------|------|------|
| 1 | 正常 | 表单正常提交 | 填写必填项→点提交 | 成功提示 + 列表刷新 |
| 2 | 边界 | 空表单提交 | 不填→点提交 | 表单校验红框 |
| 3 | 边界 | 列表为空 | 无数据 | 显示空状态占位 |
| 4 | 错误 | API 返回错误 | 触发后端错误 | 错误提示，不影响页面 |
```

:::

## QA 审查框架

> 目录：`core/skills/qa-review-framework/`

QA 审查框架。定义审查文件依赖清单、四轴（后端/前端）和五轴（全栈）审查标准、测试审计标准、审查自检清单。供 qa-agent 引用。

> 本 Skill 定义 QA Agent 的审查标准和工作流程。QA Agent 的角色特有红线和产出定义在 qa-agent.md 中。

::: details 查看完整定义


**QA 审查框架**

> 本 Skill 定义 QA Agent 的审查标准和工作流程。QA Agent 的角色特有红线和产出定义在 qa-agent.md 中。

**加载引导**

- **必加载场景**：QA Agent 启动审查时
- **可跳过场景**：其他 Agent

---

**审查文件依赖清单**

| 文件 | 产出者 | 用途 | 性质 |
|------|--------|------|------|
| `01_requirement.md` | PM | Spec 达成率的判断标准 | **审查标准** |
| `02_technical_design.md` | Arch | 代码一致性的判断标准 | **审查标准** |
| `03_impl_backend.md` | Dev | 后端执行日志 | 参考 |
| `03_impl_frontend.md` | FE | 前端执行日志 | 参考 |
| `04_test_plan.md` | Dev/FE | 测试覆盖完整性的审计标的 | **审计对象** |
| `evidences/` | Dev/FE | 自测证据 | 参考 |

> 03 是执行日志，不是审查标准。判断代码对错的标准只有 01 + 02。
> 工作流 A 只需读 backend，工作流 B 只需读 frontend，工作流 C 两者都要读。

**后端审查（工作流 A）**

**加载**：后端项目的 `coding_backend.md` + 审查规则（sql-checker、api-reviewer）

| 轴 | 检查内容 | 对标文件 |
|----|---------|---------|
| Spec 达成率 | AC 逐项核对，预期行为是否全部实现 | 01_requirement.md |
| 代码一致性 | API 端点、请求/响应结构、DB Schema 是否忠实于技术设计 | 02_technical_design.md |
| 代码质量 & 安全 | 分层合规、SQL 规范（禁拼接、必分页）、异常处理、日志脱敏 | coding_backend.md |
| 反过度设计 | YAGNI/KISS，空壳 Service 等过度抽象作为缺陷指出 | — |

**构建验证**：执行 CLAUDE.md 中定义的后端构建命令。

**测试审计**（针对 `04_test_plan.md`）：
1. 覆盖完整性 — 02 Part E 列出的每个场景，在 04 Part A 矩阵中是否都有对应测试
2. 测试有效性 — 抽查 2-3 个测试代码，断言是否真的验证了业务规则
3. 盲区补充 — 补充 Arch/Dev 未覆盖但 QA 认为重要的场景
4. 全流程可执行性 — 04 Part B 的 curl 命令格式是否正确、步骤是否完整
5. 边界用例覆盖 — 对照 spec-templates 的「边界用例必测清单」
6. 反模式检查 — 抽查是否存在「测实现不测行为」「测试间共享状态」「断言过弱」

**前端审查（工作流 B）**

**加载**：`coding_frontend_shared.md` + `frontend-ui-design/SKILL.md` + 目标 App 的 `frontend_coding.md`

| 轴 | 检查内容 | 对标文件 |
|----|---------|---------|
| Spec 达成率 | AC 逐项核对（含正常流程 + 异常状态 + 无权限/无数据） | 01_requirement.md |
| 代码一致性 | 路由/组件树/State/API 映射、B-4 字段映射表逐列核对（列是否存在、渲染方式 tag/tooltip/截断/mapper/状态点、列宽）是否忠实于技术设计 | 02_technical_design.md |
| 代码质量 & 安全 | scoped 强制、样式深度穿透规范、错误处理、权限码、UI 设计规范合规 | coding_frontend_shared.md + frontend-ui-design |
| 反过度设计 | 是否过度封装、是否复用了全局组件 | — |

**构建验证**：执行 `cd <目标App目录> && npm run lint`。

**测试审计**：
1. 覆盖完整性 — 02 Part E 列出的每个前端场景是否都有对应
2. 测试有效性 — 抽查单元测试代码
3. 盲区补充 — 补充未覆盖的场景
4. 人工验证清单完整性 — 04 Part B 操作步骤是否足够

**全栈审查（工作流 C）**

同时执行后端审查 + 前端审查，额外增加第五轴：

| 轴 | 检查内容 | 对标文件 |
|----|---------|---------|
| API 契约一致性 | 02 Part A 定义 vs 后端实际实现 vs 前端实际调用，三者一致；**后端响应封装类的分页数据序列化字段名必须与 Spec Response 示例一致，不得直接照搬 ORM 框架默认格式** | 02_technical_design.md Part A + Part B |

**审查自检（出具结论前必须执行）**

1. **是否真正逐项核对了 01 的每个 AC**？还是凭"大概看了没问题"就 PASS？
2. **是否比对了 02 的 API Schema / DB DDL / 组件树与实际代码**？还是只做了泛泛的代码 Review？
3. **04 测试审计**：是否抽查了至少 2 个测试代码，验证断言有效性？
4. **反过度设计**：是否检查了空壳 Service、不必要的中介层、过度封装？
5. **独立性**：审查结论是否受到 Dev/FE 自测结果的影响？

输出格式：
```
[QA 自检] AC逐项核对：✅/❌ | Schema比对：✅/❌ | 测试抽查：✅/❌ | 反过度设计：✅/❌ | 独立性：✅/❌
审查深度：已阅读 X 个变更文件，抽查 Y 个测试代码
```

:::

## SDD-RIPER-ONE Light

> 目录：`core/skills/sdd-riper-one-light/`

轻量 spec-driven / checkpoint-driven coding skill。用于高频、多轮的代码任务，强调最小 spec、先复述理解、执行前 checkpoint、明确批准、执行后回写。

- 面向强模型，默认自行分解任务、补足局部计划、按需追溯上下文。
- 主协议只保留少数高杠杆锚点，其余规范按需查看。
- 目标是减少低价值常驻 token，而不是减少控制力。

::: details 查看完整定义


**SDD-RIPER-ONE Light**

**核心定位**

- 面向强模型，默认自行分解任务、补足局部计划、按需追溯上下文。
- 主协议只保留少数高杠杆锚点，其余规范按需查看。
- 目标是减少低价值常驻 token，而不是减少控制力。
- Spec 的第一受众是人类（持久化的任务上下文），第二受众才是模型。

**硬约束**

- `Spec is Truth`：spec 是持久化上下文、压缩记忆与协作真相源。
- `No Spec, No Code`：未形成或更新最小 spec 前，不进入代码实现。
- `No Approval, No Execute`：未得到明确执行许可，不进入实现或高影响变更。
- `Restate First`：用户输入任务后，先用模型自己的话复述理解，再进入 spec 或计划。
- `Checkpoint Before Execute`：实现前必须给一次短 checkpoint，确认理解、目标、下一步、风险与验证方式。
- `Done by Evidence`：完成应由验证结果与外部反馈证明。
- `Reverse Sync`：执行后必须把结果、偏差、验证结论回写 spec。

**最小工作流**

1. **理解**：用模型自己的话复述用户任务，确保核心目标强一致
2. **Spec**：用最小 spec 固化目标、边界、计划与验证方式
3. **Checkpoint**：实现前给一次短 checkpoint（理解 + 目标 + 下一步 + 风险）
4. **批准**：等待用户明确批准
5. **执行**：进行代码实现
6. **回写**：执行后回写结果、偏差、验证结论

**任务深度**

- **零 Spec**：纯机械改动（typo、日志、配置），直接执行并 summary
- **快速 (Fast)**：1-3 句写清目标、文件、风险、验证方式，获批后执行
- **标准 (Standard)**：默认模式，维护轻量 spec，执行前 checkpoint，回写结论
- **深度 (Deep)**：需求模糊、架构改动等，显式分析并获批后再实施

**何时暂停**

- 需求存在关键歧义
- 需要破坏性/高风险操作
- 涉及架构/接口/数据模型变更
- 尚未形成最小 spec 或未得到明确执行许可

:::

## 两阶段自查清单

> 目录：`core/skills/self-test-checklist/`

Dev/FE 两阶段自查清单（合规检查 + 质量检查），按后端/前端模式提供具体检查项。完成后才能流转 QA。

> 本 Skill 定义 Dev 和 FE Agent 的两阶段自查标准。Agent 完成实现后、流转 QA 前必须逐项检查。
> 检查结果写入 `.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/evidences/`。

::: details 查看完整定义


**两阶段自查清单**

> 本 Skill 定义 Dev 和 FE Agent 的两阶段自查标准。Agent 完成实现后、流转 QA 前必须逐项检查。
> 检查结果写入 `.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/evidences/`。

**加载引导**

- **必加载场景**：Dev/FE Agent 进入 Self-Test 阶段时
- **可跳过场景**：其他 Agent 或尚未进入 Self-Test 阶段

---

**后端模式（Dev）**

**第一阶段：合规检查（Compliance）— 我做的和 Spec 一致吗？**

- [ ] API 路径、HTTP 方法、请求/响应字段与 `02 Part A` 逐一核对
- [ ] 数据库 Schema（建表/ALTER）与 `02 Part D` 一致
- [ ] Service/Controller 分层与 `02` 设计一致，无擅自合并或拆分
- [ ] 没有实现 Spec 之外的额外功能（YAGNI）

**第二阶段：质量检查（Quality）— 代码本身过关吗？**

- [ ] `mvn test` 所有单元测试通过（不允许 -DskipTests）
- [ ] 每个新增 Service 方法至少有一个对应测试（RED-GREEN-REFACTOR 已完成）
- [ ] 每个新增 Controller 端点至少有一个集成测试
- [ ] 02 Part E 的每个场景在测试代码中都有对应 test case
- [ ] 无注释掉的废弃代码
- [ ] 无遗漏的 TODO/FIXME
- [ ] 异常处理到位（直接抛 CommonException，无 null 语义不明）
- [ ] 日志中无密钥/Token/密码明文

---

**前端模式（FE）**

**第一阶段：合规检查（Compliance）— 我做的和 Spec 一致吗？**

- [ ] 路由路径与 `02 Part B` 的路由树逐一核对
- [ ] 组件树结构与 `02 Part B` 定义一致
- [ ] Vuex State/Getter/Action 与 `02 Part B` 字段映射一致
- [ ] 表格列定义（columns）与 `02 Part B` B-4 字段映射表逐列核对：列是否存在、渲染方式（tag/tooltip/截断/mapper/状态点）、列宽
- [ ] API 调用参数、URL、响应字段处理与 `02 Part A` 的 Contract 一致
- [ ] 没有实现 Spec 之外的额外功能（YAGNI）

**第二阶段：质量检查（Quality）— 代码本身过关吗？**

- [ ] `npm run lint` 无错误
- [ ] 构建验证通过（`npm run build` 或 `npm run generate`）
- [ ] 所有业务组件加了 `<style scoped>`
- [ ] Dialog 关闭时表单已重置
- [ ] 错误处理：无业务层重复弹出提示
- [ ] 新增按钮/页面已配置权限控制
- [ ] UI 设计规范合规：组件选型遵循 frontend-ui-design §2 决策树，颜色/间距/圆角引用 §3 Token，自检清单 §10 已逐项核对
- [ ] 02 Part E 的前端场景在验证清单中都有对应
- [ ] 新增 utils / store actions 有对应单元测试

---

**输出格式**

将两阶段检查结果写入 evidences/ 后，输出摘要：

```
[自查] 合规：✅/❌ | 质量：✅/❌
问题：[如有，列出具体项]
```

:::

## Spec 文档模板 (Spec Templates Skill)

> 目录：`core/skills/spec-templates/`

Spec 文档模板与编写规范。用于 PM/Arch/Dev/FE Agent 撰写规范化的需求、设计、实现文档。

> 本 Skill 由 PM/Arch/Dev/FE Agent 加载，用于指导 Spec 文档的编写与组织。

::: details 查看完整定义


**Spec 文档模板 (Spec Templates Skill)**

> 本 Skill 由 PM/Arch/Dev/FE Agent 加载，用于指导 Spec 文档的编写与组织。

**加载引导**

- **必加载场景**：PM/Arch/Dev/FE Agent 撰写 Spec 文档时
- **可跳过场景**：不涉及 Spec 撰写的任务
- **渐进式加载**：核心规范在本文件，各文档模板详见 references/ 目录

**目录结构**

每个 Feature/Fix 应创建一个 Spec 目录：

```
.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/
├── 01_requirement.md          # PM 撰写：业务需求与验收标准
├── 02_technical_design.md     # Arch 撰写：技术设计与实现方案
├── 03_impl_backend.md         # Dev 撰写：后端执行日志（如适用）
├── 03_impl_frontend.md        # FE 撰写：前端执行日志（如适用）
├── 04_test_plan.md            # Dev/FE 撰写：测试计划（追溯矩阵 + 全流程用例）
└── evidences/                 # QA 和主会话存放验证证据（含 QA 测试审计结论）
    ├── evidence-qa-review.md
    └── evidence-api-test.md
```

**模板索引**

| 文档 | 产出者 | 模板 |
|------|--------|------|
| 01_requirement.md | PM | [references/01-requirement.md](references/01-requirement.md) |
| 02_technical_design.md | Arch | [references/02-technical-design.md](references/02-technical-design.md) |
| 03_impl_*.md | Dev/FE | [references/03-impl.md](references/03-impl.md) |
| 04_test_plan.md | Dev/FE | [references/04-test-plan.md](references/04-test-plan.md) |

**列表（分页）接口标准响应结构（硬约定）**

> **跨项目契约**：后端分页包装器自动输出以下结构，写 Spec 时**必须**按此模板填充，禁止另行发明字段名。
> 详见后端编码规则的分页约定和前端共享编码规则 §4.1。

**Request**：
```json
{
  "pageNumber": 1,
  "pageSize":   20,
  "...": "业务过滤字段"
}
```

**Response**：
```json
{
  "code": 0,
  "message": "成功",
  "data": {
    "list":       [ /* VO 数组 */ ],
    "pageNumber": 1,
    "pageSize":   20,
    "pageTotal":  5,
    "total":      100
  }
}
```

**禁止**：ORM 框架原生别名（如 MyBatis-Plus 的 `records` / `current` / `size` / `pages`）；`page` / `limit` 等非标准别名。

**最佳实践**

1. **清晰的目标**：每个 Spec 都应有明确的业务目标和验收标准
2. **详细的 AC**：至少包括 1 个主流程 AC 和 2+ 个异常场景 AC
3. **完整的设计**：Arch 设计应涵盖 API Contract、DB Schema、前端设计等必要部分
4. **执行日志**：Dev/FE 应在实现过程中实时记录变更、决策和问题
5. **及时更新**：Spec 应在执行过程中及时更新以反映偏差和决策变化

:::

## SQL 审查规则 (SQL Checker Skill)

> 目录：`core/skills/sql-checker/`

SQL 审查规则与最佳实践。用于后端开发中的数据库操作规范验证。

> 本 Skill 由 Arch/Dev Agent 在处理数据库相关任务时加载，用于指导 SQL 设计与审查。

::: details 查看完整定义


**SQL 审查规则 (SQL Checker Skill)**

> 本 Skill 由 Arch/Dev Agent 在处理数据库相关任务时加载，用于指导 SQL 设计与审查。

**核心原则**

1. **禁止拼接**：严禁字符串拼接 SQL，必须使用参数化查询或 ORM
2. **分页必须**：所有列表查询必须分页
3. **复杂查询用 XML**：列表/多表查询必须用 Mapper XML，不在 Java 代码中硬编码
4. **索引优化**：新增字段或查询条件时，评估索引需求
5. **敏感脱敏**：日志中避免打印完整的敏感数据（如 password、token）

**SQL 编写规范**

**DDL（表结构定义）**

- 使用统一的字段命名规范（如 snake_case）
- 合理设置 NOT NULL、DEFAULT、UNIQUE 约束
- 关键查询字段必须有索引
- 时间戳字段应使用 `created_at`, `updated_at`
- 文本字段应明确指定字符集和排序规则

**DML（数据操作）**

- 使用 MyBatis/JPA 等 ORM，禁止拼接 SQL
- 列表查询必须包含 LIMIT offset, count
- UPDATE/DELETE 操作必须有明确的 WHERE 条件（防止全表操作）
- 批量操作考虑性能影响，适当分批处理

**查询优化**

- 避免 SELECT *，明确指定需要的列
- 使用 EXPLAIN PLAN 分析复杂查询的执行计划
- 避免在查询中使用函数操作索引列
- 合理使用 JOIN 而不是子查询（在大数据量场景）

**代码审查检查表**

- [ ] **拼接检查**：是否存在字符串拼接 SQL？
- [ ] **分页检查**：列表查询是否都加了 LIMIT？
- [ ] **参数化**：是否使用了 ? 或命名参数？
- [ ] **日志脱敏**：日志中是否打印了敏感信息？
- [ ] **事务处理**：多表操作是否在同一事务内？
- [ ] **错误处理**：是否妥善捕获和处理数据库异常？

:::

## Using Git Worktrees

> 目录：`core/skills/using-git-worktrees/`

Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

::: details 查看完整定义


**Using Git Worktrees**

**Overview**

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

**本项目约定**

- Worktree 目录：`.worktrees/`（已加入 .gitignore）
- 工作流 C 分支命名：
  - 后端 worktree：`.worktrees/feature-<name>-backend`，分支 `feature/<name>-backend`
  - 前端 worktree：`.worktrees/feature-<name>-frontend`，分支 `feature/<name>-frontend`
- 两个 worktree 完成后，由主会话合并到 `feature/<name>` 再推 develop
- 本项目无自动化测试基线，跳过 Verify Clean Baseline 步骤，直接报告 worktree 就绪

**Safety Verification**

创建 worktree 前，**必须验证目录已被 .gitignore 忽略**：

```bash
git check-ignore -q .worktrees 2>/dev/null
```

**如果未忽略**：先加入 .gitignore 并提交，再创建 worktree。

**Creation Steps**

**1. Create Worktree**

```bash
**后端 worktree（工作流 C）**
git worktree add .worktrees/feature-<name>-backend -b feature/<name>-backend
cd .worktrees/feature-<name>-backend/ai-kg-agent-hub

**前端 worktree（工作流 C）**
git worktree add .worktrees/feature-<name>-frontend -b feature/<name>-frontend
cd .worktrees/feature-<name>-frontend/<目标App目录>
```

**2. Run Project Setup（仅前端 worktree）**

前端 worktree 需要在**目标 App 目录**（非根目录）安装依赖：

```bash
cd .worktrees/feature-<name>-frontend/<目标App目录>
npm install
```

后端 worktree 无需额外 setup（Maven 构建时自动下载依赖）。

**3. Report Location**

```
Worktree ready at <full-path>
Ready to implement <feature-name>
```

**Quick Reference**

| Situation | Action |
|-----------|--------|
| `.worktrees/` 不存在 | 创建目录（已在 .gitignore 中） |
| 目录未被 .gitignore 忽略 | 先加入 .gitignore + commit |
| 前端 worktree | 在目标 App 目录跑 npm install |
| 后端 worktree | 无需 setup，直接开始 |
| QA 打回后需重建 | 重新 `git worktree add`，基于 feature/&lt;name&gt; 最新代码 |

**Common Mistakes**

**前端在根目录跑 npm install**

- **问题**：monorepo 根目录无 package.json 或安装了错误依赖
- **修正**：必须 cd 到具体 App 目录（如 `h-kg-agent-center/`）再 npm install

**忘记验证 .gitignore**

- **问题**：worktree 内容被 git 跟踪，污染 git status
- **修正**：创建前先 `git check-ignore -q .worktrees`

**Integration**

**Called by:**
- **dev-agent** (工作流 C) - REQUIRED before executing backend tasks in parallel
- **fe-agent** (工作流 C) - REQUIRED before executing frontend tasks in parallel

:::

