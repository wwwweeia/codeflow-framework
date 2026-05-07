# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目定位

h-codeflow-framework 是一个**元框架项目**（不是应用项目），为公司所有业务项目提供统一的 Spec-Driven Development (SDD) 工作流规范、Agent 定义、质量检查规则和知识库。多个下游业务项目通过 `upgrade.sh` 从本仓库同步框架文件。

## 核心架构

**两层分离**：
- **编排层**（本仓库 `core/`）：通用的工作流定义，版本化管理
- **执行层**（下游项目 `.claude/`）：项目特有的业务规则和知识库

**Stub Marker 机制**：被管理文件包含 `<!-- h-codeflow-framework:core vX.X.X-YYYYMMDD — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->` 标记。`upgrade.sh` 更新 marker 上方的框架内容，保留 marker 下方的项目自定义内容。修改 `core/` 下的文件时，必须确保 marker 存在且位置正确。

## 关键文件与职责

| 路径 | 职责 | 修改影响 |
|------|------|---------|
| `core/MANIFEST` | 框架管理文件清单（唯一真相源） | init/upgrade/harvest 三个脚本的文件范围 |
| `core/agents/*.md` | 7 个 Agent 定义（PM/Arch/Dev/FE/QA/Prototype/E2E） | 所有下游项目的 Agent 行为 |
| `core/rules/iron-rules.md` | 框架铁律（所有 Agent 共享的 6 条硬约束） | 所有 Agent 的行为底线 |
| `core/rules/project_rule.md` | 工作流调度规则（Intake + 路由 + 验证） | 所有下游项目的工作流 |
| `core/rules/merge_checklist.md` | 合并前检查清单 | 所有下游项目的合并流程 |
| `core/skills/*/SKILL.md` | 知识库（SQL审查、API规范、Spec模板等） | 所有下游项目的审查规则 |
| `tools/upgrade.sh` | 框架升级脚本（framework → 下游） | 所有下游项目的升级流程 |
| `tools/harvest.sh` | 变更收割脚本（下游 → framework） | 框架 core/ 内容 |
| `tools/VERSION` | 版本号（`MAJOR.MINOR.PATCH-YYYYMMDD`） | 版本追踪 |
| `templates/init-project.sh` | 新项目初始化脚本 | 新项目接入流程 |
| `templates/*.template` | 项目模板文件（初始化时复制，之后独立维护） | 仅影响新初始化的项目 |
| `demo/` | AI Prompt Lab 演示项目（FastAPI + Vue 3） | 框架变更的**首发验证环境** |

## 常用命令

```bash
# 初始化新项目（在目标项目目录执行）
bash ../h-codeflow-framework/templates/init-project.sh . "Project Name"

# 升级下游项目的框架文件（在目标项目目录执行，自动 git pull 框架最新代码）
bash ../h-codeflow-framework/tools/upgrade.sh

# 升级前预览哪些文件会变化（不写入）
bash ../h-codeflow-framework/tools/upgrade.sh --dry-run

# 升级前预览并显示详细 diff（不写入）
bash ../h-codeflow-framework/tools/upgrade.sh --dry-run --diff

# 正式升级并显示 diff
bash ../h-codeflow-framework/tools/upgrade.sh --diff

# 跳过冲突检测，强制覆盖
bash ../h-codeflow-framework/tools/upgrade.sh --force

# 跳过有冲突的文件（保留本地修改）
bash ../h-codeflow-framework/tools/upgrade.sh --conflict=preserve

# 有冲突时直接退出（CI 用）
bash ../h-codeflow-framework/tools/upgrade.sh --conflict=fail

# 升级时指定框架分支（用于测试实验分支）
FRAMEWORK_BRANCH=exp/xxx bash ../h-codeflow-framework/tools/upgrade.sh

# 从下游项目收割验证过的变更回 core/（在框架目录执行）
bash tools/harvest.sh ../your-project              # 预览差异
bash tools/harvest.sh --apply ../your-project      # 实际写入

# 发版预览（dry-run，不发送通知、不 push）
bash tools/release.sh

# 正式发送飞书群通知
bash tools/release.sh --confirm

# 在 demo 中验证框架变更（发版前必做）
cd demo && bash ../tools/upgrade.sh --diff    # 升级并查看变更

# 重置 demo 到初始状态（用于反复演示或验证）
cd demo && bash reset-demo.sh --base
```

