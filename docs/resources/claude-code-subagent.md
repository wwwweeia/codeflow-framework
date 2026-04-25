---
title: Claude Code SubAgent 完整指南
description: 子智能体：解决上下文污染与并行协作
prev: false
next:
  link: /resources/claude-code-feishu-notify
---

> 整理自《Claude Code 工程化实战》第 03、04、05 讲，作者：黄佳

---

## 一、为什么需要子代理？

### 核心问题：上下文污染

主对话上下文是**线性追加、不会自动过期**的，所有中间过程都被当成"长期记忆"保留。

- 跑测试 → 500 行日志
- 搜索代码 → 200 行 grep 输出
- 分析错误 → 一堆中间推理

这些信息对"当下执行"有用，但对"后续决策"是**噪声**。结果：Claude 越用越"健忘"，不是模型退化，是上下文被污染了。

### 子代理的解法

子代理天然拥有**独立上下文窗口**，执行完即丢弃，只把结论带回主对话。

> **一句话定义**：子代理相当于一个"专职小助手"，带着自己的规则、工具权限、上下文窗口，去完成某一类任务，然后把"结果摘要"带回来。

---

## 二、子代理的三大核心价值

| 价值 | 解决的问题 | 机制 |
|------|----------|------|
| **隔离** | 上下文污染 | 子代理有独立上下文，执行完即释放 |
| **约束** | 行为不可控 | 工具权限边界，"希望如此"变成"物理上做不到" |
| **复用** | 经验无法沉淀 | 配置文件纳入版本控制，可共享、可迭代 |

附加价值：**并行** —— 多个子代理可同时推进，天然并行加速器。

---

## 三、什么时候该用子代理？

### ✅ 适合使用子代理的 4 类场景

| 场景类型 | 特征 | 示例 |
|---------|------|------|
| **高噪声输出** | 执行过程产生大量中间信息，主对话只关心结论 | 跑测试（只需知道通过/失败）、扫描日志、全库搜索 |
| **角色边界必须明确** | 只能"看"不能"动"，或需要操作隔离 | 代码审查员（只读）、安全审计 |
| **并行研究** | 多个独立探索任务可以同时进行 | 同时调研认证逻辑、数据库设计和 API 接口 |
| **流水线式任务** | 可以拆成清晰阶段，每阶段目标/权限/输出明确 | 定位→审查→修复→验证测试 |

### ❌ 不适合使用子代理的情形

- 需要**频繁来回确认**需求、不断调整方向的任务
- 各阶段**高度耦合**、强依赖上一阶段详细过程的任务
- **非常简单**的小任务（启动子代理本身有开销）

---

## 四、一条关键约束

> **⚠️ 子代理不能嵌套调用子代理**

所有编排必须由**主对话**完成，主对话是整个流水线的唯一"调度中心"。
- 如需在子代理内复用知识：用 `skills` 字段预加载，而非嵌套子代理

---

## 五、子代理配置文件详解

### 5.1 文件格式

子代理使用 **Markdown + YAML frontmatter** 格式：

```markdown
---
name: code-reviewer
description: Review code changes for quality, security, and best practices. Proactively use after code modifications.
tools: Read, Grep, Glob, Bash
model: sonnet
---

你是一个代码审查专家。

当被调用时：
1. 首先理解代码变更的范围
2. 检查安全问题
3. 检查代码规范
4. 提供改进建议

## 输出格式
### 审查结果
- 安全问题：[列表]
- 规范问题：[列表]
- 建议：[列表]
```

frontmatter（`---` 之间）定义元数据；下方 Markdown 正文是**系统提示词**（system prompt）。子代理只收到这段 system prompt 和基本环境信息，**不会继承主对话的完整系统提示词**。

### 5.2 frontmatter 字段说明

| 字段 | 是否必填 | 说明 |
|------|---------|------|
| `name` | ✅ 必填 | 子代理唯一标识符 |
| `description` | ✅ 必填 | **最关键字段**，决定 Claude 何时自动调用 |
| `tools` | 可选 | 白名单：只能用这些工具 |
| `disallowedTools` | 可选 | 黑名单：继承所有工具，但排除这些 |
| `model` | 可选 | 模型选择（默认继承主对话模型） |
| `permissionMode` | 可选 | 权限模式覆盖 |
| `skills` | 可选 | 启动时预加载的 Skill 知识 |
| `hooks` | 可选 | 子代理专属生命周期 Hook |

