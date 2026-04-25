---
title: Claude Code Hooks 精华整理
description: Hooks 机制：安全与质量控制的中间件体系
prev: false
next:
  link: /resources/claude-code-rules
---

> 来源：极客时间《Claude Code 工程化实战》第 15 讲（防微杜渐）+ 第 16 讲（未雨绸缪）
> 作者：黄佳

---

## 一、Hooks 本质——AI 时代的中间件

```
用户请求 → Claude 决策 → [PreToolUse Hook] → 工具执行 → [PostToolUse Hook] → 响应
    ↓                                       ↓
权限检查、拦截                          格式化、验证、日志
```

**核心类比：** Web 中间件解决"业务代码不该操心安全和日志"；Hooks 解决"Claude 不该操心格式化和权限检查"。

- **Commands** = 下达任务指令（"做什么"）
- **Skills** = 掌握领域知识（"怎么做"）
- **Hooks** = 安全制度和质量规范（"不许做/必须做"）

> **三者对比：** Commands 和 Skills 告诉 Claude"怎么做"，Hooks 是唯一能拦截和修改 Claude 行为的机制——是工程化实践中安全防线的最后一道闸门。

---

## 二、17 种 Hook 事件体系

按**能否阻止**分类：

### 控制点（能阻止）
| 事件 | 时机 | 能力 |
|------|------|------|
| `PreToolUse` | 工具执行前 | 允许 / 拒绝 / 修改参数 |
| `UserPromptSubmit` | 用户输入提交前 | 拒绝不合理的输入 |
| `Stop` | Claude 响应完成前 | 阻止停止，强制继续 |
| `SubagentStop` | 子代理完成前 | 同上 |

### 接管点（替代默认行为）
| 事件 | 时机 | 能力 |
|------|------|------|
| `PermissionRequest` | 权限弹窗时 | 自动批准或拒绝权限请求 |

### 观察点（只能记录）
| 事件 | 时机 |
|------|------|
| `SessionStart` | 会话启动 |
| `PostToolUse` | 工具执行后 |
| `PostToolUseFailure` | 工具执行失败 |
| `Notification` | 通知事件 |
| `SubagentStart` | 子代理启动 |
| `PreCompact` | 压缩前 |
| `SessionEnd` | 会话结束 |

> **设计哲学：** 工具执行前可以拦截（操作未发生）；工具执行后不能拦截（操作已完成）。不对称设计是有意为之。

---

## 三、四种 Hook 类型

选择原则：**能 command 不 prompt，能 prompt 不 agent，需要远程用 http。**

| 类型 | 场景 | 特点 |
|------|------|------|
| `command` | 确定性规则（模式匹配、命令检查） | 最可靠，无随机性 |
| `prompt` | 需要 LLM 判断力（代码安全性评估） | 快，但只能"看一眼" |
| `agent` | 需要翻代码确认（完整验证） | 最强也最慢 |
| `http` | 对接外部审计服务 / 集中式安全平台 | POST 事件到远程端点 |

---

## 四、配置位置

| 位置 | 作用域 | 适用场景 |
|------|--------|----------|
| `~/.claude/settings.json` | 用户级 | 个人习惯（日志格式、桌面通知） |
| `.claude/settings.json` | 项目级 | 团队约定（格式化规则、敏感文件保护） |
| `.claude/settings.local.json` | 本地覆盖 | 临时覆盖团队配置（如调试时关闭某个 Hook） |
| **子代理 frontmatter** | 子代理专属 | 只在该子代理执行期间生效 |

**frontmatter vs 全局选择流程：**
```
这个 Hook 是否只与特定子代理相关？
├── 是 → frontmatter Hooks（例：db-reader 的 SQL 注入检查）
└── 否 → 全局 settings.json（例：所有 Write 后的格式化）

这个 Hook 是否需要随子代理定义一起分发？
├── 是 → frontmatter Hooks（开源项目的子代理）
└── 否 → 全局 settings.json
```

---

## 五、配置结构详解

