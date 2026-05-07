# 合并流程 SOP (Merge SOP)

在任何 `feature/*`、`fix/*` 或 `refactor/*` 分支合并前，**只有在用户明确同意后，AI 才可以执行合并与推送流程。**

> 代码质量检查由 QA Agent + 编码规则（`coding_backend.md` / `coding_frontend_shared.md`）覆盖，本文件只定义合并操作步骤。

## 合并流程

> **执行主体**：主会话（不是 QA Agent）。QA 只负责审查和出结论。

QA 给出 `PASS`、运行验证通过、用户确认合并后，**主会话**执行以下动作：

1. **状态检查**：确认当前在 `feature/*` 分支，无未提交的必要修改
2. **提交**：`git add <相关文件>` → `git commit` 并附简要描述
3. **切换与拉取**：`git checkout develop` → `git pull origin develop`
4. **合并**：`git merge --no-ff <feature_branch>`
   - 冲突时**立即中断**，通知用户处理
5. **推送**：`git push origin develop`
6. **清理**：删除 feature 分支（本地 + 远端）
7. **报告**：汇报合并结果

**注意**：参考 `CLAUDE.md` 中的分支策略确定基础分支和合并规则。

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
