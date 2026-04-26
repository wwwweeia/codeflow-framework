---
name: vitepress-docs
description: VitePress 文档站最佳实践。包含主题定制、CSS 变量系统、排版规范、内容展示模式。
  Use when creating or improving a VitePress documentation site, customizing theme, or writing documentation content.
argument-hint: "[theme|typography|layout|content|containers]"
allowed-tools: [Read, Grep, Glob, Bash]
---

# VitePress 文档站最佳实践

> 本 Skill 是框架文档站（`docs/`）的主题定制与内容排版参考。修改文档站样式或结构时加载。

---

## §1 CSS 变量系统

VitePress 通过 CSS 变量控制全局视觉。覆盖这些变量比写自定义 CSS 更稳定、更易维护。

### 品牌色 4 级体系

```css
:root {
  --vp-c-brand-1: #4f46e5;                    /* 主色 — 链接、按钮文字 */
  --vp-c-brand-2: #6366f1;                    /* 悬停态 */
  --vp-c-brand-3: #4338ca;                    /* 实底背景（按钮底色） */
  --vp-c-brand-soft: rgba(79, 70, 229, 0.14); /* 淡底色（badge、标签） */
}
.dark {
  --vp-c-brand-1: #a5b4fc;
  --vp-c-brand-2: #818cf8;
  --vp-c-brand-3: #6366f1;
  --vp-c-brand-soft: rgba(165, 180, 252, 0.16);
}
```

**命名规则**：`--vp-c-brand-{1|2|3|soft}` — 1 = 主文字/链接，2 = 悬停，3 = 实底，soft = 淡底。

### 文字层级

| 变量 | 用途 |
|------|------|
| `--vp-c-text-1` | 正文主色 |
| `--vp-c-text-2` | 二级文字（描述、标签） |
| `--vp-c-text-3` | 三级文字（占位、禁用） |

### 背景层级

| 变量 | 用途 |
|------|------|
| `--vp-c-bg` | 页面主背景 |
| `--vp-c-bg-alt` | 交替区域背景 |
| `--vp-c-bg-soft` | 卡片、代码块背景 |
| `--vp-c-bg-mute` | 更深的强调背景 |

### 其他常用变量

| 变量 | 用途 |
|------|------|
| `--vp-c-divider` | 分隔线颜色 |
| `--vp-c-gutter` | 侧边栏分割线 |
| `--vp-font-family-base` | 正文字体 |
| `--vp-font-family-mono` | 代码字体 |
| `--vp-nav-height` | 导航栏高度 |
| `--vp-sidebar-width` | 侧边栏宽度 |

### Hero 专属变量

```css
:root {
  --vp-home-hero-name-color: transparent;
  --vp-home-hero-name-background: -webkit-linear-gradient(120deg, #4f46e5, #0ea5e9);
  --vp-home-hero-image-background-image: linear-gradient(-45deg, #4f46e5 50%, #0ea5e9 50%);
  --vp-home-hero-image-filter: blur(44px);
}
```

---

## §2 排版与字体

### 中文站默认字体

VitePress 1.6.x 内置 `:lang(zh)` 支持，默认字体栈已覆盖中文，通常无需自定义 `--vp-font-family-base`。

### 代码字体

```css
:root {
  --vp-font-family-mono: 'JetBrains Mono', 'Fira Code', ui-monospace, monospace;
}
```

### 标题层级约定

| 层级 | 用于 | VitePress 渲染 |
|------|------|---------------|
| `h1` | 页面标题（frontmatter title） | 大标题，自动生成 |
| `h2` | 章节标题 | outline 导航第一级 |
| `h3` | 子节标题 | outline 导航第二级 |
| `h4+` | 细节补充 | 不进 outline |

> `outline` 配置控制哪些层级出现在右侧目录。推荐 `level: [2, 3]`。

---

## §3 内容展示模式

### Container 类型对照

VitePress 内置 5 种容器，直接在 Markdown 中使用：

```markdown
::: tip
推荐做法的说明
:::

::: info
补充信息
:::

::: warning
需要注意的潜在问题
:::

::: danger
严重警告，可能导致数据丢失或安全问题
:::

::: details 点击展开
默认折叠的内容，适合 FAQ 或冗长细节
:::
```

