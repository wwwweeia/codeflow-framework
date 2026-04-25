import * as fs from 'node:fs'
import * as path from 'node:path'
import matter from 'gray-matter'

// 路径常量
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '../../..')
const CORE = path.join(ROOT, 'core')
const DOCS = path.join(ROOT, 'docs')
const REF = path.join(DOCS, 'reference')

// Agent 名称映射（英文 → 中文）
const AGENT_NAMES: Record<string, string> = {
  'pm-agent': 'PM 产品经理',
  'arch-agent': 'Arch 架构师',
  'dev-agent': 'Dev 后端开发',
  'fe-agent': 'FE 前端开发',
  'qa-agent': 'QA 质量审查',
  'prototype-agent': 'Prototype 前端原型',
  'e2e-runner': 'E2E 端到端测试',
}

// ── 工具函数 ──

function ensureDir(dir: string) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
}

/** 截断 marker 行，只保留 marker 上方的框架管理内容 */
function stripMarker(content: string): string {
  return content.replace(/<!-- codeflow-framework:core[\s\S]*$/, '').trimEnd()
}

/** 将内容包装为 :::details 折叠块，## 标题降级为粗体避免污染页面 outline */
function wrapInDetails(summary: string, content: string): string {
  // ## 标题降级为粗体，避免 details 内标题出现在页面右侧 TOC
  let cleaned = content.replace(/^##\s+(.+)$/gm, '**$1**')
  // 转义代码块外的 HTML 标签（如 <module>、<template>），防止 Vue 模板编译报错
  // 保留 blockquote（> text）和代码块内的内容不变
  cleaned = escapeHtmlOutsideCode(cleaned)
  return `::: details ${summary}\n\n${cleaned}\n\n:::\n\n`
}

/** 转义 fenced code block 和 inline code 之外的 HTML 标签 */
function escapeHtmlOutsideCode(content: string): string {
  let inCodeBlock = false
  return content.split('\n').map(line => {
    if (/^(```|~~~)/.test(line.trimStart())) {
      inCodeBlock = !inCodeBlock
      return line
    }
    if (inCodeBlock) return line
    // 匹配 inline code（跳过）或 HTML 标签（转义）
    return line.replace(/(`[^`]*`)|(<\/?[a-zA-Z][a-zA-Z0-9:-]*(?:\s[^>]*)?>)/g, (m, code, tag) => {
      if (code) return code
      return tag.replace(/</g, '&lt;').replace(/>/g, '&gt;')
    })
  }).join('\n')
}

function parseFrontmatter(filePath: string): { data: Record<string, any>; content: string } {
  const raw = fs.readFileSync(filePath, 'utf-8')
  try {
    return matter(raw)
  } catch {
    // YAML 解析失败时，手动提取 frontmatter
    const match = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/)
    if (match) {
      return { data: { description: '' }, content: match[2] }
    }
    return { data: {}, content: raw }
  }
}

function extractTitle(content: string, fallback: string): string {
  const m = content.match(/^#\s+(.+)$/m)
  return m ? m[1] : fallback
}

function extractDescription(data: Record<string, any>): string {
  return data.description || ''
}

// ── 生成 Agents 页 ──

function generateAgentsPage(): string {
  const agentsDir = path.join(CORE, 'agents')
  const files = fs.readdirSync(agentsDir).filter(f => f.endsWith('.md')).sort()

  const agents = files.map(file => {
    const fp = path.join(agentsDir, file)
    const { data, content } = parseFrontmatter(fp)
    const name = file.replace('.md', '')
    return { name, data, content, file }
  })

  let md = `---
title: Agents 参考
description: 框架定义的 7 个 Agent 角色及其职责
outline:
  level: [2, 2]
---

# Agents 参考

> 框架通过 7 个 Agent 角色实现 Spec-Driven Development 工作流的自动化调度。
> 日常使用中你只需跟主对话交互，Agent 调度全自动完成。

`

  for (const agent of agents) {
    const label = AGENT_NAMES[agent.name] || agent.name
    const desc = extractDescription(agent.data)
    const tools = agent.data.tools ? agent.data.tools.join(', ') : '-'
    const model = agent.data.model || '-'
    const skills = agent.data.skills ? agent.data.skills.join(', ') : '-'

    md += `## ${label} (\`${agent.name}\`)\n\n`
    if (desc) md += `> ${desc}\n\n`
    md += `| 属性 | 值 |\n|------|-----|\n`
    md += `| 工具 | ${tools} |\n`
    md += `| 模型 | ${model} |\n`
    if (skills !== '-') md += `| 技能 | ${skills} |\n`
    md += `\n`

    // 提取正文的前几段作为摘要（去掉 YAML frontmatter 后）
    const lines = agent.content.trim().split('\n')
    let summaryLines: string[] = []
    for (const line of lines) {
      if (line.startsWith('#') || line.startsWith('---')) continue
      if (line.trim() === '') { if (summaryLines.length > 0) break; continue }
      summaryLines.push(line)
      if (summaryLines.length >= 3) break
    }
    if (summaryLines.length > 0) {
      md += summaryLines.join('\n') + '\n\n'
    }

    // 完整源文件内容（折叠）
    md += wrapInDetails('查看完整定义', stripMarker(agent.content))
  }

  return md
}

// ── 生成 Skills 页 ──

function generateSkillsPage(): string {
  const skillsDir = path.join(CORE, 'skills')
  const dirs = fs.readdirSync(skillsDir, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name)
    .sort()

  let md = `---
title: Skills 参考
description: 框架提供的 20+ 领域知识库与工具
outline:
  level: [2, 2]
---

# Skills 参考

> Skills 是按需加载的领域知识库，Agent 在执行任务时会根据需要自动引用。
> 每个 Skill 以目录形式组织，核心定义在 \`SKILL.md\` 文件中。

`

  for (const dir of dirs) {
    const skillFile = path.join(skillsDir, dir, 'SKILL.md')
    if (!fs.existsSync(skillFile)) continue

    const { data, content } = parseFrontmatter(skillFile)
    const desc = extractDescription(data)
    const title = extractTitle(content, dir)

    md += `## ${title}\n\n`
    md += `> 目录：\`core/skills/${dir}/\`\n\n`
    if (desc) md += `${desc}\n\n`

    // 提取前几段（只取段落文本，跳过所有标题）
    const lines = content.trim().split('\n')
    let summaryLines: string[] = []
    let pastTitle = false
    for (const line of lines) {
      if (!pastTitle && line.startsWith('# ')) { pastTitle = true; continue }
      if (line.startsWith('#')) continue
      if (line.startsWith('---')) continue
      if (line.trim() === '' && summaryLines.length > 0) break
      if (line.trim()) summaryLines.push(line)
      if (summaryLines.length >= 3) break
    }
    if (summaryLines.length > 0) {
      md += summaryLines.join('\n') + '\n\n'
    }

    // 完整源文件内容（折叠）
    md += wrapInDetails('查看完整定义', stripMarker(content))
  }

  return md
}

// ── 生成 Commands 页 ──

function generateCommandsPage(): string {
  const cmdsDir = path.join(CORE, 'commands')
  const files = fs.readdirSync(cmdsDir).filter(f => f.endsWith('.md')).sort()

  let md = `---
title: Commands 参考
description: 框架提供的 8 个自定义命令
outline:
  level: [2, 2]
---

# Commands 参考

> 在 Claude Code 中通过 \`/命令名\` 触发。命令定义在 \`core/commands/\` 目录下，
> 通过 \`upgrade.sh\` 同步到项目的 \`.claude/commands/\` 目录。

`

  for (const file of files) {
    const fp = path.join(cmdsDir, file)
    const { data, content } = parseFrontmatter(fp)
    const name = file.replace('.md', '')
    const desc = extractDescription(data)
    const hint = data['argument-hint'] || ''

    md += `## \`/${name}\`${hint ? ' `' + hint + '`' : ''}\n\n`
    if (desc) md += `> ${desc}\n\n`

    // 提取正文关键内容
    const lines = content.trim().split('\n')
    let bodyLines: string[] = []
    for (const line of lines) {
      if (line.startsWith('##') && bodyLines.length > 0) break
      if (line.startsWith('---')) continue
      bodyLines.push(line)
    }
    md += bodyLines.join('\n').trim() + '\n\n'

    // 完整源文件内容（折叠）
    md += wrapInDetails('查看完整定义', stripMarker(content))
  }

  return md
}

// ── 生成 Rules 页 ──

function generateRulesPage(): string {
  const rulesDir = path.join(CORE, 'rules')
  const files = fs.readdirSync(rulesDir).filter(f => f.endsWith('.md')).sort()

  const RULE_NAMES: Record<string, string> = {
    'project_rule': '全栈协作调度规则',
    'merge_checklist': '合并前检查清单',
    'framework_protection': '框架保护规则',
    'knowledge-protocol': '知识加载协议',
  }

  let md = `---
title: Rules 参考
description: 框架定义的工作流规则与检查清单
outline:
  level: [2, 2]
---

# Rules 参考

> Rules 是编码硬规则和工作流调度逻辑，自动加载到 Claude Code 会话中。
> 标记为"被管理"的规则由框架维护，marker 下方可追加项目特有规则。

`

  for (const file of files) {
    const fp = path.join(rulesDir, file)
    const { data, content } = parseFrontmatter(fp)
    const name = file.replace('.md', '')
    const label = RULE_NAMES[name] || name
    const desc = extractDescription(data)

    md += `## ${label} (\`${file}\`)\n\n`
    if (desc) md += `> ${desc}\n\n`

    // 只取前几段文本作为摘要（跳过标题，避免污染页面 outline）
    const lines = content.trim().split('\n')
    let summaryLines: string[] = []
    for (const line of lines) {
      if (line.startsWith('#') || line.startsWith('---')) continue
      if (line.trim() === '' && summaryLines.length > 0) continue
      if (line.trim()) summaryLines.push(line)
      if (summaryLines.length >= 5) break
    }
    md += summaryLines.join('\n') + '\n\n'

    // 完整源文件内容（折叠），替换原有的"完整内容参见"链接
    md += wrapInDetails('查看完整定义', stripMarker(content))
  }

  return md
}

// ── 生成 Changelog 页 ──

function generateChangelogPage(): string {
  const changelogPath = path.join(ROOT, 'CHANGELOG.md')
  if (!fs.existsSync(changelogPath)) {
    return `---
title: 更新日志
description: 框架版本历史
---

# 更新日志

> CHANGELOG.md 文件不存在。

`
  }

  const raw = fs.readFileSync(changelogPath, 'utf-8')
  // 去掉第一行标题，因为 VitePress frontmatter 已有 title
  // 将 < > 转义避免 Vue 解析为 HTML 标签
  const content = raw
    .replace(/^#\s+CHANGELOG\s*\n/, '')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

  return `---
title: 更新日志
description: codeflow-framework 版本历史与更新日志
---

# 更新日志

${content}
`
}

// ── 主流程 ──

/** 生成所有参考页，返回生成的文件路径列表 */
export function generateRefPages(): string[] {
  ensureDir(REF)

  const pages: Record<string, string> = {
    'agents.md': generateAgentsPage(),
    'skills.md': generateSkillsPage(),
    'commands.md': generateCommandsPage(),
    'rules.md': generateRulesPage(),
    'changelog.md': generateChangelogPage(),
  }

  const files: string[] = []
  for (const [filename, content] of Object.entries(pages)) {
    const filePath = path.join(REF, filename)
    fs.writeFileSync(filePath, content, 'utf-8')
    files.push(filePath)
  }
  return files
}

// CLI 入口
if (process.argv[1]?.endsWith('generate-ref.ts')) {
  const files = generateRefPages()
  for (const f of files) {
    const stat = fs.statSync(f)
    console.log(`✓ 生成 ${path.basename(f)} (${(stat.size / 1024).toFixed(1)} KB)`)
  }
  console.log(`\n完成！共生成 ${files.length} 个参考页面。`)
}
