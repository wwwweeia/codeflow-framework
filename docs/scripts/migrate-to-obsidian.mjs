#!/usr/bin/env node

/**
 * HCodeFlow 文档站 → Obsidian 迁移脚本
 *
 * 将 VitePress 文档批量转换为 Obsidian MOC 体系的笔记文件。
 * 零依赖，只用 Node.js 内置模块。
 *
 * 用法：node scripts/migrate-to-obsidian.mjs
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync, statSync } from 'node:fs'
import { join, extname, relative } from 'node:path'

// ─── 配置 ──────────────────────────────────────────────────────────
const SOURCE_DIR = join(import.meta.dirname, '..')
const TARGET_DIR = '/Users/wqw/Documents/obsidian/obsidian'

// 排除的目录
const EXCLUDE_DIRS = new Set(['.vitepress', 'node_modules', 'public', 'scripts'])

// 源路径（去掉 .md 后缀） → Obsidian 文件名
const NAME_MAP = {
  // 根目录
  '/': 'HCodeFlow 介绍',

  // guide/
  '/guide/philosophy': '设计理念',
  '/guide/quick-start': '快速入门',
  '/guide/concepts': '概念速查表',
  '/guide/onboarding': '项目接入检查清单',
  '/guide/tools': '工具速查',
  '/guide/exercises': '动手练习手册',
  '/guide/faq': '常见问题',
  '/guide/troubleshooting': '故障排查指南',

  // design/
  '/design/overview': '一、框架概述',
  '/design/architecture': '二、架构设计',
  '/design/marker': '三、Stub Marker 自动管理',
  '/design/workflow': '四、工作流体系',
  '/design/integration': '五、新项目接入指南',
  '/design/maintenance': '六、已接入项目的更新与维护',
  '/design/collaboration': '七、团队协作与框架迭代',
  '/design/tools': '八、核心工具参考',
  '/design/compliance-tests': '框架遵从度测试用例',
  '/design/appendix': '九、附录',

  // reference/
  '/reference/agents': 'Agents 参考',
  '/reference/skills': 'Skills 参考',
  '/reference/commands': 'Commands 参考',
  '/reference/rules': 'Rules 参考',
  '/reference/changelog': '更新日志',

  // cases/
  '/cases/': '实战案例索引',
  '/cases/workflow-c-preset-questions': '工作流 C 完整旅程',
  '/cases/v2-refactor': 'v2 跨语言重构实战',
  '/cases/init-practice': '新项目接入实践',
  '/cases/demo-walkthrough': 'Demo 工作流演练',
  '/cases/testing-pyramid-practice': '测试金字塔实战',

  // resources/
  '/resources/': '学习资源索引',
  '/resources/claude-code-hooks': 'Hooks 精华整理',
  '/resources/claude-code-rules': 'Rules 精华整理',
  '/resources/claude-code-skills': 'Skills 精华整理',
  '/resources/claude-code-subagent': 'SubAgent 完整指南',
  '/resources/framework-retrospective-v2': 'v2.0 复盘与改进路线',
  '/resources/rule-roi-audit': '规则 ROI 审计报告',
  '/resources/submodule-knowledge-system': '子模块知识体系增强方法论思考',
  '/resources/codex-migration': 'Codex CLI 迁移指南',
  '/resources/opencode-migration': 'OpenCode CLI 迁移指南',
  '/resources/browser-automation-tools-2026': '浏览器自动化工具选型',
  '/resources/sdd-riper-methodology': 'SDD-RIPER 方法论',
  '/resources/building-intuition': '培养你的直觉',
  '/resources/claude-code-awesome-repos': '优质仓库推荐',
  '/resources/claude-code-feishu-notify': '飞书通知集成指南',
  '/resources/lark-cli-guide': 'lark-cli 安装与使用',
  '/resources/watchtower-cicd-guide': 'CI-CD 自动化部署',

  // temporary/
  '/temporary/rule-roi-audit-third-party-review': '规则 ROI 审计 - 第三方审查意见',
}

// 反向映射：文件路径（相对 docs/）→ Obsidian 文件名
const FILE_TO_NAME = new Map()
for (const [slug, name] of Object.entries(NAME_MAP)) {
  if (slug === '/') {
    FILE_TO_NAME.set('index.md', name)
  } else if (slug.endsWith('/')) {
    // '/cases/' → 'cases/index.md'
    FILE_TO_NAME.set(slug.slice(1) + 'index.md', name)
  } else {
    // '/guide/quick-start' → 'guide/quick-start.md'
    FILE_TO_NAME.set(slug.slice(1) + '.md', name)
  }
}

// 目录 → 标签映射
const DIR_TAGS = {
  guide: '指南',
  design: '架构设计',
  reference: '参考手册',
  cases: '实战案例',
  resources: '学习资源',
  temporary: '临时笔记',
}

// ─── Frontmatter 解析 ──────────────────────────────────────────────

/**
 * 解析 YAML frontmatter，返回 { attrs, body }
 * 简单实现，只处理常见格式
 */
