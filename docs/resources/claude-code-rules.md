---
title: Claude Code Rules 精华整理
description: 规则系统：指令规则与权限规则详解
prev: false
next:
  link: /resources/claude-code-skills
---

> 来源：极客时间《Claude Code 工程化实战》第 20 讲
> 作者：黄佳

---

## 一、两种规则，两个世界

| | 指令规则 | 权限规则 |
|--|---------|---------|
| **定位** | 员工手册（"代码提交前必须跑测试"） | 门禁系统（没卡就进不了机房） |
| **本质** | Claude 的**认知约束** | 客户端的**行为约束** |
| **实现** | 注入 System Prompt | 客户端硬拦截 |
| **遵守** | Claude 可以遵守，也可以忘记 | Claude 连尝试的机会都没有 |
| **文件** | `CLAUDE.md`、`.claude/rules/*.md` | `settings.json` permissions |

> **核心比喻：** 指令规则告诉 Claude "你应该怎么做"；权限规则告诉 Claude "你被允许做什么"。

---

## 二、指令规则——`.claude/rules/` 完全指南

### 本质

`rules/` 目录下每个 `.md` 文件，本质是一段被注入 System Prompt 的文本。和 `CLAUDE.md` 没有本质区别，唯一的结构化优势是：**可以按主题拆分多个文件 + 支持条件加载**。

### 两种加载模式

#### 模式一：全局加载（无 `paths` 字段）

```yaml
# security.md —— 没有 YAML 头部，或有头部但不含 paths

## 安全规范
- 不在代码中硬编码密码或 API Key
- 所有用户输入必须做 sanitize
```

会话启动时就加载进上下文，行为和写在 `CLAUDE.md` 里完全一样。拆出来的唯一好处是文件组织更清晰。

#### 模式二：条件加载（有 `paths` 字段）

```yaml
---
paths:
  - "src/**/*.test.ts"
  - "tests/**/*.ts"
---

# 测试规范

## 命名
- 单元测试: `*.test.ts`
- 集成测试: `*.integration.test.ts`

## 结构
使用 Arrange-Act-Assert 模式
```

**关键规则：** paths 控制的是"何时加载"，不是"何时生效"。一旦加载，就不会卸载。

```
会话开始
→ 加载全局 rules（无 paths 的）
→ testing.md 未加载 ✗

用户：帮我改一下 src/utils/format.ts
→ Claude 读取 format.ts
→ paths 不匹配，testing.md 仍未加载 ✗

用户：帮我给这个函数写个测试
→ Claude 创建 src/utils/format.test.ts
→ paths 匹配！testing.md 加载 ✓

用户：再帮我改一下 CSS
→ Claude 读取 styles.css
→ testing.md 仍在上下文中 ✓（不会卸载）
```

### 何时从 CLAUDE.md 拆分到 rules？

```
CLAUDE.md 的总长度如何？
│
├── < 200 行 → 不拆，CLAUDE.md 一把梭
│   简单就是好，不要为了组织而组织
│
├── 200-500 行 → 考虑拆
│   └── 有没有"只和特定文件类型相关"的内容？
│       ├── 有 → 拆出来，加 paths
│       │   （如测试规范、前端规范、API 规范）
│       └── 没有 → 拆出来，不加 paths
│           （纯粹为了文件组织清晰）
│
└── > 500 行 → 必须拆
    CLAUDE.md 太长会稀释重要信息的权重
    把领域规范拆到 rules，CLAUDE.md 只留核心约定
```

### 标准 rules 目录结构

```
.claude/
├── settings.json            ← 权限规则（团队共享）
├── settings.local.json     ← 个人权限覆盖（.gitignore）
└── rules/
    ├── coding.md           ← 全局编码规范（无 paths）
    ├── frontend.md         ← 前端规范（paths: src/components/**）
    ├── backend.md          ← 后端规范（paths: server/**）
    ├── testing.md          ← 测试规范（paths: **/*.test.*）
    └── security.md         ← 安全规范（无 paths，全局生效）
```

### 全栈项目拆分示例

**CLAUDE.md（精简到 80 行以内）：**
```markdown
# 项目概述
全栈 TypeScript 项目。前端 React 18 + Tailwind，后端 Express + Prisma + PostgreSQL。

# 命令
- `pnpm dev` — 启动前后端开发服务器
- `pnpm test` — 运行全部测试
- `pnpm lint` — ESLint + Prettier 检查
- `pnpm db:migrate` — 执行数据库迁移

# 核心约定
- 包管理器用 pnpm，不做 npm 或 yarn
- commit message 用 conventional commits 格式
- 所有 API 返回 { success: boolean, data?: T, error?: string }
- 环境变量通过 .env 管理，不硬编码

# 详细规范
领域规范见 claude/rules/ 目录 按文件类型自动加载
```

**`.claude/rules/frontend.md`：**
```yaml
---
paths:
  - "src/components/**"
  - "src/pages/**"
  - "src/hooks/**"
---

# 前端规范

## 组件
- 函数式组件，不用 class 组件
- Props 用 interface 定义，命名 XxxProps
- 组件文件和样式文件同名同目录

## 状态管理
- 局部状态用 useState
- 跨组件状态用 Zustand
- 服务端状态用 TanStack Query

## 样式
- Tailwind 优先，复杂样式用 CSS Modules
```

