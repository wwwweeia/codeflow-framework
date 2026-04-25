---
name: "frontend-api-integration"
description: "前端 API 对接技能。适用于 Nuxt 2 / Vue 2 前端应用中新增 Vuex Store Action 和接口调用。"
---

# 前端 API 对接技能

## 触发条件
- 用户要求在前端项目中对接后端接口
- 需要新增 Vuex Store Action 或修改已有接口调用

## Store Action 编写规范

> 完整命名约定与 HTTP 方法规则见 **frontend-conventions §2.2**，Action 模板见 **frontend-conventions §2.3**。

所有 API 调用必须放在 `store/` 的 action 中，统一使用 `this.$axios`，直接返回 Promise。URL 必须使用 `state.service` 前缀，**禁止硬编码路径**。

```javascript
// store/channel.js
const state = () => ({
  service: '<service-prefix>',  // API 路径前缀，取自项目特定配置
})

const actions = {
  // 列表查询：POST + /list 后缀
  async getChannelList({ state }, params) {
    return await this.$axios({
      method: 'post',
      url: `${state.service}/channels/list`,
      data: params,
    })
  },

  // 新增：POST 到资源路径
  async createChannel({ state }, data) {
    return await this.$axios({
      method: 'post',
      url: `${state.service}/channels`,
      data,
    })
  },
}
```

## 组件中调用

```javascript
async loadData() {
  this.loading = true
  try {
    const { code, data } = await this.$store.dispatch('channel/getChannelList', this.params)
    if (code === 0) {
      this.list = data
    }
  } finally {
    this.loading = false
  }
}
```

## 关键规则

1. **禁止重复弹错误提示**：全局 axios 拦截器（`plugins/axios.js`）已统一处理所有接口错误，业务层禁止 `catch` 后手动 `Message.error`
2. **成功提示**：仅在写操作（创建/编辑/删除）成功后调用 `this.$message.success()`
3. **Token 注入**：`plugins/axios.js` 自动注入 Authorization，禁止手动设置
4. **表格场景**：若接口用于封装表格组件加载数据，Store Action 须能接收 `pageNumber` / `pageSize` 参数，通过 `tableConfig.uri` 配置（格式为 `{module}/{action}`，不是 HTTP 路径）

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
