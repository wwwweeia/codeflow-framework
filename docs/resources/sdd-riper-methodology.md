---
title: 阿里云 SDD-RIPER 方法论
description: AI 原生研发范式：从代码中心到文档驱动的演进
prev: false
next:
  text: GitHub spec-kit 全景解读
  link: /resources/github-spec-kit
---

> 来源：阿里云「无岳」系列文章（2026年2-4月）
> - 01｜从传统编程转向大模型编程
> - 02｜AI 原生研发范式：从"代码中心"到"文档驱动"的演进
> - 03｜SDD-RIPER 团队落地指南：如何让整个团队在一周内跑通大模型编程

---

## 一、核心范式：SDD（Spec-Driven Development）

### 1.1 核心理念

```
Code is Cheap, Context is Expensive
代码是廉价的消耗品，文档（Spec）才是昂贵的核心资产。
```

**三条铁律：**

| 规则 | 含义 |
|------|------|
| **No Spec, No Code** | 没有文档，不准写代码 |
| **Spec is Truth** | 文档和代码冲突时，错的一定是代码 |
| **Reverse Sync** | 发现 Bug，先修文档，再修代码 |

**核心转变：**
- 以前：人写代码 → 文档是"解释说明"（经常过期）
- 以后：人定义意图 → AI 把文档"编译"成代码
- 程序员角色：从"砌砖工匠" → "画图纸的建筑师"
- 核心产出：从 `FunctionImpl` → `RequirementSpec` + `ArchitectureDesign`

### 1.2 为什么需要 SDD —— 四大工程痛点

| 痛点 | 现象 | 根因 |
|------|------|------|
| **上下文腐烂** | 对话越长，AI 遗忘前文约束，悄悄破坏已有逻辑 | 模型架构固有局限 |
| **审查瘫痪** | AI 秒生成 500 行代码，人根本 Review 不过来 | 产出速度远超审查速度 |
| **维护断层** | 全是 AI 生成的陌生代码，两周后不敢动，改一行崩三处 | 没有"为什么这么写"的记录 |
| **代码不信任** | 不知道 AI 为什么这么写，不敢上线、不敢重构 | 信任缺失 |

### 1.3 SDD 解决了什么问题

| 受益者 | SDD 解决的问题 | 没有 SDD 的代价 |
|--------|----------------|----------------|
| 开发者自己 | 半年没碰的项目，读 Spec 20 分钟就能重新进入状态 | 花 2 天重新翻代码、猜逻辑、踩旧坑 |
| 接手的同事 | 交接 = 读 Spec + 按图施工，接入周期从周级降到天级 | 口头交接、看代码猜意图，接手周期长、风险高 |
| TL / 主管 | 打开 Spec 就知道"需求做到哪了、决策了什么、还有什么风险" | 进度靠口头汇报，风险靠事后暴露，管理全凭感觉 |
| 团队工程人员 | 每次修改都有决策留痕、有 Plan 审批、有 Review 闭环，质量可追溯 | 改了什么、为什么改、谁批准的——全靠 git log 里一行 commit message |
| 组织知识资产 | 人员轮换、项目交割时，知识不随人走，沉淀在 Spec 里 | 核心研发一离职，项目变成黑盒，没人敢动 |

### 1.4 Spec 的双重角色（澄清优先级）

> ⚠️ **常见误解：Spec 是用来喂给大模型的上下文**
>
> ✅ **真相：Spec 首先是给人的，不是给大模型的**
>
> Spec 的核心价值是解决**人的问题和工程的问题**，对大模型的优化只是附赠品。

- **第一任务**：给**人**看的持久化任务上下文（组织记忆，不是模型指令）
- **第二任务**：给**模型**的按需注意力聚焦器（只在关键节点让模型回读相关段落）

---

## 二、文档体系：端到端闭环结构

### 2.1 推荐目录结构

```
mydocs/
├── apis/                          # 接口契约层：API 定义文档
├── codemap/                       # 代码拓扑层：功能级/项目级代码地图（长期资产）
├── context/                       # 原始语料层：PRD、设计图、讨论记录（一次性）
└── specs/                         # 核心协议层：SDD Spec 文档（核心资产）
    └── feature-xxx/
        ├── 00_context.md           # 可选：一次性上下文（业务背景/现状快照）
        ├── 01_requirement.md       # 需求意图（PM/业务/Owner）
        ├── 02_interface.md         # 接口契约（前后端/客户端共同协议）
        ├── 03_implementation.md    # 实施细节（AI Coder 执行指令）
        └── 04_test_spec.md         # 测试策略与用例（QA/Test Agent）
decisions/
├── AI_CHANGELOG.md               # 决策与变更日志（审计/追溯）
└── ADR-xxxx.md                    # 可选：重大架构决策记录
skills/
└── SKILL.md                       # 团队规则库/"家规"（防复发）
logs/
└── ai-review-reports/            # 可选：每次 Review 报告归档
```

