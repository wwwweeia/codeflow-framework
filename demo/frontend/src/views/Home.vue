<template>
  <div class="home">
    <div class="hero">
      <h1>AI Prompt Lab</h1>
      <p class="subtitle">AI 智能体管理与提示词实验室</p>
    </div>

    <el-alert
      v-if="showBanner"
      type="success"
      title="欢迎使用 AI Prompt Lab"
      description="h-codeflow-framework 让 AI Coding 有序可循"
      center
      show-icon
      closable
      @close="showBanner = false"
      class="welcome-banner"
    />

    <el-row :gutter="20" class="stats">
      <el-col :span="6">
        <el-statistic title="模型" :value="stats.models" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="智能体" :value="stats.agents" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="提示词" :value="stats.prompts" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="技能" :value="stats.skills" />
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'

const showBanner = ref(true)

// 种子数据对应的初始统计
const stats = reactive({
  models: 3,
  agents: 3,
  prompts: 3,
  skills: 2,
})
</script>

<style scoped>
.home {
  padding: 20px;
}
.hero {
  text-align: center;
  padding: 60px 0 40px;
}
.hero h1 {
  font-size: 36px;
  color: #303133;
}
.subtitle {
  font-size: 16px;
  color: #909399;
  margin-top: 8px;
}
.stats {
  margin-top: 20px;
}
.welcome-banner {
  margin-top: 20px;
}
</style>
