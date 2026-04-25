# CHANGELOG

> codeflow-framework 版本历史与更新日志

## [2.1.0-20260423] - 2026-04-23

### 新增

**core/MANIFEST 清单机制**
- 引入 `core/MANIFEST` 作为框架管理文件的唯一真相源，`init-project.sh`、`upgrade.sh`、`harvest.sh` 三个脚本统一从 MANIFEST 读取文件范围
- 支持动态新增/删除/重命名文件，无需修改脚本逻辑
- MANIFEST 格式：`相对路径 level category`，level 控制初始化范围，upgrade 对所有 level 都推送

**/init-setup 命令（初始化配置驱动）**
- 初始化后生成可执行 Task 清单，用户通过 `/init-setup` 命令逐步完成项目配置
- 支持 `setup-checklist.md` 模板，自动检测并跳过已完成的步骤

**E2E 环境变量文件化管理**
- 使用 `.env` 文件替代手动 export 管理环境变量
- 新增 `templates/e2e/.env.example` 模板

**知识体系集成到 Agent 工作流**
- dev-agent: Research 阶段增加知识按需加载（knowledge-index.md → cookbook/pattern）
- fe-agent: Research 阶段增加知识按需加载，Execute 阶段增加知识参考
- qa-agent: Load Specs 阶段增加知识覆盖度检查，三种 Review 模式均增加知识索引参考
- arch-agent: 后端/前端模式加载上下文增加 knowledge-index 引用，工作流新增知识对齐步骤
- project_rule.md: 主会话职责增加知识体系透传
- knowledge-protocol.md: 新增知识加载协议，定义目录约定、加载优先级、各角色行为、沉淀触发规则

**知识索引模板**
- 新增 `templates/subproject/frontend/context/knowledge-index.md.template`
- 新增 `templates/subproject/backend/context/knowledge-index.md.template`

### 优化

**规则 ROI 精简 Phase 1**
- 去冗余：移除 project-memory 和 scenarios 目录，修复 init 脚本变量解析
- 提交通用规则：统一知识加载协议，消除 Agent 间的重复加载逻辑

**P0/P1 改进**
- 规则精简：压缩冗余描述，提升 Agent 指令密度
- Agent 自检：各 Agent 增加自我校验步骤
- 渐进式入门：优化新项目接入体验
- 遵从度测试：新增 compliance-tests.md 验证规则可执行性

**前端 Skill 规范对齐**
- 消除 Store Action 命名冲突
- 补充性能指南相关内容

**Demo 提交策略**
- 新增 Demo 提交策略规则：`core/` 变更与 `demo/.claude/` 同一次提交

### 修复

- 兼容 Windows Git Bash 环境：shasum 自动检测 + 防 CRLF + 文档补充
- 补全 Agent 缺失的 Skill 关联，清理无使用的 Skill
- 补全 init-project.sh 缺失的 commands 级别配置
- 修正参考页 outline frontmatter 格式，恢复 details 内标题层级
- Rules 参考页摘要提取跳过标题行，避免子标题泄漏到 TOC
- Reference 页面右侧 TOC 只展示 H2 一级标题

### 文档

- 新增 v2.0 复盘文档，resources 栏目"框架复盘"升级为"技术随笔"
- 新增规则 ROI 审计报告及第三方审查意见
- 新增新项目接入实践案例（AI Crawlers 初始化全流程）
- 新增 lark-cli 指南，重组学习资源侧边栏分类
- 补充复盘文档 Meta-review 章节，修复侧边栏链接
- 新增文档站部署指南，补充 v2.0.0 changelog
- compliance-tests.md: 新增 T-AGENT-05（Agent 应按需加载知识体系）
- workflow.md: 工作流 A/B/C 流程描述补充知识加载步骤

### Demo (AI Prompt Lab)

- 新增 Prompt 列表管理页面（工作流 B 演示）
- 恢复并优化 4 个演示命令，更新 README 框架验证章节
- 添加 Agent 统计 API 的 QA 审查和自测证据

### 兼容性

- 无破坏性变更：MANIFEST 机制向后兼容，无 MANIFEST 时脚本行为与旧版一致
- 知识加载为可选行为：没有 knowledge-index.md 的项目不受影响
- 模板文件仅影响新初始化的项目，已存在的项目需手动创建

## [2.0.0-20260422] - 2026-04-22

### 变更

