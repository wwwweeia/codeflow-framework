#!/usr/bin/env bash
# sync-mirror.sh — 将 h-codeflow-framework 同步到公开镜像仓库
# 用法:
#   bash tools/sync-mirror.sh <target-dir>           # 预览模式（dry-run）
#   bash tools/sync-mirror.sh --apply <target-dir>   # 实际同步
set -euo pipefail

APPLY=false
TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply) APPLY=true; shift ;;
        --dry-run) APPLY=false; shift ;;
        --help|-h)
            echo "用法: bash tools/sync-mirror.sh [--apply] <target-dir>"
            echo ""
            echo "将框架内容同步到公开镜像仓库。"
            echo "默认 dry-run 模式（只预览），加 --apply 实际执行。"
            exit 0
            ;;
        -*) echo "未知选项: $1"; exit 1 ;;
        *) TARGET="$1"; shift ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    echo "错误: 请指定目标目录"
    echo "用法: bash tools/sync-mirror.sh [--apply] <target-dir>"
    exit 1
fi

if [[ ! -d "$TARGET/.git" ]]; then
    echo "错误: $TARGET 不是 git 仓库"
    exit 1
fi

FRAMEWORK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RSYNC_OPTS=(
    -av --delete
    --itemize-changes
)

if [[ "$APPLY" == "false" ]]; then
    RSYNC_OPTS+=(--dry-run)
fi

# GitHub 独有文件（保留）
EXCLUDE_GITHUB=(
    --exclude="README.md"
    --exclude="LICENSE"
    --exclude="CONTRIBUTING.md"
    --exclude="MIGRATION.md"
    --exclude=".github/"
    --exclude=".gitattributes"
)

# 敏感文件（含内部服务地址或 @huaun/ 包引用）
EXCLUDE_SENSITIVE=(
    --exclude="core/context/coding_frontend_shared.md"
    --exclude="core/skills/frontend-ui-design/"
    --exclude="core/skills/framework-feedback/"
    --exclude="core/skills/jira-task-management/SKILL.md"
    --exclude="templates/mcp-config.json.template"
)

# 内部内容（不适合公开仓库）
EXCLUDE_INTERNAL=(
    --exclude="docs/sharing/"
    --exclude="docs/superpowers/"
    --exclude="docs/temporary/"
)

# 构建产物和 IDE 文件
EXCLUDE_BUILD=(
    --exclude="node_modules/"
    --exclude=".idea/"
    --exclude="public/"
    --exclude=".DS_Store"
    --exclude=".backup/"
    --exclude=".claude/"
    --exclude=".mcp.json"
    --exclude=".sync-state/"
)

# 只同步这些顶层目录/文件
INCLUDE_TARGETS=(
    core/
    tools/
    templates/
    docs/
    demo/
    CHANGELOG.md
    CLAUDE.md
)

echo "=== sync-mirror.sh ==="
echo "源: $FRAMEWORK_DIR"
echo "目标: $TARGET"
echo "模式: $([ "$APPLY" == "true" ] && echo "执行" || echo "预览（dry-run）")"
echo ""

# 构造 rsync 过滤规则：先排除所有，再包含目标
FILTER_RULES=()
for target in "${INCLUDE_TARGETS[@]}"; do
    FILTER_RULES+=(--include="/$target")
done
FILTER_RULES+=(--exclude="/*")

echo "--- 同步内容 ---"
for target in "${INCLUDE_TARGETS[@]}"; do
    if [[ -e "$FRAMEWORK_DIR/$target" ]]; then
        echo "  $target"
    fi
done

echo ""
echo "--- 排除敏感文件 ---"
for rule in "${EXCLUDE_SENSITIVE[@]}"; do
    [[ "$rule" == --exclude=* ]] && echo "  ${rule#--exclude=}"
done

echo ""
echo "--- 排除内部内容 ---"
for rule in "${EXCLUDE_INTERNAL[@]}"; do
    [[ "$rule" == --exclude=* ]] && echo "  ${rule#--exclude=}"
done

echo ""
echo "--- 保留 GitHub 独有文件 ---"
for rule in "${EXCLUDE_GITHUB[@]}"; do
    [[ "$rule" == --exclude=* ]] && echo "  ${rule#--exclude=}"
done

echo ""
echo "--- rsync 输出 ---"
echo ""

rsync "${RSYNC_OPTS[@]}" \
    "${EXCLUDE_GITHUB[@]}" \
    "${EXCLUDE_SENSITIVE[@]}" \
    "${EXCLUDE_INTERNAL[@]}" \
    "${EXCLUDE_BUILD[@]}" \
    "${FILTER_RULES[@]}" \
    "$FRAMEWORK_DIR/" "$TARGET/"

echo ""
if [[ "$APPLY" == "false" ]]; then
    echo "=== 以上为预览，未实际写入 ==="
    echo "确认无误后执行: bash tools/sync-mirror.sh --apply $TARGET"
else
    echo "=== 同步完成 ==="
    echo "下一步:"
    echo "  cd $TARGET"
    echo "  git add -A"
    echo '  git commit -m "sync: 从 h-codeflow-framework 同步 $(cat tools/VERSION)"'
    echo "  git push origin main"
fi
