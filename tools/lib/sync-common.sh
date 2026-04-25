#!/usr/bin/env bash
# sync-common.sh — 双向同步冲突检测的通用函数库
#
# 提供：
# - MANIFEST 清单读取（按 level 筛选框架管理文件）
# - 内容指纹计算（SHA-256）
# - 同步状态文件读写（CSV 格式，无外部依赖）
# - 版本号解析与比较（从 harvest.sh 提取复用）
#
# 状态文件格式（sync-state.csv / harvest-state.csv）：
#   #relative_path|hash|version
#   agents/pm-agent.md|a1b2c3d4|v1.9.0-20260421
#
# 用法：
#   source "$(dirname "$0")/lib/sync-common.sh"

# ─── 内容指纹 ─────────────────────────────────────────────────────────────

# macOS 用 shasum，Linux/Git Bash 用 sha256sum，输出格式一致但命令名不同
_HASH_CMD=""
_detect_hash_cmd() {
    if [[ -n "$_HASH_CMD" ]]; then return; fi
    if command -v shasum &>/dev/null; then
        _HASH_CMD="shasum -a 256"
    elif command -v sha256sum &>/dev/null; then
        _HASH_CMD="sha256sum"
    else
        echo "[ERROR] shasum / sha256sum 均不可用" >&2
        exit 1
    fi
}

# 计算内容的 SHA-256 摘要
# 用法: hash=$(compute_hash "$content")
compute_hash() {
    _detect_hash_cmd
    echo "$1" | $_HASH_CMD | cut -d' ' -f1
}

# 计算文件指定行范围的 SHA-256 摘要
# 用法: hash=$(compute_file_hash "$file_path" "$line_count")
# 计算 head -n $line_count 的 hash
compute_file_hash() {
    local file_path="$1"
    local line_count="$2"
    _detect_hash_cmd
    head -n "$line_count" "$file_path" | $_HASH_CMD | cut -d' ' -f1
}

# ─── 同步状态文件读写 ─────────────────────────────────────────────────────

# 初始化状态文件（如不存在则创建）
# 用法: init_sync_state "$state_file"
init_sync_state() {
    local state_file="$1"
    local state_dir
    state_dir="$(dirname "$state_file")"
    if [[ ! -d "$state_dir" ]]; then
        mkdir -p "$state_dir"
    fi
    if [[ ! -f "$state_file" ]]; then
        echo "#relative_path|hash|version" > "$state_file"
    fi
}

# 读取指定文件的 hash
# 用法: hash=$(read_hash "$state_file" "$relative_path")
# 返回: hash 字符串，不存在则返回空
read_hash() {
    local state_file="$1"
    local relative_path="$2"
    if [[ ! -f "$state_file" ]]; then
        echo ""
        return
    fi
    local line
    line=$(grep -v '^#' "$state_file" | grep "^${relative_path}|" | head -1)
    if [[ -z "$line" ]]; then
        echo ""
        return
    fi
    echo "$line" | cut -d'|' -f2
}

# 读取指定文件的 version
# 用法: ver=$(read_version "$state_file" "$relative_path")
read_version() {
    local state_file="$1"
    local relative_path="$2"
    if [[ ! -f "$state_file" ]]; then
        echo ""
        return
    fi
    local line
    line=$(grep -v '^#' "$state_file" | grep "^${relative_path}|" | head -1)
    if [[ -z "$line" ]]; then
        echo ""
        return
    fi
    echo "$line" | cut -d'|' -f3
}

