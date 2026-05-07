---
title: Commands 参考
description: 框架提供的 8 个自定义命令
outline:
  level: [2, 2]
---

# Commands 参考

> 在 Claude Code 中通过 `/命令名` 触发。命令定义在 `core/commands/` 目录下，
> 通过 `upgrade.sh` 同步到项目的 `.claude/commands/` 目录。

## `/commit` `message`

> 创建带上下文的 Git 提交

## 上下文

- 当前 git 状态: !`git status`
- 当前 git diff: !`git diff HEAD`
- 当前分支: !`git branch --show-current`
- 最近的提交: !`git log --oneline -10`

::: details 查看完整定义


**上下文**

- 当前 git 状态: !`git status`
- 当前 git diff: !`git diff HEAD`
- 当前分支: !`git branch --show-current`
- 最近的提交: !`git log --oneline -10`

**你的任务**

根据上面的变更创建一个单独的 Git 提交。

如果通过参数传入了 message，就直接使用它：$ARGUMENTS

否则，分析这些变更，并按照 conventional commits 格式生成合适的提交信息：
- `feat:` 新功能
- `fix:` 修复 bug
- `docs:` 文档变更
- `refactor:` 代码重构
- `test:` 新增测试
- `chore:` 维护任务

:::

## `/deploy`

快速部署命令。自动执行澄清、参数判断、构建推送，非阻塞返回。

::: details 查看完整定义

快速部署命令。自动执行澄清、参数判断、构建推送，非阻塞返回。

**澄清二问（必须，不可跳过）**

如果 `$ARGUMENTS` 已指定项目名，跳过第一问；否则两问都必须问。

```
1. 部署哪个项目？
   可选：<参见 marker 下方项目清单>
2. 确认代码已合并到 develop 分支？
```

任何一问未答，不得触发构建脚本。

**前端参数自动判断**

对前端项目，自动检测最近提交中是否变更了 `package.json`：

```bash
git log origin/develop -5 --name-only --pretty=format: | grep "package.json"
```

- 有匹配 → 传参 `1`（npm install + generate）
- 无匹配 → 传参 `0`（仅 generate）
- 无法判断 → 询问用户

**执行**

根据 marker 下方的项目构建命令表执行。

- 多项目并行执行，互不等待
- 每个项目 push 完成后即时汇报
- push 完成即返回，不等待自动部署

**完成后输出**

```
<项目名> 镜像已推送（develop），Watchtower 约 60s 内完成部署
```

**约束**

- 此流程独立于工作流 A/B/C，无需经过 PM/Dev/QA
- 不执行任何代码修改，只触发构建
- 用户未明确说"全部"时，不得擅自扩展部署范围
- 构建失败如实汇报，不自动重试，等待用户决策

用户的原始输入（如果有）：$ARGUMENTS

:::

## `/fix`

Bug 修复专用轻量流程。跳过完整 Intake 三问，直接进入定位与修复。

::: details 查看完整定义

Bug 修复专用轻量流程。跳过完整 Intake 三问，直接进入定位与修复。

**流程**

**1. 复现确认**
- 确认 bug 现象和复现路径
- 如用户描述不清，最多追问 2 个关键问题

**2. 结构化定位（4 阶段根因分析）**

**阶段 1：复现确认**
- 能否稳定复现？复现率多少？
- 影响范围：线上比例、受影响用户群（由用户提供，Agent 无法自行获取时可跳过）
- 首次出现时间：是否与某次发布或配置变更有关？

**阶段 2：边界缩小**
- 二分法：确定最早触发问题的代码路径
- 排除环境因素：本地/测试/线上是否行为一致？
- 找最小复现用例：能用最少代码重现问题吗？
- **禁止在此阶段就开始改代码**

**阶段 3：根因假设**
- 列出 2-3 个候选根因（不能只假设 1 个）
- 对每个假设：给出验证方式（如：加日志看某变量值、读某行代码逻辑）
- 验证完成后选定根因，给出定位结论：哪个文件:行号、什么原因

