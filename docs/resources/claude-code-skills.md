---
title: Claude Code Skills 精华整理
description: 技能包体系：结构、触发机制与渐进式披露
prev: false
next:
  link: /resources/claude-code-subagent
---
> 来源：09~13 讲，覆盖 Skills 结构、触发机制、任务型 Skills、渐进式披露、与 SubAgent 配合、架构定位

---

## 一、Skills 是什么？（本质定位）

### 1.1 精确定义
> Skills 是一种**可被语义触发的能力包**，包含领域知识、执行步骤、输出规范与约束条件，在需要时**渐进式加载**到主 Agent 的认知空间中。

### 1.2 Agent 生态四大支柱对比

| 组件 | 回答的问题 | 类比 |
|------|-----------|------|
| **Tools** | 能做什么 | 人的双手（原子操作） |
| **SubAgents** | 谁来做 | 同事（独立执行单元） |
| **Hooks** | 什么时候检查 | 质检流程 |
| **Skills** | **怎么做 + 何时做** | 企业 SOP 体系 |

### 1.3 Skills vs CLAUDE.md

| 维度 | CLAUDE.md | Skills |
|------|-----------|--------|
| 加载方式 | 常驻上下文（每次对话都读） | 按需加载（语义触发后才读） |
| 内容类型 | 全局规则 + 基础认知（< 100 行） | 特定场景的详细指令和知识 |
| 适合放什么 | Claude 每次都该知道的少量规则 | 特定场景下的详细流程和规范 |

**判断原则**：犹豫放 CLAUDE.md 还是 Skill，就放 Skill，并在 CLAUDE.md 里加一行引用。

---

## 二、SKILL.md 文件结构与配置

### 2.1 标准目录结构

```
.claude/skills/<skill-name>/        # Skill 目录，名称即 skill 名
├── SKILL.md                        # 主文件（必需，< 500 行）
├── reference/                      # 参考资料（按需加载）
│   ├── topic-a.md
│   └── topic-b.md
├── templates/                      # 输出模板
│   └── report.md
├── scripts/                        # 可执行脚本（确定性逻辑）
│   └── calculate.py
├── examples/                       # 示例（输入输出样本）
└── data/                           # 静态数据（JSON、CSV）
```

### 2.2 SKILL.md 完整 Frontmatter 字段

```yaml
---
name: my-skill-name          # 可选：Skill 标识符（省略则用目录名），最大 64 字符
description: What this does  # 推荐：触发器（最重要！），所有 description 共享 15,000 字符总预算
argument-hint: "[issue-number]"  # 可选：自动补全时的参数提示
disable-model-invocation: true   # 可选：禁止 Claude 自动触发（任务型 Skill 必设）
user-invocable: false            # 可选：对用户隐藏 /skill-name
allowed-tools:                   # 可选：限制可用工具（最小权限原则）
  - Read
  - Grep
  - Glob
  - Bash(git:*)                  # 可精确到命令级
model: sonnet                    # 可选：指定执行模型（haiku/sonnet/opus）
context: fork                    # 可选：在子代理中隔离执行
agent: Explore                   # 可选：context: fork 时的代理类型（Explore/Plan/general-purpose）
hooks:                           # 可选：作用域仅限此 Skill 的 Hooks（三层树形结构）
  PreToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: "echo 'Write called in skill'"
---
```

### 2.3 Description 写作公式（最重要）

```
description = [做什么] + [怎么做] + [什么时候用]
```

**❌ 差的 description：**
```yaml
description: Handles PDFs          # 太模糊
description: Write tests for code  # 两个 Skill 完全一样，会冲突
```

**✅ 好的 description：**
```yaml
# 代码审查 Skill
description: Review code for quality, security, and best practices. 
  Checks for bugs, style issues. Use when user asks for code review or 
  wants to check code quality.

# PDF 处理 Skill
description: Extract text and tables from PDF files, fill forms, merge 
  documents. Use when user mentions PDF, forms, or document extraction.
```

---

## 三、两大类型的 Skills

### 3.1 参考型 Skill（Claude 自动触发）

- **特征**：无执行步骤，无输出模板，不设 `disable-model-invocation`
- **用途**：API 设计规范、代码风格、领域知识——塑造"怎么做"的方式
- **触发**：Claude 根据语义自动判断是否加载
- **示例**：`api-conventions`、`code-style`、`error-handling`

