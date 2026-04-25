---
name: "frontend-create-component"
description: "前端组件封装技能。适用于 Nuxt 2 / Vue 2 前端应用中新建 Vue 2 组件。"
---

# 前端组件封装技能

## 触发条件
- 用户要求在前端项目中新建 Vue 组件
- 需要封装可复用的 UI 模式（卡片、弹窗、表单片段等）

## 组件目录约定

| 类型 | 推荐位置 | 说明 |
|------|---------|------|
| 通用组件 | `components/Common/` | 跨模块复用的基础组件 |
| 业务组件 | `components/<Domain>/` 或 `pages/<module>/` 子目录 | 特定业务域的组件 |

> 具体目录结构以项目 `.claude/context/components.md` 为准。

## 组件模板

```vue
<template>
  <div class="component-name">
    <!-- 内容 -->
  </div>
</template>

<script>
export default {
  name: 'ComponentName',
  props: {
    value: {
      type: [String, Number],
      default: '',
    },
  },
  data() {
    return {}
  },
  methods: {},
}
</script>

<style lang="scss" scoped>
.component-name {
}
</style>
```

## 关键规则

> 以下规则以 **frontend-conventions §5** 为权威源，本文件仅作快速参考。

1. **命名**：文件名 `PascalCase`（如 `ConversationHistory.vue`），模板引用 `kebab-case`（如 `<conversation-history>`）
2. **样式隔离**：必须加 `scoped`，微前端环境下未隔离的样式会污染其他应用
3. **深度选择器**：统一使用 `:deep(.class-name)`，禁用 `::v-deep`、`>>>`、`/deep/`
4. **组件通信**：
   - 父子通信：`props` + `$emit`
   - 跨组件共享状态：Vuex
   - 微前端跨应用通信（如适用）：`window.dispatchEvent(new CustomEvent(...))`，必须在 `beforeDestroy` 中 `removeEventListener`
5. **Options API**：使用 `data()`、`computed`、`methods`、`watch`，禁止 Composition API

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
