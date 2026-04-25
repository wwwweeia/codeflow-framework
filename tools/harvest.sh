#!/usr/bin/env bash
# harvest.sh — 从下游项目收割验证过的框架变更（upgrade.sh 的逆操作）
#
# 用法（在框架目录执行）：
#   sh tools/harvest.sh ../your-project                      # 预览差异（dry-run）
#   sh tools/harvest.sh --apply ../your-project              # 实际写入 core/
#   sh tools/harvest.sh --apply --include-new ../your-project # 含新增文件
#
# 功能：
# 1. 扫描下游项目 .claude/ 下所有包含 "codeflow-framework:core" marker 的文件
# 2. 提取 marker 行及以上的内容（框架管理部分）
# 3. 与 core/ 对应文件做 diff 对比
# 4. --apply 模式下写入 core/，更新 marker 版本号
#
# 安全机制：
# - 版本检查：下游版本低于框架版本时拒绝收割，提示先执行 upgrade.sh
# - marker-only 过滤：仅版本号不同的文件单独汇总，不展示 diff
# - 覆盖风险安全网：框架内容多于下游时标记风险，--apply 需逐文件确认
# - core/ 本地修改检测：框架侧有未发布修改时标记 [CORE-MODIFIED]，--apply 需逐文件确认

set -euo pipefail

# ─── 加载通用函数库 ────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/sync-common.sh"

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

# ─── 版本比较工具（已提取到 sync-common.sh）──────────────────────────────────

# 检测框架内容是否会被更少的下游内容覆盖（行数比较）
# 返回: 0=安全(框架行数≤下游), 1=有风险(框架行数>下游)
check_shrink_risk() {
    local core_lines harvested_lines
    core_lines=$(echo "$1" | wc -l | tr -d ' ')
    harvested_lines=$(echo "$2" | wc -l | tr -d ' ')
    [[ "$core_lines" -le "$harvested_lines" ]] && return 0
    return 1
}

# ─── 参数解析 ───────────────────────────────────────────────────────────────
APPLY=false
INCLUDE_NEW=false
PROJECT_DIR=""

for arg in "$@"; do
    case "$arg" in
        --apply) APPLY=true ;;
        --include-new) INCLUDE_NEW=true ;;
        --help|-h)
            echo "用法: sh tools/harvest.sh [--apply] [--include-new] PROJECT_DIR"
            echo ""
            echo "  默认：预览模式（dry-run），展示差异但不写入"
            echo "  --apply：实际写入 core/，写入前备份"
            echo "  --include-new：处理下游新增的、core/ 中不存在的文件"
            echo ""
            echo "示例:"
            echo "  sh tools/harvest.sh ../your-project"
            echo "  sh tools/harvest.sh --apply ../your-project"
            exit 0
            ;;
        -*) error "未知参数：$arg"; exit 1 ;;
        *) PROJECT_DIR="$arg" ;;
    esac
done

if [[ -z "$PROJECT_DIR" ]]; then
    error "请指定下游项目目录，例如：sh tools/harvest.sh ../your-project"
    exit 1
fi

# ─── 路径设置 ───────────────────────────────────────────────────────────────
FRAMEWORK_ROOT="$(dirname "$SCRIPT_DIR")"
FRAMEWORK_CORE="$FRAMEWORK_ROOT/core"
PROJECT_ROOT="$(cd "$PROJECT_DIR" && pwd)"
PROJECT_CLAUDE="$PROJECT_ROOT/.claude"

# 框架侧同步状态文件（检测 core/ 本地修改）
HARVEST_STATE_DIR="$FRAMEWORK_CORE/.sync-state"
HARVEST_STATE_FILE="$HARVEST_STATE_DIR/harvest-state.csv"

FRAMEWORK_VERSION=$(cat "$FRAMEWORK_ROOT/tools/VERSION" | tr -d '[:space:]')

if [[ ! -d "$FRAMEWORK_CORE" ]]; then
    error "框架 core 目录不存在：$FRAMEWORK_CORE"
    exit 1
fi

if [[ ! -d "$PROJECT_CLAUDE" ]]; then
    error "项目 .claude 目录不存在：$PROJECT_CLAUDE"
    exit 1
