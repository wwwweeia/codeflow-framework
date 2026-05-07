#!/usr/bin/env bash
# upgrade.sh — 升级项目中的框架托管文件
#
# 用法（在项目目录执行）：
#   cd ai-lingzhi
#   bash ../h-codeflow-framework/tools/upgrade.sh
#   bash ../h-codeflow-framework/tools/upgrade.sh --dry-run        # 预览变化，不写入
#   bash ../h-codeflow-framework/tools/upgrade.sh --dry-run --diff # 预览并显示详细 diff
#   bash ../h-codeflow-framework/tools/upgrade.sh --force          # 跳过冲突检测，强制覆盖
#   bash ../h-codeflow-framework/tools/upgrade.sh --conflict=preserve # 跳过有冲突的文件
#   bash ../h-codeflow-framework/tools/upgrade.sh --conflict=fail  # 有冲突时退出（CI 用）
#
# 功能：
# 1. 自动查找本项目 .claude/ 下所有包含 "h-codeflow-framework:core" marker 的文件
# 2. 从 ../h-codeflow-framework/core/ 复制对应的源文件
# 3. 保留 marker 下方的用户自定义内容
# 4. 检测下游 marker 上方的本地修改，防止静默覆盖
# 5. 备份原文件（如变更）
# 6. 记录同步状态（内容指纹），用于下次冲突检测

set -euo pipefail

# ─── 加载通用函数库 ────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/sync-common.sh"

# ─── 参数解析 ───────────────────────────────────────────────────────────────
DRY_RUN=false
SHOW_DIFF=false
FORCE=false
CONFLICT_MODE=""  # 空=默认(备份+覆盖), preserve=跳过冲突文件, fail=遇到冲突退出
for arg in "$@"; do
    case "$arg" in
        --dry-run)            DRY_RUN=true ;;
        --diff)               SHOW_DIFF=true ;;
        --force)              FORCE=true ;;
        --conflict=preserve)  CONFLICT_MODE="preserve" ;;
        --conflict=fail)      CONFLICT_MODE="fail" ;;
    esac
done

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

# ─── 路径设置 ───────────────────────────────────────────────────────────────
FRAMEWORK_ROOT="$(dirname "$SCRIPT_DIR")"
FRAMEWORK_CORE="$FRAMEWORK_ROOT/core"
PROJECT_ROOT="$(pwd)"
PROJECT_CLAUDE="$PROJECT_ROOT/.claude"

if $DRY_RUN; then
    header "升级框架文件（DRY-RUN 预览模式，不会写入任何内容）"
else
    header "升级框架文件"
fi

# ─── 验证路径 ───────────────────────────────────────────────────────────────
if [[ ! -d "$FRAMEWORK_CORE" ]]; then
    error "框架 core 目录不存在：$FRAMEWORK_CORE"
    exit 1
fi

if [[ ! -d "$PROJECT_CLAUDE" ]]; then
    error "项目 .claude 目录不存在：$PROJECT_CLAUDE"
    exit 1
fi

info "框架根目录：$FRAMEWORK_ROOT"
info "项目根目录：$PROJECT_ROOT"

# 同步状态文件
SYNC_STATE_DIR="$PROJECT_CLAUDE/.sync-state"
SYNC_STATE_FILE="$SYNC_STATE_DIR/sync-state.csv"

# ─── 拉取框架最新代码 ─────────────────────────────────────────────────────
header "拉取框架最新版本"

CURRENT_DIR="$(pwd)"
cd "$FRAMEWORK_ROOT"

if git rev-parse --is-inside-work-tree &>/dev/null; then
    # 支持指定分支：FRAMEWORK_BRANCH=exp/xxx sh upgrade.sh
    if [[ -n "${FRAMEWORK_BRANCH:-}" ]]; then
        info "切换到指定分支：$FRAMEWORK_BRANCH"
        git checkout "$FRAMEWORK_BRANCH"
    fi

    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    info "当前框架分支：$CURRENT_BRANCH"

    if git remote -v | grep -q origin; then
        info "正在从远程拉取最新代码..."
        if git pull origin "$CURRENT_BRANCH" 2>&1; then
            success "框架代码已更新到最新版本"
        else
            warn "拉取远程代码失败，将使用本地版本继续升级"
        fi
    else
        warn "框架仓库未配置远程仓库，使用本地版本"
    fi
