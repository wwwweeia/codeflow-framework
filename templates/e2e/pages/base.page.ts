import { Page, Locator, expect } from '@playwright/test'
import * as fs from 'fs'

/**
 * POM 基类 —— 所有页面对象继承此类
 *
 * 封装 qiankun 微前端环境下的通用等待和导航逻辑。
 */
export class BasePage {
  readonly page: Page

  constructor(page: Page) {
    this.page = page
  }

  /**
   * 等待 qiankun 子应用加载完成
   * 通过检测 #subapp-viewport 中出现内容来判断
   */
  async waitForSubApp(subAppPath: string, timeout = 15_000) {
    // 等待 URL 变化到子应用路径
    await this.page.waitForURL(`**${subAppPath}**`, { timeout })
    // 等待子应用容器有内容
    const container = this.page.locator('#subapp-viewport')
    await expect(container.locator('> *').first()).toBeVisible({ timeout })
  }

  /**
   * 等待 Element UI loading 遮罩消失
   */
  async waitForLoadingDismiss(timeout = 10_000) {
    const loading = this.page.locator('.el-loading-mask').first()
    if (await loading.isVisible()) {
      await loading.waitFor({ state: 'hidden', timeout })
    }
  }

  /**
   * 通过 data-testid 获取定位器
   */
  getByTestId(testId: string): Locator {
    return this.page.getByTestId(testId)
  }

  /**
   * 等待并点击 Element UI 确认弹窗的确定按钮
   */
  async confirmMessageBox() {
    const confirmBtn = this.page.locator('.el-message-box .el-button--primary')
    await confirmBtn.click()
  }

  /**
   * 等待 Element UI 消息提示出现
   */
  async waitForMessage(text: string, timeout = 5_000) {
    const msg = this.page.locator('.el-message').getByText(text)
    await expect(msg).toBeVisible({ timeout })
  }

  /**
   * 截图并返回路径（用于 evidence 产出）
   * @param feature 功能模块名称（对应 tests/ 下的目录名）
   * @param name 截图标识（如 ac01、ac02）
   */
  async screenshot(feature: string, name: string) {
    const dir = `.evidence/${feature}`
    fs.mkdirSync(dir, { recursive: true })
    return this.page.screenshot({ path: `${dir}/${name}.png`, fullPage: true })
  }
}
