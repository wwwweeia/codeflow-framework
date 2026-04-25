---
title: OpenCode CLI 迁移指南
description: 将 codeflow-framework 的 .claude 模板体系适配到 OpenCode CLI 的完整映射与操作指南
prev: /resources/codex-migration
next: false
---

# OpenCode CLI 迁移指南

> **背景**：团队当前使用 Claude Code + codeflow-framework 的 `.claude/` 模板体系。当需要在 [OpenCode](https://opencode.ai) CLI 中复用同一套 Spec-Driven Development 工作流规范时，需要对配置格式做适配。本文档是手动迁移的操作手册。

---

## 一、核心结论：能不能直接用？

**大部分能直接用，少量字段需调整。**

| 结论 | 说明 |
|------|------|
| **CLAUDE.md 零改动可用** | OpenCode 内置 Claude Code 兼容层，没有 `AGENTS.md` 时自动 fallback 到 `CLAUDE.md` |
| **全局 Rules 零改动可用** | `~/.claude/CLAUDE.md` 同样有 fallback 支持 |
| **Agents 几乎直搬** | `.opencode/agents/*.md` 格式与 `.claude/agents/*.md` 高度一致（YAML frontmatter + Markdown body），只需调整字段名 |
| **Commands 几乎直搬** | `.opencode/commands/*.md` 格式与 `.claude/commands/*.md` 几乎一样 |
| **Rules 可直搬** | 通过 `instructions` 数组引用，内容无需修改 |
| **Skills 部分兼容** | 全局 `~/.claude/skills/` 自动支持，项目级 skills 需通过 `instructions` 引用 |
| **配置文件需重写** | `.claude/settings.json` → `opencode.json`（JSON/JSONC），格式完全不同 |

**与 Codex CLI 迁移对比**：

| 维度 | Codex CLI | OpenCode |
|------|-----------|----------|
| CLAUDE.md | 必须改名为 AGENTS.md | **零改动 fallback** |
| Agent 定义 | 必须拆为 config.toml + AGENTS.md 段落 | **Markdown 直搬**，微调字段 |
| Commands | 必须转为 Skills | **Markdown 直搬**，微调字段 |
| Skills | 改路径即可 | 全局自动支持，项目级需适配 |
| 总体工作量 | **中高** | **低** |

---

## 二、体系对照表

### 2.1 概念映射

| 概念 | Claude Code | OpenCode | 兼容程度 |
|------|------------|----------|----------|
| **项目指令文件** | `CLAUDE.md`（根目录） | `AGENTS.md`（根目录）/ `CLAUDE.md`（fallback） | **直接兼容** |
| **全局指令** | `~/.claude/CLAUDE.md` | `~/.config/opencode/AGENTS.md` / `~/.claude/CLAUDE.md`（fallback） | **直接兼容** |
| **项目配置** | `.claude/settings.json` | `opencode.json`（JSON/JSONC） | 格式不同 |
| **Agent 定义** | `.claude/agents/*.md` | `.opencode/agents/*.md` 或 `opencode.json` 的 `agent` 字段 | **高度兼容** |
| **Commands** | `.claude/commands/*.md` | `.opencode/commands/*.md` 或 `opencode.json` 的 `command` 字段 | **高度兼容** |
| **Rules** | `.claude/rules/*.md` | `instructions` 数组引用 或 `AGENTS.md` 段落 | 可直搬 |
| **Skills** | `.claude/skills/*/SKILL.md` | `~/.claude/skills/`（兼容层）/ `instructions` 引用 | 部分兼容 |
| **Context/Codemap** | `.claude/context/*.md` | `instructions` 数组引用 | 可直搬 |

### 2.2 工具对照

| Claude Code 工具 | 功能 | OpenCode 等价 |
|-----------------|------|---------------|
| `Read` | 读取文件 | 默认支持 |
| `Write` | 写入文件 | `tools.write: true` |
| `Edit` | 编辑文件 | `tools.edit: true` |
| `Grep` | 搜索内容 | 默认支持 |
| `Glob` | 文件匹配 | 默认支持 |
| `Bash` | 执行命令 | `tools.bash: true`，权限可细粒度控制 |
| `Agent` | 启动子 Agent | 子代理（subagent），通过 `@mention` 或 Task 工具调用 |

### 2.3 权限对照

| Claude Code | OpenCode |
|-------------|----------|
| `allowed-tools: Bash(git add:*)` | `permission.bash: { "git add *": "allow" }` |
| `allowed-tools: Read, Grep, Glob` | 默认允许（读取始终可用） |
| 无沙箱 | `tools.write/edit/bash: true/false` 精细控制 |

OpenCode 权限值：`"allow"`（允许）/ `"ask"`（需确认）/ `"deny"`（禁用）。

---

## 三、目录结构对照

### Claude Code 现有结构

```
项目根/
├── CLAUDE.md                        # 项目指令
├── .claude/
│   ├── settings.json                # 项目配置
│   ├── agents/                      # Agent 定义
│   │   ├── pm-agent.md
│   │   ├── dev-agent.md
│   │   └── ...
│   ├── commands/                    # 命令定义
│   │   ├── commit.md
│   │   └── ...
│   ├── rules/                       # 规则文件
│   │   ├── project_rule.md
│   │   ├── merge_checklist.md
│   │   └── ...
│   ├── skills/                      # 技能文件
│   │   ├── api-reviewer/SKILL.md
│   │   └── ...
│   └── context/                     # 上下文文件
│       └── ...
```

### OpenCode 目标结构

```
项目根/
├── AGENTS.md                        # 项目指令（也可保留 CLAUDE.md 作为 fallback）
├── opencode.json                    # 项目配置（JSON/JSONC）
├── .opencode/
│   ├── agents/                      # Agent 定义（Markdown）
│   │   ├── pm.md
│   │   ├── dev.md
│   │   └── ...
│   └── commands/                    # 命令定义（Markdown）
│       ├── commit.md
│       └── ...
├── .claude/                         # 可保留原目录，OpenCode 自动 fallback
│   ├── rules/                       # 通过 instructions 引用
│   ├── skills/                      # 全局 skills 自动支持
│   └── context/                     # 通过 instructions 引用
```

**关键差异**：
- 配置从 `.claude/settings.json` 变为根目录的 `opencode.json`
- Agent 和 Command 文件从 `.claude/` 移到 `.opencode/`
- Rules 和 Context 通过 `opencode.json` 的 `instructions` 字段引用，无需移动
- 可以**保留原 `.claude/` 目录不动**，两套工具并行使用

---

## 四、逐步迁移指南

### 4.1 CLAUDE.md → AGENTS.md（可零改动）

**最快方案：什么都不改。**

OpenCode 的文件查找优先级：

1. `AGENTS.md`（优先）
2. `CLAUDE.md`（fallback）

如果项目中没有 `AGENTS.md`，OpenCode 会自动使用 `CLAUDE.md`。**所以不创建 `AGENTS.md` 就能直接用。**

**推荐方案：创建 AGENTS.md 保持正式性**

如果希望明确使用 OpenCode 格式，复制 `CLAUDE.md` 内容到 `AGENTS.md` 即可，无需文本替换——OpenCode 不依赖 Claude 专属工具名。

### 4.2 Agents 迁移（几乎直搬）

这是改动最小的部分之一。两边都是 YAML frontmatter + Markdown body。

**Claude 格式**（以 `dev-agent.md` 为例）：

```yaml
---
name: dev-agent
description: You are a Backend Development Manager...
tools: [Read, Grep, Glob, Write, Edit, Bash]
model: sonnet
skills:
  - domain-ontology
  - backend-rules
  - api-reviewer
---

[行为描述 Markdown 正文]
```

**OpenCode 格式**（`.opencode/agents/dev.md`）：

```yaml
---
description: Backend Development Manager — 根据 Spec 实现后端功能
mode: subagent
model: anthropic/claude-sonnet-4-20250514
tools:
  write: true
  edit: true
  bash: true
---

[行为描述 Markdown 正文 — 不需要改]
```

**字段映射**：

| Claude Code 字段 | OpenCode 字段 | 处理方式 |
|-----------------|--------------|---------|
| `name: dev-agent` | 文件名 `dev.md` | **删除** — 文件名即 Agent 名 |
| `description` | `description` | **保留**，建议改为简短描述 |
| `tools: [Read, Grep, ...]` | `tools: {write: true, ...}` | **格式转换** — 从列表变为布尔对象 |
| `model: sonnet` | `model: provider/model-id` | **格式转换** — 如 `anthropic/claude-sonnet-4-20250514` |
| `skills: [...]` | 无直接对应 | 通过 `instructions` 引用或移除 |
| _(无)_ | `mode: subagent` / `primary` | **新增** — 决定 Agent 类型 |
| _(无)_ | `temperature` | **可选新增** |
| _(无)_ | `steps` | **可选新增** — 最大迭代次数 |
| _(无)_ | `permission` | **可选新增** — 细粒度权限 |

**tools 字段详细映射**：

| Claude Code `tools` 列表 | OpenCode `tools` 对象 |
|--------------------------|----------------------|
| 含 `Write` | `write: true` |
| 含 `Edit` | `edit: true` |
| 含 `Bash` | `bash: true` |
| `Read`, `Grep`, `Glob` | 无需设置（默认可用） |

**操作步骤**：

1. 将 `.claude/agents/dev-agent.md` 复制到 `.opencode/agents/dev.md`
2. 修改 YAML frontmatter（按上表映射）
3. 正文内容无需修改

**所有 Agent 的推荐配置**：

```jsonc
// opencode.json — Agent 定义（也可用 Markdown 文件）

{
  "agent": {
    "pm": {
      "description": "Product Manager — 需求分析、Spec 产出、Intake 三问",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": false },
      "temperature": 0.3
    },
    "arch": {
      "description": "Architect — 技术设计、架构评审、工作流路由",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": false },
      "temperature": 0.2
    },
    "dev": {
      "description": "Backend Dev — 根据 Spec 实现后端功能、TDD 循环",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true },
      "temperature": 0.3
    },
    "fe": {
      "description": "Frontend Dev — 根据 Spec 实现前端功能、组件开发",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true },
      "temperature": 0.3
    },
    "qa": {
      "description": "QA — 测试用例设计、质量保障、四轴审查",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": false, "edit": false, "bash": false },
      "temperature": 0.1
    },
    "prototype": {
      "description": "Prototype — 前端原型快速验证",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true },
      "temperature": 0.3
    },
    "e2e": {
      "description": "E2E — 端到端测试",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true },
      "temperature": 0.2
    }
  }
}
```

### 4.3 Commands 迁移（几乎直搬）

两边 Commands 的 Markdown 格式几乎一样。

**Claude 格式**（以 `commit.md` 为例）：

```yaml
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)
argument-hint: [message]
description: 创建带上下文的 Git 提交
---

## 上下文
- 当前 git 状态: !`git status`
...
```

**OpenCode 格式**（`.opencode/commands/commit.md`）：

```yaml
---
description: 创建带上下文的 Git 提交
agent: build
model: anthropic/claude-sonnet-4-20250514
---

## 上下文
- 当前 git 状态: !`git status`
...
```

**字段映射**：

| Claude Code 字段 | OpenCode 字段 | 处理方式 |
|-----------------|--------------|---------|
| `description` | `description` | **保留** |
| `allowed-tools: ...` | 无直接对应 | **删除** — 通过 Agent 的 `permission` 或 `tools` 控制 |
| `argument-hint: [message]` | 无需设置 | **删除** — 模板中直接用 `$ARGUMENTS` |
| _(无)_ | `agent` | **新增** — 指定执行命令的 Agent |
| _(无)_ | `model` | **可选新增** — 覆盖默认模型 |
| _(无)_ | `subtask` | **可选新增** — 是否以子任务方式运行 |

**正文差异**：

| 功能 | Claude Code | OpenCode |
|------|------------|----------|
| 参数 | `$ARGUMENTS` | `$ARGUMENTS`（相同） |
| Shell 输出 | `!`command`` | `!`command``（相同） |
| 文件引用 | `@file` | `@file`（相同） |
| 位置参数 | 不支持 | `$1`, `$2`, `$3`... |

**好消息：正文模板语法几乎完全兼容，`!`command`` 和 `$ARGUMENTS` 都直接可用。**

### 4.4 Rules 迁移（通过 instructions 引用）

OpenCode 没有 `.claude/rules/` 目录概念，但有更灵活的 `instructions` 机制。

**方案一：`instructions` 数组引用（推荐）**

在 `opencode.json` 中引用现有 rules 文件：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".claude/rules/project_rule.md",
    ".claude/rules/merge_checklist.md",
    ".claude/rules/framework_protection.md",
    ".claude/rules/level_gateway.md"
  ]
}
```

**好处：无需移动文件，原 `.claude/rules/` 保持不动。**

**方案二：合并到 AGENTS.md**

将 rules 内容作为 AGENTS.md 的章节写入（与 Codex CLI 迁移方式相同）。

### 4.5 Skills 迁移

**全局 Skills（零改动）**

OpenCode 通过 Claude Code 兼容层自动支持 `~/.claude/skills/`。

**项目级 Skills（两种方案）**

方案一：通过 `instructions` 引用 SKILL.md 文件：

```jsonc
{
  "instructions": [
    ".claude/skills/api-reviewer/SKILL.md",
    ".claude/skills/sql-checker/SKILL.md",
    ".claude/skills/spec-templates/SKILL.md",
    ".claude/skills/domain-ontology/SKILL.md",
    ".claude/skills/backend-rules/SKILL.md",
    ".claude/skills/frontend-conventions/SKILL.md",
    ".claude/skills/sdd-riper-one-light/SKILL.md"
  ]
}
```

方案二：将 Skill 内容拆入对应 Agent 的 prompt 文件中，通过 Agent 的 `prompt` 字段引用。

---

## 五、opencode.json 完整示例

对应框架各 Agent 的推荐配置：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",

  // ── 模型选择 ──────────────────────────────────────────
  "model": "anthropic/claude-sonnet-4-20250514",
  "small_model": "anthropic/claude-haiku-4-20250514",

  // ── 默认 Agent ────────────────────────────────────────
  "default_agent": "build",

  // ── 全局权限 ──────────────────────────────────────────
  "permission": {
    "edit": "ask",
    "bash": "ask"
  },

  // ── 全局工具 ──────────────────────────────────────────
  "tools": {
    "write": true,
    "bash": true
  },

  // ── 指令文件引用 ──────────────────────────────────────
  "instructions": [
    ".claude/rules/project_rule.md",
    ".claude/rules/merge_checklist.md",
    ".claude/rules/framework_protection.md",
    ".claude/rules/level_gateway.md",
    ".claude/skills/domain-ontology/SKILL.md",
    ".claude/skills/spec-templates/SKILL.md",
    ".claude/skills/sdd-riper-one-light/SKILL.md"
  ],

  // ── Agent 定义（对应框架七角色）─────────────────────────
  "agent": {
    "pm": {
      "description": "Product Manager — 需求分析、Spec 产出、Intake 三问",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": false },
      "temperature": 0.3
    },
    "arch": {
      "description": "Architect — 技术设计、架构评审、工作流路由",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": false },
      "temperature": 0.2
    },
    "dev": {
      "description": "Backend Dev — 根据 Spec 实现后端功能",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true },
      "permission": {
        "bash": {
          "*": "ask",
          "git status *": "allow",
          "git diff *": "allow",
          "git add *": "allow",
          "git log *": "allow"
        }
      }
    },
    "fe": {
      "description": "Frontend Dev — 根据 Spec 实现前端功能",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true },
      "permission": {
        "bash": {
          "*": "ask",
          "git status *": "allow",
          "git diff *": "allow"
        }
      }
    },
    "qa": {
      "description": "QA — 测试和质量保障、四轴审查",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": false, "edit": false, "bash": false },
      "temperature": 0.1
    },
    "prototype": {
      "description": "Prototype — 前端原型快速验证",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true }
    },
    "e2e": {
      "description": "E2E — 端到端测试",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "write": true, "edit": true, "bash": true }
    }
  },

  // ── 命令定义 ──────────────────────────────────────────
  "command": {
    "commit": {
      "template": "创建带上下文的 Git 提交。分析当前变更，按 conventional commits 格式提交。\n当前 git 状态:\n!`git status`\n!`git diff`",
      "description": "创建带上下文的 Git 提交",
      "agent": "dev"
    }
  },

  // ── 压缩策略 ──────────────────────────────────────────
  "compaction": {
    "auto": true,
    "prune": true,
    "reserved": 10000
  }
}
```

