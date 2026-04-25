---
title: Rules 参考
description: 框架定义的工作流规则与检查清单
outline:
  level: [2, 2]
---

# Rules 参考

> Rules 是编码硬规则和工作流调度逻辑，自动加载到 Claude Code 会话中。
> 标记为"被管理"的规则由框架维护，marker 下方可追加项目特有规则。

## 框架保护规则 (`framework_protection.md`)

本项目的 `.claude/` 目录中有部分文件由公司级框架 **codeflow-framework** 统一管理。框架的目的是让所有业务项目共享经过验证的工作流、Agent 行为、审查规则和开发规范，避免各项目各自为政、重复踩坑。
框架采用**两层分离**架构：
- **框架层**（`../codeflow-framework/core/`）：公司级通用内容，通过 `upgrade.sh` 同步到各项目
- **项目层**（本项目 `.claude/`）：项目特有的业务规则、领域知识、自定义扩展
被框架管理的文件包含一行 marker 注释：

::: details 查看完整定义

# 框架协作规则

**框架是什么**

本项目的 `.claude/` 目录中有部分文件由公司级框架 **codeflow-framework** 统一管理。框架的目的是让所有业务项目共享经过验证的工作流、Agent 行为、审查规则和开发规范，避免各项目各自为政、重复踩坑。

框架采用**两层分离**架构：
- **框架层**（`../codeflow-framework/core/`）：公司级通用内容，通过 `upgrade.sh` 同步到各项目
- **项目层**（本项目 `.claude/`）：项目特有的业务规则、领域知识、自定义扩展

**Marker 机制与双向同步**

被框架管理的文件包含一行 marker 注释：
```

:::

## 知识加载协议 (`knowledge-protocol.md`)

> 本文件是所有 Agent 的知识加载行为规则。Claude Code 自动加载本文件，所有 Agent 无需额外引用即可感知。
每个子项目（后端 / 前端 App）的知识资产按以下结构组织：
```
<子项目>/.claude/
  rules/                        → 硬约束（Agent 需主动读取，不会自动加载）

::: details 查看完整定义

# 知识加载协议（框架标准）

> 本文件是所有 Agent 的知识加载行为规则。Claude Code 自动加载本文件，所有 Agent 无需额外引用即可感知。

---

**1. 目录约定**

每个子项目（后端 / 前端 App）的知识资产按以下结构组织：

```
<子项目>/.claude/
  rules/                        → 硬约束（Agent 需主动读取，不会自动加载）
  context/                      → 软知识（Agent 按 knowledge-index 按需加载）
  context/knowledge-index.md    → 知识索引入口（Agent 的唯一入口文件）
  context/cookbook-*.md         → 场景实操指南（带完整代码示例）
  context/pattern-*.md          → 设计模式与最佳实践
  context/<项目类型特定>.md      → 路由/Store/组件/API 约定等（初始化时生成）
```

### 判断一条知识该放哪里

| 问题 | rules | cookbook | pattern | context |
|------|-------|----------|---------|---------|
| 违反了算 Bug 吗？ | 是 | 否 | 否 | 否 |
| 有完整代码示例吗？ | 不需要 | **必须有** | 有片段 | 不需要 |
| 描述的是"怎么做"还是"为什么"？ | 怎么做 | 怎么做 | **为什么** | 是什么 |
| 会被多个场景复用吗？ | — | 单场景 | **多场景** | — |

### 不应放入知识体系的内容

- 纯代码导航（放 Codemap：`.claude/codemap/domains/`）
- 一次性临时信息（放 Spec 目录：`.claude/specs/feature-<name>/`）
- 框架已管理的通用规则（放 `core/rules/`，通过 upgrade.sh 同步）

---

**2. 加载协议**

Agent 进入具体子项目执行任务时，按以下步骤加载知识：

1. **检查知识索引**：读取目标子项目的 `.claude/context/knowledge-index.md`（不存在则跳过后续步骤）
2. **匹配任务**：根据 knowledge-index 中「任务到知识映射」表，匹配当前任务场景
3. **加载知识文件**：若匹配到映射行，读取对应的 cookbook/pattern 文件
4. **不阻塞**：知识索引不存在或无匹配行时，跳过，不影响工作流

