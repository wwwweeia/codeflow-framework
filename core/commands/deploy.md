快速部署命令。自动执行澄清、参数判断、构建推送，非阻塞返回。

## 澄清二问（必须，不可跳过）

如果 `$ARGUMENTS` 已指定项目名，跳过第一问；否则两问都必须问。

```
1. 部署哪个项目？
   可选：<参见 marker 下方项目清单>
2. 确认代码已合并到 develop 分支？
```

任何一问未答，不得触发构建脚本。

## 前端参数自动判断

对前端项目，自动检测最近提交中是否变更了 `package.json`：

```bash
git log origin/develop -5 --name-only --pretty=format: | grep "package.json"
```

- 有匹配 → 传参 `1`（npm install + generate）
- 无匹配 → 传参 `0`（仅 generate）
- 无法判断 → 询问用户

## 执行

根据 marker 下方的项目构建命令表执行。

- 多项目并行执行，互不等待
- 每个项目 push 完成后即时汇报
- push 完成即返回，不等待自动部署

## 完成后输出

```
<项目名> 镜像已推送（develop），Watchtower 约 60s 内完成部署
```

## 约束

- 此流程独立于工作流 A/B/C，无需经过 PM/Dev/QA
- 不执行任何代码修改，只触发构建
- 用户未明确说"全部"时，不得擅自扩展部署范围
- 构建失败如实汇报，不自动重试，等待用户决策

用户的原始输入（如果有）：$ARGUMENTS

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