### 5.3 description 的设计艺术

description 决定了 Claude 何时**自动**调用你的子代理——这是配置中最重要的设计决策。

```yaml
# ❌ 太模糊，Claude 不知道什么时候该用
description: A code reviewer

# ✅ 好的 description：说明做什么 + 什么时候用
description: Review code changes for quality, security vulnerabilities, and best practices. Proactively use after code modifications.
```

> **"Proactively"** 关键词会鼓励 Claude 在合适时机主动委派任务。

### 5.4 工具权限：白名单 vs 黑名单

```yaml
# 方式一：白名单（tools）—— "只能用这些"
# 适合：需要严格限制的场景（如只读审查）
tools: Read, Grep, Glob

# 方式二：黑名单（disallowedTools）—— "继承所有，但排除这些"
# 适合：需要大部分工具但排除少数危险工具的场景
disallowedTools: Write, Edit
```

> **遵循最小权限原则**：只开放必要的工具，能用 Read 完成的任务不要给 Edit。

#### 典型工具组合

| 类型 | 工具组合 | 适用场景 |
|------|---------|---------|
| 只读型（审计/检查） | `Read, Grep, Glob` | 代码审查、安全扫描 |
| 研究型（信息收集） | `Read, Grep, Glob, WebFetch, WebSearch` | 技术调研 |
| 开发型（读写改） | `Read, Write, Edit, Bash, Glob, Grep` | Bug 修复、功能开发 |

### 5.5 permissionMode 权限模式

控制子代理执行时遇到需要权限的操作的处理方式：

```yaml
# 强制只读模式，即使有 Bash 也无法写入
permissionMode: plan
```

> **注意**：`permissionMode: plan` 是系统级的只读保障，比 prompt 约束更可靠。但有同学反映这不是 agent frontmatter 的合法字段，会被静默忽略。更可靠的做法是**直接从工具层面去掉 Write/Edit/Bash**。

### 5.6 skills 字段：预加载知识

```yaml
---
name: impact-analyzer
description: Analyze impact scope of code changes on the full call chain.
tools: Read, Grep, Glob, Bash
skills:
  - chain-knowledge   # 链路拓扑和 SLA 约束
  - recent-incidents  # 近期事故记录
---
```

- 子代理启动时，Claude Code 会把对应 Skill 的**完整内容直接注入**到子代理上下文中
- 与主对话的"渐进式加载"不同，子代理的 skills 是**启动时全量灌入**
- 子代理不会自动继承主对话中可用的 Skill，**必须在 skills 字段中显式列出**

### 5.7 hooks 字段：生命周期钩子

```yaml
---
name: db-reader
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---
```

子代理可以在 frontmatter 中定义 Hook，这些 Hook 只在该子代理运行期间生效，子代理结束后自动清理。

---

## 六、子代理的存放位置与优先级

### 项目级（仅当前项目可用）

```
your-project/
└── .claude/
    └── agents/
        ├── test-runner.md
        └── code-reviewer.md
```

适合：项目特有角色（如针对特定框架的测试运行器）

### 用户级（所有项目可用）

```
~/.claude/
└── agents/
    ├── general-reviewer.md
    └── log-analyzer.md
```

适合：通用角色（日志分析器、通用代码审查器）

> **优先级**：项目级 > 用户级（同名时，高优先级覆盖低优先级）

---

## 七、创建子代理的三种方式

### 方式一：交互式创建（推荐新手）

在 Claude Code 中输入 `/agents`，按向导操作：
1. 选择 "Create new agent"
2. 选择存放位置（User-level 或 Project-level）
3. 选择 "Generate with Claude" 并描述功能
4. 选择需要的工具
5. 选择模型
6. 保存

### 方式二：手写配置文件

直接创建 `.claude/agents/your-agent.md` 文件。优势：精细控制，方便版本管理，可从其他项目复制。

### 方式三：CLI 参数临时创建

通过 `--agents` 参数，以 JSON 格式传入子代理定义。**仅在当前会话中存在，不保存到磁盘**，特别适合 CI/CD 自动化中临时创建任务专用的子代理。

---

## 八、子代理的运行模式

### 前台 vs 后台

- Claude 会根据任务自动选择前台或后台运行
- 手动控制：对 Claude 说 "run this in the background"
- 正在运行的前台子代理可按 **Ctrl+B** 切换到后台
- 后台子代理因权限不足失败时，可恢复到前台重试

### 恢复（Resume）

