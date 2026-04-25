---
title: 新项目接入实践：AI Crawlers 初始化全流程
description: 从 init-project.sh 到 /init-setup 完成的完整操作记录，真实项目案例
prev:
  text: v2 跨语言重构实战
  link: /cases/v2-refactor
next: false
---

> 以 **AI Crawlers**（网络情报数据采集系统）为例，记录从零开始接入 H-CodeFlow Framework 的完整流程。
> 每一步都附带实际输入和输出，可直接对照操作。
> 目标读者：准备接入框架的新项目负责人。

---

## 一、项目背景

**AI Crawlers** 是一个网络威胁情报采集系统，自动化采集漏洞、暗网、社交媒体等多维度数据。项目结构如下：

```
ai-crawlers/
├── data-collect-system/         # 后端（Java 8 / Spring Boot 2.6 / Maven 多模块）
│   ├── data-collect-base/       #   采集核心服务（端口 30201）
│   ├── api-proxy-service/       #   三方情报 API 代理（FOFA/ZoomEye/Hunter/Quake）
│   ├── third-party-adapter/     #   第三方数据适配器（端口 30202）
│   ├── external-proxy-service/  #   外部代理服务
│   ├── data-xxl-job-execute/    #   XXL-Job 任务执行器（端口 9969）
│   └── data-xxl-job-admin/      #   XXL-Job 调度管理（端口 40002）
├── ai-kg-front/                 # 前端主应用（Nuxt 2 + Qiankun 主容器）
├── h-kg-collection/             # 采集管理子应用（微前端）
└── h-kg-system/                 # 系统配置子应用（微前端）
```

**接入前状态**：有代码无框架、无 AI 协作规范、无业务词典。

---

## 二、Phase 1：执行初始化脚本

### 命令

```bash
cd /path/to/ai-crawlers
sh ../codeflow-framework/templates/init-project.sh . "AI Crawlers" full
```

选择 `full` 级别是因为项目需要完整功能（7 个 Agent + E2E + Jira 集成）。

### 输出

```
═══ 初始化项目：AI Crawlers ═══
[INFO]   项目目录：/path/to/ai-crawlers
[INFO]   项目名称：AI Crawlers
[INFO]   框架目录：/path/to/codeflow-framework
[INFO]   初始化级别：full
[OK]     框架已验证

═══ 创建 .claude 目录结构 ═══
[OK]     目录结构已创建：agents/ rules/ skills/ context/ specs/ codemap/ .sync-state/

═══ 复制框架托管文件（级别：full） ═══
[INFO]   Agent: pm-agent.md, arch-agent.md, dev-agent.md, fe-agent.md, qa-agent.md, ...
[INFO]   Skill: api-reviewer, sql-checker, domain-ontology, ...
[INFO]   Command: commit, deploy, fix, memory, onboard, ...
[OK]     已复制 42+ 个框架文件

═══ 复制项目模板文件 ═══
[OK]     已创建 CLAUDE.md
[OK]     已创建 .claude/rules/coding_frontend_shared.md
[OK]     已创建 .claude/rules/coding_backend.md

═══ 检测子项目 ═══
[INFO]   初始化前端子项目：ai-kg-front       → 5 个文件
[INFO]   初始化后端子项目：data-collect-system → 4 个文件
[INFO]   初始化前端子项目：h-kg-collection    → 5 个文件
[INFO]   初始化前端子项目：h-kg-system        → 5 个文件
[OK]     已初始化 4 个子项目

[OK]     已生成初始化清单：.claude/setup-checklist.md

═══ 初始化完成 ═══
✓ 框架文件已初始化（级别：full）
✓ 初始化清单已生成

下一步：执行 /init-setup 或说「继续初始化」
```

### 关键点

- 脚本**自动检测**了 4 个子项目（1 个后端 + 3 个前端），并为每个子项目生成了独立的 `.claude/` 脚手架
- `setup-checklist.md` 包含 8 个待办任务（full 级别包含全部任务；level1 只有 T1/T2/T5）

---

## 三、Phase 2：/init-setup 逐任务配置

