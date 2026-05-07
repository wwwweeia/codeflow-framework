---
title: Demo 项目工作流演练
description: 从轻量改动到纯前端，三个真实工作流的完整运行记录
prev:
  text: v2 跨语言重构实战
  link: /cases/v2-refactor
next: false
---

> 本文记录了 Demo 项目（AI Prompt Lab）中 **Q0 / 工作流 A / 工作流 B** 三种工作流的完整运行过程。
> 每个工作流都附带真实的 Spec 产出和 QA 审查结论。
> 目标读者：第一次接触框架的团队成员，阅读后能理解"跑一个工作流到底发生了什么"。

---

## 1. Demo 项目简介

**AI Prompt Lab** 是框架自带的演示项目，用于验证框架变更。技术栈：

| 维度 | 说明 |
|------|------|
| 后端 | Python 3.10 + FastAPI + SQLAlchemy + SQLite |
| 前端 | Vue 3 + Element Plus + Pinia + `<script setup>` |
| 数据模型 | 4 个核心实体：Model、Prompt、Agent、Skill |

### 快速开始

在 demo 目录下执行以下命令即可触发对应工作流：

| 命令 | 工作流 | 场景 | 预计时间 |
|------|--------|------|---------|
| `/demo-q0` | Q0 轻量 | 添加欢迎横幅 | ~5 min |
| `/demo-workflow-a` | A 纯后端 | Agent 统计 API | ~15 min |
| `/demo-workflow-b` | B 纯前端 | Prompt 管理页面 | ~15 min |
| `/demo-workflow-c` | C 全栈 | Skill 管理 | ~25 min |

---

## 2. 三个工作流一览

| 维度 | Q0 轻量 | 工作流 A（纯后端） | 工作流 B（纯前端） |
|------|---------|-------------------|-------------------|
| **触发信号** | 单文件改动，≤3 文件 | 新建 API，不涉及前端 | 新建页面，后端 API 已存在 |
| **Agent 序列** | 无子 Agent | PM → Arch → Dev → QA | PM → Prototype → Arch → FE → QA |
| **Spec 文件** | 无（微 spec 内嵌在对话中） | 4 份 + 2 份证据 | 4 份 + 1 份证据 |
| **人工决策点** | 1 个（审批微 spec） | 2 个（审批 01、02） | 2~3 个（审批 01、原型反馈、审批 02） |
| **协议** | sdd-riper-one-light | 正式 SDD | 正式 SDD |

---

## 3. Q0 演练：添加欢迎横幅

### 需求

在首页 `Home.vue` 的统计卡片区域上方，添加一个 `el-alert` 欢迎横幅。改动仅 1 个文件。

### 为什么路由到 Q0

满足 Q0 全部判定条件：
- 改动范围可预判：1 个文件
- 不涉及新建 API 或数据库变更
- 需求明确，无需多角色协同
- 不涉及跨项目改动

### 实际过程

```
用户输入需求
    ↓
Intake 三问 → 确认是单文件改动 → 路由到 Q0
    ↓
复述理解（AI 重述需求确认理解一致）
    ↓
微 Spec（AI 生成简短的实现方案描述）
    ↓
Checkpoint（AI 列出将要执行的改动）
    ↓
用户审批 ← 你唯一需要做的事
    ↓
AI 执行修改
    ↓
验证（AI 自行检查改动是否符合微 spec）
```

### 产出

Q0 不生成独立的 Spec 文件。微 spec 内嵌在对话中，格式大致为：

> **目标**：在 Home.vue 统计卡片区上方添加 el-alert 欢迎横幅
> **改动**：修改 1 个文件 `frontend/src/views/Home.vue`
> **方案**：在模板中 `<el-row>` 前插入 `<el-alert type="success" title="..." description="..." show-icon closable />`

### 关键洞察

- 即使是最小的改动，AI 也走 **复述 → Spec → 审批 → 执行** 的流程
- 你不需要写代码，只需要说"确认"或"不对，应该是……"
- 整个过程约 5 分钟，人工介入不到 1 分钟

---

## 4. 工作流 A 演练：Agent 统计 API

