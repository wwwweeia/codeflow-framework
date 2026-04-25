# Codemap vs Specs — 职责对比与使用指南

> 本文档供主对话和所有 Agent 参考，厘清两类持久化资产的边界与协作关系。

---

## 一句话定位

| 资产 | 定位 |
|------|------|
| **Codemap** | 已有代码的导航索引——"现在的代码长什么样" |
| **Specs** | 单次 Feature 的完整开发档案——"这次要做什么、怎么做、做完了没" |

---

## 核心区别

| 维度 | Codemap | Specs |
|------|---------|-------|
| 描述对象 | 已有代码现状 | 待开发 Feature |
| 时间视角 | 现在 | 将来（计划）→ 过去（存档） |
| 生命周期 | 持续维护，永久有效 | Feature 完成后归档，不再修改 |
| 存储粒度 | 按业务域（domain） | 按 Feature（单次需求） |
| 主要作者 | arch-agent（读代码后产出） | PM / Arch / Dev / FE / QA 链式接力 |
| 更新时机 | 每次 Feature QA PASS 后 | Feature 各阶段逐步填写 |

---

## 存储位置

```
.claude/
  codemap/
    domains/                       ← 按业务域，唯一文件，持续更新
      domain-<业务域>.md
      HOWTO-generate-codemap.md    ← 生成规范

  context/
    codemap-template.md            ← Codemap 文件模板
    knowledge-index.md             ← 子模块知识索引（按需加载，Agent 入口）
    cookbook-*.md                   ← 场景实操指南（如 cookbook-websocket-chat.md）
    pattern-*.md                    ← 设计模式文档

  specs/
    SPEC-INDEX.md                  ← 所有业务域导航表 + Codemap 索引
    feature-<name>/                ← 一个 Feature = 一个目录
      01_requirement.md            ← PM 产出：业务需求（无技术细节）
      02_technical_design.md       ← Arch 产出：API + DB Schema + 组件设计
      03_impl_backend.md           ← Dev 产出：执行日志 + 自测证据
      03_impl_frontend.md          ← FE 产出：执行日志 + 自测证据
      evidences/                   ← QA 产出：验收证据、构建结果
    spec-template.md               ← Spec 文件模板
```

---

## 各自记录什么

### Codemap 记录

- Controller / Service / Mapper 分层和关键方法（含文件路径:行号）
- 现有调用链（Mermaid 流程图，≤ 15 节点）
- 数据库表结构、关键字段枚举值（如 `status: active/inactive`）
- 外部集成点（调用时机、方式、入口方法）
- 风险热点（事务边界、隐式约定、非原子补偿逻辑）
- **第 7 节"影响分析"是唯一动态区**：Feature 开发前由 arch-agent 填入本次改动点；QA PASS 后清空，恢复为占位状态

### Specs 记录

- `01_requirement.md`：业务目标、边界、不做项、验收标准（AC）——纯业务，无技术细节
- `02_technical_design.md`：API 契约（端点/Request/Response/Error）、DB Schema 变更、组件树 / Vuex State / API 字段映射
- `03_impl_*.md`：实现步骤、偏差说明、自测命令和输出（backend/frontend 分开）
- `evidences/`：构建日志、QA Review 结论（五轴验收）

---

## 协作关系

```
开始新 Feature
    ↓
arch-agent 查 SPEC-INDEX.md
    ├── 有对应 domain codemap → 读现有文件，增量 Research，更新第 7 节影响分析
    └── 无对应 domain codemap → 完整 Research，新建 domain-<业务域>.md
    ↓
arch-agent 产出 02_technical_design.md（写入 Specs）
    ↓
Dev / FE 按 Spec 实现，产出 03_impl_*.md
    ↓
QA PASS → 主会话提示 arch-agent
    ↓
arch-agent 更新 domain-*.md
    ├── 第 4 节（后端分层）、第 5 节（前端分层）、第 6 节（数据结构）反映新代码现状
    └── 第 7 节清空，恢复占位状态
```

**Codemap 是 Specs 的输入，Specs 完成后反向更新 Codemap。**

---

## Agent 加载规则

| 场景 | 应加载 |
|------|--------|
| arch-agent 开始 Research | 先查 `SPEC-INDEX.md` 确认有无现有 Codemap |
| arch-agent 产出技术设计 | 读对应 `domain-*.md` 的第 1~6 节，填写第 7 节 |
| dev-agent / fe-agent 开始实现 | 读 `02_technical_design.md`（Spec），不直接读 Codemap |
| QA 验收 | 读 `01_requirement.md` AC + `02_technical_design.md` 契约 + `03_impl_*.md` 实现说明 |
| Feature 完成，主会话通知更新 | arch-agent 读新代码 → 更新 domain-*.md |
| dev-agent / fe-agent Research | 按知识加载协议（`knowledge-protocol.md`）检查目标子项目知识体系 |
| arch-agent Research | 按知识加载协议检查知识体系，设计对齐已有 cookbook 模式 |
| QA Review | 按知识加载协议检查覆盖度，缺少知识条目时建议补充 |

---

## 相关文件索引

| 文件 | 用途 |
|------|------|
| `.claude/context/codemap-template.md` | Codemap 文件模板（9 节标准结构） |
| `.claude/codemap/domains/HOWTO-generate-codemap.md` | 如何生成高质量 Codemap（经验沉淀） |
| `.claude/specs/spec-template.md` | Spec 文件模板 |
| `.claude/specs/SPEC-INDEX.md` | 所有业务域导航表，含 Codemap 链接 |

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
