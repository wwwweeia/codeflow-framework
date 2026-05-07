## API 调用规范

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

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
