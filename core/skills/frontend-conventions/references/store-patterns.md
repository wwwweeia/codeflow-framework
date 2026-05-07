## Vuex Store 设计规范

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

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