else
    warn "框架目录不是 Git 仓库，使用本地版本"
fi

# 读取框架版本
if [[ -f "$FRAMEWORK_ROOT/tools/VERSION" ]]; then
    FRAMEWORK_VERSION=$(cat "$FRAMEWORK_ROOT/tools/VERSION")
    info "框架版本：$FRAMEWORK_VERSION"
fi

cd "$CURRENT_DIR"

# ─── 查找所有需要更新的文件 ───────────────────────────────────────────────
header "扫描需要更新的文件"

MANAGED_FILES_TEMP=$(mktemp)
grep -r "<!-- h-codeflow-framework:core" "$PROJECT_CLAUDE" --include="*.md" --include="*.sh" --include="*.yaml" --include="*.yml" 2>/dev/null | cut -d: -f1 | sort -u > "$MANAGED_FILES_TEMP" || true

MANAGED_COUNT=$(wc -l < "$MANAGED_FILES_TEMP" | tr -d ' ')

if [[ "$MANAGED_COUNT" -eq 0 ]]; then
    warn "未发现需要更新的文件"
    rm "$MANAGED_FILES_TEMP"
    exit 0
fi

info "发现 $MANAGED_COUNT 个需要更新的文件"

# ─── 备份与更新 ───────────────────────────────────────────────────────────
BACKUP_DIR="$PROJECT_CLAUDE/.backup/upgrade-$(date +%Y%m%d-%H%M%S)"

UPDATED_COUNT=0
SKIPPED_COUNT=0
CONFLICT_COUNT=0
LOCAL_BACKUP_COUNT=0
CONFLICT_FILES=""

# 初始化批量 hash 写入
batch_write_init

