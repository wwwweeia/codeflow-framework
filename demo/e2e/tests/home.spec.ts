import { test, expect } from '@playwright/test'
import { HomePage } from '../pages/home.page'

test.describe('首页', () => {
  let homePage: HomePage

  test.beforeEach(async ({ page }) => {
    homePage = new HomePage(page)
    await homePage.goto()
  })

  test('页面加载后显示正确标题', async () => {
    const title = await homePage.getTitle()
    expect(title).toBe('AI Prompt Lab')

    const subtitle = await homePage.subtitle.innerText()
    expect(subtitle).toContain('AI 智能体管理与提示词实验室')

    await homePage.screenshot('home', 'loaded')
  })

  test('欢迎横幅可见且可关闭', async ({ page }) => {
    await expect(homePage.welcomeBanner).toBeVisible()
    await expect(homePage.welcomeBanner).toContainText('欢迎使用 AI Prompt Lab')

    await homePage.closeBanner()
    await expect(homePage.welcomeBanner).not.toBeVisible()

    await homePage.screenshot('home', 'banner-closed')
  })

  test('统计卡片显示正确数值', async () => {
    const stats = await homePage.getStatValues()
    expect(stats['模型']).toBe(3)
    expect(stats['智能体']).toBe(3)
    expect(stats['提示词']).toBe(3)
    expect(stats['技能']).toBe(2)

    await homePage.screenshot('home', 'stats')
  })
})