```yaml
---
name: api-conventions
description: API design patterns for this codebase. Use when writing or reviewing APIs.
allowed-tools:
  - Read
  - Grep
  - Glob
---
# API Design Conventions
...（规范内容，无执行步骤）
```

### 3.2 任务型 Skill（用户手动触发，也称斜杠命令）

- **特征**：必须设 `disable-model-invocation: true`，有明确执行步骤
- **用途**：部署、提交代码、生成报告——有"副作用"的操作
- **触发**：只能用户显式调用 `/skill-name [args]`
- **示例**：`/commit`、`/deploy`、`/pr-create`、`/review`

```yaml
---
name: committing
description: Quick git commit with auto-generated or specified message
argument-hint: [optional: commit message]
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)
model: haiku
---
Create a git commit.
If a message is provided: $ARGUMENTS
...（详细步骤）
```

---

## 四、任务型 Skill 核心机制

### 4.1 参数传递

```yaml
# 单参数：$ARGUMENTS 接收所有参数
/commit fix login bug  → $ARGUMENTS = "fix login bug"

# 多参数：$1, $2 接收位置参数
/pr-create "Add auth" "JWT"  → $1="Add auth", $2="JWT"

# 带索引访问
/migrate-component SearchBar React Vue  → $0=SearchBar, $1=React, $2=Vue

# 会话 ID
${CLAUDE_SESSION_ID}  # 用于关联日志
```

### 4.2 动态上下文注入 `!`command``

**原理**：在 Skill 内容发送给模型**之前**，先执行 shell 命令，将输出内联替换进 Prompt。

```markdown
## Current Context (Auto-detected)

Current branch:
!`git branch --show-current`

Recent commits on this branch:
!`git log origin/main..HEAD --oneline 2>/dev/null`

Files changed:
!`git diff --stat origin/main 2>/dev/null`
```

**价值**：减少 3~5 次工具调用，模型启动即有完整上下文，响应更一致。
⚠️ 注意：`$ARGUMENTS` 会先替换再执行命令，需严格限制 `allowed-tools`。

### 4.3 任务型 Skill 七步设计清单

```
1. 动作是什么？    → 命名（commit、deploy、review）
2. 谁能触发？      → disable-model-invocation: true
3. 需要什么权限？  → allowed-tools 精确到命令级
4. 启动需要什么上下文？ → !`command` 预注入
5. 执行需要什么安全网？ → hooks
6. 输出量大不大？  → 大则 context: fork
7. 用什么模型？    → model（简单 haiku，复杂 sonnet）
```

### 4.4 权限最小化原则

```yaml
# ✅ 精确授权
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)

# ❌ 过于宽泛（等于授权所有 shell 命令）
allowed-tools: Bash(*)
```

---

## 五、渐进式披露架构（三层结构）

### 5.1 三层类比

| 层级 | 类比 | 内容 | 何时加载 |
|------|------|------|---------|
| **层级 1** | 目录页 | `description` 字段 | 每次对话始终扫描（常驻） |
| **层级 2** | 章节 | `SKILL.md` 主文件正文 | Skill 被触发后加载 |
| **层级 3** | 附录 | `reference/`、`templates/`、`scripts/` | SKILL.md 中引用后，按需加载 |

**Token 节省效果**：大多数请求只需部分资源，平均节省 50~80% tokens。

### 5.2 SKILL.md 是"路由器"

主文件用 Quick Reference 表格实现路由，用最少 token 指向正确资源：

```markdown
| Analysis Type | When to Use | Reference |
|--------------|-------------|-----------|
| Revenue      | 收入、营收相关 | `reference/revenue.md` |
| Cost         | 成本、费用相关 | `reference/costs.md` |
| Profitability | 利润、毛利率相关 | `reference/profitability.md` |
```

### 5.3 契约式引用（关键技巧）

```markdown
# ❌ 弱引用（Claude 不知道何时加载）
See `reference/revenue.md` for more details.

# ✅ 契约式引用（告诉 Claude 加载条件 + 内容预期）
## Revenue Analysis
When the user asks about revenue growth, ARPU, or revenue composition:
→ Load `reference/revenue.md` for calculation formulas and industry benchmarks
```

**契约式引用三要素**：
1. **触发条件**：什么情况下加载（"当用户问到 X 时"）
2. **文件路径**：去哪里找
3. **内容预期**：加载后能得到什么

### 5.4 知识拆分决策