在新会话中说「继续初始化」，AI 读取 `setup-checklist.md` 从 T1 开始逐步执行。

### T1 — 填充 CLAUDE.md（自动检测 → 用户补充）

**AI 自动检测的内容**：

| 检测项 | 方法 | 检测结果 |
|--------|------|---------|
| 技术栈（后端） | 读 `pom.xml` | Java 8 + Spring Boot 2.6 + Spring Cloud + MyBatis-Plus + MySQL/MongoDB/Redis/Kafka/ES |
| 技术栈（前端） | 读 `package.json` × 3 | Nuxt 2 + Vue 2 + Element UI + Qiankun 微前端 |
| 子项目结构 | 扫描顶层目录 | 1 后端（6 模块）+ 3 前端 |
| 部署配置 | 读 `application.yaml` | MySQL 30201、MongoDB 27017、Redis 6379、ES 9201 |
| Docker | 扫描 Dockerfile | Harbor 私有仓库 + OpenTelemetry + SkyWalking |

**AI 询问用户的内容**：

> 项目一句话定位？

用户回答：**网络情报数据采集系统，面向安全团队**

> 团队成员与角色？

用户回答：**后端负责人 your-name，前端待补充**

> 关键约束或已知坑点？

用户回答：**Java 8 锁定、MyBatis-Plus 不用 Lambda 风格、前端无 ESLint**

**最终效果**：CLAUDE.md 从模板（含 `[请填写]` 占位符）变为包含 9 个子项目行、6 条约束、完整技术栈描述的项目文档。关键字段：

```markdown
| 维度 | 说明 |
|------|------|
| 技术栈（后端） | Java 8 + Spring Boot 2.6 + Spring Cloud 2021 + MyBatis-Plus |
| 技术栈（前端） | Nuxt 2 + Vue 2 + Element UI + Qiankun 微前端 |
| 主要模块 | data-collect-base、api-proxy-service、third-party-adapter、... |
```

**耗时**：约 3 分钟（自动检测 1 分钟 + 用户补充 2 分钟）

---

### T2 — 填充业务词典（实体扫描 → 术语确认）

**AI 自动检测的内容**：

| 检测项 | 方法 | 结果 |
|--------|------|------|
| 实体类 | 扫描 `@TableName` 注解 | CollectTaskDefine、CollectTaskInstance、CollectDataSource、CollectCrawlerInfo、CollectIpResource 等 |
| 枚举类 | 扫描 `enum` 定义 | TaskInstanceCategoryEnum（5 种状态）、CollectTaskSourceEnum（11 种采集源） |
| API 端点 | 扫描 `@RequestMapping` | `/collect/taskDefine`、`/collect/taskInstance`、`/collect/dataSource` 等 |
| 数据源类型 | 读 CollectDataSource | 7 种类型（漏洞/网站/社交/暗网/博客/公众号） |

**AI 询问用户的内容**：

> 检测到的实体 CollectTaskDefine 的中文业务名称是什么？

用户回答：**采集任务定义** — 描述"要采集什么"的配置模板

> 实体间关系确认？

用户回答：**一个 TaskDefine 可产生多个 TaskInstance（1:N）；Crawler 和 DataSource 是多对多**

**最终效果**：业务词典包含 9 个核心术语、4 个业务实体（含完整属性和关系图）、5 条业务规则、3 个常见场景流程。

术语表示例：

| 术语 | 英文 | 定义 |
|------|------|------|
| 采集任务定义 | CollectTaskDefine | "要采集什么"的配置模板，是实例化前的静态配置 |
| 采集任务实例 | CollectTaskInstance | 任务定义被触发后产生的一次具体执行记录 |
| 数据源 | CollectDataSource | 情报数据的来源渠道，分 7 种类型 |

**耗时**：约 5 分钟（扫描 2 分钟 + 用户确认术语和关系 3 分钟）

---

### T3 — MCP 集成（跳过）

AI 检测到 `.mcp.json` 已创建但凭据为空，询问是否配置。

用户回答：**本地开发暂不需要 Jira/Confluence，跳过**

AI 标记为 `skipped`。