**阶段 4：修复方案确认**（进入 Micro-spec 前完成）
- 明确修复范围：只改这个文件的这个逻辑
- 评估回归风险：这里改了，哪些调用方可能受影响？
- 给出定位结论汇总（文件 + 函数 + 根因 + 风险评估）

**3. Micro-spec**
- 1-3 句写清：修复目标、涉及文件、验证方式
- 写明 Done Contract：什么算修完

**4. Approval（审批门禁）**
- 用户明确批准前，不执行修改
- **No Approval, No Execute**

**5. Execute**
- 获批后从 develop 创建 `fix/<描述>` 分支
- 按 micro-spec 小步修复
- 禁止自行扩 scope；如需变更方案，先回到 micro-spec

**6. 验证与收尾（证明修复有效，不只是"能跑"）**

**必须提供的证明（Proof of Fix）**：
- 原 bug 复现路径：按原来的步骤操作，问题已不出现
- 回归路径：改动涉及的调用方正常工作
- 构建通过：后端 `mvn clean package -DskipTests`，前端 `npm run lint`

**输出格式**：
```
变更摘要：修改了 <文件:行号>，原因是 <根因>
验证结果：原场景已通过 / 回归场景已通过
剩余风险：<有无未覆盖的边缘情况>
```

**强约束**

- 三铁律详见 `.claude/rules/project_rule.md` §6（micro-spec 即可，不需要完整 Spec）
- 分支规范：`fix/<描述>`
- 遵守对应项目的编码规则（后端 → coding_backend.md，前端 → frontend_coding.md）
- 修复范围严格限定于 bug 本身，不顺手重构

**何时升级到 /dev**

以下情况应退出 /fix，改用 /dev 完整流程：
- 修复需要新增 API 或修改表结构
- 涉及 3 个以上文件的改动
- 根因不明确，需要深入调研

用户的原始输入（如果有）：$ARGUMENTS

:::

## `/init-setup`

逐步驱动项目初始化清单，自动检测项目信息并引导用户完成配置。

::: details 查看完整定义

逐步驱动项目初始化清单，自动检测项目信息并引导用户完成配置。

**使用方式**

```
/init-setup              # 展示阶段概览，从第一个未完成阶段继续
/init-setup --status     # 查看当前进度摘要
/init-setup --skip T6    # 跳过指定任务（标记为 skipped）
/init-setup --phase 2    # 直接执行指定阶段（1/2/3）
/init-setup T3           # 跳转到指定任务执行
```

**阶段划分**

任务按主题分为 3 个阶段，建议分阶段、分会话完成：

| 阶段 | 任务 | 主题 | 说明 |
|------|------|------|------|
| P1 基础 | T1, T2 | 项目能跑起来 | 全部 required，首次必须完成 |
| P2 领域 | T3, T4, T5 | AI 理解你的代码 | 代码扫描类，需要清晰注意力 |
| P3 集成 | T6, T7, T8, T9 | 可选增强 | 全部 optional，按需 |

每个阶段完成后建议 `/clear` 开始新会话，再用 `/init-setup --phase N` 继续下一阶段。
进度保存在 `.claude/setup-checklist.md`，断点续做不会丢失。

**执行步骤**

**第零步：读取清单**

读取 `.claude/setup-checklist.md`。

- 若文件不存在：提示用户先执行 `bash <框架路径>/templates/init-project.sh . "<项目名>"` 完成初始化
- 若文件存在：解析全部任务块，提取 `status`、`required`、`level`、`files`、`auto-detect`、`ask-user`、`verify` 字段

**第零步半：阶段概览与选择**

解析清单后，按上方「阶段划分」的固定映射将任务归入阶段。
输出阶段进度表（用 emoji 标注每个任务状态：✅ done, ⏳ pending, ⏸ skipped）：

```
**初始化 — 3 个阶段**

| 阶段 | 进度 | 任务详情 |
|------|------|---------|
| P1 基础 | 1/2 | T1 ✅ · T2 ⏳ |
| P2 领域 | 0/3 | T3 ⏳ · T4 ⏳ · T5 ⏳ |
| P3 集成 | 0/4 | T6 ⏳ · T7 ⏳ · T8 ⏳ · T9 ⏳ |

⏳ 待完成  ✅ 已完成  ⏸ 已跳过
```