while IFS= read -r TARGET_FILE; do
    [[ -z "$TARGET_FILE" ]] && continue

    RELATIVE_PATH="${TARGET_FILE#$PROJECT_CLAUDE/}"
    SOURCE_FILE="$FRAMEWORK_CORE/$RELATIVE_PATH"

    if [[ ! -f "$SOURCE_FILE" ]]; then
        warn "源文件不存在，跳过：$SOURCE_FILE"
        continue
    fi

    # 查找 marker 行号
    MARKER_LINE=$(grep -n "<!-- h-codeflow-framework:core" "$TARGET_FILE" | head -1 | cut -d: -f1)

    if [[ -z "$MARKER_LINE" ]]; then
        warn "未找到 marker，跳过：$RELATIVE_PATH"
        continue
    fi

    # 提取源文件的 marker 前内容
    SOURCE_MARKER_LINE=$(grep -n "<!-- h-codeflow-framework:core" "$SOURCE_FILE" | head -1 | cut -d: -f1)

    if [[ -z "$SOURCE_MARKER_LINE" ]]; then
        error "源文件缺少 marker，跳过：$SOURCE_FILE"
        continue
    fi

    # ── 冲突检测：检查下游 marker 上方是否有本地修改 ──
    LOCAL_MODIFIED=false
    if ! $FORCE; then
        LAST_HASH=$(read_hash "$SYNC_STATE_FILE" "$RELATIVE_PATH")
        if [[ -n "$LAST_HASH" ]]; then
            CURRENT_ABOVE_HASH=$(compute_file_hash "$TARGET_FILE" "$MARKER_LINE")
            if [[ "$CURRENT_ABOVE_HASH" != "$LAST_HASH" ]]; then
                LOCAL_MODIFIED=true
            fi
        fi
    fi

    if $LOCAL_MODIFIED; then
        if [[ "$CONFLICT_MODE" == "fail" ]]; then
            error "检测到本地修改（冲突模式: fail）：${RELATIVE_PATH}"
            error "请先收割本地修改（harvest.sh）或使用 --force 覆盖"
            exit 1
        elif [[ "$CONFLICT_MODE" == "preserve" ]]; then
            warn "跳过（有本地修改）：${RELATIVE_PATH}"
            CONFLICT_COUNT=$((CONFLICT_COUNT + 1))
            CONFLICT_FILES="${CONFLICT_FILES}  - ${RELATIVE_PATH}\n"
            continue
        else
            # 默认：备份本地版本，继续覆盖
            warn "检测到本地修改：${RELATIVE_PATH}（将备份本地版本后覆盖）"
        fi
    fi

    # 提取目标文件的 marker 下方内容
    USER_CONTENT=$(tail -n "+$((MARKER_LINE + 1))" "$TARGET_FILE" 2>/dev/null || echo "")

    # 提取源文件的 marker 前内容（包括 marker）
    SOURCE_CONTENT=$(head -n "$SOURCE_MARKER_LINE" "$SOURCE_FILE")

    # 注入当前框架版本号到 marker（防止 core/ 源文件版本滞后导致振荡）
    if [[ -n "${FRAMEWORK_VERSION:-}" ]]; then
        SOURCE_CONTENT=$(echo "$SOURCE_CONTENT" | sed "s/h-codeflow-framework:core v[^ ]*/h-codeflow-framework:core v${FRAMEWORK_VERSION}/")
    fi

    # 生成合并后的新内容
    NEW_CONTENT=$(
        echo "$SOURCE_CONTENT"
        if [[ -n "$USER_CONTENT" ]]; then
            echo "$USER_CONTENT"
        fi
    )

    # 比较新旧内容，仅在有变化时才更新
    CURRENT_CONTENT=$(cat "$TARGET_FILE")
    if [[ "$NEW_CONTENT" = "$CURRENT_CONTENT" ]]; then
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))

        # 记录 hash（用于下次冲突检测）
        SKIP_ABOVE_HASH=$(compute_file_hash "$TARGET_FILE" "$MARKER_LINE")
        batch_write_add "$RELATIVE_PATH" "$SKIP_ABOVE_HASH" "${FRAMEWORK_VERSION:-unknown}"
        continue
    fi

    if $SHOW_DIFF; then
        printf "${YELLOW}[DIFF]${NC}   %s\n" "$RELATIVE_PATH"
        diff <(echo "$CURRENT_CONTENT") <(echo "$NEW_CONTENT") || true
        echo ""
    fi

    if $DRY_RUN; then
        $SHOW_DIFF || printf "${YELLOW}[DIFF]${NC}   %s\n" "$RELATIVE_PATH"
    else
        # 备份原文件
        mkdir -p "$BACKUP_DIR"
        cp "$TARGET_FILE" "$BACKUP_DIR/$(basename "$TARGET_FILE").bak"

        # 有本地修改时额外备份 .local 副本
        if $LOCAL_MODIFIED; then
            cp "$TARGET_FILE" "$BACKUP_DIR/$(basename "$TARGET_FILE").local"
            LOCAL_BACKUP_COUNT=$((LOCAL_BACKUP_COUNT + 1))
            CONFLICT_COUNT=$((CONFLICT_COUNT + 1))
            CONFLICT_FILES="${CONFLICT_FILES}  - ${RELATIVE_PATH}\n"
        fi

        # 写入更新内容
        echo "$NEW_CONTENT" > "$TARGET_FILE"

        success "已更新：$RELATIVE_PATH"
    fi

    # 记录新内容的 hash（用于下次冲突检测）
    NEW_ABOVE_HASH=$(compute_hash "$SOURCE_CONTENT")
    batch_write_add "$RELATIVE_PATH" "$NEW_ABOVE_HASH" "${FRAMEWORK_VERSION:-unknown}"

    UPDATED_COUNT=$((UPDATED_COUNT + 1))
done < "$MANAGED_FILES_TEMP"

rm "$MANAGED_FILES_TEMP"

