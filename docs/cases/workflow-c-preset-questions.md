---
title: 实战案例：工作流 C 完整旅程
description: 一个 Feature 从需求到上线的完整开发过程，采用 SDD 工作流 C（前后端联动）
prev: false
next:
  text: v2 跨语言重构实战
  link: /cases/v2-refactor
---

> 本文档记录了"预设问题管理"功能的完整开发过程。
> 全流程在一个 Claude Code 会话中完成，采用 SDD 工作流 C（前后端联动）。
> 目标读者：新接入 AI Coding 的团队成员，阅读后能理解"AI 协作开发到底是怎么运转的"。

---

## 1. 概述

**需求**：为 `ai_preset_questions` 表新增一套 CRUD 管理功能（后端 4 个 API + 前端管理页面）

**起点**：用户说"我想测试一个完整的工作流C，我也没有明确的需求"

**终点**：代码合并到 develop，Docker 镜像推送到 Harbor，Watchtower 自动部署到服务器

**最终交付物**：
- 后端：7 个 Java 文件（353 行），4 个 REST API
- 前端：4 个 Vue/JS 文件（615 行），1 个完整管理页面
- 原型：2 个原型文件（610 行），用于需求对齐
- Spec 文档：3 份（1059 行），完整记录需求→设计→实现
- 验收证据：4 份（API 测试、lint、构建、QA Review）

---

## 2. 流程时间线

> 全流程约 35-40 分钟。

| # | 阶段 | AI 角色 | 产出 | 人工介入 |
|---|------|---------|------|---------|
| 1 | **Intake 三问** | 主对话 | 目标/边界/验收标准 | 用户确认需求方向 |
| 2 | **智能路由** | 主对话 | 判定为工作流 C | 无 |
| 3 | **需求撰写** | @pm-agent | `01_requirement.md`（285行） | **用户审批**（门控点） |
| 4 | **原型创建** | @prototype-agent | 2 个 Vue 原型文件 | 无 |
| 5 | **原型迭代** | 主对话 | 修改列名 + 增加时间查询 + 调整列宽 | **用户反馈 3 轮** |
| 6 | **技术设计** | @arch-agent | `02_technical_design.md`（626行） | **用户审批**（门控点） |
| 7 | **后端实现** | @dev-agent | 7 个 Java 文件 + BUILD SUCCESS | 无 |
| 8 | **前端实现** | @fe-agent | 4 个前端文件 + lint 通过 | 无 |
| 9 | **全栈 QA** | @qa-agent | **FAIL**：发现 1 个权限缺陷 | 无 |
| 10 | **缺陷修复** | @fe-agent | 修复 toolbar 权限绑定 | 无 |
| 11 | **QA 复验** | @qa-agent | **PASS** | 无 |
| 12 | **API 自动测试** | 主对话 | 6 项 curl 测试全部 PASS | 无 |
| 13 | **合并 + 推送** | 主对话 | merge → develop → push | **用户授权** |
| 14 | **构建部署** | 主对话 | 前后端镜像推送 Harbor | **用户授权** |

**人工介入统计**：共 5 个决策点（需求确认 / 01审批 / 原型反馈 / 02审批 / 合并授权），其余全部由 AI 自动完成。

---

## 3. 关键节点详解

### 3.1 Intake → 智能路由

用户只说了一句"我想测试一个完整的工作流C"，**甚至没有具体需求**。

AI 主对话的第一反应不是去写代码，而是：

1. **探索代码库**：自动扫描已有表结构和管理页面，找到 `ai_preset_questions`（有表无页面）
2. **提出候选方案**：给出 3 个可选需求让用户选
3. **Intake 三问**：用户选定后，AI 替用户整理出目标/边界/验收标准
4. **路由判定**：分析需求涉及"新建 API + 新建页面" → 工作流 C（前后端联动）

**启示**：AI 不是被动等指令，而是主动引导。即使用户不知道要做什么，Intake 机制也能把需求从模糊变清晰。

### 3.2 PM 产出 → 用户审批

@pm-agent 自动完成了以下 Research：
- 读取 `ai_preset_questions` 表结构（16 个字段）
- 读取现有 `QuestionController`（发现只有导入/导出接口，CRUD 需新建）
- 读取 `skills/list.vue`（参考已有管理页面的 UI 模式）

