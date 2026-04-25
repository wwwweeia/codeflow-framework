#!/usr/bin/env bash
# init-e2e.sh — 初始化项目 E2E 测试基础设施
#
# 用法（在项目根目录执行）：
#   cd new-project
#   sh ../codeflow-framework/templates/e2e/init-e2e.sh . "Project Name"
#
# 参数：
#   $1: 项目根目录（通常为 .）
#   $2: 项目名称（用于 package.json 中的 name 字段）
#
# 功能：
# 1. 创建 e2e/ 目录结构
# 2. 从 templates/e2e/ 复制脚手架文件
# 3. 替换模板占位符
# 4. 安装依赖

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

# ─── 参数验证 ───────────────────────────────────────────────────────────────
PROJECT_DIR="${1:-.}"
PROJECT_NAME="${2:-unknown-project}"
E2E_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || { error "项目目录不存在：$1"; exit 1; }

# ─── 路径设置 ───────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
E2E_DIR="$PROJECT_DIR/e2e"

header "初始化 E2E 测试基础设施：$PROJECT_NAME"

info "项目目录：$PROJECT_DIR"
info "E2E 目录：$E2E_DIR"
info "模板目录：$SCRIPT_DIR"

# ─── 检查是否已存在 ───────────────────────────────────────────────────────
if [[ -d "$E2E_DIR" ]]; then
  warn "e2e/ 目录已存在"
  read -p "是否覆盖已有文件？(y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "跳过 E2E 初始化"
    exit 0
  fi
fi

# ─── 创建目录结构 ───────────────────────────────────────────────────────────
header "创建 e2e/ 目录结构"

mkdir -p "$E2E_DIR"/{tests,pages,fixtures,utils,scripts,.auth,.evidence}

success "目录结构已创建：
  e2e/
  ├── tests/
  ├── pages/
  ├── fixtures/
  ├── utils/
  ├── scripts/
  ├── .auth/
  └── .evidence/"

# ─── 复制脚手架文件 ─────────────────────────────────────────────────────────
header "复制 E2E 脚手架文件"

COPIED_COUNT=0

# 复制模板文件（需要替换占位符）
for tpl in playwright.config.ts.template package.json.template; do
  if [[ -f "$SCRIPT_DIR/$tpl" ]]; then
    target_name="${tpl%.template}"
    sed "s/\${PROJECT_NAME}/$E2E_NAME/g" "$SCRIPT_DIR/$tpl" \
      > "$E2E_DIR/$target_name"
    COPIED_COUNT=$((COPIED_COUNT + 1))
    success "已创建 e2e/$target_name"
  fi
done

# 复制完全通用的文件
for file in tsconfig.json .gitignore .env.example; do
  if [[ -f "$SCRIPT_DIR/$file" ]]; then
    cp "$SCRIPT_DIR/$file" "$E2E_DIR/$file"
    COPIED_COUNT=$((COPIED_COUNT + 1))
    success "已复制 e2e/$file"
  fi
done

# 复制 fixtures/
if [[ -d "$SCRIPT_DIR/fixtures" ]]; then
  cp "$SCRIPT_DIR/fixtures/"*.ts "$E2E_DIR/fixtures/" 2>/dev/null || true
  COPIED_COUNT=$((COPIED_COUNT + 1))
  success "已复制 fixtures/"
fi

# 复制 pages/
if [[ -d "$SCRIPT_DIR/pages" ]]; then
  cp "$SCRIPT_DIR/pages/"*.ts "$E2E_DIR/pages/" 2>/dev/null || true
  COPIED_COUNT=$((COPIED_COUNT + 1))
  success "已复制 pages/"
fi

# 复制 utils/
if [[ -d "$SCRIPT_DIR/utils" ]]; then
  cp "$SCRIPT_DIR/utils/"*.ts "$E2E_DIR/utils/" 2>/dev/null || true
  COPIED_COUNT=$((COPIED_COUNT + 1))
  success "已复制 utils/"
fi

# 复制 scripts/
if [[ -d "$SCRIPT_DIR/scripts" ]]; then
  cp "$SCRIPT_DIR/scripts/"* "$E2E_DIR/scripts/" 2>/dev/null || true
  COPIED_COUNT=$((COPIED_COUNT + 1))
  success "已复制 scripts/"
fi

# 复制 tests/auth.setup.ts
if [[ -f "$SCRIPT_DIR/tests/auth.setup.ts" ]]; then
  cp "$SCRIPT_DIR/tests/auth.setup.ts" "$E2E_DIR/tests/auth.setup.ts"
  COPIED_COUNT=$((COPIED_COUNT + 1))
  success "已复制 tests/auth.setup.ts"
fi

success "已复制 $COPIED_COUNT 个文件"

# ─── 安装依赖 ─────────────────────────────────────────────────────────────
header "安装依赖"

cd "$E2E_DIR"

if command -v npm &> /dev/null; then
  npm install
  npx playwright install chromium
  success "依赖安装完成"
else
  warn "未检测到 npm，请手动安装依赖：cd e2e && npm install && npx playwright install chromium"
fi

# ─── 输出指导 ─────────────────────────────────────────────────────────────
header "E2E 初始化完成"

printf '%b\n' "
${GREEN}✓ E2E 测试基础设施已初始化${NC}

${BOLD}目录说明：${NC}

  e2e/
  ├── tests/          测试用例（按 feature 分子目录）
  │   └── auth.setup.ts  认证 setup（已完成）
  ├── pages/          POM 页面对象（base.page.ts + login.page.ts 已提供）
  ├── fixtures/       Playwright fixtures（auth.fixture.ts 已提供）
  ├── utils/          工具函数（api-login.ts + encryption.ts 已提供）
  ├── scripts/        辅助脚本（read_captcha.swift 已提供）
  ├── .auth/          认证产物（已 gitignore）
  ├── .evidence/      运行时截图（已 gitignore）
  ├── playwright.config.ts
  ├── package.json
  └── tsconfig.json

${BOLD}下一步：${NC}

1. ${BLUE}配置环境变量${NC}
   cp e2e/.env.example e2e/.env
   # 编辑 e2e/.env，填写实际的服务地址和账号

2. ${BLUE}编写第一个测试${NC}
   mkdir -p e2e/tests/your-feature
   # 由 e2e-runner Agent 基于 02_technical_design.md Part E 自动生成

3. ${BLUE}运行测试${NC}
   cd e2e && npm test
"