### 需求

新增 `GET /api/v1/agents/stats` 统计 API，返回各状态 Agent 数量。

### 为什么路由到 A

- 涉及新建 API 端点（满足 A 信号）
- 不涉及前端页面变更（排除 C）
- 改动超过 3 个文件（排除 Q0）

### Agent 序列

```
Intake 三问 → 路由判定 → 工作流 A
    ↓
PM Agent 产出 01_requirement.md → 用户审批
    ↓
Arch Agent 产出 02_technical_design.md → 用户审批
    ↓
Dev Agent 实现 + 产出 03_impl_backend.md + 04_test_plan.md
    ↓
QA Agent 四轴审查 → PASS
    ↓
主会话验证（curl 测试）
```

### Spec 目录结构

```
demo/.claude/specs/2026-04-23_agent-stats-api/
  01_requirement.md              ← PM 产出（本例为空，见说明）
  02_technical_design.md         ← Arch 产出（90 行）
  03_impl_backend.md             ← Dev 执行日志（28 行）
  04_test_plan.md                ← 测试计划（70 行）
  evidences/
    evidence-qa-review.md        ← QA 四轴审查报告
    evidence-self-test.md        ← Dev 自测证据
```

:::tip 关于空的 01_requirement.md
本次 demo 中 PM 阶段未生成独立的需求文档。这是因为 Agent Stats API 需求非常简单明确（一个只读统计接口），需求已在 Intake 阶段充分澄清。**在实际项目中，01_requirement.md 是必需的门控文件**，即使是简单需求也应产出。
:::

### 关键节点详解

#### 4.1 Arch 阶段：技术设计

Arch Agent 自动完成 Research（读取现有代码结构）后，产出 `02_technical_design.md`：

**API Contract**：
```json
GET /api/v1/agents/stats

Response 200:
{
  "code": 0,
  "message": "success",
  "data": {
    "total": 3,
    "by_status": { "draft": 1, "active": 2, "inactive": 0 }
  }
}
```

**文件变更清单**：

| 操作 | 文件 | 说明 |
|------|------|------|
| 新建 | `backend/app/services/agent_service.py` | AgentService，含 get_stats() |
| 新建 | `backend/app/api/v1/agent_endpoints.py` | Agent 路由，含 stats 端点 |
| 修改 | `backend/app/schemas/schema.py` | 新增 AgentStatsRead |
| 修改 | `backend/app/api/v1/router.py` | 注册 agents_router |

<details>
<summary>查看 02_technical_design.md 的实现设计（Schema + Service + Endpoint）</summary>

```python
# Schema — schema.py 新增
class AgentStatsRead(BaseModel):
    total: int
    by_status: dict[str, int]

# Service — agent_service.py
class AgentService:
    def __init__(self, db: Session):
        self.db = db

    def get_stats(self) -> AgentStatsRead:
        from sqlalchemy import func
        from app.models.entity import Agent, AgentStatus

        by_status = {s.value: 0 for s in AgentStatus}
        rows = self.db.query(Agent.status, func.count()).group_by(Agent.status).all()
        for status, count in rows:
            by_status[status.value] = count
        return AgentStatsRead(total=sum(by_status.values()), by_status=by_status)

# Endpoint — agent_endpoints.py
agents_router = APIRouter()

@agents_router.get("/stats", response_model=Response[AgentStatsRead])
def get_agent_stats(db: Session = Depends(get_db)):
    service = AgentService(db)
    return Response(data=service.get_stats())
```

</details>

#### 4.2 Dev 阶段：实现

Dev Agent 严格按照 02 技术设计实现，产出 `03_impl_backend.md`：

**修改文件清单**：

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 修改 | `backend/app/schemas/schema.py` | Agent 区块新增 AgentStatsRead |
| 新建 | `backend/app/services/agent_service.py` | AgentService，含 get_stats() |
| 新建 | `backend/app/api/v1/agent_endpoints.py` | agents_router，含 GET /stats |
| 修改 | `backend/app/api/v1/router.py` | 注册 agents_router |

**遇到的问题**：无。实现与设计完全一致。