**文档体系重构（MAJOR）**
- 将 `docs/` 从散落的中文编号 Markdown（01~07-*.md）迁移为结构化 VitePress 文档站
- 文档路径全部变更：旧路径（如 `docs/01-快速入门.md`）不再存在，新路径按分类组织
- 下游项目中引用旧文档路径的脚本或链接需要更新

### 新增

**VitePress 文档站**
- 初始化 VitePress 项目（v1.6.4）：导航栏、侧边栏、本地搜索、中文界面
- 文档分为 guide/（入门指南 8 篇）、design/（架构详述 9 篇）、cases/（实战案例 3 篇）、resources/（学习资源 10 篇）、reference/（参考手册 5 篇）

**参考页自动生成与折叠查看**
- 新增 `docs/.vitepress/utils/generate-ref.ts`：从 `core/` 自动生成 agents/skills/commands/rules/changelog 五个参考页
- 每个条目展示摘要 + VitePress `:::details` 折叠块，可展开查看完整源文件定义
- 自动截断 marker 行、降级标题避免 TOC 污染、精确转义代码块外 HTML 标签

**HMR 热更新**
- 新增 `hmrRefPages()` Vite 插件：dev 模式自动监听 `core/` 和 `CHANGELOG.md` 变更
- 文件变化时自动重新生成参考页，浏览器热更新

**部署配置**
- 新增 `.github/workflows/`：develop 分支自动构建并部署 GitHub Pages
- 新增 `deploy/` 目录：Docker 多阶段构建、docker-compose、Nginx 配置、SSL 证书脚本

**Demo AI Prompt Lab**
- 新增 AI Prompt Lab 演示项目（`demo/`），提供最小可运行的 SDD 工作流参考实现

**环境诊断增强**
- `tools/doctor.sh` 新增 E2E 测试环境检查

### 优化

**Demo 验证规则简化**
- 简化 Demo 验证规则，聚焦文件同步正确性
- 在 CLAUDE.md 中建立 demo 作为框架首发验证环境的规则

---

## [1.10.0-20260422] - 2026-04-22

### 新增

**E2E Runner Agent**
- 新增 `e2e-runner.md`：定义 E2E 测试 Agent 的触发时机、工作流集成规则和产出物规范
- 统一 Agent 角色数量描述为 7 个（PM/Arch/Dev/FE/QA/Prototype/E2E）

**E2E 测试脚手架**
- 新增 E2E 测试脚手架模板（`templates/e2e/`），标准化 E2E 测试项目结构
- 增强 skill/agent 路径约定，确保测试脚本可正确定位框架组件

**Jira/Confluence MCP 集成**
- 集成 Jira MCP 和 Confluence MCP，支持项目级配置
- 实现需求/文档与代码工作流的全链路联动

**环境诊断工具**
- 新增 `tools/doctor.sh`：一键诊断框架运行环境（Node、Claude Code、Git 等），快速定位配置问题

**双向同步冲突检测**
- upgrade.sh 新增基于内容指纹（SHA-256）的冲突检测，防止 marker 上方内容被静默覆盖
- 支持三种冲突策略：默认备份覆盖、`--conflict=preserve` 保留本地、`--conflict=fail` 直接退出

### 优化

**Spec 定位统一**
- 统一 `03 Spec` 为执行日志定位，拆分 backend/frontend 命名，提升多项目场景可读性

---

## [1.9.0-20260421] - 2026-04-21

### 新增

**Framework Feedback 技能**
- 新增 `framework-feedback` 技能（`core/skills/framework-feedback/`）：下游项目可向框架团队提交结构化反馈
- 支持 4 种反馈类型：Bug、Feature Request、Improvement、Question
- 自动收集项目名、框架版本等上下文信息，减少用户填写负担
- 提交前展示预览，用户确认后才发送
- 通过通知发送给框架维护团队
- 修正仓库路径并优化通知卡片描述渲染

**Using Git Worktrees 技能**
- 新增 `using-git-worktrees` 技能（`core/skills/using-git-worktrees/`）：支持在隔离的 git worktree 中创建工作区
- 自动创建临时分支、完成任务后清理 worktree

**Harvest 收割安全网**
- 新增版本检查：harvest 前比对下游项目与框架的 marker 版本，避免覆盖更新版本
- 新增 `--marker-only` 过滤：只收割有 marker 的文件，跳过无 marker 文件
- 新增覆盖风险安全网：检测并警告可能导致下游自定义内容丢失的操作

## [1.8.0-20260421] - 2026-04-21

### 新增

**Prototype Agent（前端原型设计师）**
- 新增 `prototype-agent.md`：根据 PM Spec 产出可运行的 Vue 原型页面，用于需求确认
- 原型阶段由"可跳过"改为"需用户指示"，确保用户主动触发