```bash
# 环境诊断（检查框架基础设施、项目构建工具、可选集成、E2E 环境）
bash tools/doctor.sh              # 完整检查
bash tools/doctor.sh --quiet      # 只显示有问题的项
bash tools/doctor.sh --json       # JSON 格式输出（CI 集成）
```

## 发版流程

### 开发阶段（不碰版本号和 CHANGELOG）

1. **修改内容**：在 `core/`、`tools/`、`templates/` 等目录完成改动
2. **Demo 验证**：`cd demo && bash ../tools/upgrade.sh`，确认变更效果（见下方"Demo 验证规则"）
3. **提交**：用常规 commit message（`feat:`/`fix:`/`refactor:`）
4. **不修改 `tools/VERSION`，不修改 `CHANGELOG.md`**

### 发版阶段（`/release-core` 命令）

执行 `/release-core` 命令，一次性完成：

1. 确认工作区干净
2. 确定 MAJOR/MINOR/PATCH 版本号
3. `git log <TAG>..HEAD --oneline` 找到所有未发布 commit
4. **归纳为面向用户的 CHANGELOG 内容**（见下方"CHANGELOG 写作规范"）
5. 更新 `tools/VERSION` + 在 `CHANGELOG.md` 顶部插入新版本记录
6. 提交：`chore(release): 发布 vX.Y.Z-YYYYMMDD`
7. `release.sh` 预览 → `release.sh --confirm`（打 tag + 发飞书通知）

**`release.sh` 会自动校验**：VERSION 与 CHANGELOG 一致性、dev 版本拦截。任何校验失败都会阻止发送并提示原因。

### CHANGELOG 写作规范

CHANGELOG 面向**框架使用者**（下游项目开发者），不是内部开发日志。写作要求：

**视角**：站在"升级后会怎样"的角度描述变更，不堆叠 commit 信息。

**格式**：
```markdown
## [X.Y.Z-YYYYMMDD] - YYYY-MM-DD

### 🟢 新增
- **功能名称**：用户能做什么新事情（不说实现细节）

### 🔵 改进
- **改进内容**：用户体验有什么变化（不说行数、文件路径）

### 🐛 修复
- **#Issue** 简述修复的问题和影响

### 📋 升级须知
- 是否需要项目侧适配？直接 upgrade.sh 还是有额外步骤？
- 是否有破坏性变更？
```

**原则**：
- 说**改了什么、对用户有什么影响**，不说**怎么改的、改了多少行**
- 保留 Issue 编号便于追溯，但不展开实现细节
- 每个版本必须包含"升级须知"段，即使只写"无需项目侧适配"

### Demo 验证规则（发版前置条件）

`demo/` 是框架的**首发验证环境**。任何 `core/` 变更在正式发版前，必须先在 demo 中验证**文件同步是否正常**。

```bash
# 在 demo 中执行升级，确认 marker 上方文件内容正确同步
cd demo && bash ../tools/upgrade.sh --diff
```

**核心验证点**：
- `upgrade.sh` 正常执行，无报错
- `--diff` 输出与预期变更一致
- marker 上方内容正确更新，marker 下方项目自定义内容未被覆盖

**验证不通过的变更不得发版**，必须修复后重新验证。

### Dev 版本约定（试验场推送）

开发中需要推送到下游项目验证时，临时设 dev 版本，测完恢复：

```bash
# 临时设 dev 版本
echo "X.Y.Z-dev.1-$(date +%Y%m%d)" > tools/VERSION
# 推送到试验项目
FRAMEWORK_BRANCH=your-branch bash ../h-codeflow-framework/tools/upgrade.sh
# 测完恢复 VERSION
git checkout tools/VERSION
```

- dev 版本可通过 `upgrade.sh` 推送到试验项目，marker 会自动携带 dev 版本号
- `release.sh` 会拒绝发布含 `-dev` 的版本，确保正式发版前必须去掉 dev 标记
- 详细流程参见 `docs/design/maintenance.md` §6.4

## 试验场工作流（双向同步）

框架没有执行环境，变更需要在真实项目中验证。当前形成"demo 快速验证 → your-project 真实任务验证 → 沉淀"三层闭环：

- **`demo/`（首发验证）**：框架内自带的最小演示项目，所有 `core/` 变更**必须先在此验证**通过
- **`your-project`（真实验证）**：真实下游项目，用于在业务场景中验证变更的实际效果

### 双向工具链