#### 4.3 QA 阶段：四轴审查

QA Agent 独立审查所有变更，执行四轴验收：

**轴 1：Spec 达成率** — 4/4 AC 全部 PASS（100%）
- AC-1 正常统计返回 ✅
- AC-2 空数据返回全 0 ✅
- AC-3 数据库异常上抛 500 ✅
- AC-4 total 与 by_status 一致性 ✅

**轴 2：技术设计符合性** — 100%
- Schema、Service、Endpoint、Router 注册与设计完全一致
- 一个微小差异：import 放在文件顶部而非方法内（更好的实践，不视为偏离）

**轴 3：代码质量与安全** — PASS
- 类型注解完整、命名规范、分层合规
- 无 SQL 拼接，无敏感信息泄露

**轴 4：反过度设计** — PASS
- 18 行 Service + 14 行 Endpoint + 3 行 Schema，极简

<details>
<summary>查看完整 QA 审查结论</summary>

> **Review Verdict: PASS**
>
> 通过理由：
> 1. Spec 达成率 100%：4 个 AC 全部满足
> 2. 技术设计完全一致：实现与 02 的每个设计项均匹配
> 3. 代码质量合格：类型注解完整、命名规范、分层合规、无安全风险
> 4. 反过度设计通过：代码简洁，无冗余抽象
> 5. 测试覆盖充分：核心场景均已覆盖
>
> 建议（非阻碍）：
> 1. 考虑为项目补充全局异常处理器，统一 500 响应格式
> 2. 当前 FastAPI 默认 500 返回 `{"detail": "Internal Server Error"}`，与正常接口的 `{code, message, data}` 格式不同

</details>

#### 4.4 验证：curl 测试

Dev Agent 自测 + 主会话验证：

```bash
$ curl -s http://127.0.0.1:8901/api/v1/agents/stats | python -m json.tool
{
    "code": 0,
    "data": {
        "total": 3,
        "by_status": {"draft": 1, "active": 2, "inactive": 0}
    },
    "message": "success"
}
```

### 人工介入统计

| 介入点 | 决策内容 | 耗时 |
|--------|---------|------|
| Intake 确认 | 确认需求三问 | ~1 min |
| 02 审批 | 通过技术设计 | ~1 min |
| **合计** | **2 个决策点** | **~2 min** |

---

## 5. 工作流 B 演练：Prompt 管理页面

### 需求

新增 Prompt 列表管理页面，支持搜索/筛选，使用 Mock 数据（后端 API 尚未实现）。

### 为什么路由到 B

- 仅涉及前端页面/组件变更（满足 B 信号）
- 后端 Prompt 端点尚未实现，PM 阶段决策使用 Mock 策略
- 不涉及后端 API 变更（排除 C）

### Agent 序列

```
Intake 三问 → 路由判定 → 工作流 B
    ↓
PM Agent 产出 01_requirement.md → 用户审批
    ↓
Prototype Agent 生成原型页面 → 用户确认
    ↓
Arch Agent 产出 02_technical_design.md → 用户审批
    ↓
FE Agent 实现 + 产出 03_impl_frontend.md + 04_test_plan.md
    ↓
QA Agent 四轴审查 → PASS
    ↓
主会话构建验证
```

### Spec 目录结构

```
demo/.claude/specs/2026-04-23_prompt-management/
  01_requirement.md              ← PM 产出（244 行）
  02_technical_design.md         ← Arch 产出（258 行）
  03_impl_frontend.md            ← FE 执行日志（87 行）
  04_test_plan.md                ← 测试计划（100 行，22 个场景）
  evidences/
    evidence-qa-review.md        ← QA 四轴审查报告
```

### 关键节点详解

#### 5.1 PM 阶段：需求规格

PM Agent 产出完整的 `01_requirement.md`（244 行），包含：

- **Part A**：业务背景与目标
- **Part B**：功能需求（页面结构、交互流程、Mock 数据策略）
- **Part C**：非功能需求
- **Part D**：验收标准（AC-1 到 AC-6）

**页面结构定义示例**：