function parseFrontmatter(content) {
  const trimmed = content.trimStart()
  if (!trimmed.startsWith('---')) {
    return { attrs: {}, body: content }
  }

  const endIdx = trimmed.indexOf('---', 3)
  if (endIdx === -1) {
    return { attrs: {}, body: content }
  }

  const yamlStr = trimmed.slice(3, endIdx).trim()
  const body = trimmed.slice(endIdx + 3)

  // 简单 YAML 解析（只处理基本 key: value 和数组）
  const attrs = {}
  const lines = yamlStr.split('\n')
  let currentKey = null
  let inArray = false

  for (const line of lines) {
    // 跳过空行
    if (!line.trim()) continue

    // 数组项：  - value
    if (inArray && /^\s*-\s+/.test(line)) {
      const val = line.replace(/^\s*-\s+/, '').trim()
      if (val) {
        attrs[currentKey].push(val)
      }
      continue
    }

    // key: value
    const kvMatch = line.match(/^(\w[\w-]*)\s*:\s*(.*)/)
    if (kvMatch) {
      const key = kvMatch[1]
      let value = kvMatch[2].trim()

      // 布尔值
      if (value === 'false') {
        attrs[key] = false
        currentKey = null
        inArray = false
        continue
      }
      if (value === 'true') {
        attrs[key] = true
        currentKey = null
        inArray = false
        continue
      }

      // 空值 → 可能是数组或对象的开始
      if (!value) {
        attrs[key] = []
        currentKey = key
        inArray = true
        continue
      }

      attrs[key] = value
      currentKey = null
      inArray = false
    }
  }

  return { attrs, body }
}

/**
 * 将 attrs 对象序列化为 YAML frontmatter 字符串
 */
function serializeFrontmatter(attrs) {
  const lines = ['---']
  for (const [key, value] of Object.entries(attrs)) {
    if (Array.isArray(value)) {
      lines.push(`${key}:`)
      for (const item of value) {
        lines.push(`  - ${item}`)
      }
    } else if (typeof value === 'string') {
      // 包含特殊字符时加引号
      if (value.includes(':') || value.includes('#') || value.includes("'") || value.includes('"')) {
        lines.push(`${key}: "${value.replace(/"/g, '\\"')}"`)
      } else {
        lines.push(`${key}: ${value}`)
      }
    } else {
      lines.push(`${key}: ${value}`)
    }
  }
  lines.push('---')
  return lines.join('\n')
}

/**
 * 转换 frontmatter：保留 title/description，移除 VitePress 专有字段，添加 tags/aliases
 */
function transformFrontmatter(attrs, sourceRelativePath) {
  const newAttrs = {}

  // 保留的字段
  if (attrs.title) newAttrs.title = attrs.title
  if (attrs.description) newAttrs.description = attrs.description

  // 添加标签
  const dir = sourceRelativePath.includes('/') ? sourceRelativePath.split('/')[0] : ''
  const tag = DIR_TAGS[dir] || 'hcodeflow'
  newAttrs.tags = ['hcodeflow', tag].filter((v, i, a) => a.indexOf(v) === i)

  // 添加别名（原始路径）
  const slug = sourceRelativePath === 'index.md'
    ? '/'
    : '/' + sourceRelativePath.replace(/\.md$/, '')
  newAttrs.aliases = [slug]

  return newAttrs
}

// ─── 内容转换 ──────────────────────────────────────────────────────

/**
 * 转换 ::: details 块为 Obsidian 可折叠 callout
 */
function convertDetailsBlocks(body) {
  // 匹配 ::: details 标题\n...\n:::
  return body.replace(/^::: details\s+(.+)\n([\s\S]*?)\n:::$/gm, (match, title, content) => {
    const lines = content.split('\n').map(line => `> ${line}`).join('\n')
    return `> [!info]- ${title}\n>\n${lines}`
  })
}

/**
 * 转换其他 VitePress 容器（::: tip / warning / info / danger）为 Obsidian callout
 */
