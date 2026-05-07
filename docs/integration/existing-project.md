---
title: 已有项目
description: 已接入 HCodeFlow 的项目的日常使用 — 升级、收割、版本管理
prev:
  text: 新项目接入
  link: /integration/new-project
next:
  text: 团队接入
  link: /integration/team-onboarding
---

# 已有项目的日常使用

> 你的项目已经接入 HCodeFlow（`.claude/` 目录已存在）？这里讲日常使用。

---

## 升级框架版本

当框架发布新版本时，用 `upgrade.sh` 同步更新：

### 预览变更（推荐先做）

```bash
# 在业务项目目录执行
bash ../h-codeflow-framework/tools/upgrade.sh --dry-run       # 预览哪些文件会变
bash ../h-codeflow-framework/tools/upgrade.sh --dry-run --diff  # 预览详细 diff
```

### 正式升级

```bash
bash ../h-codeflow-framework/tools/upgrade.sh          # 正式执行
bash ../h-codeflow-framework/tools/upgrade.sh --diff    # 执行并显示 diff
```

**升级保证**：Marker 下方的自定义内容**永远不会被覆盖**。

### 处理冲突

如果下游项目的 Marker 上方内容有本地修改：

| 参数 | 行为 |
|------|------|
| （默认） | 备份 `.local` 副本后继续覆盖，最后汇总提示 |
| `--conflict=preserve` | 跳过冲突文件，保留本地修改 |
| `--conflict=fail` | 遇到冲突直接退出（CI 用） |
| `--force` | 跳过冲突检测，强制覆盖 |

### 回滚

`upgrade.sh` 每次执行会自动备份到 `.claude/.backup/`：

```bash
# 查看备份
ls .claude/.backup/

# 恢复
cp -r .claude/.backup/upgrade-YYYYMMDD-HHMMSS/* .claude/
```

---

## 从项目贡献回框架（Harvest）

如果你在 Marker 上方做了有价值的改进（如优化了 Agent 行为、工作流规则等），可以用 `harvest.sh` 收割回框架：

### 预览差异

```bash
# 在框架目录执行
bash tools/harvest.sh ../your-project    # 只看 diff，不写入
```

### 正式收割

```bash
bash tools/harvest.sh --apply ../your-project   # 实际写入 core/
```

**收割规则**：
- 只提取 Marker 行及以上的内容
- Marker 下方的项目自定义内容不会被收割
- 默认 dry-run 模式（只看 diff），`--apply` 才实际写入

**收割审查要点**：
- 确保去除了项目特有引用（项目名、端口、地址）
- 确保内容是通用的，其他项目也能用
- 确保 Marker 上方结构完整

---

## 环境诊断

遇到问题时，先用诊断工具检查：

```bash
# 在框架目录执行
bash tools/doctor.sh           # 完整检查
bash tools/doctor.sh --quiet   # 只显示有问题的项
bash tools/doctor.sh --json    # JSON 格式（CI 集成）
```

---

## 子项目管理

### 检查子项目状态

```bash
# 查看子项目 .claude/ 是否存在
ls 子项目目录/.claude/
```

### 补充子项目

如果初始化时漏了子项目：

```bash
bash ../h-codeflow-framework/templates/init-subproject.sh ./子项目路径 fe "项目名"
```

### 更新子项目上下文

子项目的 `.claude/context/` 文件可以手动或让 AI 自动填充：
- **前端**：components.md（组件清单）、routes.md（路由结构）、stores.md（状态管理）
- **后端**：tech-stack.md（技术栈）、api-conventions.md（API 约定）

用 `/onboard <模块名>` 测试，AI 能输出完整的模块概览就说明上下文配置良好。

### 补充知识沉淀

如果初始化时跳过了知识扫描，可以在日常使用中手动触发：

1. 在 Claude Code 中对子项目说「扫描并建议 cookbook」
2. AI 会扫描代码中的复杂场景，建议创建 cookbook 条目
3. 确认后自动创建文件并更新 `knowledge-index.md`

也可以在 Feature 开发完成后，提示 Agent 沉淀新发现的知识（参见 `knowledge-protocol.md`）。

---

## 下一步

- **团队其他成员如何上手？** → [团队接入指南](/integration/team-onboarding)
- **遇到问题？** → [故障排查](/getting-started/troubleshooting)
- **想了解工具详情？** → [工具速查](/getting-started/tools)