| 序号 | 标签 | 字段名 | 组件类型 |
|------|------|--------|---------|
| 1 | 标题关键词 | `keyword` | `el-input` (clearable) |
| 2 | 标签筛选 | `tag` | `el-select` (多选, clearable) |

**验收标准示例**（AC-2）：

> **Given**：用户在 Prompt 列表页面
> **When**：用户输入"代码"并点击搜索
> **Then**：表格只展示 title 中包含"代码"的记录（不区分大小写）

<details>
<summary>查看 Mock 数据策略（PM 决策）</summary>

PM 阶段发现后端 Prompt API 尚未实现，做出以下决策：

- 前端使用 Mock 数据，Store 层预留 API 调用接口
- Mock 数据与后端 `PromptRead` Schema 字段对齐
- 后续切换后端时只需替换数据源，不需改组件代码

```javascript
// Store 接口预留
async function fetchPrompts(params) {
  // 当前：前端 Mock 筛选
  // 后续：const res = await api.get('/api/v1/prompts', { params })
}
```

</details>

#### 5.2 Arch 阶段：技术设计

Arch Agent 产出 `02_technical_design.md`（258 行），包含 B-1 到 B-7 七个设计维度：

**路由注册**：

| 路由 name | path | 加载方式 |
|----------|------|---------|
| `PromptList` | `/prompts` | 懒加载 |

**Pinia Store 设计**：

```
State:     prompts / loading / searchForm
Getters:   normalizedPrompts / allTags / filteredPrompts
Actions:   fetchPrompts() / search() / resetSearch()
```

**组件树**：

```
PromptList.vue
  ├── 搜索区
  │   ├── el-input（标题关键词）
  │   ├── el-select multiple（标签筛选）
  │   └── el-button（搜索 / 重置）
  └── 表格区
      ├── el-table-column（ID）
      ├── el-table-column（标题）
      ├── el-table-column（内容摘要，截断）
      ├── el-table-column（标签，el-tag 渲染）
      └── el-table-column（创建时间，sortable）
```

<details>
<summary>查看技术风险 C-1：框架规范与项目技术栈的差异</summary>

> `frontend-conventions` Skill 定义的是 Nuxt 2 + Vue 2 + Options API 的规范，而本项目技术栈为 Vue 3 + Composition API + `<script setup>`。
>
> **处理**：项目级 `frontend/.claude/rules/frontend_coding.md` 已明确覆盖框架级规范：
> - 使用 Composition API + `<script setup>`，禁止 Options API
> - 使用 Pinia Composition API 风格，不使用 Vuex
> - 使用 Element Plus（非 Element UI）
> - 无 `vul-table` 封装组件，使用 Element Plus 原生 `el-table`

这是一个很好的示例：当框架级 Skill 与项目技术栈冲突时，项目级规则优先，Arch 需在 Part C 中说明差异。

</details>

#### 5.3 FE 阶段：实现

FE Agent 产出 `03_impl_frontend.md`（87 行），包含 4 个文件变更：

| 文件 | 操作 | 说明 |
|------|------|------|
| `stores/prompt.js` | 新增 | Pinia Store（Mock 数据 + State/Getter/Action） |
| `views/PromptList.vue` | 新增 | 搜索区 + 表格 + 底部信息栏 |
| `router/index.js` | 修改 | 追加 /prompts 路由 |
| `App.vue` | 修改 | 导航菜单添加入口 |

**关键决策 B-1**：Store 搜索表单与组件搜索表单的双向同步

> 组件维护自己的 reactive 搜索表单（用于 el-form :model 绑定），搜索时通过 `promptStore.search()` 同步到 Store；重置时先清空本地表单，再调用 `promptStore.resetSearch()`。Store 的 searchForm 仅用于驱动 getter 计算，不直接与 DOM 绑定。

#### 5.4 QA 阶段：四轴审查

**轴 1：Spec 达成率** — AC-1 到 AC-6 共 14 个子项，全部 PASS

**轴 2：代码一致性** — 02 B-1 到 B-7 逐项比对，无偏差

**轴 3：代码质量** — 项目级 + 框架级编码规则全部合规，无 XSS 风险

