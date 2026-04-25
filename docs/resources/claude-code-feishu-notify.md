---
title: Claude Code 飞书通知集成指南
description: 通过飞书机器人实现任务完成的实时通知
prev: false
next:
  link: /resources/claude-code-awesome-repos
---

> 通过飞书自建应用机器人 + Claude Code Hooks，实现任务完成、等待授权、等待指令等事件的**个人私聊实时通知**。

## 效果预览

Claude Code 在后台运行时，你会在飞书收到以下类型的卡片消息：

| 卡片颜色 | 事件 | 说明 |
|---------|------|------|
| 🟢 绿色 | 任务完成 | Claude 完成一轮对话，输出最终回复摘要 |
| 🟠 橙色 | 需要授权 | Claude 需要你授权某个工具操作（如写文件、执行命令） |
| 🔵 蓝色 | 等待指令 | Claude 完成当前任务，等待你的下一步输入 |

## 架构概览

```
Claude Code（本地 CLI）
    │
    │  Hook 事件（Stop / Notification）
    │  通过 stdin 传入 JSON 数据
    ▼
feishu-notify.sh（本地脚本）
    │
    │  1. 获取 tenant_access_token（带缓存）
    │  2. 构建飞书卡片消息
    │  3. 调用飞书 API 发送
    ▼
飞书开放平台 API
    │
    │  im/v1/messages（单聊）
    ▼
你的飞书 App（私聊消息）
```

## 前置条件

- Claude Code CLI 已安装并可正常使用
- macOS / Linux 环境
- 已安装 `jq`（JSON 处理工具）：`brew install jq`
- 飞书企业账号（需要能创建应用的权限，或联系管理员审批）

---

## 第一步：创建飞书自建应用

### 1.1 创建应用