**`.claude/rules/backend.md`：**
```yaml
---
paths:
  - "server/**"
  - "src/api/**"
  - "prisma/**"
---

# 后端规范

## 路由
- RESTful 风格，资源名用复数
- 路由文件放 server/routes/，一个资源一个文件

## 数据库
- 所有查询通过 Prisma ORM，不写原生 SQL
- 迁移文件不手动编辑
- 关联查询用 include，不用多次查询

## 错误处理
- 业务错误抛 AppError(code, message)
- 统一在 errorHandler 中间件中捕获
```

**`.claude/rules/testing.md`：**
```yaml
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
---

# 测试规范

## 工具
- 单元测试：Vitest
- 组件测试：Testing Library
- E2E：Playwright

## 结构
- Arrange-Act-Assert 模式
- 每个 describe 对应一个函数或组件
- Mock 外部依赖，不 mock 内部模块

## 覆盖率
- 业务逻辑 > 80%
- 工具函数 > 90%
```

**`.claude/rules/security.md`（无 paths，全局生效）：**
```markdown
# 安全规范

- 用户输入在使用前必须 validate + sanitize
- SQL 参数化（Prisma 默认做到了）
- XSS 防护：不使用 dangerouslySetInnerHTML
- CORS 只允许白名单域名
- 敏感信息（API Key、数据库密码）只放 .env
- 认证 token 用 httpOnly cookie，不存 localStorage
```

---

## 三、权限规则——行为管控的硬约束

### 基本结构

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Read"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(curl *)",
      "Edit(.env)"
    ]
  }
}
```

### 评估顺序

**deny → ask → allow。** 第一个匹配的规则胜出，deny 总是优先。即使你在 allow 里写了 `Bash(rm -rf *)`，如果 deny 里也有这条，deny 赢。

### 覆盖的工具范围

```markdown
Bash(command pattern)    → 控制 Shell 命令的执行
Read(file pattern)       → 控制文件的读取
Edit(file pattern)       → 控制文件的编辑
Write(file pattern)      → 控制文件的创建
WebFetch(domain:pattern) → 控制网页抓取的域名范围
WebSearch               → 控制是否允许网络搜索
mcp__server__tool       → 控制 MCP 工具的使用
Skill(skill-name)       → 控制 Skill 的调用
Task(agent-name)        → 控制子代理的调用
```

### 配置层级体系

| 层级 | 位置 | 说明 |
|------|------|------|
| 用户级 | `~/.claude/settings.json` | 个人配置 |
| 项目级 | `.claude/settings.json` | 团队共享 |
| 本地覆盖 | `.claude/settings.local.json` | 个人临时覆盖 |
| 组织级 | （企业配置） | 高优先级 |

> **关键规则：** 高层级的 deny 不可被低层级覆盖。如果组织策略禁止了 `Bash(curl *)`，项目配置和个人配置都无法解除这个限制。

### 权限安全基线（适用于大多数团队）

```jsonc
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(npm run *)", "Bash(pnpm *)",
      "Bash(git status)", "Bash(git diff *)", "Bash(git log *)",
      "Bash(node *)", "Bash(npx *)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(* --force)",
      "Bash(curl *)", "Bash(wget *)",
      "Read(./.env)", "Read(./.env.*)",
      "Edit(./.env)", "Edit(./.env.*)",
      "Read(~/.ssh/*)", "Read(~/.aws/*)"
    ]
  }
}
```

---

## 四、权限规则在扩展机制中的渗透

权限规则不仅存在于 `settings.json`，还渗透到了 Claude Code 各扩展机制：

### 1. Skills 的 `allowed-tools`

Skill 被触发时只能使用白名单中的工具：
```yaml
---
name: code-reviewing
description: Review code for quality and security issues
allowed-tools:
  - Read
  - Grep
  - Glob
---
```

### 2. Sub-Agents 的 `tools`

子代理的工具集被裁剪，甚至拿不到主对话的 `CLAUDE.md`：
```yaml
---
name: code-reviewer
tools: Read, Grep, Glob
model: sonnet
---
```

### 3. Hooks 的动态拦截

最灵活的权限控制，可以根据动态条件决定是否放行：
```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "./hooks/block-dangerous.sh" }
        ]
      }
    ]
  }
}
```

---

## 五、四层纵深防御体系

```
工具调用请求
  ↓
第一关：settings.json 的 deny 规则
  → 命中？直接拦截，不可绕过
  ↓
第二关：Hooks 的 PreToolUse 拦截
  → 脚本返回非零？拦截，可自定义逻辑
  ↓
第三关：Skill/Agent 的 allowed-tools 限制
  → 不在白名单？拦截
  ↓
第四关：settings.json 的 allow 规则 / 用户交互审批
  → 在白名单？自动放行
  → 不在任何规则中？弹窗询问用户
  ↓
