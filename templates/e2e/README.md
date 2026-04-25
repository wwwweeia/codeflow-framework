# E2E 测试套件

基于 Playwright 的端到端测试框架模板，通过 `init-e2e.sh` 初始化到下游项目后使用。

## 前置条件

- Node.js 18+（推荐通过 nvm 管理）
- macOS（验证码 OCR 依赖系统 Swift）
- 目标应用可访问

```bash
# 确保 nvm 已加载
source ~/.nvm/nvm.sh
node -v   # 确认 >= 18

# 安装依赖（首次或 package.json 变更后）
cd e2e && npm install
```

## 初始化

在项目根目录执行：

```bash
sh ../codeflow-framework/templates/e2e/init-e2e.sh . "project-name"
```

初始化完成后：

1. 配置环境变量：`cp .env.example .env`，填写实际服务器地址和账号
2. 安装浏览器：`npx playwright install chromium`

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `E2E_BASE_URL` | `https://localhost` | 被测应用地址（必填） |
| `E2E_USERNAME` | `aikg` | 登录用户名 |
| `E2E_PASSWORD` | `admin123` | 登录密码 |
| `E2E_HEADLESS` | `true` | 无头模式，设 `false` 打开浏览器 |
| `E2E_MAX_OCR_ATTEMPTS` | `10` | 验证码 OCR 最大重试次数 |

默认值已内置在 `playwright.config.ts`，配置 `.env` 文件后即可运行。如需临时指定目标服务器：

```bash
E2E_BASE_URL=https://your-server npx playwright test
```

## 运行测试

```bash
cd e2e

# 跑全部测试
npx playwright test

# 跑指定功能模块
npx playwright test tests/your-feature/

# 跑单个用例（按标题匹配）
npx playwright test -g "用例标题"

# 有界面模式（可以看到浏览器操作过程）
npx playwright test --headed

# 调试模式（逐步执行，可暂停检查）
npx playwright test --debug
```

## 认证机制

测试不走浏览器登录页面，而是 **直接用 HTTP API 模拟登录**，拿到 token 后伪装成"已登录状态"注入给浏览器。这样可以避开验证码输入、按钮点击等不稳定的 UI 操作。

### API 登录流程

核心逻辑在 `utils/api-login.ts`，分四步：

```
① GET /api/uias-service/oauth/captcha?uuid=xxx
   └─→ 拿到验证码图片，保存到 .auth/captcha.png

② 调用 Swift OCR 脚本识别出 4 位字符（如 "BMUU"）

③ POST /api/uias-service/oauth/token  (multipart/form-data)
   ├─ username: xxx
   ├─ password: md5("xxx")
   ├─ captcha: "BMUU"     ← ② 的识别结果
   ├─ uuid: "xxx"         ← ① 同一个 UUID（关键！后端靠它关联验证码）
   └─ appCode, loginType, client_id ...
   └─→ 返回 token + userInfo + resourceTree

④ 把返回数据 AES 加密 → 写入 .auth/session-storage.json
```

**关键点：UUID 是纽带**。验证码请求和登录请求必须用同一个 UUID，后端靠它关联"哪张验证码对应哪次登录"。

### 登录态注入到浏览器

API 登录拿到的是后端返回的原始数据，但前端应用通过 `sessionStorage` 判断登录状态。所以需要把数据"塞"进浏览器：

1. `auth.setup.ts` 在 setup 阶段完成 API 登录，将加密后的认证数据写入 `.auth/session-storage.json`
2. 每个业务测试通过 `page.addInitScript()` 或 Playwright `storageState` 机制注入到浏览器
3. 前端路由守卫检查 `sessionStorage` 里有 `authUser`，就不会跳转到登录页

```typescript
// sessionStorage 注入示例
await page.evaluate((data) => {
  for (const [key, value] of Object.entries(data)) {
    sessionStorage.setItem(key, value as string)
  }
}, sessionData)
```

`addInitScript` 的时序很重要——它在页面 JS 执行前注入，确保路由守卫检查时 sessionStorage 已经有值。

### Playwright 两阶段项目配置

`playwright.config.ts` 定义了两个 project，保证 setup 先跑、业务测试后跑：

| project | 匹配文件 | 作用 |
|---------|---------|------|
| `setup` | `auth.setup.ts` | API 登录，保存 `.auth/user.json` + `session-storage.json` |
| `authenticated` | `*.spec.ts` | 依赖 setup 完成，使用 `storageState` 注入 cookie/localStorage |

setup 会在每次 `npx playwright test` 时自动执行，无需手动操作。

## 目录结构

```
e2e/
├── playwright.config.ts    # Playwright 配置（项目定义、浏览器选项）
├── tests/
│   ├── auth.setup.ts       # 登录 setup（自动执行）
│   └── smoke/              # 烟雾测试（页面可达性）
├── pages/                  # Page Object Model 页面对象
│   ├── base.page.ts        # POM 基类（通用等待、截图、Element UI 操作）
│   └── login.page.ts       # 登录页 POM
├── fixtures/
│   └── auth.fixture.ts     # 认证 fixture（提供已登录状态）
├── utils/
│   ├── api-login.ts        # API 登录模块
│   └── encryption.ts       # AES 加密
├── scripts/
│   └── read_captcha.swift  # 验证码 OCR 脚本
├── .auth/                  # 登录态文件（已 gitignore）
├── .evidence/              # 测试截图证据（已 gitignore）
├── .env.example            # 环境变量模板
└── .gitignore
```

## POM 模式

所有页面对象继承 `BasePage`（`pages/base.page.ts`），它封装了：

- `waitForSubApp(path)` — 等待 qiankun 子应用加载完成
- `waitForLoadingDismiss()` — 等待 Element UI loading 遮罩消失
- `confirmMessageBox()` — 点击 Element UI 确认弹窗
- `waitForMessage(text)` — 等待 Element UI 消息提示
- `screenshot(feature, name)` — 截图保存到 `.evidence/`

编写新页面时，继承 `BasePage` 并按需暴露 Locator：

```typescript
import { Page, Locator } from '@playwright/test'
import { BasePage } from './base.page'

export class SomePage extends BasePage {
  readonly someButton: Locator

  constructor(page: Page) {
    super(page)
    this.someButton = page.getByRole('button', { name: '操作' })
  }

  async goto() {
    await this.page.goto('/some-path')
    await this.waitForLoadingDismiss()
  }
}
```

## 查看测试报告

```bash
# 测试完成后查看 HTML 报告（含截图、录屏、trace）
npx playwright show-report
```

如果测试失败，Playwright 会自动在 `test-results/` 下保存截图和录屏，报告里可以直接查看。

## 常见问题

**Q: 验证码 OCR 一直失败？**

登录 setup 会自动重试（默认最多 10 次），通常 2-3 次内成功。如果持续失败，检查：
- 目标服务器是否可达
- Swift 是否可用：`swift --version`

**Q: 测试超时？**

默认单用例 60 秒超时。如果网络较慢，可适当调大 `playwright.config.ts` 中的 `timeout`。

**Q: 想看浏览器操作过程？**

加 `--headed` 参数，或在 `.env` 中设 `E2E_HEADLESS=false`。

**Q: `npx: command not found`？**

nvm 未加载，先执行 `source ~/.nvm/nvm.sh`。

**Q: 不需要认证的项目怎么用？**

如果项目没有登录页面，删除 `auth.setup.ts`，将 `playwright.config.ts` 中的 `projects` 简化为单一 project，移除 `storageState` 配置即可。参考 demo 项目的简化配置。
