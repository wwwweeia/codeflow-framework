---
name: e2e-testing
description: E2E 测试知识库。当需要为项目新 Feature 编写/运行 Playwright E2E 测试时加载。包含认证机制、选择器模式、POM 模板、项目结构约定、运行命令等关键知识。
---

# E2E 测试知识库

本 Skill 封装了 E2E 测试的全部关键技术决策和踩坑经验。适用于：
- e2e-runner Agent 执行测试时参考
- 主会话调度 E2E 测试时参考
- 新 Feature 编写 E2E 测试时的模板

---

## §1 认证机制与 Setup 模式

### 核心决策：API 直接登录（不走浏览器）

灵智 AI 登录需要验证码（OCR 不稳定），因此 **auth.setup.ts 使用 Node.js HTTP API 直接调用登录接口**，避免浏览器渲染。

**流程**：
```
auth.setup.ts:
  1. GET /api/uias-service/oauth/captcha?uuid=xxx → 验证码图片（二进制）
  2. Swift OCR 脚本识别 → 验证码文本（重试 < 1s/次）
  3. POST /api/uias-service/oauth/token → { token, userInfo, resourceTree, ... }
  4. AES-128-CBC 加密各字段 → 写入 .auth/session-storage.json
  5. page.evaluate() 注入 sessionStorage
  6. context.storageState() 保存 cookies（兼容 Playwright 机制）
```

**登录 API 参数**（multipart/form-data）：

| 参数 | 值 |
|------|------|
| username | 环境变量（默认 aikg） |
| password | MD5 哈希后的值 |
| captcha | OCR 识别结果 |
| uuid | 与验证码请求一致的 UUID |
| appCode | ai-kg |
| loginType | user |
| client_id | browser |
| client_secret | browser |
| tenantKey | 3a57a9ab730e40ae181533ebb703512c |

**响应结构**：`{ code: 0, data: { token, userInfo, resourceTree, orgTree, agentInfo, agentFunctionEnable } }`

### AES-128-CBC 加密参数

前端用 AES 加密后存入 sessionStorage（`ai-kg-front/plugins/encrytion.js`）：

```
Key: (storageKey + "9vApxLk5G3PAsJrM").slice(0, 16)
IV:  "FnJL7EDzjqWjcaY9"（硬编码）
模式: aes-128-cbc
输出: hex 字符串
```

加密后的 sessionStorage 键：

| 键名 | 加密前内容 |
|------|-----------|
| authUser | `JSON.stringify(token)` |
| permission | `JSON.stringify(resourceTree)` |
| info | `JSON.stringify(userInfo)` |
| org | `JSON.stringify(orgTree)` |
| agentInfo | `JSON.stringify(agentInfo)` |
| agentFunctionEnable | `String(boolean)`（未加密） |

**加密工具已封装在** `e2e/utils/encryption.ts`，API 登录已封装在 `e2e/utils/api-login.ts`。

### 测试文件中的 Session 注入

**关键：必须用 `page.addInitScript()` 在页面 JS 执行前注入，不能用 `page.evaluate()` 后注入。**

原因：Vue app 的 auth middleware 在页面加载时立即检查 sessionStorage。如果注入太晚，页面已经重定向到 `/login`。

```typescript
// tests/*.spec.ts
test.beforeEach(async ({ page }) => {
  const sessionData = JSON.parse(fs.readFileSync(SESSION_FILE, 'utf-8'))
  await page.addInitScript((data) => {
    for (const [key, value] of Object.entries(data)) {
      sessionStorage.setItem(key, value as string)
    }
  }, sessionData)
})
```

---

## §2 技术栈特定选择器模式

### Element UI + qiankun 微前端

| 陷阱 | 正确做法 |
|------|---------|
| 表格操作列有 `fixed="right"` | 操作按钮在 `.el-table__fixed-right` 中，常规 tbody 里的按钮是 **hidden** |
| `getByText('编辑')` 匹配到单元格数据 | 用 `getByRole('button', { name: '编辑' })` 精确匹配按钮，避免匹配包含"编辑"的文本 |
| loading mask 有多个 | `page.locator('.el-loading-mask').first()` 避免 strict mode |
| Dialog 关闭有动画 | 用 `await expect(dialog).not.toBeVisible({ timeout: 5000 })` 而非 `isDialogVisible()` |
| 子应用路由格式 | `/agentCenter/preset-questions`（注意大小写） |

### Operation 组件按钮文本

h-kg-agent-center 的 `<Operation>` 组件按钮文本**不是**常见语义：

| Operation flag | 实际文本 | 常见误写 |
|---------------|---------|---------|
| isAdd | **新建** | ~~新增~~ |
| isDel | **删除** | |
| isImport | **导入** | |
| isExport | **导出** | |

### SearchForm 组件按钮文本

