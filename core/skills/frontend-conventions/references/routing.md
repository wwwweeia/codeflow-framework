## 路由设计规范

### 1.1 三层嵌套结构

```
根路由 { path: '/<appPrefix>', component: 'appLayout' }
└── 模块路由 { path: '<module>', component: '<module>/index.vue', name: '<module>' }
    ├── 列表页 { path: '',       component: '<module>/list.vue',   name: '<module>/list' }
    ├── 新增页 { path: 'add',    component: '<module>/add.vue',    name: '<module>/add' }
    └── 详情页 { path: 'detail', component: '<module>/detail.vue', name: '<module>/detail' }
```

**约定**：
- 列表页路径始终为 `''`（空路径），即模块路由的默认子路由
- 新增/编辑共用同一页面（`add.vue`），通过 `$route.query.id` 区分
- 模块路由的 `name` = 模块名，子路由的 `name` = `<模块>/<页面>`

> 部分 App 的页面目录可能使用不同的命名后缀，FE 执行时以目标项目现有结构为准。

### 1.2 壳页面（index.vue）固定写法

```vue
<template>
  <nuxt-child keep-alive :keep-alive-props="{ include: keepList }"></nuxt-child>
</template>
<script>
export default {
  name: '<Module>Index',
  meta: { title: '<模块中文名>' },
  computed: {
    keepList() { return this.$store.state?.<module>?.keepList },
  },
}
</script>
```

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
