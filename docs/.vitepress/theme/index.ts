import DefaultTheme from 'vitepress/theme'
import mediumZoom from 'medium-zoom'
import { onMounted, watch, nextTick } from 'vue'
import type { EnhanceAppContext } from 'vitepress'
import './style.css'

export default {
  extends: DefaultTheme,
  setup() {
    onMounted(() => {
      initZoom()
    })

    watch(
      () => window.location.pathname,
      () => nextTick(() => initZoom())
    )
  },
} as typeof DefaultTheme

function initZoom() {
  // 为 .main 下的所有内容图片添加 zoom 能力
  document.querySelectorAll('.main img').forEach((img) => {
    if (img.closest('a')) return // 跳过本身就是链接的图片
    img.setAttribute('data-zoomable', '')
  })
  mediumZoom('[data-zoomable]', {
    background: 'var(--vp-c-bg)',
    margin: 24,
  })
}
