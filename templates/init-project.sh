#!/usr/bin/env bash
# init-project.sh — 初始化新项目的框架结构
#
# 用法（在新项目目录执行）：
#   cd new-project
#   sh ../h-codeflow-framework/templates/init-project.sh . "Project Name"
#
# 参数：
#   $1: 项目根目录（通常为 .）
#   $2: 项目名称（用于文档中的项目标识）
#   $3: 初始化级别（可选，默认 full）
#       - level1: 最小化（Intake + 轻量流程，适合首次接触框架的团队）
#       - level2: 标准化（+ PM + Arch 角色分离）
#       - level3: 专业级（+ Dev/FE 两阶段自查 + QA 独立审查）
#       - level4/full: 完整版（+ Prototype + E2E + Jira 集成）
#
# 功能：
# 1. 创建 .claude 目录结构（agents, rules, skills, context, specs, codemap）
# 2. 根据初始化级别从框架 core/ 复制对应文件（含 marker）
# 3. 从 templates/ 复制项目模板文件并调整项目名称
# 4. 输出初始化清单和下一步指导
#
# 用法示例：
#   sh init-project.sh . "My Project"              # 完整版（默认）
#   sh init-project.sh . "My Project" level1       # 最小化
#   sh init-project.sh . "My Project" level2       # 标准化

set -euo pipefail

# ─── 颜色输出 ───────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { printf "${BLUE}[INFO]${NC}   %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}     %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}   %s\n" "$1"; }
error()   { printf "${RED}[ERROR]${NC}  %s\n" "$1"; }
header()  { printf "\n${BOLD}${CYAN}═══ %s ═══${NC}\n\n" "$1"; }

# ─── 参数验证 ───────────────────────────────────────────────────────────────
PROJECT_DIR="${1:-.}"
PROJECT_NAME="${2:-unknown-project}"
INIT_LEVEL="${3:-full}"

PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || { error "项目目录不存在：$1"; exit 1; }

# ─── 路径设置（提前，供后续检测使用）──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_ROOT="$(dirname "$SCRIPT_DIR")"
FRAMEWORK_CORE="$FRAMEWORK_ROOT/core"
FRAMEWORK_TEMPLATES="$SCRIPT_DIR"

# ─── 防止在框架内部执行 ───────────────────────────────────────────────────────
# 初始化脚本面向下游项目，在框架自身目录执行毫无意义且会污染 core/
if [[ "$PROJECT_DIR" == "$FRAMEWORK_ROOT" ]] || [[ "$PROJECT_DIR" == "$FRAMEWORK_ROOT/"* ]]; then
    error "不能在框架目录内执行初始化"
    error "请在目标项目目录中运行，例如："
    error "  cd /path/to/your-project"
    error "  bash ../h-codeflow-framework/templates/init-project.sh . \"Project Name\""
    exit 1
fi

# ─── 标准化级别参数 ─────────────────────────────────────────────────────────
case "$INIT_LEVEL" in
    level1|minimal)  INIT_LEVEL="level1" ;;
    level2|standard) INIT_LEVEL="level2" ;;
    level3|pro)      INIT_LEVEL="level3" ;;
    level4|full)     INIT_LEVEL="full" ;;
    *)               error "未知初始化级别：${INIT_LEVEL}（可选：level1/level2/level3/full）"; exit 1 ;;
esac

header "初始化项目：$PROJECT_NAME"

info "项目目录：$PROJECT_DIR"
info "项目名称：$PROJECT_NAME"
info "框架目录：$FRAMEWORK_ROOT"
info "初始化级别：$INIT_LEVEL"

# ─── 加载同步工具库 ─────────────────────────────────────────────────────────
source "$FRAMEWORK_ROOT/tools/lib/sync-common.sh"

# 验证 MANIFEST 存在
if [[ ! -f "$FRAMEWORK_CORE/MANIFEST" ]]; then
    error "框架 MANIFEST 不存在：$FRAMEWORK_CORE/MANIFEST"
    exit 1
fi

