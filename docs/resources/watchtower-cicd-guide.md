---
title: CI/CD 自动化部署指南
description: 基于 Watchtower + Docker 的自动化部署方案，支持飞书群机器人实时通知
prev: false
next: false
---

# CI/CD 自动化部署：Watchtower + 飞书通知

基于 Docker + Watchtower 的轻量级自动化部署方案，代码合并后无需人工登录服务器，镜像自动拉取部署，并通过飞书群机器人推送通知。

## 设计目标

- 代码合并到 `develop` 分支后，**无需人工登录服务器**，镜像自动拉取并部署
- 部署完成后向飞书群机器人推送通知
- 前端静态文件更新后自动重载 Nginx，使新内容立即生效

---

## 整体架构

```
开发机
  └─ build_push.sh
       ├─ mvn / npm run generate   构建产物
       ├─ docker build             打镜像
       └─ docker push → Harbor     推送 develop tag
                                       │
                                       │ （每 60s 轮询）
                                       ▼
服务器
  ┌─────────────────────────────────────────────────────┐
  │  Watchtower                                          │
  │  检测 Harbor 上 develop tag 镜像变化                   │
  │  → stop / rm / pull / up 对应容器                     │
  │  → HTTP POST → 127.0.0.1:9388/notify                │
  └──────────────────┬──────────────────────────────────┘
                     │                         │
                     ▼                         ▼
          watchtower-notifier           nginx-reloader
          解析 payload                  监听 Docker start 事件
          → notify-feishu.py           → docker restart <nginx-container>
          → 飞书群机器人卡片通知
```

---

## 组件说明

### Watchtower

**轮询间隔**：60 秒（可通过环境变量调整）

关键行为：
- 发现 `develop` tag 镜像 digest 变化 → 原地更新容器（stop → rm → pull → up）
- 更新完成后通过 **shoutrrr generic+http** 协议向 `127.0.0.1:9388/notify` 推送通知
- `WATCHTOWER_CLEANUP=true`：自动清理旧镜像，防止磁盘堆积

使用 `network_mode: host`，与 `watchtower-notifier` 共享宿主机网络，通过 `127.0.0.1` 直通。

---

### watchtower-notifier（HTTP 中转服务）

**监听端口**：`9388`（宿主机，`network_mode: host`）

职责：HTTP 中转服务，接收 Watchtower 通知并异步转发。

```
POST /notify
  → 解析 JSON payload（shoutrrr generic 格式）
  → 立即回包 200（避免 Watchtower 等待超时）
  → 异步调用 notify-feishu.py
```

处理两种 payload 格式：
- **shoutrrr generic 格式**（当前）：`{"title": "...", "message": "..."}`，从 message 中用正则提取容器名
- **Docker 事件格式**（兼容旧版）：`{"Action": "start/stop/update", "Name": "...", "ImageName": "..."}`

---

### notify-feishu.py（飞书通知脚本）

**职责**：构造飞书交互卡片并推送。

卡片内容：
- Header：部署通知标题 + 颜色（成功=绿色）
- 更新的容器名列表
- 触发时间
- 原始 message 详情（折叠）

---

### nginx-reloader

**镜像**：`docker:cli`
**挂载**：`/var/run/docker.sock`

职责：监听 Docker 事件，在前端容器重启后自动 `docker restart <nginx-container>`。

```
docker events
  --filter event=start
  --filter name=<frontend-container-1>
  --filter name=<frontend-container-2>
| while read cname; do
    docker restart <nginx-container>;
  done
```

**存在原因**：前端容器只提供静态文件，Nginx 作为统一入口通过 volume 或 proxy 提供服务。Watchtower 只重启前端容器本身，Nginx 进程不感知文件变化，需要显式 restart 才能加载新内容。

`nginx-reloader` 与 Watchtower 完全解耦，即使 Watchtower 替换为其他工具，此机制依然有效。

---

## 部署步骤

### 前置条件

- 服务器已安装 Docker & Docker Compose
- Harbor 镜像仓库已配置，开发机已登录
- 飞书群机器人 Webhook URL 已获取

### Docker Compose 配置

以下为基础设施服务的编排配置。**业务容器需自行添加**，并设置 `com.centurylinklabs.watchtower.enable=true` label 以启用 Watchtower 监控。

