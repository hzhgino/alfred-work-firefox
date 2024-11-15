#!/bin/bash

# 导入通用函数
source ./alfred.sh

# 常量定义
CACHE_EXPIRY=$((24 * 60 * 60)) # 24小时，单位：秒
CACHE_DIR="$(handle_workflow_dir true)"

# 复制数据库文件
copy_places_db() {
    local profile="$1"
    local places_file="places.sqlite"
    local orig="$profile/$places_file"
    local new="$profile/places-alfredcopy.sqlite"
    
    if [ ! -f "$orig" ]; then
        echo "<!-- 错误: 找不到 places.sqlite -->" >&2
        return 1
    fi
    
    cp "$orig" "$new"
    echo "$new"
}

# 构建 SQL 查询
build_sql_query() {
    local query="$1"
    query=$(echo "$query" | sed 's/[%_]/\\&/g' | tr -s ' ')
    
    cat << EOF
    SELECT DISTINCT 
        moz_places.id, 
        COALESCE(moz_places.title, moz_places.url) as title, 
        moz_places.url
    FROM moz_places
    INNER JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id
    WHERE (
        COALESCE(moz_places.title, '') LIKE '%${query}%' ESCAPE '\\'
        OR moz_places.url LIKE '%${query}%' ESCAPE '\\'
    )
    GROUP BY moz_places.id
    ORDER BY MAX(moz_historyvisits.visit_date) DESC
    LIMIT $MAX_RESULTS;
EOF
}

# 搜索结果处理
process_results() {
    local places_db="$1"
    local query="$2"  # 修正参数位置
    local found_items=()
    
    local sql_query=$(build_sql_query "$query")
    echo "<!-- 执行查询: $sql_query -->" >&2
    
    while IFS='|' read -r id title url; do
        local key="$id:$title:$url"
        if [[ " ${found_items[@]} " =~ " ${key} " ]]; then
            continue
        fi
        found_items+=("$key")
        
        echo "<!-- 找到历史记录: '$title' ($url) -->" >&2
        create_item "$title" "$url" "$(generate_uid "$id")" "" "$url"
    done < <(sqlite3 "$places_db" "$sql_query" 2>/dev/null)
    
    if [ ${#found_items[@]} -eq 0 ]; then
        return 1
    fi
    
    return 0
}

# 主函数
main() {
    # 获取 Firefox 配置文件路径
    local profile_dir=$(find "$HOME/Library/Application Support/Firefox/Profiles" -name "*.default*" -type d 2>/dev/null | head -n 1)
    
    if [ -z "$profile_dir" ]; then
        # 开始XML输出
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        echo "<items>"
        create_item "错误" "未找到Firefox配置文件" "$(generate_uid "error")"
        echo "</items>"
        exit 1
    fi
    
    echo "<!-- 找到Firefox配置文件: $profile_dir -->" >&2
    
    # 从 Alfred 获取查询参数
    local query="$(parse_args "$1")"
    
    # 开始XML输出
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    echo "<items>"
    
    # 如果查询为空，显示提示信息
    if [ -z "$query" ]; then
        create_item "开始搜索" "输入关键词以搜索Firefox历史记录" "$(generate_uid "hint")"
        echo "</items>"
        return
    fi
    
    # 复制数据库
    local places_db="/tmp/places-alfredcopy-$$.sqlite"
    
    # 复制数据库文件
    if ! cp "$profile_dir/places.sqlite" "$places_db" 2>/dev/null; then
        create_item "错误" "无法访问Firefox历史记录数据库" "$(generate_uid "error")"
        echo "</items>"
        return
    fi
    
    # 处理结果
    if ! process_results "$places_db" "$query"; then
        create_item "未找到结果" "没有匹配的Firefox历史记录" "$(generate_uid "noresult")"
    fi
    
    # 清理临时文件
    rm -f "$places_db" "$favicons_db" "$places_db-shm" "$places_db-wal" "$favicons_db-shm" "$favicons_db-wal"

    
    # 结束XML输出
    echo "</items>"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 