> **什么情况下跳过**：本地开发不使用 Jira 管理任务、不使用 Confluence 管理文档时。团队内部用协作工具 管理的也可以跳过。

---

### T4 — 自定义编码规范（代码风格检测）

**AI 自动检测的内容**：

| 检测项 | 方法 | 结果 |
|--------|------|------|
| 前端缩进 | 采样 10 个 Vue 文件 | 2 个空格（无 Tab） |
| 前端引号/分号 | 读 `.prettierrc` | 单引号、无分号（`"semi": false, "singleQuote": true`） |
| 前端 ESLint | 检查 `.eslintrc*` | 未启用（`@nuxtjs/eslint-module` 已注释） |
| 后端缩进 | 采样 10 个 Java 文件 | 4 个空格 |
| 后端 Checkstyle | 检查 `checkstyle.xml` | 不存在 |
| 包管理器 | 检测 lock 文件 | npm（前端）+ Maven（后端） |

**AI 询问用户的内容**：

> 检测到 MyBatis-Plus 使用 Wrapper 而非 Lambda 风格，这是否是团队约定？

用户回答：**是的，团队不熟悉 Lambda 风格，历史代码全是非 Lambda 写法**

> 还有其他约定吗？

用户回答：**前端子应用不引入 vul-ui（避免微前端样式冲突）；API 统一走 /api/ 网关**

**最终效果**：前后端编码规范文件 marker 下方均写入了项目特定约定：

- 后端：Java 8 锁定、MyBatis-Plus 非 Lambda、分页强制、枚举代替魔法数、API Key 保护
- 前端：Qiankun 微前端约定、代码风格（2空格/单引号/无分号）、vul-ui 仅主应用使用

**耗时**：约 3 分钟

---

### T5 — 框架升级（跳过）

AI 检测到刚执行 `init-project.sh`，当前版本与框架一致。

用户确认：**跳过，后续有框架更新时再执行**

> **什么时候需要执行**：init 后过了一段时间，框架发布了新版本（可通过 `tools/VERSION` 查看最新版本号）。

---

### T6 — 完善子项目上下文（后端技术栈填充）

AI 重点填充了 `data-collect-system/.claude/context/tech-stack.md`：

**检测内容**：

| 检测项 | 结果 |
|--------|------|
| Maven 模块结构 | 6 个子模块，每个有独立端口 |
| 核心实体 | CollectTaskDefine、CollectTaskInstance、CollectDataSource、CollectCrawlerInfo 等 8 个 |
| API 端点 | `/collect/taskDefine`（CRUD + 启停）、`/collect/taskInstance`（查询+分页）等 6 组 |
| 三方 API | FOFA、ZoomEye、Hunter、Quake、天眼查、0.Zone 等 8 个 |
| 基础设施 | MySQL + MongoDB + Redis + ES + Kafka + MinIO + XXL-Job（含内网地址） |
| 技术约束 | Java 8 锁定、MyBatis-Plus 非 Lambda、分页强制 pageNumber/pageSize |

**最终效果**：tech-stack.md 从模板（含 `[待填写]` 占位符）变为包含完整技术栈表格、多模块架构图、8 个实体表、6 组 API 端点、8 个三方服务、7 个基础设施地址的参考文档。

**耗时**：约 4 分钟

---

### T7 — 确认 Spec 目录结构（信息确认）

AI 检查 `.claude/specs/` 目录为空。

AI 提示：**首次创建 Feature 时，PM Agent 会自动创建 Spec 文件**

用户确认，标记为 done。

---

### T8 — E2E 测试基础设施（跳过）

AI 检测到无 `e2e/` 目录、无 `playwright.config.ts`。

用户回答：**项目暂不需要 E2E 测试，跳过**

---

## 四、Phase 3：最终效果

### 任务完成状态

