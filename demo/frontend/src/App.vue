<template>
  <el-container class="app-container">
    <el-header class="app-header">
      <div class="logo">AI Prompt Lab</div>
      <el-menu mode="horizontal" router :default-active="$route.path">
        <el-menu-item index="/">首页</el-menu-item>
        <el-menu-item index="/prompts">Prompt 管理</el-menu-item>
      </el-menu>
    </el-header>
    <el-main>
      <router-view />
    </el-main>
  </el-container>
</template>

<script setup>
</script>

<style scoped>
.app-container {
  min-height: 100vh;
}
.app-header {
  display: flex;
  align-items: center;
  border-bottom: 1px solid #e6e6e6;
}
.logo {
  font-size: 20px;
  font-weight: bold;
  margin-right: 24px;
  color: #409eff;
}
</style>