然后询问用户：

「要从哪个阶段开始？
 1. P1 基础（推荐，包含全部必需任务）
 2. P2 领域
 3. P3 集成
 4. 跳转到指定任务（如 T3）」

如果某个阶段已全部完成（done/skipped），在表中标注 ✅ 并跳过。

**第一步：参数处理**

根据 `$ARGUMENTS` 分支：

**`--status`**：输出阶段进度表 + 任务明细表后停止，不执行任何任务：
```
**初始化进度 — <项目名>**

| 阶段 | 进度 | 任务详情 |
|------|------|---------|
| P1 基础 | 1/2 | T1 ✅(2026-04-23) · T2 ⏳ |
| P2 领域 | 0/3 | T3 ⏳ · T4 ⏳ · T5 ⏳ |
| P3 集成 | 0/4 | T6 ⏳ · T7 ⏳ · T8 ⏳ · T9 ⏳ |

总进度：1/9 完成，0/9 跳过，8/9 待完成
下一个任务：T2 执行框架升级（P1 基础）
```

**`--skip T<N>`**：将指定任务的 `status: pending` 改为 `status: skipped`，输出确认后停止

**`--phase <N>`（1/2/3）**：执行指定阶段的第一个 pending 任务：
- --phase 1 → 找 T1、T2 中第一个 pending 的
- --phase 2 → 找 T3、T4、T5 中第一个 pending 的
- --phase 3 → 找 T6、T7、T8、T9 中第一个 pending 的
- 若该阶段已全部完成，输出提示并建议下一阶段

**`T<N>`（任务 ID）**：跳转到指定任务执行（无论其状态如何）

**无参数**：展示阶段概览并询问用户选择（见第零步半）

**第二步：执行任务**

对当前任务，按以下顺序执行：

**2a. 宣告任务**
输出：
```
---
▶ 正在执行：T<N> — <任务标题>
```

**2b. 自动检测**
按任务的 `auto-detect` 字段描述，扫描项目：
- 读取构建文件（package.json、pom.xml、build.gradle、requirements.txt）
- 扫描源码目录结构
- 读取现有配置文件（.eslintrc、checkstyle.xml 等）
- 检测框架路径和版本

将检测结果组织成清晰的摘要，不要输出原始文件内容。

**2c. 呈现草稿**
基于检测结果，为用户生成当前任务的**填写草稿**：
- T1：生成 CLAUDE.md 填充建议（技术栈、架构描述等）
- T3：生成业务词典初始条目表格
- T4：生成检测到的代码风格摘要
- T7：生成子项目上下文的骨架内容

明确标出哪些是自动检测到的、哪些需要用户补充。

**2d. 询问用户**
按任务的 `ask-user` 字段，逐项询问需要用户提供的信息。

**T6（MCP 配置）特殊处理**：凭据信息（用户名/密码）逐项询问，不要一次性全部问。处理完后提醒用户确认 `.gitignore` 已包含 `.mcp.json`。

**T2（升级）特殊处理**：先用 `--dry-run --diff` 预览变更，让用户确认后再执行真正的升级。

**T8（Spec 目录）特殊处理**：仅说明 Spec 工作流，告知用户首次创建 Feature 时 PM Agent 会自动建立，询问是否已了解，无需用户填写任何内容。

**T9（E2E）特殊处理**：询问是否需要 E2E 基础设施；若需要，执行 `bash <框架路径>/templates/e2e/init-e2e.sh <项目路径> <项目名>`；若不需要，标记为 skipped。

**T5（Codemap 生成）特殊处理**：
1. 展示自动检测到的业务模块列表
2. 询问用户是否要为部分或全部模块生成 codemap
3. 若用户同意，对每个选定的模块：
   - 读取 `.claude/codemap/domains/HOWTO-generate-codemap.md` 作为生成指南
   - 按 `.claude/context/codemap-template.md` 模板结构生成 `domain-<业务域>.md`
   - 生成后展示给用户确认，确认后写入 `.claude/codemap/domains/`
