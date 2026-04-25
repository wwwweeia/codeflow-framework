---
name: frontend-conventions
description: 前端共享惯例知识库（唯一权威源）。路由三层结构、Store 设计模式、权限规范、API 调用规则、组件规范、页面组件树——Arch/FE/Prototype 三个角色共同引用，消除知识重复。
---

# 前端共享惯例知识库

> **Single Source of Truth**：本 Skill 定义前端路由、Store、权限、API 调用、组件的共享规范。
> `frontend-arch-design`（Arch 产出格式）、`frontend-create-module`（FE 执行步骤）、`frontend-prototype`（原型设计）均引用本文件。
> 任何规范变更只需修改此处，三个角色自动对齐。

---

## 1. 路由设计规范

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

---

## 2. Vuex Store 设计规范

### 2.1 State 结构模板

```javascript
const state = () => ({
  service: '<service-prefix>',   // 必填，API 路径前缀（见项目特定配置）
  keepList: [],                   // 必填，keep-alive 页面列表
  currentItem: null,              // 按需，单条详情缓存
  // 业务特有字段按需追加
})
```

### 2.2 Actions 命名规范

| 操作 | 命名模式 | HTTP | 路径模式 |
|------|---------|------|----------|
| 分页列表 | `getXxxList` | POST | `/xxx/list` |
| 新增 | `addXxx` / `saveXxx` | POST / PUT | `/xxx` or `/xxx/0` |
| 编辑 | `updateXxx` / `saveXxx` | PUT | `/xxx/:id` |
| 删除（批量） | `deleteXxx` | DELETE | `/xxx?ids=1,2,3` |
| 状态切换 | `toggleXxxStatus` | PATCH | `/xxx/:id/status` |
| 导入 | `importXxx` | POST | `/xxx/import` |
| 导出 | `exportXxx` | POST | `/xxx/export` |

### 2.3 Store Action 编写模板

```javascript
const actions = {
  async getXxxList({ state }, params) {
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

export default { namespaced: true, state, mutations: {}, actions }
```

---

## 3. 权限配置规范

### 3.1 resourceCode 命名

格式：`{app}-{module}-{action}`，全部 kebab-case。

| 部分 | 说明 | 示例 |
|------|------|------|
| app | 项目标识（取路由前缀的 kebab-case） | `claw`、`agent-center`、`front` |
| module | 模块名（与路由路径对齐） | `channel`、`preset-question`、`task` |
| action | 操作动词（仅按钮/功能节点需要） | `add`、`edit`、`delete`、`view`、`stop` |

### 3.2 resourceType 枚举

| 值 | 含义 | 说明 |
|----|------|------|
| 0 | 目录 | 菜单分组容器，无实际 URI |
| 1 | 菜单 | 叶子菜单，有 URI，显示在侧边栏 |
| 2 | 按钮 | UI 按钮权限，挂在菜单下 |
| 3 | 功能 | API 功能权限，挂在菜单下 |

---

## 4. API 调用规范

1. **所有 API 调用必须放在 Store Action 中**，统一使用 `this.$axios`，直接返回 Promise
2. **禁止重复弹错误提示**：全局 axios 拦截器（`plugins/axios.js`）已统一处理所有接口错误，业务层禁止 `catch` 后手动 `Message.error`
3. **成功提示**：仅在写操作（创建/编辑/删除）成功后调用 `this.$message.success()`
4. **Token 注入**：`plugins/axios.js` 自动注入 Authorization，禁止手动设置
5. **表格场景**：若接口用于封装表格组件（vul-table），通过 `tableConfig.uri` 配置（格式为 `{store命名空间}/{action名}`，**不是 HTTP 路径**）

**组件中调用模式**：
```javascript
const res = await this.$store.dispatch('<module>/<action>', params)
if (res && res.code === 0) {
  // 处理 res.data
}
```

---

## 5. 组件通用规范

- **样式隔离**：必须加 `<style scoped>`，微前端环境下未隔离的样式会污染其他应用
- **深度选择器**：统一使用 `:deep(.class-name)`，禁用 `::v-deep`、`>>>`、`/deep/`
- **Options API**：使用 `data()`、`computed`、`methods`、`watch`，禁止 Composition API
- **命名**：文件名 PascalCase（如 `ConversationHistory.vue`），模板引用 kebab-case（如 `<conversation-history>`）
- **组件通信**：父子 `props + $emit`，跨组件 Vuex，微前端跨应用 `CustomEvent`（`beforeDestroy` 中必须 `removeEventListener`）
- **页面根容器**：背景色 `#fff`

---

## 6. 标准页面组件树

### 6.1 列表页（list.vue）

```
pages/<module>/list.vue
├── search-form（搜索条件区）
│   └── formList: [{ label, value, type, opts? }]
├── operation（操作按钮栏）
│   └── operationObj: { isAdd, isDel, isImport?, isExport? }
├── vul-table（推荐，自动分页）或 el-table（手动分页，适合定制列）
│   ├── el-table-column type="selection"
│   ├── el-table-column ...（各数据列）
│   └── el-table-column label="操作" fixed="right"
├── el-pagination（仅在使用 el-table 时手动配置）
└── el-dialog（新增/编辑弹窗，可选）
    └── el-form（表单验证）
```

**选型原则**：
- 使用 **vul-table**：列需要 `render` 函数、需要内置自动分页时
- 使用 **el-table + el-pagination**：需要 `slot-scope` 写法、弹窗内联编辑时

### 6.2 编辑页（add.vue）

```
pages/<module>/add.vue
├── el-form（表单验证，ref="form"）
│   ├── el-form-item（各字段）
│   └── el-input / el-select / el-input-number / el-switch / tags / ...
└── 吸底按钮栏
    ├── el-button（取消）
    └── el-button type="primary"（提交）
```

---

## 7. 性能优化指南

### 7.1 大列表场景

| 数据量 | 方案 | 说明 |
|--------|------|------|
| < 500 行 | `vul-table` 默认分页 | 无需额外处理 |
| ≥ 500 行且需前端渲染 | `vxe-table` 虚拟滚动 | `virtual-y: { enabled: true, gt: 0 }` |
| 无限滚动流 | `Intersection Observer` + 分批追加 | 避免 DOM 节点堆积 |

### 7.2 路由级代码分割

子应用路由必须使用动态导入，禁止静态 import 全部页面组件：

```javascript
// router/routes.js
{ path: 'channel', component: () => import('@/pages/channel/index.vue') }
```

### 7.3 防抖 / 节流

| 场景 | 方案 | 推荐延迟 |
|------|------|---------|
| 搜索框输入触发查询 | `debounce` | 300ms |
| 滚动 / resize 事件 | `throttle` | 100ms |
| 按钮防重复提交 | 禁用按钮（`loading` 状态） | — |

统一使用 `lodash-es` 的 `debounce` / `throttle`，禁止手动 `setTimeout` 实现。

### 7.4 computed 缓存规范

- 派生数据必须用 `computed` 而非 `methods`（后者无缓存，每次渲染都重新执行）
- `computed` 内禁止副作用（禁止 `this.$store.dispatch`、`this.$axios`）
- 依赖项过多（> 10 个响应式字段）时，考虑拆分或移到 Store getter

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
