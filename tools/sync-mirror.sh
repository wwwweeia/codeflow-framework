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

# 敏感文件（含内部服务地址或 @your-org/ 包引用）
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
echo "--- 脱敏替换 ---"
echo ""

# 脱敏：将内部标识替换为通用占位符
# 顺序很重要：长模式在前，避免部分匹配被短模式吞掉
SANITIZE_SED=(
    -e 's|https://gitlab\.huaun\.com/rd\.huaun/h-codeflow-framework|https://github.com/wwwweeia/codeflow-framework|g'
    -e 's|git@gitlab\.huaun\.com:rd\.huaun/h-codeflow-framework\.git|git@github.com:wwwweeia/codeflow-framework.git|g'
    -e 's|gitlab\.huaun\.com/rd\.huaun/h-codeflow-framework/-/edit/develop/docs/:path|github.com/wwwweeia/codeflow-framework/edit/main/docs/:path|g'
    -e 's|gitlab\.huaun\.com|gitlab.example.com|g'
    -e 's|jira\.huaun\.com|jira.example.com|g'
    -e 's|wiki\.huaun\.com|wiki.example.com|g'
    -e 's|北京华云安信息技术有限公司|CodeFlow Contributors|g'
    -e 's|@huaun/vul-ui|@your-org/ui-lib|g'
    -e 's|@huaun/|@your-org/|g'
    -e 's|com/huaun/aikg/|com/example/project/|g'
    -e 's|com\.huaun\.aikg|com.example.project|g'
    -e 's|ai-lingzhi|your-project|g'
    -e 's|ai-kg-agent-hub|backend-service|g'
    -e 's|192\.168\.104\.125|docs.example.com|g'
    -e 's|SAIKG-|PROJECT-|g'
    -e 's|huaun-codeflow-framework|h-codeflow-framework|g'
    -e "s|window\.dispatchEvent('huaun:|window.dispatchEvent('app:|g"
    -e "s|text: 'GitLab'|text: 'GitHub'|g"
)

SANITIZE_FILES=$(find "$TARGET" -type f \( -name '*.md' -o -name '*.ts' -o -name '*.sh' -o -name '*.json' -o -name '*.yml' \) \
    ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/.vitepress/cache/*' ! -path '*/public/*')

if [[ "$APPLY" == "true" ]]; then
    echo "$SANITIZE_FILES" | while read -r file; do
        [[ -z "$file" ]] && continue
        sed -i '' "${SANITIZE_SED[@]}" "$file"
    done
    echo "✓ 脱敏替换已执行"
else
    COUNT=0
    echo "$SANITIZE_FILES" | while read -r file; do
        [[ -z "$file" ]] && continue
        MATCHES=$(sed "${SANITIZE_SED[@]}" "$file" | diff "$file" - 2>/dev/null | grep -c '^[<>]' || true)
        if [[ "$MATCHES" -gt 0 ]]; then
            echo "  $(basename "$file"): ${MATCHES} 行变更"
        fi
    done
    echo "（dry-run 模式，未实际替换）"
fi

echo ""
if [[ "$APPLY" == "false" ]]; then
    echo "=== 以上为预览，未实际写入 ==="
    echo "确认无误后执行: bash tools/sync-mirror.sh --apply $TARGET"
else
    echo "=== 同步 + 脱敏完成 ==="
    echo "下一步:"
    echo "  cd $TARGET"
    echo "  git add -A"
    echo '  git commit -m "sync: 从 h-codeflow-framework 同步 $(cat tools/VERSION)"'
    echo "  git push origin main"
fi