# ─── 提交同步状态 ────────────────────────────────────────────────────────
if ! $DRY_RUN; then
    batch_write_commit "$SYNC_STATE_FILE"
else
    rm -f "$BATCH_WRITE_TEMP" 2>/dev/null || true
fi

# ─── 冲突汇总 ────────────────────────────────────────────────────────────
if [[ "$CONFLICT_COUNT" -gt 0 ]]; then
    echo ""
    printf "${YELLOW}════════════════════════════════════════${NC}\n"
    printf "${YELLOW}⚠  以下 %d 个文件存在本地修改：${NC}\n" "$CONFLICT_COUNT"
    printf "$CONFLICT_FILES"
    echo ""
    if [[ "$CONFLICT_MODE" == "preserve" ]]; then
        printf "${CYAN}这些文件已跳过升级，本地修改已保留。${NC}\n"
        printf "如需升级，可先收割本地修改（harvest.sh）或使用 --force 覆盖。\n"
    else
        printf "${CYAN}本地修改已备份至：${NC}\n"
        printf "  %s/\n" "$BACKUP_DIR"
        echo ""
        printf "合并建议：\n"
        printf "  1. 对比 .local 文件与当前文件，决定是否恢复部分本地修改\n"
        printf "  2. 如本地改进值得保留，联系 AI 基础设施组执行 harvest.sh\n"
    fi
    printf "${YELLOW}════════════════════════════════════════${NC}\n"
fi

# ─── 基于 MANIFEST 同步新增文件 ──────────────────────────────────────────
header "基于 MANIFEST 同步新增文件"

NEW_COUNT=0

if [[ -f "$FRAMEWORK_CORE/MANIFEST" ]]; then
    # 读取 MANIFEST 中所有文件（展开 skill 目录为具体文件）
    while IFS= read -r manifest_entry; do
        [[ -z "$manifest_entry" ]] && continue

        TARGET_PATH="$PROJECT_CLAUDE/$manifest_entry"

        if [[ -d "$FRAMEWORK_CORE/$manifest_entry" ]]; then
            # skill 目录：检查目录是否存在
            if [[ ! -d "$TARGET_PATH" ]]; then
                if $DRY_RUN; then
                    printf "${YELLOW}[NEW]${NC}    新增 skill（未写入）：$manifest_entry\n"
                else
                    cp -r "$FRAMEWORK_CORE/$manifest_entry" "$TARGET_PATH"
                    success "新增 skill：$manifest_entry"
                fi
                NEW_COUNT=$((NEW_COUNT + 1))
            else
                # skill 目录已存在：同步 core 中有 marker 但下游缺失/未纳管的文件
                while IFS= read -r -d '' CORE_FILE; do
                    REL="${CORE_FILE#$FRAMEWORK_CORE/}"
                    DST="$PROJECT_CLAUDE/$REL"
                    if [[ ! -f "$DST" ]] && grep -q "<!-- h-codeflow-framework:core" "$CORE_FILE" 2>/dev/null; then
                        # 下游不存在且 core 有 marker → 新增
                        if $DRY_RUN; then
                            printf "${YELLOW}[NEW]${NC}    新增文件（未写入）：$REL\n"
                        else
                            mkdir -p "$(dirname "$DST")"
                            cp "$CORE_FILE" "$DST"
                            success "新增文件：$REL"
                        fi
                        NEW_COUNT=$((NEW_COUNT + 1))
                    elif ! grep -q "<!-- h-codeflow-framework:core" "$DST" 2>/dev/null && grep -q "<!-- h-codeflow-framework:core" "$CORE_FILE" 2>/dev/null; then
                        # 下游无 marker 但 core 有 marker → 用 core 版本覆盖（纳入框架管理）
                        if $DRY_RUN; then
                            printf "${YELLOW}[SYNC]${NC}   纳管文件（未写入）：$REL\n"
                        else
                            cp "$CORE_FILE" "$DST"
                            success "纳管文件：$REL"
                        fi
                        NEW_COUNT=$((NEW_COUNT + 1))
                    fi
                done < <(find "$FRAMEWORK_CORE/$manifest_entry" -type f -print0)
            fi
        elif [[ -f "$FRAMEWORK_CORE/$manifest_entry" ]]; then
            # 单文件：检查文件是否存在
            if [[ ! -f "$TARGET_PATH" ]]; then
                if $DRY_RUN; then
                    printf "${YELLOW}[NEW]${NC}    新增文件（未写入）：$manifest_entry\n"
                else
                    mkdir -p "$(dirname "$TARGET_PATH")"
                    cp "$FRAMEWORK_CORE/$manifest_entry" "$TARGET_PATH"
                    success "新增文件：$manifest_entry"
                fi
                NEW_COUNT=$((NEW_COUNT + 1))
            fi
        fi
    done < <(read_manifest "$FRAMEWORK_CORE" "")