---

## 六、文本替换清单

相比 Codex CLI 迁移，OpenCode 需要的替换非常少。

### Agent Frontmatter 替换

| Claude 字段 | 替换为 | 说明 |
|-------------|--------|------|
| `name: dev-agent` | _(删除)_ | 文件名即 Agent 名 |
| `tools: [Read, Grep, ...]` | `tools: {write: true, ...}` | 列表→布尔对象 |
| `model: sonnet` | `model: anthropic/claude-sonnet-4-20250514` | 加 provider 前缀 |
| `skills: [...]` | _(删除)_ | 通过 instructions 引用 |
| _(无)_ | `mode: subagent` | 新增必填 |
| _(无)_ | `description: "..."` | 新增必填 |

### Command Frontmatter 替换

| Claude 字段 | 替换为 | 说明 |
|-------------|--------|------|
| `allowed-tools: ...` | _(删除)_ | 通过 Agent permission 控制 |
| `argument-hint: ...` | _(删除)_ | 模板中用 `$ARGUMENTS` |

### 正文替换

**好消息：OpenCode 的正文几乎不需要替换。** 两边都支持 `!`command``（Shell 输出）和 `$ARGUMENTS`（参数），文件引用语法也一致。

唯一需要注意的是 Agent 引用方式变化：

