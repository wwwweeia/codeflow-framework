模块/业务域快速上手命令。输入模块名，输出架构概览、核心文件、数据流和常见坑点。

## 使用方式

```
/onboard <模块名或业务域>
```

示例：`/onboard gateway`、`/onboard agent`、`/onboard ai-kg-front`

## 执行步骤

### 1. 定位资料

按以下顺序查找模块相关资料（有则读取，无则跳过）：

- **Domain Codemap**：`.claude/codemap/domains/domain-<模块>.md`
- **业务域 Spec**：`.claude/specs/SPEC-INDEX.md` → 对应 Spec 文件
- **编码规则**：后端 `.claude/rules/coding_backend.md` / 前端 `<App>/.claude/rules/frontend_coding.md`
- **历史 Feature Specs**：`.claude/specs/feature-*/` 中与该模块相关的

### 2. 代码扫描

- 识别核心文件：Controller、Service、Mapper、Entity（后端）或 pages、components、store（前端）
- 梳理调用链：入口 → 核心逻辑 → 数据层 / 外部依赖
- 标注关键数据表及其关联关系

### 3. 输出模板

```
## <模块名> 上手指南

### 一句话定位
<这个模块做什么，服务于谁>

### 核心文件
| 文件 | 职责 |
|------|------|
| ... | ... |

### 数据流
<入口> → <核心处理> → <数据层/外部调用>

### 关键表
| 表名 | 用途 | 关联 |
|------|------|------|
| ... | ... | ... |

### 已有规范
- Codemap：<路径或"无">
- Spec：<路径或"无">
- 编码规则：<路径或"无">

### 常见坑点
- ...
```

## 约束

- 只读操作，不修改任何文件
- 优先从已有 Codemap/Spec 提炼，避免重复扫描大量代码
- 如果模块名无法匹配，列出可选的模块清单供用户选择

用户的原始输入（如果有）：$ARGUMENTS

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
