#!/usr/bin/env bash
# doctor.sh — h-codeflow-framework 环境诊断工具
#
# 用法：
#   bash tools/doctor.sh           # 完整检查
#   bash tools/doctor.sh --quiet   # 只显示有问题的项
#   bash tools/doctor.sh --json    # JSON 格式输出（CI 集成）
#
# 执行位置：
#   在框架目录 → 检查框架基础设施
#   在项目目录 → 检查框架基础设施 + 项目构建工具 + 可选集成
#
# 检查项：
#   第一层：框架基础设施（bash, git, shasum, python3）
#   第二层：项目构建工具（node/npm, mvn/gradle — 按技术栈自动探测）
#   第三层：可选集成（gh CLI, MCP 配置）

set -euo pipefail

# ─── 颜色 ─────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── 参数 ─────────────────────────────────────────────────────────────────────
QUIET=false
JSON_OUTPUT=false

for arg in "$@"; do
    case "$arg" in
        --quiet)  QUIET=true ;;
        --json)   JSON_OUTPUT=true ;;
        --help|-h)
            echo "用法: bash tools/doctor.sh [--quiet] [--json]"
            echo ""
            echo "  --quiet  只显示有问题的项"
            echo "  --json   JSON 格式输出"
            exit 0
            ;;
        *)
            echo "未知参数: $arg"
            echo "用法: bash tools/doctor.sh [--quiet] [--json]"
            exit 1
            ;;
    esac
done

# ─── 状态收集（用于 --json 输出和总结）─────────────────────────────────────────
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
JSON_ITEMS=()
FAIL_SUMMARIES=()
WARN_SUMMARIES=()

# ─── 辅助函数 ─────────────────────────────────────────────────────────────────

# 获取命令版本号（取第一行，截取前 30 字符）
get_version() {
    local cmd="$1"
    local ver=""
    ver=$($cmd --version 2>/dev/null | head -1 | cut -c1-30) || true
    echo "$ver"
}

# 检查命令是否存在，输出状态行
# 用法: check_command "git" "版本控制系统" "必选" "brew install git"
check_command() {
    local cmd="$1"
    local desc="$2"
    local level="$3"       # required / optional
    local install_hint="$4"

    if command -v "$cmd" &>/dev/null; then
        local path
        path=$(command -v "$cmd")
        local ver
        ver=$(get_version "$cmd")

        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"$cmd\",\"status\":\"pass\",\"path\":\"$path\",\"version\":\"$ver\"}")

        if [ "$QUIET" = false ]; then
            local ver_display=""
            [ -n "$ver" ] && ver_display=" ($ver)"
            say "  ${GREEN}✓${NC} $cmd    $path$ver_display"
        fi
        return 0
    else
        local marker icon color
        if [ "$level" = "required" ]; then
            marker="FAIL"
            icon="✗"
            color="$RED"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            FAIL_SUMMARIES+=("$cmd — $desc")
        else
            marker="WARN"
            icon="⚠"
            color="$YELLOW"
            WARN_COUNT=$((WARN_COUNT + 1))
            WARN_SUMMARIES+=("$cmd — $desc")
        fi

        JSON_ITEMS+=("{\"name\":\"$cmd\",\"status\":\"$marker\",\"desc\":\"$desc\",\"hint\":\"$install_hint\"}")

        say "  ${color}${icon}${NC} $cmd    ${color}未安装${NC} — $desc"
        say "         ${CYAN}→ $install_hint${NC}"
        return 1
    fi
}

# 检查 npm script 是否在 package.json 中配置
# 用法: check_npm_script "lint" "FE Agent 自查阶段会用到" "npm run lint"
check_npm_script() {
    local script_name="$1"
    local usage="$2"
    local run_cmd="$3"

    if [ ! -f "package.json" ]; then
        return 0
    fi

    # 用 node 解析比 grep 更准确，但 grep 兼容性更好
    if grep -q "\"$script_name\"" package.json 2>/dev/null; then
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"npm run $script_name\",\"status\":\"pass\"}")

        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} $run_cmd   — 已配置"
        fi
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAIL_SUMMARIES+=("$run_cmd 未配置 — $usage")
        JSON_ITEMS+=("{\"name\":\"npm run $script_name\",\"status\":\"FAIL\",\"desc\":\"$usage\"}")

        say "  ${RED}✗${NC} $run_cmd   — ${RED}未配置${NC}（$usage）"
        say "         ${CYAN}→ 在 package.json 的 scripts 中添加 \"$script_name\" 条目${NC}"
    fi
}