fi

header "收割框架变更"
info "下游项目：$PROJECT_ROOT"
info "框架版本：$FRAMEWORK_VERSION"

if [[ "$APPLY" = true ]]; then
    warn "写入模式（--apply）：变更将写入 core/"
else
    info "预览模式（dry-run）：仅展示差异，不写入文件"
fi

# ─── 扫描下游 marker 文件 ─────────────────────────────────────────────────
header "扫描下游项目文件"

MANAGED_FILES_TEMP=$(mktemp)
grep -r "codeflow-framework:core" "$PROJECT_CLAUDE" --include="*.md" 2>/dev/null | cut -d: -f1 | sort -u > "$MANAGED_FILES_TEMP" || true

MANAGED_COUNT=$(wc -l < "$MANAGED_FILES_TEMP" | tr -d ' ')

if [[ "$MANAGED_COUNT" -eq 0 ]]; then
    warn "未发现包含 marker 的文件"
    rm "$MANAGED_FILES_TEMP"
    exit 0
fi

info "发现 $MANAGED_COUNT 个 marker 文件"

# ─── MANIFEST 范围检查 ──────────────────────────────────────────────────
if [[ -f "$FRAMEWORK_CORE/MANIFEST" ]]; then
    MANIFEST_UNKNOWN_COUNT=0
    MANIFEST_UNKNOWN_FILES=""

    while IFS= read -r MF; do
        [[ -z "$MF" ]] && continue
        MF_RELATIVE="${MF#$PROJECT_CLAUDE/}"

        if ! is_in_manifest "$FRAMEWORK_CORE" "$MF_RELATIVE"; then
            MANIFEST_UNKNOWN_COUNT=$((MANIFEST_UNKNOWN_COUNT + 1))
            MANIFEST_UNKNOWN_FILES="${MANIFEST_UNKNOWN_FILES}  - ${MF_RELATIVE}\n"
        fi
    done < "$MANAGED_FILES_TEMP"

    if [[ "$MANIFEST_UNKNOWN_COUNT" -gt 0 ]]; then
        echo ""
        printf "${YELLOW}[MANIFEST]${NC} %d 个 marker 文件不在 MANIFEST 中：\n\n" "$MANIFEST_UNKNOWN_COUNT"
        printf "$MANIFEST_UNKNOWN_FILES"
        echo ""
        printf "${CYAN}这些文件可能是已废弃的框架文件，收割后也不会写入 core/。${NC}\n"
        printf "${CYAN}建议在下游项目中移除这些文件或移除其 marker。${NC}\n"
        echo ""
    fi
else
    warn "未找到 MANIFEST，跳过范围检查"
fi

# ─── 版本检查（框架为主原则） ─────────────────────────────────────────────
# upgrade.sh 只更新有内容变化的文件的 marker，所以取所有文件的最大版本号
DOWNSTREAM_VERSION=""
MAX_VERSION="0.0.0-00000000"

while IFS= read -r MF; do
    [[ -z "$MF" ]] && continue
    MF_VER=$(grep -oE "codeflow-framework:core v[^ ]+" "$MF" \
             | tail -1 | sed 's/codeflow-framework:core v//' | tr -d '[:space:]')
    if [[ -n "$MF_VER" ]] && [[ "$MF_VER" != X* ]]; then
        # 比较当前版本与已知的最大版本
        VERSION_CMP_TMP=0
        compare_versions "$MF_VER" "$MAX_VERSION" || VERSION_CMP_TMP=$?
        if [[ $VERSION_CMP_TMP -eq 1 ]]; then
            MAX_VERSION="$MF_VER"
        fi
    fi
done < "$MANAGED_FILES_TEMP"

DOWNSTREAM_VERSION="$MAX_VERSION"

