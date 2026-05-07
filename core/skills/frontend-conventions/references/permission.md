## 权限配置规范

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

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