| 方向 | 工具 | 执行位置 | 作用 |
|------|------|---------|------|
| framework → 下游 | `upgrade.sh` | 下游项目目录 | 同步框架内容到项目 `.claude/` |
| 下游 → framework | `harvest.sh` | 框架目录 | 收割项目中验证过的内容回 `core/` |

### 操作流程

当需要在下游项目中实验新功能并沉淀回框架时：

1. **框架侧开分支**：`git checkout -b exp/xxx`，修改 `core/`，VERSION 设为 dev 版本（如 `1.6.0-dev.1-20260418`）
2. **推送到试验项目**：在 your-project 执行 `FRAMEWORK_BRANCH=exp/xxx bash ../h-codeflow-framework/tools/upgrade.sh`
3. **验证迭代**：在真实任务中使用，发现问题可直接修改 marker 上方内容
4. **收割回框架**：在框架目录执行 `bash tools/harvest.sh ../your-project`（先 dry-run 看 diff），确认后 `--apply`
5. **正式发版**：去掉 VERSION 中的 `-dev`，更新 CHANGELOG，执行 `release.sh`

### 冲突检测机制

双向同步通过**内容指纹（SHA-256）**防止静默覆盖：

- **upgrade.sh 方向**：每次升级成功后，记录下游 marker 上方内容的 hash 到 `.claude/.sync-state/sync-state.csv`。下次升级前比对，如果下游 marker 上方有本地修改：
  - 默认行为：备份 `.local` 副本后继续覆盖，最后汇总提示
  - `--conflict=preserve`：跳过冲突文件，保留本地修改
  - `--conflict=fail`：遇到冲突直接退出（CI 用）
  - `--force`：跳过冲突检测，强制覆盖
- **harvest.sh 方向**：收割时检测 `core/` 中是否有未发布的修改（通过 `core/.sync-state/harvest-state.csv`），标记 `[CORE-MODIFIED]` 并需逐文件确认

**向后兼容**：首次运行新版本 upgrade.sh 时，无 sync-state 文件，行为与旧版一致。升级后自动生成。

### harvest.sh 收割规则

- 只提取 marker 行及以上的内容（框架管理部分），marker 下方的项目自定义内容不会被收割
- 默认 dry-run 模式（只看 diff 不写入），`--apply` 才实际写入 `core/`
- `--include-new` 处理下游新增的、`core/` 中不存在的文件
- **收割前必须审查 diff**：确保去除项目特有引用（项目名、子项目路径、特定端口），确保内容是通用的

### 下游项目中验证过的功能如何沉淀

AI 在下游项目中改进了 marker 上方的框架内容（如优化了 Agent 行为、工作流规则等），且经过实际任务验证有效后，应建议用户执行收割流程：

```
**[框架沉淀建议]**
- 验证项目：your-project
- 涉及文件：.claude/rules/project_rule.md（marker 上方）
- 改进内容：<具体描述>
- 建议操作：在框架目录执行 `bash tools/harvest.sh ../your-project` 预览差异
```

## 通知系统

| 文件 | 职责 |
|------|------|
| `notify/notify-release.py` | 框架发版飞书通知（构建卡片消息 + 发送） |

## 框架维护规则

本仓库是框架源头，直接修改 `core/` 下的文件。以下规则仅适用于在本仓库工作时：

1. **保持 marker 完整**：每个被管理文件必须包含 marker 行，且位置正确（通常在文件末尾或内容分界处），不要删除或移动
2. **保持 Agent frontmatter**：修改 `core/agents/*.md` 时，保持 YAML frontmatter 结构（name、description、tools、model、skills）
3. **同步更新 MANIFEST**：`core/MANIFEST` 是框架管理文件的**唯一真相源**，`init-project.sh`、`upgrade.sh`、`harvest.sh` 都依赖它决定文件范围。维护者只需编辑这一个文件即可控制同步范围，具体规则：
   - **新增文件**：在 `core/` 下创建新文件后，在 MANIFEST 对应分类中添加一行（如 `commands/new-cmd.md level2 command`），init 和 upgrade 会自动推送
   - **删除文件**：从 `core/` 删除文件后，从 MANIFEST 移除对应行，upgrade 会将下游残留标记为孤儿文件并提示清理
   - **重命名文件**：先删旧行再加新行，同时在 `core/` 中重命名文件
   - **调整 level**：修改条目的 level 字段即可（如将 `level2` 改为 `level3`），init 会按新 level 筛选；upgrade 对所有 level 都推送，level 仅控制初始化
   - **不要修改的**：MANIFEST 只列框架管理的文件，项目特有文件（模板生成的 `rules/coding_backend.md`、`rules/coding_frontend_shared.md`、`setup-checklist.md`）不在 MANIFEST 中
   - MANIFEST 格式：`相对路径 level category`，skill 按目录名列（如 `skills/domain-ontology`），其他按文件路径列