**三档资产性质：**

| 目录 | 性质 | 说明 |
|------|------|------|
| `codemap/` | **长期资产** | 每次需求迭代时更新，团队所有人复用 |
| `context/` | **一次性语料** | 按需求整理，用完即归档 |
| `specs/` | **核心资产** | 每个需求一份，是代码的"源码" |

### 2.2 四类核心文档模板

#### A. 01_requirement.md（需求规格）——意图层

```markdown
## Background
[为什么要做，1段即可]

## In/Out
- In：[做哪些]
- Out：[不做哪些]

## Acceptance Criteria (AC)
- AC1：[可验证的条目]
- AC2：...

## Constraints
[性能/安全/兼容/依赖系统/灰度要求]

## Risks & Rollout
[上线策略、回滚预案]
```

**门禁：** AC 至少覆盖主流程 + 重复请求/幂等 + 至少 2 个失败场景

#### B. 02_interface.md（接口契约）——协议层

```markdown
## API: POST /api/v1/points/check-in
Auth: Bearer Token
Idempotency: 同一 userId + 同一 date 必须幂等

### Request
- date (string, optional): YYYY-MM-DD，不传则默认当天

### Response (Success)
- checkedIn (boolean)
- checkedInAt (string, ISO8601, nullable)
- pointsEarned (int)

### Error Codes
- INVALID_DATE：date 格式非法
- UNAUTHORIZED：未登录/Token无效

### Examples
Success(first time): { ... }
Success(already checked-in): { ... }
```

**门禁：** 必须有成功 + 已签到（幂等） + 至少 1 个失败示例

#### C. 03_implementation.md（实施细节）——执行层

```markdown
## File Changes
- backend/src/.../CheckInController.java
- backend/src/.../PointsService.java

## Core Logic (pseudo)
1) parse date(default today) -> validate format
2) start tx
3) try insert checkin_record with unique(user_id, date)
   - if conflict -> return already checked-in
4) if inserted -> add points(+5) and write ledger/audit
5) commit

## Execution Plan
- Step 1: 增加 checkin_record 唯一约束
- Step 2: 实现 PointsService.checkIn() 幂等逻辑
- Step 3: Controller 层对齐接口契约
- Step 4: 补单元测试
```

**门禁：** 明确文件路径 + 方法签名/职责边界；核心流程覆盖幂等/并发/事务/异常映射

#### D. 04_test_spec.md（测试策略）——验证层

```markdown
## Strategy
- Service 层：单测覆盖幂等与错误码
- Controller 层：契约测试校验 JSON 字段

## Test Cases
- TC1 首日签到：返回 checkedIn=true, pointsEarned=5
- TC2 重复签到：pointsEarned=0，总积分不变
- TC3 非法 date：返回 INVALID_DATE
- TC4 并发重复请求：验证唯一约束/幂等
```

**门禁：** 用例必须覆盖 AC 关键路径 + Error Codes + 并发/幂等

### 2.3 CodeMap（代码地图）

**什么时候用：** 当你要改一个不熟悉的模块、接手一个老项目、或者需要梳理复杂链路时。

```markdown
# Code Map: 权限校验模块
## Scope
权限校验的完整链路，从请求入口到最终鉴权判定。

## Entry Points
- `PermissionFilter.java:L28` — HTTP 请求拦截入口
- `RpcPermissionInterceptor.java:L15` — RPC 调用拦截入口

## Core Logic Chain
1. `PermissionFilter.doFilter()` → `AuthService.checkAccess()`
2. `AuthService.checkAccess()` → `PermissionDAO.queryUserPermission()`

## Dependencies
- 数据库：`t_user_permission` 表
- RPC：`UserCenterService.getUserRole()`
- 缓存：Redis key `perm:{userId}:{resourceId}`

## Risks / Unknowns
- RpcPermissionInterceptor 的调用方不明确，可能已废弃
- LegacyAuthAdapter 的兼容逻辑是否还需要保留？
```

**注意：** CodeMap 不是全项目总图，而是聚焦于本次任务相关的功能链路。

---

