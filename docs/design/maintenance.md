---
title: 六、已接入项目的更新与维护
description: 日常维护、框架升级、版本命名与试验场工作流
prev:
  text: 五、新项目接入
  link: /design/integration
next:
  text: 七、团队协作
  link: /design/collaboration
---

# 六、已接入项目的更新与维护

## 6.1 日常维护

项目接入框架后，日常维护工作分为两部分：

**框架管理的内容（marker 上方）**：由框架统一维护，项目团队**不要直接修改**（改了也会被下次升级覆盖）。如需调整，走反馈流程（见 [八、核心工具参考](/design/tools)）。

**项目自定义内容（marker 下方）**：项目团队自行维护，框架升级时**永远不会被覆盖**。包括：

| 内容 | 维护方式 |
|------|---------|
| Agent 行为扩展 | 在 `agents/*.md` marker 下方追加项目特有指令 |
| 工作流规则扩展 | 在 `project_rule.md` marker 下方追加项目规则 |
| 合并检查项扩展 | 在 `merge_checklist.md` marker 下方追加检查项 |
| 业务词典 | 在 `domain-ontology/SKILL.md` marker 下方填充术语和实体 |
| 编码规范 | 直接编辑 `coding_backend.md`、`coding_frontend_shared.md`（纯项目文件） |
| Spec 文档 | 在 `specs/` 目录按模板创建 |
| 项目记忆 | 在 `project-memory/MEMORY.md` 维护 |

## 6.2 框架升级

当框架发布新版本后（`tools/VERSION` 更新），已接入项目需要执行升级以获取最新的 Agent 定义、工作流规则和知识库。

### 升级操作

```bash
cd my-project
bash ../h-codeflow-framework/tools/upgrade.sh
```

> `upgrade.sh` 执行时会自动 `git pull` 框架仓库最新代码，无需手动拉取。合并原理详见 [三、Stub Marker](/design/marker)，完整参数说明详见 [八、核心工具参考](/design/tools)。

### 升级验证

```bash
# 执行升级
bash ../h-codeflow-framework/tools/upgrade.sh

# 检查变更内容
git diff .claude/

# 确认项目自定义内容完好（marker 下方应无变化）

# 提交升级
git add .claude/
git commit -m "chore(framework): upgrade to v1.x.x-YYYYMMDD"
git push origin develop
```

### 回滚方案

`upgrade.sh` 每次执行都会自动备份到 `.claude/.backup/`，回滚只需：

```bash
# 查看备份位置（脚本执行结束时会提示）
ls .claude/.backup/

# 恢复
cp -r .claude/.backup/upgrade-YYYYMMDD-HHMMSS/* .claude/
```

## 6.3 版本命名规则

```
MAJOR.MINOR.PATCH-YYYYMMDD          ← 正式版本
MAJOR.MINOR.PATCH-dev.N-YYYYMMDD    ← 实验版本（dev 版本）

示例：1.5.0-20260417（正式）  1.6.0-dev.1-20260418（实验）
```

| 字段 | 变更时机 |
|------|---------|
| MAJOR | 不兼容的架构变更（如 marker 格式变化、目录结构重组） |
| MINOR | 新增功能（如新增 Agent、新增 Skill） |
| PATCH | 修复和小优化（如 Agent 行为微调、规则措辞优化） |
| 日期 | 发布日期 |
| dev.N | 实验迭代序号，正式发版前必须去掉（`release.sh` 会拦截） |

### VERSION 更新时机

- **开发期间**：VERSION 保持最后已发布版本号，不随代码变更更新
- **发版时**：`/release-core` 命令统一更新 VERSION 为新版本号
- **试验场推送**：临时设 dev 版本，验证完毕后恢复

### CHANGELOG 生成时机

- **开发期间**：不修改 CHANGELOG.md
- **发版时**：`/release-core` 通过 `git log <TAG>..HEAD` 找到所有未发布 commit，归纳为面向用户的 CHANGELOG 条目
- CHANGELOG 面向框架使用者（下游项目开发者），不堆叠 commit 信息，而是重写为用户视角

## 6.4 试验场工作流（双向同步）

框架是元框架，没有执行环境——改动无法在框架仓库内验证。实际做法是在真实下游项目中实验，验证通过后再反向沉淀回框架。

### 双向工具链

```
┌─────────────────────┐                    ┌─────────────────────┐
│  h-codeflow-framework│                    │     下游项目         │
│      (编排层)        │                    │     (试验场)        │
│   core/             │  ── upgrade.sh ──→ │   .claude/          │
│   (框架源)           │    framework→下游   │   (marker上方被替换) │
│   core/             │  ←── harvest.sh ── │   .claude/          │
│   (更新)            │     下游→framework  │   (marker上方被收割) │
└─────────────────────┘                    └─────────────────────┘
```

### 完整流程（5 步）

```
Step 1: [框架] 开实验分支，设 dev 版本
Step 2: [试验项目] FRAMEWORK_BRANCH=exp/xxx bash upgrade.sh
Step 3: [试验项目] 真实任务中验证、迭代
Step 4: [框架] harvest.sh --apply 收割验证过的内容
Step 5: [框架] 去掉 -dev，更新 CHANGELOG，release.sh --confirm
```

具体命令参见 CLAUDE.md "试验场工作流" 章节。

### 冲突检测机制

双向同步通过内容指纹（SHA-256）防止静默覆盖：

- **upgrade.sh 方向**：检测下游 marker 上方是否有本地修改 → 默认备份 `.local` 后继续 / `--conflict=preserve` 跳过 / `--conflict=fail` 退出 / `--force` 跳过检测
- **harvest.sh 方向**：检测 core/ 中是否有未发布修改 → 标记 `[CORE-MODIFIED]` 需逐文件确认

推荐顺序：先收割（下游→框架），再升级（框架→下游），确保下游改进不丢失。

## 6.5 常见问题

常见问题和故障排查已独立维护，参见：
- **[常见问题](/getting-started/faq)**：高频问题（基础概念/初始化/升级/工作流/环境）
- **[故障排查](/getting-started/troubleshooting)**：五大问题域的排查步骤和解决方案