```jsonc
{
  "hooks": {
    "PreToolUse": [                    // 第一层：事件（什么时候触发）
      {
        "matcher": "Bash",              // 第二层：匹配器（针对哪个工具）
        "hooks": [                     // 第三层：Hook 列表（执行什么）
          {
            "type": "command",
            "command": "./hooks/block-dangerous.sh",
            "timeout": 30000,
            "async": false              // 可选：异步不阻塞
          }
        ]
      }
    ]
  }
}
```

**matcher 模式：**
```jsonc
"matcher": "Write"           // 精确匹配
"matcher": "Edit|Write|MultiEdit"  // 多工具
"matcher": "*"               // 所有工具（慎用）
"matcher": ""                // 空匹配（用于生命周期事件）
```

---

## 六、核心事件详解

### 6.1 PreToolUse——入口安检

**三种决策响应：**

```jsonc
// 允许
{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "allow" } }

// 拒绝（exit 2 = 有意阻止，exit 1 = 脚本出错不阻止）
{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "危险命令" } }

// 交给用户确认
{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": "需要人类判断" } }

// 修改参数后执行
{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "allow", "updatedInput": { "command": "rm -rf /tmp/test --dry-run" } } }
```

**退出码协议：**
- `exit 0` = 允许执行（默认允许）
- `exit 2` = 阻止执行
- 其他非零 = 脚本出错，但不阻止（安全检查脚本未安装 → 不应阻碍正常命令）

**实战案例 1：阻止危险命令** `block-dangerous.sh`
```bash
#!/bin/bash
set -e
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

DANGEROUS_PATTERNS=(
  "rm -rf /" "rm -rf ~" "rm -rf \$HOME"
  "git push --force origin main" "git push --force origin master"
  "DROP DATABASE" "DROP TABLE" "TRUNCATE"
  "curl.*| sh" "curl.*| bash" "wget.*| sh" "wget.*| bash"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked: $pattern"
  }
}
EOF
    exit 2
  fi
done
echo '{}'
exit 0
```

**实战案例 2：保护敏感文件** `protect-files.sh`
```bash
PROTECTED_PATTERNS=(
  ".env" ".env.*" "credentials.json" "secrets.yaml" "secrets.yml"
  "*.pem" "*.key" "id_rsa" "id_ed25519" ".ssh/config" "kubeconfig"
)
# 匹配 Write|Edit 工具，检查 tool_input.file_path
```

**关键坑：调试输出必须到 stderr**
```bash
echo "DEBUG: ..." >&2   # ✓ 正确
echo "DEBUG: ..."       # ✗ 错误——污染 stdout 导致 JSON 解析失败
```

---

### 6.2 PostToolUse——过程质检

**特有字段：** 包含 `tool_response`（执行结果）+ `additionalContext`（注入上下文）

```jsonc
// 向 Claude 反馈信息（Claude 会看到并据此调整行为）
{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": "ESLint found 3 errors." } }
```

**实战案例 1：自动格式化** `auto-format.sh`
- 根据文件扩展名自动选择工具：Prettier（JS/TS）→ Black（Python）→ gofmt（Go）→ rustfmt（Rust）
- 优雅降级：工具不存在时跳过而非报错
- 通过 `additionalContext` 告诉 Claude 已自动格式化

**实战案例 2：自动 Lint 检查** `lint-check.sh`
- `|| true` 防止 ESLint 非零退出码导致脚本中断
- `head -30` 截断输出，只传递最关键信息（高噪声处理）

**实战案例 3：审计日志** `audit-log.sh`
```bash
LOG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/audit.log"
echo "[$(date -Iseconds)] $TOOL_NAME: $(echo "$INPUT" | jq -c '.tool_input // {}')" >> "$LOG_FILE"
echo '{}'
exit 0
```

---

### 6.3 Stop Hook——出厂验收

**核心能力：** `continue: true` 让 Claude 继续工作，不是"做完了再检查"，而是"检查通过了才算做完"。

