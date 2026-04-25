扫描所有 Spec 目录，输出各 Feature 和业务域 Spec 的当前状态总览。

## 执行步骤

### 1. 扫描业务域 Spec

读取 `.claude/specs/SPEC-INDEX.md`，提取 Section 2 维护状态表，输出各业务域状态。

### 2. 扫描 Feature Specs

遍历 `.claude/specs/feature-*/` 和 `.claude/specs/YYYY-MM-DD_hh-mm_*/` 目录，按目录内文件判断阶段：

| 存在的文件 | 判定阶段 |
|-----------|---------|
| 仅 `01_requirement.md` | PM（需求已完成） |
| + `02_technical_design.md` | Arch（技术设计已完成） |
| + `03_impl_backend.md` | Dev（后端实现中/已完成） |
| + `03_impl_frontend.md` | FE（前端实现中/已完成） |
| + `evidences/` 目录有内容 | QA（验收中/已完成） |

同时检查 `evidences/` 下是否有 `evidence-qa.md` 且结论为 PASS，判定是否已 Done。

### 3. 输出格式

```
## Spec 状态总览

### 业务域 Spec
| 业务域 | 状态 | 版本 | 最后更新 |
|--------|------|------|---------|
| ... | ... | ... | ... |

### Feature Specs
| Feature | 阶段 | 创建时间 | 包含文件 |
|---------|------|---------|---------|
| ... | PM / Arch / Dev / FE / QA / Done | ... | ... |

### 统计
- 业务域 Spec：N 个 active / N 个待创建
- Feature Spec：N 个进行中 / N 个已完成
```

## 约束

- 只读操作，不修改任何文件
- 如果 specs 目录为空，提示用户尚无 Spec 并给出创建指引

用户的原始输入（如果有）：$ARGUMENTS

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