**Intake 需求确认硬约束**
- Intake 三问完成后，主对话必须向用户呈现需求要点摘要 + 路由判断，等待用户明确同意后才可路由启动 Agent

**路径校验规则**
- 所有 Agent（PM/Arch/Dev/FE/QA/Prototype）新增路径校验：写入文件前校验路径与项目约定一致性，不一致时使用项目约定路径

**主对话派发约束**
- 派发子 Agent 时只指定产出物名称，不硬编码文件路径，由子 Agent 按项目约定确定

**测试计划闭环（Part E + 04_test_plan.md）**
- 引入测试计划闭环：Arch 产出 Part E（测试场景），Dev/FE 产出 04_test_plan.md，QA 审计 04

**`/release-core` 发版命令**
- 新增标准化发版 slash command，覆盖完整流程：版本号确认 → CHANGELOG 更新 → Git 提交 → 通知预览 → 正式发送

### 优化

**工作流文档精简**
- 移除 Agent 冗余章节，减少维护负担

**命令体系重构（`commands/`）**
- 新增双向同步命令和通用工具命令，完善框架命令覆盖范围

**脚本调用统一**
- `upgrade-core` 命令中 `sh` 统一改为 `bash`，与其他脚本调用方式保持一致

---

## [1.7.0-20260420] - 2026-04-20

### 新增

**全栈并行执行工作流（Worktrees）**
- dev-agent / fe-agent 新增工作流 C（全栈并行）：使用 `using-git-worktrees` skill 创建隔离工作区，Dev 和 FE 可同时开工，不再串行等待
- project_rule.md 更新全栈工作流：@dev-agent 与 @fe-agent 并行启动，各自独立 worktree 分支（feature/<name>-backend / feature/<name>-frontend），完成后由主会话合并并清理 worktree

**两阶段自查（Self-Test 升级）**
- dev-agent：自测拆分为「合规检查（Compliance）」+「质量检查（Quality）」两阶段，合规对标 02 Spec 逐项核对，质量要求 mvn test 全通过、无废弃代码
- fe-agent：同步两阶段自查，合规对标路由/组件/Store/API Contract，质量要求 lint 通过、权限控制到位

**TDD 执行节奏（后端）**
- dev-agent 新增 RED-GREEN-REFACTOR 子任务循环：先写失败测试 → 最小实现通过 → 重构优化，实时追加到 03_implementation.md

### 优化

**fix 命令根因分析结构化**
- `commands/fix.md` 定位阶段升级为 4 阶段：复现确认 → 边界缩小 → 根因假设（2-3 候选）→ 修复方案确认
- 新增 Proof of Fix 输出格式：原路径验证 + 回归路径 + 剩余风险

---

## [1.6.0-20260417] - 2026-04-17

### 变更（Breaking Change）

**工作流重构：取消 Dev/FE 中间审批，改为直接执行**
- 旧模式：Dev/FE 先出 Plan（03_implementation.md）→ 用户 Approve → 建分支 Execute
- 新模式：01（PM）+ 02（Arch）经用户审批后，Dev/FE 直接建分支执行，03 变为执行日志
- `02_interface.md` 废弃，其内容（API Contract、前端数据映射）合入 Arch 产出的 `02_technical_design.md`
- Spec 路径格式：`YYYY-MM-DD_hh-mm_<name>/` → `feature-<name>/`

### 新增

**新增 Skill**
- `core/skills/frontend-conventions/SKILL.md` — 前端共享惯例知识库（唯一权威源），定义路由/Store/权限/API/组件规范，Arch/FE/Prototype 三角色共同引用
- `core/skills/frontend-arch-design/SKILL.md` — 前端架构设计产出规范（Part B），定义 B-1~B-7 各节的产出格式与 Checklist

**新增知识文档**
- `core/codemap/domains/HOWTO-generate-codemap.md` — 如何生成高质量 Domain Codemap（经验沉淀）
- `core/context/codemap-vs-specs.md` — Codemap vs Specs 职责对比与使用指南

**Spec 产出物定义表**
- project_rule.md 新增 Spec 产出物定义表（01/02/03 的产出者、定位、审批门控）

**Prototype Agent 工作流**
- 工作流 B（纯前端）和工作流 C（全栈）新增 Prototype 原型阶段

**主会话职责明确化**
- project_rule.md 新增 §7 主会话职责章节，明确调度中心在全流程中的角色

### 优化