```jsonc
// 测试通过
{ "decision": "approve", "reason": "All tests passed." }

// 测试失败 → 强制继续
{ "decision": "block", "reason": "Tests are failing. Please fix.", "continue": true, "systemMessage": "..." }
```

**防止死循环：** 检查 `stop_hook_active` 字段
```bash
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # 已经重试过，这次让 Claude 停下来
fi
```

**项目类型自动检测：**
```bash
[ -f "package.json" ]     && npm test
[ -f "pyproject.toml" ]   && pytest
[ -f "go.mod" ]           && go test ./...
[ -f "Cargo.toml" ]       && cargo test
```

---

### 6.4 SubagentStart / SubagentStop

**SubagentStart：** 为子代理注入上下文（不能阻止启动）
```jsonc
{ "hookSpecificOutput": { "hookEventName": "SubagentStart", "additionalContext": "当前分支是 feature/payment-refactor，请关注支付相关变更" } }
```
→ 每次 code-reviewer 启动时自动收到团队编码规范，不占用子代理上下文空间

**SubagentStop：** 验证子代理工作质量
- 独有字段：`agent_transcript_path`（子代理自己的对话记录）
- 可用 `decision: "block"` + `continue: true` 强制子代理继续

**验证审查质量脚本** `verify-review-quality.sh`
```bash
HAS_ISSUES=$(grep -c "issue\|问题\|bug\|warning" "$TRANSCRIPT" || true)
HAS_SUGGESTIONS=$(grep -c "suggest\|建议\|recommend" "$TRANSCRIPT" || true)
if [ "$HAS_ISSUES" -gt 0 ] && [ "$HAS_SUGGESTIONS" -eq 0 ]; then
  # 只发现问题没给建议 → 阻住
fi
```

---

## 七、两大完整 Hook 系统

### 系统一：安全钩子系统（纵深防御）

```
第一道防线：PreToolUse → Bash（命令拦截）
  └── 拦截 rm -rf /、git push --force、DROP DATABASE 等

第二道防线：PreToolUse → Write|Edit（文件保护）
  └── 保护 .env、*.pem、credentials.json 等敏感文件

第三道防线：PostToolUse → *（审计日志）
  └── 所有操作无差别记录，事后追溯
```

### 系统二：质量钩子系统（两阶段流水线）

```
第一阶段：PostToolUse → Write|Edit（逐文件质量保证）
  └── 先 auto-format.sh（格式化）
  └── 再 lint-check.sh（Lint 检查）
  └── 注意：hooks 数组按顺序执行，顺序不能反

第二阶段：Stop（全局质量门控）
  └── run-tests.sh（完整测试套件）
  └── 测试不通过 → Claude 继续修复 → 循环直到全部通过
```

---

## 八、高级模式与最佳实践

### 多 Hook 链
```jsonc
"hooks": [
  { "type": "command", "command": "./hooks/format.sh" },
  { "type": "command", "command": "./hooks/lint.sh" },
  { "type": "command", "command": "./hooks/log.sh" }
]
```
- 按数组顺序执行，前一个返回 `exit 2` 阻住，后续不执行
- 把"不能失败"的 Hook（如日志）放在最前面

### 异步 Hook
```jsonc
{
  "type": "command",
  "command": "./hooks/run-tests-async.sh",
  "async": true,
  "timeout": 300
}
```
- 适合：后台跑测试、发送通知、写入远程日志
- **限制：** 只能 command 类型；不能阻止操作；结果有延迟

### HTTP Hook
```jsonc
{
  "type": "http",
  "url": "http://localhost:8080/hooks/tool-use",
  "headers": { "Authorization": "Bearer $MY_TOKEN" },
  "allowedEnvVars": ["MY_TOKEN"]
}
```
- 响应体用 JSON 格式表达决策
- HTTP 状态码不能阻止操作

### Skill / Command 中内置临时 Hook
```yaml
---
description: Deploy with safety checks
hooks:
  - event: PreToolUse
    matcher: Bash
    command: |
      if [[ "$TOOL_INPUT" == *"production"* ]]; then
        echo "Production detected" >&2
      fi
  - event: PostToolUse
    matcher: Edit
    command: npx prettier --write "$FILE_PATH"
    once: true   # 只触发一次（仅 Skill 支持）
---
```