```
面对一段知识，该放哪里？

├─ 每次请求都用？ → 内联进 SKILL.md（高频内联）
├─ 确定性计算逻辑？ → scripts/ 下的脚本
├─ 输出结构模板？ → templates/ 目录
├─ 偶尔用到的详细规则？ → reference/ 目录（契约式引用）
└─ 示例集？ → examples/ 目录
```

**500 行法则**：SKILL.md 超过 500 行就该重构——把参考资料移到辅助文件。

---

## 六、Skills 存放位置与管理

### 6.1 存放位置与优先级

```
Enterprise 级    ~/.enterprise/skills/    （最高优先级）
Personal 级      ~/.claude/skills/         跨项目个人使用
Project 级       .claude/skills/           随项目 git 分发（推荐）
Plugin Skills    使用 plugin-name:skill-name 命名空间，不冲突
```

**同名优先级**：Enterprise > Personal > Project

### 6.2 Monorepo 自动发现

```
packages/
├── frontend/.claude/skills/component-gen/SKILL.md  ← 编辑前端文件时自动发现
├── backend/.claude/skills/api-gen/SKILL.md          ← 编辑后端文件时自动发现
└── shared/.claude/skills/lint-check/SKILL.md
```

### 6.3 触发控制三种方式

```yaml
# 方式1：全局禁用（在 /permissions 中 deny Skill 工具）
Skill(deploy *)   # 放在 deny 列表

# 方式2：精确控制
Skill(commit)        # 精确匹配
Skill(review-pr *)   # 前缀匹配

# 方式3：逐个控制
disable-model-invocation: true  # 在 frontmatter 中设置
```

### 6.4 命令命名与组织

```
.claude/commands/
├── commit.md      → /commit
├── review.md      → /review
└── git/
    ├── status.md  → /git:status   （目录名成为命名空间前缀，用冒号分隔）
    └── log.md     → /git:log
```

> ⚠️ **注意**：`.claude/skills/` 目录下的 Skill 不支持命名空间（嵌套目录不会生成 `git:commit` 形式），可用 `name` 前缀模拟（如 `git-commit`）。

### 6.5 Commands 目录 vs Skills 目录

| 特性 | `.claude/commands/` | `.claude/skills/` |
|------|--------------------|--------------------|
| 历史 | 早期独立组件 | 新版推荐，Commands 已合并为子集 |
| 辅助文件 | 不支持 | 支持（templates/scripts/reference/） |
| 优先级 | 低 | 高（同名 Skill 优先） |
| 建议 | 已有文件继续用，无需迁移 | 新建命令用这里 |

---

## 七、Skills 与 SubAgents 配合使用

### 7.1 核心职责划分

| 组件 | 负责回答 | 类比 |
|------|---------|------|
| **SubAgent**（.md 文件） | WHO + WHAT + WHERE + OUTPUT | "是谁、做什么、写到哪、返回什么" |
| **Skill**（SKILL.md + 附属文件） | HOW + WITH WHAT + BY WHAT STANDARD | "怎么做、用什么工具、遵循什么标准" |

**核心判断标准**：这件事需要"另一个人"承担，还是只需要"多一本手册"？

### 7.2 两大组合方向

#### 方向 A：SubAgent 包含 Skill（最常见）

SubAgent 通过 `skills` 字段预加载领域知识（**全量加载**，不是渐进式）。

```yaml
# .claude/agents/api-doc-generator.md
---
name: api-doc-generator
description: Generate comprehensive API documentation
model: sonnet
tools: [Read, Grep, Glob, Write, Bash]
skills:
  - api-generating      # ← 预加载 Skill 全量内容作为领域知识
---

You are an API documentation specialist.
## Your Mission
Generate or update API documentation for Express.js routes.
```

**执行流程**：
```
主对话 → 调用 SubAgent → SubAgent 启动时注入 SKILL.md 全文 → 按 SKILL.md 步骤执行 → 返回摘要
```

**适用场景**：SubAgent 需要特定领域知识、同一 Skill 被多个角色复用、长期维护的专家型 Agent。

#### 方向 B：Skill 包含 SubAgent（`context: fork`）

Skill 通过 `context: fork` 自动派遣子代理执行，无需单独定义 SubAgent 文件。

```yaml
---
name: code-health-check
description: Perform a comprehensive code health check
context: fork          # ← 在隔离子代理中执行
agent: general-purpose # ← 子代理类型（Explore/Plan/general-purpose）
allowed-tools: [Read, Grep, Glob]
---

Analyze the codebase at `$ARGUMENTS` and produce a structured health report.
```