产出 `01_requirement.md`（285 行），包含：
- 后端：数据模型、4 个接口定义、业务规则
- 前端：搜索区 4 字段、表格 10 列、弹窗 9 字段、完整交互流程
- 权限配置清单：1 个菜单 + 3 个按钮
- 15 条验收标准（含联调场景）

**门控点**：用户审阅后 Approve，才进入下一阶段。

### 3.3 原型迭代（需求可视化）

@prototype-agent 根据 01_requirement.md 自动生成可运行的 Vue 原型页面（mock 数据，不调后端）。

用户启动 `npm run dev` 在浏览器预览后，提出 2 轮反馈：

| 轮次 | 用户反馈 | AI 响应 |
|------|---------|---------|
| 第 1 轮 | "列名改成'中文名称/英文名称'，去掉'问题'前缀" | 同步更新 Spec + 原型 |
| 第 2 轮 | "搜索条件加更新时间范围查询" | 同步更新 Spec + 原型 |
| 第 3 轮 | "优先级列没有排序图标" | 列宽从 80→100px，排序箭头显示正常 |

**启示**：原型的价值不是"画个漂亮页面"，而是把需求分歧提前暴露在代码之前。3 轮迭代每轮只需 1-2 分钟，但避免了后续开发返工。

### 3.4 Arch 技术设计

@arch-agent 完成了以下 Research：
- 后端：读取 Controller/Service/Mapper/XML + 参考模块（AiMcps）的完整 CRUD 写法
- 前端：读取 Store/Router/API 模式 + 原型文件
- 数据库：通过 MCP 工具直接查询 `DESCRIBE ai_preset_questions`

产出 `02_technical_design.md`（626 行），包含：
- Part A：API Contract（4 个接口的 Request/Response/Error Codes）
- Part B：前端技术设计（路由/Store/组件树/API 字段映射）
- Part C：技术风险（`sortOrder` 字段名冲突、`Base_Column_List` 历史遗留）
- Part D：DB Schema（确认无需变更）

**发现的风险**：`BasePageParam.sortOrder`（排序配置）与 `AiPresetQuestions.sortOrder`（排序字段）同名，提前警示 Dev Agent 注意。

### 3.5 Dev + FE 实现

**后端**（@dev-agent）：
- 创建 `feature/test-preset-questions` 分支
- 新增 2 个类（Query DTO、Request DTO），修改 5 个文件
- 构建验证：`mvn clean package -DskipTests` → BUILD SUCCESS
- 发现并绕过了 `Base_Column_List` 中不存在的 `agent_name` 列（历史遗留），记录在 `03_implementation.md`

**前端**（@fe-agent）：
- 合并原型分支 → 在原型基础上改造（mock → 真实 Store 调用）
- 新增 Store 模块 + 路由注册 + 正式页面
- lint 验证通过

### 3.6 QA 发现缺陷 → 打回 → 修复 → 复验

@qa-agent 做了全栈四轴验收 + API Contract 一致性检查。

**后端**：全部通过（接口路径一致、分页正确、R 包装、SQL 无拼接、refreshCache 调用正确）

**前端发现 1 个阻塞缺陷**：
> FE-01：工具栏"新增"和"删除"按钮的 `operationObj.isAdd/isDel` 固定为 `true`，未与权限码关联。行内按钮的权限控制正确，仅工具栏遗漏。

流程：
1. QA 输出 **FAIL** + 具体修复建议
2. 主对话打回 @fe-agent
3. @fe-agent 在 `getAuth()` 末尾追加 4 行代码，修复权限绑定
4. @qa-agent 复验 → **PASS**

**启示**：QA Agent 比人更细致——它会逐个检查权限码、逐行对照 Spec 与实现。这个权限漏洞在人工 Review 中很容易被忽略。

### 3.7 API 自动验证

主对话启动后端服务（`mvn spring-boot:run`），自动跑了 6 项 curl 测试：