### 加载优先级

```
rules（硬约束，自动加载） > cookbook（实操指南，按需加载） > pattern（设计模式，按需参考）
```

---

**3. 各角色加载上下文**

| 角色 | 目标子项目 | 知识索引路径 |
|------|-----------|-------------|
| Dev (后端模式) | 后端项目 | `<后端项目目录>/.claude/context/knowledge-index.md` |
| FE (前端模式) | 目标前端 App | `<目标App目录>/.claude/context/knowledge-index.md` |
| Arch (后端模式) | 后端项目 | `<后端项目目录>/.claude/context/knowledge-index.md` |
| Arch (前端模式) | 目标前端 App | `<目标App目录>/.claude/context/knowledge-index.md` |
| Arch (全栈模式) | 后端 + 前端 App | 两侧均检查 |
| QA (后端审查) | 后端项目 | `<后端项目目录>/.claude/context/knowledge-index.md` |
| QA (前端审查) | 目标前端 App | `<目标App目录>/.claude/context/knowledge-index.md` |
| QA (全栈审查) | 后端 + 前端 App | 两侧均检查 |

> 具体项目路径和 App 列表参见 CLAUDE.md。

---

**4. 角色特定行为**

### Dev / FE Agent

- **时机**：Research 阶段
- **使用**：实现中必须参考已加载 cookbook 的数据流和关键点
- **反馈**：如发现 cookbook 与实际代码不一致，记录到 `03_impl_*.md` 并上报主对话

### Arch Agent

- **时机**：Research 阶段（加载上下文时）
- **使用**：了解已有知识资产，设计时对齐 cookbook 描述的既定模式
- **对齐检查**：技术设计方案如偏离已有 cookbook/pattern，必须在 `02 Part C`（技术风险）中说明原因

### QA Agent

- **时机**：Load Specs 阶段
- **使用**：读取知识条目作为审查补充参考
- **覆盖度检查**：检查本次变更涉及的功能区域是否有对应知识条目；如缺少，在审查报告中建议补充

### 主会话

- **时机**：派发 Agent 时
- **行为**：如目标子项目存在 `knowledge-index.md`，在派发 prompt 中提示 Agent 参考知识索引（Agent 自行按需加载，主会话不预加载内容）

---

**5. 知识沉淀触发**

完成任务后，各角色检查是否需要沉淀新知识，形成「加载 → 使用 → 沉淀」闭环：

| 角色 | 沉淀时机 | 触发条件 | 沉淀动作 |
|------|---------|---------|---------|
| Dev / FE | 编码完成后 | 发现可复用的代码模式 | 建议创建 `cookbook-<场景>.md`，在 `knowledge-index.md` 注册映射 |
| Arch | 设计完成后 | 发现新的通用架构方案 | 建议创建 `pattern-<模式>.md`，在 `knowledge-index.md` 注册映射 |
| QA | 审查完成后 | 发现新的反模式或常见问题 | 建议更新 `rules/` 下对应规则文件 |
| 主会话 | 合并完成后 | 涉及新业务域 | 提示更新 `knowledge-index.md` 的映射表 |

### 沉淀原则

- **不预先批量生产**：知识在实际开发任务中逐步沉淀，不凭空设计
- **来源可追溯**：每条知识关联到产出它的 Spec 或代码审查发现
- **通用性检验**：沉淀前判断"换一个项目，这条知识还有用吗？"——有用考虑提升到框架 Skill

:::

## 合并前检查清单 (`merge_checklist.md`)

在任何 `feature/*`、`fix/*` 或 `refactor/*` 分支合并前，**只有在用户明确同意后，AI 才可以执行合并与推送流程。**
> 代码质量检查由 QA Agent + 编码规则（`coding_backend.md` / `coding_frontend_shared.md`）覆盖，本文件只定义合并操作步骤。
> **执行主体**：主会话（不是 QA Agent）。QA 只负责审查和出结论。
QA 给出 `PASS`、运行验证通过、用户确认合并后，**主会话**执行以下动作：
1. **状态检查**：确认当前在 `feature/*` 分支，无未提交的必要修改

::: details 查看完整定义