# 检查 npm script（可选级别）
check_npm_script_optional() {
    local script_name="$1"
    local usage="$2"
    local run_cmd="$3"

    if [ ! -f "package.json" ]; then
        return 0
    fi

    if grep -q "\"$script_name\"" package.json 2>/dev/null; then
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"npm run $script_name\",\"status\":\"pass\"}")

        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} $run_cmd   — 已配置"
        fi
    else
        WARN_COUNT=$((WARN_COUNT + 1))
        WARN_SUMMARIES+=("$run_cmd 未配置 — $usage")
        JSON_ITEMS+=("{\"name\":\"npm run $script_name\",\"status\":\"WARN\",\"desc\":\"$usage\"}")

        say "  ${YELLOW}⚠${NC} $run_cmd   — 未配置（$usage）"
    fi
}

# 打印分节标题（JSON 模式下静默）
print_section() {
    [ "$JSON_OUTPUT" = true ] && return
    local title="$1"
    echo ""
    echo -e "${BOLD}━━━ $title ━━━${NC}"
}

# 输出一行（JSON 模式下静默）
say() {
    [ "$JSON_OUTPUT" = true ] && return
    echo -e "$@"
}

# ─── 环境探测 ─────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_DIR=""  # 框架根目录
IS_PROJECT_DIR=false
HAS_FRONTEND=false
HAS_BACKEND=false

# 判断执行位置
detect_context() {
    # 如果 tools/VERSION 存在，说明在框架目录
    if [ -f "$SCRIPT_DIR/VERSION" ]; then
        FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
    fi

    # 判断项目目录（当前工作目录）
    if [ -f "package.json" ]; then
        IS_PROJECT_DIR=true
        HAS_FRONTEND=true
    fi
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        IS_PROJECT_DIR=true
        HAS_BACKEND=true
    fi
    # 有 .claude/ 也算项目目录
    if [ -d ".claude" ]; then
        IS_PROJECT_DIR=true
    fi
}

# ─── 第一层：框架基础设施 ─────────────────────────────────────────────────────

check_framework_base() {
    print_section "框架基础设施"

    check_command "bash"   "Shell 执行环境"          "required" "系统应自带"
    check_command "git"    "版本控制，所有 Agent 依赖" "required" "brew install git 或 apt install git"

    # shasum (macOS) / sha256sum (Linux)
    if command -v shasum &>/dev/null; then
        local path
        path=$(command -v shasum)
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"shasum\",\"status\":\"pass\",\"path\":\"$path\"}")

        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} shasum  $path"
        fi
    elif command -v sha256sum &>/dev/null; then
        local path
        path=$(command -v sha256sum)
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"sha256sum\",\"status\":\"pass\",\"path\":\"$path\"}")

        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} sha256sum $path（shasum 不可用，使用 sha256sum 替代）"
        fi
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAIL_SUMMARIES+=("shasum/sha256sum — 用于 upgrade.sh 冲突检测")
        JSON_ITEMS+=("{\"name\":\"shasum\",\"status\":\"FAIL\",\"desc\":\"用于 upgrade.sh 冲突检测\"}")

        say "  ${RED}✗${NC} shasum/sha256sum 未安装 — upgrade.sh 冲突检测依赖此命令"
        say "         ${CYAN}→ macOS 自带；Linux: apt install coreutils${NC}"
    fi

    check_command "python3" "框架发版通知（仅发版时需要）" "optional" "brew install python3 或 apt install python3"
}

# ─── 第二层：项目构建工具 ─────────────────────────────────────────────────────

