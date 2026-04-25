# 前端共享编码规则 (Frontend Shared Coding Rules)

> 本文件是所有 Nuxt 2 / Vue 2 前端项目的共享硬规则。
> 各 App 特有规则在各自 `.claude/rules/frontend_coding.md` 中定义。
> 冲突时，App 特有规则优先于本文件。

---

## 1. 命名规范

- **时间字段**：必须以 `Time` 结尾（如 `createTime`, `updateTime`），禁止使用 `At` 结尾
- **组件命名**：文件名及 `name` 属性用 `PascalCase`（如 `SearchForm.vue`）
- **模板引用**：`kebab-case`（如 `<search-form>`）
- **路由命名**：`kebab-case`（如 `agent-center-add`）
- **文件命名**：Vue 组件 `PascalCase`，JS 文件 `kebab-case`
- **Store**：
  - 模块名单数、与接口分类对齐（如 `agent.js`, `client.js`）
  - `actions` / `methods`：`camelCase`
  - `mutations`：`SET_<STATE_NAME>` 或 `set_<stateName>`
- **权限码（resourceCode）**：格式为 `{app}-{module}-{action}`，全部 kebab-case
  - `app` 取值：各子应用自行定义（参见 marker 下方项目扩展）
  - `action` 常用值：`add` / `edit` / `delete` / `view` / `stop`
  - 写 Spec 时必须参照同 App 已有页面的权限码确认格式，**禁止使用冒号分隔**

## 2. 样式规范

- **Scoped 强制**：页面及业务组件样式**必须加 `scoped`**（`<style scoped lang="scss">`）
- **深度选择器**：统一使用 `:deep(.class-name)`，禁用 `::v-deep`、`>>>` 和 `/deep/`（历史代码中仍存在 `::v-deep`，新代码一律用 `:deep()`）
- **禁止污染**：禁止直接修改 Element UI `.el-*` 类名，如需修改必须在 `:deep()` 内进行
- **全局变量**：`$color-primary` 等已通过 `styleResources` 自动注入，无需手动 `@import`
- **BEM 命名**：遵循 `.block__element--modifier`，全部小写中划线分隔
- **微前端隔离**：通过 scoped 隔离样式，防止主子应用互相污染
- **页面最外层背景**：页面根容器 `background` 统一为白色 `#fff`，**禁止使用 `#f5f7fa` / `#f0f2f5` / `#fafbfc` 等灰底**（灰底只能用于卡片内的二级分组区、表单分块等局部场景）

## 3. 错误处理

**核心原则：不要对接口失败重复弹 `Message.error`。**

- 全局 axios 拦截器已统一处理所有接口错误（业务异常、HTTP 异常、Token 过期等）
- **禁止**：在 Store action 或业务代码中 `catch` 后手动 `Message.error`
- **必须**：Store action 直接返回 axios Promise
- **页面层**：判断 `if (code === 0)` 后处理成功逻辑，调用 `this.$message.success()`
- **加载状态**：使用独立变量（如 `dialogSubmitting`, `syncing`）进行按钮级 loading

## 4. 接口响应契约

后端统一使用 `R` 包装器返回，外层结构：`{ code, message, detail, data }`。code === 0 表示成功。

### 4.1 列表（分页）接口响应结构

**后端约定**：`R.ok().addData(voPage)` 自动拆分为下面的结构，**前端必须按此读取，禁止使用 `records` / `current` / `size` / `pages` 等 MyBatis-Plus IPage 原生别名**。

```json
{
  "code": 0,
  "message": "成功",
  "data": {
    "list":       [ /* 业务对象数组 */ ],
    "pageNumber": 1,
    "pageSize":   20,
    "pageTotal":  5,
    "total":      100
  }
}
```

- **前端取值**：`res.data.list` / `res.data.total`；**禁止 `res.data.records`**
- **请求入参**：`pageNumber` / `pageSize`（Long），禁止 `current` / `size` / `page` / `limit`
- **历史代码中的 `|| data.records` 防御写法是误导性冗余**，新代码一律 `res.data.list`；维护老页面时顺手清理

### 4.2 单对象接口

- 成功：`{ code: 0, data: { ... } }`，前端读 `res.data`
- 失败：全局拦截器处理，页面层无需额外 catch

## 5. 表单与表格

- **表格组件**：优先使用 `<vul-table>` + `tableConfig`
  - `tableConfig.uri` 是 Vuex dispatch 路径，格式为 `{module}/{action}`（如 `agent/getAgentList`），**不是 HTTP 路径**
  - `vul-table` 内部调用 `this.$store.dispatch(uri, params)` 加载分页数据，store action 须能接收 `pageNumber` / `pageSize` 参数
  - `asyncSelect` 组件的 `:uri` prop 遵循同一约定
- **搜索组件**：使用 `<search-form>` + `tableParamsSearch` computed
- **按钮组**：使用 `<operation>` + `operationObj`
- **新增/编辑复用**：通过 `this.$route.query.id` 区分
- **Dialog 重置**：关闭事件 `@closed` 时 `resetFields()` 重置表单和验证

## 6. 组件通信

- 父子通信：`props` + `$emit`
- 跨组件共享状态：Vuex
- 避免使用 `$parent` / `$children` / `provide/inject`

## 7. 技术栈约束

| 项目 | 约束 |
|------|------|
| 框架 | Nuxt 2.15.8 + Vue 2.6.14（**不迁移 Nuxt 3**） |
| API 风格 | Options API（**不使用 Composition API**） |
| UI 组件库 | Element UI 2.15 + element-ui |
| 微前端 | @femessage/nuxt-micro-frontend（qiankun） |
| 渲染模式 | SPA（`ssr: false`） |
| 构建 | Webpack 4（Nuxt 2 内置） |

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
