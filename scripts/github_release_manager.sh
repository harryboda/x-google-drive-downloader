#!/bin/bash

# GitHub Release管理脚本
# 用于管理GitHub Releases的创建、删除和更新
# 避免使用gh CLI命令的限制，改用GitHub API

set -e

REPO_USER="harryboda"
REPO_NAME="x-google-drive-downloader"
BASE_URL="https://api.github.com/repos/$REPO_USER/$REPO_NAME"

# 获取GitHub Token
get_github_token() {
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        gh auth token
    elif [ -n "$GITHUB_TOKEN" ]; then
        echo "$GITHUB_TOKEN"
    else
        echo "❌ 错误: 需要GitHub认证"
        echo "请运行: gh auth login 或设置 GITHUB_TOKEN 环境变量"
        exit 1
    fi
}

# 列出所有releases
list_releases() {
    echo "🔍 获取所有releases..."
    local token=$(get_github_token)
    
    local response=$(curl -s -H "Accept: application/vnd.github.v3+json" \
                          -H "Authorization: token $token" \
                          "$BASE_URL/releases")
    
    # 简单解析输出
    echo "$response" | grep -o '"id": *[0-9]*' | head -10 | while read -r line; do
        local id=$(echo "$line" | grep -o '[0-9]*')
        echo "Release ID: $id"
    done
    
    echo ""
    echo "完整响应:"
    echo "$response"
}

# 删除指定的release
delete_release() {
    local release_id="$1"
    if [ -z "$release_id" ]; then
        echo "❌ 错误: 请提供release ID"
        echo "用法: delete_release <release_id>"
        return 1
    fi
    
    echo "🗑️ 删除release ID: $release_id..."
    local token=$(get_github_token)
    
    local response=$(curl -s -w "%{http_code}" \
                          -X DELETE \
                          -H "Accept: application/vnd.github.v3+json" \
                          -H "Authorization: token $token" \
                          "$BASE_URL/releases/$release_id")
    
    local http_code="${response: -3}"
    if [ "$http_code" = "204" ]; then
        echo "✅ Release删除成功"
    else
        echo "❌ 删除失败，HTTP状态码: $http_code"
        echo "响应: ${response%???}"
        return 1
    fi
}

# 获取指定tag的release信息
get_release_by_tag() {
    local tag="$1"
    if [ -z "$tag" ]; then
        echo "❌ 错误: 请提供tag名称"
        return 1
    fi
    
    echo "🔍 获取tag '$tag' 的release信息..."
    local token=$(get_github_token)
    
    curl -s -H "Accept: application/vnd.github.v3+json" \
         -H "Authorization: token $token" \
         "$BASE_URL/releases/tags/$tag" | \
    jq -r '"ID: \(.id) | Tag: \(.tag_name) | Name: \(.name) | Published: \(.published_at)"'
}

# 删除指定tag的release
delete_release_by_tag() {
    local tag="$1"
    if [ -z "$tag" ]; then
        echo "❌ 错误: 请提供tag名称"
        echo "用法: delete_release_by_tag <tag_name>"
        return 1
    fi
    
    echo "🔍 查找tag '$tag' 的release..."
    local token=$(get_github_token)
    
    # 获取release信息
    local release_info=$(curl -s -H "Accept: application/vnd.github.v3+json" \
                              -H "Authorization: token $token" \
                              "$BASE_URL/releases/tags/$tag")
    
    # 检查是否找到release (简单检查是否包含错误信息)
    if echo "$release_info" | grep -q '"message"'; then
        echo "❌ 未找到tag '$tag' 对应的release"
        echo "详细信息: $release_info"
        return 1
    fi
    
    # 提取release ID (简单的文本提取)
    local release_id=$(echo "$release_info" | grep -o '"id": *[0-9]*' | head -1 | grep -o '[0-9]*')
    
    if [ -z "$release_id" ]; then
        echo "❌ 无法提取release ID"
        echo "响应: $release_info"
        return 1
    fi
    
    echo "📍 找到release - ID: $release_id, Tag: $tag"
    
    # 确认删除
    echo "⚠️ 即将删除release: $tag (ID: $release_id)"
    read -p "确认删除？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        delete_release "$release_id"
    else
        echo "🚫 取消删除"
    fi
}

# 显示帮助信息
show_help() {
    echo "GitHub Release管理工具"
    echo ""
    echo "用法: $0 <command> [arguments]"
    echo ""
    echo "命令:"
    echo "  list                     - 列出所有releases"
    echo "  get <tag>               - 获取指定tag的release信息"
    echo "  delete <release_id>     - 删除指定ID的release"
    echo "  delete_tag <tag>        - 删除指定tag的release"
    echo "  help                    - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 list"
    echo "  $0 get v2.0.0"
    echo "  $0 delete_tag v2.0.0"
    echo ""
    echo "注意:"
    echo "- 需要GitHub认证 (gh auth login 或 GITHUB_TOKEN 环境变量)"
    echo "- 删除操作不可逆，请谨慎操作"
    echo "- 删除release不会删除对应的git tag"
}

# 主函数
main() {
    case "${1:-help}" in
        "list")
            list_releases
            ;;
        "get")
            get_release_by_tag "$2"
            ;;
        "delete")
            delete_release "$2"
            ;;
        "delete_tag")
            delete_release_by_tag "$2"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 检查依赖
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo "❌ 错误: 需要安装 curl"
        exit 1
    fi
}

# 脚本入口
check_dependencies
main "$@"