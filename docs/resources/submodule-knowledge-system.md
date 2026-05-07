# 子模块知识体系增强方法论

> 版本：v1.0 | 日期：2026-04-23 | 作者：wqw + Claude Code

## 一、问题：框架有了，模块该填什么？

### 1.1 现象

在 AI 辅助开发实践中，我们建立了公司级的协作框架（h-codeflow-framework），统一了：
- **流程编排**：Intake 三问 → 智能路由 → PM/Arch/Dev/FE/QA 六角色工作流
- **通用规范**：编码硬规则、命名规范、Git 规范
- **Agent 定义**：7 个专业 Agent 的行为边界和技能加载

框架回答了 **"怎么协作"** 的问题。但在实际编码场景中，我们发现一个明显的断层：

| 子模块 | 框架规则覆盖 | 模块领域知识覆盖 | 差距 |
|--------|------------|----------------|------|
| 后端 (ai-kg-agent-hub) | 完整的编码硬规则 + 3 场景规则 | 5 个上下文文件 | 部分业务域仍缺场景规则 |
| 前端子模块 (agent-center) | 空壳规则文件 | 路由/Store/组件清单 | **几乎空白** |
| 前端子模块 (claw) | 空壳规则文件 | 路由/Store/组件清单 | **几乎空白** |

**核心矛盾**：框架定义了流程，但具体到每个子模块的业务域、交互模式、常见陷阱，Agent 缺乏可参考的领域知识。就像给了一个新员工完整的工作流程手册，但没有告诉他"这个系统里消息推送的坑在哪里"。

### 1.2 目标

为每个子模块建立 **"领域知识体系"**，让 Agent 在编码时能像熟悉项目的高级工程师一样做出正确决策。

---

## 二、框架与模块的职责边界

先搞清楚什么该框架管、什么该模块管，避免重复建设或职责混乱。

| 维度 | 框架管 | 模块管 |
|------|--------|--------|
| 编排流程 | Intake 三问、路由决策、Spec 格式、合并 SOP | — |
| 通用编码 | 分层架构、命名、样式、错误处理、Git 规范 | — |
| Agent 行为 | 角色定义、审查轴、Skill 加载 | — |
| 业务域知识 | — | 实体关系、场景规则、API 约定、数据流 |
| 模块特有约束 | — | 微前端宿主/子应用规则、WebSocket 模式、权限码体系 |
| 常见陷阱 | — | 架构痛点、历史包袱、兼容性陷阱 |

**核心原则：框架定义"怎么协作"，模块定义"这个域怎么写"。**

判断一件知识该放哪里，问一个问题：**"换一个项目，这条规则还有用吗？"**
- 有用 → 框架层
- 不一定 → 模块层

---

## 三、知识资产类型体系

我们在实践中定义了四种知识资产类型，放在子模块的 `.claude/` 目录中：

```
rules/                    → 硬约束（违反即 Bug），Agent 需主动读取
                            示例："禁止直接调 Mapper"

context/                  → 软知识（按需参考）
                            示例：路由清单、Store 模块、组件结构

context/cookbook-*.md     → 场景化实操指南
                            "要做 X 应该怎么写"，带完整代码示例
                            示例：cookbook-websocket-chat.md

context/pattern-*.md      → 设计模式与最佳实践
                            重复出现的架构模式、推荐方案
                            示例：pattern-dual-write.md
```

跨模块的数据流文档统一放在项目根 `.claude/context/dataflow-*.md`。

### 3.1 各类型的定位

```
                    抽象程度高
                        ↑
              pattern    |    rules
           (设计模式)    |   (硬约束)
                        |
         ───────────────┼───────────────→ 强制程度高
                        |
            cookbook    |   context
           (实操指南)    |   (参考知识)
                        ↓
                    具体程度高
```

### 3.2 为什么不新建顶级目录

`cookbook/` 和 `pattern/` 文件统一放在 `context/` 下，通过命名前缀区分类型。原因：
1. 保持与 Claude Code 的 `.claude/` 结构约定一致
2. 避免破坏框架 `upgrade.sh` 的同步机制
3. 通过 `knowledge-index.md` 索引文件统一管理