else
    warn "未找到 MANIFEST，跳过新增文件检测"
fi

if [[ "$NEW_COUNT" -gt 0 ]]; then
    if $DRY_RUN; then
        info "将新增 $NEW_COUNT 个文件/skill（dry-run，未写入）"
    else
        success "新增了 $NEW_COUNT 个文件/skill"
    fi
else
    info "无新增文件"
fi

# ─── 孤儿文件检测（下游有 marker 但不在 MANIFEST 中）─────────────────────
header "孤儿文件检测"

ORPHAN_COUNT=0
ORPHAN_FILES=""

if [[ -f "$FRAMEWORK_CORE/MANIFEST" ]]; then
    while IFS= read -r TARGET_FILE; do
        [[ -z "$TARGET_FILE" ]] && continue
        RELATIVE_PATH="${TARGET_FILE#$PROJECT_CLAUDE/}"

        if ! is_in_manifest "$FRAMEWORK_CORE" "$RELATIVE_PATH"; then
            ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
            ORPHAN_FILES="${ORPHAN_FILES}  - ${RELATIVE_PATH}\n"
        fi
    done < <(grep -rl "<!-- h-codeflow-framework:core" "$PROJECT_CLAUDE" --include="*.md" --include="*.sh" --include="*.yaml" --include="*.yml" 2>/dev/null | sort -u)
fi

if [[ "$ORPHAN_COUNT" -gt 0 ]]; then
    echo ""
    printf "${YELLOW}════════════════════════════════════════${NC}\n"
    printf "${YELLOW}⚠  发现 %d 个孤儿文件（有 marker 但不在 MANIFEST 中）：${NC}\n" "$ORPHAN_COUNT"
    printf "$ORPHAN_FILES"
    echo ""
    printf "${CYAN}这些文件曾属于框架管理，但已从 core/MANIFEST 中移除。${NC}\n"
    printf "建议：\n"
    printf "  1. 确认这些文件确实不再需要，手动删除\n"
    printf "  2. 如需保留为项目特有文件，移除其中的 marker 行\n"
    printf "${YELLOW}════════════════════════════════════════${NC}\n"
else
    info "无孤儿文件"
fi

if $DRY_RUN; then
    header "预览完成（DRY-RUN，未写入任何文件）"
    if [[ "$UPDATED_COUNT" -gt 0 ]]; then
        warn "有 $UPDATED_COUNT 个文件将被更新，$SKIPPED_COUNT 个文件无变化"
        info "确认无误后，去掉 --dry-run 参数重新执行以应用变更"
    else
        success "所有 $SKIPPED_COUNT 个文件均已是最新，无需更新"
    fi
else
    header "升级完成"
    if [[ "$UPDATED_COUNT" -gt 0 ]]; then
        success "更新了 $UPDATED_COUNT 个文件，跳过 $SKIPPED_COUNT 个未变化文件"
        info "备份保存至：$BACKUP_DIR"
    else
        success "所有 $SKIPPED_COUNT 个文件均已是最新，无需更新"
        # 无文件更新时清理空备份目录
        [[ -d "$BACKUP_DIR" ]] && rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi
fi

