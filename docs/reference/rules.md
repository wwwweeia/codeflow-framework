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

本项目的 `.claude/` 目录中有部分文件由公司级框架 **h-codeflow-framework** 统一管理。框架的目的是让所有业务项目共享经过验证的工作流、Agent 行为、审查规则和开发规范，避免各项目各自为政、重复踩坑。
框架采用**两层分离**架构：
- **框架层**（`../h-codeflow-framework/core/`）：公司级通用内容，通过 `upgrade.sh` 同步到各项目
- **项目层**（本项目 `.claude/`）：项目特有的业务规则、领域知识、自定义扩展
被框架管理的文件包含一行 marker 注释：

::: details 查看完整定义

**框架协作规则**

**框架是什么**

本项目的 `.claude/` 目录中有部分文件由公司级框架 **h-codeflow-framework** 统一管理。框架的目的是让所有业务项目共享经过验证的工作流、Agent 行为、审查规则和开发规范，避免各项目各自为政、重复踩坑。

框架采用**两层分离**架构：
- **框架层**（`../h-codeflow-framework/core/`）：公司级通用内容，通过 `upgrade.sh` 同步到各项目
- **项目层**（本项目 `.claude/`）：项目特有的业务规则、领域知识、自定义扩展

**Marker 机制与双向同步**