```
用 code-reviewer 子代理审查认证模块
[子代理完成]

继续刚才的审查，再看一下授权逻辑
[Claude 恢复之前的子代理，保留完整上下文]
```

恢复的子代理会保留所有之前的对话历史，从上次停下的地方继续。

### 上下文机制（重要）

子代理是**"报文传输"模式，不是"共享内存"模式**：
- 子代理启动时只能看到主 Claude 显式传递给它的 prompt
- 看不到主会话之前的对话历史
- 有自己独立的上下文窗口

**CLAUDE.md 继承规则**：
- 加载顺序：全局 `~/.claude/CLAUDE.md` → 项目 `CLAUDE.md` → 代理定义文件
- 优先级：代理定义文件 > 项目 CLAUDE.md > 全局 CLAUDE.md

---

## 九、内置子代理：开箱即用

| 内置子代理 | 特点 | 工具 | 用途 |
|-----------|------|------|------|
| **Explore** | 快速、只读 | Read, Grep, Glob | 搜索和分析代码库，有 quick/medium/very thorough 三档 |
| **Plan** | 规划模式专用 | 只读 | 在制定实施计划前收集项目上下文 |
| **General-purpose** | 全能型 | 完整工具集 | 同时需要探索和修改的复杂任务 |

> **实践技巧**：在 CLAUDE.md 中可以指定 Explore 的搜索深度，例如：涉及调用链分析 → 使用 "very thorough"；查找特定文件 → 使用 "quick"。

---

## 十、Multi-Agent 架构模式（第04讲）

### 何时从单 Agent 升级到多 Agent？

**LangChain 建议**：先从单 Agent 起步，优先通过引入工具扩展能力；只有当系统确实触及单 Agent 的架构边界时，才考虑多 Agent。

#### 两个核心触发信号

1. **上下文管理挑战**：多个能力领域无法舒适地塞进单一 prompt；Agent 接近"dumb zone（迟钝区）"
2. **分布式开发需求**：多个团队需要独立拥有和维护各自的 Agent 能力

### 四种核心设计模式

#### 模式一：Sub-Agents（集中式编排）

```
Supervisor Agent（老板）
    ├── Sub-Agent A：研究专员
    ├── Sub-Agent B：代码专员
    └── Sub-Agent C：测试专员
```

- 上下文隔离最强，每个 Sub-Agent 独立上下文
- 天然支持并行执行
- 用户通过 Supervisor 间接沟通
- **适合**：并行检索多源信息、跨知识领域协同、个人助手协调多系统

#### 模式二：Skills（渐进式能力加载）

```
.claude/skills/
├── deploy/SKILL.md
├── review-pr/SKILL.md
└── database-migration/SKILL.md
```

- 仍然是单 Agent，通过 SKILL.md 实现能力按需加载
- 共享同一上下文窗口，对话状态自然连续
- 复杂度最低，响应延迟最低
- **适合**：能力种类多但单次只需少量能力的场景

#### 模式三：Handoffs（状态驱动切换）

```
intake（信息收集）→ diagnosis（问题诊断）→ resolution（解决方案）
```

- 通过 Prompt + 状态约束 + 工程结构模拟切换
- 严格的顺序执行，上下文选择性传递
- **适合**：具有明确阶段划分的流程型场景（客服工单、多阶段审批）

Claude Code 中实现 Handoffs 的三要素：
1. 明确的阶段状态（State）
2. 每个阶段的角色约束
3. 显式的阶段完成条件（Exit Criteria）

#### 模式四：Router（并行分发与合成）

```
用户提问："退货政策是什么？最近销售数据如何？"
    Router 分解：
    ├── 查询1：退货政策 → 政策文档 Agent
    ├── 查询2：销售数据 → 数据分析 Agent
    └── 合成结果 → 统一回答
```

- 极强的并行能力，各分支上下文完全隔离
- 通常无状态，不利于连续对话
- **适合**：跨多个知识域或数据源的查询

### 架构演进路径

```
阶段一：单 Agent + Tools（大多数初期场景）
    ↓（工具 > 10个，prompt 臃肿）
阶段二：单 Agent + Skills（渐进式加载）
    ↓（需要独立上下文和专业知识）
阶段三：Supervisor + Sub-Agents（多领域并行）
    ↓（成熟系统，不同任务流用不同模式）
阶段四：混合架构（Router + Sub-Agent + Handoff）
```

### 升级决策树

