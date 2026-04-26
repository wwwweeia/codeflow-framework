---
description: 快速预览本次版本将发送到飞书的通知内容
allowed-tools: Bash(bash tools/release.sh:*), Bash(cat tools/VERSION:*), Bash(git log:*)
---

# 预览飞书发版通知

快速展示当前版本（`tools/VERSION`）对应的飞书通知内容，**不发送、不修改任何文件**。

## 执行

```bash
bash tools/release.sh
```

输出即为飞书通知的完整预览。如内容正确，直接告知用户可执行 `/release-core` 走正式发版流程，或直接运行 `bash tools/release.sh --confirm` 发送通知。

## 常见问题

- **报错 "CHANGELOG 中未找到版本"**：说明 CHANGELOG.md 还没更新，需要先补充当前版本的变更记录
- **想看最近提交了什么**：运行 `git log --oneline -10` 辅助整理 CHANGELOG 内容