# 合并流程 SOP (Merge SOP)

在任何 `feature/*`、`fix/*` 或 `refactor/*` 分支合并前，**只有在用户明确同意后，AI 才可以执行合并与推送流程。**

> 代码质量检查由 QA Agent + 编码规则（`coding_backend.md` / `coding_frontend_shared.md`）覆盖，本文件只定义合并操作步骤。

**合并流程**

> **执行主体**：主会话（不是 QA Agent）。QA 只负责审查和出结论。

QA 给出 `PASS`、运行验证通过、用户确认合并后，**主会话**执行以下动作：

1. **状态检查**：确认当前在 `feature/*` 分支，无未提交的必要修改
2. **提交**：`git add <相关文件>` → `git commit` 并附简要描述
3. **切换与拉取**：`git checkout develop` → `git pull origin develop`
4. **合并**：`git merge --no-ff <feature_branch>`
   - 冲突时**立即中断**，通知用户处理
5. **推送**：`git push origin develop`
6. **清理**：删除 feature 分支（本地 + 远端）
7. **报告**：汇报合并结果

**注意**：参考 `CLAUDE.md` 中的分支策略确定基础分支和合并规则。

:::

## 全栈协作调度规则 (`project_rule.md`)

> 本文件是主对话（调度中心）的全局指导，覆盖项目的全栈开发工作流。
> - 后端编码硬规则 → `.claude/rules/coding_backend.md`（项目特定）
> - 前端共享编码规则 → `.claude/context/coding_frontend_shared.md`（项目特定）
> - 各模块特有规则 → `.claude/rules/` 下的其他文件
> - 业务名词解释 → `.claude/skills/domain-ontology/SKILL.md`

::: details 查看完整定义

# 全栈协作调度规则（框架标准）

> 本文件是主对话（调度中心）的全局指导，覆盖项目的全栈开发工作流。
> - 后端编码硬规则 → `.claude/rules/coding_backend.md`（项目特定）
> - 前端共享编码规则 → `.claude/context/coding_frontend_shared.md`（项目特定）
> - 各模块特有规则 → `.claude/rules/` 下的其他文件
> - 业务名词解释 → `.claude/skills/domain-ontology/SKILL.md`

---

**1. Intake 触发规则（硬约束）**

> 无论需求描述多简单，以下规则不得绕过。

**触发条件**：收到任何涉及"新增 / 修改 / 删除功能"的需求描述时。

**强制行为**：主对话收到需求后，**第一句话必须是 Intake 三问**，禁止先读代码、禁止先写代码、禁止直接转发给子 Agent。

```
1. 目标   — 要做什么？数据来源？涉及哪个项目？
2. 边界   — 不做什么？是否需要鉴权？是否涉及已有接口？
3. 验收   — 做完怎么算完成？
```

**例外**（以下情况可跳过 Intake）：
- 纯解释 / 查询类（"这段代码是什么意思"）
- 明确的 bug 定位（已有完整复现路径，无需新增功能）

### 1.1 需求确认（硬约束）

Intake 三问完成后，**不得立即路由或启动 Agent**。主对话必须向用户呈现：
1. 已明确的需求要点摘要（目标、边界、验收标准、涉及项目）
2. 路由判断（工作流 A/B/C 或轻量流程）及理由
3. 询问：「还有需要补充的吗？如果没有，我将启动 PM 产出需求文档。」

**只有用户明确回复"开始"/"确认"/"继续"等同意信号后**，主对话才可路由并启动 PM Agent。

> **路由自检**（checkpoint）：路由判断输出后，主对话必须明确列出：
> - 判定结果：工作流 A / B / C / 轻量流程
> - 判定理由：满足了哪些信号条件
> - 已排除的选项：为什么排除（一行说明即可）

---

**1.5 初始化配置触发（优先级高于 Intake）**

当用户表达以下意图之一，且项目根目录存在 `.claude/setup-checklist.md` 时：
- 「继续初始化」「继续配置」「setup」「init-setup」
- 「下一步」「继续」（在刚完成 init-project.sh 初始化之后的上下文中）

→ **跳过 Intake 三问**，直接等同于执行 `/init-setup` 命令。

