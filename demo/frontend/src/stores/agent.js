import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../api'

export const useAgentStore = defineStore('agent', () => {
  const agents = ref([])
  const loading = ref(false)

  async function fetchAgents() {
    loading.value = true
    try {
      const res = await api.get('/api/v1/agents')
      agents.value = res.data?.data || []
    } finally {
      loading.value = false
    }
  }

  return { agents, loading, fetchAgents }
})
