import { Page, Locator, expect } from '@playwright/test'
import { BasePage } from './base.page'

/**
 * 首页 POM
 */
export class HomePage extends BasePage {
  readonly heroTitle: Locator
  readonly subtitle: Locator
  readonly welcomeBanner: Locator
  readonly statsRow: Locator
  readonly statItems: Locator

  constructor(page: Page) {
    super(page)
    this.heroTitle = page.locator('.hero h1')
    this.subtitle = page.locator('.hero .subtitle')
    this.welcomeBanner = page.locator('.welcome-banner')
    this.statsRow = page.locator('.stats')
    // Element Plus el-col 直接子元素包含每个统计项
    this.statItems = page.locator('.stats .el-col')
  }

  async goto() {
    await this.page.goto('/')
    await this.page.waitForLoadState('networkidle')
    await expect(this.heroTitle).toBeVisible()
  }

  async getTitle(): Promise<string> {
    return this.heroTitle.innerText()
  }

  async getStatValues(): Promise<Record<string, number>> {
    const result: Record<string, number> = {}
    const count = await this.statItems.count()
    for (let i = 0; i < count; i++) {
      const item = this.statItems.nth(i)
      // el-statistic 内部：第一个 div 是标题，第二个 div 是数值
      const titleEl = item.locator('div > div').first()
      const valueEl = item.locator('div > div').last()
      const title = await titleEl.innerText()
      const value = await valueEl.innerText()
      result[title.trim()] = parseInt(value, 10)
    }
    return result
  }

  async closeBanner() {
    // Element Plus alert 关闭按钮是 el-alert 内最后一个 img 元素
    const closeBtn = this.welcomeBanner.locator('.el-alert__close-btn')
    if (await closeBtn.count() === 0) {
      // 回退：使用 alert 内可点击的 img
      const imgs = this.welcomeBanner.locator('img')
      const count = await imgs.count()
      if (count > 0) {
        await imgs.nth(count - 1).click()
        return
      }
    }
    await closeBtn.click()
  }
}
