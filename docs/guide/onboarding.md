---
title: 项目接入检查清单
description: 从初始化到正式投入使用的逐步配置指南
prev:
  text: 概念速查表
  link: /guide/concepts
next:
  text: 工具速查
  link: /guide/tools
---

# 项目接入检查清单

> 从 `init-project.sh` 执行完毕到项目正式投入使用，逐步完成以下配置。
> 每步有"做什么"、"怎么验证"、"注意什么"。

---

## Phase 1：初始化验证

### 1.1 确认目录结构

```bash
ls -la .claude/{agents,rules,skills,context,specs,codemap,project-memory}
```

验证：7 个子目录都存在。

### 1.2 确认被管理文件

```bash
grep -rl "codeflow-framework:core" .claude/ | wc -l
```

验证：输出 13（或以上，含子项目脚手架生成的文件）。这些文件包含 marker，会被 `upgrade.sh` 管理。

### 1.3 确认子项目已初始化

```bash
# 检查前端子项目
ls <前端子项目>/.claude/

# 检查后端子项目
ls <后端子项目>/.claude/
```

验证：子项目的 `.claude/` 目录已创建，包含 context/、rules/、project-memory/。

如果缺失，手动补：

```bash
sh ../codeflow-framework/templates/init-subproject.sh ./子项目路径 fe "项目名"
```

---

## Phase 2：项目配置

### 2.1 编写 CLAUDE.md

**做什么**：基于生成的模板，补充项目信息。

**必填内容**：
- 项目概述（业务背景、目标）
- 子项目结构（各子目录说明）
- 技术栈（语言、框架、数据库）
- 技术约束（部署环境、特殊依赖）

**怎么验证**：让一个不了解项目的人读完 CLAUDE.md 后，能说清楚项目是做什么的、代码怎么组织的。

**注意**：CLAUDE.md 在项目根目录，不在 `.claude/` 下。

### 2.2 填充业务词典

**做什么**：编辑 `.claude/skills/domain-ontology/SKILL.md`，在 **marker 下方** 补充项目的核心业务术语。

**填充内容**：
- 核心实体（用户、订单、渠道等）
- 术语定义（行业中容易混淆的概念）
- 实体关系（A 属于 B，C 引用 D）

**怎么验证**：PM Agent 产出 Spec 时，能正确使用业务术语，不需要你反复纠正。

**注意**：只改 marker 下方的内容，marker 上方的格式说明不要动。

### 2.3 配置后端编码规范

**做什么**：编辑 `.claude/rules/coding_backend.md`。

**建议内容**：
- 包结构约定（controller/service/mapper 的职责边界）
- 命名规范（类名、方法名、变量名）
- 异常处理策略（统一异常封装）
- SQL 规范（禁止拼接、使用参数化查询）
- 日志规范（什么级别记什么内容）

**怎么验证**：Dev Agent 产出的代码符合这些规范，不需要你反复指出同样的问题。

### 2.4 配置前端编码规范

**做什么**：编辑 `.claude/context/coding_frontend_shared.md`。

**建议内容**：
- 组件规范（命名、props 定义、事件命名）
- 状态管理（Pinia/Vuex 使用约定）
- API 调用层封装（统一错误处理、Loading 状态）
- 样式规范（scoped 强制、设计系统对接）

**怎么验证**：FE Agent 产出的代码符合这些规范。

### 2.5 完善子项目 context

**做什么**：检查各子项目的 `.claude/context/` 文件，补充实际内容。

子项目 context 文件内嵌了 AI 行为指令（HTML 注释），Agent 首次使用时会自动扫描并填充。你也可以手动填写：

- **前端子项目**：components.md（组件清单）、routes.md（路由结构）、stores.md（状态管理）
- **后端子项目**：tech-stack.md（技术栈）、api-conventions.md（API 约定）、scenario-index.md（场景索引）

**怎么验证**：用 `/onboard <模块名>` 测试，AI 能输出完整的模块概览。

### 2.6 配置分支策略（可选）

**做什么**：编辑 `.claude/context/branches.md`（marker 下方），补充项目特有的分支规则。

**注意**：如果使用框架默认的分支策略（feature/* / fix/* / refactor/*），可以跳过这步。

---

## Phase 3：功能验证

### 3.1 验证升级脚本

```bash
# 先 dry-run，确认不会出问题
bash ../codeflow-framework/tools/upgrade.sh --dry-run

# 正式执行
bash ../codeflow-framework/tools/upgrade.sh

# 检查变更
git diff .claude/
```

验证：dry-run 无报错，正式执行后 marker 下方内容不变。

### 3.2 跑一个 Q0 任务

在 Claude Code 中输入一个简单需求（如修改文案），确认：
- [ ] AI 执行了 Intake 三问
- [ ] AI 判断为 Q0 轻量模式
- [ ] 你审批后 AI 才改代码
- [ ] 修改完成，功能正常

### 3.3 跑一个正式工作流

给一个真实需求（新 API / 新页面 / 全栈功能），确认：
- [ ] AI 正确路由到 A/B/C 工作流
- [ ] PM 产出 01，你审批
- [ ] Arch 产出 02，你审批
- [ ] Dev/FE 实现，QA 审查
- [ ] Spec 链完整（01 → 02 → 03 → evidences）

---

## Phase 4：提交与团队就绪

### 4.1 Git 提交初始化结构

```bash
git add .claude/ CLAUDE.md
git commit -m "chore: init codeflow framework structure"
```

### 4.2 团队同步

- 确保团队成员知道 `.claude/` 目录的存在和用途
- 分享 [快速入门](/guide/quick-start) 链接
- 提醒：marker 上方的内容不要手动改（改了也会被 upgrade 覆盖）

### 4.3 日常使用约定

- 需求描述尽量具体（帮 AI 做好 Intake）
- 审批 PM 和 Arch 的产出时要认真看（这是你影响质量的关键环节）
- 踩坑后写规则（防止 AI 重复犯同样的错误）