> 初始化配置不是功能需求，不走 Intake → Agent 路由，而是由主对话直接驱动清单执行。

---

**2. 智能路由（Intake 完成后）**

### 分类决策树

```
需求已明确
    ↓
Q0: 是否属于轻量改动？
    （单文件改动 / bug fix / 配置变更 / 小特性增强 / 文案调整）
    ├── 是 → 走轻量流程（/dev 或 /fix），遵循 sdd-riper-one-light 协议
    └── 否 → 继续 Q1（正式多角色工作流）
         ↓
Q1: 是否涉及数据库/API/后端逻辑变更？
    ├── 否 → Q2
    └── 是 → Q3
         ↓
Q3: 是否同时涉及页面/组件/交互变更？
    ├── 否 → 纯后端（工作流 A）
    └── 是 → 前后端联动（工作流 C）

Q2: 是否涉及页面/组件/样式/交互变更？
    ├── 否 → 非功能性（文档/配置/规则变更，直接处理）
    └── 是 → 纯前端（工作流 B）→ 确定具体 App
```

### Q0 轻量模式判定标准

满足以下**全部**条件时走轻量流程，否则走正式工作流：
- 改动范围可预判，不超过 3 个文件
- 不涉及新建 API 端点或数据库表结构变更
- 需求明确，无需多角色协同澄清
- 不涉及跨项目（前后端联动）改动

> 轻量流程详见 `.claude/skills/sdd-riper-one-light/SKILL.md`

### 路由信号速查

| 工作流 | 触发信号（满足任一） |
|--------|-------------------|
| A 纯后端 | 新增/修改 DB 表、REST API、定时任务、外部集成、权限逻辑，且不涉及前端 |
| B 纯前端 | 仅页面/交互/样式变更，所需后端接口**已存在** |
| C 前后端联动 | 新建 API + 前端页面、修改 API 响应 + 前端适配、新增实体需建表+CRUD+页面 |
| 轻量 | Q0 全部条件满足 |

---

**3. Spec 产出物定义**

| 文件 | 产出者 | 定位 | 审批门控 |
|------|--------|------|---------|
| `01_requirement.md` | PM | 需求规格（业务语言，含字段级页面结构） | **用户必须审批** |
| `02_technical_design.md` | Arch | 技术设计（API Contract + 前端架构 + DB Schema + 风险） | **用户必须审批** |
| `03_impl_backend.md` | Dev | 后端执行日志（修改文件清单 + 关键决策 + 问题记录） | 无需审批，供 QA 参考 |
| `03_impl_frontend.md` | FE | 前端执行日志（修改文件清单 + 关键决策 + 问题记录） | 无需审批，供 QA 参考 |
| `04_test_plan.md` | Dev/FE | 测试计划（追溯矩阵 + 全流程用例），QA 审计 | 无需审批 |

---

**4. 工作流调度序列**

> 各 Agent 的内部行为规则见对应 Agent 定义文件。此处只定义调度序列和门控。

### 工作流 A：纯后端

```
PM(01) → [用户审批01] → Arch(02) → [用户审批02] → Dev(03+04+code) → QA(四轴+审计04) → 主会话(验证+合并)
```

### 工作流 B：纯前端

```
PM(01) → [用户审批01] → Prototype(需用户指示) → [用户确认原型] → Arch(02) → [用户审批02] → FE(03+04+code) → QA(四轴+审计04) → 主会话(验证+合并)
```

### 工作流 C：前后端联动

```
PM(01) → [用户审批01] → Prototype(需用户指示) → [用户确认原型] → Arch(02) → [用户审批02]
→ Dev⚡FE(worktree并行, 各自03+04+code) → 主会话(合并子分支) → QA(五轴+审计04) → 主会话(验证+合并)
```

**工作流 C 并行细节**：
- Dev worktree：`feature/<name>-backend` @ `.worktrees/feature-<name>-backend`
- FE worktree：`feature/<name>-frontend` @ `.worktrees/feature-<name>-frontend`
- 合并顺序：`git checkout -b feature/<name>` → merge backend → merge frontend

---

**5. 绝对禁止事项**

> No Spec / 未审批即流转 / 跳过 Intake 由 §1 触发条件和审批门控保证，此处不重复。