# 写入/更新指定文件的 hash 和 version
# 用法: write_hash "$state_file" "$relative_path" "$hash" "$version"
write_hash() {
    local state_file="$1"
    local relative_path="$2"
    local hash="$3"
    local version="$4"

    init_sync_state "$state_file"

    # 检查是否已有记录（去掉注释行和空行）
    if grep -v '^#' "$state_file" | grep -q "^${relative_path}|"; then
        # 更新已有记录（BSD sed 兼容）
        local tmp_file
        tmp_file=$(mktemp)
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" == \#* ]] || [[ -z "$line" ]]; then
                echo "$line" >> "$tmp_file"
            elif [[ "$line" == "${relative_path}|"* ]]; then
                echo "${relative_path}|${hash}|${version}" >> "$tmp_file"
            else
                echo "$line" >> "$tmp_file"
            fi
        done < "$state_file"
        mv "$tmp_file" "$state_file"
    else
        # 追加新记录
        echo "${relative_path}|${hash}|${version}" >> "$state_file"
    fi
}

# 批量写入 hash（处理完所有文件后统一写入，避免频繁 IO）
# 用法: batch_write_init "$state_file"
#       batch_write_add "$relative_path" "$hash" "$version"
#       batch_write_commit "$state_file"
BATCH_WRITE_TEMP=""
batch_write_init() {
    BATCH_WRITE_TEMP=$(mktemp)
}

batch_write_add() {
    echo "$1|$2|$3" >> "$BATCH_WRITE_TEMP"
}

batch_write_commit() {
    local state_file="$1"
    init_sync_state "$state_file"

    if [[ ! -f "$BATCH_WRITE_TEMP" ]] || [[ ! -s "$BATCH_WRITE_TEMP" ]]; then
        rm -f "$BATCH_WRITE_TEMP"
        return
    fi

    # 逐条更新
    while IFS='|' read -r rel_path hash version; do
        [[ -z "$rel_path" ]] && continue
        write_hash "$state_file" "$rel_path" "$hash" "$version"
    done < "$BATCH_WRITE_TEMP"

    rm -f "$BATCH_WRITE_TEMP"
}

# ─── 版本号解析与比较（从 harvest.sh 提取） ─────────────────────────────

# 版本格式: MAJOR.MINOR.PATCH-YYYYMMDD 或 MAJOR.MINOR.PATCH-dev.N-YYYYMMDD
# parse_version 将版本字符串拆分到全局变量 PARSED_*
parse_version() {
    local ver="$1"
    ver="${ver#v}"  # 去掉前缀 "v"

    local main_part="${ver%%-*}"   # MAJOR.MINOR.PATCH
    local suffix="${ver#*-}"       # YYYYMMDD 或 dev.N-YYYYMMDD

    IFS='.' read -r PARSED_MAJOR PARSED_MINOR PARSED_PATCH <<< "$main_part"
    PARSED_MAJOR="${PARSED_MAJOR:-0}"
    PARSED_MINOR="${PARSED_MINOR:-0}"
    PARSED_PATCH="${PARSED_PATCH:-0}"

    if [[ "$suffix" == dev* ]]; then
        local dev_part="${suffix#dev.}"  # N-YYYYMMDD
        PARSED_DATE="${dev_part#*-}"
        PARSED_DEV="${dev_part%-*}"
    else
        PARSED_DEV=0
        PARSED_DATE="$suffix"
    fi
}

# 比较两个版本号
# 返回: 0=相等, 1=v1>v2, 2=v1<v2
compare_versions() {
    parse_version "$1"
    local m1="$PARSED_MAJOR" n1="$PARSED_MINOR" p1="$PARSED_PATCH" d1="$PARSED_DEV" dt1="$PARSED_DATE"

    parse_version "$2"
    local m2="$PARSED_MAJOR" n2="$PARSED_MINOR" p2="$PARSED_PATCH" d2="$PARSED_DEV" dt2="$PARSED_DATE"

    # 比较 MAJOR.MINOR.PATCH
    [[ "$m1" -lt "$m2" ]] && return 2
    [[ "$m1" -gt "$m2" ]] && return 1
    [[ "$n1" -lt "$n2" ]] && return 2
    [[ "$n1" -gt "$n2" ]] && return 1
    [[ "$p1" -lt "$p2" ]] && return 2
    [[ "$p1" -gt "$p2" ]] && return 1

    # 同 MAJOR.MINOR.PATCH：正式版 > dev 版本
    [[ "$d1" -eq 0 && "$d2" -gt 0 ]] && return 1  # 正式 > dev
    [[ "$d1" -gt 0 && "$d2" -eq 0 ]] && return 2  # dev < 正式
    [[ "$d1" -lt "$d2" ]] && return 2
    [[ "$d1" -gt "$d2" ]] && return 1

    # 最后比较日期
    [[ "$dt1" -lt "$dt2" ]] && return 2
    [[ "$dt1" -gt "$dt2" ]] && return 1

    return 0
}

