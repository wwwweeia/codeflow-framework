# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目定位

codeflow-framework 是一个**元框架项目**（不是应用项目），为多个业务项目提供统一的 Spec-Driven Development (SDD) 工作流规范、Agent 定义、质量检查规则和知识库。多个下游业务项目通过 `upgrade.sh` 从本仓库同步框架文件。

## 核心架构

**两层分离**：
- **编排层**（本仓库 `core/`）：通用的工作流定义，版本化管理
- **执行层**（下游项目 `.claude/`）：项目特有的业务规则和知识库

**Stub Marker 机制**：被管理文件包含 `<!-- codeflow-framework:core vX.X.X-YYYYMMDD — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->` 标记。`upgrade.sh` 更新 marker 上方的框架内容，保留 marker 下方的项目自定义内容。修改 `core/` 下的文件时，必须确保 marker 存在且位置正确。

## 关键文件与职责

| 路径 | 职责 | 修改影响 |
|------|------|---------|
| `core/MANIFEST` | 框架管理文件清单（唯一真相源） | init/upgrade/harvest 三个脚本的文件范围 |
| `core/agents/*.md` | 7 个 Agent 定义（PM/Arch/Dev/FE/QA/Prototype/E2E） | 所有下游项目的 Agent 行为 |
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
sh ../codeflow-framework/templates/init-project.sh . "Project Name"

# 升级下游项目的框架文件（在目标项目目录执行，自动 git pull 框架最新代码）
bash ../codeflow-framework/tools/upgrade.sh

# 升级前预览哪些文件会变化（不写入）
bash ../codeflow-framework/tools/upgrade.sh --dry-run

# 升级前预览并显示详细 diff（不写入）
bash ../codeflow-framework/tools/upgrade.sh --dry-run --diff

# 正式升级并显示 diff
bash ../codeflow-framework/tools/upgrade.sh --diff

# 跳过冲突检测，强制覆盖
bash ../codeflow-framework/tools/upgrade.sh --force

# 跳过有冲突的文件（保留本地修改）
bash ../codeflow-framework/tools/upgrade.sh --conflict=preserve

# 有冲突时直接退出（CI 用）
bash ../codeflow-framework/tools/upgrade.sh --conflict=fail

# 升级时指定框架分支（用于测试实验分支）
FRAMEWORK_BRANCH=exp/xxx bash ../codeflow-framework/tools/upgrade.sh

# 从下游项目收割验证过的变更回 core/（在框架目录执行）
sh tools/harvest.sh ../your-project              # 预览差异
sh tools/harvest.sh --apply ../your-project      # 实际写入

# 发版预览（dry-run，不发送通知、不 push）
sh tools/release.sh

# 正式发版（创建 tag + 推送 + 可选通知）
sh tools/release.sh --confirm

# 在 demo 中验证框架变更（发版前必做）
cd demo && bash ../tools/upgrade.sh --diff    # 升级并查看变更

# 重置 demo 到初始状态（用于反复演示或验证）
cd demo && sh reset-demo.sh --base
```

```bash
# 环境诊断（检查框架基础设施、项目构建工具、可选集成、E2E 环境）
bash tools/doctor.sh              # 完整检查
bash tools/doctor.sh --quiet      # 只显示有问题的项
bash tools/doctor.sh --json       # JSON 格式输出（CI 集成）
```

## 发版流程

当框架内容变更需要发布新版本时，**必须按以下步骤执行**：

1. **修改内容**：在 `core/`、`tools/`、`templates/` 等目录完成改动
2. **Demo 验证**：在 `demo/` 中执行 `cd demo && bash ../tools/upgrade.sh`，确认变更效果符合预期（见下方"Demo 验证规则"）
3. **更新版本号**：修改 `tools/VERSION`（格式：`MAJOR.MINOR.PATCH-YYYYMMDD`）
4. **更新变更日志**：在 `CHANGELOG.md` 顶部添加新版本记录，格式参考已有条目
5. **提交所有改动**：`git add` + `git commit`，确保工作区干净
6. **预览发版**：执行 `sh tools/release.sh`，检查通知内容是否正确
7. **正式发版**：执行 `sh tools/release.sh --confirm`，创建 git tag 并推送（可选发送通知）

**`release.sh` 会自动校验**：VERSION 与 CHANGELOG 一致性、dev 版本拦截。任何校验失败都会阻止发版并提示原因。通知功能需通过 `NOTIFY_SCRIPT` 环境变量配置。

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

### Dev 版本约定（试验场模式）

实验阶段可使用 dev 版本号，格式：`MAJOR.MINOR.PATCH-dev.N-YYYYMMDD`（如 `1.6.0-dev.1-20260418`）。

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
2. **推送到试验项目**：在 your-project 执行 `FRAMEWORK_BRANCH=exp/xxx bash ../codeflow-framework/tools/upgrade.sh`
3. **验证迭代**：在真实任务中使用，发现问题可直接修改 marker 上方内容
4. **收割回框架**：在框架目录执行 `sh tools/harvest.sh ../your-project`（先 dry-run 看 diff），确认后 `--apply`
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
- 建议操作：在框架目录执行 `sh tools/harvest.sh ../your-project` 预览差异
```

## 通知系统（可选）

`release.sh` 支持通过环境变量 `NOTIFY_SCRIPT` 指定通知脚本路径。配置后，发版时自动调用该脚本发送通知。未配置则跳过通知，仅创建 tag 和推送。

## 框架维护规则

本仓库是框架源头，直接修改 `core/` 下的文件。以下规则仅适用于在本仓库工作时：

1. **保持 marker 完整**：每个被管理文件必须包含 marker 行，且位置正确（通常在文件末尾或内容分界处），不要删除或移动
2. **保持 Agent frontmatter**：修改 `core/agents/*.md` 时，保持 YAML frontmatter 结构（name、description、tools、model）
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
├── index.md                   # 首页（Hero + Feature Cards）
├── .vitepress/config.ts       # VitePress 配置（导航、侧边栏、搜索）
├── .vitepress/utils/generate-ref.ts  # 参考页自动生成脚本
├── package.json               # VitePress 依赖
│
├── guide/                     # 入门指南（手动维护）
│   ├── quick-start.md         #   ← 原 01-快速入门.md
│   ├── concepts.md            #   ← 原 02-概念速查表.md
│   ├── onboarding.md          #   ← 原 04-项目接入检查清单.md
│   ├── faq.md                 #   ← 原 05-常见问题.md
│   ├── troubleshooting.md     #   ← 原 06-故障排查指南.md
│   └── exercises.md           #   ← 原 07-动手练习手册.md
│
├── design/                    # 架构详述（手动维护，拆自原 03-框架设计文档.md）
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
| 新增/删除 Agent 角色 | `guide/concepts.md` + `design/overview.md` + `core/MANIFEST` | 手动更新七角色描述 + 更新 MANIFEST |
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

### config.ts 维护

`docs/.vitepress/config.ts` 包含导航栏和侧边栏配置。当文档结构变更时（新增/删除/重命名页面），必须同步更新 config.ts 中的：

- **nav**：顶部导航链接
- **sidebar**：侧边栏分组和链接（文件路径对应页面 URL）

### GitHub Pages 部署

- 可通过 GitHub Actions 自动部署文档站
- 构建输出：`public/`（或 `docs/.vitepress/dist/`）
- `base` 路径：部署时需改为 `'/codeflow-framework/'`，本地预览用 `'/'`