| 按钮 | 实际文本 | 常见误写 |
|------|---------|---------|
| 提交 | **检索** | ~~搜索~~ |
| 重置 | **重置** | |

### 表格 fixed 列选择器模板

```typescript
// 操作按钮在 fixed-right 区域
private getFixedRow(rowIndex: number) {
  return this.table.locator(
    '.el-table__fixed-right .el-table__fixed-body-wrapper tbody tr'
  ).nth(rowIndex)
}

async clickEdit(rowIndex: number) {
  const btn = this.getFixedRow(rowIndex).getByText('编辑')
  await btn.waitFor({ state: 'visible', timeout: 10_000 })
  await btn.click()
}
```

---

## §3 POM 模板与约定

### BasePage 已封装方法

`e2e/pages/base.page.ts` 提供：

| 方法 | 用途 |
|------|------|
| `waitForSubApp(path)` | 等待 qiankun 子应用加载 |
| `waitForLoadingDismiss()` | 等待 Element UI loading 消失 |
| `waitForMessage(text)` | 等待 Element UI 消息提示 |
| `confirmMessageBox()` | 点击确认弹窗的确定按钮 |
| `screenshot(name)` | 截图保存为 evidence |

### 新 POM 模板

```typescript
import { Page, Locator, expect } from '@playwright/test'
import { BasePage } from './base.page'

export class XxxPage extends BasePage {
  readonly table: Locator
  readonly tableRows: Locator
  readonly pagination: Locator
  readonly dialog: Locator
  readonly dialogConfirmBtn: Locator

  constructor(page: Page) {
    super(page)
    this.table = page.locator('.xxx-page .el-table')
    this.tableRows = this.table.locator('tbody tr')
    this.pagination = page.locator('.xxx-page .el-pagination')
    this.dialog = page.locator('.el-dialog:visible').last()
    this.dialogConfirmBtn = this.dialog.locator('.el-button--primary')
  }

  async goto() {
    await this.page.goto('/agentCenter/xxx')
    await this.page.waitForLoadState('networkidle')
    await expect(this.table).toBeVisible({ timeout: 15_000 })
  }

  // fixed 列操作按钮
  private getFixedRow(rowIndex: number) {
    return this.table.locator(
      '.el-table__fixed-right .el-table__fixed-body-wrapper tbody tr'
    ).nth(rowIndex)
  }

  async clickAdd() {
    await this.page.getByText('新建').first().click()
    await expect(this.dialog).toBeVisible()
  }

  async clickEdit(rowIndex: number) {
    const btn = this.getFixedRow(rowIndex).getByRole('button', { name: '编辑' })
    await btn.waitFor({ state: 'visible', timeout: 10_000 })
    await btn.click()
    await expect(this.dialog).toBeVisible()
  }

  async submitDialog() {
    await this.dialogConfirmBtn.click()
  }

  async searchByKeyword(keyword: string) {
    const input = this.page.getByPlaceholder(/关键词/)
    await input.fill(keyword)
    await this.page.getByText('检索').first().click()
    await this.waitForLoadingDismiss()
  }
}
```

### 选择器优先级

1. `data-testid` — 最稳定（需前端配合添加）
2. `getByText()` / `getByRole()` — 语义化，较稳定
3. `.el-form-item` + `filter({ hasText: '标签名' })` — Element UI 表单定位
4. CSS 选择器 — 最后手段

---

## §4 运行命令

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| E2E_BASE_URL | https://192.168.104.125 | 被测服务器地址 |
| E2E_USERNAME | aikg | 登录用户名 |
| E2E_PASSWORD | admin123 | 登录密码 |
| E2E_HEADLESS | true | 是否无头模式 |
| E2E_MAX_OCR_ATTEMPTS | 10 | OCR 最大重试次数 |

### 执行命令

```bash
cd e2e

# 全量执行
npx playwright test

# 带 UI 可见浏览器
npx playwright test --headed

# 只跑某个文件
npx playwright test tests/xxx.spec.ts

# 只跑 setup（重新登录）
npx playwright test --project=setup --headed

# 查看 HTML 报告
npx playwright show-report
```

### Playwright 配置要点

- `workers: 1` — 串行执行（sessionStorage 不支持并行）
- `ignoreHTTPSErrors: true` — 内网 HTTPS 证书
- 两个 project：`setup`（登录） → `authenticated`（测试，依赖 setup）
- `authenticated` 使用 `storageState: '.auth/user.json'`

---

## §5 踩坑记录（避坑指南）

