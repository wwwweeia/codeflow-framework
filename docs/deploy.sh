#!/usr/bin/env bash
# docs/deploy.sh — 同步文档到远程服务器并构建
# 用法：
#   bash deploy.sh                    # 预览要同步的文件（dry-run）
#   bash deploy.sh --confirm          # 实际同步 + 远程构建
#   bash deploy.sh --confirm --build-only  # 只触发远程构建，不同步文件

set -euo pipefail

# 定位项目根目录（脚本可能在 docs/ 或项目根目录执行）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/core/MANIFEST" ]; then
  ROOT_DIR="$SCRIPT_DIR"
elif [ -f "$SCRIPT_DIR/../core/MANIFEST" ]; then
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  echo "错误：找不到项目根目录（缺少 core/MANIFEST）" >&2
  exit 1
fi
cd "$ROOT_DIR"

REMOTE_HOST="${DOCS_REMOTE_HOST:-root@192.168.104.125}"
REMOTE_DIR="${DOCS_REMOTE_DIR:-/home/HCodeFlow}"

# ── 参数解析 ──
CONFIRM=false
BUILD_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --confirm)   CONFIRM=true ;;
    --build-only) BUILD_ONLY=true ;;
    --help|-h)
      echo "用法: bash deploy.sh [--confirm] [--build-only]"
      echo ""
      echo "  (默认)       dry-run，预览要同步的文件"
      echo "  --confirm    实际同步并触发远程构建"
      echo "  --build-only 只触发远程构建，不同步文件"
      echo ""
      echo "环境变量："
      echo "  DOCS_REMOTE_HOST  远程主机 (默认: root@192.168.104.125)"
      echo "  DOCS_REMOTE_DIR   远程目录 (默认: /home/HCodeFlow)"
      exit 0
      ;;
    *) echo "未知参数: $arg"; exit 1 ;;
  esac
done

# ── 只构建 ──
if $BUILD_ONLY; then
  echo ">>> 触发远程构建..."
  ssh "$REMOTE_HOST" "cd $REMOTE_DIR/docs && npm run docs:build"
  echo "✓ 构建完成"
  exit 0
fi

# ── 同步文件（docs 构建只需要这些） ──
SYNC_FILES=(
  docs/
  core/
  CHANGELOG.md
  CLAUDE.md
)

RSYNC_OPTS=(
  -avz
  --exclude='node_modules'
  --exclude='.vitepress/cache'
  --exclude='public'
  --exclude='.DS_Store'
)

if ! $CONFIRM; then
  RSYNC_OPTS+=(--dry-run)
  echo ">>> [DRY-RUN] 预览要同步的文件..."
else
  echo ">>> 同步文件到 ${REMOTE_HOST}:${REMOTE_DIR}..."
fi

rsync "${RSYNC_OPTS[@]}" "${SYNC_FILES[@]}" "${REMOTE_HOST}:${REMOTE_DIR}/"

if ! $CONFIRM; then
  echo ""
  echo "以上文件将被同步。确认后执行：bash deploy.sh --confirm"
  exit 0
fi

# ── 远程构建 ──
echo ""
echo ">>> 检查远程依赖..."

# 只在 package-lock.json 变化时才 npm ci
NEED_CI=$(ssh "$REMOTE_HOST" "
  cd $REMOTE_DIR/docs
  if [ ! -d node_modules/.package-lock.json ] || \
     ! diff -q <(md5sum package-lock.json | cut -d' ' -f1) \
               <(md5sum node_modules/.package-lock.json 2>/dev/null | cut -d' ' -f1) >/dev/null 2>&1; then
    echo 'yes'
  else
    echo 'no'
  fi
")

if [ "$NEED_CI" = "yes" ]; then
  echo ">>> package-lock.json 有变化，执行 npm ci..."
  ssh "$REMOTE_HOST" "cd $REMOTE_DIR/docs && npm ci"
else
  echo ">>> 依赖无变化，跳过 npm ci"
fi

echo ">>> 触发远程构建..."
ssh "$REMOTE_HOST" "cd $REMOTE_DIR/docs && npm run docs:build"

echo ""
echo "✓ 部署完成"
