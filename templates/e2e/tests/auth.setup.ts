import { test as base, expect } from '@playwright/test'
import { apiLogin } from '../utils/api-login'

/**
 * 认证 setup —— API 直接登录并保存会话状态
 *
 * 不通过浏览器登录，直接用 HTTP API 完成：
 * 1. GET 验证码图片 → OCR
 * 2. POST 登录 API → 获取 token + 用户数据
 * 3. AES 加密后写入 .auth/session-storage.json
 *
 * 环境变量：
 * - E2E_BASE_URL：服务器地址（必填）
 * - E2E_USERNAME：用户名
 * - E2E_PASSWORD：密码
 * - E2E_MAX_OCR_ATTEMPTS：验证码 OCR 最大重试次数（默认 10）
 */

base('authenticate via API', async ({ page, context }) => {
  const baseURL = process.env.E2E_BASE_URL
  const username = process.env.E2E_USERNAME || 'aikg'
  const password = process.env.E2E_PASSWORD || 'admin123'
  const maxAttempts = parseInt(process.env.E2E_MAX_OCR_ATTEMPTS || '10', 10)

  if (!baseURL) {
    throw new Error('E2E_BASE_URL 环境变量未设置')
  }

  // API 直接登录（不走浏览器）
  const result = await apiLogin(baseURL, username, password, maxAttempts)

  // 验证登录结果
  expect(result.token).toBeTruthy()
  expect(Object.keys(result.sessionStorageData).length).toBeGreaterThan(0)

  // 导航到应用页面，注入 sessionStorage
  await page.goto(baseURL, { waitUntil: 'domcontentloaded', timeout: 30_000 })

  await page.evaluate((data) => {
    for (const [key, value] of Object.entries(data)) {
      sessionStorage.setItem(key, value as string)
    }
  }, result.sessionStorageData)

  // 验证 sessionStorage 注入成功
  const authUser = await page.evaluate(() => sessionStorage.getItem('authUser'))
  expect(authUser).toBeTruthy()

  // 保存 Playwright storageState（cookies + localStorage）
  await context.storageState({ path: '.auth/user.json' })

  // 验证能正常访问应用（不再跳转到 /login）
  await page.goto(baseURL, { waitUntil: 'domcontentloaded', timeout: 30_000 })
  await page.waitForTimeout(3000)

  const currentUrl = page.url()
  // 应该不在登录页
  expect(currentUrl).not.toContain('/login')
})
