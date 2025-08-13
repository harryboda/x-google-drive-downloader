#!/bin/bash

# Google Drive Downloader 运行脚本
# 此脚本简化了环境变量设置和应用运行过程

set -e

echo "🚀 Google Drive Downloader v2.0"
echo "================================="

# 检查 .env 文件是否存在
if [ ! -f .env ]; then
    echo "❌ 未找到 .env 配置文件"
    echo "请按以下步骤配置:"
    echo "1. 复制示例文件: cp .env.example .env"
    echo "2. 编辑 .env 文件，填入你的Google OAuth凭证"
    echo "3. 重新运行此脚本"
    exit 1
fi

# 加载环境变量
echo "📋 加载环境变量..."
source .env

# 检查必要的环境变量
if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
    echo "❌ 环境变量未正确设置"
    echo "请确保 .env 文件中包含以下变量:"
    echo "- GOOGLE_CLIENT_ID"
    echo "- GOOGLE_CLIENT_SECRET"
    exit 1
fi

echo "✅ 环境变量已加载"
echo "🔧 客户端ID: ${GOOGLE_CLIENT_ID:0:10}..."

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo "❌ 未找到Flutter命令，请确保Flutter已正确安装"
    exit 1
fi

# 获取依赖
echo "📦 获取Flutter依赖..."
flutter pub get

# 生成代码
echo "⚙️ 生成序列化代码..."
dart run build_runner build --delete-conflicting-outputs

# 运行应用
echo "🎯 启动应用..."
flutter run -d macos \
    --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
    --dart-define=GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET"

echo "✨ 应用已启动！"