```
你的任务需要多 Agent 吗？
├─ 单一领域、工具 < 5个、上下文 < 50K tokens
│  └─→ 不需要。用单 Agent + 好的 prompt 即可
├─ 单一领域、但工具 > 10个
│  └─→ 考虑 Skills 模式
├─ 多领域、各领域需要独立上下文
│  └─→ 使用 Sub-Agents 模式
├─ 需要多步骤状态流转
│  └─→ 使用 Handoffs 模式
└─ 需要跨多个数据源并行查询
   └─→ 使用 Router 模式
```

### 性能与成本权衡

- 多 Agent 系统存在约 **15倍的 token 成本**放大效应
- 约 95% 的性能波动归因于三因素：Token 使用量（80%）+ 工具调用次数（10%）+ 模型选择（5%）
- **选择更合适的模型，往往比单纯翻倍 token 预算效果更好**

### 黄金法则

```
1. 从单 Agent 开始 → 只在遇到明确瓶颈时才升级
2. 先加工具，再加 Agent → Tools 是最小的扩展单位
3. 选对模型 > 堆更多 token → 升级模型效果超过翻倍预算
4. 上下文隔离是核心价值 → 多 Agent 的第一价值不是并行，是隔离
5. Token 成本要求高价值任务 → 不是所有场景都值得多 Agent
```

---

## 十一、实战案例：只读型代码审查子代理（第05讲）

### 设计思维路径

```
工程痛点 → 分析缺什么能力 → 设计职责边界 → 选择工具组合 → 配置子代理
```

### 完整配置示例

```markdown
---
name: code-reviewer
description: Review code changes for quality, security, and best practices. Proactively use after code modifications.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer with expertise in security and software engineering best practices.

## Review Dimensions

### Security (Critical Priority)
- SQL injection vulnerabilities
- XSS vulnerabilities
- Hardcoded secrets/credentials
- Authentication/authorization issues

### Performance
- N+1 query patterns
- Memory leaks

### Maintainability
- Code complexity
- Missing error handling

### Best Practices
- SOLID principles violations
- Anti-patterns

## Output Format

### Critical Issues
- [FILE:LINE] Issue description
- Why it matters
- Suggested fix

### Warnings / Suggestions / Summary
...
```

> **注意**：如果要确保真正只读，更安全的做法是 `tools: Read, Grep, Glob`（去掉 Bash），从工具层面彻底断掉修改文件的能力。

### 调用方式

```bash
# 显式调用
让 code-reviewer 审查 src/ 目录下的所有代码
用 code-reviewer 检查 src/auth.js 的安全问题

# 触发自动调用（需在 description 中有明确说明）
用子代理帮我看看代码有没有安全问题
```

### 扩展：影响面分析子代理

```yaml
---
name: impact-analyzer
description: Analyze the impact scope of code changes on the full call chain.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: plan
skills:
  - chain-knowledge   # 链路拓扑和 SLA 约束
  - recent-incidents  # 近期事故记录
---
```

### 工程决策：何时创建子代理？

**该创建的场景**：
- 同类任务**重复频率高**（每天 / 每次提交）
- 需要**严格权限控制**（只读审计）
- 执行过程**输出噪声大**（日志分析、测试运行）
- 需要**专业知识加持**（通过 skills 注入领域知识）

**不该创建的场景**：
- 一次性任务：直接在主对话完成
- 简单的 prompt 模板：用 Skill 文件即可
- 自动化触发动作：用 Hook

---

## 十二、快速参考卡

### 子代理配置文件模板

```markdown
---
name: [子代理名称]
description: [做什么 + 什么时候用，包含 "Proactively" 关键词]
tools: [Read, Grep, Glob, Bash, Write, Edit, WebFetch, WebSearch 中选择]
model: [haiku | sonnet | opus，根据任务复杂度选择]
skills:
  - [skill-name]        # 可选，启动时预加载的知识
permissionMode: [plan]  # 可选，强制只读
hooks:                  # 可选，生命周期钩子
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---

[系统提示词 - 角色定义、工作流程、输出格式]
```

### 模式选择速查

| 需求 | 推荐模式 |
|------|---------|
| 隔离高噪声任务 | Sub-Agents |
| 只读安全审计 | Sub-Agents（只读型）|
| 能力按需加载 | Skills |
| 多阶段流程 | Handoffs |
| 多源并行查询 | Router |
| 复杂系统 | 混合架构 |

---

*整理时间：2026-04-10*
