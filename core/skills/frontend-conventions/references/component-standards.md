## 组件通用规范

- **样式隔离**：必须加 `<style scoped>`，微前端环境下未隔离的样式会污染其他应用
- **深度选择器**：统一使用 `:deep(.class-name)`，禁用 `::v-deep`、`>>>`、`/deep/`
- **Options API**：使用 `data()`、`computed`、`methods`、`watch`，禁止 Composition API
- **命名**：文件名 PascalCase（如 `ConversationHistory.vue`），模板引用 kebab-case（如 `<conversation-history>`）
- **组件通信**：父子 `props + $emit`，跨组件 Vuex，微前端跨应用 `CustomEvent`（`beforeDestroy` 中必须 `removeEventListener`）
- **页面根容器**：背景色 `#fff`

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