4. **收割审查**：执行 `harvest.sh` 收割下游变更前，审查 diff 确认：
   - 去除项目特有引用（项目名、子项目路径、特定端口/地址）
   - 内容是通用的，可被其他下游项目复用
   - marker 上方结构完整（YAML frontmatter、章节标题等）
5. **版本管理**：修改 `core/` 后需更新 `tools/VERSION` 和 `CHANGELOG.md`，通过 `release.sh` 发版
6. **版本号格式**：`MAJOR.MINOR.PATCH-YYYYMMDD`（MAJOR=不兼容变更，MINOR=新增功能，PATCH=修复优化）
7. **dev 版本**：实验阶段使用 `X.Y.Z-dev.N-YYYYMMDD` 格式，`release.sh` 会拒绝发布 dev 版本
8. **Demo 先行**：修改 `core/` 后，必须先在 `demo/` 中执行 `bash ../tools/upgrade.sh` 升级并验证，确认无问题后再发版。demo 中的最佳实践可通过 `harvest.sh` 沉淀回 `core/`
9. **Demo 提交策略**：`demo/` 的 `.claude/` 变更是 `upgrade.sh` 从 `core/` 派生的结果，应与 `core/` 变更**同一次提交**，保持因果关系清晰。demo 业务代码（FastAPI/Vue 等非 `.claude/` 部分）可独立提交

## VitePress 文档站维护

项目文档基于 VitePress 搭建，源文件在 `docs/` 目录。修改 `core/`、`tools/` 等框架代码时，**必须同步维护对应文档**。

### 文档目录结构

```
docs/
├── index.md                   # 首页（一句话说清 + 路径选择 + 特点展示）
├── .vitepress/config.ts       # VitePress 配置（导航、侧边栏、搜索）
├── .vitepress/utils/generate-ref.ts  # 参考页自动生成脚本
├── package.json               # VitePress 依赖
│
├── getting-started/           # 入门指南（按用户旅程组织：认知→体验→上手→精通）
│   ├── what-is-sdd.md         #   认识 SDD（5 分钟，概念入门）
│   ├── quick-start.md         #   快速入门（15 分钟，跑通 Q0）
│   ├── tutorial.md            #   端到端教程（30 分钟，走完完整 Feature）
│   ├── concepts.md            #   概念详解（工作流全貌、七角色、Spec、Marker）
│   ├── glossary.md            #   术语速查表
│   ├── philosophy.md          #   设计理念
│   ├── tools.md               #   工具速查
│   ├── exercises.md           #   动手练习（3 个递进式练习）
│   ├── faq.md                 #   常见问题
│   └── troubleshooting.md     #   故障排查
│
├── integration/               # 项目接入（按场景拆分）
│   ├── new-project.md         #   新项目接入（含"新项目"定义）
│   ├── existing-project.md    #   已有项目日常使用
│   └── team-onboarding.md     #   团队接入指南
│
├── design/                    # 架构详述（手动维护）
│   ├── overview.md            #   一、框架概述
│   ├── architecture.md        #   二、架构设计
│   ├── marker.md              #   三、Stub Marker
│   ├── workflow.md            #   四、工作流体系
│   ├── integration.md         #   五、新项目接入
│   ├── maintenance.md         #   六、更新与维护
│   ├── collaboration.md       #   七、团队协作
│   ├── tools.md               #   八、核心工具参考
│   └── appendix.md            #   九、附录
│
└── reference/                 # 参考手册（自动生成 + 手动 changelog）
    ├── agents.md              #   [自动] 从 core/agents/*.md 生成
    ├── skills.md              #   [自动] 从 core/skills/*/SKILL.md 生成
    ├── commands.md            #   [自动] 从 core/commands/*.md 生成
    ├── rules.md               #   [自动] 从 core/rules/*.md 生成
    └── changelog.md           #   [自动] 从根目录 CHANGELOG.md 转换
```

### 源文件 → 文档映射

修改以下源文件时，必须同步更新对应文档：