### 3.3 各类型的判断标准

| 问题 | rules | cookbook | pattern | context |
|------|-------|----------|---------|---------|
| 违反了算 Bug 吗？ | 是 | 否 | 否 | 否 |
| 有完整代码示例吗？ | 不需要 | **必须有** | 有片段 | 不需要 |
| 描述的是"怎么做"还是"为什么"？ | 怎么做 | 怎么做 | **为什么** | 是什么 |
| 会被多个场景复用吗？ | — | 单场景 | **多场景** | — |

---

## 四、各子模块增强清单

### 4.1 后端 (ai-kg-agent-hub)

后端已有 1 个硬规则 + 3 个场景规则 + 5 个上下文，覆盖较好。需要补充：

| 优先级 | 增强项 | 类型 | 文件 |
|--------|--------|------|------|
| P0 | HITL 人机协同 Cookbook | cookbook | `context/cookbook-hitl.md` |
| P0 | 定时任务调度 Cookbook | cookbook | `context/cookbook-task-scheduling.md` |
| P0 | 应用接入与权限 Cookbook | cookbook | `context/cookbook-application-access.md` |
| P1 | 渠道集成 Cookbook | cookbook | `context/cookbook-channel-integration.md` |
| P1 | 提示词版本管理 Cookbook | cookbook | `context/cookbook-prompt-versioning.md` |
| P1 | 双写一致性 Pattern | pattern | `context/pattern-dual-write.md` |
| P1 | 定时同步基类 Pattern | pattern | `context/pattern-sync-task.md` |
| P2 | WebSocket 生命周期 | context | `context/websocket-lifecycle.md` |
| P2 | SSH 命令执行 | context | `context/ssh-command-execution.md` |
| P2 | 枚举字段速查 | context | `context/entity-field-enums.md` |

### 4.2 h-kg-agent-center (Agent 管理中心)

| 优先级 | 增强项 | 类型 | 文件 |
|--------|--------|------|------|
| P0 | 充实 frontend_coding.md | 规则 | `rules/frontend_coding.md` |
| P1 | CRUD 模块 Cookbook | cookbook | `context/cookbook-crud-module.md` |
| P1 | 资源关联管理 Cookbook | cookbook | `context/cookbook-relation-management.md` |
| P1 | 权限树分配 Cookbook | cookbook | `context/cookbook-permission-tree.md` |
| P2 | 导入导出 Cookbook | cookbook | `context/cookbook-import-export.md` |

### 4.3 h-kg-claw (数字员工)

| 优先级 | 增强项 | 类型 | 文件 |
|--------|--------|------|------|
| P0 | 充实 frontend_coding.md | 规则 | `rules/frontend_coding.md` |
| P0 | WebSocket 对话 Cookbook | cookbook | `context/cookbook-websocket-chat.md` |
| P1 | HITL 审批流程 Cookbook | cookbook | `context/cookbook-hitl-audit.md` |
| P1 | 数字员工管理 Cookbook | cookbook | `context/cookbook-digital-employee.md` |
| P1 | claw Store Pattern | pattern | `context/pattern-claw-store.md` |
| P2 | 渠道配置 Cookbook | cookbook | `context/cookbook-channel-config.md` |

### 4.4 跨模块数据流

| 优先级 | 增强项 | 文件 |
|--------|--------|------|
| P0 | Agent 管理数据流 | 根 `.claude/context/dataflow-agent-management.md` |
| P1 | 对话链路数据流 | 根 `.claude/context/dataflow-gateway-chat.md` |
| P1 | HITL 审批数据流 | 根 `.claude/context/dataflow-hitl-approval.md` |
| P2 | 渠道集成数据流 | 根 `.claude/context/dataflow-channel-integration.md` |

---

## 五、落地策略：需求驱动

**不预先批量生产文档**。知识体系在实际开发任务中逐步沉淀。

### 5.1 采集时机

