# 02_technical_design.md 模板

> Arch Agent 撰写，产出技术设计与实现方案。后端项目填 Part A/D/C，前端项目填 Part B/C。

## 结构（后端）

```markdown
# 技术设计：[功能名称]

## Part A: API Contract

### 新增 API
- 端点：`POST /api/v1/users`
- 请求：{ name, email, ... }
- 响应：{ code, message, data: { id, name, ... } }
- 错误：{ code: 400, message: "邮箱格式错误" }

### 修改 API
- ...

## Part D: DB Schema

### 新增表
\`\`\`sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ...
);
CREATE INDEX idx_users_email ON users(email);
\`\`\`

### 修改表
\`\`\`sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
\`\`\`

## Part C: 技术风险与注意事项
- 风险 1：...
- 风险 2：...
- 注意事项：...
```

## 结构（前端）

```markdown
# 技术设计：[功能名称]

## Part B: 页面/路由/组件设计

### 路由
- 新增路由：`/user/profile`

### 页面结构
```
UserProfile
  ├─ Header（用户基本信息）
  ├─ Form（编辑表单）
  └─ Actions（提交/取消按钮）
```

### Vuex State
- 新增：`user.profile = { id, name, email, ... }`
- 新增 mutation：`setUserProfile(state, profile)`

### API 字段映射
| 后端字段 | 前端字段 | 说明 |
|---------|---------|------|
| user_id | id | 用户 ID |
| name | name | 用户名 |
| ... | ... | ... |

## Part C: 技术风险与注意事项
- 风险 1：...
- 注意事项：...
```

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