function convertContainerBlocks(body) {
  const containerTypes = ['tip', 'warning', 'info', 'danger', 'caution']

  for (const type of containerTypes) {
    // 有标题：::: type 标题
    const regexWithTitle = new RegExp(
      `^::: ${type}\\s+(.+)$\\n([\\s\\S]*?)\\n^:::$`,
      'gm'
    )
    body = body.replace(regexWithTitle, (match, title, content) => {
      const lines = content.split('\n').map(line => `> ${line}`).join('\n')
      return `> [!${type}] ${title}\n>\n${lines}`
    })

    // 无标题：::: type
    const regexNoTitle = new RegExp(
      `^::: ${type}\\s*$\\n([\\s\\S]*?)\\n^:::$`,
      'gm'
    )
    body = body.replace(regexNoTitle, (match, content) => {
      const lines = content.split('\n').map(line => `> ${line}`).join('\n')
      return `> [!${type}]\n>\n${lines}`
    })
  }

  return body
}

/**
 * 转换内部链接为 wikilink
 * [显示文本](/path/to/file) → [[文件名|显示文本]]
 */
function convertInternalLinks(body) {
  // 匹配 [text](/path) 或 [text](/path#anchor)，排除外部链接
  return body.replace(/\[([^\]]+)\]\((\/[^)#]+?)(#[^)]+)?\)/g, (match, displayText, path, anchor) => {
    const targetName = NAME_MAP[path]
    if (!targetName) {
      // 没在映射表中的链接，保持原样
      return match
    }

    // 处理锚点：#_2-4-xxx → #2-4-xxx
    let suffix = ''
    if (anchor) {
      suffix = '#' + anchor.slice(1).replace(/^_/, '')
    }

    // 显示文本与文件名相同时用简写
    if (displayText === targetName || displayText === targetName + '.md') {
      return `[[${targetName}${suffix}]]`
    }

    return `[[${targetName}${suffix}|${displayText}]]`
  })
}

/**
 * 特殊处理主页 index.md（layout: home）
 * 主页的 frontmatter 含复杂嵌套对象，简单解析器处理不了，直接硬编码内容
 */
function convertHomepage(attrs, body) {
  return `# HCodeFlow 介绍

> Spec-Driven Development — 先确认再执行，让 AI 在确定性空间里高速运转

## 核心特性

- **Spec 驱动，No Spec No Code** — 需求确认 → 设计确认 → AI 执行。所有不确定性在写代码之前消除，而不是在返工中暴露。
- **7 Agent 专业分工** — PM、架构师、后端、前端、QA、原型、E2E — 角色职责明确，按工作流自动编排协作。
- **零依赖，基于原生配置** — 不引入运行时，纯文件分发。基于 Claude Code 原生 CLAUDE.md / Agents / Rules / Commands 机制。
- **双向同步，持续进化** — upgrade.sh 向下推送标准，harvest.sh 向上收割实战经验。框架与项目共同成长。
- **内置质量门禁** — 合并检查清单、Spec 格式校验、代码审查规则 — 每个环节都有自动化质量保障。
- **渐进式采纳** — 从单项目轻量接入到团队全面推广。四个工作流（Q0/A/B/C）覆盖从 bug fix 到全栈联动的所有场景。

## 为什么是框架，不是插件？

> Claude Code 有多种扩展方式，HCodeFlow 选择了最轻量、最原生的一种。

| 层级 | 机制 | 说明 |
|------|------|------|
| 运行时 | MCP Server | 给 Claude 增加新工具能力（外部进程），需要独立开发维护 |
| 事件层 | Hooks | 事件驱动脚本（如提交前自动检查），适合自动化检查点 |
| 配置层 | CLAUDE.md · Agents · Rules · Commands | **← HCodeFlow 在这里**。纯文本指令，零运行时、零依赖、开箱即用 |
| 记忆层 | Memory | 跨会话持久化上下文，记录用户偏好和项目经验 |

### 插件思维

- 需要安装、注册、版本管理
- 引入运行时依赖（MCP 进程、npm 包）
- 绑定特定 Claude Code 版本
- 解决的是"能力扩展"问题

### 框架思维

- 文件即配置，upgrade.sh 一键同步
- 零运行时，不引入任何外部依赖
- 跟 Claude Code 一起自然演进
- 解决的是"团队协作方式"问题

> 框架不替代 Claude Code 的能力，而是**定义团队如何使用这些能力**——规范工作流、明确角色分工、统一质量标准。

## 快速导航

- [[快速入门]]
- [[设计理念]]
- [[一、框架概述]]
`
}

