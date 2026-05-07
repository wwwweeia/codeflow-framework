---
title: GitHub spec-kit：开源 SDD 工具包全景解读
description: 深度解析 GitHub 官方开源的 Spec-Driven Development 工具包，与 HCodeFlow 的异同对比及参考价值
prev:
  text: SDD-RIPER 方法论
  link: /resources/sdd-riper-methodology
next:
  text: 培养你的直觉
  link: /resources/building-intuition
---

> 来源：[github/spec-kit](https://github.com/github/spec-kit) — GitHub 官方开源项目，MIT 协议
> 整理日期：2026-04-28
> 本文基于 spec-kit 仓库 README、[spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md) 方法论文档及社区扩展生态整理

---

## 一、spec-kit 是什么

**一句话定位**：GitHub 官方开源的 Spec-Driven Development（SDD）工具包，通过 CLI 工具 + 模板系统 + 多 Agent 集成，让开发者专注产品场景而非 vibe coding。

spec-kit 的核心主张很明确：

> Specifications don't serve code — code serves specifications.
> 规范不服务于代码，代码服务于规范。

这不是"先写文档再写代码"的老生常谈，而是一次根本性的权力翻转：**规范（Specification）成为一等公民和可执行产物**，代码只是规范在特定技术栈下的表达。

| 传统开发 | spec-kit SDD |
|---------|-------------|
| 代码是真相（Code is truth） | 规范是真相（Spec is truth） |
| PRD 指导开发，用完即弃 | PRD 驱动生成实现，持续维护 |
| 调试代码 | 修复规范，重新生成代码 |
| 重构代码 | 重构规范的清晰度 |
| 需求变更 = 手动传播改动 | 需求变更 = 系统化重新生成 |

---

## 二、四阶段工作流

spec-kit 将 SDD 落地为一条清晰的生产线：

```
Constitution（宪章） → Specify（规范） → Plan（计划） → Tasks（任务）
                                                    ↕
                              clarify / checklist / analyze / implement
```

每个阶段都有对应的 slash command 触发，且**前一阶段的产出是后一阶段的输入**。

### 2.1 Constitution（宪章）—— 项目基因

Constitution 是 spec-kit 最独特的设计之一。它是一份**不可变的项目宪法**，定义了所有后续规范和代码必须遵守的核心原则。

spec-kit 自带的九条开发原则：

| 原则 | 核心要求 | 防什么 |
|------|---------|--------|
| I. Library-First | 每个功能先作为独立库实现 | 防单体 |
| II. CLI Interface | 所有库通过 CLI 暴露能力 | 防黑盒 |
| III. Test-First | TDD 红绿重构，不可协商 | 防无测试 |
| IV. Integration Testing | 真实环境测试优先于 mock | 防假通过 |
| V. Observability | 文本 I/O + 结构化日志 | 防不可调试 |
| VI. Versioning | 语义化版本管理 | 防破坏性变更 |
| VII. Simplicity | 最多 3 个项目、YAGNI | 防过度工程 |
| VIII. Anti-Abstraction | 直接使用框架能力 | 防抽象泄漏 |
| IX. Integration-First Testing | 合同测试强制优先 | 防接口不一致 |

关键机制是 **Phase -1 Gates（前置门禁）**：模板中硬编码了 Simplicity Gate、Anti-Abstraction Gate 等检查点。LLM 在生成计划时必须逐条通过这些门禁，或者记录违规原因到 "Complexity Tracking" 区块。这是一种把**架构合规自动化**的思路。

触发方式：
```markdown
/speckit.constitution This project follows a "Library-First" approach. All features must be implemented as standalone libraries first. We use TDD strictly.
```

### 2.2 Specify（规范）—— 意图层

`/speckit.specify` 命令将一句话的功能描述转化为完整的结构化规范。

**自动完成的工作：**
- 扫描现有 spec 编号，自动分配下一个编号（001、002...）
- 根据描述生成语义化分支名并自动创建 Git 分支
- 基于模板填充完整规范文档到 `specs/<branch-name>/` 目录

**核心约束**：规范阶段**只关注 WHAT（做什么）和 WHY（为什么）**，严格禁止涉及 HOW（怎么做、用什么技术栈）。

**[NEEDS CLARIFICATION] 标记机制**：模板强制 LLM 不允许猜测，必须在不确定处显式标记：
```
[NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
```

示例：
```markdown
/speckit.specify Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping.
```

### 2.3 Plan（计划）—— 执行层

`/speckit.plan` 命令将规范转化为技术实现计划。**此时才引入技术栈和架构选型**。

产出物矩阵：

| 文件 | 内容 |
|------|------|
| `plan.md` | 高层实现计划（可读性优先） |
| `research.md` | 技术选型调研（库对比、性能基准） |
| `data-model.md` | 数据模型定义 |
| `contracts/` | API 合同定义 |
| `quickstart.md` | 关键验证场景 |

计划必须对照 Constitution 逐条验证合规性。

### 2.4 Tasks（任务）—— 行动层

`/speckit.tasks` 命令分析计划文档，生成可执行的任务清单：

- 按 User Story 组织
- 独立任务标记 `[P]`，明确可并行组
- 测试任务排在实现任务之前（Test-First）
- 明确文件路径和依赖关系

### 2.5 辅助命令

| 命令 | 作用 | 典型时机 |
|------|------|---------|
| `/speckit.clarify` | 结构化澄清规范中的歧义 | Specify 之后、Plan 之前 |
| `/speckit.checklist` | 生成质量检查清单 | Plan 之后、Tasks 之前 |
| `/speckit.analyze` | 跨产物一致性与覆盖度分析 | Tasks 之后、Implement 之前 |
| `/speckit.implement` | 按任务清单执行实现 | 分析通过后 |
| `/speckit.taskstoissues` | 转换为 GitHub Issues | 需要项目管理同步时 |

---

## 三、模板驱动质量：约束 LLM 的艺术

spec-kit 最值得深挖的设计是**通过模板约束 LLM 输出质量**。这不是提示词技巧，而是结构化工程。

### 六大约束策略

**1. 防止过早涉及实现细节**

模板显式指令：
```
✅ Focus on WHAT users need and WHY
❌ Avoid HOW to implement (no tech stack, APIs, code structure)
```

LLM 想跳到"用 React + Redux 实现"时，模板把它拉回"用户需要实时数据更新"。

**2. 强制不确定性标记**

`[NEEDS CLARIFICATION]` 机制防止 LLM 做出看似合理但可能错误的假设。不猜，标出来。

**3. 结构化自检清单**

模板内嵌完整检查项，LLM 必须逐条自审：
```markdown
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
```

**4. 宪章合规门禁**

Phase -1 Gates 作为模板的一部分，LLM 无法跳过：
```markdown
#### Simplicity Gate (Article VII)
- [ ] Using ≤3 projects?
- [ ] No future-proofing?

#### Anti-Abstraction Gate (Article VIII)
- [ ] Using framework directly?
- [ ] Single model representation?
```

**5. 分层信息管理**

模板强制分离关注点：
```
plan.md → 高层可读概览（不超过 2-3 页）
implementation-details/ → 代码示例、算法细节、技术规格
```

**6. 测试先行约束**

文件创建顺序被硬编码：
```
1. contracts/ — API 规范
2. 测试文件 — contract → integration → e2e → unit
3. 源码 — 让测试通过
```

**复合效果**：这些约束共同作用，将 LLM 从"创意写手"转变为"规范工程师"，产出一致高质量的、可执行的规范文档。

---

## 四、Agent 集成与扩展生态

### 4.1 30+ AI Agent 一键切换

spec-kit 通过 `specify integration` 命令管理 Agent 集成。每个 Agent 是一个独立的集成子包，继承统一基类：

| 类别 | Agent |
|------|-------|
| **Claude 系** | Claude Code（skills 集成） |
| **GitHub 系** | Copilot（agent.md 格式）、Copilot CLI |
| **Google 系** | Gemini CLI（TOML 格式）、Jules |
| **OpenAI 系** | Codex CLI（skills 集成） |
| **IDE 原生** | Cursor、Windsurf、Trae、Junie |
| **独立工具** | Roo Code、Goose（YAML recipe）、Kimi、Qwen Code、Amp、Auggie |
| **其他** | Forge、Tabnine、Kilo Code、SHAI 等 29+ |

关键设计：
- **一个项目同一时间只有一个活跃集成**，通过 `switch` 命令切换
- **SHA-256 追踪文件修改**：uninstall 时自动保留你手动修改过的文件
- **Generic 集成**：对于未列出的 Agent，可通过 `--commands-dir` 指定任意目录

### 4.2 三层扩展机制

```
┌──────────────────────────────────────────┐
│  Workflows  — 自动化多步流程              │  ← 条件分支、人工门禁、fan-out/fan-in
├──────────────────────────────────────────┤
│  Presets     — 覆盖模板适配领域           │  ← 不改工具，改工作流模板
├──────────────────────────────────────────┤
│  Extensions  — 添加新命令/钩子/能力       │  ← 横向扩展功能
├──────────────────────────────────────────┤
│  Core        — 框架核心                   │  ← 四阶段工作流 + 标准模板
└──────────────────────────────────────────┘
```

**模板解析优先级**：项目本地覆盖 > Preset > Extension > Core。上层覆盖下层，但不破坏下层。

### 4.3 社区生态精选

社区通过 `catalog.json` + PR 提交机制贡献扩展和预设。几个代表性案例：

| 类型 | 名称 | 领域 | 亮点 |
|------|------|------|------|
| Preset | Fiction Book Writing | 剧本创作 | SDD 最极端的领域适配——把软件开发工作流搬到文学创作 |
| Preset | Explicit Task Dependencies | 项目管理 | 任务依赖 DAG 图，支持复杂依赖拓扑 |
| Extension | spec-kit-jira | 项目管理 | Jira 双向同步，Spec 变更自动更新 Issue |
| Extension | spec-kit-qa | 质量保障 | 自动生成质量报告和覆盖率分析 |
| Extension | spec-kit-review | 代码审查 | 实现后自动审查，对照规范检查一致性 |

---

## 五、与 HCodeFlow 的对比分析

两个项目在 SDD 理念上高度一致，但选择了不同的实现路径：

| 维度 | spec-kit | HCodeFlow |
|------|----------|-----------|
| **核心理念** | SDD（规范驱动开发） | SDD（规范驱动开发） |
| **实现路径** | 工具优先（CLI + 模板 + Agent 集成） | 规范优先（规则文件 + Agent 定义 + 知识库） |
| **工作流** | Constitution → Specify → Plan → Tasks → Implement | 宪章 → 规范 → 计划 → 任务（Intake 路由） |
| **Agent 支持** | 29+ Agent，一键切换 | Claude Code 深度集成 |
| **质量约束** | 模板硬约束（Phase -1 Gates、[NEEDS CLARIFICATION]） | Agent 角色分离 + 审批门禁 |
| **规范载体** | `.specify/` 目录 + markdown 模板 | `core/` + rules/agents/skills 文件体系 |
| **扩展性** | Extensions / Presets / Workflows 三层 | Skills + Commands 渐进式 |
| **部署方式** | pip/uv 全局安装 CLI | Git submodule + upgrade.sh 同步 |
| **适用场景** | 通用项目、多 Agent 环境 | 企业统一框架、单 Agent 深度集成 |

### 可借鉴的三个方向

**1. 宪章机制 + 自动门禁**

spec-kit 的 Constitution + Phase -1 Gates 将"架构合规"从人工审查变为自动化检查。我们可以考虑在审批阶段引入类似的自动检查点——不是替代人工审查，而是**先过一遍机器能检查的规则**，减少人工审查的负担。

**2. 模板驱动质量**

通过模板约束 LLM 行为是一种低成本高回报的做法。特别是 `[NEEDS CLARIFICATION]` 标记和分层信息管理——让 LLM 不猜、不堆、不遗漏。我们现有的 spec-templates skill 可以借鉴这些约束模式。

**3. 扩展系统设计**

Extensions（添加能力）/ Presets（适配领域）/ Workflows（自动化流程）的三层分离提供了清晰的关注点分离。我们的 Skills 已覆盖了 Extensions 的功能，但 Presets（领域适配模板覆盖）和 Workflows（自动化多步流程）是值得考虑的演进方向。

---

## 六、参考资源

- **spec-kit 仓库**：https://github.com/github/spec-kit
- **SDD 方法论文档**：[spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md) — spec-kit 根目录的完整方法论阐述，强烈推荐阅读
- **快速入门**：[Quick Start Guide](https://github.com/github/spec-kit/blob/main/docs/quickstart.md) — 6 步跑通完整工作流
- **扩展目录**：[catalog.json](https://github.com/github/spec-kit/blob/main/extensions/catalog.json) — 查看所有官方和社区扩展
- **预设目录**：[catalog.json](https://github.com/github/spec-kit/blob/main/presets/catalog.json) — 查看所有预设
- **本文对应的 HCodeFlow 方法论**：[SDD-RIPER 方法论](/resources/sdd-riper-methodology) — 阿里云「无岳」系列文章精华整理
