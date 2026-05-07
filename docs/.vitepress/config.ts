import { defineConfig, type Plugin } from 'vitepress'
import * as path from 'node:path'
import { generateRefPages } from './utils/generate-ref'

// 项目根目录（docs 的上级）
const ROOT = path.resolve(__dirname, '../..')

/** dev 模式下 watch core/ 和 CHANGELOG.md，自动重新生成参考页 */
function hmrRefPages(): Plugin {
  const coreDir = path.resolve(ROOT, 'core')
  const changelogFile = path.resolve(ROOT, 'CHANGELOG.md')

  return {
    name: 'hmr-ref-pages',
    configureServer(server) {
      // 将外部目录加入 watcher
      server.watcher.add(coreDir)
      server.watcher.add(changelogFile)

      server.watcher.on('all', (event, file) => {
        if (event !== 'change' && event !== 'unlink') return
        if (!file.startsWith(coreDir) && file !== changelogFile) return
        // 只关心 .md 文件
        if (!file.endsWith('.md')) return

        console.log(`[hmr-ref-pages] 检测到 ${path.relative(ROOT, file)} 变更，重新生成参考页...`)
        generateRefPages()
      })
    },
  }
}

export default defineConfig({
  // GitHub Pages: '/codeflow-framework/'，GitLab Pages: '/h-codeflow-framework/'，本地预览: '/'
  base: '/codeflow-framework/',

  // GitLab Pages 要求输出到项目根目录的 public/
  outDir: '../public',
  cacheDir: '.vitepress/cache',

  // 自动生成的参考页中可能包含相对链接，忽略死链接检查
  ignoreDeadLinks: true,

  lang: 'zh-CN',
  title: 'HCodeFlow',
  description: '确定性优先的 AI 开发框架，用结构化规范把不确定性消除在执行之前',

  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { property: 'og:title', content: 'HCodeFlow' }],
    ['meta', { property: 'og:description', content: '确定性优先的 AI 开发框架' }],
  ],

  markdown: {
    lineNumbers: true,
  },

  vite: {
    plugins: [hmrRefPages()],
  },

  themeConfig: {
    logo: '/logo.svg',

    // ── 顶部导航 ──
    nav: [
      { text: '入门', link: '/getting-started/what-is-sdd' },
      { text: '项目接入', link: '/integration/new-project' },
      { text: '架构详述', link: '/design/overview' },
      { text: '案例', link: '/cases/' },
      { text: '学习资源', link: '/resources/' },
      {
        text: '参考手册',
        items: [
          { text: 'Agents', link: '/reference/agents' },
          { text: 'Skills', link: '/reference/skills' },
          { text: 'Commands', link: '/reference/commands' },
          { text: 'Rules', link: '/reference/rules' },
          { text: '更新日志', link: '/reference/changelog' },
        ],
      },
      {
        text: '帮助',
        items: [
          { text: '常见问题', link: '/getting-started/faq' },
          { text: '故障排查', link: '/getting-started/troubleshooting' },
        ],
      },
      {
        text: 'GitLab',
        link: 'https://gitlab.huaun.com/rd.huaun/h-codeflow-framework',
      },
    ],

    // ── 侧边栏 ──
    sidebar: {
      '/getting-started/': [
        {
          text: '认识框架',
          items: [
            { text: '认识 SDD', link: '/getting-started/what-is-sdd' },
            { text: '快速入门', link: '/getting-started/quick-start' },
            { text: '端到端教程', link: '/getting-started/tutorial' },
          ],
        },
        {
          text: '深入理解',
          items: [
            { text: '概念详解', link: '/getting-started/concepts' },
            { text: '术语速查', link: '/getting-started/glossary' },
            { text: '设计理念', link: '/getting-started/philosophy' },
          ],
        },
        {
          text: '工具与练习',
          items: [
            { text: '工具速查', link: '/getting-started/tools' },
            { text: '动手练习', link: '/getting-started/exercises' },
          ],
        },
        {
          text: '帮助',
          items: [
            { text: '常见问题', link: '/getting-started/faq' },
            { text: '故障排查', link: '/getting-started/troubleshooting' },
            { text: '框架反馈', link: '/getting-started/feedback' },
          ],
        },
      ],
      '/integration/': [
        {
          text: '项目接入',
          items: [
            { text: '新项目接入', link: '/integration/new-project' },
            { text: '已有项目', link: '/integration/existing-project' },
            { text: '团队接入', link: '/integration/team-onboarding' },
          ],
        },
      ],
      '/design/': [
        {
          text: '架构详述',
          items: [
            { text: '一、框架概述', link: '/design/overview' },
            { text: '二、架构设计', link: '/design/architecture' },
            { text: '三、Stub Marker 自动管理', link: '/design/marker' },
            { text: '四、工作流体系', link: '/design/workflow' },
            { text: '五、新项目接入指南', link: '/design/integration' },
            { text: '六、已接入项目的更新与维护', link: '/design/maintenance' },
            { text: '七、团队协作与框架迭代', link: '/design/collaboration' },
            { text: '八、核心工具参考', link: '/design/tools' },
            { text: '框架遵从度测试用例', link: '/design/compliance-tests' },
            { text: '九、附录', link: '/design/appendix' },
          ],
        },
      ],
      '/reference/': [
        {
          text: '参考手册',
          items: [
            { text: 'Agents', link: '/reference/agents' },
            { text: 'Skills', link: '/reference/skills' },
            { text: 'Commands', link: '/reference/commands' },
            { text: 'Rules', link: '/reference/rules' },
            { text: '更新日志', link: '/reference/changelog' },
          ],
        },
      ],
      '/cases/': [
        {
          text: '实战案例',
          items: [
            { text: '案例索引', link: '/cases/' },
            { text: '工作流 C 完整旅程', link: '/cases/workflow-c-preset-questions' },
            { text: 'v2 跨语言重构实战', link: '/cases/v2-refactor' },
            { text: '新项目接入实践', link: '/cases/init-practice' },
            { text: 'Demo 工作流演练', link: '/cases/demo-walkthrough' },
            { text: '测试金字塔实战', link: '/cases/testing-pyramid-practice' },
          ],
        },
      ],
      '/resources/': [
        {
          text: '学习资源',
          items: [
            { text: '资源索引', link: '/resources/' },
          ],
        },
        {
          text: 'Claude Code 深度学习',
          items: [
            { text: 'Hooks 精华整理', link: '/resources/claude-code-hooks' },
            { text: 'Rules 精华整理', link: '/resources/claude-code-rules' },
            { text: 'Skills 精华整理', link: '/resources/claude-code-skills' },
            { text: 'SubAgent 完整指南', link: '/resources/claude-code-subagent' },
          ],
        },
        {
          text: '技术随笔',
          items: [
            { text: 'v2.0 复盘与改进路线', link: '/resources/framework-retrospective-v2' },
            { text: '规则 ROI 审计报告', link: '/resources/rule-roi-audit' },
            { text: '子模块知识体系增强方法论思考', link: '/resources/submodule-knowledge-system' },
            { text: 'Codex CLI 迁移指南', link: '/resources/codex-migration' },
            { text: 'OpenCode CLI 迁移指南', link: '/resources/opencode-migration' },
            { text: '浏览器自动化工具选型', link: '/resources/browser-automation-tools-2026' },
          ],
        },
        {
          text: '方法论与社区',
          items: [
            { text: 'SDD-RIPER 方法论', link: '/resources/sdd-riper-methodology' },
            { text: 'GitHub spec-kit 全景解读', link: '/resources/github-spec-kit' },
            { text: '培养你的直觉', link: '/resources/building-intuition' },
            { text: 'Superpowers 深度解读', link: '/resources/superpowers-deep-dive' },
            { text: '优质仓库推荐', link: '/resources/claude-code-awesome-repos' },
          ],
        },
        {
          text: '飞书工具集成',
          items: [
            { text: '飞书通知集成指南', link: '/resources/claude-code-feishu-notify' },
            { text: 'lark-cli 安装与使用', link: '/resources/lark-cli-guide' },
          ],
        },
        {
          text: '运维指南',
          items: [
            { text: 'CI/CD 自动化部署', link: '/resources/watchtower-cicd-guide' },
          ],
        },
      ],
    },

    // ── 搜索（本地） ──
    search: {
      provider: 'local',
      options: {
        locales: {
          zh: {
            translations: {
              button: { buttonText: '搜索文档' },
              modal: {
                noResultsText: '无法找到相关结果',
                resetButtonTitle: '清除查询条件',
                footer: { selectText: '选择', navigateText: '切换', closeText: '关闭' },
              },
            },
          },
        },
      },
    },

    // ── 编辑链接 ──
    editLink: {
      pattern:
        'https://gitlab.huaun.com/rd.huaun/h-codeflow-framework/-/edit/develop/docs/:path',
      text: '在 GitLab 上编辑此页面',
    },

    // ── 页脚 ──
    footer: {
      // message: 'Huaun AI Group',
      copyright: 'Copyright ©️ 2026, 北京华云安信息技术有限公司',
    },

    // ── 其他 ──
    lastUpdated: {
      text: '最后更新于',
      formatOptions: { dateStyle: 'medium', timeStyle: 'short' },
    },
    outline: { level: [2, 3], label: '本页目录' },
    docFooter: { prev: '上一篇', next: '下一篇' },
    returnToTopLabel: '回到顶部',
    sidebarMenuLabel: '菜单',
    darkModeSwitchLabel: '主题',
    lightModeSwitchTitle: '切换到浅色模式',
    darkModeSwitchTitle: '切换到深色模式',
  },
})
