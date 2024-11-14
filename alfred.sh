#!/bin/bash

# 定义全局常量 - 统一使用一个变量控制结果数量
MAX_RESULTS=${ALFRED_MAX_RESULTS:-5}  # 允许通过环境变量覆盖，默认显示5条结果
BUNDLE_ID="com.firefox.workflow"      # 使用固定的 bundle ID

# XML 转义函数
xml_escape() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    printf '%s' "$s"
}

# 创建 Item XML，移除图标相关代码
create_item() {
    local title="$(xml_escape "$1")"
    local subtitle="$(xml_escape "$2")"
    local uid="$3"
    local arg="$5"
    
    printf '<item uid="%s"%s>\n' "$uid" "$([ -n "$arg" ] && echo " arg=\"$(xml_escape "$arg")\"")"
    printf '  <title>%s</title>\n' "$title"
    printf '  <subtitle>%s</subtitle>\n' "$subtitle"
    echo "</item>"
}

# 创建工作目录
create_dir() {
    local path="$1"
    if [ ! -d "$path" ]; then
        mkdir -p "$path"
    fi
    if [ ! -w "$path" ]; then
        echo "No write access: $path" >&2
        exit 1
    fi
}

# 获取环境变量
get_env() {
    local key="alfred_$1"
    echo "${!key}"
}

# 生成唯一ID
generate_uid() {
    echo "${BUNDLE_ID}-$1"
}

# 处理工作目录
handle_workflow_dir() {
    local volatile=$1
    local dir
    
    if [ "$volatile" = true ]; then
        dir="$(get_env workflow_cache)"
    else
        dir="$(get_env workflow_data)"
    fi
    
    create_dir "$dir"
    echo "$dir"
}

# 参数解析函数
parse_args() {
    local query="$1"
    # 处理转义字符
    query="${query//\\\;/;}"
    query="${query//\\\(/\(}"
    query="${query//\\\)/\)}"
    echo "$query"
}

# 主函数
main() {
    local query="$(parse_args "$1")"
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    echo "<items>"
    echo "</items>"
}

# 仅在直接运行时执行main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 