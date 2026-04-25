---
title: Codex CLI 迁移指南
description: 将 codeflow-framework 的 .claude 模板体系适配到 OpenAI Codex CLI 的完整映射与操作指南
prev: /resources/framework-retrospective-v2
next: false
---

# Codex CLI 迁移指南

> **背景**：团队当前使用 Claude Code + codeflow-framework 的 `.claude/` 模板体系。当需要在 OpenAI Codex CLI 中复用同一套 Spec-Driven Development 工作流规范时，需要对格式做适配。本文档是手动迁移的操作手册。

---

## 一、核心结论：能不能直接用？

**不能直接用，但改动比想象中小。**

| 结论 | 说明 |
|------|------|
| **Skills 几乎直搬** | `SKILL.md` 的 YAML frontmatter（`name` + `description`）两边格式一样，只改目录路径 |
| **Rules 可直搬** | 写入 `AGENTS.md` 即可，纯文本内容无格式依赖 |
| **Commands 需转为 Skills** | Codex 没有 Command 概念，每个 Command 变成一个 Skill |
| **Agents 需拆分** | Claude 的单文件 Agent 需拆成 `config.toml` 配置 + `AGENTS.md` 行为段落 |
| **工具引用需替换** | `Read/Grep/Glob` 等是 Claude 专属工具名，Codex 不认识 |

---

## 二、体系对照表

### 2.1 概念映射

| 概念 | Claude Code | Codex CLI | 兼容程度 |
|------|------------|-----------|----------|
| **项目指令文件** | `CLAUDE.md`（根目录） | `AGENTS.md`（根目录） | 内容可复用 |
| **全局指令** | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | 内容可复用 |
| **项目配置** | `.claude/settings.json` | `.codex/config.toml` | 格式不同 |
| **Agent 定义** | `.claude/agents/*.md` | `config.toml` 的 `[agents.<name>]` | 需拆分 |
| **Skills** | `.claude/skills/*/SKILL.md` | `.agents/skills/*/SKILL.md` | 高度兼容 |
| **Commands** | `.claude/commands/*.md` | 转为 `.agents/skills/*/SKILL.md` | 需转换 |
| **Rules** | `.claude/rules/*.md` | 写入 `AGENTS.md` 段落 | 可直搬 |
| **Context/Codemap** | `.claude/context/*.md` | 写入 `AGENTS.md` 或独立 Skill | 可直搬 |

### 2.2 工具对照

| Claude Code 工具 | 功能 | Codex CLI 等价操作 |
|-----------------|------|-------------------|
| `Read` | 读取文件 | 默认支持（sandbox 内可读） |
| `Write` | 写入文件 | `sandbox_mode = "workspace-write"` 后自动支持 |
| `Edit` | 编辑文件 | 同上 |
| `Grep` | 搜索内容 | 默认支持 |
| `Glob` | 文件匹配 | 默认支持 |
| `Bash` | 执行命令 | 按 `approval_policy` 决定是否需要确认 |
| `Agent` | 启动子 Agent | `[agents]` 配置 + spawn |

### 2.3 权限对照