- Dev/FE 发现 Spec/设计问题后自行变通而不上报
- 在主对话中直接输出大段日志或长串代码修改（委派给子 Agent 处理）
- 前端任务加载 `coding_backend.md`；后端任务加载 `coding_frontend_shared.md`

---

**6. 主会话职责**

主会话（调度中心）承担以下职责：

> Intake/路由（§1）、审批门控（§1.1）、运行验证（§7）、提交合并（merge_checklist.md）已在对应章节定义，此处不重复。

- **派发约束**：派发子 Agent 时只指定产出物名称（如 01_requirement.md），**不指定文件写入路径**
- **跨 Agent 协调**：Agent 间流转时，负责状态同步和信息传递
- **异常处理**：Dev/FE 上报执行中断时，协调处理（打回 PM/Arch 修改 Spec，或调整方案）
- **不重复建分支**：feature 分支由 Dev/FE Agent 创建，主会话只检查状态
- **知识体系透传**：派发 Agent 时，如目标子项目存在 `knowledge-index.md`，提示 Agent 按知识加载协议检查知识体系
- **路径校验（通用）**：所有 Agent 写入文件前，必须校验路径是否与项目约定一致。校验方式：检查 `.claude/specs/` 下已有同类文件位置；不一致时使用项目约定路径并注明差异

---

**7. 运行验证（QA PASS 后、合并前）**

| 验证类型 | 适用工作流 | 方式 | 证据 |
|---------|-----------|------|------|
| 后端 API | A / C | 主会话读取 04 Part B → 启动服务 → 按 curl 步骤自动执行 → 比对预期 → 回写状态 | `evidences/evidence-api-test.md` |
| 前端页面 | B / C | 用户按 04 Part B 人工验证清单操作浏览器 | 用户反馈 |
| 全栈联调 | C | 后端自动验证 + 前端人工验证 | 同上 |

### E2E 测试（可选）

QA PASS 后，如项目有 `e2e/` 目录和 Playwright 配置，主会话**询问用户**是否执行 E2E 测试。
选择执行时：先 Deploy → E2E Runner 基于 02 Part E 执行测试 → PASS 进入验证 / FAIL 上报处理。

### Deploy（可选、非阻塞）

主会话只负责触发构建脚本并推送镜像，不等待服务器部署完成。

---

**8. Jira 集成（可选、非阻塞）**

项目配置了 Jira MCP Server（`.mcp.json`）时，各阶段自动关联：
- Intake：检测 Issue Key → 获取详情
- PM/Dev/FE/QA：按 jira-task-management Skill 操作
- 收尾：合并完成后关闭 Issue

未配置时所有 Jira 操作静默跳过，不影响工作流。

---

**9. 会话日志（轻量数据收集）**

**目的**：收集框架使用数据，用数据驱动规则改进。

**触发条件**：工作流完成（合并成功）或中断（用户取消 / 异常终止 / 会话结束前未完成）时，主会话追加一条记录。

**记录格式**（追加到 `.claude/session-log.csv`）：

```csv
timestamp,workflow,rounds,status,interrupt_stage,notes
```

| 字段 | 说明 | 示例 |
|------|------|------|
| timestamp | ISO 格式时间 | `2026-04-23T14:30:00` |
| workflow | 工作流类型 | `A` / `B` / `C` / `lightweight` / `none` |
| rounds | 总对话轮次（估算） | `18` |
| status | 结束状态 | `completed` / `interrupted` / `cancelled` |
| interrupt_stage | 中断环节（完成时填 `-`） | `intake` / `pm` / `arch` / `dev` / `qa` / `verify` / `-` |
| notes | 简要备注（可选） | `QA打回1次` / `用户取消` / `-` |

**行为要求**：

- 文件不存在时自动创建并写入 CSV 头行
- 首次创建前检查 `.claude/` 目录是否存在
- 中断场景：用户明确说"不用了"/"算了"时记录为 `cancelled`；会话意外结束时无法记录（可接受）
- 轻量流程（sdd-riper-one-light）完成时同样记录，workflow 填 `lightweight`
- 纯查询/解释类对话（未触发工作流）**不需要记录**

:::