被框架管理的文件包含一行 marker 注释：
```

:::

## iron-rules (`iron-rules.md`)

> 以下规则是不可违反的底线。各 Agent 另有角色特有的行为约束，见各自定义文件。
1. **Spec is Truth, Design is Guide**
   - `01_requirement.md` = 做什么（必须忠实执行）
   - `02_technical_design.md` = 怎么做（必须遵循）
   - 两份文档已经用户审批，直接按此执行

::: details 查看完整定义

**框架铁律（所有 Agent 共享）**

> 以下规则是不可违反的底线。各 Agent 另有角色特有的行为约束，见各自定义文件。

1. **Spec is Truth, Design is Guide**
   - `01_requirement.md` = 做什么（必须忠实执行）
   - `02_technical_design.md` = 怎么做（必须遵循）
   - 两份文档已经用户审批，直接按此执行

2. **No Spec No Code**：任何代码开发前，必须有用户审批过的 Spec

3. **发现问题立即停止**：执行中发现 Spec 或设计有误/缺失/无法落地时，立即停止编码，将问题记录到 03 执行日志，上报主对话。不自行变通

4. **YAGNI/KISS**：严禁过度设计。简单 CRUD 或查询禁止创建无业务逻辑的中间层，直接闭环

5. **证据落盘**：测试输出、执行日志、审查结论写入 `.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/evidences/`，禁止在对话中输出大段日志

6. **合并按 SOP**：合并操作按 `.claude/rules/merge_checklist.md` 执行（代码质量由自查两阶段 + QA 覆盖）

7. **残留代码不构成 Spec**：编译产物、git 历史中的已删除代码、孤立的 store/配置文件、仍然存活的数据库表，均不能代替正式 Spec。即使残留物看起来"功能完整"，新功能开发也必须走完整 Intake→路由流程。恢复已删除功能等同于新功能开发。

:::

## 知识加载协议 (`knowledge-protocol.md`)

> 本文件是所有 Agent 的知识加载行为规则。Claude Code 自动加载本文件，所有 Agent 无需额外引用即可感知。
每个子项目（后端 / 前端 App）的知识资产按以下结构组织：
| 问题 | rules | cookbook | pattern | context |
|------|-------|----------|---------|---------|
| 违反了算 Bug 吗？ | 是 | 否 | 否 | 否 |

::: details 查看完整定义

**知识加载协议（框架标准）**

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

**判断一条知识该放哪里**

| 问题 | rules | cookbook | pattern | context |
|------|-------|----------|---------|---------|
| 违反了算 Bug 吗？ | 是 | 否 | 否 | 否 |
| 有完整代码示例吗？ | 不需要 | **必须有** | 有片段 | 不需要 |
| 描述的是"怎么做"还是"为什么"？ | 怎么做 | 怎么做 | **为什么** | 是什么 |
| 会被多个场景复用吗？ | — | 单场景 | **多场景** | — |

**不应放入知识体系的内容**

- 纯代码导航（放 Codemap：`.claude/codemap/domains/`）
- 一次性临时信息（放 Spec 目录：`.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/`）
- 框架已管理的通用规则（放 `core/rules/`，通过 upgrade.sh 同步）

---

**2. 加载协议**

Agent 进入具体子项目执行任务时，按以下步骤加载知识：

1. **检查知识索引**：读取目标子项目的 `.claude/context/knowledge-index.md`（不存在则跳过后续步骤）
2. **匹配任务**：根据 knowledge-index 中「任务到知识映射」表，匹配当前任务场景
3. **加载知识文件**：若匹配到映射行，读取对应的 cookbook/pattern 文件
4. **不阻塞**：知识索引不存在或无匹配行时，跳过，不影响工作流

**加载优先级**

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

**Dev / FE Agent**

- **时机**：Research 阶段
- **使用**：实现中必须参考已加载 cookbook 的数据流和关键点
- **反馈**：如发现 cookbook 与实际代码不一致，记录到 `03_impl_*.md` 并上报主对话

**Arch Agent**

- **时机**：Research 阶段（加载上下文时）
- **使用**：了解已有知识资产，设计时对齐 cookbook 描述的既定模式
- **对齐检查**：技术设计方案如偏离已有 cookbook/pattern，必须在 `02 Part C`（技术风险）中说明原因

**QA Agent**

- **时机**：Load Specs 阶段
- **使用**：读取知识条目作为审查补充参考
- **覆盖度检查**：检查本次变更涉及的功能区域是否有对应知识条目；如缺少，在审查报告中建议补充

**主会话**

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

**沉淀原则**

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

**合并流程 SOP (Merge SOP)**

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

> 主对话（调度中心）的全局指导。编码规则见 `.claude/rules/coding_backend.md`、`.claude/context/coding_frontend_shared.md`；业务名词见 `.claude/skills/domain-ontology/SKILL.md`。
当用户表达「继续初始化」「setup」「init-setup」等意图，且项目存在 `.claude/setup-checklist.md` 时，**跳过 Intake**，直接驱动清单执行。初始化不是功能需求，不走 Agent 路由。
> Intake 的目的是澄清模糊需求，而非为明确需求增加流程负担。
| 判定                 | 条件                              |
| ------------------ | ------------------------------- |

::: details 查看完整定义

**全栈协作调度规则（框架标准）**

> 主对话（调度中心）的全局指导。编码规则见 `.claude/rules/coding_backend.md`、`.claude/context/coding_frontend_shared.md`；业务名词见 `.claude/skills/domain-ontology/SKILL.md`。

---

**0.5 初始化配置触发**

当用户表达「继续初始化」「setup」「init-setup」等意图，且项目存在 `.claude/setup-checklist.md` 时，**跳过 Intake**，直接驱动清单执行。初始化不是功能需求，不走 Agent 路由。

---

**1. Intake 触发规则**

> Intake 的目的是澄清模糊需求，而非为明确需求增加流程负担。

**1.0 需求判定表**

| 判定                 | 条件                              |
| ------------------ | ------------------------------- |
| **跳过 Intake，直连路由** | 目标明确 + 改动 ≤3 文件（或有参考实现）+ 无歧义    |
| **必须触发 Intake**    | 需求模糊 / 多方案需决策 / 范围不可预判 / 业务规则不清 |
| **始终跳过**           | 纯解释查询 / 已有复现路径的 bug 定位          |

> 直连路由时仍须输出一句简短路由说明，供用户快速确认。

**1.1 Intake 三问**

> 三问前，主动加载 domain-ontology Skill，以便在澄清需求时引用已有业务术语和实体定义，提升提问的精准度。若项目尚未填写 domain-ontology，则跳过加载，按通用方式提问。

```
1. 目标   — 要做什么？数据来源？涉及哪个项目？
2. 边界   — 不做什么？是否需要鉴权？是否涉及已有接口？
3. 验收   — 做完怎么算完成？
```

**1.2 需求确认与路由自检**

三问后**不得立即路由**。向用户呈现：需求要点摘要 → 路由判断及理由 → 询问「还有补充吗？没有则启动 PM」。
**只有用户明确回复"开始"/"确认"等同意信号后**，才可启动 PM Agent。
路由自检须列出：判定结果（A/B/C/轻量）+ 满足的信号条件 + 已排除选项的理由。

---

**2. 智能路由**

**分类决策树**

```
需求已明确
    ↓
