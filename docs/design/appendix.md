---
title: 九、附录
description: Spec 目录结构与 Git 分支策略
prev:
  text: 八、核心工具参考
  link: /design/tools
next: false
---

# 九、附录

## A. Spec 目录结构

每个功能的 Spec 文档按以下结构组织：

```
.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/
├── 01_requirement.md          PM 产出：业务需求 + 验收标准
├── 02_technical_design.md     Arch 产出：技术设计方案（含 API/DB/前端/测试场景/风险）
├── 03_impl_backend.md         Dev 产出：后端执行日志
├── 03_impl_frontend.md        FE 产出：前端执行日志
├── 04_test_plan.md            Dev/FE 产出：测试计划（追溯矩阵 + 用例）
└── evidences/                 验证证据
    ├── evidence-qa-review.md  QA 审查结论
    └── evidence-api-test.md   API 测试结果
```

## B. Git 分支策略

| 分支 | 用途 | 命名规则 |
|------|------|---------|
| `master` | 生产分支 | — |
| `develop` | 开发主线 | — |
| `feature/*` | 功能开发 | `feature/YYYYMMDD-简述` |
| `fix/*` | Bug 修复 | `fix/YYYYMMDD-简述` |
| `refactor/*` | 重构 | `refactor/YYYYMMDD-简述` |

**合并流程**（由主会话执行）：

```bash
# 1. 确认在 feature 分支且无未提交修改
git status

# 2. 提交所有变更
git add . && git commit -m "feat: ..."

# 3. 切换到 develop 并拉取最新
git checkout develop && git pull origin develop

# 4. 合并（保留分支历史）
git merge --no-ff feature/YYYYMMDD-xxx

# 5. 推送
git push origin develop

# 6. 清理分支
git branch -d feature/YYYYMMDD-xxx
git push origin --delete feature/YYYYMMDD-xxx
```

---

**版本**：1.10.0-20260422 | **维护者**：wqw | **更新日期**：2026-04-22