将知识采集嵌入现有的 SDD 工作流，不额外增加流程负担：

| 时机 | 动作 | 触发条件 |
|------|------|---------|
| Dev/FE 执行完编码 | 检查是否需要新增 cookbook | 新增了可复用的代码模式 |
| QA 完成审查 | 检查是否需要新增/更新规则 | 发现了新的常见问题或反模式 |
| 主会话合并完成后 | 更新 knowledge-index | 涉及新业务域 |

### 5.2 知识来源

不要凭空设计，从实际产出中提炼：

1. **从已完成 Spec 中提炼**：每个 Feature Spec 完成后，检查是否有可沉淀的模式
2. **从代码审查中提炼**：QA 发现的常见问题 → 规则化
3. **从 git log 中挖掘**：高频修改的文件区域通常需要更好的文档化

### 5.3 与框架的双向提升

模块内的知识经过验证后，可以提升到框架层：

```
模块 cookbook/pattern（单次验证）
    ↓ 在 2+ 个子模块中验证同一模式
框架 Skill（多项目通用）
    ↓ 通过 framework-feedback 提交
upgrade.sh 同步到所有项目
```

不应提升到框架的知识：
- 业务域特有的实体关系（如 Agent-MCP-Skill 的挂载逻辑）
- 特定 API 端点的字段枚举
- UI 交互细节（如权限树分配的具体操作流程）

---

## 六、数据流文档模板

跨模块数据流是前端后端联动的关键文档，统一使用以下模板：

```markdown
# 数据流：<场景名>

## 端到端流程（Mermaid sequenceDiagram）

## 后端入口
- Controller: ...
- Service: ...
- Mapper: ...

## 前端入口
- App: ...
- Store Action: ...
- API 调用: ...

## 字段映射表
| 后端字段 | 前端字段 | 说明 |

## 错误处理链路
- 后端异常 → 全局拦截器 → 前端展示

## 已知坑点
- ...
```

---

## 七、样板参考

我们选择了 **h-kg-claw**（数字员工前端）作为首个样板模块，原因是：
1. 交互最复杂（WebSocket 对话、流式消息、HITL 审批）
2. 当前知识覆盖最薄弱（规则文件为空壳）
3. 完成后对 Agent 编码质量的提升最显著

样板产出物：
- 充实的 `rules/frontend_coding.md`
- `context/cookbook-websocket-chat.md`
- `context/knowledge-index.md`

其他模块和项目组可参照此样板，按相同结构建设自己的知识体系。

---

## 八、关键决策记录

| 决策 | 选项 | 选择 | 理由 |
|------|------|------|------|
| 知识类型体系 | 两层/三层/按业务域 | rules + context（cookbook/pattern 前缀命名）+ dataflow | 覆盖硬约束、实操、抽象、跨模块四个维度 |
| 文件存放方式 | 新建顶级目录/前缀命名 | 前缀命名放 context/ | 不破坏 upgrade.sh 同步机制 |
| 落地策略 | 集中建设/需求驱动 | 需求驱动 | 不预先批量生产，跟着业务长 |
| 首个样板模块 | agent-center/claw/front | h-kg-claw | 交互最复杂，覆盖最薄弱，效果最显著 |

---

## 九、Codemap vs 子模块知识体系：职责对比

框架中已存在 Codemap 机制（`.claude/codemap/domains/`），新引入的知识体系（cookbook/pattern/knowledge-index）与之是互补关系，不是替代关系。

### 9.1 一句话定位

| 资产 | 定位 | 类比 |
|------|------|------|
| **Codemap** | 已有代码的导航索引——"代码在哪里、怎么调用的" | 地图 |
| **知识体系** | 编码场景的指导手册——"应该怎么写、哪里容易踩坑" | 驾驶指南 |

### 9.2 核心区别

