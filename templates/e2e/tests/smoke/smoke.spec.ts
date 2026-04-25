import { test, expect } from '@playwright/test'

/**
 * 示例 E2E 测试 —— 烟雾测试
 *
 * 验证主应用和子应用的基本可达性。
 * 实际测试用例由 e2e-runner Agent 基于 02_technical_design.md Part E 动态生成。
 */
test.describe('烟雾测试', () => {
  test('主应用首页可访问', async ({ page }) => {
    await page.goto('/')
    // 未登录应重定向到 /login
    await expect(page).toHaveURL(/\/login/)
  })

  test('登录页元素完整', async ({ page }) => {
    await page.goto('/login')
    await expect(page.locator('.login-form')).toBeVisible()
    await expect(page.locator('.box-button')).toBeVisible()
  })
})