| Claude Code | Codex CLI |
|-------------|-----------|
| `allowed-tools: Bash(git add:*)` | `approval_policy = "never"` 或 granular policy |
| `allowed-tools: Read, Grep, Glob` | 默认允许（所有模式下都可读） |
| 无沙箱 | `sandbox_mode = "read-only"` / `"workspace-write"` / `"danger-full-access"` |

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
│   │   ├── sql-checker/SKILL.md
│   │   └── ...
│   └── context/                     # 上下文文件
│       └── ...
```

### Codex CLI 目标结构

```
项目根/
├── AGENTS.md                        # 项目指令（合并 rules + context）
├── .codex/
│   └── config.toml                  # 全局配置 + Agent 定义
├── .agents/
│   └── skills/                      # Skills（含原 Commands 转换）
│       ├── api-reviewer/SKILL.md
│       ├── sql-checker/SKILL.md
│       ├── commit/SKILL.md          # ← 原 commands/commit.md
│       └── ...
```

**关键变化**：
- `CLAUDE.md` → `AGENTS.md`
- `rules/` 内容合并到 `AGENTS.md`
- `commands/` 每个文件转为一个 Skill
- `agents/` 的元数据拆到 `config.toml`，行为描述合入 `AGENTS.md`

---

## 四、逐步迁移指南

### 4.1 CLAUDE.md → AGENTS.md

**操作**：复制 `CLAUDE.md` 内容到 `AGENTS.md`，执行以下文本替换。

| 替换项 | 原文示例 | 替换为 |
|--------|---------|--------|
| 指令文件名 | `CLAUDE.md` | `AGENTS.md` |
| 目录路径 | `.claude/rules/project_rule.md` | `AGENTS.md 的"工作流规则"段落` |
| 工具调用 | `使用 Read 工具读取` | `读取` |
| 工具调用 | `使用 Grep 搜索` | `搜索` |
| 工具调用 | `使用 Edit 工具修改` | `修改` |
| Agent 引用 | `启动 PM Agent` | `使用 PM 角色`（Codex 通过 spawn agent 实现） |
| 子 Agent | `子 Agent` | `spawn agent` 或 `agent thread` |

**替换示例**：

```markdown
# 替换前（Claude Code 风格）
1. 阅读 CLAUDE.md 了解项目结构
2. 使用 Read 工具读取 01_requirement.md
3. 使用 Grep 搜索相关实现
4. 启动 PM Agent 产出需求文档

# 替换后（Codex 兼容风格）
1. 阅读 AGENTS.md 了解项目结构
2. 读取 01_requirement.md
3. 搜索相关实现
4. 切换到 PM 角色产出需求文档
```

### 4.2 Agents → config.toml + AGENTS.md 段落

Claude 的 Agent 是一个 `.md` 文件，包含 YAML frontmatter（元数据）+ 正文（行为描述）。Codex 需要拆为两部分。

**步骤 1：从 Agent 文件提取元数据，写入 `config.toml`**

Claude 格式（以 `dev-agent.md` 为例）：

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
```

对应的 Codex `config.toml`：

```toml
[agents.dev]
description = "Backend Development Manager — 根据已审批的 Spec 实现后端功能"
config_file = "./agents/dev.toml"
nickname_candidates = ["Dev"]
```

对应的 `agents/dev.toml`：

```toml
model = "gpt-5.5"
sandbox_mode = "workspace-write"
approval_policy = "on-request"
```

**步骤 2：行为描述写入 `AGENTS.md` 的对应段落**

```markdown
# AGENTS.md

## Agent: Dev（后端研发经理）

你是本项目的后端研发经理 (Dev)，负责后端项目的代码实现。

### 行为准则
1. Spec is Truth, Design is Guide
2. 发现问题立即停止
3. YAGNI/KISS — 严禁过度设计
...
```

**所有 Agent 的 config.toml 参考**：

```toml
# .codex/config.toml — Agent 定义

[agents.pm]
description = "Product Manager — 需求分析和 Spec 产出"
config_file = "./agents/pm.toml"

[agents.arch]
description = "Architect — 技术设计和架构评审"
config_file = "./agents/arch.toml"

[agents.dev]
description = "Backend Dev — 根据 Spec 实现后端功能"
config_file = "./agents/dev.toml"

[agents.fe]
description = "Frontend Dev — 根据 Spec 实现前端功能"
config_file = "./agents/fe.toml"

[agents.qa]
description = "QA — 测试和质量保障"
config_file = "./agents/qa.toml"
```

### 4.3 Skills 迁移（几乎直搬）

这是改动最小的部分。Codex 的 Skill 格式与 Claude Code 几乎一致。

**操作步骤**：

1. 将 `.claude/skills/` 下的每个目录复制到 `.agents/skills/`
2. `SKILL.md` 文件的 YAML frontmatter 保持不变（`name` + `description`）
3. 替换正文中的 Claude 工具引用