Q0: 是否属于轻量改动？（单文件改动 / bug fix / 配置变更 / 小特性增强 / 文案调整）
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
    ├── 否 → 非功能性（文档/配置变更，直接处理）
    └── 是 → 纯前端（工作流 B）→ 确定具体 App
```

**Q0 轻量模式判定标准**

满足**全部**条件时走轻量流程：改动 ≤3 文件 / 不涉及新 API 或表结构 / 需求明确无需多角色 / 不涉及跨项目。

**路由信号速查**

| 工作流   | 触发信号（满足任一）                                 |
| ----- | ------------------------------------------ |
| A 纯后端 | 新增/修改 DB 表、REST API、定时任务、外部集成、权限逻辑，且不涉及前端  |
| B 纯前端 | 仅页面/交互/样式变更，所需后端接口**已存在**                  |
| C 联动  | 新建 API + 前端页面、修改 API + 前端适配、新实体需建表+CRUD+ 页面 |
| 轻量    | Q0 全部条件满足                                  |

**§2.5 Skill 加载指引**

路由完成后，主会话在派发 Agent 时指定本次加载的 Skill 分组。各 Agent 的 Skill 按以下分类（详见各 Agent 定义文件的 skills 字段）：

| 分类       | 说明                                               | 加载时机        |
| -------- | ------------------------------------------------ | ----------- |
| core     | 角色必需知识（spec-templates、domain-ontology 等）         | 始终加载        |
| backend  | 后端工作流（backend-rules、api-reviewer、sql-checker 等）  | 后端/全栈模式     |
| frontend | 前端工作流（frontend-conventions、frontend-ui-design 等） | 前端/全栈模式     |
| optional | 外部集成（jira-task-management、confluence-doc-sync）   | 检测到 MCP 可用时 |

**按工作流的加载组合**：

| 工作流  | PM   | Arch                  | Dev/FE              | QA                    |
| ---- | ---- | --------------------- | ------------------- | --------------------- |
| A 后端 | core | core+backend          | core+backend        | core+backend          |
| B 前端 | core | core+frontend         | core+frontend       | core+frontend         |
| C 全栈 | core | core+backend+frontend | core+ 对应端            | core+backend+frontend |
| 轻量   | —    | —                     | sdd-riper-one-light | —                     |

---

**3. Spec 产出物定义**

| 文件                       | 产出者    | 定位                                         | 审批门控         |
| ------------------------ | ------ | ------------------------------------------ | ------------ |
| `01_requirement.md`      | PM     | 需求规格（业务语言，含字段级页面结构）                        | **用户必须审批**   |
| `02_technical_design.md` | Arch   | 技术设计（API Contract + 前端架构 + DB Schema + 风险） | **用户必须审批**   |
| `03_impl_backend.md`     | Dev    | 后端执行日志（修改文件 + 关键决策 + 问题记录）                 | 无需审批，供 QA 参考 |
| `03_impl_frontend.md`    | FE     | 前端执行日志（修改文件 + 关键决策 + 问题记录）                 | 无需审批，供 QA 参考 |
| `04_test_plan.md`        | Dev/FE | 测试计划（追溯矩阵 + 全流程用例），QA 审计                   | 无需审批         |

---

**4. 工作流调度序列**

> 各 Agent 内部行为见对应定义文件，此处只定义调度序列和门控。

**工作流 A：纯后端**

```
PM(01) → [用户审批01] → Arch(02) → [用户审批02] → Dev(03+04+code) → QA(四轴+审计04) → 主会话(验证+合并)
```

**工作流 B：纯前端**

```
PM(01) → [用户审批01] → Prototype(需用户指示) → [用户确认原型] → Arch(02) → [用户审批02] → FE(03+04+code) → QA(四轴+审计04) → 主会话(验证+合并)
```

**工作流 C：前后端联动**

```
PM(01) → [用户审批01] → Prototype(需用户指示) → [用户确认原型] → Arch(02) → [用户审批02]
→ Dev⚡FE(worktree并行, 各自03+04+code) → 主会话(合并子分支) → QA(五轴+审计04) → 主会话(验证+合并)
```

**工作流 C 并行细节**

> **主会话硬约束**：派发 Dev 和 FE 并行 Agent 前，主会话**必须**为每个 Agent 创建独立 Worktree（使用 `isolation: worktree` 参数），禁止两个 Agent 共用同一分支或同一工作目录。

**隔离操作步骤**：
1. 主会话先创建目标合并分支：`git checkout -b feature/<name>`
2. 派发 Dev Agent 时指定 `isolation: worktree`，Dev 在隔离环境中创建 `feature/<name>-backend` 子分支
3. 派发 FE Agent 时同样指定 `isolation: worktree`，FE 在隔离环境中创建 `feature/<name>-frontend` 子分支
4. 两个 Agent 完成后，主会话按顺序合并：`git checkout feature/<name>` → merge backend → merge frontend

**分支命名**：Dev `feature/<name>-backend` + FE `feature/<name>-frontend`

**5. 绝对禁止事项**

* Dev/FE 发现 Spec/设计问题后自行变通而不上报
* 在主对话中直接输出大段日志或长串代码修改（委派给子 Agent 处理）
* 前端任务加载后端编码规则；后端任务加载前端编码规则
* 未经用户审批直接流转到下一阶段

---

**6. 主会话职责**

> Intake/路由（§1）、审批门控（§1.1）、运行验证（§7）、提交合并（merge\_checklist.md）已在对应章节定义。

* **派发约束**：派发子 Agent 时只指定产出物名称，**不指定文件写入路径**
* **跨 Agent 协调**：Agent 间流转时，负责状态同步和信息传递
* **异常处理**：Dev/FE 上报执行中断时，协调处理（打回 PM/Arch 修改 Spec，或调整方案）
* **并行隔离（Workflow C）**：派发 Dev/FE 并行 Agent 时，必须使用 `isolation: worktree` 创建隔离环境，禁止共用同一分支；Agent 在各自隔离环境内自行建 feature 子分支
* **知识体系透传**：派发 Agent 时，如目标子项目存在 `knowledge-index.md`，提示 Agent 按知识加载协议检查
* **路径校验**：所有 Agent 写入文件前校验路径与项目约定一致（检查 `.claude/specs/` 下已有同类文件位置）

---

**7. 运行验证（QA PASS 后、合并前）**

| 验证类型   | 适用  | 方式                                                   | 证据                               |
| ------ | --- | ---------------------------------------------------- | -------------------------------- |
| 后端 API | A/C | 主会话读取 04 Part B → 启动服务 → 按 curl 步骤自动执行 → 比对预期 → 回写状态 | `evidences/evidence-api-test.md` |
| 前端页面   | B/C | 用户按 04 Part B 人工验证清单操作浏览器                            | 用户反馈                             |
| 全栈联调   | C   | 后端自动验证 + 前端人工验证                                      | 同上                               |

**E2E（可选）**：QA PASS 后如项目有 `e2e/` + Playwright，询问用户是否执行。选择执行：Deploy → E2E Runner 基于 02 Part E 执行 → PASS 进入验证 / FAIL 上报。
**Deploy（可选、非阻塞）**：主会话只触发构建脚本并推送镜像，不等待部署完成。
---

**8. Jira 集成（可选、非阻塞）**

> 项目配置了 Jira MCP Server（`.mcp.json`）时自动关联：Intake 检测 Issue Key → PM/Dev/FE/QA 按 jira-task-management Skill 操作 → 合并完成后关闭 Issue。未配置时静默跳过。

**9. 会话日志**

**触发**：工作流完成（合并成功）或中断（用户取消 / 异常终止）时追加一条记录到 `.claude/session-log.csv`。纯查询类不记录。文件不存在时自动创建并写入头行。

```csv
timestamp,workflow,rounds,status,interrupt_stage,notes
```

| 字段               | 说明            | 示例                                                       |
| ---------------- | ------------- | -------------------------------------------------------- |
| timestamp        | ISO 格式        | `2026-04-23T14:30:00`                                    |
| workflow         | 工作流类型         | `A` / `B` / `C` / `lightweight` / `none`                 |
| rounds           | 对话轮次（估算）      | `18`                                                     |
| status           | 结束状态          | `completed` / `interrupted` / `cancelled`                |
| interrupt\_stage | 中断环节（完成填 `-`） | `intake` / `pm` / `arch` / `dev` / `qa` / `verify` / `-` |
| notes            | 简要备注          | `QA打回1次` / `用户取消` / `-`                                  |

:::

