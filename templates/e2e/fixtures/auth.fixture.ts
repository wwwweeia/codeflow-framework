import { test as base, expect } from '@playwright/test'
import { LoginPage } from '../pages/login.page'

/**
 * 认证状态类型
 */
type AuthFixture = {
  loginPage: LoginPage
  /** 已登录的 page（自动完成登录流程并保存状态） */
  authenticatedPage: typeof base
}

/**
 * 扩展 test fixture，提供：
 * - loginPage：登录页 POM
 * - authenticatedPage：已完成登录的页面（用于需要登录态的测试）
 */
export const test = base.extend<{
  loginPage: LoginPage
}>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page)
    await use(loginPage)
  },
})

/**
 * 创建已认证的测试
 *
 * 使用方式：
 * ```typescript
 * import { createAuthTest } from '../fixtures/auth.fixture'
 * const authTest = createAuthTest()
 *
 * authTest('测试需要登录的功能', async ({ page }) => {
 *   await page.goto('/some-protected-page')
 *   // 已处于登录态
 * })
 * ```
 */
export function createAuthTest() {
  return base.extend<{
    storageState: string
  }>({
    storageState: async ({}, use) => {
      // 使用 PLAYWRIGHT_AUTH_FILE 环境变量指定的 storageState 文件
      const authFile = process.env.PLAYWRIGHT_AUTH_FILE || '.auth/user.json'
      await use(authFile)
    },
  })
}

export { expect }