4. 若用户跳过，告知后续 Feature 开发时 arch-agent 会按需生成，标记为 skipped

**T7（子项目上下文）特殊处理 — 知识扫描**：
当 T7 的 auto-detect 检测到项目中存在可沉淀的知识场景时（如外部集成、补偿模式、复杂交互等），
在展示草稿时额外呈现：
1. 检测到的可沉淀场景列表（表格形式：场景 | 涉及代码 | 建议类型 cookbook/pattern）
2. 询问用户是否要为这些场景预创建 cookbook/pattern 文件
3. 若用户同意：
   - 在对应子项目的 `.claude/context/` 下创建 `cookbook-<场景名>.md`
   - cookbook 内容包含：场景描述、关键代码路径、数据流、已知坑点（AI 从代码中提取）
   - 更新该子项目 `knowledge-index.md` 中的 Cookbook 表和任务映射表
   - 展示给用户确认后写入
4. 若用户跳过，告知后续 Feature 开发中 Agent 会按 knowledge-protocol 自动沉淀

**2e. 写入文件**
将草稿 + 用户输入合并，写入任务 `files` 字段指定的文件：
- 对于有 marker 的文件（domain-ontology、coding rules）：内容写在 marker **下方**，不动 marker 上方的框架内容
- 对于 CLAUDE.md：替换占位符 `[请填写...]`，保留已有结构
- 对于 .mcp.json：用 JSON 更新，保持格式整洁

**2f. 验证**
按任务的 `verify` 字段检查结果。验证通过后继续；不通过则告知用户问题并询问是否重试。

**2g. 更新状态**
将 `.claude/setup-checklist.md` 中对应任务的状态行从：
```
- status: pending
```
改为：
```
- status: done (YYYY-MM-DDTHH:MM:SS)
```

**2h. 询问继续与上下文健康提示**

输出当前进度和阶段进度：

```
✅ T<N> — <任务标题> 完成

P<M> 进度：<已完成数>/<阶段总数>
总进度：<总完成数>/9

💡 上下文提示：如果感觉对话开始变长，可以输入 /clear 开始新会话，
然后重新执行 /init-setup，会自动从断点继续（进度保存在 checklist 文件中）。

继续下一个任务（T<N+1>）？还是先到这里？
```

用户确认后，自动进入下一个 `pending` 任务；用户说「先到这里」则停止并输出进度摘要。

**2i. 阶段完成检查**

每完成一个任务后，检查当前阶段的所有任务是否均为 done/skipped。
若是，输出阶段完成提示：

```
🎉 P<M> <阶段名> 阶段完成！

💡 建议：现在 /clear 开始新会话，然后执行 /init-setup --phase <M+1> 继续。
分阶段执行能保持每个会话的注意力聚焦。

如果你想一气呵成，直接说「继续」进入下一阶段。
```

阶段映射：P1=基础(T1,T2)、P2=领域(T3,T4,T5)、P3=集成(T6,T7,T8,T9)。
P3 完成后跳过此提示，直接进入「第三步：全部完成」。

**第三步：全部完成**

当所有任务均为 `done` 或 `skipped` 时，输出：

```
🎉 初始化配置全部完成！

已完成：N 个任务
已跳过：M 个任务

⚠️ 重要：请关闭当前会话，重新打开一个新会话再开始工作。

为什么？当前会话包含了大量初始化配置的上下文信息，
在新会话中提需求能让 SDD 工作流以干净的上下文启动，
避免注意力稀释。

下一步（在新会话中）：
- 描述你的需求，主对话将启动 Intake 三问
```

**约束**

- 每次只处理**一个**任务，完成后明确询问是否继续，不要自动连续执行多个任务
- 每完成一个任务后**必须**输出上下文健康提示（2h），每个阶段完成后**必须**输出阶段完成提示（2i）
- 写入文件前必须向用户展示将要写入的内容，不要静默覆盖
- T6（MCP 配置）涉及密码等敏感信息，不在对话中回显完整密码
- 只修改任务 `files` 字段明确指定的文件，不要修改其他文件
- 状态更新（2g）必须在验证通过后才执行
- 阶段映射是固定的（P1=T1,T2；P2=T3,T4,T5；P3=T6,T7,T8,T9），不要从清单中推断