check_project_tools() {
    if [ "$IS_PROJECT_DIR" = false ]; then
        print_section "项目构建工具"
        say "  ${YELLOW}⚠ 未检测到项目目录（package.json / pom.xml / .claude）${NC}"
        say "    请在下游项目目录执行本脚本以检查项目构建工具"
        return
    fi

    # 无前端也无后端，跳过此段
    if [ "$HAS_FRONTEND" = false ] && [ "$HAS_BACKEND" = false ]; then
        return
    fi

    print_section "项目构建工具"

    # ── 前端 ──
    if [ "$HAS_FRONTEND" = true ]; then
        say "  ${BOLD}[前端]${NC} 检测到 package.json"

        check_command "node" "前端运行环境"    "required" "https://nodejs.org 或 brew install node"

        # 检测包管理器
        local pkg_manager="npm"
        if [ -f "pnpm-lock.yaml" ]; then
            pkg_manager="pnpm"
        elif [ -f "yarn.lock" ]; then
            pkg_manager="yarn"
        fi

        check_command "$pkg_manager" "前端包管理器" "required" "npm install -g $pkg_manager"

        # 检查关键 npm scripts
        check_npm_script        "lint"    "QA Agent / FE Agent 代码检查" "$pkg_manager run lint"
        check_npm_script        "build"   "FE Agent 构建验证"            "$pkg_manager run build"
        check_npm_script_optional "test"  "QA Agent 测试验证（部分项目可无）" "$pkg_manager run test"

        say ""
    fi

    # ── 后端 ──
    if [ "$HAS_BACKEND" = true ]; then
        say "  ${BOLD}[后端]${NC} 检测到构建配置"

        local build_tool="mvn"
        if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
            build_tool="gradle"

            # 如果有 gradlew，用 gradlew
            if [ -f "gradlew" ]; then
                PASS_COUNT=$((PASS_COUNT + 1))
                JSON_ITEMS+=("{\"name\":\"gradlew\",\"status\":\"pass\"}")
                if [ "$QUIET" = false ]; then
                    say "  ${GREEN}✓${NC} gradlew  ./gradlew（项目自带）"
                fi
            else
                check_command "gradle" "后端构建工具" "required" "https://gradle.org/install/"
            fi
        else
            # 检查是否有 mvnw
            if [ -f "mvnw" ]; then
                PASS_COUNT=$((PASS_COUNT + 1))
                JSON_ITEMS+=("{\"name\":\"mvnw\",\"status\":\"pass\"}")
                if [ "$QUIET" = false ]; then
                    say "  ${GREEN}✓${NC} mvnw    ./mvnw（项目自带）"
                fi
            else
                check_command "mvn" "后端构建工具（Dev Agent 单元测试、打包）" "required" "brew install maven 或 apt install maven"
            fi
        fi

        say ""
    fi
}

# ─── 第三层：可选集成 ─────────────────────────────────────────────────────────

check_optional_integrations() {
    print_section "可选集成"

    check_command "gh"  "GitHub Issue/PR 管理" "optional" "brew install gh"

    # MCP 配置检查
    local mcp_found=false
    for mcp_file in ".claude/.mcp.json" ".mcp.json"; do
        if [ -f "$mcp_file" ]; then
            mcp_found=true
            PASS_COUNT=$((PASS_COUNT + 1))
            JSON_ITEMS+=("{\"name\":\"mcp_config\",\"status\":\"pass\",\"path\":\"$mcp_file\"}")

            if [ "$QUIET" = false ]; then
                say "  ${GREEN}✓${NC} MCP 配置  $mcp_file"
            fi
            break
        fi
    done

    if [ "$mcp_found" = false ]; then
        WARN_COUNT=$((WARN_COUNT + 1))
        WARN_SUMMARIES+=("MCP 配置未找到 — Jira/Confluence 集成不可用")
        JSON_ITEMS+=("{\"name\":\"mcp_config\",\"status\":\"WARN\",\"desc\":\"Jira/Confluence 集成不可用\"}")

        say "  ${YELLOW}⚠${NC} MCP 配置  未找到 — Jira/Confluence 集成不可用"
        say "         ${CYAN}→ 参考 templates/mcp-config.json.template 配置 .claude/.mcp.json${NC}"
    fi
}

# ─── 第四层：E2E 测试环境 ──────────────────────────────────────────────────────