| 测试 | 接口 | 结果 |
|------|------|------|
| 分页查询 | POST /api/question/list | PASS（返回分页数据） |
| 新增 | POST /api/question/add | PASS（新增成功） |
| 查询验证 | POST /api/question/list?question=QA测试 | PASS（能查到新增记录） |
| 编辑 | PUT /api/question/update | PASS（编辑成功） |
| 删除 | DELETE /api/question/delete | PASS（删除成功） |
| 越界校验 | priority=11 | PASS（返回"优先级范围为 1~10"） |

### 3.8 合并 + 部署

用户授权后，主对话执行：
1. `git merge --no-ff feature/test-preset-questions` → develop
2. `git push origin develop`
3. 并行触发 `build_push.sh`（后端 + 前端）
4. 清理 feature 和 prototype 分支

镜像推送完成后，Watchtower 约 60s 自动拉取新镜像并重启容器。

---

## 4. 数据统计

### 代码产出

| 类别 | 文件数 | 新增行数 |
|------|--------|---------|
| 后端 Java + XML | 7 | 353 |
| 前端 Vue + JS | 4 | 615 |
| 原型文件 | 3 | 610 |
| 路由配置 | 1 | 29 |
| **合计** | 15 | 1,607 |

### 文档产出

| 文档 | 行数 | 产出角色 |
|------|------|---------|
| 01_requirement.md | 285 | PM Agent |
| 02_technical_design.md | 626 | Arch Agent |
| 03_implementation.md | 148 | Dev + FE Agent |
| 验收证据（4 份） | ~150 | QA Agent + 主对话 |
| **合计** | ~1,209 | — |

### 人工介入

| 介入点 | 耗时 | 决策内容 |
|--------|------|---------|
| Intake 确认 | ~1min | 选择方案 A，确认三问 |
| 01 审批 | ~1min | 通过需求文档 |
| 原型反馈 | ~3min | 3 轮修改（列名 + 时间查询 + 列宽） |
| 02 审批 | ~0.5min | 直接通过 |
| 合并/部署授权 | ~0.5min | 确认合并 + 触发构建 |
| **合计** | **~6min** | 5 个决策点 |

### 关键结论

- **AI 自主完成**：~95% 的工作量（Research + 代码 + 文档 + 测试 + 部署）
- **人专注决策**：~5% 的时间用于审批和反馈，不写一行代码
- **质量保障**：QA 自动发现 1 个权限缺陷，API 自动测试 6 项全 PASS

---

## 5. 产物索引

所有产物存放在 `.claude/specs/test-preset-questions/` 目录下：

```
.claude/specs/test-preset-questions/
  01_requirement.md          ← PM 产出的需求规格
  02_technical_design.md     ← Arch 产出的技术设计
  03_implementation.md       ← Dev/FE 的执行日志
  evidences/
    evidence-api-test.md     ← API 自动测试报告
    evidence-build.md        ← 后端构建验证
    evidence-fe-lint.md      ← 前端 lint 验证
    evidence-qa-review.md    ← QA 全栈审查报告（含缺陷修复复验）
```

代码变更：
- 后端：`ai-kg-agent-hub/src/main/java/com/example/system/` 下的 controller/service/mapper/dto/query
- 前端：`h-kg-agent-center/pages/preset-questions/` + `store/presetQuestion.js` + `router/routes.js`
- 原型：`h-kg-agent-center/pages/prototype/preset-questions/`

---

## 6. 给新成员的建议

读完这个案例后，你应该能理解：

1. **你不需要写代码**：你的角色是"审批者"和"决策者"，AI 负责执行
2. **Spec 是核心**：所有代码都能追溯到 Spec，Spec 追溯到 Intake 三问
3. **原型很值得**：花 3 分钟反馈原型，比花 3 小时返工代码划算得多
4. **QA 比你细心**：让 AI 审查 AI 的代码，它会检查你想不到的地方
5. **门控很重要**：01 和 02 的审批不能跳过——这是你控制方向的唯一机会

### 如果你想自己试一次

1. 安装 Claude Code
2. 进入项目目录，输入一个简单需求
3. 跟着 Intake 三问走，体验 AI 如何引导你澄清需求
4. 审批 Spec，看 AI 如何自动分工实现
5. 在 QA 报告中看 AI 发现了什么问题
