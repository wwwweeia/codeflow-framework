import { test, expect } from '@playwright/test'
import { PromptListPage } from '../pages/prompt-list.page'

test.describe('Prompt 列表页', () => {
  let promptPage: PromptListPage

  test.beforeEach(async ({ page }) => {
    promptPage = new PromptListPage(page)
    await promptPage.goto()
  })

  test('页面加载后自动显示列表', async () => {
    const rowCount = await promptPage.getRowCount()
    expect(rowCount).toBeGreaterThan(0)

    const totalText = await promptPage.getTotalText()
    expect(totalText).toContain('条记录')

    await promptPage.screenshot('prompt-list', 'loaded')
  })

  test('按关键词搜索过滤列表', async () => {
    // 搜索"翻译"应只返回包含该关键词的记录
    await promptPage.searchByKeyword('翻译')
    const rowCount = await promptPage.getRowCount()
    expect(rowCount).toBeGreaterThanOrEqual(1)

    // 验证搜索结果包含关键词
    const firstTitle = await promptPage.getCellText(0, '标题')
    expect(firstTitle).toContain('翻译')

    await promptPage.screenshot('prompt-list', 'search-keyword')
  })

  test('标签筛选过滤列表', async ({ page }) => {
    // 选择"代码生成"标签
    await promptPage.selectTag('代码生成')

    // 点击搜索按钮触发筛选
    await promptPage.searchBtn.click()
    await promptPage.waitForLoadingDismiss()

    const rowCount = await promptPage.getRowCount()
    expect(rowCount).toBeGreaterThanOrEqual(1)

    await promptPage.screenshot('prompt-list', 'filter-tag')
  })

  test('重置搜索恢复全部数据', async () => {
    // 先搜索缩小范围
    await promptPage.searchByKeyword('翻译')
    const filteredCount = await promptPage.getRowCount()
    expect(filteredCount).toBeLessThan(7)

    // 重置后恢复全部
    await promptPage.resetSearch()
    const totalCount = await promptPage.getRowCount()
    expect(totalCount).toBeGreaterThan(filteredCount)

    await promptPage.screenshot('prompt-list', 'reset')
  })

  test('搜索不存在的关键词显示空状态', async () => {
    await promptPage.searchByKeyword('zzz不存在的内容xyz')
    await expect(promptPage.emptyText).toBeVisible()
    expect(await promptPage.emptyText.innerText()).toContain('暂无数据')

    await promptPage.screenshot('prompt-list', 'empty-result')
  })
})