| 原文 | 替换为 |
|------|--------|
| `启动 PM Agent` | `@pm <任务描述>` |
| `使用 Agent 工具启动` | `@<agent-name>` |

---

## 七、验证方法

### 7.1 检查文件加载

```bash
# 启动 OpenCode，验证规则文件被加载
opencode run "列出当前项目加载的所有指令文件和 Agents"
```

预期输出应包含：
- `AGENTS.md`（或 `CLAUDE.md`）的内容摘要
- `instructions` 引用的各 rules 文件内容
- 各 Agent 的 `description`

### 7.2 检查 Agent 可用

```bash
# 在 TUI 中按 Tab 键查看可切换的 Agent
opencode
# 或列出子代理
opencode run "@general 列出所有可用的 Agent 及其描述"
```

预期：列出 pm、arch、dev、fe、qa、prototype、e2e 等 Agent。

### 7.3 测试核心工作流

1. **Intake 三问**：输入一个功能需求，验证是否触发 Intake 流程
2. **Agent 切换**：使用 `@pm` 切换到 PM Agent 产出需求文档
3. **命令执行**：在 TUI 中输入 `/commit` 测试自定义命令
4. **权限控制**：验证 QA Agent 无法编辑文件

### 7.4 排查问题

| 现象 | 原因 | 解决 |
|------|------|------|
| CLAUDE.md 没加载 | 同时存在 AGENTS.md | AGENTS.md 优先级更高，检查是否为空 |
| Agent 列表为空 | `.opencode/agents/` 目录不存在 | 创建目录并放入 Agent 文件 |
| Commands 不显示 | `.opencode/commands/` 目录不存在 | 创建目录并放入 Command 文件 |
| instructions 未加载 | 路径不对或文件不存在 | 使用相对于 `opencode.json` 的路径 |
| Agent 无法编辑文件 | `tools.write: false` | 检查 Agent 的 tools 配置 |
| Claude Code 兼容被禁用 | 环境变量 `OPENCODE_DISABLE_CLAUDE_CODE=1` | 移除该环境变量 |