**Agent 行为升级**
- arch-agent：新增"流程定位"和"设计即契约"原则，skills 扩充（backend-rules/api-reviewer/sql-checker/spec-templates/frontend-conventions/frontend-arch-design）
- dev-agent/fe-agent：改为"Spec is Truth, Design is Guide"双文档模型，新增异常处理章节
- pm-agent：只产出 01_requirement.md，前端模式新增 §1-§7 字段级精度结构
- qa-agent：审查标准改为对标 01 + 02_technical_design.md，新增审查文件依赖清单

**知识文档细化（来自 your-project 试验场验证）**
- `codemap-vs-specs.md`：`03_implementation.md` 拆分为 `03_impl_backend.md` + `03_impl_frontend.md`（BE/FE 分开产出），"四轴"→"五轴验收"，新增 spec-template.md 引用
- `HOWTO-generate-codemap.md`：3.2/3.4 小节补充经验提示，3.4 增加 `convertToVO` / `buildVO` 作为 VO 组装方法的参考

**运行验证详细化**
- project_rule.md §8 细化后端 API 自动验证和前端手工验证流程，新增演进路线

**Deploy 通用化**
- project_rule.md §9 改为通用构建脚本模板，支持 Watchtower 等自动化部署工具

### 清理

- 移除所有 Skill/Rule 文件中 marker 下方的空占位模板（"项目特定xxx"段落），这些内容应由 init-project.sh 模板提供
- 移除 fe-agent 中已废弃的 `frontend-api-integration` skill 引用

---

## [1.5.0-20260417] - 2026-04-17

### 变更（Breaking Change）

**仓库迁移与重命名**
- 仓库名称：`codeflow-framework` → `codeflow-framework`
- 仓库地址：`github.com/wwwweeia/ai.kg/ai/codeflow-framework` → `github.com/wwwweeia/codeflow-framework`
- 所有 Stub Marker 关键词同步更新：`codeflow-framework:core` → `codeflow-framework:core`
- 所有脚本、文档、模板中的路径引用同步更新

### 下游项目升级指南

> ⚠️ **本次为不兼容变更**，下游项目需手动执行以下步骤：

1. 克隆新仓库到与项目同级目录：`git clone git@github.com:wwwweeia/codeflow-framework.git`
2. 将项目 `.claude/` 下所有 `.md` 文件中的 marker 关键词替换：
   ```bash
   find .claude -name "*.md" -exec sed -i '' 's/codeflow-framework/codeflow-framework/g' {} +
   ```
3. 更新项目 `CLAUDE.md` 中对框架目录的引用路径
4. 执行升级：`sh ../codeflow-framework/tools/upgrade.sh`
5. 提交变更：`git commit -am "chore: migrate to codeflow-framework v1.5.0"`

---

## [1.4.0-20260416] - 2026-04-16

### 新增

**后端开发知识库 Skill**（`core/skills/backend-rules/`）
- `SKILL.md` — 核心索引与速查，采用中部 marker 模式（框架提供结构定义，项目填充具体代码）
- `templates/controller-template.md` — 标准 REST Controller + DTO/Query/VO 四件套骨架
- `templates/service-template.md` — Service 接口与实现骨架
- `templates/xml-mapper-template.md` — Mapper 接口 + XML + 批量/联表模板
- `references/orm-config.md` — ORM 配置参考骨架（分页/逻辑删除/自动填充）

### 修复

- `dev-agent.md` 的 `skills` frontmatter 引用了不存在的 `backend-rules` 技能，现已补全对应 Skill 目录
- `framework_protection.md` 注册 `backend-rules` 到框架管理文件清单

### 清理

- 删除未被任何脚本引用的死文件 `templates/backend-rules.md.template`（内容已被新 Skill 覆盖）
- 清理 `README.md` 和 `docs/codeflow-framework-design.md` 中对该文件的引用

---

## [1.3.1-20260416] - 2026-04-16

### 修复

- 补全 3 个前端 Skill（frontend-api-integration / frontend-create-component / frontend-create-module）缺失的 stub marker，确保 `upgrade.sh` 能正确管理这些文件

---

## [1.3.0-20260416] - 2026-04-16

### 新增

**前端开发 Skill 三件套**（从 your-project 项目验证后上提）
- `core/skills/frontend-api-integration/SKILL.md` — Vuex Store Action + axios 接口对接规范
- `core/skills/frontend-create-component/SKILL.md` — Vue 2 组件创建模板与命名/样式/通信规则
- `core/skills/frontend-create-module/SKILL.md` — 业务模块脚手架（路由 + Store + 列表页标准套件）

