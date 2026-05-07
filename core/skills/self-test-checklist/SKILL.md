---
name: self-test-checklist
description: Dev/FE 两阶段自查清单（合规检查 + 质量检查），按后端/前端模式提供具体检查项。完成后才能流转 QA。
---

# 两阶段自查清单

> 本 Skill 定义 Dev 和 FE Agent 的两阶段自查标准。Agent 完成实现后、流转 QA 前必须逐项检查。
> 检查结果写入 `.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/evidences/`。

## 加载引导

- **必加载场景**：Dev/FE Agent 进入 Self-Test 阶段时
- **可跳过场景**：其他 Agent 或尚未进入 Self-Test 阶段

---

## 后端模式（Dev）

### 第一阶段：合规检查（Compliance）— 我做的和 Spec 一致吗？

- [ ] API 路径、HTTP 方法、请求/响应字段与 `02 Part A` 逐一核对
- [ ] 数据库 Schema（建表/ALTER）与 `02 Part D` 一致
- [ ] Service/Controller 分层与 `02` 设计一致，无擅自合并或拆分
- [ ] 没有实现 Spec 之外的额外功能（YAGNI）

### 第二阶段：质量检查（Quality）— 代码本身过关吗？

- [ ] `mvn test` 所有单元测试通过（不允许 -DskipTests）
- [ ] 每个新增 Service 方法至少有一个对应测试（RED-GREEN-REFACTOR 已完成）
- [ ] 每个新增 Controller 端点至少有一个集成测试
- [ ] 02 Part E 的每个场景在测试代码中都有对应 test case
- [ ] 无注释掉的废弃代码
- [ ] 无遗漏的 TODO/FIXME
- [ ] 异常处理到位（直接抛 CommonException，无 null 语义不明）
- [ ] 日志中无密钥/Token/密码明文

---

## 前端模式（FE）

### 第一阶段：合规检查（Compliance）— 我做的和 Spec 一致吗？

- [ ] 路由路径与 `02 Part B` 的路由树逐一核对
- [ ] 组件树结构与 `02 Part B` 定义一致
- [ ] Vuex State/Getter/Action 与 `02 Part B` 字段映射一致
- [ ] 表格列定义（columns）与 `02 Part B` B-4 字段映射表逐列核对：列是否存在、渲染方式（tag/tooltip/截断/mapper/状态点）、列宽
- [ ] API 调用参数、URL、响应字段处理与 `02 Part A` 的 Contract 一致
- [ ] 没有实现 Spec 之外的额外功能（YAGNI）

### 第二阶段：质量检查（Quality）— 代码本身过关吗？

- [ ] `npm run lint` 无错误
- [ ] 构建验证通过（`npm run build` 或 `npm run generate`）
- [ ] 所有业务组件加了 `<style scoped>`
- [ ] Dialog 关闭时表单已重置
- [ ] 错误处理：无业务层重复弹出提示
- [ ] 新增按钮/页面已配置权限控制
- [ ] UI 设计规范合规：组件选型遵循 frontend-ui-design §2 决策树，颜色/间距/圆角引用 §3 Token，自检清单 §10 已逐项核对
- [ ] 02 Part E 的前端场景在验证清单中都有对应
- [ ] 新增 utils / store actions 有对应单元测试

---

## 输出格式

将两阶段检查结果写入 evidences/ 后，输出摘要：

```
[自查] 合规：✅/❌ | 质量：✅/❌
问题：[如有，列出具体项]
```

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
