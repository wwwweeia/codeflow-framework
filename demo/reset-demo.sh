#!/usr/bin/env bash
# reset-demo.sh — 重置演示项目到指定状态
#
# 用法：
#   sh reset-demo.sh --base          # 完全重置到初始状态
#   sh reset-demo.sh --scenario N    # 重置到场景 N 起点（1-4）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { printf "${CYAN}[INFO]${NC}  %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }

MODE="${1:---base}"
SCENARIO="${2:-0}"

# ─── 清理生成的文件 ───────────────────────────────────────────────

info "清理演示生成的文件..."

# 清理 specs 目录（保留目录结构）
if [ -d ".claude/specs" ]; then
    rm -rf .claude/specs/*
    success "已清理 .claude/specs/"
fi

# 清理 codemap（保留模板）
if [ -d ".claude/codemap" ]; then
    find .claude/codemap -type f -not -name "*.template" -delete 2>/dev/null || true
    success "已清理 .claude/codemap/"
fi

# 清理数据库文件
rm -f backend/*.db backend/test.db
success "已清理数据库文件"

# 清理前端构建产物
rm -rf frontend/dist
success "已清理前端构建产物"

# 清理后端 __pycache__
find backend -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
success "已清理 Python 缓存"

# 清理 git worktrees
if [ -d ".worktrees" ]; then
    rm -rf .worktrees
    success "已清理 worktrees"
fi

# 删除 feature 分支（保留 main/develop）
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCHES=$(git branch --list 'feature/*' 'feat/*' 2>/dev/null || true)
    if [ -n "$BRANCHES" ]; then
        echo "$BRANCHES" | xargs git branch -D 2>/dev/null || true
        success "已清理 feature 分支"
    fi
fi

# ─── 重置种子数据 ───────────────────────────────────────────────

info "重新生成种子数据..."
cd backend
python scripts/seed.py 2>/dev/null && success "种子数据已重建" || warn "种子数据重建失败（请先 pip install）"
cd ..

echo ""
success "演示环境已重置！"
info "启动方式："
info "  后端: cd backend && uvicorn app.main:app --reload"
info "  前端: cd frontend && npm run dev"
