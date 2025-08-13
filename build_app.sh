#!/bin/bash

# Google Drive Downloader 构建脚本
# 用于构建生产环境的应用

set -e

echo "🏗️ Google Drive Downloader 构建脚本"
echo "====================================="

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

# 清理旧的构建文件
echo "🧹 清理旧的构建文件..."
flutter clean

# 获取依赖
echo "📦 获取Flutter依赖..."
flutter pub get

# 生成代码
echo "⚙️ 生成序列化代码..."
dart run build_runner build --delete-conflicting-outputs

# 构建应用
echo "🔨 构建macOS应用..."
flutter build macos --release \
    --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
    --dart-define=GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET"

echo "✅ 构建完成！"
echo "📍 应用位置: build/macos/Build/Products/Release/gdrive_downloader_flutter.app"
echo ""
echo "🚀 要运行应用，执行:"
echo "open build/macos/Build/Products/Release/gdrive_downloader_flutter.app"