**轴 4：反过度设计** — 一个组件 + 一个 Store，无过度封装

<details>
<summary>查看 QA 审查自检清单</summary>

```
[QA 自检]
AC 逐项核对：PASS（14 个子项全部比对）
Schema 比对：PASS（02 B-1 到 B-7 逐项比对）
测试抽查：PASS（抽查 3 个测试行均有效）
反过度设计：PASS（Store 有实际业务逻辑）
独立性：PASS（审查结论基于代码阅读，未受 FE 自测影响）
```

**建议（非阻碍）**：
1. `01_requirement.md` 和 `02_technical_design.md` 需从 stash 恢复并提交
2. 可追加"Mock 加载失败降级"和"浏览器前进/后退"两个低风险测试场景

</details>

#### 5.5 构建验证

```bash
$ cd frontend && npm run build
vite v6.4.2 building for production...
✓ 1662 modules transformed.
✓ built in 2.51s
```

### 人工介入统计

| 介入点 | 决策内容 | 耗时 |
|--------|---------|------|
| Intake 确认 | 确认需求，决策使用 Mock 策略 | ~1 min |
| 01 审批 | 通过需求文档 | ~1 min |
| 原型确认 | 确认原型页面效果 | ~2 min |
| 02 审批 | 通过技术设计 | ~1 min |
| **合计** | **4 个决策点** | **~5 min** |

---

## 6. Spec 文件解剖

每个正式工作流（A/B/C）都会在 `.claude/specs/` 下生成一组标准文件：

```
.claude/specs/YYYY-MM-DD_<name>/
  01_requirement.md              ← PM：需求规格
  02_technical_design.md         ← Arch：技术设计
  03_impl_backend.md 或 03_impl_frontend.md   ← Dev/FE：执行日志
  04_test_plan.md                ← Dev/FE：测试计划
  evidences/
    evidence-qa-review.md        ← QA：审查报告
    evidence-self-test.md        ← Dev/FE：自测证据
```

### 各文件定位

| 文件 | 谁写 | 写什么 | 需要你审批？ |
|------|------|--------|------------|
| `01_requirement.md` | PM Agent | 业务需求、页面结构（字段级）、交互流程、验收标准 | **是（门控点）** |
| `02_technical_design.md` | Arch Agent | API 契约、数据库 Schema、组件树、技术风险 | **是（门控点）** |
| `03_impl_*.md` | Dev/FE Agent | 修改文件清单、关键决策、遇到的问题 | 否（供 QA 参考） |
| `04_test_plan.md` | Dev/FE Agent | 测试矩阵（追溯 AC）+ curl/人工验证步骤 | 否（QA 审计） |
| `evidence-qa-review.md` | QA Agent | 四轴审查结论、AC 逐项核对、代码质量检查 | 否（最终结论） |
| `evidence-self-test.md` | Dev/FE Agent | 模块导入验证、Service/API 测试结果 | 否（供 QA 抽查） |

### Spec 链：追溯关系

```
Intake 三问
    ↓ 澄清
01_requirement.md（AC-1~AC-N）
    ↓ 驱动
02_technical_design.md（API Contract、组件树、风险）
    ↓ 指导
代码实现（03 记录过程）
    ↓ 对照
04_test_plan.md（每个 AC 都有对应测试场景）
    ↓ 审计
evidence-qa-review.md（逐项核对 01 AC + 02 设计 + 代码质量）
```

所有代码都能追溯到 Spec，Spec 追溯到 Intake 三问。这就是 **Spec-Driven Development**。

---

## 7. 准备清单：开始前你需要什么

### 7.1 项目基础设施

| 项目 | 要求 | 如何检查 |
|------|------|---------|
| Claude Code | 已安装并登录 | `claude --version` |
| 项目 CLAUDE.md | 已填写项目基本信息 | 项目根目录存在 `CLAUDE.md` |
| `.claude/` 目录 | 框架文件已同步 | 执行 `bash ../h-codeflow-framework/tools/upgrade.sh` |
| 编码规则 | `coding_backend.md` / `coding_frontend_shared.md` 已存在 | 检查 `.claude/rules/` |
| 前置知识 | 领域词典（domain-ontology）已填充 | 检查 `.claude/skills/domain-ontology/SKILL.md` |