**分页接口契约标准化**
- `spec-templates/SKILL.md` 新增列表接口标准响应结构（`list` / `pageNumber` / `pageSize` / `total`），跨项目统一

### 优化

**前端共享编码规范全面升级**（`templates/coding_frontend_shared.md.template`）
- 新增 §1 命名规范（时间字段、组件、Store、权限码）
- 新增 §2 样式规范（BEM、深度选择器、页面白底、微前端隔离）
- 新增 §3 错误处理（禁止重复弹错误、全局拦截器约定）
- 新增 §4 接口响应契约（分页结构、单对象、前端取值规范）
- 新增 §5 表单与表格（tableConfig.uri 模式、Dialog 重置）
- 新增 §6 组件通信（props/emit/Vuex，禁止 $parent/$children）
- 新增 §7 技术栈约束（Vue 2 / Options API / Element UI）

---

## [1.2.1-20260416] - 2026-04-16

### 🐛 修复

- 补全 `sdd-riper-one-light` 技能缺失的文档和示例（README、agents、examples、references 共 9 个文件）

---

## [1.2.0-20260416] - 2026-04-16

### ✨ 新增

**子项目 .claude 脚手架自动初始化**
- `templates/init-subproject.sh` — 独立子项目初始化脚本，支持前端 (fe) / 后端 (be) 两种类型
- `templates/subproject/frontend/` — 前端子项目模板（组件清单、路由、状态管理、编码规则、协作记忆）
- `templates/subproject/backend/` — 后端子项目模板（技术栈、API 约定、场景索引、编码规则、协作记忆）
- `init-project.sh` 增加子项目自动检测：扫描 `package.json`（前端）/ `pom.xml`（后端），自动创建子项目 `.claude/` 脚手架
- `init-project.sh` 初始化时将 `coding_frontend_shared.md` 和 `coding_backend.md` 复制到根 `.claude/rules/` 作为共享规范
- 子项目规则采用轻量引用模式，指向根目录共享规范，仅存放子项目特有补充
- context 模板内嵌 AI 行为指令，Agent 首次使用时可自动扫描项目并填充内容
- 幂等设计：重复执行时自动跳过已初始化的子项目

### 📝 文档

- 方案设计文档新增子项目执行层结构（2.4）、子项目自动检测规则、真实初始化日志示例
- 新增 `init-subproject.sh` 工具参考（9.2）
- 更新接入验证清单、操作示例

---

## [1.1.2-20260416] - 2026-04-16

### 🔧 优化

- `upgrade.sh` 增加内容比较，仅更新实际有变化的文件，跳过未变化文件
- 升级日志区分已更新/已跳过文件数量，输出更清晰
- 备份目录按需创建，无文件变更时不产生空备份

---

## [1.1.1-20260416] - 2026-04-16

### 🐛 修复

- 修正 `dev-agent.md` 和 `fe-agent.md` 中 merge_checklist 引用路径（`.claude/context/` → `.claude/rules/`）

---

## [1.1.0-20260416] - 2026-04-16

### ✨ 新增

**发版通知系统**
- `tools/release.sh` — 一键发版脚本
  - 自动校验 VERSION 与 CHANGELOG 一致性
  - 校验 git 工作区干净、tag 不重复
  - 支持 dry-run 预览和 `--confirm` 正式发版
  - 自动 git tag + push + 可选通知
- `notify/notify-release.py` — 发版通知脚本
  - 构建互动卡片消息（版本号、更新内容、升级命令）
  - 支持命令行参数和 stdin JSON 两种调用方式

### 📝 文档

- CLAUDE.md 新增发版流程说明和通知系统文档

---

## [1.0.0-20260416] - 2026-04-16

### ✨ 新增

**框架基础设施**
- 6 个 Agent 定义文件（PM / Architect / Dev / FE / QA / Prototype）
  - 每个 Agent 包含职责定义、行为约束、工作流
  - 支持后端、前端、全栈三种模式
  
- 通用工作流规则（project_rule.md）
  - 四种工作流：Q0 轻量模式、工作流 A（纯后端）、工作流 B（纯前端）、工作流 C（前后端联动）
  - 四个路由判定规则（Q0 / Q1 / Q2 / Q3）
  - 运行验证、Deploy 阶段、用户直接请求部署的完整流程

- 合并检查清单（merge_checklist.md）
  - 通用检查（需求、测试、代码质量）
  - 后端专项检查（SQL、分页、安全）
  - 前端专项检查（样式、交互）
  - 全栈专项检查（API 契约）
  - 合并流程与检查表