### frontmatter Hooks vs 全局 Hooks

| 对比维度 | 全局 settings.json | frontmatter Hooks |
|---------|-------------------|-------------------|
| 作用域 | 所有工具调用 | 只在该子代理内 |
| 覆盖一切 | ✓ | ✗ |
| SQL 注入检查 | 所有 Bash（浪费+误拦） | 只 db-reader 子代理 |

---

## 九、安全最佳实践

1. **用绝对路径** `"$CLAUDE_PROJECT_DIR"/.claude/hooks/xxx.sh`（相对路径在子代理中可能解析错误）
2. **最小权限原则** — 检查条件越少，误拦概率越低
3. **快速失败** — 耗时操作用 `async: true`
4. **优雅降级** — 工具不存在时跳过，不报错
5. **输入校验** — 用 `jq` 解析并验证 stdin，从不盲目信任
6. **引号包裹变量** — `"$VAR"` 防空格路径问题
7. **路径遍历防护** — 检查 `..` 防止恶意路径逃逸

---

## 十、三维决策框架

设计 Hook 方案需回答三个问题：

| 维度 | 选项 | 决策依据 |
|------|------|----------|
| **事件**（什么时候） | PreToolUse / PostToolUse / Stop / Subagent... | 操作前拦截 → 操作后反馈 |
| **类型**（怎么做） | command / prompt / agent / http | 确定性优先；需要理解力时升级 |
| **位置**（谁的责任） | 全局 / 项目级 / frontmatter | 通用 → 全局；特定子代理 → frontmatter |

---

## 十一、Hooks + SubAgent 组合模式

```
子代理定义（frontmatter）
├── Stop Hook → 内部自检（"我的输出完整吗？"）
│
全局 settings.json
├── SubagentStart Hook → 外部注入（"给你必要的上下文"）
└── SubagentStop Hook  → 外部验收（"你的工作达标了吗？"）
```

| 视角 | 能发现的问题 |
|------|------------|
| frontmatter 内部自检 | "自己知道自己的漏了什么" |
| SubagentStop 外部验收 | "它觉得完成了，但其实不够好" |

---

## 十二、与 Pipeline / Git Hooks 的时间窗口对比

| 层级 | 时间窗口 | 职责 |
|------|---------|------|
| **Hooks** | 毫秒级 | Claude 正在操作的那一秒 |
| **Git Hooks** | 秒级 | 代码提交的那一刻 |
| **Pipeline** | 分钟级 | 代码合入的那一步 |

> **三者互补：** 去任何一层都会在对应时间窗口留下空白。Pipeline 是保险，Hooks 是烟雾报警器——保险赔得了钱，赔不了命。

---

## 十三、调试技巧

1. **stderr 输出调试**：`echo "DEBUG: ..." >&2`（不污染 stdout 的 JSON）
2. **手动测试**：`echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | ./hooks/block-dangerous.sh`
3. **Claude Debug 模式**：`claude --debug` 查看完整执行细节
4. **排查清单**：
   - Hook 不触发 → 检查 matcher 大小写；编辑后需重启会话
   - 权限问题 → `chmod +x hooks/*.sh`
   - JSON 解析失败 → 检查 `~/.zshrc`/`~/.bashrc` 是否有无条件 `echo` 语句污染 stdout
   - Stop 死循环 → 确认已加 `stop_hook_active` 判断

---

## 十四、核心金句

> - "Hooks 是 Claude Code 三大扩展机制中唯一能拦截和修改 AI 行为的组件。"
> - "Claude 不需要知道有 Hook 在运行——安全防线、质量守卫、审计日志的工作，全部由 Hooks 在'幕后'自动完成。"
> - "CL AUDE.md 是'建议'，Hook 是'法律'——一个靠 LLM 自觉，一个靠代码强制。"
> - "能用 command 解决的不要用 prompt，能用 prompt 解决的不要用 agent。"
