#!/usr/bin/env bash
# submit-feedback.sh — 向 codeflow-framework 团队提交反馈
#
# 用法: echo '<json>' | bash submit-feedback.sh [--dry-run]
#
# 输入 JSON 格式（通过 stdin）:
# {
#   "type": "bug|feature|improvement|question",
#   "component": "agents|rules|skills|workflow|upgrade|other",
#   "priority": "low|medium|high",
#   "title": "一句话概括",
#   "description": "详细描述",
#   "project": "来源项目名",
#   "framework_version": "vX.X.X-YYYYMMDD",
#   "submitter": "提交者",
#   "reproduce_steps": "复现步骤（bug 专用，可选）",
#   "expected_behavior": "期望行为（bug 专用，可选）",
#   "actual_behavior": "实际行为（bug 专用，可选）"
# }
#
# Phase 1: Webhook 通知
# Phase 2: GitHub Issue + Webhook 通知（Issue URL 嵌入通知）

set -euo pipefail

# ─── 参数解析 ───────────────────────────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
    esac
done

# ─── 配置 ───────────────────────────────────────────────────────────────────
# Webhook URL（需通过环境变量配置）
WEBHOOK_URL="${FEEDBACK_WEBHOOK:-}"

# 框架 GitHub 仓库（Issue 统一创建在框架仓库，便于集中管理）
FRAMEWORK_REPO="${FRAMEWORK_FEEDBACK_REPO:-wwwweeia/codeflow-framework}"

# ─── 颜色输出 ───────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { printf "${BLUE}[INFO]${NC}   %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}     %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}   %s\n" "$1"; }
error()   { printf "${RED}[ERROR]${NC}  %s\n" "$1"; }

# ─── 读取 stdin 并用 python3 处理全部逻辑 ────────────────────────────────────
INPUT=$(cat)

if ! echo "$INPUT" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    error "输入不是有效的 JSON"
    exit 1
fi

# 将输入写入临时文件，让 python3 安全读取（避免 bash 变量中的特殊字符问题）
TMP_INPUT=$(mktemp)
echo "$INPUT" > "$TMP_INPUT"
trap "rm -f $TMP_INPUT /tmp/feedback_resp.json" EXIT