## 三、核心流程：RIPER 状态机

### 3.1 整体概览

```
┌──────────────────────────────────────────────────────────────┐
│  Pre-Research  →  Research  →  Innovate  →  Plan            │
│   (准备输入)      (调研事实)    (方案对比)     (原子规划)       │
│                                                              │
│  Execute  →  Review  →  Archive                             │
│   (按图施工)    (验收闭环)    (知识沉淀)                        │
└──────────────────────────────────────────────────────────────┘
         Plan Approved = 分水岭
         之前 = 讨论 | 之后 = 指令
```

### 3.2 Pre-Research（准备输入）

**三个可选命令：**

| 命令 | 作用 | 是否必须 |
|------|------|----------|
| `create_codemap` | 让 AI 扫描代码库，生成功能级代码地图 | 中大型任务强烈建议 |
| `build_context_bundle` | 把需求文档、设计图、讨论记录整理成结构化上下文包 | 需求复杂时建议 |
| `sdd_bootstrap` | 收口所有输入，启动 RIPER 流程，产出首版 Spec | 建议必须 |

**sdd_bootstrap 用法：**
```
sdd_bootstrap:
- task=<任务名>
- goal=<你要达成的目标>
- requirement=<需求文档路径或简要描述>
- codemap_ref=<代码地图路径>
- context_ref=<上下文包路径>
```

### 3.3 各阶段详解

#### Step 1：Research（调研与事实锁定）

```
做什么：让 AI 查清代码现状，锁定事实，消除信息差。
核心原则：
- 每个结论必须有代码出处（文件路径、函数名、行号）
- 不接受"我认为"、"通常来说"——只接受"我在XXX.java:L42看到了YYY"
- 让 AI 主动提问，把不确定的点暴露出来
```

**完成标准：**
- [ ] 入口、链路、依赖、风险全部锁定
- [ ] 每个结论有代码出处
- [ ] 不确定项已在 Spec 中显式标注
- [ ] AI 的疑问已全部回答或标记为 [待确认]

#### Step 2：Innovate（方案设计与对比）

```
做什么：逼 AI 给出 2-3 个方案，对比 Pros/Cons，人类拍板选哪个。
核心原则：
- 禁止只给一个方案——一个方案 = 没有选择 = 局部最优陷阱
- 每个方案必须说清：改哪些文件、影响范围、风险点、工作量估算
- 人类做决策，AI 做分析
```

#### Step 3：Plan（原子级规划）

```
做什么：把选定的方案拆解为原子级的实施清单，精确到文件路径和函数签名。
这是整个流程的决胜点。Plan 看不懂 = 不准动手。
```

**Plan 必须包含：**
- 每一步精确到文件路径 + 方法签名
- 明确的执行顺序（依赖关系）
- 每一步的验证方式

**审批检查清单：**
- [ ] 每一步我都看得懂吗？
- [ ] 文件路径和函数签名是否正确？
- [ ] 执行顺序是否合理？
- [ ] 有没有遗漏的文件或步骤？
- [ ] 风险点是否已标注？

**人类回复：`Plan Approved`**（这是讨论和命令的分水岭）

#### Step 4：Execute（按图施工）

```
做什么：AI 严格按照 Plan 逐步执行，生成代码。人类只需监督。
核心原则：
- AI 只能按 Plan 执行，不允许自由发挥
- 如果执行中发现 Plan 有问题，必须停下来，回到 Plan 阶段修正
- 关闭 YOLO / 全自动模式：绝对禁止 AI "先斩后奏"
```

#### Step 5：Review（验收闭环）

```
做什么：对照 Spec 验收代码，确保"文档说的 = 代码做的"。
核心原则：
- 三角定位：Spec（预期） vs 代码（实现） vs 执行日志（过程），三方交叉验证
- 发现偏差：先修 Spec，再修代码（Reverse Sync）
```

**三轴审查：**
- 轴一：Spec 达成率（预期行为是否都已实现）
- 轴二：代码一致性 Diff（代码是否忠实于 Spec）
- 轴三：代码质量与弱点（潜在风险）

#### Step 6：Archive（知识沉淀）

```
做什么：项目收尾时把中间产出的各种 Spec 进行精简合并，沉淀为团队的长期复用资产。
```

**archive 命令自动产出两份资产：**
- **Human 视角版** (`_human.md`)：精炼的方案与汇报，供人阅读维护
- **LLM 视角版** (`_llm.md`)：浓缩的项目背景、数据结构，仅为机器设计的输入切片（组织提效不折旧的核心）