check_e2e_environment() {
    # 仅在检测到 e2e/ 目录时执行
    if [ ! -d "e2e" ]; then
        return
    fi

    print_section "E2E 测试环境"

    say "  ${BOLD}[E2E]${NC} 检测到 e2e/ 目录"

    # 检查 e2e/package.json
    if [ -f "e2e/package.json" ]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"e2e_package_json\",\"status\":\"pass\"}")
        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} e2e/package.json  已配置"
        fi
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAIL_SUMMARIES+=("e2e/package.json 缺失 — E2E 未正确初始化")
        JSON_ITEMS+=("{\"name\":\"e2e_package_json\",\"status\":\"FAIL\",\"desc\":\"E2E 未正确初始化\"}")
        say "  ${RED}✗${NC} e2e/package.json  缺失 — 请重新初始化：sh ../h-codeflow-framework/templates/e2e/init-e2e.sh . \"Project Name\""
    fi

    # 检查依赖是否已安装
    if [ -d "e2e/node_modules" ]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"e2e_node_modules\",\"status\":\"pass\"}")
        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} e2e/node_modules  依赖已安装"
        fi
    else
        WARN_COUNT=$((WARN_COUNT + 1))
        WARN_SUMMARIES+=("e2e/node_modules 未安装 — 需执行 cd e2e && npm install")
        JSON_ITEMS+=("{\"name\":\"e2e_node_modules\",\"status\":\"WARN\",\"desc\":\"E2E 依赖未安装\"}")
        say "  ${YELLOW}⚠${NC} e2e/node_modules  未安装"
        say "         ${CYAN}→ cd e2e && npm install${NC}"
    fi

    # 检查 Playwright 是否可用
    local pw_ver=""
    pw_ver=$(cd e2e && npx playwright --version 2>/dev/null | head -1) || true
    if [ -n "$pw_ver" ]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"e2e_playwright\",\"status\":\"pass\",\"version\":\"$pw_ver\"}")
        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} Playwright  $pw_ver"
        fi
    else
        WARN_COUNT=$((WARN_COUNT + 1))
        WARN_SUMMARIES+=("Playwright 未安装 — 需执行 cd e2e && npx playwright install")
        JSON_ITEMS+=("{\"name\":\"e2e_playwright\",\"status\":\"WARN\",\"desc\":\"Playwright 未安装\"}")
        say "  ${YELLOW}⚠${NC} Playwright  未安装"
        say "         ${CYAN}→ cd e2e && npm install && npx playwright install chromium${NC}"
    fi

    # 检查 ddddocr（E2E 验证码 OCR 依赖）
    local ddddocr_ok=""
    ddddocr_ok=$(python3 -c "import ddddocr" 2>/dev/null && echo "ok") || true
    if [ -n "$ddddocr_ok" ]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        JSON_ITEMS+=("{\"name\":\"e2e_ddddocr\",\"status\":\"pass\"}")
        if [ "$QUIET" = false ]; then
            say "  ${GREEN}✓${NC} ddddocr   已安装（验证码 OCR）"
        fi
    else
        WARN_COUNT=$((WARN_COUNT + 1))
        WARN_SUMMARIES+=("ddddocr 未安装 — E2E 登录验证码识别不可用")
        JSON_ITEMS+=("{\"name\":\"e2e_ddddocr\",\"status\":\"WARN\",\"desc\":\"E2E 登录验证码识别不可用\"}")
        say "  ${YELLOW}⚠${NC} ddddocr   未安装 — E2E 登录验证码识别将失败"
        say "         ${CYAN}→ pip install ddddocr${NC}"
    fi

    say ""
}

# ─── 总结 ─────────────────────────────────────────────────────────────────────

print_summary() {
    print_section "总结"

    local has_issue=false

    if [ "$FAIL_COUNT" -gt 0 ]; then
        has_issue=true
        say "  ${RED}✗ $FAIL_COUNT 项需要处理：${NC}"
        for item in "${FAIL_SUMMARIES[@]}"; do
            say "    ${RED}•${NC} $item"
        done
    fi

    if [ "$WARN_COUNT" -gt 0 ]; then
        has_issue=true
        say "  ${YELLOW}⚠ $WARN_COUNT 项可选建议：${NC}"
        for item in "${WARN_SUMMARIES[@]}"; do
            say "    ${YELLOW}•${NC} $item"
        done
    fi

    if [ "$has_issue" = false ]; then
        say "  ${GREEN}所有检查通过，环境就绪！${NC}"
    fi

    # 提示
    if [ "$FAIL_COUNT" -gt 0 ]; then
        say ""
        say "  ${CYAN}💡 未配置的 npm scripts 请在 package.json 的 scripts 中添加对应条目${NC}"
        say "  ${CYAN}💡 缺少的系统工具请根据上方提示安装${NC}"
    fi
}

# ─── JSON 输出 ────────────────────────────────────────────────────────────────

print_json() {
    echo "{"
    echo "  \"framework_dir\": \"$FRAMEWORK_DIR\","
    echo "  \"is_project_dir\": $IS_PROJECT_DIR,"
    echo "  \"has_frontend\": $HAS_FRONTEND,"
    echo "  \"has_backend\": $HAS_BACKEND,"
    echo "  \"has_e2e\": $([ -d \"e2e\" ] && echo true || echo false),"
    echo "  \"summary\": {"
    echo "    \"pass\": $PASS_COUNT,"
    echo "    \"warn\": $WARN_COUNT,"
    echo "    \"fail\": $FAIL_COUNT"
    echo "  },"
    echo "  \"items\": ["
    local first=true
    for item in "${JSON_ITEMS[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            echo "    ,"
        fi
        echo -n "    $item"
    done
    echo ""
    echo "  ]"
    echo "}"
}

# ─── 主流程 ───────────────────────────────────────────────────────────────────

detect_context

if [ "$JSON_OUTPUT" = true ]; then
    # JSON 模式：静默检查，最后统一输出
    check_framework_base
    check_project_tools
    check_optional_integrations
    check_e2e_environment
    print_json
else
    # 交互模式：逐步输出
    say ""
    say "${BOLD}h-codeflow-framework 环境诊断${NC}"
    say ""

    check_framework_base
    check_project_tools
    check_optional_integrations
    check_e2e_environment
    print_summary

    say ""
fi
