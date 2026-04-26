---
argument-hint: "<类型> <主题>（类型: case|essay|guide|resource）"
description: 写一篇文档并归档到文档站（case=实战案例, essay=技术随笔, guide=使用指南, resource=学习资源）
---

## 上下文

- 文档站目录: `docs/`
- 侧边栏配置: `docs/.vitepress/config.ts`

## 你的任务

根据参数创建文档：`$ARGUMENTS`

第一个词为类型（case/essay/guide/resource），其余为主题。

### 排版风格

参考 `.claude/skills/vitepress-docs/SKILL.md` §3（内容展示模式），使用 Container（tip/info/warning/danger/details）、Badge、代码高亮等规范呈现内容，不要写纯 Markdown。

### 按类型选择目标和写作要求

#### case — 实战案例

- **目录**: `docs/cases/`
- **sidebar**: `/cases/` → 实战案例分组
- **写作**: 背景 → 问题 → 方案 → 效果 → 经验教训。侧重可复现的实操步骤，关键代码片段必须包含，踩坑过程、决策理由、最终效果都要写

#### essay — 技术随笔

- **目录**: `docs/resources/`
- **sidebar**: `/resources/` → 技术随笔分组
- **写作**: 先说观点，再展开分析，最后收尾点题。要有代码示例、数据对比或架构图（ASCII）中的至少一种，不能纯文字。文末标注日期和"wqw"

#### guide — 使用指南

- **目录**: `docs/guide/`
- **sidebar**: `/guide/` → 入门指南分组
- **写作**: 读者是刚接触 HCodeFlow 的开发者。结构：目标 → 前置条件 → 操作步骤 → 验证 → 下一步。每个步骤都有命令和预期输出

#### resource — 学习资源

- **目录**: `docs/resources/`
- **sidebar**: 根据内容主题自动选分组（Claude Code 相关→`Claude Code 深度学习`，飞书/工具集成→`飞书工具集成`，CI/CD→`运维指南`，方法论→`方法论与社区`）
- **写作**: 教程式，跟着做就能上手。结构：是什么 → 怎么装 → 怎么用 → 进阶技巧 → 常见问题。每个步骤都有可执行的命令或代码

### 归档操作（写完后自动执行）

1. 加 VitePress frontmatter：
   ```yaml
   ---
   title: 文章标题
   description: 一句话摘要
   ---
   ```
   guide 类型额外加 `prev` / `next` 导航，并更新相邻页面。

2. 保存到对应目录，文件名用英文短横线命名（如 `<name>.md`）

3. 在 `docs/.vitepress/config.ts` 的对应 sidebar 分组的 `items` 数组中添加条目：
   ```ts
   { text: '文章标题', link: '/目录/文件名' }
   ```