| 维度 | Codemap | 子模块知识体系 |
|------|---------|--------------|
| **描述对象** | 代码现状（客观） | 编码指导（主观+客观） |
| **内容风格** | 调用链、分层结构、字段枚举、Mermaid 流程图 | 规则约束、代码示例、坑点清单、设计模式 |
| **主要作者** | arch-agent（研究代码后产出） | arch-agent + 高级开发（踩坑后沉淀） |
| **主要消费者** | arch-agent（设计阶段参考） | dev-agent / fe-agent（编码阶段参考） |
| **使用时机** | Feature 开始前：研究现有代码 → 产出技术设计 | Feature 编码中：遇到特定场景 → 查阅避坑 |
| **更新触发** | 每次 Feature QA PASS 后由 arch-agent 更新 | 需求驱动，踩坑或发现可复用模式时沉淀 |
| **生命周期** | 持续维护，永久有效 | 逐步积累，不定期刷新 |
| **格式** | 9 节标准模板（统一结构） | 按类型不同（rules / cookbook / pattern） |
| **粒度** | 按业务域（domain-gateway、domain-hitl...） | 按场景+模块（cookbook-websocket-chat...） |

### 9.3 协作关系

```
新 Feature 开始
    ↓
arch-agent 读 Codemap → 理解现有代码结构 → 产出 02_technical_design.md
    ↓
dev-agent / fe-agent 开始编码
    ├── 读 rules/frontend_coding.md → 知道硬约束
    ├── 遇到 WebSocket 场景 → 读 cookbook-websocket-chat.md → 知道怎么写、哪里有坑
    └── 遇到双写一致性场景 → 读 pattern-dual-write.md → 知道推荐方案
    ↓
QA PASS → arch-agent 更新 Codemap + 检查是否需要沉淀新的 cookbook/pattern
```

**Codemap 回答"是什么"，知识体系回答"怎么做"。** 两者覆盖不同的开发阶段和不同的读者。

### 9.4 判断一条知识该放哪里

| 问题 | 放 Codemap | 放知识体系 |
|------|-----------|-----------|
| 它描述的是代码的位置和调用关系吗？ | 是 | 否 |
| 它描述的是编码时必须遵守的约束吗？ | 否 | 是（rules） |
| 它给出了某个场景的完整代码示例吗？ | 否 | 是（cookbook） |
| 它描述的是重复出现的设计方案吗？ | 否 | 是（pattern） |
| 换一个项目，这条知识还有用吗？ | — | 如果有用 → 考虑提升到框架 |

---

## 十、加载机制缺失（已解决）

> **状态：已解决**（v2.1.0-20260423）。本节描述的问题通过 `core/rules/knowledge-protocol.md` 统一解决。加载协议作为项目规则自动加载，所有 Agent 自动感知，无需逐个 Agent 定义中硬编码。以下内容保留作为历史分析参考。

### 10.1 现状

### 10.1 现状

| 文件类型 | 当前加载方式 | 问题 |
|---------|------------|------|
| `rules/*.md` | Claude Code 自动加载 | 正常 |
| `context/*.md` | Agent 需主动 Read，但无引导 | 没人告诉 Agent 去读哪个文件 |
| `codemap/domains/*.md` | 仅 arch-agent 定义中引用 | dev/fe/qa 完全不感知 |
| `context/knowledge-index.md` | 无任何 Agent 引用 | 索引文件存在但无人使用 |
| `context/cookbook-*.md` | 无任何 Agent 引用 | 好内容锁在抽屉里 |
| `context/pattern-*.md` | 无任何 Agent 引用 | 同上 |

**核心问题：我们创建了一堆有价值的知识文件，但没有把它们接入 Agent 的加载路径。**

### 10.2 根因分析

Claude Code 的加载机制是：
1. `rules/` 下文件自动加载（强制，无法跳过）
2. `context/` 下文件不会被自动加载，需要 Agent 主动 Read
3. Agent 只会读自己定义中明确提到的路径

当前 Agent 定义中：
- **arch-agent**：提到了 codemap（在 Research 阶段读取）
- **dev-agent / fe-agent**：只提到了 rules 和 skills，没有提到 context 下的任何知识文件
- **qa-agent**：只提到了 rules 和 skills

这意味着 dev/fe/qa 在编码和审查时，**完全不知道** cookbook、pattern、knowledge-index 的存在。

