---
name: "frontend-create-module"
description: "前端模块创建技能。适用于 Nuxt 2 / Vue 2 前端应用中新增业务模块（路由 + Store + 页面）。"
---

# 前端模块创建技能

## 触发条件
- 用户要求在前端项目中新增业务模块
- 需要新增路由 + Store + 列表/表单页面的完整模块

## 模块创建差异（微前端场景）

| 步骤 | 宿主应用 | 子应用 |
|------|---------|--------|
| 路由 | 按宿主路由机制注册（可能是动态注册或 `pages/` 文件路由） | `router/routes.js` 中添加路由配置 |
| Store | `store/moduleName.js` | `store/moduleName.js` |
| 布局 | 需兼容全局侧边栏/抽屉推挤效果（如适用） | 标准布局 |

> 具体差异以各项目 `.claude/context/routes.md` 和 `.claude/context/stores.md` 为准。

## Store 模块模板

> Action 命名约定与 HTTP 方法规则见 **frontend-conventions §2.2**。

```javascript
const state = () => ({
  service: '<service-prefix>',  // API 路径前缀，见项目特定配置 / frontend-conventions §2.1
  list: [],
  loading: false,
})

const mutations = {
  SET_LIST(state, list) {
    state.list = list
  },
}

const actions = {
  // 列表查询：POST + /list 后缀（见 frontend-conventions §2.2）
  async getXxxList({ state }, params = {}) {
    return await this.$axios({
      method: 'post',
      url: `${state.service}/xxx/list`,
      data: params,
    })
  },

  async addXxx({ state }, data) {
    return await this.$axios({ method: 'post', url: `${state.service}/xxx`, data })
  },

  async updateXxx({ state }, data) {
    return await this.$axios({ method: 'put', url: `${state.service}/xxx/${data.id}`, data })
  },

  async deleteXxx({ state }, ids) {
    return await this.$axios({ method: 'delete', url: `${state.service}/xxx?ids=${ids}` })
  },
}

export default { namespaced: true, state, mutations, actions }
```

## 列表页标准套件（封装表格模式）

```vue
<template>
  <div class="xxx-center">
    <search-form :form-list="commonSearch" :my-form="tableConfig.params"
      @changeForm="getList" @resetForm="resetForm" />
    <div class="grid-content">
      <operation :operation="operationObj" @operations="operationsFun" />
      <vul-table v-if="showTable" ref="table" v-bind="tableConfig"
        @selection-change="handleSelect" />
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      showTable: true,
      tableConfig: {
        uri: 'moduleName/getXxxList',  // Vuex dispatch 路径，不是 HTTP 路径
        params: {},
        columns: [
          { type: 'selection', width: 55 },
          { prop: 'name', label: '名称', minWidth: 150 },
          { prop: 'createTime', label: '创建时间', width: 180 },
        ],
      },
    }
  },
}
</script>
```

> 表格组件名和搜索组件名以项目实际封装为准，上述为常见模式。

## 完成检查
- [ ] 路由已在对应配置文件中注册
- [ ] Store 模块名为单数、与接口分类对齐
- [ ] 时间字段使用 `createTime` / `updateTime`
- [ ] 列表页使用封装表格 + `tableConfig.uri` 模式
- [ ] 接口失败未在业务层弹 `Message.error`
- [ ] 样式加了 `scoped`

<!-- codeflow-framework:core v1.5.0-20260417 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
