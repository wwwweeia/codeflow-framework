## 变更类型

- [ ] 新功能 (Feature)
- [ ] Bug 修复 (Fix)
- [ ] 文档更新 (Docs)
- [ ] 重构 (Refactor)
- [ ] 工具/脚本改进 (Tools)

## 变更描述

<!-- 简要描述这个 PR 做了什么，以及为什么要做 -->

## 相关 Issue

<!-- 关联的 Issue 编号，如 Closes #123 -->

## 自查清单

- [ ] 在 `demo/` 中执行 `bash ../tools/upgrade.sh --diff` 验证通过
- [ ] 更新 `CHANGELOG.md`（如涉及用户可感知的变更）
- [ ] 同步更新文档（参照 CLAUDE.md 中的"源文件 → 文档映射"表）
- [ ] Stub Marker 完整且位置正确（如修改了 `core/` 文件）
- [ ] Shell 脚本通过 `bash -n` 语法检查（如修改了 `tools/` 或 `templates/`）
- [ ] 如新增/删除文件，已同步更新 `core/MANIFEST`
