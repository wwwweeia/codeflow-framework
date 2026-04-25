# AI Prompt Lab — 演示项目

> codeflow-framework 的最小可运行演示，用于培训、汇报和最佳实践参考。

## 前置条件

- Python 3.10+
- Node.js 18+
- Claude Code（CLI 或 IDE 插件）
- 框架仓库与 demo 同级（demo 已在框架内）

## 快速启动（5 分钟）

### 1. 启动后端

```bash
cd demo/backend
pip install -r requirements.txt
python scripts/seed.py          # 初始化种子数据
uvicorn app.main:app --reload   # http://localhost:8000，API 文档 /docs
```

### 2. 启动前端

```bash
cd demo/frontend
npm install
npm run dev                     # http://localhost:5173
```

### 3. 运行演示场景

打开 Claude Code，进入 `demo/` 目录，选择一个演示命令：

| 命令 | 场景 | 工作流 | 时间 |
|------|------|--------|------|
| `/demo-q0` | 在首页加欢迎横幅 | Q0 轻量 | 5 min |
| `/demo-workflow-a` | 新增 Agent 统计 API | A 纯后端 | 15 min |
| `/demo-workflow-b` | 新增 Prompt 管理页面 | B 纯前端 | 15 min |
| `/demo-workflow-c` | 实现 Skill 管理功能 | C 全栈 | 25 min |

## 框架验证与维护

demo 是框架的**首发验证环境**——修改 `core/` 后必须先在此验证同步是否正常。

### 升级框架文件

```bash
# 预览哪些文件会变化（不写入）
cd demo && bash ../tools/upgrade.sh --dry-run

# 正式升级并查看变更
cd demo && bash ../tools/upgrade.sh --diff
```

验证要点：upgrade.sh 正常执行、`--diff` 输出符合预期、marker 上方更新正确、marker 下方项目自定义内容未被覆盖。

### 重置演示

```bash
# 完全重置到初始状态（清理 specs、codemap、数据库、构建产物、feature 分支）
sh reset-demo.sh --base

# 重置到特定场景起点
sh reset-demo.sh --scenario 2
```

### 典型场景速查

| 场景 | 操作 |
|------|------|
| 修改了 `core/`，验证同步效果 | `cd demo && bash ../tools/upgrade.sh --diff` |
| 演示前重置环境 | `cd demo && sh reset-demo.sh --base` |
| 在 demo 中实验新功能 | 改 marker 上方内容 → 验证 → 框架侧 `harvest.sh` 收割回 core/ |
| 发版前验证 | demo 升级通过后才允许执行 `release.sh` |

## 项目结构

```
demo/
├── backend/          # FastAPI + SQLAlchemy + SQLite
│   ├── app/          # 后端应用
│   └── .claude/      # 后端子项目规则（预填充）
├── frontend/         # Vue 3 + Element Plus + Pinia
│   ├── src/          # 前端应用
│   └── .claude/      # 前端子项目规则（预填充）
└── .claude/          # 根项目配置（完全配置好）
    ├── agents/       # 框架管理
    ├── rules/        # 工作流 + 编码规范
    ├── skills/       # 领域本体（AI Prompt Lab）
    └── commands/     # 演示命令
```

## 业务域：AI Prompt Lab

4 个核心实体：
- **Model**（模型）：LLM 模型配置（GPT-4、Claude 等）
- **Prompt**（提示词）：提示词模板，支持变量和标签
- **Agent**（智能体）：绑定 Model + Prompt 的 AI Agent，状态机 draft → active → inactive
- **Skill**（技能）：Agent 可调用的工具能力

## E2E 测试

demo 包含基于 Playwright 的 E2E 测试，覆盖首页和 Prompt 列表页的核心功能。

### 前置条件

```bash
cd demo/e2e
npm install
npx playwright install chromium
```

### 运行测试

```bash
# 确保 demo 前端已启动
cd demo/frontend && npm run dev

# 运行 E2E 测试
cd demo/e2e && npm test

# 带浏览器 UI 运行（演示用）
cd demo/e2e && npm run test:headed

# 查看 HTML 报告
cd demo/e2e && npm run report
```

### 测试覆盖

| 页面 | 测试场景 |
|------|---------|
| 首页 | 标题渲染、欢迎横幅关闭、统计数据正确性 |
| Prompt 列表 | 列表加载、关键词搜索、标签筛选、搜索重置、空结果处理 |

### 项目结构

```
demo/e2e/
├── pages/                 # Page Object Model
│   ├── base.page.ts       # 基类（截图、loading 等待）
│   ├── home.page.ts       # 首页 POM
│   └── prompt-list.page.ts
├── tests/                 # 测试用例
│   ├── home.spec.ts
│   └── prompt-list.spec.ts
├── playwright.config.ts
├── package.json
└── tsconfig.json
```

## 学习目标

通过本演示项目，你将学会：
1. 如何填写 `.claude/` 的 context/rules/ontology 文件
2. 如何体验 Q0/A/B/C 四种工作流的完整流程
3. 如何使用 `upgrade.sh` / `harvest.sh` 双向同步框架
4. 如何将最佳实践沉淀回框架