if [[ -n "$DOWNSTREAM_VERSION" ]]; then
    info "下游项目版本：$DOWNSTREAM_VERSION"
    info "框架版本：    $FRAMEWORK_VERSION"

    # || 避免 set -e 捕获非零返回码
    VERSION_CMP=0
    compare_versions "$DOWNSTREAM_VERSION" "$FRAMEWORK_VERSION" || VERSION_CMP=$?

    if [[ $VERSION_CMP -eq 2 ]]; then
        echo ""
        error "下游项目版本 ($DOWNSTREAM_VERSION) 低于框架版本 ($FRAMEWORK_VERSION)"
        error "直接收割会用旧内容覆盖框架新内容，导致新增规则丢失"
        echo ""
        warn "请先在下游项目执行升级："
        echo ""
        echo "  cd $PROJECT_DIR"
        echo "  bash ../codeflow-framework/tools/upgrade.sh"
        echo ""
        warn "升级后再执行 harvest.sh"
        rm "$MANAGED_FILES_TEMP"
        exit 1
    elif [[ $VERSION_CMP -eq 0 ]]; then
        success "版本一致，可以安全收割"
    else
        info "下游版本高于框架版本，将收割验证过的内容"
    fi
else
    warn "未能从下游文件提取版本号，跳过版本检查"
fi

# ─── 备份与收割 ───────────────────────────────────────────────────────────
BACKUP_DIR="$FRAMEWORK_CORE/.backup/harvest-$(date +%Y%m%d-%H%M%S)"

SKIPPED_COUNT=0
NEW_COUNT=0
REAL_CHANGED_COUNT=0
MARKER_ONLY_COUNT=0
MARKER_ONLY_FILES=""
SHRINK_RISK_FILES=""
CORE_MODIFIED_COUNT=0
CORE_MODIFIED_FILES=""

# 初始化批量 hash 写入
batch_write_init

