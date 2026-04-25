---
title: lark-cli 安装与使用指南
description: 飞书 CLI 工具安装、配置与 Claude Code 集成指南
prev: false
next: false
---

# lark-cli 安装与使用指南

> lark-cli 是一个面向 AI 助手（Claude Code 等）设计的飞书 CLI 工具，返回紧凑 JSON / Markdown，token 消耗远低于官方 MCP Server。
>
> 仓库地址：https://github.com/yjwong/lark-cli

---

## 一、前置条件

| 依赖 | 最低版本 | 检查命令 |
|------|---------|---------|
| Go | 1.21+ | `go version` |
| 飞书企业自建应用 | — | [飞书开放平台](https://open.feishu.cn) 创建 |

---

## 二、安装

### 2.1 推荐方式：go install

```bash
# 国内环境使用 goproxy.cn 加速
GOPROXY=https://goproxy.cn,direct go install github.com/yjwong/lark-cli/cmd/lark@latest
```

安装后二进制在 `~/go/bin/lark`。

> **踩坑记录**：
> - `go install github.com/yjwong/lark-cli@latest` 会报 `does not contain package` 错误，因为 main 包在 `cmd/lark` 子目录，必须指定完整路径 `github.com/yjwong/lark-cli/cmd/lark@latest`。
> - 编译包含 sqlite CGO 依赖（modernc.org/sqlite），首次编译耗时较长（2-3 分钟），请耐心等待。

### 2.2 备选方式：源码编译

```bash
git clone https://github.com/yjwong/lark-cli.git
cd lark-cli
make build    # 产出 ./lark
make install  # 安装到 $GOPATH/bin
```

> **踩坑记录**：国内网络环境下 `git clone` GitHub 仓库可能失败（Connection reset / Proxy CONNECT aborted），建议优先用 `go install` + goproxy.cn。

### 2.3 配置 PATH

将 Go bin 目录加入 PATH（写入 `~/.zshrc`）：

```bash
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

验证：

```bash
lark --help
```

---

## 三、飞书应用配置

### 3.1 创建应用

1. 登录 [飞书开放平台](https://open.feishu.cn)
2. 创建**企业自建应用**，记录 App ID 和 App Secret

### 3.2 配置重定向 URL

**应用管理 → 安全设置 → 重定向 URL**，添加：

```
http://localhost:9999/callback
```

> **踩坑记录**：不配置此项会报错 `错误码：20029 重定向 URL 有误`。lark-cli 登录时会在本地 9999 端口启动回调服务，必须预先注册。

### 3.3 开通权限

**应用管理 → 权限管理**，按需开通以下权限：

#### 文档类（必选）

| 权限标识 | 说明 |
|---------|------|
| `docs:doc:readonly` | 查看、评论和导出文档 |
| `docs:document.content:read` | 查看云文档内容 |
| `docx:document` | 创建及编辑新版文档 |
| `docx:document:readonly` | 查看新版文档 |
| `drive:drive:readonly` | 查看、评论和下载云空间中所有文件 |
| `wiki:wiki:readonly` | 查看知识库 |
| `space:document:retrieve` | 搜索云文档 |

#### 其他（按需）

| 权限标识 | 说明 |
|---------|------|
| `calendar:calendar:readonly` | 查看日历 |
| `contact:user:search` | 搜索用户 |
| `im:message:readonly` | 读取消息 |

> **踩坑记录**：权限添加后需要**创建应用版本并发布**（或管理员审批），否则授权时会报 `错误码：20027 当前应用权限不足`。

### 3.4 发布应用

**应用管理 → 版本管理与发布** → 创建版本 → 申请发布 → 管理员审批通过

---

## 四、本地认证配置

### 4.1 创建配置文件

```bash
mkdir -p ~/.lark

cat > ~/.lark/config.yaml << 'EOF'
app_id: "你的App ID"
region: "feishu"
EOF
```

### 4.2 设置环境变量

写入 `~/.zshrc`：

```bash
cat >> ~/.zshrc << 'EOF'

# lark-cli (飞书 CLI)
export LARK_CONFIG_DIR="$HOME/.lark"
export LARK_APP_SECRET="你的App Secret"
export PATH="$HOME/go/bin:$PATH"
EOF

source ~/.zshrc
```

> **注意**：`LARK_CONFIG_DIR` 是必须的环境变量，不设置会报 `CONFIG_ERROR: LARK_CONFIG_DIR environment variable is not set`。

### 4.3 登录认证

```bash
# 全部权限
lark auth login

# 仅文档权限（推荐最小化）
lark auth login --scopes documents
```

> **踩坑记录（重要）**：lark-cli 存在一个 bug——即使 `config.yaml` 中 `region` 设为 `feishu`，OAuth 授权 URL 仍然生成国际版域名 `accounts.larksuite.com`，国内飞书用户无法访问。
>
> **解决方法**：手动将终端输出的 URL 中的域名替换：
> ```
> # 原始（无法访问）
> https://accounts.larksuite.com/open-apis/authen/v1/authorize?...
>
> # 替换为（可访问）
> https://accounts.feishu.cn/open-apis/authen/v1/authorize?...
> ```
> 其余参数保持不变，在浏览器中打开替换后的链接完成授权。

### 4.4 检查认证状态

```bash
lark auth status
```

成功输出示例：

```json
{
  "authenticated": true,
  "expires_at": "2026-04-20T18:36:10+08:00",
  "granted_groups": ["documents"],
  "scope_groups": {
    "documents": true,
    "calendar": false,
    "contacts": false,
    "messages": false
  }
}
```

---

## 五、使用指南

### 5.1 读取云文档

```bash
# 直接用文档 token
lark doc get <docToken>
```

文档 token 从 URL 中提取：`https://xxx.feishu.cn/docx/EtV6div2joCdadxviPQc4K3tnwf` → token 为 `EtV6div2joCdadxviPQc4K3tnwf`

### 5.2 读取知识库文档

知识库链接需要先解析 wiki node，再获取内容：

```bash
# 第一步：解析 wiki node 获取 obj_token
lark doc wiki <nodeToken>
# 返回 { "obj_token": "EtV6div2joCdadxviPQc4K3tnwf", "obj_type": "docx", ... }

# 第二步：用 obj_token 读取内容
lark doc get <obj_token>
```

Wiki URL 示例：`https://xxx.feishu.cn/wiki/FxpAwDPLgi5b6IkcoTxcPmawnVd` → nodeToken 为 `FxpAwDPLgi5b6IkcoTxcPmawnVd`

### 5.3 其他文档操作

```bash
# 列出文件夹内容
lark doc list <folderToken>

# 搜索文档
lark doc search "关键词"

# 搜索知识库
lark doc wiki-search "关键词"

# 列出知识库子节点
lark doc wiki-children <spaceId> <nodeToken>

# 查看文档评论
lark doc comments <docToken>

# 查看文档块结构（原始 block 数据）
lark doc blocks <docToken>
```

### 5.4 日历（需 calendar 权限）

```bash
lark cal list --week       # 本周日程
lark cal list --today      # 今日日程
```

### 5.5 联系人（需 contacts 权限）

```bash
lark contacts search "张三"
```

### 5.6 消息（需 messages 权限）

```bash
lark msg list <chatId>     # 获取聊天记录
```

---

## 六、与 Claude Code 集成

lark-cli 通过 **Bash 工具** 在 Claude Code 中直接调用，无需 MCP 配置。

在对话中直接请求即可：
- "帮我读一下这个飞书文档 https://xxx.feishu.cn/docx/xxx"
- "搜索飞书知识库里关于 Agent 的文档"

Claude Code 会自动调用 `lark doc wiki` + `lark doc get` 完成解析和读取。

### 可选：安装 Skills

lark-cli 仓库提供了预置的 Claude Code Skills（`skills/` 目录），可复制到项目中使用：

```bash
# 如果已 clone 源码
cp -r /path/to/lark-cli/skills/* .claude/skills/
```

---

## 七、常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| `command not found: lark` | `~/go/bin` 不在 PATH | `export PATH="$HOME/go/bin:$PATH"` 加入 `~/.zshrc` 后 `source ~/.zshrc` |
| `CONFIG_ERROR: LARK_CONFIG_DIR not set` | 未设置环境变量 | `export LARK_CONFIG_DIR="$HOME/.lark"` |
| `错误码 20029: 重定向 URL 有误` | 飞书应用未配置回调地址 | 应用安全设置中添加 `http://localhost:9999/callback` |
| `错误码 20027: 权限不足` | 应用未开通或未发布对应权限 | 开通权限 + 发布应用版本 |
| OAuth URL 打不开（larksuite.com） | lark-cli feishu region 的 bug | 手动替换域名为 `accounts.feishu.cn` |
| `does not contain package` | go install 路径不对 | 用 `github.com/yjwong/lark-cli/cmd/lark@latest` |
| Token 过期 | 约 2 小时有效期 | 重新执行 `lark auth login` |

---

## 八、安全注意事项

- App Secret 不要硬编码在代码仓库中，通过环境变量注入
- `.lark/` 目录包含认证 token，已被 `.gitignore` 排除（如未排除需手动添加）
- 建议定期在飞书开放平台重置 App Secret