用户的原始输入（如果有）：$ARGUMENTS

:::

## `/memory`

回顾本次会话中的非显而易见决策，更新项目长期记忆（可选）。

::: details 查看完整定义

回顾本次会话中的非显而易见决策，更新项目长期记忆（可选）。

**执行步骤**

1. 读取 Claude 自动 memory 索引（`~/.claude/projects/*/memory/MEMORY.md`）
2. 回顾本次会话中的关键信息，提炼值得保留的内容：
   - 关键决策及其原因（为什么选 A 不选 B）
   - 排坑经验（下次可复用的教训）
   - 用户偏好变化（协作方式、代码风格等）
   - 项目状态变化（架构调整、依赖升级、流程变更等）
3. 检查是否已有相关 memory，有则更新，无则新建
4. 写入 Claude 自动 memory 目录（每条 memory 独立文件 + 更新 MEMORY.md 索引）

**不记录**
- 代码细节、文件路径、git 历史（可从代码/git 推断）
- 临时进度状态（属于 todo，不属于 memory）
- CLAUDE.md 中已有的规则（避免重复）

**memory 类型参考**
- **user**：用户角色、偏好、知识背景
- **feedback**：用户对协作方式的纠正或认可
- **project**：项目进展、决策、里程碑
- **reference**：外部系统的指针（Linear、Grafana、文档链接等）

用户提示（如有）：$ARGUMENTS

:::

## `/onboard`

模块/业务域快速上手命令。输入模块名，输出架构概览、核心文件、数据流和常见坑点。

::: details 查看完整定义

模块/业务域快速上手命令。输入模块名，输出架构概览、核心文件、数据流和常见坑点。

**使用方式**

```
/onboard <模块名或业务域>
```

示例：`/onboard gateway`、`/onboard agent`、`/onboard ai-kg-front`

**执行步骤**

**1. 定位资料**

按以下顺序查找模块相关资料（有则读取，无则跳过）：

- **Domain Codemap**：`.claude/codemap/domains/domain-<模块>.md`
- **业务域 Spec**：`.claude/specs/SPEC-INDEX.md` → 对应 Spec 文件
- **编码规则**：后端 `.claude/rules/coding_backend.md` / 前端 `<App>/.claude/rules/frontend_coding.md`
- **历史 Feature Specs**：`.claude/specs/feature-*/` 中与该模块相关的

**2. 代码扫描**

- 识别核心文件：Controller、Service、Mapper、Entity（后端）或 pages、components、store（前端）
- 梳理调用链：入口 → 核心逻辑 → 数据层 / 外部依赖
- 标注关键数据表及其关联关系

**3. 输出模板**

```
**<模块名> 上手指南**

**一句话定位**
<这个模块做什么，服务于谁>

**核心文件**
| 文件 | 职责 |
|------|------|
| ... | ... |

**数据流**
<入口> → <核心处理> → <数据层/外部调用>

**关键表**
| 表名 | 用途 | 关联 |
|------|------|------|
| ... | ... | ... |

**已有规范**
- Codemap：<路径或"无">
- Spec：<路径或"无">
- 编码规则：<路径或"无">

**常见坑点**
- ...
```

**约束**

- 只读操作，不修改任何文件
- 优先从已有 Codemap/Spec 提炼，避免重复扫描大量代码
- 如果模块名无法匹配，列出可选的模块清单供用户选择

用户的原始输入（如果有）：$ARGUMENTS

:::

## `/push-all`

> 暂存所有变更，创建提交并推送到远程（请谨慎使用）

# 提交并推送全部内容

⚠️ **注意**：将所有变更都暂存、提交并推送到远程。只有在你确认所有改动都应该放在一起时才使用。

::: details 查看完整定义


**提交并推送全部内容**

⚠️ **注意**：将所有变更都暂存、提交并推送到远程。只有在你确认所有改动都应该放在一起时才使用。

**工作流**

