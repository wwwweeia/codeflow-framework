#!/usr/bin/env bash
# release.sh — 框架发版脚本
#
# 用法：
#   cd h-codeflow-framework
#   bash tools/release.sh            # 预览模式（dry-run），审核通知内容
#   bash tools/release.sh --confirm  # 正式发版
#
# 流程（--confirm）：
# 1. 读取 VERSION，校验 CHANGELOG 中存在该版本记录
# 2. 推送 develop 到远程
# 3. 创建 tag 并推送
# 4. 合并 develop → master 并推送
# 5. 发送飞书通知

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
            echo "  默认：预览模式（dry-run），展示通知内容但不发送"
            echo "  --confirm：正式发送飞书通知"
            exit 0
            ;;
    esac
done

# ─── 路径设置 ───────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$FRAMEWORK_ROOT/tools/VERSION"
CHANGELOG_FILE="$FRAMEWORK_ROOT/CHANGELOG.md"
NOTIFY_SCRIPT="$FRAMEWORK_ROOT/notify/notify-release.py"

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

# 提取当前版本的 CHANGELOG 内容（从版本标题到下一个版本标题或文件末尾的分割线）
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

# 飞书 lark_md 不支持 # 标题语法，转成加粗格式
# ### 章节标题加 emoji 前缀，与 **子标题** 形成视觉层级
CHANGELOG_SUMMARY=$(echo "$CHANGELOG_CONTENT" | sed \
      -e 's/^### 变更\(.*\)$/🔴 **变更\1**/g' \
    -e 's/^### 新增$/🟢 **新增**/g' \
    -e 's/^### 优化$/🔵 **优化**/g' \
    -e 's/^### 清理$/🔘 **清理**/g' \
    -e 's/^### \(.*\)$/📌 **\1**/g' \
    -e 's/^## \(.*\)$/**\1**/g')

echo "$CHANGELOG_SUMMARY"

# ─── Step 4: 预览 / 发送通知 ──────────────────────────────────────────────
if [[ "$CONFIRM" != true ]]; then
    header "预览模式（dry-run）"
    warn "以下为飞书通知预览，不会实际发送"
    echo ""
    echo "────────────────────────────────────"
    echo "📦 Codeflow 框架新版本发布"
    echo "────────────────────────────────────"
    echo "版本：$VERSION"
    echo "发布时间：$RELEASE_DATE"
    echo ""
    echo "更新内容："
    echo "$CHANGELOG_SUMMARY"
    echo ""
    echo "升级方式："
    echo "  cd your-project"
    echo "  sh ../h-codeflow-framework/tools/upgrade.sh"
    echo "────────────────────────────────────"
    echo ""
    info "确认无误后，执行以下命令正式发送通知："
    echo ""
    printf "  ${BOLD}sh tools/release.sh --confirm${NC}\n"
    echo ""
    exit 0
fi

# ─── 推送 develop ──────────────────────────────────────────────────────────
header "推送 develop"

CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "develop" ]]; then
    error "当前不在 develop 分支（当前: ${CURRENT_BRANCH}），发版必须在 develop 上执行"
    exit 1
fi

git push origin develop 2>/dev/null && success "已推送 develop 到远程" || warn "develop 推送失败，请手动推送: git push origin develop"

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

# ─── 合并 develop → master ──────────────────────────────────────────────────
header "合并 develop → master"

# 保存当前分支，切换到 master，合并 develop，推送
git checkout master 2>/dev/null
git pull origin master 2>/dev/null

if git merge develop --no-edit; then
    success "已合并 develop → master"
    git push origin master 2>/dev/null && success "已推送 master 到远程" || warn "master 推送失败，请手动推送: git push origin master"
else
    error "合并 develop → master 失败，可能有冲突"
    echo "请手动解决冲突后执行："
    echo "  git add . && git commit --no-edit"
    echo "  git push origin master"
fi

# 切回 develop
git checkout develop 2>/dev/null
success "已切回 develop 分支"

# ─── 发送飞书通知 ──────────────────────────────────────────────────────────
header "发送飞书通知"

if [[ ! -f "$NOTIFY_SCRIPT" ]]; then
    error "通知脚本不存在：$NOTIFY_SCRIPT"
    exit 1
fi

python3 "$NOTIFY_SCRIPT" "$VERSION" "$RELEASE_DATE" "$CHANGELOG_SUMMARY"

header "发版完成"
success "版本 $VERSION 已发布并通知团队"
success "  - develop 已推送远程"
success "  - tag ${TAG_NAME} 已创建并推送"
success "  - master 已合并并推送"
