# 现有项目迁移指南

> 本指南说明如何将已有项目迁移到 codeflow-framework。

## 前置条件

- 项目已有基本的 `.claude/` 目录结构
- 项目位于与 `codeflow-framework` 同级的目录中
- 项目已初始化 git 仓库

## 迁移步骤

### Step 1：备份现有 .claude/ 目录

```bash
cd your-project
cp -r .claude .claude.backup.$(date +%Y%m%d)
```

### Step 2：运行 init 脚本（可选，仅初始化缺失文件）

如果 `.claude/` 目录不完整，可选择运行 init 脚本来完成初始化：

```bash
sh ../codeflow-framework/templates/init-project.sh . "Project Name"
```

脚本会自动检测并创建缺失的目录和文件。

### Step 3：更新 Marker（关键）

为现有的框架管理文件添加 marker。对于以下文件：

- `.claude/agents/*.md`
- `.claude/rules/project_rule.md`
- `.claude/rules/merge_checklist.md`
- `.claude/skills/*/SKILL.md`
- `.claude/context/branches.md`

添加 marker 注释。**注意：不同文件类型的 marker 位置不同**：

**Agent 文件**（`.claude/agents/*.md`）— marker 必须在**文件末尾**（Claude Code 要求第一行必须是 `---`，且 body 内容也由框架管理）：

```markdown
---
name: agent-name
description: ...
tools: [...]
model: sonnet
---

Agent body content（框架管理）...

<!-- codeflow-framework:core v1.0.0-20260416 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->

（项目自定义扩展内容放在 marker 下方，如有）
```

**其他文件**（rules、skills、context）— marker 在文件**第一行**：

```markdown
<!-- codeflow-framework:core v1.0.0-20260416 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->

File content...
```

### Step 4：测试升级脚本

运行升级脚本，确保能正确识别和更新文件：

```bash
sh ../codeflow-framework/tools/upgrade.sh
```

检查输出，确认没有错误。

### Step 5：验证项目可用性

检查关键文件是否完整：

```bash
ls -la .claude/{agents,rules,skills,context,specs,codemap,project-memory}
```

### Step 6：更新 CLAUDE.md（项目级）

如果项目的 `CLAUDE.md` 中引用了旧的框架或工具名称，请更新为 `codeflow-framework`。

### Step 7：初始化 project-memory（可选）

如果项目是新接入框架，可创建初始的项目记忆：

```bash
cat > .claude/project-memory/MEMORY.md << 'EOF'
# 项目协作记忆索引

## 已有记忆

- [项目迁移记录](migration_2026-04-16.md) — 2026-04-16 迁移至 codeflow-framework

EOF
```

## 迁移检查清单

- [ ] 备份了原始 `.claude/` 目录
- [ ] 运行了 init-project.sh（如需）
- [ ] 为所有框架管理文件添加了 marker
- [ ] 测试运行了 upgrade.sh
- [ ] 验证了关键目录结构
- [ ] 更新了 CLAUDE.md 中的框架引用
- [ ] 初始化了 project-memory（可选）
- [ ] 提交了迁移变更：`git add .claude && git commit -m "chore: migrate to codeflow-framework"`

## 常见问题

### Q: 现有的 .claude/ 文件会被覆盖吗？

A: **不会**。upgrade.sh 只更新 marker 上方的框架内容，marker 下方的项目自定义内容会被自动保留。

### Q: 可以跳过 marker 添加步骤吗？

A: 如果只想使用框架的工作流规则而不需要自动升级，可以跳过。但强烈建议添加 marker，以便后续框架更新时能自动同步。

### Q: 迁移后如何快速了解框架？

A: 
1. 阅读本项目的 README.md
2. 阅读 `.claude/rules/project_rule.md`（工作流说明）
3. 阅读 `CLAUDE.md`（项目特定约定）
4. 阅读 `.claude/skills/domain-ontology/SKILL.md`（业务术语）

### Q: 如果 marker 格式不对怎么办？

A: upgrade.sh 会跳过没有正确 marker 的文件。可手动修复 marker 格式后重新运行。

## 迁移后的升级流程

迁移完成后，按照以下流程保持框架同步：

1. **定期升级**（推荐每 2-3 周）：
   ```bash
   sh ../codeflow-framework/tools/upgrade.sh
   ```

2. **查看升级日志**：脚本会输出更新的文件列表和备份位置

3. **审查变更**：
   ```bash
   git diff .claude/
   ```

4. **提交升级**：
   ```bash
   git add .claude && git commit -m "chore: upgrade codeflow-framework"
   ```

## 支持与问题

如果迁移过程中遇到问题，请：
1. 查看脚本的错误输出
2. 检查 marker 格式是否正确
3. 参考本指南的常见问题部分

