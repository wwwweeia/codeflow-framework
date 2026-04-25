import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'

const routes = [
  { path: '/', name: 'Home', component: Home },
  { path: '/prompts', name: 'PromptList', component: () => import('../views/PromptList.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
