#!/usr/bin/env bash
# init-subproject.sh — 初始化子项目的 .claude 目录结构
#
# 用法：
#   sh init-subproject.sh <子项目路径> <fe|be> [项目名]
#
# 参数：
#   $1: 子项目路径（如 ./ai-kg-front）
#   $2: 子项目类型（fe=前端, be=后端）
#   $3: 项目名称（可选，默认从子项目目录名推断）

set -euo pipefail

# ─── 颜色输出 ───────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { printf "${BLUE}[INFO]${NC}   %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}     %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}   %s\n" "$1"; }
error()   { printf "${RED}[ERROR]${NC}  %s\n" "$1"; }

# ─── 参数验证 ───────────────────────────────────────────────────────────────
SUBPROJECT_DIR="${1:-}"
SUBPROJECT_TYPE="${2:-}"
PROJECT_NAME="${3:-}"

if [[ -z "$SUBPROJECT_DIR" || -z "$SUBPROJECT_TYPE" ]]; then
    error "用法：sh init-subproject.sh <子项目路径> <fe|be> [项目名]"
    exit 1
fi

if [[ "$SUBPROJECT_TYPE" != "fe" && "$SUBPROJECT_TYPE" != "be" ]]; then
    error "类型参数无效：${SUBPROJECT_TYPE}（仅支持 fe 或 be）"
    exit 1
fi

SUBPROJECT_DIR="$(cd "$SUBPROJECT_DIR" 2>/dev/null && pwd)" || { error "子项目目录不存在：$1"; exit 1; }
SUBPROJECT_NAME="$(basename "$SUBPROJECT_DIR")"

if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="$SUBPROJECT_NAME"
fi

# ─── 路径设置 ───────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/subproject"

# ─── 检查是否已初始化 ─────────────────────────────────────────────────────
if [[ -d "$SUBPROJECT_DIR/.claude" ]]; then
    warn "子项目已有 .claude 目录，跳过：$SUBPROJECT_NAME"
    exit 0
fi

# ─── 确定模板目录 ─────────────────────────────────────────────────────────
if [[ "$SUBPROJECT_TYPE" == "fe" ]]; then
    SOURCE_DIR="$TEMPLATE_DIR/frontend"
    TYPE_LABEL="前端"
else
    SOURCE_DIR="$TEMPLATE_DIR/backend"
    TYPE_LABEL="后端"
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    error "模板目录不存在：$SOURCE_DIR"
    exit 1
fi

# ─── 创建目录结构 ─────────────────────────────────────────────────────────
info "初始化${TYPE_LABEL}子项目：$SUBPROJECT_NAME"

mkdir -p "$SUBPROJECT_DIR/.claude"/{context,rules}

# ─── 复制并替换模板 ───────────────────────────────────────────────────────
FILE_COUNT=0

# 遍历模板目录中所有 .template 文件
while IFS= read -r -d '' template_file; do
    # 计算相对路径并去掉 .template 后缀
    rel_path="${template_file#"$SOURCE_DIR/"}"
    target_path="$SUBPROJECT_DIR/.claude/${rel_path%.template}"

    # 确保目标目录存在
    mkdir -p "$(dirname "$target_path")"

    # 复制并替换占位符
    sed -e "s/\${PROJECT_NAME}/$PROJECT_NAME/g" \
        -e "s/\${SUBPROJECT_NAME}/$SUBPROJECT_NAME/g" \
        "$template_file" > "$target_path"

    FILE_COUNT=$((FILE_COUNT + 1))
done < <(find "$SOURCE_DIR" -name "*.template" -type f -print0)

success "已创建 $FILE_COUNT 个文件 → $SUBPROJECT_NAME/.claude/"
