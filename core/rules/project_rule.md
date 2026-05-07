# 全栈协作调度规则（框架标准）

> 主对话（调度中心）的全局指导。编码规则见 `.claude/rules/coding_backend.md`、`.claude/context/coding_frontend_shared.md`；业务名词见 `.claude/skills/domain-ontology/SKILL.md`。

***

## 0.5 初始化配置触发

当用户表达「继续初始化」「setup」「init-setup」等意图，且项目存在 `.claude/setup-checklist.md` 时，**跳过 Intake**，直接驱动清单执行。初始化不是功能需求，不走 Agent 路由。

***

## 1. Intake 触发规则

> Intake 的目的是澄清模糊需求，而非为明确需求增加流程负担。

### 1.0 需求判定表

| 判定                 | 条件                              |
| ------------------ | ------------------------------- |
| **跳过 Intake，直连路由** | 目标明确 + 改动 ≤3 文件（或有参考实现）+ 无歧义    |
| **必须触发 Intake**    | 需求模糊 / 多方案需决策 / 范围不可预判 / 业务规则不清 |
| **始终跳过**           | 纯解释查询 / 已有复现路径的 bug 定位          |

> 直连路由时仍须输出一句简短路由说明，供用户快速确认。

### 1.1 Intake 三问

> 三问前，主动加载 domain-ontology Skill，以便在澄清需求时引用已有业务术语和实体定义，提升提问的精准度。若项目尚未填写 domain-ontology，则跳过加载，按通用方式提问。

```
1. 目标   — 要做什么？数据来源？涉及哪个项目？
2. 边界   — 不做什么？是否需要鉴权？是否涉及已有接口？
3. 验收   — 做完怎么算完成？
```

### 1.2 需求确认与路由自检

三问后**不得立即路由**。向用户呈现：需求要点摘要 → 路由判断及理由 → 询问「还有补充吗？没有则启动 PM」。
**只有用户明确回复"开始"/"确认"等同意信号后**，才可启动 PM Agent。
路由自检须列出：判定结果（A/B/C/轻量）+ 满足的信号条件 + 已排除选项的理由。

***

## 2. 智能路由

### 分类决策树

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

### Q0 轻量模式判定标准

满足**全部**条件时走轻量流程：改动 ≤3 文件 / 不涉及新 API 或表结构 / 需求明确无需多角色 / 不涉及跨项目。

### 路由信号速查

| 工作流   | 触发信号（满足任一）                                 |
| ----- | ------------------------------------------ |
| A 纯后端 | 新增/修改 DB 表、REST API、定时任务、外部集成、权限逻辑，且不涉及前端  |
| B 纯前端 | 仅页面/交互/样式变更，所需后端接口**已存在**                  |
| C 联动  | 新建 API + 前端页面、修改 API + 前端适配、新实体需建表+CRUD+ 页面 |
| 轻量    | Q0 全部条件满足                                  |

### §2.5 Skill 加载指引

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

***

## 3. Spec 产出物定义

| 文件                       | 产出者    | 定位                                         | 审批门控         |
| ------------------------ | ------ | ------------------------------------------ | ------------ |
| `01_requirement.md`      | PM     | 需求规格（业务语言，含字段级页面结构）                        | **用户必须审批**   |
| `02_technical_design.md` | Arch   | 技术设计（API Contract + 前端架构 + DB Schema + 风险） | **用户必须审批**   |
| `03_impl_backend.md`     | Dev    | 后端执行日志（修改文件 + 关键决策 + 问题记录）                 | 无需审批，供 QA 参考 |
| `03_impl_frontend.md`    | FE     | 前端执行日志（修改文件 + 关键决策 + 问题记录）                 | 无需审批，供 QA 参考 |
| `04_test_plan.md`        | Dev/FE | 测试计划（追溯矩阵 + 全流程用例），QA 审计                   | 无需审批         |

***

## 4. 工作流调度序列

> 各 Agent 内部行为见对应定义文件，此处只定义调度序列和门控。

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

### 工作流 C 并行细节

> **主会话硬约束**：派发 Dev 和 FE 并行 Agent 前，主会话**必须**为每个 Agent 创建独立 Worktree（使用 `isolation: worktree` 参数），禁止两个 Agent 共用同一分支或同一工作目录。

**隔离操作步骤**：
1. 主会话先创建目标合并分支：`git checkout -b feature/<name>`
2. 派发 Dev Agent 时指定 `isolation: worktree`，Dev 在隔离环境中创建 `feature/<name>-backend` 子分支
3. 派发 FE Agent 时同样指定 `isolation: worktree`，FE 在隔离环境中创建 `feature/<name>-frontend` 子分支
4. 两个 Agent 完成后，主会话按顺序合并：`git checkout feature/<name>` → merge backend → merge frontend

**分支命名**：Dev `feature/<name>-backend` + FE `feature/<name>-frontend`

## 5. 绝对禁止事项

* Dev/FE 发现 Spec/设计问题后自行变通而不上报
* 在主对话中直接输出大段日志或长串代码修改（委派给子 Agent 处理）
* 前端任务加载后端编码规则；后端任务加载前端编码规则
* 未经用户审批直接流转到下一阶段

***

## 6. 主会话职责

> Intake/路由（§1）、审批门控（§1.1）、运行验证（§7）、提交合并（merge\_checklist.md）已在对应章节定义。

* **派发约束**：派发子 Agent 时只指定产出物名称，**不指定文件写入路径**
* **跨 Agent 协调**：Agent 间流转时，负责状态同步和信息传递
* **异常处理**：Dev/FE 上报执行中断时，协调处理（打回 PM/Arch 修改 Spec，或调整方案）
* **并行隔离（Workflow C）**：派发 Dev/FE 并行 Agent 时，必须使用 `isolation: worktree` 创建隔离环境，禁止共用同一分支；Agent 在各自隔离环境内自行建 feature 子分支
* **知识体系透传**：派发 Agent 时，如目标子项目存在 `knowledge-index.md`，提示 Agent 按知识加载协议检查
* **路径校验**：所有 Agent 写入文件前校验路径与项目约定一致（检查 `.claude/specs/` 下已有同类文件位置）

***

## 7. 运行验证（QA PASS 后、合并前）

| 验证类型   | 适用  | 方式                                                   | 证据                               |
| ------ | --- | ---------------------------------------------------- | -------------------------------- |
| 后端 API | A/C | 主会话读取 04 Part B → 启动服务 → 按 curl 步骤自动执行 → 比对预期 → 回写状态 | `evidences/evidence-api-test.md` |
| 前端页面   | B/C | 用户按 04 Part B 人工验证清单操作浏览器                            | 用户反馈                             |
| 全栈联调   | C   | 后端自动验证 + 前端人工验证                                      | 同上                               |

**E2E（可选）**：QA PASS 后如项目有 `e2e/` + Playwright，询问用户是否执行。选择执行：Deploy → E2E Runner 基于 02 Part E 执行 → PASS 进入验证 / FAIL 上报。
**Deploy（可选、非阻塞）**：主会话只触发构建脚本并推送镜像，不等待部署完成。
-------------------------------------------

## 8. Jira 集成（可选、非阻塞）

> 项目配置了 Jira MCP Server（`.mcp.json`）时自动关联：Intake 检测 Issue Key → PM/Dev/FE/QA 按 jira-task-management Skill 操作 → 合并完成后关闭 Issue。未配置时静默跳过。

## 9. 会话日志

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

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