# ─── 校验 + 构建 + 发送（全部用 python3 完成） ───────────────────────────────
RESULT=$(python3 - "$TMP_INPUT" "$WEBHOOK_URL" "$FRAMEWORK_REPO" "$DRY_RUN" <<'PYTHON_SCRIPT'
import json
import subprocess
import sys
import urllib.request


def create_github_issue(data, repo):
    """通过 gh CLI 在框架仓库创建 GitHub Issue，返回结果字典"""
    try:
        # 检查 gh 是否可用
        subprocess.run(["gh", "--version"], capture_output=True, timeout=5, check=True)
    except (FileNotFoundError, subprocess.TimeoutExpired, subprocess.CalledProcessError) as e:
        print(f"[INFO]   gh CLI 不可用，跳过 GitHub Issue 创建: {e}", file=sys.stderr)
        return {"status": "skipped", "note": "gh CLI 不可用"}

    # 构建 Issue body
    body_parts = [data["description"]]
    if data["type"] == "bug":
        for field, label in [("reproduce_steps", "### 复现步骤"), ("expected_behavior", "### 期望行为"), ("actual_behavior", "### 实际行为")]:
            val = data.get(field, "")
            if val:
                body_parts.append(f"\n{label}\n{val}")
    body_parts.append(f"\n---\n**来源项目**: {data.get('project', 'unknown')} | **框架版本**: {data.get('framework_version', 'unknown')} | **提交者**: {data.get('submitter', 'anonymous')}")

    body = "\n".join(body_parts)

    # gh issue create 参数
    label_map = {
        "bug": "bug",
        "feature": "enhancement",
        "improvement": "improvement",
        "question": "question",
    }
    label = label_map.get(data["type"], "feedback")

    cmd = [
        "gh", "issue", "create",
        "--repo", repo,
        "--title", data["title"],
        "--body", body,
        "--label", label,
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        output = (result.stdout or "") + (result.stderr or "")

        # gh 成功时输出包含 Issue URL
        if result.returncode == 0:
            # 从输出中提取 URL（格式通常为 https://github.com/owner/repo/issues/N）
            import re
            url_match = re.search(r'(https?://\S+/issues/\d+)', output)
            issue_url = url_match.group(1) if url_match else output.strip()
            iid_match = re.search(r'/issues/(\d+)', issue_url) if issue_url else None
            issue_iid = iid_match.group(1) if iid_match else ""

            print(f"[OK]     GitHub Issue 创建成功: {issue_url}", file=sys.stderr)
            return {"status": "success", "url": issue_url, "iid": issue_iid}
        else:
            print(f"[WARN]   GitHub Issue 创建失败: {output.strip()}", file=sys.stderr)
            return {"status": "failed", "error": output.strip()}
    except Exception as e:
        print(f"[WARN]   GitHub Issue 创建异常: {e}", file=sys.stderr)
        return {"status": "failed", "error": str(e)}


def main():
    input_file = sys.argv[1]
    webhook_url = sys.argv[2]
    repo = sys.argv[3]
    dry_run = sys.argv[4] == "true"

    with open(input_file) as f:
        data = json.load(f)

    # 校验必填字段
    required = ["type", "title", "description"]
    missing = [k for k in required if not data.get(k)]
    if missing:
        print(json.dumps({"status": "failed", "error": f"缺少必填字段: {', '.join(missing)}"}))
        sys.exit(1)

    valid_types = ["bug", "feature", "improvement", "question"]
    if data["type"] not in valid_types:
        print(json.dumps({"status": "failed", "error": f"无效的 type: {data['type']}"}))
        sys.exit(1)

    # 填充默认值
    data.setdefault("component", "other")
    data.setdefault("priority", "medium")
    data.setdefault("project", "unknown")
    data.setdefault("framework_version", "unknown")
    data.setdefault("submitter", "anonymous")

    if dry_run:
        print("[DRY-RUN] 将提交以下反馈：", file=sys.stderr)
        print(json.dumps(data, ensure_ascii=False, indent=2), file=sys.stderr)
        print(json.dumps({
            "status": "dry_run",
            "type": data["type"],
            "title": data["title"],
            "project": data["project"]
        }))
        return

    # Phase 2: 先创建 GitHub Issue，拿到 URL
    github_result = create_github_issue(data, repo)
    data["issue_url"] = github_result.get("url", "")
    data["issue_iid"] = github_result.get("iid", "")

    # 发送 Webhook 通知（如果配置了）
    webhook_result = {"status": "skipped", "note": "未配置 FEEDBACK_WEBHOOK"}
    if webhook_url:
        webhook_result = send_webhook(data, webhook_url)

    overall = "success" if github_result.get("status") in ("success", "skipped") else "partial"
    result = {
        "status": overall,
        "webhook": webhook_result,
        "github": github_result
    }
    print(json.dumps(result, ensure_ascii=False))


def send_webhook(data, webhook_url):
    """发送 Webhook 通知，返回结果字典"""
    try:
        payload = json.dumps({
            "type": data["type"],
            "title": data["title"],
            "description": data["description"],
            "priority": data["priority"],
            "project": data.get("project", "unknown"),
            "issue_url": data.get("issue_url", ""),
            "submitter": data.get("submitter", "anonymous"),
            "framework_version": data.get("framework_version", "unknown"),
        }, ensure_ascii=False).encode("utf-8")
        req = urllib.request.Request(
            webhook_url,
            data=payload,
            headers={"Content-Type": "application/json"}
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            result = json.loads(resp.read().decode("utf-8"))

        print("[OK]     Webhook 通知发送成功", file=sys.stderr)
        return {"status": "success"}
    except Exception as e:
        print(f"[WARN]   Webhook 通知发送失败: {e}", file=sys.stderr)
        return {"status": "failed", "error": str(e)}


if __name__ == "__main__":
    main()
PYTHON_SCRIPT
)

echo "$RESULT"