| 任务 | 状态 | 耗时 | AI 自动 | 用户补充 |
|------|------|------|---------|---------|
| T1 CLAUDE.md | ✅ done | ~3 min | 技术栈、目录结构、部署配置 | 项目定位、团队、约束 |
| T2 业务词典 | ✅ done | ~5 min | 实体/枚举/API 扫描 | 中文术语、业务规则、关系 |
| T3 MCP 集成 | ⊘ skipped | ~0.5 min | 文件存在性检查 | 确认跳过 |
| T4 编码规范 | ✅ done | ~3 min | 代码风格采样、lint 配置 | 确认 + 补充微前端约定 |
| T5 框架升级 | ⊘ skipped | ~0.5 min | 版本号比对 | 确认跳过 |
| T6 子项目上下文 | ✅ done | ~4 min | Maven 结构、实体、API、中间件 | 确认 + 补充约束 |
| T7 Spec 目录 | ✅ done | ~0.5 min | 目录检查 | 确认 |
| T8 E2E 测试 | ⊘ skipped | ~0.5 min | 环境检查 | 确认跳过 |

**总计**：约 17 分钟，其中 5 个任务 done、3 个 skipped。

### 项目目录结构（初始化后）

```
ai-crawlers/
├── CLAUDE.md                          ← T1 已填充
├── .claude/
│   ├── agents/ (7 个)                 ← 框架管理
│   ├── rules/
│   │   ├── project_rule.md            ← 框架管理
│   │   ├── merge_checklist.md         ← 框架管理
│   │   ├── coding_backend.md          ← T4 已填充
│   │   └── coding_frontend_shared.md  ← T4 已填充
│   ├── skills/
│   │   ├── domain-ontology/SKILL.md   ← T2 已填充
│   │   └── ... (24 个 Skill)
│   ├── commands/ (8 个)               ← 框架管理
│   ├── context/                       ← 框架模板
│   ├── specs/                         ← 空（T7 确认）
│   ├── codemap/                       ← 空
│   └── setup-checklist.md             ← 全部 done/skipped
├── data-collect-system/.claude/
│   └── context/tech-stack.md          ← T6 已填充
├── ai-kg-front/.claude/               ← 初始化脚手架
├── h-kg-collection/.claude/           ← 初始化脚手架
└── h-kg-system/.claude/               ← 初始化脚手架
```

---

## 五、经验总结

### 时间投入

| 阶段 | 耗时 | 占比 |
|------|------|------|
| init-project.sh 执行 | ~1 分钟 | 5% |
| T1-T8 逐任务配置 | ~17 分钟 | 85% |
| 验证和检查 | ~2 分钟 | 10% |
| **合计** | **~20 分钟** | 100% |

### 关键决策点

1. **初始化级别选择**：选 `full` 还是 `level1`？
   - `level1`（最小）：只有 T1(CLAUDE.md) + T2(词典) + T5(upgrade)，适合快速体验
   - `full`（完整）：含 E2E + Jira 集成，适合正式项目
   - **建议**：先用 `level1` 体验，后续需要时重新执行 init 升级级别

2. **哪些任务可以跳过**：
   - T3 MCP：不用 Jira/Confluence 的团队可跳过
   - T5 upgrade：刚 init 时跳过
   - T8 E2E：不需要 E2E 测试时可跳过
   - 其他任务建议全部完成，尤其是 T1 和 T2

3. **AI 自动检测 vs 用户手动**：
   - 技术栈、代码风格、实体结构 → AI 自动检测（准确率 90%+）
   - 业务语义、团队约定、约束条件 → 必须用户补充（AI 无法推断）

### 给新接入者的建议

1. **先确保框架目录同级**：`codeflow-framework` 和业务项目在同一级目录，init 脚本和 upgrade 脚本才能正常工作
2. **T1 和 T2 优先级最高**：CLAUDE.md 是 AI 理解项目的入口，业务词典是 AI 使用正确术语的基础。这两个做好，后续 AI 的产出质量会明显提升
3. **验证后再提交**：用 `/init-setup --status` 检查所有任务状态，确认无误后再 `git add .claude/ CLAUDE.md`
4. **marker 下方才是你的**：编辑 rules、skills 等文件时，只在 `<!-- codeflow-framework:core ... -->` 这行**下方**写内容，上方会被 `upgrade.sh` 覆盖
5. **后续升级**：框架发布新版本后，执行 `bash ../codeflow-framework/tools/upgrade.sh --dry-run` 先预览变更