**执行流程**：
```
用户 /code-health-check src/ → SKILL.md 被激活 → 自动创建子代理 → 子代理在隔离上下文执行 → 返回报告到主对话（主对话上下文干净）
```

**适用场景**：研究型任务、重型批量生成、安全隔离（大量输出不污染主对话）。

### 7.3 方向 A vs 方向 B 对比

| 对比维度 | 方向 A：SubAgent 包含 Skill | 方向 B：Skill 包含 SubAgent |
|---------|---------------------------|---------------------------|
| 入口 | 显式调用 SubAgent | 触发 Skill（可语义自动） |
| Skill 内容 | 启动时预加载 | Skill 触发时 fork |
| 主会话历史 | 子代理可继承 | 子代理看不到 |
| 配置复杂度 | 需定义 SubAgent .md 文件 | 只需 SKILL.md 一个文件 |
| 最常用 | ✅ 最常见 | 研究/重型任务 |

---

## 八、三种组合模式（实战）

### 模式一：SubAgent 预加载 Skill（方向 A 的单次应用）

**适用**：一个任务需要一个领域专家执行。

```
项目结构：
├── .claude/agents/api-doc-generator.md  （SubAgent：WHO/WHAT）
└── .claude/skills/api-generating/
    ├── SKILL.md                          （Skill：HOW，精简版）
    ├── scripts/detect-routes.py
    └── templates/api-doc.md
```

**精简原则**：SubAgent 场景下，Skill 只需保留执行流程（HOW），参考型知识（PATTERNS/STANDARDS/EXAMPLES）可以精简，因为 SubAgent 的角色描述已承担了部分职责。

### 模式二：Skill + `context: fork`（方向 B 的直接应用）

**适用**：独立完整的任务，执行完把结果送回即可。

```yaml
---
name: deep-research
description: Research a topic thoroughly in the codebase
context: fork
agent: Explore
---
Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

**优势**：只需一个 SKILL.md，`context: fork` + `agent:` 自动搞定其它，无需手动创建 SubAgent 定义文件。

### 模式三：流水线中的 Skill 分工（方向 A 的多阶段串联）

**适用**：复杂多阶段任务，每阶段需要不同专业知识。

```
08-skill-pipeline/
├── CLAUDE.md                           ← 流水线编排逻辑
├── .claude/
│   ├── agents/
│   │   ├── route-scanner.md            ← 阶段1: haiku 模型
│   │   ├── doc-writer.md               ← 阶段2: sonnet 模型
│   │   └── quality-checker.md          ← 阶段3: haiku 模型
│   └── skills/
│       ├── route-scanning/SKILL.md     ← 扫描工作流程
│       ├── doc-writing/SKILL.md        ← 文档生成工作流程
│       └── quality-checking/SKILL.md  ← 质量检查工作流程
```

**流水线三要点**：
1. **清晰的阶段间接口**：每个 Skill 明确定义输出格式（JSON 路由清单 / 文件列表 / PASS 报告）
2. **单一职责**：每个 Skill 只做一件事（扫描不生成，生成不检查）
3. **编排集中管理**：流水线顺序和数据传递逻辑放在 `CLAUDE.md`，调整流程只改 CLAUDE.md

---

## 九、Skills 四种设计模式（架构层面）

| 模式 | 解决问题 | 关键组件 | 适用场景 |
|------|---------|---------|---------|
| **模板驱动** | 输出不稳定 | `templates/` | 报告生成、文档输出 |
| **脚本增强** | 结果不稳定（数值计算） | `scripts/` | 公式计算、数据转换 |
| **知识分层** | 上下文膨胀 | `reference/` + 契约式引用 | 规则多、领域复杂的 Skill |
| **工具隔离** | 越权风险 | `allowed-tools` 精确配置 | 安全控制、审计类 Skill |

**组合决策树**：
```
你的 Skill 需要……
├─ 标准化输出格式？ → 加 templates/（模板驱动）
├─ 确定性计算/匹配？ → 加 scripts/（脚本增强）
├─ 知识量 > 500 行？ → 拆分 reference/（知识分层）
└─ 安全边界控制？ → 配置 allowed-tools（工具隔离）
```

**生产级 Skill 通常组合多种模式**：
```
api-generator = 模板驱动 + 脚本增强 + 知识分层 + 工具隔离
```

---

## 十、Skills 在 Claude Code 五层架构中的位置

```
┌────────────────────────────────────────────┐
│  第五层 Distribution Layer（Plugins）       │ ← 能力封装与交付
├────────────────────────────────────────────┤
│  第四层 Automation Layer（Hooks）           │ ← 事件驱动控制
├────────────────────────────────────────────┤
│  第三层 Agent Layer（SubAgents/Teams）      │ ← 执行编排
├────────────────────────────────────────────┤
│  ★ 第二层 Knowledge Layer（Skills）★      │ ← 策略与操作规约（本讲核心）
├────────────────────────────────────────────┤
│  第一层 Tool Layer（Read/Write/Bash...）    │ ← 原子操作接口
├────────────────────────────────────────────┤
│  LLM 底座（推理 + Agentic Loop）           │
└────────────────────────────────────────────┘
```

**Skills 的三个结构方向**：
- **向下**：通过 `allowed-tools` + `scripts/` 约束并编排 Tools（知识约束行动）
- **向上**：为 SubAgents 提供预加载的专业知识（知识服务决策）
- **平行**：与 CLAUDE.md 互补（专业能力 vs 基础认知框架）

---

## 十一、三级进化路径

| 级别 | 阶段 | 解决什么 | 特征 |
|------|------|---------|------|
| **第一级** | SOP | 可执行（标准化单任务） | 单一 SKILL.md，流程可复现 |
| **第二级** | 专家系统 | 可扩展（领域内复杂变体） | 渐进式披露 + 脚本 + 模板 |
| **第三级** | 组织智能 | 可规模化（跨角色协作） | 多 Skills + SubAgents 流水线 + Hooks |

> 大多数项目在第二级就能满足需求，不要为了"高级"而过度设计。

---

## 十二、Skills × Tools 协作关系

```
第一层（约束）：Skills 通过 allowed-tools 限制 Tools 的使用范围
    → 审查 Skill 只给 Read/Grep，不给 Write