工具执行
```

---

## 六、两种规则协同——支付服务完整案例

### 场景：React + Express + Stripe 全栈支付服务

**指令规则（CLAUDE.md）：**
```markdown
# 支付服务
Node.js + TypeScript + Stripe API，处理用户支付流程。

# 命令
- `pnpm dev` — 启动开发服务器
- `pnpm test` — 运行测试
- `pnpm lint` — 代码检查

# 核心约定
- 所有金额用 cents（整数），不用浮点数
- 日志必须包含 requestId，便于追踪
- 不在日志中打印卡号、CVV 等敏感信息
```

**`.claude/rules/stripe.md`：**
```yaml
---
paths:
  - "src/payments/**"
  - "src/webhooks/**"
---

# Stripe 集成规范

## Webhook 处理
- 始终验证 webhook 签名（stripe.webhooks.constructEvent）
- 幂等处理：用 event.id 去重
- 先返回 200，再异步处理业务逻辑

## 错误处理
- StripeCardError → 返回用户友好消息
- StripeRateLimitError → 指数退避重试
- 其他 Stripe 错误 → 记录日志 + 告警
```

**权限规则（`.claude/settings.json`）：**
```jsonc
{
  "permissions": {
    "allow": [
      "Bash(pnpm *)", "Bash(git status)", "Bash(git diff *)", "Bash(git log *)",
      "Read", "Glob", "Grep"
    ],
    "deny": [
      "Bash(curl *)", "Bash(wget *)",          // 防止 Claude 自行调用外部 API
      "Read(./.env)", "Read(./.env.*)",       // 保护 Stripe Secret Key
      "Edit(./.env)", "Edit(./.env.*)",
      "Bash(rm -rf *)", "Bash(* --force)",    // 防止破坏性操作
      "Bash(stripe *)"                        // 防止用 Stripe CLI 操作生产环境
    ]
  }
}
```

**两道规则各司其职：**
- 指令规则（认知层面）→ "处理 webhook 要验签、金额用 cents"
- 权限规则（系统层面）→ "不许读 .env、不许执行 stripe CLI"
- 两者互补：即使 Claude "忘记"了不在日志中打印卡号的要求，权限规则也能确保它无法读取 `.env`。

---

## 七、常见错误清单

| 错误 | ❌ 错误做法 | ✅ 正确做法 |
|------|-----------|-----------|
| **规则放错地方** | `rules/security.md` 里写"禁止执行 rm -rf" | 在 `settings.json` deny 中写 `Bash(rm -rf *)` |
| **用错配置文件** | `settings.json` 里写"用 TypeScript 写代码" | 在 `CLAUDE.md` 或 `rules/*.md` 中写编码规范 |
| **rules 文件矛盾** | `coding.md` 说"缩进用 2 空格"，`frontend.md` 说"缩进用 4 空格" | 全局规范放 `coding.md`，领域规范只写领域特有的 |
| **paths 粒度不当** | `paths: ["**/*"]`（太宽，等于没写） | `paths: ["src/components/**"]`（合理粒度） |
| **子代理继承错误** | 期望子代理自动遵守 `.claude/rules/` 中的规范 | 把关键规范写进子代理的 Markdown body 或通过 Skills 注入 |

---

## 八、Rules 在架构中的定位

> **"规则"不是架构中的一个方块，而是渗透在每一层中的横切关注点。**

| 层次 | 规则类型 | 位置 |
|------|---------|------|
| **指令层** | 认知约束 | `CLAUDE.md`、`.claude/rules/` |
| **能力层** | 能力边界 | Skills 的 `allowed-tools`、Agent 的 `tools` |
| **管控层** | 行为硬约束 | `settings.json permissions`、Hooks、CLI 参数 |

---

## 九、核心金句

> - "指令规则是 Claude 的认知约束，权限规则是客户端的行为约束。"
> - "指令规则像公司的员工手册——员工可以遵守，也可以偷懒。权限规则像门禁系统——没有卡就进不了机房，系统不给你选择。"
> - "指令规则让 Claude 做对，权限规则让 Claude 做不了错。两者协同，才是完整的规则体系。"
> - "Rules 不是独立组件，是横切关注点，它渗透在 Memory、Tools、Skills、SubAgents、Hooks 每一讲中。"
> - "CLAUDE.md 超过 200 行就考虑拆分，超过 500 行必须拆分。3-5 个 rules 文件是最佳规模。"

---

## 十、Rules vs Skills vs Hooks 对比

| 维度 | Rules（指令规则） | Skills | Hooks |
|------|------------------|--------|-------|
| **本质** | 认知约束（"应该怎么做"） | 领域能力（"具备什么知识"） | 行为拦截（"不许做/必须做"） |
| **生效** | 软约束（LLM 可能忘记） | 按需激活 | 硬拦截（代码强制） |
| **加载时机** | 会话开始 / 访问特定文件时 | 命令触发 | 工具调用时 |
| **存放位置** | `CLAUDE.md` / `.claude/rules/` | `.claude/commands/` / `~/.workbuddy/skills/` | `settings.json` / frontmatter |
| **与 Claude 的关系** | Claude 能"看到" | Claude 能"使用" | Claude 不知道它的存在 |