// ─── MOC 生成 ──────────────────────────────────────────────────────

function generateMOCs() {
  const mocs = {}

  mocs['HCodeFlow MOC'] = `---
tags:
  - moc
  - hcodeflow
---

# HCodeFlow MOC

> 确定性优先的 AI 开发框架 — Spec-Driven Development
> 让 AI 在确定性空间里高速运转

## 入门

- [[快速入门]] — 从零到第一个 Feature
- [[设计理念]] — 三铁律、设计哲学
- [[概念速查表]] — 核心概念速查

## 架构与设计

- [[Design MOC]] — 架构详述系列（九篇）

## 实战案例

- [[Cases MOC]] — 真实项目案例记录

## 参考手册

- [[Reference MOC]] — Agents / Skills / Commands / Rules / 更新日志

## 学习资源

- [[Resources MOC]] — Claude Code 深度学习、技术随笔、方法论

## 帮助

- [[常见问题]] — 10 个高频问题
- [[故障排查指南]] — 按问题域分类的排查步骤
`

  mocs['Guide MOC'] = `---
tags:
  - moc
  - 指南
---

# Guide MOC

## 理念

- [[设计理念]] — No Spec No Code, Spec is Truth, No Approval No Execute

## 入门指南

- [[快速入门]] — 5 分钟速览 + 15 分钟动手 + 30 分钟深入
- [[概念速查表]] — 三铁律、七角色、四工作流
- [[项目接入检查清单]] — init-project 到完整配置
- [[工具速查]] — Shell 脚本和 Claude Code 命令速查
- [[动手练习手册]] — Q0/A/B 三种练习

## 帮助

- [[常见问题]] — 初始化/升级/工作流/环境问题
- [[故障排查指南]] — 五大问题域排查
`

  mocs['Design MOC'] = `---
tags:
  - moc
  - 架构设计
---

# Design MOC

> 框架架构详述系列，共九篇 + 测试用例附录

1. [[一、框架概述]] — 定位、核心理念、设计原则
2. [[二、架构设计]] — 分层架构、目录结构、子项目
3. [[三、Stub Marker 自动管理]] — marker 机制与版本管理
4. [[四、工作流体系]] — Q0/A/B/C 四种工作流
5. [[五、新项目接入指南]] — init-project 全流程
6. [[六、已接入项目的更新与维护]] — upgrade/harvest 双向同步
7. [[七、团队协作与框架迭代]] — 团队推广与反馈
8. [[八、核心工具参考]] — Shell 脚本和命令详解
9. [[九、附录]] — 术语表和版本历史

- [[框架遵从度测试用例]] — 框架合规性检查
`

  mocs['Reference MOC'] = `---
tags:
  - moc
  - 参考手册
---

# Reference MOC

> 参考手册，内容来自 core/ 目录源文件

- [[Agents 参考]] — 7 个 Agent 角色定义（含完整 prompt）
- [[Skills 参考]] — 技能包定义
- [[Commands 参考]] — 自定义命令
- [[Rules 参考]] — 协作规则、合并 SOP、调度规则
- [[更新日志]] — 版本历史
`

  mocs['Cases MOC'] = `---
tags:
  - moc
  - 实战案例
---

# Cases MOC

> 来自真实项目的完整案例，记录从需求到上线的全过程

- [[工作流 C 完整旅程]] — 预设问题管理，全栈联动，35 分钟
- [[v2 跨语言重构实战]] — Java→Python / Vue 2→Vue 3 全栈迁移
- [[新项目接入实践]] — AI Crawlers 初始化全流程
- [[Demo 工作流演练]] — Q0/A/B 三种工作流对比
- [[测试金字塔实战]] — 单元/集成/E2E 分层测试实践
`

  mocs['Resources MOC'] = `---
tags:
  - moc
  - 学习资源
---

# Resources MOC

> Claude Code 工程化实战、SDD 方法论和社区资源

## Claude Code 深度学习

- [[Hooks 精华整理]]
- [[Rules 精华整理]]
- [[Skills 精华整理]]
- [[SubAgent 完整指南]]

## 技术随笔

- [[v2.0 复盘与改进路线]]
- [[规则 ROI 审计报告]]
- [[子模块知识体系增强方法论思考]]
- [[Codex CLI 迁移指南]]
- [[OpenCode CLI 迁移指南]]
- [[浏览器自动化工具选型]]

## 方法论与社区

- [[SDD-RIPER 方法论]]
- [[培养你的直觉]]
- [[优质仓库推荐]]

## 飞书工具集成

- [[飞书通知集成指南]]
- [[lark-cli 安装与使用]]

## 运维指南

- [[CI-CD 自动化部署]]
`

  return mocs
}

