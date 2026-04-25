import { Page, Locator, expect } from '@playwright/test'
import { BasePage } from './base.page'

/**
 * 登录页 POM
 *
 * 路由：/login
 * 注意：E2E 测试使用 API 直接登录（auth.setup.ts），此 POM 仅用于需要浏览器登录的场景
 */
export class LoginPage extends BasePage {
  readonly usernameInput: Locator
  readonly passwordInput: Locator
  readonly captchaInput: Locator
  readonly captchaImage: Locator
  readonly submitButton: Locator

  constructor(page: Page) {
    super(page)
    this.usernameInput = page.locator('.login-form .el-form-item').nth(0).getByRole('textbox')
    this.passwordInput = page.locator('.login-form .el-form-item').nth(1).getByRole('textbox')
    this.captchaInput = page.locator('.login-form .el-form-item').nth(2).getByRole('textbox')
    this.captchaImage = page.locator('.captcha-trigger img')
    this.submitButton = page.locator('.login-form .box-button')
  }

  async goto() {
    await this.page.goto('/login')
    await expect(this.submitButton).toBeVisible()
  }

  /**
   * 执行登录（不含验证码的场景需自行处理）
   * 生产环境有验证码，E2E 测试环境下建议关闭验证码或提供万能验证码
   */
  async login(username: string, password: string, captcha = '0000') {
    await this.usernameInput.fill(username)
    await this.passwordInput.fill(password)
    await this.captchaInput.fill(captcha)
    await this.submitButton.click()
  }

  /**
   * 等待登录完成 —— URL 离开 /login 页面
   */
  async waitForLoginSuccess(timeout = 10_000) {
    await this.page.waitForURL(url => !url.toString().includes('/login'), { timeout })
  }
}