```yaml
version: "3.1"
services:

  # ── Nginx 自动重载（前端容器更新后触发）────────────────────────────
  # 监听 Docker start 事件，指定前端容器重启后自动 restart nginx
  nginx-reloader:
    image: docker:cli
    container_name: nginx-reloader
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: >
      sh -c "docker events
        --filter event=start
        --filter name=<frontend-container-1>
        --filter name=<frontend-container-2>
        --format '{{.Actor.Attributes.name}}'
      | while read cname; do
          echo \"[nginx-reloader] \$$cname restarted, reloading nginx...\";
          docker restart <nginx-container>;
        done"
    network_mode: host

  # ── 飞书通知中转服务 ──────────────────────────────────────────────
  # 监听 9388 端口，接收 Watchtower 的 HTTP 通知，转发到飞书群机器人
  watchtower-notifier:
    image: python:3.11-slim
    container_name: watchtower-notifier
    command: python /opt/watchtower/watchtower-http.py
    volumes:
      - /opt/watchtower/watchtower-http.py:/opt/watchtower/watchtower-http.py:ro
      - /opt/watchtower/notify-feishu.py:/opt/watchtower/notify-feishu.py:ro
    environment:
      - TZ=Asia/Shanghai
      - FEISHU_WEBHOOK_URL=<你的飞书 Webhook URL>
      - NOTIFY_SCRIPT=/opt/watchtower/notify-feishu.py
    network_mode: host
    restart: unless-stopped

  # ── Watchtower 自动更新 + 部署通知 ───────────────────────────────
  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /root/.docker/config.json:/config.json:ro
    environment:
      - WATCHTOWER_POLL_INTERVAL=60
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_INCLUDE_STOPPED=false
      - WATCHTOWER_NO_PULL=false
      # 容器更新后通过 shoutrrr generic 协议推送到本机中转服务
      - WATCHTOWER_NOTIFICATION_URL=generic+http://127.0.0.1:9388/notify
      - TZ=Asia/Shanghai
    # 指定要监控的容器名（空格分隔）
    command: <backend-service> <frontend-service-1> <frontend-service-2>
    network_mode: host
```

> **替换说明**：
> - `<frontend-container-1/2>` → 你的前端容器名
> - `<nginx-container>` → 你的 Nginx 容器名
> - `<backend-service>` → 你的后端容器名
> - `<你的飞书 Webhook URL>` → 飞书群机器人的 Webhook 地址
> - 如使用私有 Harbor，将 `containrrr/watchtower:latest` 替换为你的镜像

### 启动服务

```bash
# 1. 将 watchtower-http.py 和 notify-feishu.py 放到服务器 /opt/watchtower/
# 2. 修改 docker-compose.yaml 中的占位符
# 3. 启动基础设施服务
docker-compose up -d

# 4. 验证容器运行
docker-compose ps
```

---

## 完整数据流

```
1. 开发机执行 build_push.sh
   → Docker 镜像 build → push 到 Harbor（develop tag）

2. Watchtower 轮询（~60s）发现 digest 变化
   → stop 旧容器 → pull 新镜像 → start 新容器

3a. [后端] 容器 start 事件被 Docker Engine 记录
    → nginx-reloader 仅监听前端容器，跳过后端

3b. [前端] 容器 start 事件触发 nginx-reloader
    → docker restart <nginx-container>
    → Nginx 重载，新静态文件立即生效

4. Watchtower 更新完成
   → HTTP POST 127.0.0.1:9388/notify（shoutrrr generic）

5. watchtower-notifier 收到请求
   → 立即回包 200
   → 调用 notify-feishu.py

6. notify-feishu.py
   → 构造飞书卡片（容器名 + 时间 + 详情）
   → POST 飞书 Webhook
   → 飞书群收到部署通知
```

---

## 脚本源码

### watchtower-http.py

HTTP 中转服务，接收 Watchtower 通知并转发给飞书通知脚本：

<details>
<summary>查看源码</summary>

```python
#!/usr/bin/env python3
"""Watchtower HTTP 通知中转服务
监听 9388 端口，接收 Watchtower shoutrrr generic 通知，转发给 notify-feishu.py
"""

import json
import logging
import os
import subprocess
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = int(os.environ.get("NOTIFIER_PORT", 9388))
SCRIPT = os.environ.get("NOTIFY_SCRIPT", "/opt/watchtower/notify-feishu.py")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger("watchtower-notifier")


def call_script(payload: dict):
    try:
        proc = subprocess.run(
            [sys.executable, SCRIPT],
            input=json.dumps(payload),
            capture_output=True,
            text=True,
            timeout=30
        )
        if proc.stdout:
            logger.info(proc.stdout.strip())
        if proc.stderr:
            logger.error(proc.stderr.strip())
    except Exception as e:
        logger.error(f"调用脚本失败: {e}")


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/notify":
            self.send_error(404)
            return

        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8")

        try:
            payload = json.loads(body)
        except json.JSONDecodeError:
            # shoutrrr generic+http 默认发送纯文本，包装成统一格式
            payload = {"message": body.strip(), "title": "Watchtower 部署通知"}

        logger.info(f"收到通知: {payload.get('title') or payload.get('Action', 'unknown')}")

        # 先回包，避免 Watchtower 因等待响应超时；再同步执行脚本
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"ok": true}')

        call_script(payload)

    def log_message(self, fmt, *args):
        pass  # 使用自定义 logger


def main():
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    logger.info(f"中转服务已启动: http://0.0.0.0:{PORT}/notify")
    logger.info(f"通知脚本路径: {SCRIPT}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("中转服务已停止")
        server.shutdown()


if __name__ == "__main__":
    main()
```

</details>

### notify-feishu.py

飞书通知构造与发送脚本。Webhook URL 通过环境变量 `FEISHU_WEBHOOK_URL` 传入：

<details>
<summary>查看源码</summary>

