---
name: frontend-conventions
description: 前端共享惯例知识库（唯一权威源）。路由三层结构、Store 设计模式、权限规范、API 调用规则、组件规范、页面组件树——Arch/FE/Prototype 三个角色共同引用，消除知识重复。
---

# 前端共享惯例知识库

> **Single Source of Truth**：本 Skill 定义前端路由、Store、权限、API 调用、组件的共享规范。
> `frontend-arch-design`（Arch 产出格式）、`frontend-create-module`（FE 执行步骤）、`frontend-prototype`（原型设计）均引用本文件。
> 任何规范变更只需修改此处，三个角色自动对齐。
>
> **UI 设计规范**：组件选型策略（vul-ui 优先三层决策）、设计 Token（色彩/字体/间距/圆角/阴影）、组件使用规范、交互与反馈规范、页面模板、业务组件开发规范、合规检查清单——详见 **frontend-ui-design** Skill。
> 本文件（frontend-conventions）聚焦路由/Store/权限/API 调用/组件树的架构规范。

---

## 加载引导

- **必加载场景**：Arch/FE/Prototype Agent 涉及前端工作时
- **可跳过场景**：纯后端任务
- **渐进式加载**：核心规范在本文件，详细参考见 `references/` 目录（按需读取）

## 规范索引

| 规范 | 速查 | 详情 |
|------|------|------|
| 路由设计 | 三层嵌套 + 壳页面写法 | → references/routing.md |
| Store 设计 | State 模板 + Actions 命名 + 编写模板 | → references/store-patterns.md |
| 权限配置 | resourceCode 命名 + resourceType 枚举 | → references/permission.md |
| API 调用 | 5 条规则 + 组件调用模式 | → references/api-calling.md |
| 组件规范 | 样式隔离 + 深度选择器 + Options API + 命名 + 通信 | → references/component-standards.md |
| 页面模板 | 列表页 + 编辑页 + 组件分层 + 性能优化 | → references/page-template.md |

## 组件通用规范（速查）

- **样式隔离**：必须加 `<style scoped>`，微前端环境下未隔离的样式会污染其他应用
- **深度选择器**：统一使用 `:deep(.class-name)`，禁用 `::v-deep`、`>>>`、`/deep/`
- **Options API**：使用 `data()`、`computed`、`methods`、`watch`，禁止 Composition API
- **命名**：文件名 PascalCase（如 `ConversationHistory.vue`），模板引用 kebab-case（如 `<conversation-history>`）
- **组件通信**：父子 `props + $emit`，跨组件 Vuex，微前端跨应用 `CustomEvent`（`beforeDestroy` 中必须 `removeEventListener`）
- **页面根容器**：背景色 `#fff`

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