| 修改了 | 必须同步更新 | 方式 |
|--------|-------------|------|
| `core/agents/*.md` | `reference/agents.md` | 重新生成：`cd docs && npm run docs:generate-ref` |
| `core/skills/*/SKILL.md` | `reference/skills.md` | 重新生成：`cd docs && npm run docs:generate-ref` |
| `core/commands/*.md` | `reference/commands.md` | 重新生成：`cd docs && npm run docs:generate-ref` |
| `core/rules/*.md` | `reference/rules.md` | 重新生成：`cd docs && npm run docs:generate-ref` |
| `CHANGELOG.md` | `reference/changelog.md` | 重新生成：`cd docs && npm run docs:generate-ref` |
| `core/agents/*.md` 行为变更 | `design/workflow.md` | 手动更新工作流描述 |
| `core/rules/project_rule.md` | `design/workflow.md` | 手动更新工作流规则章节 |
| `core/rules/merge_checklist.md` | `design/workflow.md` | 手动更新合并检查章节 |
| `tools/upgrade.sh` 参数/行为变更 | `design/tools.md` §8.3 | 手动更新工具文档 |
| `tools/harvest.sh` 参数/行为变更 | `design/tools.md` §8.4 | 手动更新工具文档 |
| `tools/VERSION` 版本格式变更 | `design/maintenance.md` §6.3 | 手动更新版本命名规则 |
| `templates/` 模板变更 | `design/integration.md` | 手动更新接入指南 |
| 新增/删除 Agent 角色 | `getting-started/concepts.md` + `design/overview.md` + `core/MANIFEST` | 手动更新七角色描述 + 更新 MANIFEST |
| 新增/删除 Skill | `design/architecture.md` + `core/MANIFEST` | 更新被管理文件清单 + 更新 MANIFEST |
| `core/MANIFEST` 变更 | `design/architecture.md` §2.2 | 手动更新被管理文件清单描述 |
| 新增/删除 Skill | `design/architecture.md` §2.2 被管理文件清单 | 手动更新列表 |

### 生成参考页

`reference/` 下的 agents、skills、commands、rules、changelog 页面由脚本自动生成。当 `core/` 或 `CHANGELOG.md` 变更时：

```bash
cd docs && npm run docs:generate-ref
```

脚本会从 `core/` 解析 YAML frontmatter 和内容摘要，自动覆盖 `reference/` 下的 5 个文件。**不要手动编辑这 5 个文件**，下次生成会被覆盖。

### 手动维护的文档

`guide/` 和 `design/` 下的文档需要手动更新。修改原则：

1. **内容准确性**：文档描述必须与代码实际行为一致
2. **链接正确性**：使用 VitePress 相对路径（如 `/guide/quick-start`、`/design/workflow`），不要用 `.md` 后缀
3. **frontmatter 完整**：每个文件包含 `title`、`description`、`prev`、`next`
4. **中文标题 + 英文文件名**：页面标题用中文（frontmatter title），URL 用英文（文件名）

### 验证文档

```bash
# 启动本地预览
cd docs && npm run docs:dev

# 构建验证（检查是否有 Vue 解析错误）
cd docs && npm run docs:build

# 重新生成参考页后构建
cd docs && npm run docs:generate-ref && npm run docs:build
```

> **注意**：修改 `theme/index.ts`、`theme/style.css` 或 `package.json` 新增依赖后，Vite HMR 无法自动生效，必须**重启 dev server**（Ctrl+C 后重新 `npm run docs:dev`）。

### 文档部署

`docs/deploy.sh` 负责同步文件到远程服务器并触发构建。修改 `docs/`、`core/`、`CHANGELOG.md` 后，**主动提醒用户是否需要部署**。

```bash
# 预览要同步的文件
bash docs/deploy.sh

# 同步 + 远程构建（需用户确认）
bash docs/deploy.sh --confirm

# 只触发远程构建，不同步文件
bash docs/deploy.sh --build-only
```

### config.ts 维护

`docs/.vitepress/config.ts` 包含导航栏和侧边栏配置。当文档结构变更时（新增/删除/重命名页面），必须同步更新 config.ts 中的：

- **nav**：顶部导航链接
- **sidebar**：侧边栏分组和链接（文件路径对应页面 URL）

### GitLab Pages 部署

- CI 配置：`.gitlab-ci.yml`，仅 `develop` 分支触发
- 构建输出：`public/`（GitLab Pages 要求）
- `base` 路径：部署时需改为 `'/h-codeflow-framework/'`，本地预览用 `'/'`
