## 标准页面组件树

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
└── el-pagination（仅在使用 el-table 时手动配置）
```

**list.vue 职责边界**——仅负责列表数据的获取、筛选、展示与操作触发：
- **应包含**：搜索区 + 操作按钮 + 表格 + 分页
- **禁止包含**：新增/编辑表单弹窗、详情弹窗、复杂交互弹窗
- **操作触发方式**：
  - 新增/编辑 → 路由跳转到 `add.vue`（通过 `$route.query.id` 区分新增/编辑）
  - 详情查看 → 路由跳转到 `detail.vue`
  - 删除/重置等简单确认 → `this.$confirm()` 弹窗
  - 行内快速编辑等无法路由的场景 → 抽取为 `components/` 子组件（见 §6.3）

**选型原则**：
- 使用 **vul-table**：列需要 `render` 函数、需要内置自动分页时
- 使用 **el-table + el-pagination**：需要 `slot-scope` 写法时

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

### 6.3 组件分层规范

页面组件按职责分为两层：

**page 层**（路由页面，`pages/<module>/`）：负责数据获取、页面组装、路由跳转。

```
pages/<module>/
├── index.vue     # 壳页面（keep-alive 容器）
├── list.vue      # 列表页：搜索 + 表格 + 操作触发
├── add.vue       # 新增/编辑页：表单 + 提交
└── detail.vue    # 详情页：数据展示
```

**component 层**（私有组件，`pages/<module>/components/`）：仅在路由无法覆盖的交互场景中使用。

**判定标准**——什么时候用路由跳转，什么时候抽取子组件：

| 场景 | 方案 | 理由 |
|------|------|------|
| 新增/编辑表单 | 路由跳转 `add.vue` | 独立页面体验，支持 keep-alive 和浏览器后退 |
| 详情查看 | 路由跳转 `detail.vue` | 独立 URL，可分享/收藏 |
| 删除确认、重置等 | `this.$confirm()` | 内置弹窗即可，无需自定义组件 |
| 行内快速编辑（改一个字段） | `components/InlineEdit.vue` | 交互轻量，不需要整页跳转 |
| 表格行展开的复杂内容 | `components/ExpandDetail.vue` | 嵌套在表格内，无法独立路由 |
| 同一列表页有多个独立弹窗 | `components/XxxDialog.vue` | 弹窗间无关联，各自独立管理状态 |

**子组件通信约定**：
- 父 → 子：`props` 传递数据（如 `:row-data`）
- 子 → 父：`$emit` 通知结果（如 `@saved`、`@cancelled`）
- 弹窗子组件自管 `visible` 状态，父组件通过 `ref` 调用 `open(row)` 方法打开

---

## 性能优化指南

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

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