### 3.4 三个常见协作模式

#### 模式一：一个主项目 + 若干轻项目

- 默认以主项目作为 workdir
- 通过 ProjectMap 只暴露与当前任务相关的轻项目信息（哪个轻项目有关、相关目录、接口配置）
- 大模型不是"接管整个轻项目"，而是像伸出触手一样，只触达与当前任务直接相关的局部代码

#### 模式二：两个主项目并线协作

- 把父目录作为 workdir
- 在父目录维护统一的跨项目协作文档（联动任务总 Spec、职责边界、核心接口与数据流）
- 每个主项目内部保留自己的 CodeMap

#### 模式三：多个项目组成的复杂工程

- 引入强化版 ProjectMap 作为整个工程的一级导航层
- ProjectMap 至少要回答四个问题：
  1. 这次任务究竟涉及哪些项目？
  2. 这些项目之间如何调用、依赖和传递数据？
  3. 每个项目应该先看哪条链路、哪几个模块？
  4. 哪些项目只是背景信息，哪些项目必须实际修改？

**推荐固定工作顺序：** ProjectMap → 锁定涉及项目 → 进入各项项目 CodeMap → 按需阅读具体代码

---

## 四、Skill 配置（通过 Claude Code 实现）

### 4.1 两个 Skill 版本

| Skill | 适用场景 | 推荐模型 | 规模 |
|-------|---------|---------|------|
| `sdd-riper-one` | 主力协议，完整闭环（强烈推荐新手起步） | Claude 4.5 / GPT-5.3 / codex | ~3,000-3,500 tokens |
| `sdd-riper-one-light` | 适用于强模型和更熟练的大模型驾驶员 | Claude 4.6 opus / GPT-5.4 | ~800-1,000 tokens |

**团队建议：** 新团队一律先用标准版建立规范；等团队成员对 RIPER 各个阶段烂熟于心后，日常敏捷迭代再切换到 Light 版本。

### 4.2 自用 agents.md 示例

```markdown
# 工作指南
- 使用中文交流。
- 永远不要执行 `git clean`（任何参数，尤其是 `-fdx`）。
- `No Spec, No Code`
- `No Approval, No Execute`
- `Spec is Truth`

## Skill 使用约定
- 默认使用 `sdd-riper-one`
- 仅当任务明显简单、边界清晰、改动很小、无需完整阶段流转时，使用 `sdd-riper-one-light`
- 极简单、无需 spec / checkpoint / 分阶段控制的任务，可以不使用 skill

## 执行规则
- 代码修改前先提交方案并等待我确认；文档修改可直接执行。
- 等待确认期间，先将方案收敛到最小改动集，不要无限扩展搜索范围。
- 修改文件时，不要一次性重写整个文件；优先小步、分段、少量多次修改。
- 除非我明确要求，否则不要做大范围重构、整文件替换或超大 patch。
- 多文件改动时，先完成最核心链路的最小可用修改，再逐步补齐。

## 命令边界
- 除非我明确要求，否则不要主动运行编译、打包、测试、部署、迁移或其他高开销命令。
- 除非我明确要求，否则不要主动安装依赖、升级依赖、删除依赖或修改锁文件。
- 对可能造成不可逆后果的命令，先等待我确认。

## Git 边界
- 默认严格尊重 `.gitignore` 与所有已忽略路径。
- 不要主动使用 `git add -f` / `git add --force`。

## Spec 同步
- 当改动影响需求、接口、行为、约束、流程或实现决策时，执行后同步更新 spec。
- 纯机械性改动可不更新 spec。
```

---

## 五、最小执行指南（通过 Claude Code 实现）

### 5.1 第一步：安装 Skill（1 分钟）

```
1. 打开 Skill 安装页面
2. 安装 sdd-riper-one（标准版）
3. 安装 sdd-riper-one-light（轻量版）
4. 可选：安装额外 Prompt 效率工具箱扩充
```

### 5.2 第二步：首个需求跑通（4 分钟）

**大型系统/标准落地（基于 sdd-riper-one）：**
```
在对话中输入：
请启用 $sdd-riper-one，并执行 sdd_bootstrap：
- task=<你的任务名>
- goal=<你要达成的目标>
- requirement=<需求文档路径或简要描述>

（如果需求横跨多个代码库可以追加：
- mode=multi_project 启用跨库智能依赖发现）
```

AI 会自动按照 RIPER 流程引导你：Research → Innovate → Plan → Execute → Review

