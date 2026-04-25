import { defineConfig, devices } from '@playwright/test'

/**
 * AI Prompt Lab E2E 测试配置
 *
 * 简化版：无需认证，直接测试 Vue SPA 页面
 *
 * 环境变量：
 * - E2E_BASE_URL：前端地址（默认 http://localhost:5173）
 * - E2E_HEADLESS：是否无头模式（默认 true）
 */
export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: [
    ['html', { open: 'never' }],
    ['list'],
  ],
  timeout: 30_000,
  expect: {
    timeout: 5_000,
  },

  use: {
    baseURL: process.env.E2E_BASE_URL || 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    headless: process.env.E2E_HEADLESS !== 'false',
  },

  projects: [
    {
      name: 'tests',
      testMatch: /.*\.spec\.ts/,
      use: { ...devices['Desktop Chrome'] },
    },
  ],
})
