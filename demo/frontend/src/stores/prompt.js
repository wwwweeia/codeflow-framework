import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../api'

// ============================================================
// Mock 数据（对齐后端 PromptRead Schema）
// 后续切换后端时只需将 mockPrompts 替换为 API 调用
// ============================================================
const mockPrompts = [
  {
    id: 1,
    title: '翻译助手',
    content: '你是一个专业的翻译助手，能够将中文翻译成英文，也可以将英文翻译成中文。请保持原文的语义和语气，确保翻译结果自然流畅。对于专业术语，请提供括号内的原文注释。',
    tags: ['翻译', '多语言'],
    variables: '{"source_lang", "target_lang"}',
    createdTime: '2026-04-20 10:30:00',
  },
  {
    id: 2,
    title: '代码生成专家',
    content: '你是一个代码生成专家，擅长编写高质量的代码。用户会描述需求，你需要生成符合要求的代码。请确保代码具有良好的命名规范、合理的注释和适当的错误处理。',
    tags: ['代码生成'],
    variables: '{"language", "framework"}',
    createdTime: '2026-04-19 14:20:00',
  },
  {
    id: 3,
    title: '对话模拟器',
    content: '你是一个对话模拟器，可以模拟不同角色之间的对话场景。用户会给出角色设定和对话主题，你需要生成逼真的对话内容，包含自然的语气转换、情感表达和语境理解。每次对话结束后，请对对话质量进行简要评估。',
    tags: ['对话', '写作'],
    variables: null,
    createdTime: '2026-04-18 09:15:00',
  },
  {
    id: 4,
    title: '数据分析报告',
    content: '短文本',
    tags: [],
    variables: null,
    createdTime: '2026-04-17 16:45:00',
  },
  {
    id: 5,
    title: 'SQL 查询优化建议器',
    content: '你是一个 SQL 查询优化专家。用户会提供 SQL 查询语句和表结构信息，你需要分析查询性能瓶颈，给出具体的优化建议，包括索引建议、查询重写方案和执行计划解读。请用结构化的格式输出优化前后的对比。',
    tags: ['代码生成', '数据库'],
    variables: '{"db_type"}',
    createdTime: '2026-04-16 11:00:00',
  },
  {
    id: 6,
    title: '产品需求文档撰写助手',
    content: '你是一个产品经理的得力助手，专门负责撰写产品需求文档（PRD）。用户会提供功能的简要描述，你需要将其扩展为完整的产品需求文档，包括功能概述、用户故事、验收标准、交互说明和非功能需求。文档格式清晰，逻辑严密，语言专业。',
    tags: ['写作', '产品'],
    variables: '{"product_name", "feature_name"}',
    createdTime: '2026-04-15 08:30:00',
  },
  {
    id: 7,
    title: 'Bug 复现分析器',
    content: '你是',
    tags: null,
    variables: null,
    createdTime: '2026-04-14 20:10:00',
  },
]

/**
 * 解析 tags 字段：JSON 字符串 / null / 数组 -> 统一为数组
 * 后端 tags 可能为 JSON 字符串、原生数组或 null
 */
function parseTags(raw) {
  if (raw == null) return []
  if (Array.isArray(raw)) return raw
  try {
    const parsed = JSON.parse(raw)
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

export const usePromptStore = defineStore('prompt', () => {
  // ==================== State ====================
  const prompts = ref([])
  const loading = ref(false)
  const searchForm = ref({
    keyword: '',
    tags: [],
  })

  // ==================== Getters ====================

  /** 规范化数据：将 tags 字段统一解析为数组 */
  const normalizedPrompts = computed(() =>
    prompts.value.map((item) => ({
      ...item,
      tags: parseTags(item.tags),
    }))
  )

  /** 所有可用标签（去重排序） */
  const allTags = computed(() => {
    const tagSet = new Set()
    normalizedPrompts.value.forEach((item) => {
      item.tags.forEach((tag) => tagSet.add(tag))
    })
    return Array.from(tagSet).sort()
  })

  /** 按搜索条件筛选后的列表 */
  const filteredPrompts = computed(() => {
    const keyword = searchForm.value.keyword.trim().toLowerCase()
    const selectedTags = searchForm.value.tags

    return normalizedPrompts.value.filter((item) => {
      // 标题模糊匹配（不区分大小写）
      if (keyword && !item.title.toLowerCase().includes(keyword)) {
        return false
      }
      // 标签 AND 筛选：选中标签必须全部包含
      if (selectedTags.length > 0) {
        const itemTagSet = new Set(item.tags)
        if (!selectedTags.every((tag) => itemTagSet.has(tag))) {
          return false
        }
      }
      return true
    })
  })

  // ==================== Actions ====================

  /**
   * 加载提示词列表
   * 当前：前端 Mock，模拟 200ms 网络延迟
   * 未来：替换为 api.get('/api/v1/prompts')
   */
  async function fetchPrompts() {
    loading.value = true
    try {
      // Mock 版本
      await new Promise((resolve) => setTimeout(resolve, 200))
      prompts.value = [...mockPrompts]

      // 真实 API 版本（未来替换）
      // const res = await api.get('/api/v1/prompts')
      // prompts.value = res.data || []
    } catch (e) {
      console.error('[PromptStore] 加载失败:', e)
      prompts.value = []
    } finally {
      loading.value = false
    }
  }

  /** 更新搜索条件（getter 自动触发筛选） */
  function search(keyword, tags) {
    searchForm.value.keyword = keyword
    searchForm.value.tags = tags
  }

  /** 重置搜索条件 */
  function resetSearch() {
    searchForm.value.keyword = ''
    searchForm.value.tags = []
  }

  return {
    prompts,
    loading,
    searchForm,
    normalizedPrompts,
    allTags,
    filteredPrompts,
    fetchPrompts,
    search,
    resetSearch,
  }
})