**日常业务小需求（基于 sdd-riper-one-light）：**
```
请启用 $sdd-riper-one-light，我有个小任务：[简要描述目标]
```

AI 会生成极简的 micro-spec + 简短的操作计划。

### 5.3 第三步：团队约定（必须）

**在团队内达成一个共识：**
> **未经 Plan Approved，不得改代码。**

这一条规则就够了。它确保所有人都在 RIPER 流程内工作，而不是"想到哪写到哪"。

---

## 六、Debug 协议：LAFR

当生产环境报错或测试不通过时，严格执行 LAFR 流程：

```
L - Locate（定位）：
  构建"案发现场"。投喂黄金三角：Spec 文档 + 相关代码 + 报错日志。

A - Analyze（分析）：
  让 AI 判决，是"执行层错误"（代码写错了）还是"设计层错误"（文档没写对）。

F - Fix（修复）：
  如果是代码错 -> 生成补丁。
  如果是文档错 -> 必须先改文档，再重新生成代码。
  （避免暗箱修改：先改文档，再改代码）

R - Record（留痕）：
  更新 SKILL.md，防止下次复发。
  在文档上打补丁："⚠ [FIX] 此处逻辑曾导致死锁，已修正为..."
```

---

## 七、团队一周落地 SOP

### Day 1-2：选一个老需求试点

1. 核心研发花 1-2 小时，对老项目执行 `create_codemap`，产出 Code Map
2. 把需求描述整理成简单的文档（目标 / 范围 / 约束 / 验收标准）
3. 让一位低经验同学用 SDD-RIPER 流程完成这个需求
4. 核心研发只做两件事：**审 Plan + 最终 Review**

### Day 3-4：复盘与调整

**复盘清单：**
- [ ] 需求是否按预期完成？
- [ ] Plan 审查是否有效拦住了问题？
- [ ] 低经验同学的体感如何？卡在哪里了？
- [ ] Spec 文档是否完整、可复用？
- [ ] 与传统方式相比，周期和质量有什么变化？

**常见调整：**
- 如果 Plan 太粗：要求 AI 拆解到文件路径和函数签名级别
- 如果 Research 不够深：补充 Code Map 或 Context Bundle
- 如果同学不习惯：让他先看一遍招式篇的实战案例

### Day 5-7：扩大范围

1. 第二个需求：换一个人来做，验证流程的可复制性
2. 并行交付：核心研发写 Spec + 审 Plan，多个低经验同学同时按图施工
3. 沉淀模板：把试点中产出的 Spec 作为团队模板，后续需求直接参考

---

## 八、效果数据

| 类别 | 指标 | 变化 |
|------|------|------|
| **质量提升** | 主语言（Java）Bug 率 | **-18%** |
| **质量提升** | 非主语言（Go/Python/Node.js）Bug 率 | **-37%** |
| **效率飞跃** | 日常需求周期 | 1-2周 → **3-4天** |
| **效率飞跃** | 大型需求周期 | 2个月 → **1个月** |
| **效率飞跃** | 大客户交付人力 | 节省 **40%** |
| **效率飞跃** | 团队整体效率 | **+55%** |

| 重度实战验证 | 数据 |
|-------------|------|
| 30 天 Token 使用量 | 10.8 亿 |
| 并行窗口数 | 4 窗口 |
| 核心人员角色 | 只做阶段性 Review |
| 缓存利用率 | **447x** |

---

## 九、AI 协作三大坑与正确姿势

### 坑一：讨论和命令混为一谈

| 意图类型 | 你在做什么 | AI 应该做什么 | RIPER 对应 |
|---------|-----------|--------------|-----------|
| "我还不确定要什么" | 提供选项、提问、挑战假设 | 分析、提问、暴露风险 | Research |
| "帮我分析利弊" | 给出对比、推荐、风险提示 | 对比分析、推荐方案 | Innovate |
| "就按这个干" | 忠实执行，不自由发挥 | 严格按 Plan 施工作 | Execute |
| "帮我检查" | 对照标准逐条验证 | 验收结论、偏差记录 | Review |

**Plan Approved = 讨论和命令的分水岭。** 在它之前，你和 AI 是在讨论；在它之后，你在下命令。

### 坑二：每个阶段该要什么产出搞混了

| 阶段 | 该要的产出 | 不该要的产出 |
|------|-----------|------------|
| Research | 事实、发现、风险、代码出处 | ❌ 代码、方案 |
| Innovate | 方案对比、Pros/Cons、推荐 | ❌ 代码、实施细节 |
| Plan | 文件路径、函数签名、执行顺序 | ❌ 代码实现 |
| Execute | 可运行的代码 | ❌ 方案讨论、架构建议 |
| Review | 验收结论、偏差记录 | ❌ 新功能、优化建议 |