**替换前后对比**（以 `api-reviewer/SKILL.md` 为例）：

```yaml
# 不需要改（YAML frontmatter 完全兼容）
---
name: api-reviewer
description: REST API 设计与审查规则。用于后端 API 端点的设计与实现验证。
---
```

```markdown
# 正文只需替换工具引用
# 替换前：
使用 Grep 搜索项目中的 API 路由定义
使用 Read 读取 Controller 文件

# 替换后：
搜索项目中的 API 路由定义
读取 Controller 文件
```

**可选增强**：添加 `agents/openai.yaml` 配置隐式触发：

```yaml
# .agents/skills/api-reviewer/agents/openai.yaml
interface:
  display_name: "API 审查"
  short_description: "REST API 设计与审查规则"

policy:
  allow_implicit_invocation: true  # 任务匹配 description 时自动触发
```

### 4.4 Commands → 转为 Skills

Codex 没有 Command 概念。每个 Command 变成一个 Skill，通过 `$skill-name` 显式调用或隐式触发。

**转换模板**（以 `commit.md` 为例）：

Claude 格式：

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

Codex 格式（`.agents/skills/commit/SKILL.md`）：

```yaml
---
name: commit
description: 创建带上下文的 Git 提交。当用户要求 commit、提交代码时触发。
---

# Git 提交规范

分析当前变更，按照 conventional commits 格式创建提交。

## 提交信息格式

- `feat:` 新功能
- `fix:` 修复 bug
- `docs:` 文档变更
- `refactor:` 代码重构
- `test:` 新增测试
- `chore:` 维护任务

## 操作步骤

1. 运行 `git status` 查看当前变更
2. 运行 `git diff` 查看具体修改
3. 分析变更，生成合适的提交信息
4. 执行 `git add` 暂存相关文件
5. 执行 `git commit` 提交
```

**`allowed-tools` 映射到权限配置**：

```toml
# config.toml — commit 命令需要写权限和执行 git 命令
sandbox_mode = "workspace-write"

# 或使用 granular policy 更精细控制
approval_policy = { granular = { sandbox_approval = true } }
```

### 4.5 Rules → 合并到 AGENTS.md

Rules 是纯文本规则，没有格式依赖，直接作为 `AGENTS.md` 的章节写入。

```markdown
# AGENTS.md

## 工作流调度规则

> 来自原 `.claude/rules/project_rule.md`

### Intake 触发规则（硬约束）
收到任何涉及"新增/修改/删除功能"的需求时，第一句话必须是 Intake 三问...

### 智能路由
...

---

## 合并检查清单

> 来自原 `.claude/rules/merge_checklist.md`

- [ ] 代码已通过自测
- [ ] 单元测试覆盖
...

---

## 框架保护规则

> 来自原 `.claude/rules/framework_protection.md`

禁止修改 marker 上方的框架管理内容...
```

---

## 五、config.toml 完整示例

对应框架各 level 的推荐配置：

```toml
# .codex/config.toml

# ── 模型选择 ──────────────────────────────────────────
model = "gpt-5.5"

# ── 权限与沙箱 ──────────────────────────────────────
approval_policy = "on-request"
sandbox_mode = "workspace-write"

# ── 项目文档 ──────────────────────────────────────────
project_doc_max_bytes = 65536  # 框架内容较多，调大上限

# ── Agent 定义（对应框架各角色）─────────────────────────
[agents.pm]
description = "Product Manager — 需求分析、Spec 产出、Intake 三问"
config_file = "./agents/pm.toml"

[agents.arch]
description = "Architect — 技术设计、架构评审、工作流路由"
config_file = "./agents/arch.toml"

[agents.dev]
description = "Backend Dev — 根据 Spec 实现后端功能、TDD 循环"
config_file = "./agents/dev.toml"

[agents.fe]
description = "Frontend Dev — 根据 Spec 实现前端功能、组件开发"
config_file = "./agents/fe.toml"

[agents.qa]
description = "QA — 测试用例设计、质量保障、审查"
config_file = "./agents/qa.toml"

[agents]
max_threads = 3     # 同一时间最多 3 个 Agent
max_depth = 1       # 嵌套深度限制

# ── Skills 配置 ───────────────────────────────────────
# 可按需禁用特定 Skill
# [[skills.config]]
# path = ".agents/skills/confluence-doc-sync/SKILL.md"
# enabled = false
```