**1. 分析变更**
并行运行：
- `git status` - 显示已修改/已添加/已删除/未跟踪文件
- `git diff --stat` - 显示变更统计
- `git log -1 --oneline` - 查看最近一次提交，便于统一提交信息风格

**2. 安全检查**

**❌ 如果发现以下内容，立即停止并警告：**
- Secrets：`.env*`、`*.key`、`*.pem`、`credentials.json`、`secrets.yaml`、`id_rsa`、`*.p12`、`*.pfx`、`*.cer`
- API Keys：任何 `*_API_KEY`、`*_SECRET`、`*_TOKEN` 变量包含真实值，而不是占位符，如 `your-api-key`、`xxx`、`placeholder`
- 大文件：`>10MB` 且未使用 Git LFS
- 构建产物：`node_modules/`、`dist/`、`build/`、`__pycache__/`、`*.pyc`、`.venv/`
- 临时文件：`.DS_Store`、`thumbs.db`、`*.swp`、`*.tmp`

**API Key 校验：**
检查修改文件中是否存在以下模式：
```bash
OPENAI_API_KEY=sk-proj-xxxxx  # ❌ 检测到真实密钥！
AWS_SECRET_KEY=AKIA...         # ❌ 检测到真实密钥！
STRIPE_API_KEY=sk_live_...    # ❌ 检测到真实密钥！

**✅ 可接受的占位符：**
API_KEY=your-api-key-here
SECRET_KEY=placeholder
TOKEN=xxx
API_KEY=<your-key>
SECRET=${YOUR_SECRET}
```

**✅ 确认：**
- `.gitignore` 配置正确
- 没有合并冲突
- 分支正确（如果是 `main`/`master` 要提醒）
- API key 只是占位符

**3. 请求确认**

展示摘要：
```
📊 变更摘要：
- X 个文件已修改，Y 个文件已新增，Z 个文件已删除
- 总计：+AAA 行新增，-BBB 行删除

🔒 安全性：✅ 无 secrets | ✅ 无大文件 | ⚠️ [警告]
🌿 分支： [name] → origin/[name]

我将执行：git add . → commit → push

请输入 'yes' 继续，或输入 'no' 取消。
```

**在收到明确的 "yes" 之前不要继续。**

**4. 执行（确认后）**

按顺序运行：
```bash
git add .
git status  # 验证暂存状态
```

**5. 生成提交信息**

分析变更并创建 conventional commit：

**格式：**
```
[type]: 简要摘要（最多 72 个字符）

- 关键改动 1
- 关键改动 2
- 关键改动 3
```

**类型：** `feat`、`fix`、`docs`、`style`、`refactor`、`test`、`chore`、`perf`、`build`、`ci`

**示例：**
```
docs: 更新概念文档，补充完整说明

- 添加架构图和表格
- 补充实用示例
- 扩展最佳实践部分
```

**6. 提交并推送**

```bash
git commit -m "$(cat <<'EOF'
[生成的提交信息]
EOF
)"
git push  # 如果失败：git pull --rebase && git push
git log -1 --oneline --decorate  # 验证
```

**7. 确认成功**

```
✅ 已成功推送到远程！

Commit: [hash] [message]
Branch: [branch] → origin/[branch]
Files changed: X (+insertions, -deletions)
```

**错误处理**

- `git add` 失败：检查权限、锁定文件，确认仓库已初始化
- `git commit` 失败：修复 pre-commit hooks，检查 git 配置（user.name/email）
- `git push` 失败：
  - 非快进：`git pull --rebase && git push`
  - 没有远程分支：`git push -u origin [branch]`
  - 受保护分支：改用 PR 工作流

**适用场景**

✅ **适合：**
- 多文件文档更新
- 同时包含测试和文档的功能
- 跨多个文件的 bug 修复
- 项目级格式化/重构
- 配置变更

❌ **避免：**
- 不确定要提交哪些内容
- 包含 secrets/敏感数据
- 受保护分支且未经过审核
- 存在合并冲突
- 想保留更细粒度的提交历史
- pre-commit hooks 失败

**替代方案**