### 7.2 你的前置知识

你**不需要**会写代码，但需要理解：

| 知识点 | 为什么需要 | 在哪了解 |
|--------|----------|---------|
| 业务需求 | Intake 三问需要你澄清目标/边界/验收 | 自己最清楚 |
| 路由判定 | 知道你的需求走哪个工作流 | [工作流体系](/design/workflow) |
| Spec 审批 | 01 和 02 需要你判断"方向对不对" | 本文 + [概念详解](/getting-started/concepts) |
| 技术栈差异 | 不同项目可能用不同框架（Vue 2 vs Vue 3） | 项目级 `coding_frontend_shared.md` |

### 7.3 每个环节你做什么

```
Intake（你发起）
  → 说清楚"要做什么、不做什么、怎么算完成"
  → 确认 AI 的路由判断

01 审批（你审批）
  → 看 PM 产出的需求文档：需求理解对不对？边界对不对？AC 够不够？
  → 不需要看代码，看业务描述就行
  → 说"通过"或"第 X 节需要调整"

原型反馈（工作流 B/C，你操作浏览器）
  → 启动前端 dev server，在浏览器看原型
  → 告诉 AI"列名不对""少了个搜索条件"等

02 审批（你审批）
  → 看 Arch 产出的技术设计：API 路径对不对？文件结构合理吗？
  → 不需要完全理解技术细节，关注"是不是在解决我的需求"

QA 审查（自动，你看结果）
  → QA 报告中的 PASS/FAIL 结论
  → 如果 FAIL，看修复建议，确认修复方案

合并授权（你确认）
  → 确认可以合并到 develop
  → 说"合并"即可
```

---

## 8. 数据统计

### 工作流 A：Agent Stats API

| 类别 | 数量 |
|------|------|
| Spec 文件 | 4 份（01 空 + 02 + 03 + 04） |
| 证据文件 | 2 份 |
| 代码文件变更 | 4 个（2 新建 + 2 修改） |
| 人工决策点 | 2 个 |
| QA 结论 | PASS（4/4 AC） |

### 工作流 B：Prompt 管理页面

| 类别 | 数量 |
|------|------|
| Spec 文件 | 4 份（01 + 02 + 03 + 04） |
| 证据文件 | 1 份 |
| 代码文件变更 | 4 个（2 新建 + 2 修改） |
| 测试场景 | 22 个 |
| 人工决策点 | 4 个 |
| QA 结论 | PASS（14/14 AC 子项） |

### 三个工作流对比

| 指标 | Q0 | A | B |
|------|----|---|---|
| AI 自主完成 | ~90% | ~95% | ~95% |
| 人工时间 | <1 min | ~2 min | ~5 min |
| Spec 文件 | 0 | 6 | 5 |
| 门控审批 | 1 | 2 | 2~3 |

---

## 9. 给新成员的建议

1. **先跑 Demo 再上项目**：用 `bash reset-demo.sh --base` 重置 demo，按本文的步骤走一遍
2. **审批是核心**：01 和 02 的审批是你控制方向的唯一机会——认真看，但不纠结于技术细节
3. **Spec 是真相源**：所有代码实现都追溯到 Spec，如果 Spec 错了，代码一定错
4. **QA 比你细心**：让 AI 审查 AI 的代码，它会逐项核对每个 AC、每个字段映射
5. **原型很值得**：工作流 B/C 有原型环节，花 2 分钟反馈原型比花 2 小时返工代码划算

### 如果你想自己试一次

1. `cd demo && bash reset-demo.sh --base`（重置到初始状态）
2. 启动 Claude Code，输入 `/demo-workflow-a`
3. 跟着 Intake 三问走，审批 02 技术设计
4. 看 Dev 自动实现，看 QA 自动审查
5. 对照本文理解每个环节

想了解更复杂的工作流 C（前后端联动），参见 [工作流 C 完整旅程](/cases/workflow-c-preset-questions)。
