import { Page, Locator, expect } from '@playwright/test'
import * as fs from 'fs'

/**
 * POM 基类 —— 所有页面对象继承此类
 */
export class BasePage {
  readonly page: Page

  constructor(page: Page) {
    this.page = page
  }

  /** 等待 Element Plus loading 遮罩消失 */
  async waitForLoadingDismiss(timeout = 10_000) {
    const loading = this.page.locator('.el-loading-mask').first()
    if (await loading.isVisible()) {
      await loading.waitFor({ state: 'hidden', timeout })
    }
  }

  /** 截图并返回路径（用于 evidence 产出） */
  async screenshot(feature: string, name: string) {
    const dir = `.evidence/${feature}`
    fs.mkdirSync(dir, { recursive: true })
    return this.page.screenshot({ path: `${dir}/${name}.png`, fullPage: true })
  }
}