1. 打开 [飞书开放平台](https://open.feishu.cn/app)
2. 点击「创建企业自建应用」
3. 填写应用信息：
   - **应用名称**：`CC 通知助手`（或你喜欢的名称）
   - **应用描述**：`Claude Code 开发助手通知机器人，用于向开发者推送任务完成、构建部署等关键事件通知`

### 1.2 添加机器人能力

1. 进入应用详情 → 「添加应用能力」
2. 选择「机器人」

### 1.3 申请权限

进入「权限管理」，搜索并申请以下权限：

| 权限 | 说明 | 用途 |
|------|------|------|
| `im:message:send_as_bot` | 以机器人身份发送消息 | 发送通知卡片 |
| `contact:user.id:readonly` | 通过邮箱/手机号查询用户 ID | 获取你的 open_id |

### 1.4 发布应用

1. 点击「创建版本」→ 填写版本号和更新说明
2. 提交审核（需要企业管理员审批）
3. 审批通过后应用即可使用

### 1.5 记录凭证

在应用的「凭证与基础信息」页面，记录以下信息（后续脚本需要用到）：

```
App ID:     cli_xxxxxxxxxx
App Secret: xxxxxxxxxxxxxxxx
```

---

## 第二步：获取你的 open_id

飞书中每个用户对每个应用有唯一的 `open_id`。需要通过 API 查询。

### 2.1 激活单聊通道

在飞书中搜索你刚创建的机器人名称，**给它发一条消息**（内容任意）。这一步是必须的，否则机器人无法主动给你发消息。

### 2.2 通过 API 查询 open_id

将下面命令中的 `APP_ID`、`APP_SECRET`、`YOUR_EMAIL` 替换为你的实际值：

```bash
# 获取 token
TOKEN=$(curl -s -X POST 'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal' \
  -H 'Content-Type: application/json' \
  -d '{"app_id":"<APP_ID>","app_secret":"<APP_SECRET>"}' \
  | jq -r '.tenant_access_token')

# 通过邮箱查询 open_id
curl -s -X POST 'https://open.feishu.cn/open-apis/contact/v3/users/batch_get_id' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"emails":["<YOUR_EMAIL>"]}' | jq '.data.user_list'
```

输出示例：

```json
[
  {
    "email": "yourname@company.com",
    "user_id": "ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
]
```

记录 `user_id` 的值，这就是你的 `open_id`。

### 2.3 验证连通性（可选）

发一条测试消息确认一切正常：

```bash
curl -s -X POST 'https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "receive_id": "<YOUR_OPEN_ID>",
    "msg_type": "text",
    "content": "{\"text\":\"通知通道测试成功\"}"
  }' | jq '.code'
```

返回 `0` 表示成功，检查飞书是否收到消息。

---

## 第三步：部署通知脚本

### 3.1 创建脚本目录

```bash
mkdir -p ~/.claude/scripts
```

### 3.2 创建通知脚本

```bash
cat > ~/.claude/scripts/feishu-notify.sh << 'SCRIPT_EOF'
#!/bin/bash
# Claude Code 飞书通知脚本（机器人单聊版）
# 通过自建应用机器人给指定用户发送卡片消息
#
# ⚠️ 请替换以下三个变量为你的实际值
FEISHU_APP_ID="<你的 App ID>"
FEISHU_APP_SECRET="<你的 App Secret>"
FEISHU_USER_OPEN_ID="<你的 open_id>"

# Token 缓存（2 小时有效，避免每次请求）
TOKEN_CACHE="/tmp/feishu-bot-token.json"

get_token() {
    local now=$(date +%s)
    if [ -f "$TOKEN_CACHE" ]; then
        local cached_token=$(jq -r '.token' "$TOKEN_CACHE" 2>/dev/null)
        local expire_at=$(jq -r '.expire_at' "$TOKEN_CACHE" 2>/dev/null)
        if [ -n "$cached_token" ] && [ "$now" -lt "${expire_at:-0}" ]; then
            echo "$cached_token"
            return
        fi
    fi

    local resp=$(curl -s -X POST 'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal' \
        -H 'Content-Type: application/json' \
        -d "{\"app_id\":\"$FEISHU_APP_ID\",\"app_secret\":\"$FEISHU_APP_SECRET\"}")

    local token=$(echo "$resp" | jq -r '.tenant_access_token // ""')
    if [ -z "$token" ]; then
        echo ""
        return
    fi

    local expire_at=$((now + 7000))
    jq -n --arg token "$token" --arg expire_at "$expire_at" \
        '{"token":$token,"expire_at":($expire_at|tonumber)}' > "$TOKEN_CACHE"
    echo "$token"
}

send_card() {
    local token="$1"
    local card_json="$2"

    local payload=$(jq -n --arg rid "$FEISHU_USER_OPEN_ID" --arg content "$card_json" \
        '{"receive_id":$rid,"msg_type":"interactive","content":$content}')

    curl -s -X POST 'https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id' \
        -H "Authorization: Bearer $token" \
        -H 'Content-Type: application/json' \
        -d "$payload" >> /tmp/feishu-debug.log 2>&1
}

# --- 主逻辑 ---

input=$(cat)
echo "[RAW] $input" >> /tmp/feishu-debug.log

cwd=$(echo "$input" | jq -r '.cwd // "Unknown"')
last_msg=$(echo "$input" | jq -r '.last_assistant_message // ""')
hook_event=$(echo "$input" | jq -r '.hook_event_name // "Unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "Unknown"' | head -c 8)
notif_msg=$(echo "$input" | jq -r '.message // ""')

project_name=$(basename "$cwd")
current_time=$(date '+%Y-%m-%d %H:%M:%S')

# 根据事件类型构建卡片
if [ "$hook_event" = "Stop" ]; then
    msg_len=${#last_msg}
    if [ "$msg_len" -lt 50 ]; then
        exit 0
    fi
    # 清理消息：去掉 markdown 格式符号，保留可读文本
    clean_msg=$(echo "$last_msg" | sed 's/`//g; s/\*\*//g; s/\\n/\n/g')
    # 截断过长消息
    if [ ${#clean_msg} -gt 500 ]; then
        clean_msg="${clean_msg:0:500}..."
    fi

    card=$(jq -n \
        --arg proj "$project_name" \
        --arg time "$current_time" \
        --arg sid "$session_id" \
        --arg msg "$clean_msg" \
        '{
            "header": {
                "title": {"content": "✅ 任务完成", "tag": "plain_text"},
                "template": "green"
            },
            "elements": [
                {
                    "tag": "markdown",
                    "content": ("**项目** " + $proj + "　　**Session** " + $sid + "\n**时间** " + $time)
                },
                {"tag": "hr"},
                {
                    "tag": "markdown",
                    "content": $msg
                }
            ]
        }')

elif [ "$hook_event" = "Notification" ]; then
    notif_type=$(echo "$input" | jq -r '.notification_type // ""' 2>/dev/null)

    if [ "$notif_type" = "permission_prompt" ]; then
        tool_name=$(echo "$notif_msg" | sed -n 's/.*permission to use \(.*\)/\1/p')
        title="🔐 需要授权"
        body="需要授权使用工具：**${tool_name:-未知}**"
        color="orange"
    elif [ "$notif_type" = "idle_prompt" ]; then
        title="💬 等待指令"
        body="Claude Code 等待你的输入"
        color="blue"
    else
        title="📢 通知"
        body="$notif_msg"
        color="blue"
    fi

    card=$(jq -n \
        --arg title "$title" \
        --arg color "$color" \
        --arg proj "$project_name" \
        --arg time "$current_time" \
        --arg body "$body" \
        '{
            "header": {
                "title": {"content": $title, "tag": "plain_text"},
                "template": $color
            },
            "elements": [
                {
                    "tag": "markdown",
                    "content": ($body + "\n\n**项目** " + $proj + "　　**时间** " + $time)
                }
            ]
        }')
else
    card=$(jq -n \
        --arg event "$hook_event" \
        --arg proj "$project_name" \
        --arg time "$current_time" \
        '{
            "header": {
                "title": {"content": ("📢 " + $event), "tag": "plain_text"},
                "template": "blue"
            },
            "elements": [
                {
                    "tag": "markdown",
                    "content": ("**项目** " + $proj + "　　**时间** " + $time)
                }
            ]
        }')
fi

# 获取 token 并发送
token=$(get_token)
if [ -z "$token" ]; then
    echo "[$current_time] ERROR: failed to get token" >> /tmp/feishu-debug.log
    exit 1
fi

send_card "$token" "$card"
echo "[$current_time] hook=$hook_event project=$project_name" >> /tmp/feishu-debug.log
SCRIPT_EOF

chmod +x ~/.claude/scripts/feishu-notify.sh
```

### 3.3 替换配置

编辑 `~/.claude/scripts/feishu-notify.sh`，将文件顶部三个变量替换为你的实际值：

```bash
FEISHU_APP_ID="cli_xxxxxxxxxx"        # 第一步记录的 App ID
FEISHU_APP_SECRET="xxxxxxxxxxxxxxxx"   # 第一步记录的 App Secret
FEISHU_USER_OPEN_ID="ou_xxxxxxxx..."   # 第二步获取的 open_id
```

---

## 第四步：配置 Claude Code Hooks

编辑 `~/.claude/settings.json`，在顶层添加 `hooks` 配置：

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/feishu-notify.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/feishu-notify.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/feishu-notify.sh"
          }
        ]
      }
    ]
  }
}
```

> 如果你已有 `settings.json`，只需将 `hooks` 字段合并进去，不要覆盖其他配置。

### Hook 事件说明

| 事件 | 触发时机 | 说明 |
|------|---------|------|
| `Stop` | Claude 完成一轮对话 | 脚本会过滤过短的回复（< 50 字符），避免琐碎通知 |
| `Notification` + `permission_prompt` | Claude 需要用户授权工具操作 | 如执行命令、写文件等需要确认的操作 |
| `Notification` + `idle_prompt` | Claude 等待用户输入 | 任务完成后等待下一步指令 |

---

## 第五步：验证

1. 重启 Claude Code（退出后重新打开，或新开一个终端窗口）
2. 随便问一个问题，等 Claude 回复完成
3. 检查飞书是否收到绿色「任务完成」卡片通知

如果没有收到，检查调试日志：

```bash
tail -20 /tmp/feishu-debug.log
```

---

## 常见问题

### Q: 收到 `open_id cross app` 错误

每个飞书应用对同一用户有不同的 `open_id`。你需要用**当前这个应用**查出来的 `open_id`，不能复用其他应用的。参考第二步重新查询。

### Q: 收到 `Access denied` 权限错误

应用权限未申请或未审批。去开发者后台检查 `im:message:send_as_bot` 和 `contact:user.id:readonly` 是否已通过审批。

### Q: 机器人发不了消息（code 非 0）

确认你已在飞书中**给机器人发过一条消息**，激活单聊通道。机器人无法主动给从未交互过的用户发消息。

### Q: Token 过期报错

脚本已内置 Token 缓存机制（2 小时），正常情况会自动刷新。如果持续报错，手动清除缓存：

```bash
rm /tmp/feishu-bot-token.json
```

### Q: 通知太频繁怎么办

- **Stop 事件**：脚本已过滤短回复（< 50 字符），可调整阈值
- **减少事件**：从 `settings.json` 的 `hooks` 中移除不需要的事件（比如去掉 `idle_prompt`）
- **只保留任务完成通知**：删掉整个 `Notification` 配置块，只留 `Stop`

### Q: 想通知多个人怎么办

修改脚本，将 `FEISHU_USER_OPEN_ID` 改为数组，循环发送：

```bash
FEISHU_USER_OPEN_IDS=("ou_aaa..." "ou_bbb..." "ou_ccc...")

for uid in "${FEISHU_USER_OPEN_IDS[@]}"; do
    FEISHU_USER_OPEN_ID="$uid" send_card "$token" "$card"
done
```

注意：每个接收人都需要先给机器人发过消息。

---

## 安全提醒

- `App Secret` 是敏感凭证，**不要提交到 Git 仓库**
- `~/.claude/scripts/feishu-notify.sh` 包含凭证，确保文件权限为 `600`：
  ```bash
  chmod 600 ~/.claude/scripts/feishu-notify.sh
  ```
- 如果团队共享同一个应用，每个人只需替换自己的 `open_id`，`App ID` 和 `App Secret` 可以相同
- 调试日志 `/tmp/feishu-debug.log` 包含原始消息，定期清理