如果用户想保留控制权，可以建议：
1. **选择性暂存**：查看并暂存特定文件
2. **交互式暂存**：使用 `git add -p` 逐块选择
3. **PR 工作流**：创建分支 → 推送 → 发起 PR（使用 `/pr` 命令）

**⚠️ 记住**：在推送前始终先检查变更。拿不准时，使用单独的 git 命令会更可控。

:::

## `/spec-status`

扫描所有 Spec 目录，输出各 Feature 和业务域 Spec 的当前状态总览。

::: details 查看完整定义

扫描所有 Spec 目录，输出各 Feature 和业务域 Spec 的当前状态总览。

**执行步骤**

**1. 扫描业务域 Spec**

读取 `.claude/specs/SPEC-INDEX.md`，提取 Section 2 维护状态表，输出各业务域状态。

**2. 扫描 Feature Specs**

遍历 `.claude/specs/feature-*/` 和 `.claude/specs/YYYY-MM-DD_hh-mm_*/` 目录，按目录内文件判断阶段：

| 存在的文件 | 判定阶段 |
|-----------|---------|
| 仅 `01_requirement.md` | PM（需求已完成） |
| + `02_technical_design.md` | Arch（技术设计已完成） |
| + `03_impl_backend.md` | Dev（后端实现中/已完成） |
| + `03_impl_frontend.md` | FE（前端实现中/已完成） |
| + `evidences/` 目录有内容 | QA（验收中/已完成） |

同时检查 `evidences/` 下是否有 `evidence-qa.md` 且结论为 PASS，判定是否已 Done。

**3. 输出格式**

```
**Spec 状态总览**

**业务域 Spec**
| 业务域 | 状态 | 版本 | 最后更新 |
|--------|------|------|---------|
| ... | ... | ... | ... |

**Feature Specs**
| Feature | 阶段 | 创建时间 | 包含文件 |
|---------|------|---------|---------|
| ... | PM / Arch / Dev / FE / QA / Done | ... | ... |

**统计**
- 业务域 Spec：N 个 active / N 个待创建
- Feature Spec：N 个进行中 / N 个已完成
```

**约束**

- 只读操作，不修改任何文件
- 如果 specs 目录为空，提示用户尚无 Spec 并给出创建指引

用户的原始输入（如果有）：$ARGUMENTS

:::

## `/upgrade-core`

# 升级框架托管文件

从 h-codeflow-framework 拉取最新 core/ 内容，更新当前项目 `.claude/` 下的框架托管文件，保留 marker 下方的项目自定义内容。

::: details 查看完整定义


**升级框架托管文件**

从 h-codeflow-framework 拉取最新 core/ 内容，更新当前项目 `.claude/` 下的框架托管文件，保留 marker 下方的项目自定义内容。

**参数**

用户传入的参数：$ARGUMENTS

- `--dry-run`：仅预览变化，不写入（默认）
- `--diff`：显示详细 diff

**工作流**

**1. 定位框架目录**

按以下顺序查找 `h-codeflow-framework`：
1. `../h-codeflow-framework`（最常见的同级目录布局）
2. 用户指定的路径

找不到则提示用户手动指定框架路径。

**2. 预览变更**

**始终先 dry-run**：

```bash
bash ../h-codeflow-framework/tools/upgrade.sh --dry-run --diff
```

展示将要更新的文件列表和差异。

**3. 确认升级**

告知用户：
- 将更新哪些文件
- marker 下方的项目自定义内容会被保留
- 原文件会备份到 `.claude/.backup/`

请求用户输入 `yes` 确认后执行：

```bash
bash ../h-codeflow-framework/tools/upgrade.sh
```

**4. 验证结果**

升级完成后：

```bash
git status   # 查看变更文件
git diff     # 查看具体差异
```

展示摘要：
```
📋 升级完成，后续步骤：
1. git diff .claude/ — 确认变更内容
2. 检查 marker 下方的自定义内容是否完好
3. git add + commit
```

**指定框架分支**

如需使用实验分支（如 `exp/xxx`），提示用户：

```bash
FRAMEWORK_BRANCH=exp/xxx bash ../h-codeflow-framework/tools/upgrade.sh
```

:::