| 坑 | 原因 | 解决 |
|----|------|------|
| 页面总是跳转到 /login | `page.evaluate()` 注入 sessionStorage 太晚 | 用 `page.addInitScript()` 在 JS 执行前注入 |
| 编辑/删除按钮 found but not visible | Element UI `fixed="right"` 列有独立 DOM | 用 `.el-table__fixed-right` 选择器 |
| `strict mode violation: .el-loading-mask` | 页面同时存在多个 loading mask | 用 `.first()` |
| Dialog 关闭检测失败 | Dialog 有关闭动画，`isVisible()` 瞬间仍为 true | 用 `expect(dialog).not.toBeVisible({ timeout: 5000 })` |
| "新增"按钮找不到 | Operation 组件的添加按钮文本是 "新建" | 查看实际组件源码确认按钮文本 |
| "搜索"按钮找不到 | SearchForm 组件的搜索按钮文本是 "检索" | 同上 |
| `getByText('编辑')` 匹配到 `E2E编辑_xxx` | getByText 做子串匹配，单元格数据含"编辑" | 用 `getByRole('button', { name: '编辑' })` 精确匹配 |

---

## §6 故障分类与处理策略

测试失败时先分类再行动：

### A 类：E2E 技术问题（自行修复）

选择器不匹配、等待超时、Session 注入时机、OCR 登录失败、Element UI 组件交互模式等。

→ 参考 §2/§3 修复测试代码，重跑。**不上报主会话。**

### B 类：业务/应用问题（上报主会话）

| 症状 | 根因 | 上报 |
|------|------|------|
| API 返回非预期格式 | 前后端接口约定不一致 | 接口 URL + 期望 vs 实际 |
| API 500 / 超时 | 后端 bug / 性能 | 接口 URL + 错误信息 |
| 提交后数据未变 | 后端逻辑 bug | 请求体 + 响应体 |
| 按钮存在但无响应 | 前端事件缺失 | 组件路径 |
| 非预期验证失败 | 校验规则不一致 | 字段名 + 期望 vs 实际 |
| 缺少 UI 元素 | 功能未实现 | AC 编号 |
| 权限不足 | 用户缺权限 | resourceCode |

→ **不修改应用代码**，记录 evidence 后上报主会话，附截图 + 分类 + 修复方向。主会话派发 dev-agent 或 fe-agent 处理。

---

## §7 项目结构约定

### 目录布局

```
e2e/
├── tests/
│   ├── auth.setup.ts             # 认证 setup（框架模板提供）
│   ├── smoke/
│   │   └── smoke.spec.ts         # 烟雾测试
│   └── {feature-name}/           # 按 feature/spec 组织（项目特有）
│       └── {scenario}.spec.ts
├── pages/
│   ├── base.page.ts              # 通用基类（框架模板提供）
│   ├── login.page.ts             # 登录页（框架模板提供）
│   └── {page-name}.page.ts       # 业务页面 POM（项目特有）
├── fixtures/
│   └── auth.fixture.ts           # 认证 fixture（框架模板提供）
├── utils/
│   ├── api-login.ts              # API 登录（框架模板提供）
│   └── encryption.ts             # AES 加密（框架模板提供）
├── scripts/
│   └── read_captcha.swift        # OCR 脚本（框架模板提供）
├── .auth/                        # 认证产物（gitignore）
├── .evidence/{feature}/          # 运行时截图（gitignore）
├── playwright.config.ts
├── package.json
└── tsconfig.json
```

### Spec 到测试的映射规则

每个包含 Part E 的 Spec 对应 `e2e/tests/` 下的一个 feature 目录：

| Spec 目录 | Feature 名称 | 测试目录 |
|-----------|-------------|---------|
| `.claude/specs/test-preset-questions/` | `preset-questions` | `e2e/tests/preset-questions/` |
| `.claude/specs/feature-channel-mgmt/` | `channel-mgmt` | `e2e/tests/channel-mgmt/` |
| `.claude/specs/preset-question-import-export/` | `preset-question-import-export` | `e2e/tests/preset-question-import-export/` |

命名规则：去掉 spec 目录的 `test-` / `feature-` 前缀。

### 证据放置规则

| 类型 | 路径 | 说明 |
|------|------|------|
| 运行时截图 | `e2e/.evidence/{feature}/` | 已 gitignore，不提交到仓库 |
| 最终报告 | `.claude/specs/{spec-dir}/evidences/evidence-e2e.md` | 提交到仓库，长期存档 |
| 关键截图 | `.claude/specs/{spec-dir}/evidences/` | e2e-runner 复制关键截图到此目录 |

### 截图方法

`BasePage.screenshot(feature, name)` 将截图保存到 `.evidence/{feature}/{name}.png`：

```typescript
// 使用示例
await pqPage.screenshot('preset-questions', 'ac01')  // → .evidence/preset-questions/ac01.png
```

### 测试文件 import 路径

由于测试文件在 `tests/{feature}/` 子目录中，相对路径需要多退一层：

```typescript
// tests/preset-questions/crud.spec.ts
import { XxxPage } from '../../pages/xxx.page'
const SESSION_FILE = path.join(__dirname, '..', '..', '.auth', 'session-storage.json')
```
<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