# ─── MANIFEST 清单读取 ───────────────────────────────────────────────────

# 从 core/MANIFEST 读取文件列表
# 参数: $1=core目录, $2=level(可选，筛选级别)
# 返回: 文件相对路径列表（每行一个），skill 返回目录名
# 用法: read_manifest "$FRAMEWORK_CORE" "level3"
read_manifest() {
    local core_dir="$1"
    local filter_level="$2"
    local manifest="$core_dir/MANIFEST"

    if [[ ! -f "$manifest" ]]; then
        echo "[ERROR] MANIFEST not found: $manifest" >&2
        return 1
    fi

    while IFS= read -r line; do
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        local path level
        path=$(echo "$line" | awk '{print $1}')
        level=$(echo "$line" | awk '{print $2}')

        [[ -z "$path" ]] && continue
        [[ -z "$level" ]] && continue

        # level 筛选：core 级别始终包含
        if [[ -z "$filter_level" ]] || [[ "$level" == "core" ]]; then
            echo "$path"
        elif [[ "$filter_level" == "full" ]]; then
            echo "$path"
        elif [[ "$filter_level" == "level3" ]]; then
            [[ "$level" =~ ^(level1|level2|level3)$ ]] && echo "$path"
        elif [[ "$filter_level" == "level2" ]]; then
            [[ "$level" =~ ^(level1|level2)$ ]] && echo "$path"
        elif [[ "$filter_level" == "level1" ]]; then
            [[ "$level" == "level1" ]] && echo "$path"
        fi
    done < "$manifest"
}

# 从 MANIFEST 读取所有文件路径（不筛选 level），返回完整路径列表
# skill 目录展开为目录下所有文件
# 参数: $1=core目录
# 用法: read_manifest_all_files "$FRAMEWORK_CORE"
read_manifest_all_files() {
    local core_dir="$1"
    local manifest="$core_dir/MANIFEST"

    if [[ ! -f "$manifest" ]]; then
        echo "[ERROR] MANIFEST not found: $manifest" >&2
        return 1
    fi

    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        local path
        path=$(echo "$line" | awk '{print $1}')
        [[ -z "$path" ]] && continue

        local full_path="$core_dir/$path"
        if [[ -d "$full_path" ]]; then
            # skill 目录：展开为所有文件
            find "$full_path" -type f | sed "s|^$core_dir/||" | sort
        elif [[ -f "$full_path" ]]; then
            echo "$path"
        fi
    done < "$manifest" | sort -u
}

# 检查一个路径是否在 MANIFEST 中（用于孤儿检测）
# 参数: $1=core目录, $2=要检查的相对路径
# 返回: 0=在清单中, 1=不在
is_in_manifest() {
    local core_dir="$1"
    local check_path="$2"
    local manifest="$core_dir/MANIFEST"

    if [[ ! -f "$manifest" ]]; then return 1; fi

    # 对于 skill 子文件，检查其目录是否在清单中
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        local manifest_path
        manifest_path=$(echo "$line" | awk '{print $1}')
        [[ -z "$manifest_path" ]] && continue

        if [[ "$check_path" == "$manifest_path" ]]; then
            return 0
        fi
        # skill 目录匹配：manifest 列出 skills/xxx，检查路径是否以之开头
        if [[ -d "$core_dir/$manifest_path" ]] && [[ "$check_path" == "$manifest_path/"* ]]; then
            return 0
        fi
    done < "$manifest"

    return 1
}