// ─── 文件处理 ──────────────────────────────────────────────────────

/**
 * 处理单个文件
 */
function processFile(filePath, relativePath) {
  const content = readFileSync(filePath, 'utf-8')
  const { attrs, body } = parseFrontmatter(content)

  const isHomepage = attrs.layout === 'home'

  // 转换 frontmatter
  const newAttrs = transformFrontmatter(attrs, relativePath)

  // 转换内容
  let newBody
  if (isHomepage) {
    newBody = convertHomepage(attrs, body)
  } else {
    newBody = body
    newBody = convertDetailsBlocks(newBody)
    newBody = convertContainerBlocks(newBody)
    newBody = convertInternalLinks(newBody)
  }

  // 组装最终内容
  const newContent = serializeFrontmatter(newAttrs) + '\n' + newBody.trimStart() + '\n'

  // 确定目标文件名
  const targetName = FILE_TO_NAME.get(relativePath)
  if (!targetName) {
    console.warn(`  ⚠ 跳过（未在映射表中）: ${relativePath}`)
    return null
  }

  // 从源路径推导子文件夹：guide/xxx.md → guide/，根目录 index.md → 根目录
  const dir = relativePath.includes('/') ? relativePath.split('/')[0] : ''

  return { name: targetName + '.md', dir, content: newContent }
}

/**
 * 递归收集所有 .md 文件
 */
function collectMdFiles(dir, baseDir) {
  const results = []
  const entries = readdirSync(dir, { withFileTypes: true })

  for (const entry of entries) {
    if (entry.isDirectory()) {
      if (EXCLUDE_DIRS.has(entry.name)) continue
      results.push(...collectMdFiles(join(dir, entry.name), baseDir))
    } else if (entry.isFile() && extname(entry.name) === '.md') {
      results.push(join(dir, entry.name))
    }
  }

  return results
}

// ─── 主流程 ────────────────────────────────────────────────────────

function main() {
  console.log('🚀 HCodeFlow 文档 → Obsidian 迁移开始\n')

  // 确保目标目录存在
  if (!existsSync(TARGET_DIR)) {
    console.error(`❌ 目标目录不存在: ${TARGET_DIR}`)
    process.exit(1)
  }

  // 创建 attachments 目录
  const attachmentsDir = join(TARGET_DIR, 'attachments')
  if (!existsSync(attachmentsDir)) {
    mkdirSync(attachmentsDir, { recursive: true })
    console.log('📁 创建 attachments 目录')
  }

  // 收集所有 .md 文件
  const mdFiles = collectMdFiles(SOURCE_DIR, SOURCE_DIR)
  console.log(`📄 找到 ${mdFiles.length} 个 Markdown 文件\n`)

  let processed = 0
  let skipped = 0

  // 处理每个文件
  for (const filePath of mdFiles) {
    const relativePath = relative(SOURCE_DIR, filePath)
    const result = processFile(filePath, relativePath)

    if (!result) {
      skipped++
      continue
    }

    // 创建子文件夹并写入文件
    const subDir = result.dir ? join(TARGET_DIR, result.dir) : TARGET_DIR
    if (result.dir && !existsSync(subDir)) {
      mkdirSync(subDir, { recursive: true })
    }
    const targetPath = join(subDir, result.name)
    writeFileSync(targetPath, result.content, 'utf-8')
    const displayPath = result.dir ? `${result.dir}/${result.name}` : result.name
    console.log(`  ✅ ${displayPath} ← ${relativePath}`)
    processed++
  }

  // 生成 MOC 文件
  console.log('\n📝 生成 MOC 索引文件...\n')
  const mocs = generateMOCs()
  for (const [name, content] of Object.entries(mocs)) {
    const targetPath = join(TARGET_DIR, `${name}.md`)
    writeFileSync(targetPath, content, 'utf-8')
    console.log(`  ✅ ${name}.md`)
  }

  console.log(`\n✨ 迁移完成！共处理 ${processed} 篇文章，${Object.keys(mocs).length} 个 MOC 索引，跳过 ${skipped} 个文件`)
  console.log(`📂 目标目录: ${TARGET_DIR}`)
}

main()