### 坑三：自由度给错了

| 阶段 | 自由度 | 为什么 |
|------|-------|--------|
| Research | 中 | 让 AI 自由探索代码库，但必须给出证据 |
| Innovate | **高** | 唯一鼓励 AI 自由想象的阶段 |
| Plan | 低 | 必须精确到文件路径和函数签名，压缩创造力 |
| Execute | **零** | 严格按 Plan 施工，发现问题必须停下来报告 |
| Review | 中 | 让 AI 自由检查，但结论必须有依据 |

**记住：** 在需要 AI **创造力**的时候放开（Innovate），在需要 AI **执行力**的时候收紧（Execute）。

---

## 十、安全与合规

### 10.1 数据安全分级

| 等级 | 示例 | 策略 |
|------|------|------|
| **C3**（高敏感） | 支付核心、用户隐私数据 | 严禁把敏感信息喂给外部大模型。使用私有化部署模型生成脱敏 Spec |
| **C1/C2**（通用） | 前端 UI、工具类、单元测试 | 大胆使用最先进的外部模型（GPT-5.2/Claude 4.5） |

### 10.2 双模协作模式（C3 场景）

```
1. 内部模型（如 Qwen3）：读代码、生成 Code Map、产出脱敏 Spec
2. 外部模型（如 Claude 4.5）：基于脱敏 Spec 做架构设计和方案对比
3. 代码始终不出内网，Spec 作为中间层隔离敏感信息
```

### 10.3 C3 场景最小 Checklist

- [ ] 确认当前用的是内部/合规模型，而不是公网接口
- [ ] 避免把以下内容发往外部：完整关键业务实现、明文密钥、账号密码、个人信息
- [ ] 若确需借助外部模型，是否先通过内部模型或手工做了脱敏/抽象？
- [ ] 外部模型生成的代码，是否经过了内部 Review 和测试再合入？

---

## 十一、常见陷阱与策略

| 陷阱 ❌ | 正确做法 ✅ |
|--------|------------|
| 持续保持在同一个对话上太久 | 使用 compact 指令；解决完问题后使用 clear 指令清理上下文 |
| "帮我优化这个函数"（结果 AI 重构了整个类） | "只优化函数 calculateTotal，不做任何其他变更，集中于此函数一点" |
| 直接使用 AI 提到的 StringUtils.sanitize() 方法 | 先用 IDE 搜索确认项目里是否真有这个方法 |
| 只看 AI 的文字解释："我已经修复了空指针问题" | 每次都让大模型执行并运行相关测试验证 |
| 一次要求太多 | 拆成多个小任务，每次只做一个功能模块 |
| 因为一次特殊情况骂了 AI，导致 SOP 里写死了极端规则 | 定期 Review 你的 Prompt/SOP 文件，像重构代码一样重构 Prompt |

---

## 十二、核心金句

> 1. **Code is Cheap, Context is Expensive.** 代码是廉价的消耗品，文档才是昂贵的核心资产。
> 2. **Spec 是 AI 智能体之间的"通信协议"**——以后不再是你和我沟通，而是你的大模型和我的大模型进行沟通，人类只需要做 Review 和信息确认。
> 3. **Spec 首先是给人的，其次才是给大模型的。** 它解决的是团队协作、工程质量、知识传承的问题。
> 4. **SDD 不是"多做了准备工作"，而是用输入 Token 换输出 Token。** 花 1 块钱的输入，省 10 块钱的输出，效果还更好。
> 5. **在需要 AI 创造力的时候放开（Innovate），在需要 AI 执行力的时候收紧（Execute）。**
> 6. **复杂项目不是让模型读更多代码，而是让模型先找到正确索引，再按需进入正确局部。**
> 7. **Plan Approved = 分水岭。** 之前是讨论，之后是命令。
> 8. **AI 是你的笔，字写错了是人的问题。** 谁 Sign-off 文档，谁 Sign-off 代码，谁就对 Bug 负责。
> 9. **Vibe Coding 提倡"If fixing takes too long, regenerate"。但如果没有 Spec，你每次 Regenerate 都是碰运气。** SDD 是 Vibe Coding 的"安全带"。
> 10. **错误即规则（Error to Rule）：** 出现 Bug → 修 Skill → 让 AI 重新生成代码。