第二层（编排）：scripts/ 目录是预编译的 Tool 调用序列
    → 一次 Bash(python calculate.py data.json) 替代多轮工具调用

第三层（反哺）：!`command` 让 Tools 输出注入 Skill 上下文
    → PR diff: !`gh pr diff`  工具输出 → 注入 Skill 上下文
```

---

## 十三、渐进式披露 vs 子代理隔离（两种上下文管理策略）

| 策略 | 机制 | 解决的问题 |
|------|------|-----------|
| **渐进式披露** | 按需加载 Skill 内容 | 节省 token，避免注意力稀释 |
| **子代理隔离** | 独立上下文执行 | 防止中间过程污染主对话 |

**组合使用**：子代理可通过 `skills` 字段预加载 Skill，该 Skill 内部仍可用渐进式披露组织内容。

---

## 十四、实战速查

### 典型 Skill 配置模板

```yaml
# 参考型 Skill（Claude 自动触发）
---
name: api-conventions
description: API design patterns. Use when writing or reviewing API endpoints.
allowed-tools: [Read, Grep, Glob]
---

# 任务型 Skill（用户手动触发）
---
name: smart-commit
description: Create a git commit with auto-generated message
argument-hint: [optional: commit message]
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)
model: haiku
---
Create a git commit.
If message is provided: $ARGUMENTS
## Steps
1. Check `git status`
2. If nothing staged, run `git add .`
3. Review `git diff --staged`
4. Commit with provided or auto-generated message

# Skill + context: fork（隔离执行）
---
name: code-review
description: Full codebase review in isolated context
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: [Read, Grep, Glob]
---

# SubAgent 预加载 Skill
---（SubAgent .md 文件）
name: api-expert
skills:
  - api-conventions
  - error-handling-patterns
---
You are an API specialist. Follow the conventions from preloaded skills.
```

### 选型决策树

```
面对一个新需求，我该用 Skill 还是 SubAgent？

这件事需要特定领域知识？
  YES → Skill（参考型）
  
这件事是重复性流程，想要快捷命令？
  YES → Skill（任务型，disable-model-invocation: true）
  
这件事需要隔离上下文，不污染主对话？
  YES → SubAgent 或 context: fork

这件事需要多步骤、独立判断的复杂任务？
  YES → SubAgent（.md 文件）

这件事需要专业知识 + 独立执行？
  YES → SubAgent 预加载 Skill（最常见的组合）

这件事是多阶段流水线，每阶段需要不同专业知识？
  YES → 多 SubAgent + 多 Skill（流水线模式）
```

---

*整理自极客时间《实战 Claude Code 工程化》09~13 讲*
