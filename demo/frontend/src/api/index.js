import axios from 'axios'
import { ElMessage } from 'element-plus'

const api = axios.create({
  timeout: 10000,
})

// 响应拦截器：统一处理错误
api.interceptors.response.use(
  (response) => {
    const res = response.data
    if (res.code !== undefined && res.code !== 0) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message))
    }
    return res
  },
  (error) => {
    ElMessage.error(error.response?.data?.detail || error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default api
