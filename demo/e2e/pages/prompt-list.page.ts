import { Page, Locator, expect } from '@playwright/test'
import { BasePage } from './base.page'

/**
 * Prompt 列表页 POM
 */
export class PromptListPage extends BasePage {
  readonly searchInput: Locator
  readonly searchBtn: Locator
  readonly resetBtn: Locator
  readonly tagSelect: Locator
  readonly table: Locator
  readonly tableRows: Locator
  readonly tableFooter: Locator
  readonly emptyText: Locator

  constructor(page: Page) {
    super(page)
    this.searchInput = page.getByPlaceholder('请输入标题关键词')
    this.searchBtn = page.getByRole('button', { name: '搜索' })
    this.resetBtn = page.getByRole('button', { name: '重置' })
    this.tagSelect = page.locator('.el-select')
    this.table = page.locator('.el-table')
    this.tableRows = this.table.locator('tbody tr')
    this.tableFooter = page.locator('.table-footer .total-count')
    this.emptyText = page.locator('.el-table__empty-text')
  }

  async goto() {
    await this.page.goto('/prompts')
    await this.page.waitForLoadState('networkidle')
    await expect(this.table).toBeVisible()
  }

  async getRowCount(): Promise<number> {
    return this.tableRows.count()
  }

  async getTotalText(): Promise<string> {
    return this.tableFooter.innerText()
  }

  async getCellText(rowIndex: number, columnHeader: string): Promise<string> {
    const colIndex = await this.getColumnIndex(columnHeader)
    return this.tableRows.nth(rowIndex).locator('td').nth(colIndex).innerText()
  }

  async searchByKeyword(keyword: string) {
    await this.searchInput.fill(keyword)
    await this.searchBtn.click()
    await this.waitForLoadingDismiss()
  }

  async selectTag(tagName: string) {
    // 点击标签下拉触发器
    await this.tagSelect.click()
    // 从下拉面板中选择标签
    const option = this.page.locator('.el-select-dropdown__item').getByText(tagName).first()
    await option.click()
    // 关闭下拉面板
    await this.page.keyboard.press('Escape')
  }

  async resetSearch() {
    await this.resetBtn.click()
  }

  private async getColumnIndex(header: string): Promise<number> {
    const headers = this.table.locator('thead th')
    const count = await headers.count()
    for (let i = 0; i < count; i++) {
      const text = await headers.nth(i).innerText()
      if (text.includes(header)) return i
    }
    return -1
  }
}
