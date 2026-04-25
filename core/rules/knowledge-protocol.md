# 知识加载协议（框架标准）

> 本文件是所有 Agent 的知识加载行为规则。Claude Code 自动加载本文件，所有 Agent 无需额外引用即可感知。

---

## 1. 目录约定

每个子项目（后端 / 前端 App）的知识资产按以下结构组织：

```
<子项目>/.claude/
  rules/                        → 硬约束（Agent 需主动读取，不会自动加载）
  context/                      → 软知识（Agent 按 knowledge-index 按需加载）
  context/knowledge-index.md    → 知识索引入口（Agent 的唯一入口文件）
  context/cookbook-*.md         → 场景实操指南（带完整代码示例）
  context/pattern-*.md          → 设计模式与最佳实践
  context/<项目类型特定>.md      → 路由/Store/组件/API 约定等（初始化时生成）
```

### 判断一条知识该放哪里

| 问题 | rules | cookbook | pattern | context |
|------|-------|----------|---------|---------|
| 违反了算 Bug 吗？ | 是 | 否 | 否 | 否 |
| 有完整代码示例吗？ | 不需要 | **必须有** | 有片段 | 不需要 |
| 描述的是"怎么做"还是"为什么"？ | 怎么做 | 怎么做 | **为什么** | 是什么 |
| 会被多个场景复用吗？ | — | 单场景 | **多场景** | — |

### 不应放入知识体系的内容

- 纯代码导航（放 Codemap：`.claude/codemap/domains/`）
- 一次性临时信息（放 Spec 目录：`.claude/specs/feature-<name>/`）
- 框架已管理的通用规则（放 `core/rules/`，通过 upgrade.sh 同步）

---

## 2. 加载协议

Agent 进入具体子项目执行任务时，按以下步骤加载知识：

1. **检查知识索引**：读取目标子项目的 `.claude/context/knowledge-index.md`（不存在则跳过后续步骤）
2. **匹配任务**：根据 knowledge-index 中「任务到知识映射」表，匹配当前任务场景
3. **加载知识文件**：若匹配到映射行，读取对应的 cookbook/pattern 文件
4. **不阻塞**：知识索引不存在或无匹配行时，跳过，不影响工作流

### 加载优先级

```
rules（硬约束，自动加载） > cookbook（实操指南，按需加载） > pattern（设计模式，按需参考）
```

---

## 3. 各角色加载上下文

| 角色 | 目标子项目 | 知识索引路径 |
|------|-----------|-------------|
| Dev (后端模式) | 后端项目 | `<后端项目目录>/.claude/context/knowledge-index.md` |
| FE (前端模式) | 目标前端 App | `<目标App目录>/.claude/context/knowledge-index.md` |
| Arch (后端模式) | 后端项目 | `<后端项目目录>/.claude/context/knowledge-index.md` |
| Arch (前端模式) | 目标前端 App | `<目标App目录>/.claude/context/knowledge-index.md` |
| Arch (全栈模式) | 后端 + 前端 App | 两侧均检查 |
| QA (后端审查) | 后端项目 | `<后端项目目录>/.claude/context/knowledge-index.md` |
| QA (前端审查) | 目标前端 App | `<目标App目录>/.claude/context/knowledge-index.md` |
| QA (全栈审查) | 后端 + 前端 App | 两侧均检查 |

> 具体项目路径和 App 列表参见 CLAUDE.md。

---

## 4. 角色特定行为

### Dev / FE Agent

- **时机**：Research 阶段
- **使用**：实现中必须参考已加载 cookbook 的数据流和关键点
- **反馈**：如发现 cookbook 与实际代码不一致，记录到 `03_impl_*.md` 并上报主对话

### Arch Agent

- **时机**：Research 阶段（加载上下文时）
- **使用**：了解已有知识资产，设计时对齐 cookbook 描述的既定模式
- **对齐检查**：技术设计方案如偏离已有 cookbook/pattern，必须在 `02 Part C`（技术风险）中说明原因

### QA Agent

- **时机**：Load Specs 阶段
- **使用**：读取知识条目作为审查补充参考
- **覆盖度检查**：检查本次变更涉及的功能区域是否有对应知识条目；如缺少，在审查报告中建议补充

### 主会话

- **时机**：派发 Agent 时
- **行为**：如目标子项目存在 `knowledge-index.md`，在派发 prompt 中提示 Agent 参考知识索引（Agent 自行按需加载，主会话不预加载内容）

---

## 5. 知识沉淀触发

完成任务后，各角色检查是否需要沉淀新知识，形成「加载 → 使用 → 沉淀」闭环：

| 角色 | 沉淀时机 | 触发条件 | 沉淀动作 |
|------|---------|---------|---------|
| Dev / FE | 编码完成后 | 发现可复用的代码模式 | 建议创建 `cookbook-<场景>.md`，在 `knowledge-index.md` 注册映射 |
| Arch | 设计完成后 | 发现新的通用架构方案 | 建议创建 `pattern-<模式>.md`，在 `knowledge-index.md` 注册映射 |
| QA | 审查完成后 | 发现新的反模式或常见问题 | 建议更新 `rules/` 下对应规则文件 |
| 主会话 | 合并完成后 | 涉及新业务域 | 提示更新 `knowledge-index.md` 的映射表 |

### 沉淀原则

- **不预先批量生产**：知识在实际开发任务中逐步沉淀，不凭空设计
- **来源可追溯**：每条知识关联到产出它的 Spec 或代码审查发现
- **通用性检验**：沉淀前判断"换一个项目，这条知识还有用吗？"——有用考虑提升到框架 Skill

<!-- codeflow-framework:core v2.1.0-20260423 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
