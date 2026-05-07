---
title: 常见问题
description: HCodeFlow 使用过程中的高频问题 — 从基础概念到日常操作
prev:
  text: 动手练习
  link: /getting-started/exercises
next:
  text: 故障排查
  link: /getting-started/troubleshooting
---

# 常见问题（FAQ）

> 从最基础的概念问题到日常使用中的操作问题，都在这里。

---

## 基础概念

### Q: HCodeFlow 是什么？

HCodeFlow 是一个**给 AI 编码助手（如 Claude Code）定义工作流的框架**。

它做一件事：**确保 AI 按流程交付代码，而不是按感觉写代码。**

核心工作流：拿到需求 → 写规格文档（Spec） → 人审批 → AI 实现 → 代码审查 → 合并。

### Q: HCodeFlow 不是什么？

- 不是 IDE 插件 — 不需要安装到编辑器
- 不是 AI 模型 — 不替代 Claude/GPT 等模型
- 不是项目管理工具 — 不替代 Jira/飞书等
- 不是运行时框架 — 不引入任何依赖

它就是一组**配置文件和规则**，告诉 AI 编码助手"在我们团队应该怎么干活"。

### Q: 它和 Claude Code 是什么关系？

Claude Code 是 AI 编码助手（类似 Cursor、Copilot），HCodeFlow 是给它配的"工作流大脑"。

类比：Claude Code = 厨师，HCodeFlow = 标准菜谱 + 出餐流程。

没有 HCodeFlow，Claude Code 也能写代码，但没有统一的标准和流程。有了 HCodeFlow，每次代码变更都有迹可循、质量可控。

### Q: 我的项目必须用完整工作流吗？

**不需要。** 小改动用 Q0 轻量模式（直接改，几步搞定），大需求才走完整工作流（Spec → 审批 → 实现 → 审查）。

AI 会自动判断用哪个模式，你不用操心。

### Q: 不用 Claude Code 能用吗？

HCodeFlow 的 Agent 定义和 Rules 是基于 Claude Code 的原生机制设计的。理论上可以把核心理念适配到其他 AI 编码工具，但需要自行调整配置格式。

---

## 初始化相关

### Q: init-project.sh 和 upgrade.sh 的区别是什么？

| | init-project.sh | upgrade.sh |
|---|---|---|
| 什么时候用 | 新项目首次接入 | 已接入项目更新框架文件 |
| 执行位置 | 新项目目录 | 已接入项目目录 |
| 做了什么 | 创建完整 `.claude/` 结构 + 复制所有文件 | 只更新 marker 上方的框架内容 |
| 是否覆盖 | 同名文件会覆盖 | marker 下方的自定义内容永远保留 |

### Q: 子项目是什么？需要手动创建吗？

如果你的项目是 monorepo（包含多个前端/后端子目录），`init-project.sh` 会**自动检测**并生成子项目的 `.claude/` 脚手架：

- 含 `package.json` 的子目录 → 自动识别为前端
- 含 `pom.xml` / `build.gradle` 的子目录 → 自动识别为后端

不需要手动创建。如果初始化时漏了，可以单独补：

```bash
bash ../h-codeflow-framework/templates/init-subproject.sh ./new-app fe "My Project"
```

### Q: doctor.sh 报错了怎么办？

按提示安装缺失依赖。常见问题：

| 检查项 | 失败原因 | 修复方式 |
|--------|---------|---------|
| bash | 系统缺少 bash | macOS/Linux 自带；Windows 用 Git Bash |
| git | 未安装 git | `brew install git` 或系统包管理器 |
| shasum/sha256sum | 系统缺少哈希工具 | macOS 自带 shasum；Linux 安装 coreutils |
| python3 | 未安装 Python | `brew install python3` |

加了 `--quiet` 参数只显示有问题的项：`bash tools/doctor.sh --quiet`

---

## Marker 与升级相关

### Q: marker 上方和下方分别是什么？我能改 marker 上方的内容吗？

**marker 上方**是框架管理的内容（Agent 定义、工作流规则等），`upgrade.sh` 会用框架最新版本覆盖。

**marker 下方**是你自定义的内容，升级时**永远不会被覆盖**。

你可以改 marker 上方内容，但下次升级会被覆盖。如果你在 marker 上方做了有价值的改进，可以联系框架维护者，通过 `harvest.sh` 收割回框架，让所有项目受益。

### Q: 框架升级会影响我的自定义内容吗？

**不会。** 这是 marker 机制的核心保证。升级只替换 marker 上方的框架内容，marker 下方永远保留。

升级后建议执行 `git diff .claude/` 确认变更范围。

### Q: 升级后发现问题怎么回滚？

`upgrade.sh` 每次执行都会自动备份到 `.claude/.backup/`：

```bash
# 查看备份
ls .claude/.backup/

# 恢复
cp -r .claude/.backup/upgrade-YYYYMMDD-HHMMSS/* .claude/
```

---

## 工作流相关

### Q: 什么时候用 Q0 轻量模式？什么时候用正式工作流？

AI 会自动判断，但了解规则有助于写出更好的需求描述：

**Q0 轻量模式**（满足全部条件）：
- 改动不超过 3 个文件
- 不涉及新建 API 或数据库表
- 需求明确，无需多角色协同
- 不涉及跨项目改动

**正式工作流**（A/B/C）：
- 涉及新的 API 端点、数据库变更 → 工作流 A
- 涉及页面开发、组件封装 → 工作流 B
- 前后端都要改 → 工作流 C

### Q: 七个 Agent 我需要全部了解吗？

**不需要。** 日常使用中你只跟主对话交互（就是你打开 Claude Code 后对话的那个），Agent 的调度是全自动的。

你需要做的是：
1. 回答 Intake 三问（目标、边界、验收标准）
2. 审批 PM 产出的需求文档
3. 审批 Arch 产出的技术设计
4. 确认最终结果

AI 会自动在 PM → Arch → Dev/FE → QA 之间流转。

### Q: Spec 文档在哪里？是谁创建的？

Spec 文档在 `.claude/specs/` 目录下，按 Feature 分目录：

```
.claude/specs/YYYY-MM-DD_HH-MM_feature-name/
├── 01_requirement.md          ← PM 产出
├── 02_technical_design.md     ← Arch 产出
├── 03_impl_backend.md         ← Dev 产出
├── 03_impl_frontend.md        ← FE 产出
└── evidences/                 ← QA + 验证证据
```

这些都是 Agent 自动创建和维护的，你只需要**审批** 01 和 02 文档。

### Q: 我的项目不是 Java + Vue 技术栈，能用吗？

**可以。** 框架的工作流是技术栈无关的：
- 三铁律、七角色、四工作流的设计与具体技术无关
- 编码规范模板（`coding_backend.md`、`coding_frontend.md`）需要你根据技术栈自行适配
- Agent 定义中的具体实现约定可能需要调整

接入后根据你的技术栈修改编码规范即可，工作流调度逻辑不需要改。

---

## 获取帮助

| 方式 | 适用场景 |
|------|---------|
| [故障排查指南](/getting-started/troubleshooting) | 环境/升级/工作流问题排查 |
| [快速入门](/getting-started/quick-start) | 快速入门指南 |
| [概念详解](/getting-started/concepts) | 深入理解框架概念 |
| [项目接入](/integration/new-project) | 新项目接入指南 |
| `/onboard <模块名>` | 在 Claude Code 中快速了解某个模块 |
| 飞书群 | 社区互助答疑 |
| [框架反馈](/getting-started/feedback) | 结构化提交框架改进建议 |