# ─── 从 MANIFEST 读取文件列表（按 level 筛选）─────────────────────────────────
# read_manifest 返回三类条目：
#   文件条目（如 agents/pm-agent.md）→ 直接复制
#   目录条目（如 skills/domain-ontology）→ 整个目录复制
# 分类处理
AGENTS_TO_COPY=""
SKILLS_TO_COPY=""
COMMANDS_TO_COPY=""
OTHER_FILES=""  # rules/context/codemap 等 core 级别文件

while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue

    if [[ "$entry" == agents/* ]]; then
        AGENTS_TO_COPY="$AGENTS_TO_COPY $entry"
    elif [[ "$entry" == skills/* ]]; then
        # skill 条目是目录名（如 skills/domain-ontology）
        SKILLS_TO_COPY="$SKILLS_TO_COPY $entry"
    elif [[ "$entry" == commands/* ]]; then
        COMMANDS_TO_COPY="$COMMANDS_TO_COPY $entry"
    else
        OTHER_FILES="$OTHER_FILES $entry"
    fi
done < <(read_manifest "$FRAMEWORK_CORE" "$INIT_LEVEL")

# 去重
AGENTS_TO_COPY=$(echo "$AGENTS_TO_COPY" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ')
SKILLS_TO_COPY=$(echo "$SKILLS_TO_COPY" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ')
COMMANDS_TO_COPY=$(echo "$COMMANDS_TO_COPY" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ')

# ─── 验证框架存在 ───────────────────────────────────────────────────────────
if [[ ! -d "$FRAMEWORK_CORE" ]]; then
    error "框架 core 目录不存在：$FRAMEWORK_CORE"
    exit 1
fi

success "框架已验证"

# ─── 创建目录结构 ───────────────────────────────────────────────────────────
header "创建 .claude 目录结构"

mkdir -p "$PROJECT_DIR/.claude"/{agents,rules,skills,context,specs,codemap,.sync-state}

success "目录结构已创建：
  .claude/
  ├── agents/
  ├── rules/
  ├── skills/
  ├── context/
  ├── specs/
  ├── codemap/
  └── .sync-state/"

# ─── 复制框架文件 ───────────────────────────────────────────────────────────
header "复制框架托管文件（级别：${INIT_LEVEL}）"

COPIED_COUNT=0

# 复制 agents/（根据级别选择性复制）
mkdir -p "$PROJECT_DIR/.claude/agents"
if [[ -n "$AGENTS_TO_COPY" ]]; then
    for agent in $AGENTS_TO_COPY; do
        local_name=$(basename "$agent")
        if [[ -f "$FRAMEWORK_CORE/$agent" ]]; then
            cp "$FRAMEWORK_CORE/$agent" "$PROJECT_DIR/.claude/agents/$local_name"
            COPIED_COUNT=$((COPIED_COUNT + 1))
            info "  Agent: $local_name"
        else
            warn "  Agent 不存在: $agent"
        fi
    done
fi

# 复制 skills/（根据级别选择性复制，MANIFEST 列出目录名）
if [[ -n "$SKILLS_TO_COPY" ]]; then
    for skill_dir in $SKILLS_TO_COPY; do
        skill_name=$(echo "$skill_dir" | sed 's|^skills/||')
        if [[ -d "$FRAMEWORK_CORE/skills/$skill_name" ]]; then
            cp -r "$FRAMEWORK_CORE/skills/$skill_name" "$PROJECT_DIR/.claude/skills/"
            COPIED_COUNT=$((COPIED_COUNT + 1))
            info "  Skill: $skill_name"
        else
            warn "  Skill 不存在: $skill_name"
        fi
    done
fi

# 复制 commands/（根据级别选择性复制）
mkdir -p "$PROJECT_DIR/.claude/commands"
if [[ -n "$COMMANDS_TO_COPY" ]]; then
    for cmd in $COMMANDS_TO_COPY; do
        local_name=$(basename "$cmd")
        if [[ -f "$FRAMEWORK_CORE/$cmd" ]]; then
            cp "$FRAMEWORK_CORE/$cmd" "$PROJECT_DIR/.claude/commands/$local_name"
            COPIED_COUNT=$((COPIED_COUNT + 1))
            info "  Command: $local_name"
        fi
    done
fi

# 复制其他 core 级别文件（rules/context/codemap）
if [[ -n "$OTHER_FILES" ]]; then
    for entry in $OTHER_FILES; do
        target_dir="$PROJECT_DIR/.claude/$(dirname "$entry")"
        mkdir -p "$target_dir"
        if [[ -f "$FRAMEWORK_CORE/$entry" ]]; then
            cp "$FRAMEWORK_CORE/$entry" "$PROJECT_DIR/.claude/$entry"
            COPIED_COUNT=$((COPIED_COUNT + 1))
            info "  $(basename "$entry")"
        else
            warn "  文件不存在: $entry"
        fi
    done
fi

success "已复制 $COPIED_COUNT+ 个框架文件"

# ─── 复制模板文件并调整项目名称 ───────────────────────────────────────────
header "复制项目模板文件"

if [[ -f "$FRAMEWORK_TEMPLATES/CLAUDE.md.template" ]]; then
    if [[ -f "$PROJECT_DIR/CLAUDE.md" ]]; then
        info "CLAUDE.md 已存在，跳过（如需重置请先删除）"
    else
        sed "s/\${PROJECT_NAME}/$PROJECT_NAME/g" "$FRAMEWORK_TEMPLATES/CLAUDE.md.template" \
            > "$PROJECT_DIR/CLAUDE.md"
        success "已创建 CLAUDE.md"
    fi
fi

# 复制共享编码规范到根目录 .claude/rules/（子项目规则文件会引用这些）
for tpl in coding_frontend_shared.md.template coding_backend.md.template; do
    if [[ -f "$FRAMEWORK_TEMPLATES/$tpl" ]]; then
        target_name="${tpl%.template}"
        if [[ -f "$PROJECT_DIR/.claude/rules/$target_name" ]]; then
            info "$target_name 已存在，跳过（如需重置请先删除）"
        else
            sed "s/\${PROJECT_NAME}/$PROJECT_NAME/g" "$FRAMEWORK_TEMPLATES/$tpl" \
                > "$PROJECT_DIR/.claude/rules/$target_name"
            success "已创建 .claude/rules/$target_name"
        fi
    fi
done

# ─── 复制 MCP 配置模板 ──────────────────────────────────────────────────
if [[ -f "$FRAMEWORK_TEMPLATES/mcp-config.json.template" ]]; then
    if [[ -f "$PROJECT_DIR/.mcp.json" ]]; then
        info ".mcp.json 已存在，跳过（如需重置请先删除）"
    else
        cp "$FRAMEWORK_TEMPLATES/mcp-config.json.template" "$PROJECT_DIR/.mcp.json"
        # 确保 .mcp.json 和 .backup 在 .gitignore 中
        if [[ -f "$PROJECT_DIR/.gitignore" ]]; then
            grep -qxF '.mcp.json' "$PROJECT_DIR/.gitignore" 2>/dev/null || echo '.mcp.json' >> "$PROJECT_DIR/.gitignore"
            grep -qxF '.claude/.backup/' "$PROJECT_DIR/.gitignore" 2>/dev/null || echo '.claude/.backup/' >> "$PROJECT_DIR/.gitignore"
        fi
        warn "已创建 .mcp.json（MCP 配置模板）——请编辑填写 Jira/Confluence 凭据和服务路径"
    fi
fi

# ─── 初始化 git（如需）────────────────────────────────────────────────────
if [[ -d "$PROJECT_DIR/.git" ]]; then
    info "项目已是 git 仓库"
else
    warn "项目非 git 仓库，如需，手动执行：cd $PROJECT_DIR && git init"
fi

# ─── 自动检测并初始化子项目 ─────────────────────────────────────────────
header "检测子项目"

SUBPROJECT_COUNT=0

for dir in "$PROJECT_DIR"/*/; do
    [[ ! -d "$dir" ]] && continue
    SUBDIR_NAME="$(basename "$dir")"

    # 跳过隐藏目录
    [[ "$SUBDIR_NAME" == .* ]] && continue

    # 跳过 docs 等非代码目录
    [[ "$SUBDIR_NAME" == "docs" ]] && continue

    # 跳过已有 .claude/ 的
    if [[ -d "$dir/.claude" ]]; then
        info "跳过已初始化：$SUBDIR_NAME"
        continue
    fi

    # 检测类型
    TYPE=""
    if [[ -f "$dir/package.json" ]]; then
        TYPE="fe"
    elif [[ -f "$dir/pom.xml" ]] || [[ -f "$dir/build.gradle" ]]; then
        TYPE="be"
    fi

    if [[ -n "$TYPE" ]]; then
        bash "$SCRIPT_DIR/init-subproject.sh" "$dir" "$TYPE" "$PROJECT_NAME"
        SUBPROJECT_COUNT=$((SUBPROJECT_COUNT + 1))
    fi
done

if [[ "$SUBPROJECT_COUNT" -gt 0 ]]; then
    success "已初始化 $SUBPROJECT_COUNT 个子项目"
else
    info "未检测到子项目（含 package.json 或 pom.xml 的子目录）"
    info "可手动初始化：sh $(dirname "$0")/init-subproject.sh <子项目路径> <fe|be>"
fi

# ─── 生成初始化清单 ───────────────────────────────────────────────────────
CHECKLIST_TEMPLATE="$FRAMEWORK_ROOT/templates/setup-checklist.md.template"
CHECKLIST_TARGET="$PROJECT_DIR/.claude/setup-checklist.md"

if [[ -f "$CHECKLIST_TEMPLATE" ]]; then
    INIT_TIME=$(date '+%Y-%m-%dT%H:%M:%S')

    # 第一步：变量替换
    sed -e "s|\${PROJECT_NAME}|$PROJECT_NAME|g" \
        -e "s|\${INIT_LEVEL}|$INIT_LEVEL|g" \
        -e "s|\${INIT_TIME}|$INIT_TIME|g" \
        "$CHECKLIST_TEMPLATE" > "$CHECKLIST_TARGET.tmp"

    # 第二步：按级别裁剪任务块（awk 解析 level 字段）
    case "$INIT_LEVEL" in
        level1) KEEP_LEVELS="level1" ;;
        level2) KEEP_LEVELS="level1|level2" ;;
        level3) KEEP_LEVELS="level1|level2|level3" ;;
        full)   KEEP_LEVELS="level1|level2|level3|full" ;;
    esac

    awk -v keep="$KEEP_LEVELS" '
        /^<!-- TASKS BEGIN -->/ { print; in_tasks=1; next }
        /^<!-- TASKS END -->/   { if (task) { if (match(buf, "- level: ("keep")")) printf "%s", buf }; task=0; buf=""; print; in_tasks=0; next }
        !in_tasks { print; next }
        /^## T[0-9]/ {
            if (task) { if (match(buf, "- level: ("keep")")) printf "%s", buf }
            task=1; buf=$0"\n"; next
        }
        task { buf=buf $0"\n"; next }
    ' "$CHECKLIST_TARGET.tmp" > "$CHECKLIST_TARGET"

    rm -f "$CHECKLIST_TARGET.tmp"
    success "已生成初始化清单：.claude/setup-checklist.md"
else
    warn "未找到清单模板，跳过生成（$CHECKLIST_TEMPLATE）"
fi

# ─── 完成提示 ────────────────────────────────────────────────────────────
header "初始化完成"

printf '%b\n' "
${GREEN}✓ 框架文件已初始化（级别：${INIT_LEVEL}）${NC}
${GREEN}✓ 初始化清单已生成：.claude/setup-checklist.md${NC}

${BOLD}下一步${NC}：在项目目录启动一个新的 Claude 会话
  ${BLUE}cd $PROJECT_DIR && claude${NC}

  然后执行 ${BLUE}/init-setup${NC}，AI 会引导你逐步完成项目配置：
  检测技术栈、生成编码规范、配置工作流规则等（能自动检测的直接填好，需要决策的会主动问你）

  ${DIM}查看进度：/init-setup --status${NC}
  ${DIM}跳过任务：/init-setup --skip T6${NC}
  ${DIM}直接跳转：/init-setup T3${NC}

${BOLD}项目目录：${NC} $PROJECT_DIR
${BOLD}框架目录：${NC} $FRAMEWORK_ROOT"