while IFS= read -r TARGET_FILE; do
    [[ -z "$TARGET_FILE" ]] && continue

    RELATIVE_PATH="${TARGET_FILE#$PROJECT_CLAUDE/}"
    SOURCE_FILE="$FRAMEWORK_CORE/$RELATIVE_PATH"

    # 查找下游文件的 marker 行号（取最后一个，跳过代码块内的 template marker）
    MARKER_LINE=$(grep -n "codeflow-framework:core" "$TARGET_FILE" | tail -1 | cut -d: -f1)

    if [[ -z "$MARKER_LINE" ]]; then
        warn "未找到 marker，跳过：$RELATIVE_PATH"
        continue
    fi

    # 提取 marker 行及以上内容（框架管理部分）
    HARVESTED_CONTENT=$(head -n "$MARKER_LINE" "$TARGET_FILE")

    # 将最后一行 marker 中的版本号更新为当前框架版本
    HARVESTED_CONTENT=$(echo "$HARVESTED_CONTENT" | sed "$ s/codeflow-framework:core v[^ ]*/codeflow-framework:core v${FRAMEWORK_VERSION}/")

    # ── 处理新文件（core/ 中不存在的）──
    if [[ ! -f "$SOURCE_FILE" ]]; then
        NEW_COUNT=$((NEW_COUNT + 1))
        printf "${YELLOW}[NEW]${NC}    %s — core/ 中无对应文件\n" "$RELATIVE_PATH"

        if [[ "$INCLUDE_NEW" = true ]] && [[ "$APPLY" = true ]]; then
            mkdir -p "$(dirname "$SOURCE_FILE")"
            echo "$HARVESTED_CONTENT" > "$SOURCE_FILE"
            success "已创建：$RELATIVE_PATH"
        elif [[ "$INCLUDE_NEW" = true ]]; then
            info "（dry-run）将创建：$RELATIVE_PATH"
        fi
        continue
    fi

    # ── 比较内容差异（三分类） ──
    CURRENT_CORE=$(cat "$SOURCE_FILE")

    # 完全一致 → 跳过
    if [[ "$HARVESTED_CONTENT" = "$CURRENT_CORE" ]]; then
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    # 去掉 marker 行后比较，判断是否为 marker-only 变更
    CORE_NO_MARKER=$(echo "$CURRENT_CORE" | grep -v "codeflow-framework:core")
    HARVESTED_NO_MARKER=$(echo "$HARVESTED_CONTENT" | grep -v "codeflow-framework:core")

    if [[ "$HARVESTED_NO_MARKER" = "$CORE_NO_MARKER" ]]; then
        # marker-only：仅版本号差异，不展示 diff
        MARKER_ONLY_COUNT=$((MARKER_ONLY_COUNT + 1))
        LOCAL_DS_VER=$(grep -oE "codeflow-framework:core v[^ ]+" "$TARGET_FILE" \
                       | tail -1 | sed 's/codeflow-framework:core v//' | tr -d '[:space:]')
        MARKER_ONLY_FILES="${MARKER_ONLY_FILES}  - ${RELATIVE_PATH}  (${LOCAL_DS_VER:-?} → ${FRAMEWORK_VERSION})\n"
        continue
    fi

    # 有实质内容差异
    REAL_CHANGED_COUNT=$((REAL_CHANGED_COUNT + 1))

    # ── 检测 core/ 本地修改（框架侧是否有未发布的变更） ──
    CORE_MODIFIED=false
    CORE_LAST_HASH=$(read_hash "$HARVEST_STATE_FILE" "$RELATIVE_PATH")
    if [[ -n "$CORE_LAST_HASH" ]]; then
        CORE_CURRENT_HASH=$(compute_hash "$CURRENT_CORE")
        if [[ "$CORE_CURRENT_HASH" != "$CORE_LAST_HASH" ]]; then
            CORE_MODIFIED=true
            CORE_MODIFIED_COUNT=$((CORE_MODIFIED_COUNT + 1))
            CORE_MODIFIED_FILES="${CORE_MODIFIED_FILES}  - ${RELATIVE_PATH}\n"
        fi
    fi

    # ── 安全网检测（框架内容缩减风险） ──
    SHRINK_RISK=false
    if ! check_shrink_risk "$CURRENT_CORE" "$HARVESTED_CONTENT"; then
        SHRINK_RISK=true
        CORE_LINES=$(echo "$CURRENT_CORE" | wc -l | tr -d ' ')
        HARVESTED_LINES=$(echo "$HARVESTED_CONTENT" | wc -l | tr -d ' ')
        SHRINK_RISK_FILES="${SHRINK_RISK_FILES}  - ${RELATIVE_PATH} (框架 ${CORE_LINES} 行 → 下游 ${HARVESTED_LINES} 行)\n"
    fi

    # ── 展示 diff ──
    printf "\n${BOLD}[CHANGED]${NC} %s\n" "$RELATIVE_PATH"
    if [[ "$CORE_MODIFIED" = true ]]; then
        printf "${RED}[CORE-MODIFIED]${NC} 框架侧此文件有未发布的修改，覆盖需确认\n"
    fi
    if [[ "$SHRINK_RISK" = true ]]; then
        printf "${YELLOW}[RISK]${NC}    框架内容多于下游，覆盖可能导致内容丢失\n"
    fi
    echo "─────────────────────────────────────────"
    DIFF_TMP_A=$(mktemp)
    DIFF_TMP_B=$(mktemp)
    echo "$CURRENT_CORE" > "$DIFF_TMP_A"
    echo "$HARVESTED_CONTENT" > "$DIFF_TMP_B"
    diff --color "$DIFF_TMP_A" "$DIFF_TMP_B" || true
    rm -f "$DIFF_TMP_A" "$DIFF_TMP_B"
    echo "─────────────────────────────────────────"

    if [[ "$APPLY" = true ]]; then
        # 安全网确认：有缩减风险或 core/ 本地修改时逐文件询问
        CONFIRM_NEEDED=false
        if [[ "$SHRINK_RISK" = true ]]; then
            printf "\n${YELLOW}[确认]${NC}   ${RELATIVE_PATH} 的框架内容比下游多，覆盖将丢失部分内容。\n"
            CONFIRM_NEEDED=true
        elif [[ "$CORE_MODIFIED" = true ]]; then
            printf "\n${YELLOW}[确认]${NC}   ${RELATIVE_PATH} 在框架侧有未发布的修改，覆盖将丢失这些修改。\n"
            CONFIRM_NEEDED=true
        fi
        if [[ "$CONFIRM_NEEDED" = true ]]; then
            printf "         继续写入此文件？[y/N] "
            read -r CONFIRM_FILE
            if [[ "$CONFIRM_FILE" != "y" && "$CONFIRM_FILE" != "Y" ]]; then
                warn "跳过：$RELATIVE_PATH"
                continue
            fi
        fi

        # 备份原文件
        mkdir -p "$BACKUP_DIR/$(dirname "$RELATIVE_PATH")"
        cp "$SOURCE_FILE" "$BACKUP_DIR/$RELATIVE_PATH.bak"

        # 写入收割内容
        echo "$HARVESTED_CONTENT" > "$SOURCE_FILE"
        success "已更新：$RELATIVE_PATH"

        # 记录新内容的 hash（用于下次检测 core/ 本地修改）
        NEW_CORE_HASH=$(compute_hash "$HARVESTED_CONTENT")
        batch_write_add "$RELATIVE_PATH" "$NEW_CORE_HASH" "$FRAMEWORK_VERSION"
    fi
