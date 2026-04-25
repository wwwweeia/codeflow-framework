# framework-feedback 技能环境配置指南

下游项目团队在使用框架反馈技能前，需完成以下配置。

> **快速检查**：在项目目录执行 `gh issue list`，如果能看到 Issue 列表（哪怕是空的），说明环境已就绪。

## 前置条件

| 依赖 | 用途 | 必需？ |
|------|------|--------|
| gh CLI | 创建 GitHub Issue | 是（无则降级为仅 Webhook 通知） |
| GitHub 账号权限 | 在 github.com 有项目访问权限 | 是 |
| python3 | 脚本运行环境 | 是（Claude Code 自带） |

## 第 1 步：安装 GitHub CLI

**macOS（推荐）**：
```bash
brew install gh
```

**Linux**：
```bash
# Debian/Ubuntu
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

**验证安装**：
```bash
gh version
```

## 第 2 步：配置 GitHub 认证

在**项目根目录**执行以下命令，完成 GitHub 认证：

```bash
gh auth login
```

交互式引导中选择：

```
? What is your preferred protocol for Git operations?  → HTTPS
? How would you like to authenticate GitHub CLI?        → Login with a web browser
```

按提示复制一次性验证码，在浏览器中完成授权。

**验证认证**：
```bash
gh repo view
```
能看到项目信息即认证成功。

### 令牌认证（备选）

如果浏览器认证不可用，可使用 Personal Access Token：

1. 访问 `https://github.com/settings/tokens`
2. 创建 Token，勾选 `repo` 和 `write:org` 权限
3. 执行认证：
```bash
gh auth login --with-token < your-token-file
```

## 第 3 步：确认 GitHub Labels

脚本会根据反馈类型自动打标签（`bug`、`enhancement`、`improvement`、`question`）。如果 Label 不存在，`gh issue create` 仍会成功，但不会自动打标签。

建议在 GitHub 项目中预先创建以下 Labels（Issues → Labels → New label）：

| Label | 颜色 | 用途 |
|-------|------|------|
| `bug` | #FF0000 | Bug 报告 |
| `enhancement` | #428BCA | 功能请求 |
| `improvement` | #5CB85C | 改进建议 |
| `question` | #F0AD4E | 使用疑问 |
| `feedback` | #8B5CF6 | 默认标签 |

可通过 CLI 批量创建：

```bash
gh label create "bug" --color "FF0000" --description "Bug 报告"
gh label create "enhancement" --color "428BCA" --description "功能请求"
gh label create "improvement" --color "5CB85C" --description "改进建议"
gh label create "question" --color "F0AD4E" --description "使用疑问"
gh label create "feedback" --color "8B5CF6" --description "默认反馈标签"
```

## 第 4 步：验证完整流程

在项目目录执行 dry-run 测试：

```bash
cat <<'EOF' | bash .claude/skills/framework-feedback/scripts/submit-feedback.sh --dry-run
{
  "type": "question",
  "title": "环境配置测试（可忽略）",
  "description": "验证反馈技能环境配置",
  "project": "测试项目",
  "framework_version": "v0.0.0-test",
  "submitter": "tester"
}
EOF
```

看到 `DRY-RUN` 输出即表示环境正常。

## 降级行为

技能设计为**优雅降级**——如果 gh CLI 不可用或认证失败：

- Webhook 通知**仍正常发送**（不依赖 gh）
- 通知中会显示 "GitHub Issue 未创建（gh 不可用）" 提示
- 不影响反馈内容送达框架团队

## 自定义 Webhook（可选）

默认不发送 Webhook 通知。如需启用（如发送到项目专属通知渠道），设置环境变量：

```bash
export FEEDBACK_WEBHOOK="https://your-webhook-endpoint.example.com/notify"
```

可在 shell profile（`~/.zshrc`）中持久化。