---

## 六、文本替换清单

迁移时需要全局替换的 Claude 专属引用：

### 工具名替换

| 原文（Claude 专属） | 替换为（工具无关） |
|---------------------|-------------------|
| `使用 Read 工具读取` | `读取` |
| `使用 Write 工具写入` | `写入` |
| `使用 Edit 工具编辑` | `编辑` |
| `使用 Grep 搜索` | `搜索` |
| `使用 Glob 查找` | `查找` |
| `使用 Bash 执行` | `执行` |
| `使用 Agent 工具启动` | `spawn agent` |

### 路径替换

| 原文 | 替换为 |
|------|--------|
| `CLAUDE.md` | `AGENTS.md` |
| `.claude/rules/` | `AGENTS.md 的对应章节` |
| `.claude/agents/` | `config.toml 的 [agents] 段` |
| `.claude/commands/` | `.agents/skills/` |
| `.claude/skills/` | `.agents/skills/` |
| `.claude/context/` | `AGENTS.md 的对应章节` |
| `.claude/specs/` | `specs/`（保持不变） |

### YAML Frontmatter 处理

| 字段 | 处理方式 |
|------|---------|
| `tools: [...]` | **删除**（Codex 用 config.toml 控制权限） |
| `model: sonnet` | **移到 config.toml** 的 `model` 字段 |
| `skills: [...]` | **删除**（Codex 自动发现 `.agents/skills/`） |
| `allowed-tools: ...` | **移到 config.toml** 的 `approval_policy` |
| `argument-hint: ...` | **删除**（Codex 通过 description 触发） |
| `name:` / `description:` | **保留**（两边格式一致） |

---

## 七、验证方法

### 7.1 检查文件加载

```bash
# 启动 Codex，验证 AGENTS.md 被加载
codex --ask-for-approval never "列出当前加载的所有指令文件和 Skills"
```

预期输出应包含：
- `AGENTS.md` 的内容摘要
- 各个 Skill 的 `name` 和 `description`

### 7.2 检查 Skills 发现

```bash
# 在 TUI 中使用 /skills 命令查看可用 Skills
codex
# 输入 /skills
```

预期：列出所有迁移过来的 Skills（api-reviewer、sql-checker、commit 等）。

### 7.3 测试核心工作流

1. **Intake 三问**：输入一个功能需求，验证 Codex 是否触发 Intake 流程
2. **Spec 产出**：确认 PM 角色能产出需求文档
3. **Git 提交**：使用 `$commit` 或自然语言触发提交 Skill
4. **API 审查**：使用 `$api-reviewer` 触发 API 审查规则

### 7.4 排查问题

| 现象 | 原因 | 解决 |
|------|------|------|
| AGENTS.md 没加载 | 文件为空或路径不对 | 确认文件在项目根目录且有内容 |
| Skills 列表为空 | 目录路径不对 | 确认在 `.agents/skills/` 下 |
| 工具调用失败 | sandbox 限制 | 调整 `sandbox_mode` |
| 指令被截断 | 超过 32KB | 调大 `project_doc_max_bytes` |

---

## 八、后续规划

当前是手动迁移阶段。如果团队确认 Codex CLI 会长期使用，后续可考虑：

1. **自动化转换脚本**：`tools/convert-claude-to-codex.sh`，从 `core/` 自动生成 `.codex/` 结构
2. **双轨 upgrade 脚本**：`tools/upgrade-codex.sh`，与现有 `upgrade.sh` 并行，支持 `--dry-run`、`--diff`
3. **共享内容层**：将工具无关的工作流逻辑（Intake 三问、路由决策树、Spec 模板）提取到 `core/shared/`，两套模板共用