done < "$MANAGED_FILES_TEMP"

rm "$MANAGED_FILES_TEMP"

# ─── 提交同步状态 ────────────────────────────────────────────────────────
if [[ "$APPLY" = true ]]; then
    batch_write_commit "$HARVEST_STATE_FILE"
else
    rm -f "$BATCH_WRITE_TEMP" 2>/dev/null || true
fi

# ─── 报告 ─────────────────────────────────────────────────────────────────
header "收割完成"

# marker-only 汇总
if [[ "$MARKER_ONLY_COUNT" -gt 0 ]]; then
    printf "${CYAN}[MARKER-ONLY]${NC} ${MARKER_ONLY_COUNT} 个文件仅有版本号差异（无实际内容变更）：\n\n"
    printf "$MARKER_ONLY_FILES"
    echo ""
    if [[ "$APPLY" = true ]]; then
        info "以上文件 marker 版本号已自动更新为 $FRAMEWORK_VERSION"
    fi
    echo ""
fi

# 缩减风险汇总（dry-run 模式下统一提示）
if [[ "$APPLY" = false ]] && [[ -n "$SHRINK_RISK_FILES" ]]; then
    printf "${YELLOW}[RISK]${NC}    以下文件框架内容多于下游，覆盖有丢失风险：\n\n"
    printf "$SHRINK_RISK_FILES"
    echo ""
fi

# core/ 本地修改汇总
if [[ "$CORE_MODIFIED_COUNT" -gt 0 ]]; then
    printf "${RED}[CORE-MODIFIED]${NC} %d 个文件在框架侧有未发布的修改：\n\n" "$CORE_MODIFIED_COUNT"
    printf "$CORE_MODIFIED_FILES"
    echo ""
    if [[ "$APPLY" = false ]]; then
        warn "收割将覆盖这些未发布的修改，--apply 时会逐文件确认"
    fi
fi

# 实质变更汇总
if [[ "$REAL_CHANGED_COUNT" -gt 0 ]]; then
    if [[ "$APPLY" = true ]]; then
        success "已写入 $REAL_CHANGED_COUNT 个有实质变更的文件"
        info "备份保存至：$BACKUP_DIR"
    else
        warn "发现 $REAL_CHANGED_COUNT 个文件有实质内容差异"
        echo ""
        info "确认无误后，执行以下命令写入 core/："
        echo ""
        printf "  ${BOLD}sh tools/harvest.sh --apply %s${NC}\n" "$PROJECT_DIR"
        echo ""
    fi
else
    if [[ "$MARKER_ONLY_COUNT" -eq 0 ]]; then
        success "所有 $SKIPPED_COUNT 个文件均一致，无需收割"
    else
        success "无实质内容差异（$MARKER_ONLY_COUNT 个 marker-only 变更已跳过展示）"
    fi
fi

# 统计行
echo ""
printf "${BOLD}统计：${NC}一致 %d | marker-only %d | 实质变更 %d | core-修改 %d | 新文件 %d\n" \
    "$SKIPPED_COUNT" "$MARKER_ONLY_COUNT" "$REAL_CHANGED_COUNT" "$CORE_MODIFIED_COUNT" "$NEW_COUNT"

# 新文件提示
if [[ "$NEW_COUNT" -gt 0 ]]; then
    warn "发现 $NEW_COUNT 个新文件（core/ 中无对应）"
    if [[ "$INCLUDE_NEW" != true ]]; then
        info "如需纳入新文件，添加 --include-new 参数"
    fi
fi
