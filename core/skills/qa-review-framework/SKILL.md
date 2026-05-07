---
name: qa-review-framework
description: QA 审查框架。定义审查文件依赖清单、四轴（后端/前端）和五轴（全栈）审查标准、测试审计标准、审查自检清单。供 qa-agent 引用。
---

# QA 审查框架

> 本 Skill 定义 QA Agent 的审查标准和工作流程。QA Agent 的角色特有红线和产出定义在 qa-agent.md 中。

## 加载引导

- **必加载场景**：QA Agent 启动审查时
- **可跳过场景**：其他 Agent

---

## 审查文件依赖清单

| 文件 | 产出者 | 用途 | 性质 |
|------|--------|------|------|
| `01_requirement.md` | PM | Spec 达成率的判断标准 | **审查标准** |
| `02_technical_design.md` | Arch | 代码一致性的判断标准 | **审查标准** |
| `03_impl_backend.md` | Dev | 后端执行日志 | 参考 |
| `03_impl_frontend.md` | FE | 前端执行日志 | 参考 |
| `04_test_plan.md` | Dev/FE | 测试覆盖完整性的审计标的 | **审计对象** |
| `evidences/` | Dev/FE | 自测证据 | 参考 |

> 03 是执行日志，不是审查标准。判断代码对错的标准只有 01 + 02。
> 工作流 A 只需读 backend，工作流 B 只需读 frontend，工作流 C 两者都要读。

## 后端审查（工作流 A）

**加载**：后端项目的 `coding_backend.md` + 审查规则（sql-checker、api-reviewer）

| 轴 | 检查内容 | 对标文件 |
|----|---------|---------|
| Spec 达成率 | AC 逐项核对，预期行为是否全部实现 | 01_requirement.md |
| 代码一致性 | API 端点、请求/响应结构、DB Schema 是否忠实于技术设计 | 02_technical_design.md |
| 代码质量 & 安全 | 分层合规、SQL 规范（禁拼接、必分页）、异常处理、日志脱敏 | coding_backend.md |
| 反过度设计 | YAGNI/KISS，空壳 Service 等过度抽象作为缺陷指出 | — |

**构建验证**：执行 CLAUDE.md 中定义的后端构建命令。

**测试审计**（针对 `04_test_plan.md`）：
1. 覆盖完整性 — 02 Part E 列出的每个场景，在 04 Part A 矩阵中是否都有对应测试
2. 测试有效性 — 抽查 2-3 个测试代码，断言是否真的验证了业务规则
3. 盲区补充 — 补充 Arch/Dev 未覆盖但 QA 认为重要的场景
4. 全流程可执行性 — 04 Part B 的 curl 命令格式是否正确、步骤是否完整
5. 边界用例覆盖 — 对照 spec-templates 的「边界用例必测清单」
6. 反模式检查 — 抽查是否存在「测实现不测行为」「测试间共享状态」「断言过弱」

## 前端审查（工作流 B）

**加载**：`coding_frontend_shared.md` + `frontend-ui-design/SKILL.md` + 目标 App 的 `frontend_coding.md`

| 轴 | 检查内容 | 对标文件 |
|----|---------|---------|
| Spec 达成率 | AC 逐项核对（含正常流程 + 异常状态 + 无权限/无数据） | 01_requirement.md |
| 代码一致性 | 路由/组件树/State/API 映射、B-4 字段映射表逐列核对（列是否存在、渲染方式 tag/tooltip/截断/mapper/状态点、列宽）是否忠实于技术设计 | 02_technical_design.md |
| 代码质量 & 安全 | scoped 强制、样式深度穿透规范、错误处理、权限码、UI 设计规范合规 | coding_frontend_shared.md + frontend-ui-design |
| 反过度设计 | 是否过度封装、是否复用了全局组件 | — |

**构建验证**：执行 `cd <目标App目录> && npm run lint`。

**测试审计**：
1. 覆盖完整性 — 02 Part E 列出的每个前端场景是否都有对应
2. 测试有效性 — 抽查单元测试代码
3. 盲区补充 — 补充未覆盖的场景
4. 人工验证清单完整性 — 04 Part B 操作步骤是否足够

## 全栈审查（工作流 C）

同时执行后端审查 + 前端审查，额外增加第五轴：

| 轴 | 检查内容 | 对标文件 |
|----|---------|---------|
| API 契约一致性 | 02 Part A 定义 vs 后端实际实现 vs 前端实际调用，三者一致；**后端响应封装类的分页数据序列化字段名必须与 Spec Response 示例一致，不得直接照搬 ORM 框架默认格式** | 02_technical_design.md Part A + Part B |

## 审查自检（出具结论前必须执行）

1. **是否真正逐项核对了 01 的每个 AC**？还是凭"大概看了没问题"就 PASS？
2. **是否比对了 02 的 API Schema / DB DDL / 组件树与实际代码**？还是只做了泛泛的代码 Review？
3. **04 测试审计**：是否抽查了至少 2 个测试代码，验证断言有效性？
4. **反过度设计**：是否检查了空壳 Service、不必要的中介层、过度封装？
5. **独立性**：审查结论是否受到 Dev/FE 自测结果的影响？

输出格式：
```
[QA 自检] AC逐项核对：✅/❌ | Schema比对：✅/❌ | 测试抽查：✅/❌ | 反过度设计：✅/❌ | 独立性：✅/❌
审查深度：已阅读 X 个变更文件，抽查 Y 个测试代码
```

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