### 10.3 建议：框架层需要做的改动

**目标**：让各 Agent 在合适的时机自动感知并加载对应的知识文件。

#### 方案 A：在 Agent 定义中增加知识加载指令（推荐）

在 `dev-agent.md`、`fe-agent.md`、`qa-agent.md` 中增加统一的指令：

```markdown
## 模块知识加载（Execute 阶段）

编码前必须检查当前工作目录对应的子模块知识：
1. 检查 `<子项目>/.claude/context/knowledge-index.md` 是否存在
2. 如存在，读取索引，根据当前任务场景定位需要参考的 cookbook/pattern
3. 读取对应的 cookbook/pattern 文件作为编码参考

加载优先级：rules（硬约束） > cookbook（实操指南） > pattern（设计模式）
```

**改动点**：
- `core/agents/dev-agent.md`：增加上述指令
- `core/agents/fe-agent.md`：增加上述指令
- `core/agents/qa-agent.md`：增加审查时检查规则覆盖度的指令

**优点**：改动小，不破坏现有结构，Agent 按需加载不浪费 token。
**缺点**：依赖 Agent 自觉执行，无法强制。

#### 方案 B：通过 Skill 封装知识加载逻辑

新建一个框架级 Skill `module-knowledge`：

```markdown
# SKILL.md - module-knowledge

## 触发条件
当 Agent 进入具体子项目目录执行编码任务时自动触发。

## 行为
1. 扫描当前子项目的 `.claude/context/knowledge-index.md`
2. 根据 knowledge-index 中的「任务到知识映射」表，匹配当前任务场景
3. 加载匹配的 cookbook/pattern 文件到上下文
4. 报告：已加载 X 个知识文件，覆盖 Y 个场景

## Skill 引用
- dev-agent: 加载编码相关知识
- fe-agent: 加载前端编码相关知识
- qa-agent: 加载审查相关知识（检查规则覆盖度）
```

**优点**：封装为 Skill 后逻辑清晰，可在 Agent 定义中统一引用。
**缺点**：多一层 Skill 间接调用。

#### 方案 C：在 project_rule.md 中增加全局指令

在 `core/rules/project_rule.md` 的 §7 主会话职责中增加：

```markdown
### 7.x 模块知识加载

主会话在将任务委派给 dev-agent / fe-agent 时，应传递模块知识上下文：
- 如子模块有 `knowledge-index.md`，将索引内容作为 Agent prompt 的一部分传递
- 明确告知 Agent 需要加载哪些 cookbook/pattern
```

**优点**：主会话统一协调，可控性最强。
**缺点**：主会话职责进一步膨胀。

### 10.4 推荐方案

**推荐方案 A + 辅以 knowledge-index 的任务映射表**。理由：

1. **方案 A 最简单**：只需修改 3 个 Agent 定义文件（dev/fe/qa），各加一段指令
2. **knowledge-index 已经设计了任务映射表**：Agent 读完索引就能知道当前场景该读什么
3. **不需要新建 Skill**：避免引入新的抽象层
4. **upgrade.sh 同步**：Agent 定义文件在框架管理范围内，改框架后通过 upgrade.sh 同步到所有项目

**具体改动清单**：

| 文件 | 改动 |
|------|------|
| `core/agents/dev-agent.md` | Execute 阶段增加：读取子模块 `knowledge-index.md`，按场景加载 cookbook/pattern |
| `core/agents/fe-agent.md` | Execute 阶段增加：同上 |
| `core/agents/qa-agent.md` | Review 阶段增加：检查子模块 rules 和 cookbook 覆盖度，发现新反模式时建议沉淀 |
| `core/agents/arch-agent.md` | Research 阶段：已有 Codemap 引用，补充 dataflow 文档的引用 |
| `core/context/codemap-vs-specs.md` | 更新 Agent 加载规则表，纳入知识体系的加载指引 |

**同步机制**：以上文件均在 `core/` 下，修改后各项目执行 `upgrade.sh` 即可同步。