```python
#!/usr/bin/env python3
"""Watchtower → 飞书通知"""

import json
import os
import re
import sys
import urllib.request
from datetime import datetime

FEISHU_WEBHOOK = os.environ.get("FEISHU_WEBHOOK_URL", "")


def build_card(title: str, color: str, fields: list) -> dict:
    return {
        "msg_type": "interactive",
        "card": {
            "header": {
                "title": {"tag": "plain_text", "content": title},
                "template": color
            },
            "elements": [{"tag": "div", "fields": fields}]
        }
    }


def parse_shoutrrr_message(data: dict) -> dict:
    """解析 Watchtower shoutrrr generic 格式：{"title": "...", "message": "..."}"""
    message = data.get("message", "")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # 从 message 中提取容器名
    containers = []
    for line in message.strip().splitlines():
        # 匹配 "Creating /container-name" 行
        match = re.match(r"Creating\s+/?(\S+)", line.strip())
        if match:
            containers.append(match.group(1).lstrip("/"))

    container_str = "\n".join(containers) if containers else "（见详情）"

    fields = [
        {"is_short": True,  "text": {"tag": "lark_md", "content": f"**更新容器**\n{container_str}"}},
        {"is_short": True,  "text": {"tag": "lark_md", "content": f"**时间**\n{timestamp}"}},
        {"is_short": False, "text": {"tag": "lark_md", "content": f"**详情**\n```\n{message}\n```"}},
    ]
    return build_card("🚀 部署通知 — 容器已更新", "green", fields)


def parse_docker_event(data: dict) -> dict:
    """解析 Docker 事件格式（旧版兼容）"""
    action = data.get("Action", "")
    container_name = data.get("Name", "unknown")
    image = data.get("ImageName", "")
    image_short = image.split("/")[-1] if "/" in image else image
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if action == "start":
        title, color = "✅ 部署通知 — 容器启动", "green"
    elif action == "stop":
        title, color = "⏸ 部署通知 — 容器停止", "yellow"
    elif action == "update":
        title, color = "🚀 部署通知 — 镜像更新", "green"
    else:
        title, color = "🔔 部署通知", "blue"

    fields = [
        {"is_short": True, "text": {"tag": "lark_md", "content": f"**容器**\n{container_name}"}},
        {"is_short": True, "text": {"tag": "lark_md", "content": f"**镜像**\n{image_short}"}},
        {"is_short": True, "text": {"tag": "lark_md", "content": f"**时间**\n{timestamp}"}},
        {"is_short": True, "text": {"tag": "lark_md", "content": f"**事件**\n{action}"}},
    ]
    return build_card(title, color, fields)


def send_feishu(payload: dict):
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        FEISHU_WEBHOOK,
        data=data,
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main():
    if not FEISHU_WEBHOOK:
        print("[错误] 未设置 FEISHU_WEBHOOK_URL 环境变量", file=sys.stderr)
        sys.exit(1)

    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    # 自动识别格式：shoutrrr generic 格式含 "message" 字段
    if "message" in data:
        msg = parse_shoutrrr_message(data)
    else:
        action = data.get("Action", "")
        if action not in ("start", "stop", "update"):
            sys.exit(0)
        msg = parse_docker_event(data)

    result = send_feishu(msg)
    if result.get("code") == 0 or result.get("StatusCode") == 0:
        print("[通知] 发送成功")
    else:
        print(f"[通知] 发送失败: {result}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
```

</details>

---

## 运维速查

### 查看各组件日志

```bash
docker logs -f watchtower           # Watchtower 拉取 / 更新记录
docker logs -f watchtower-notifier  # HTTP 中转 + 飞书通知日志
docker logs -f nginx-reloader       # Nginx 重载触发记录
```

### 手动触发部署（测试用）

```bash
# 重新 push 同一镜像，触发 Watchtower 更新
docker pull <image>:<tag>
docker tag <image>:<tag> <your-registry>/<name>:develop
docker push <your-registry>/<name>:develop
```

### 重启各组件

```bash
docker restart watchtower-notifier
docker restart nginx-reloader
```

### 确认 Nginx 是否完成重载

```bash
docker logs nginx-reloader | tail -20
docker exec <nginx-container> nginx -t    # 验证配置语法
```

### 热更新脚本

`watchtower-http.py` 和 `notify-feishu.py` 在容器中以只读 volume 挂载，修改脚本后执行 `docker restart watchtower-notifier` 即可生效，**无需重建镜像**。

---

## 已知限制与注意事项

| 限制 | 说明 |
|------|------|
| 多前端同时更新 | nginx-reloader 会触发多次 restart，Nginx 短暂重启多次，无害但有轻微抖动 |
| Nginx 容器名强依赖 | Nginx 容器名硬编码在 nginx-reloader 命令中，改名需同步更新 |
| 非即时部署 | `build_push.sh` push 完即返回，实际服务重启需等待 Watchtower 下一轮轮询（最长 60s） |
| Harbor 认证 | Watchtower 需要 Harbor 的 Docker 登录凭据（`/root/.docker/config.json`） |

---

## 参考

- [Watchtower 官方文档](https://containrrr.dev/watchtower/)
- [飞书 Bot 文档](https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot)