**Skill 文件**
- domain-ontology/SKILL.md — 业务词典与领域建模骨架
- sdd-riper-one-light/SKILL.md — 轻量 spec-driven 协议
- sql-checker/SKILL.md — SQL 审查规则
- api-reviewer/SKILL.md — REST API 设计规范
- spec-templates/SKILL.md — Spec 文档模板与编写规范

**工具脚本**
- `tools/upgrade.sh` — 框架升级脚本
  - 自动扫描并更新项目中的被管理文件
  - 通过 marker 机制，保留项目自定义内容
  - 自动备份和日志记录
  
- `templates/init-project.sh` — 项目初始化脚本
  - 创建 `.claude/` 完整目录结构
  - 复制框架被管理文件
  - 复制并调整项目模板文件
  - 输出初始化清单和下一步指导

**项目模板文件**
- `CLAUDE.md.template` — 项目协作指南
- `coding_backend.md.template` — 后端编码规范
- `coding_frontend_shared.md.template` — 前端编码规范
- `domain-ontology.md.template` — 业务词典模板
- `backend-rules.md.template` — 后端架构与规则
- `memory.md.template` — 项目协作记忆索引

**文档**
- `README.md` — 框架概览与快速开始
- `MIGRATION.md` — 现有项目迁移指南
- `CHANGELOG.md` — 本文件

### 🏗️ 架构特性

- **两层分离**：编排层（codeflow-framework/core/）+ 执行层（各项目/.claude/）
- **Stub Marker 管理**：通过 marker（`<!-- codeflow-framework:core vX.X.X — ... -->`）实现自动管理与保留项目自定义
- **五角色工作流**：PM → Architect → Dev/FE → QA ← 主会话（调度）
- **多工作流支持**：Q0 轻量、A 纯后端、B 纯前端、C 全栈联动
- **无依赖分布**：框架作为同级项目，通过相对路径脚本实现零依赖集成

### 📋 核心规则

- **三铁律**：No Spec, No Code / Spec is Truth / No Approval, No Execute
- **YAGNI 原则**：最小改动，避免过度设计
- **Intake 触发**：新增/修改/删除功能时，主对话必须先做 Intake 三问
- **智能路由**：根据需求范围自动路由到合适的工作流
- **证据驱动完成**：完成应由验证结果证明，而非模型自行宣布

### 🔧 工具与脚本

- `tools/upgrade.sh` — 框架升级与同步
- `templates/init-project.sh` — 项目初始化
- 版本化跟踪：VERSION 文件记录当前框架版本

---

## 未来计划

- [ ] **Phase 2**：your-project 项目集成与验证
- [ ] **Phase 3**：框架文档补充与 example 编写
- [ ] **Phase 4**：脚本测试与容错能力增强
- [ ] **Phase 5**：团队培训与推广

---

## 版本对应表

| 版本 | 发布日期 | 框架年份 | 主要变更 |
|------|---------|--------|--------|
| 1.6.0-20260417 | 2026-04-17 | 2026 | 工作流重构（直接执行模型）+ 新增 Skill + Prototype 工作流 |
| 1.5.0-20260417 | 2026-04-17 | 2026 | 仓库迁移重命名 |
| 1.4.0-20260416 | 2026-04-16 | 2026 | 后端开发知识库 Skill |
| 1.3.0-20260416 | 2026-04-16 | 2026 | 前端 Skill 三件套 + 编码规范全面升级 |
| 1.2.1-20260416 | 2026-04-16 | 2026 | 补全 sdd-riper-one-light 文档和示例 |
| 1.2.0-20260416 | 2026-04-16 | 2026 | 子项目脚手架自动初始化 |
| 1.1.1-20260416 | 2026-04-16 | 2026 | 修正 Agent 中 merge_checklist 引用路径 |
| 1.1.0-20260416 | 2026-04-16 | 2026 | 发版通知系统 |
| 1.0.0-20260416 | 2026-04-16 | 2026 | 初始版本，核心框架完成 |

---

## 命名规则

- **版本格式**：`MAJOR.MINOR.PATCH-YYYYMMDD`
- **例**：`1.0.0-20260416` 表示 2026 年 4 月 16 日发布的 1.0.0 版本
- **发布频率**：2-4 周一次，或根据需求临时发布

---

**当前版本**：1.6.0-20260417
**Maintainer**: your-name
**更新日期**：2026-04-17