**选择指南**：
- 推荐做法 → `tip`（绿色）
- 中性信息 → `info`（蓝色）
- 注意事项 → `warning`（橙色）
- 严重警告 → `danger`（红色）
- 折叠内容 → `details`

### 表格样式

```css
/* 防止标签列换行 */
.vp-doc table th:first-child,
.vp-doc table td:first-child {
  white-space: nowrap;
}

/* 宽表格水平滚动 */
.vp-doc table {
  display: table;
  width: 100%;
}
```

### 代码块

**行号**：在 `config.ts` 中开启：
```typescript
markdown: { lineNumbers: true }
```

**行高亮**：在代码块语言后加 `{4-6}` 或 `{2,5}`：
````markdown
```typescript {4-6}
const config = defineConfig({
  title: 'HCodeFlow',
  lang: 'zh-CN',    // 这行高亮
  description: '...', // 这行高亮
  head: [],           // 这行高亮
})
```
````

**代码分组**：多个语言版本的代码并列展示：
````markdown
::: code-group
```bash
npm install
```
```bash
yarn install
```
```bash
pnpm install
```
:::
````

### Badge 徽章

在文字后标注状态：
```markdown
* 核心规则 <Badge type="danger" text="必须" />
* 可选配置 <Badge type="info" text="可选" />
* 已废弃 <Badge type="warning" text="废弃" />
```

---

## §4 自定义组件

### 注册模式

在 `docs/.vitepress/theme/index.ts` 中注册全局组件：

```typescript
import DefaultTheme from 'vitepress/theme'
import MyComponent from './components/MyComponent.vue'
import './style.css'

export default {
  ...DefaultTheme,
  enhanceApp({ app }) {
    app.component('MyComponent', MyComponent)
  }
}
```

### 全局 CSS 叠加

在 `docs/.vitepress/theme/style.css` 中覆盖默认样式：
- 优先使用 CSS 变量覆盖，而非硬编码选择器
- 自定义组件样式写在同一文件中，通过类名隔离

### 首页自定义区域

`index.md` 的 `<style>` 块用于首页独有的组件样式（如对比卡片、层级图示等），**通用变量**（品牌色、hero 渐变）应放在 `style.css` 中统一管理。

---

## §5 导航与内容组织

### Sidebar 分组模式

```typescript
sidebar: {
  '/guide/': [
    {
      text: '章节名',
      items: [
        { text: '页面标题', link: '/guide/page-slug' },
      ]
    }
  ]
}
```

**约定**：
- 每个路由前缀对应一个 sidebar 配置
- `text` 用简洁的章节名，`link` 用 kebab-case 路径
- 最多 2 级嵌套（text → items → link）

### Nav 下拉

```typescript
nav: [
  {
    text: '参考手册',
    items: [
      { text: 'Agents', link: '/reference/agents' },
    ]
  }
]
```

### Frontmatter 约定

```yaml
---
title: 页面标题          # 必填，SEO + 浏览器标签
description: 页面描述     # 必填，SEO snippet
prev: /guide/prev-page   # 可选，底部导航
next: /guide/next-page   # 可选，底部导航
layout: doc              # 默认 doc，首页用 home
---
```

---

## §6 配置速查

### head meta（链接预览）

```typescript
head: [
  ['link', { rel: 'icon', href: '/favicon.ico' }],
  ['meta', { property: 'og:title', content: 'HCodeFlow' }],
  ['meta', { property: 'og:description', content: '确定性优先的 AI 开发框架' }],
]
```

### 搜索中文化

```typescript
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
}
```

### 编辑链接

```typescript
editLink: {
  pattern: 'https://gitlab.example.com/group/repo/-/edit/develop/docs/:path',
  text: '在 GitLab 上编辑此页面',
}
```

### 其他推荐配置

```typescript
outline: { level: [2, 3], label: '本页目录' },
lastUpdated: { text: '最后更新于' },
docFooter: { prev: '上一篇', next: '下一篇' },
footer: {
  message: '团队名',
  copyright: 'Copyright © 2026 Company',
},
```