---

## 八、Claude Code 兼容层详解

OpenCode 的 Claude Code 兼容层是本次迁移的核心优势。详细行为：

### 优先级规则

```
1. AGENTS.md            → 找到就用，停止查找
2. CLAUDE.md            → fallback（仅当无 AGENTS.md 时）
3. ~/.config/opencode/AGENTS.md  → 全局规则（优先）
4. ~/.claude/CLAUDE.md          → 全局 fallback
```

### 禁用兼容层

如果需要完全切换到 OpenCode 原生格式：

```bash
# 禁用所有 .claude 支持
export OPENCODE_DISABLE_CLAUDE_CODE=1

# 只禁用 ~/.claude/CLAUDE.md
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1

# 只禁用 .claude/skills
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
```

### 最小迁移策略

如果想以最小成本试用 OpenCode：

1. **不创建任何新文件** — 直接在项目目录运行 `opencode`
2. OpenCode 自动 fallback 到 `CLAUDE.md`
3. Rules 通过 `instructions` 引用
4. Agent 和 Command 逐步迁移，不急

---

## 九、后续规划

当前是手动迁移阶段。如果团队确认 OpenCode 会长期使用，后续可考虑：

1. **自动化转换脚本**：`tools/convert-claude-to-opencode.sh`，从 `core/` 自动生成 `.opencode/` 结构
2. **双轨 upgrade 脚本**：在现有 `upgrade.sh` 基础上，增加 `--target opencode` 选项，同时生成 `.opencode/` 目录
3. **共享内容层**：将工具无关的工作流逻辑提取到 `core/shared/`，Claude Code 和 OpenCode 两套配置共用
