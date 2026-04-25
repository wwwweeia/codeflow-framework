---
name: frontend-arch-design
description: 前端架构设计产出规范。供 arch-agent 设计 02_technical_design.md Part B 时使用，定义 B-1~B-7 各节的产出格式与 Checklist。底层规范引用 frontend-conventions。
---

# 前端架构设计产出规范（Part B）

> 本 Skill 面向 **arch-agent**，用于设计阶段产出 `02_technical_design.md` Part B。
> 底层规范（路由结构、Store 模式、权限命名、API 调用规则、组件树）见 **frontend-conventions**。
> 本 Skill 专注于 **Part B 的产出格式和 Checklist**。

---

## 1. Part B 各节产出格式

### B-1：路由注册

在 `<App>/router/routes.js` 中，在 `<相邻模块>` 路由块之后追加：

```markdown
| 路由 name | path | 页面组件 |
|----------|------|--------|
| `<module>` | `<module>` | `<module>/index.vue` |
| `<module>/list` | `''` | `<module>/list.vue` |
| `<module>/add` | `add` | `<module>/add.vue` |
```

> 路由 name 和嵌套结构必须遵循 frontend-conventions §1 的三层约定。

### B-2：页面文件结构

```
pages/<module>/index.vue    ← 壳页面（nuxt-child + keep-alive）
pages/<module>/list.vue     ← 列表主体
pages/<module>/add.vue      ← 新增/编辑（共用，query.id 区分）
pages/<module>/detail.vue   ← 详情页（按需）
```

### B-3：Vuex Store 模块

新建文件：`<App>/store/<module>.js`

**State**：
- `service`：`'<service-prefix>'`（见 conventions 项目特定配置）
- `keepList`：`[]`

**Actions**（按 conventions §2.2 命名）：

```markdown
| Action | HTTP | 路径 |
|--------|------|------|
| `getXxxList` | POST | `/xxx/list` |
| `addXxx` | POST | `/xxx` |
| `updateXxx` | PUT | `/xxx/:id` |
| `deleteXxx` | DELETE | `/xxx?ids=...` |
```

### B-4：API 字段映射表

#### 列表展示（后端 Response → 前端表格）

```markdown
| 后端字段 | 类型 | 前端展示 | 说明 |
|---------|------|--------|------|
| `id` | Long | 不展示 | 主键，用于编辑/删除 |
| `name` | String | vul-text-tooltip 截断 | 名称 |
| `isActive` | Integer | 状态点：1=启用/0=禁用 | — |
| `updateTime` | DateTime | YYYY-MM-DD HH:mm | 支持列排序 |
```

#### 弹窗表单（前端 dialogForm → 后端 Request）

```markdown
| dialogForm 字段 | 后端字段 | 必填 |
|----------------|---------|------|
| `name` | `name` | 是 |
| `isActive` | `isActive` | 是 |
```

**关联对象处理**：
- 一对多关联 → `multiCell` 组件渲染标签列表
- 枚举值 → 在列 `render` 或 `slot-scope` 中映射转换
- 长文本 → `vul-text-tooltip` 包裹

### B-5：组件树

列出每个页面的三层结构（Page → Section → Component），标注组件选型决策。

> 组件树结构和选型原则参考 frontend-conventions §6。

示例：

```markdown
#### pages/<module>/list.vue（列表主体）
- search-form
  - 搜索字段：name（input）/ status（select）
- operation
  - operationObj: { isAdd, isDel }
- el-table（带 selection、sortable:custom 列）
  - 列：名称 / 分类 / 优先级 / 状态 / 更新时间 / 操作
- el-pagination（total 来自后端）
- el-dialog（新增/编辑弹窗）
  - el-form：name / type / priority / isActive
```

### B-6：API 调用清单

```markdown
| 接口 | Action | Method | Path | Request 示例 | Response 示例 |
|------|--------|--------|------|-------------|---------------|
| 分页列表 | `getXxxList` | POST | `/xxx/list` | `{ pageNumber, pageSize, ... }` | `{ code:0, data:{ list, total, ... } }` |
| 新增 | `addXxx` | POST | `/xxx` | `{ name, ... }` | `{ code:0, message:"新增成功" }` |
```

> ⚠️ Response 示例**必须**使用项目约定的字段名（参考 frontend-conventions 项目特定配置中的分页响应格式），**禁止**使用 ORM 默认格式。

### B-7：权限配置清单

```markdown
| 按钮 | resourceCode | resourceType |
|------|-------------|-------------|
| 菜单 | `<app>-<module>` | 1（菜单） |
| 新增 | `<app>-<module>-add` | 2（按钮） |
| 编辑 | `<app>-<module>-edit` | 2（按钮） |
| 删除 | `<app>-<module>-delete` | 2（按钮） |
```

> resourceCode 命名规则见 frontend-conventions §3。

---

## 2. Part B 完整产出 Checklist

撰写 `02_technical_design.md` Part B 时，必须输出以下所有部分：

| 节 | 内容 | 关键检查项 |
|----|------|-----------|
| B-1 | 路由注册 | 嵌套结构正确，name 命名规范 |
| B-2 | 页面文件结构 | index.vue / list.vue / add.vue 说明 |
| B-3 | Vuex Store 模块 | state 模板、actions 完整列出 |
| B-4 | API 字段映射表 | 后端字段 ↔ 前端字段，**特别标注分页响应字段名** |
| B-5 | 组件树 | 三层结构，组件选型说明 |
| B-6 | API 调用清单 | 所有接口的 Action/Method/Path/Request/Response |
| B-7 | 权限配置清单 | resourceCode 命名格式，菜单节点+按钮节点均列出 |

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
