#!/usr/bin/env bash
# release.sh — 框架发版脚本
#
# 用法：
#   cd codeflow-framework
#   sh tools/release.sh            # 预览模式（dry-run），审核发版内容
#   sh tools/release.sh --confirm  # 正式发版（创建 tag + 推送 + 可选通知）
#
# 流程：
# 1. 读取 VERSION，校验 CHANGELOG 中存在该版本记录
# 2. 从 CHANGELOG 提取当前版本更新摘要
# 3. 预览发版内容
# 4. --confirm 时：创建 git tag、推送、发送通知（如配置了 NOTIFY_SCRIPT）

set -euo pipefail

# ─── 颜色输出 ───────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { printf "${BLUE}[INFO]${NC}   %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}     %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}   %s\n" "$1"; }
error()   { printf "${RED}[ERROR]${NC}  %s\n" "$1"; }
header()  { printf "\n${BOLD}${CYAN}═══ %s ═══${NC}\n\n" "$1"; }

# ─── 参数解析 ───────────────────────────────────────────────────────────────
CONFIRM=false
for arg in "$@"; do
    case "$arg" in
        --confirm) CONFIRM=true ;;
        --help|-h)
            echo "用法: sh tools/release.sh [--confirm]"
            echo "  默认：预览模式（dry-run），展示发版内容但不执行"
            echo "  --confirm：正式发版（创建 tag + 推送 + 通知）"
            echo ""
            echo "通知配置：设置 NOTIFY_SCRIPT 环境变量指向通知脚本路径"
            exit 0
            ;;
    esac
done

# ─── 路径设置 ───────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$FRAMEWORK_ROOT/tools/VERSION"
CHANGELOG_FILE="$FRAMEWORK_ROOT/CHANGELOG.md"
NOTIFY_SCRIPT="${NOTIFY_SCRIPT:-}"

# ─── Step 1: 读取版本号 ────────────────────────────────────────────────────
header "检查发版条件"

if [[ ! -f "$VERSION_FILE" ]]; then
    error "VERSION 文件不存在：$VERSION_FILE"
    exit 1
fi

VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
RELEASE_DATE=$(echo "$VERSION" | grep -oE '[0-9]{8}$' | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/')

if [[ -z "$VERSION" ]]; then
    error "VERSION 文件为空"
    exit 1
fi

if [[ "$VERSION" == *-dev* ]]; then
    error "VERSION 包含 '-dev' 标记（${VERSION}）— 请先移除 dev 标记再发版"
    exit 1
fi

info "版本号：$VERSION"
info "发布日期：$RELEASE_DATE"

# ─── Step 2: 校验 CHANGELOG ────────────────────────────────────────────────
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    error "CHANGELOG.md 不存在：$CHANGELOG_FILE"
    exit 1
fi

if ! grep -q "\[${VERSION}\]" "$CHANGELOG_FILE"; then
    error "CHANGELOG.md 中未找到版本 [${VERSION}] 的记录"
    error "请先更新 CHANGELOG.md，添加该版本的变更说明"
    exit 1
fi

success "CHANGELOG 中已包含版本 ${VERSION} 的记录"

# ─── Step 3: 提取 CHANGELOG 摘要 ──────────────────────────────────────────
header "提取更新摘要"

CHANGELOG_CONTENT=$(awk "
    /^## \\[${VERSION}\\]/ { found=1; next }
    found && /^## \\[/      { exit }
    found && /^---$/        { exit }
    found                   { print }
" "$CHANGELOG_FILE" | sed '/^$/N;/^\n$/d' | head -80)

if [[ -z "$CHANGELOG_CONTENT" ]]; then
    warn "未能从 CHANGELOG 提取到详细内容，使用默认摘要"
    CHANGELOG_CONTENT="版本 ${VERSION} 已发布，请查看 CHANGELOG.md 了解详情。"
fi

CHANGELOG_SUMMARY=$(echo "$CHANGELOG_CONTENT" | sed \
      -e 's/^### 变更\(.*\)$/🔴 **变更\1**/g' \
    -e 's/^### 新增$/🟢 **新增**/g' \
    -e 's/^### 优化$/🔵 **优化**/g' \
    -e 's/^### 清理$/🔘 **清理**/g' \
    -e 's/^### \(.*\)$/📌 **\1**/g' \
    -e 's/^## \(.*\)$/**\1**/g')

echo "$CHANGELOG_SUMMARY"

# ─── Step 4: 预览 / 发版 ──────────────────────────────────────────────────
if [[ "$CONFIRM" != true ]]; then
    header "预览模式（dry-run）"
    warn "以下为发版预览，不会实际执行"
    echo ""
    echo "────────────────────────────────────"
    echo "📦 CodeFlow 框架新版本发布"
    echo "────────────────────────────────────"
    echo "版本：$VERSION"
    echo "发布时间：$RELEASE_DATE"
    echo ""
    echo "更新内容："
    echo "$CHANGELOG_SUMMARY"
    echo ""
    echo "升级方式："
    echo "  cd your-project"
    echo "  bash ../codeflow-framework/tools/upgrade.sh"
    echo "────────────────────────────────────"
    echo ""
    info "确认无误后，执行以下命令正式发版："
    echo ""
    printf "  ${BOLD}sh tools/release.sh --confirm${NC}\n"
    echo ""
    exit 0
fi

# ─── 创建 git tag ──────────────────────────────────────────────────────────
header "创建版本 Tag"

TAG_NAME="v${VERSION}"
if git tag -l "$TAG_NAME" | grep -q .; then
    error "Tag ${TAG_NAME} 已存在"
    exit 1
fi

git tag "$TAG_NAME"
success "已创建 tag: ${TAG_NAME}"

git push origin "$TAG_NAME" 2>/dev/null && success "已推送 tag: ${TAG_NAME}" || warn "Tag 推送失败，请手动推送: git push origin ${TAG_NAME}"

# ─── 发送通知（可选） ──────────────────────────────────────────────────────
if [[ -n "$NOTIFY_SCRIPT" && -f "$NOTIFY_SCRIPT" ]]; then
    header "发送通知"
    python3 "$NOTIFY_SCRIPT" "$VERSION" "$RELEASE_DATE" "$CHANGELOG_SUMMARY"
    success "通知已发送"
else
    header "通知"
    info "未配置 NOTIFY_SCRIPT 环境变量，跳过通知"
    info "如需通知，设置 NOTIFY_SCRIPT 指向通知脚本路径"
fi

header "发版完成 🎉"
success "版本 $VERSION 已发布"
