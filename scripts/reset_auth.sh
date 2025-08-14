#!/bin/bash

# OAuth认证重置脚本
# 清除所有存储的认证信息，让应用重新进入配置流程

set -e

APP_NAME="X Google Drive Downloader"

echo "🔄 重置 ${APP_NAME} OAuth认证配置"
echo "=" * 50

# 1. 清除macOS Keychain中的认证信息
echo "🔐 清除Keychain认证信息..."
security delete-generic-password -s "x_google_drive_downloader_auth_tokens" 2>/dev/null || echo "  认证令牌不存在"
security delete-generic-password -s "x_google_drive_downloader_user_info" 2>/dev/null || echo "  用户信息不存在"
security delete-generic-password -s "x_google_drive_downloader_custom_config" 2>/dev/null || echo "  自定义配置不存在"

# 2. 清除SharedPreferences（通过删除plist文件）
echo "📱 清除SharedPreferences..."
APP_ID="com.xiong.googledrivedownload"
PREFS_PATH="$HOME/Library/Preferences/${APP_ID}.plist"

if [ -f "$PREFS_PATH" ]; then
    rm -f "$PREFS_PATH"
    echo "  ✅ 已删除: $PREFS_PATH"
else
    echo "  ℹ️ 配置文件不存在: $PREFS_PATH"
fi

# 3. 清除可能的应用数据目录
echo "📂 清除应用数据目录..."
APP_DATA_DIRS=(
    "$HOME/Library/Containers/${APP_ID}"
    "$HOME/Library/Application Support/${APP_NAME}"
    "$HOME/Library/Caches/${APP_ID}"
)

for dir in "${APP_DATA_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "  ✅ 已删除: $dir"
    else
        echo "  ℹ️ 目录不存在: $dir"
    fi
done

# 4. 清除Flutter的本地存储
echo "🗄️ 清除Flutter本地存储..."
FLUTTER_STORAGE_DIRS=(
    "$HOME/Library/Containers/${APP_ID}/Data/Documents"
    "$HOME/Library/Containers/${APP_ID}/Data/Library"
)

for dir in "${FLUTTER_STORAGE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"/*
        echo "  ✅ 已清空: $dir"
    else
        echo "  ℹ️ 目录不存在: $dir"
    fi
done

# 5. 清除可能的临时文件
echo "🧹 清除临时文件..."
TEMP_PATTERNS=(
    "/tmp/*google_drive_downloader*"
    "/tmp/*oauth*"
    "/var/folders/*/T/*google*"
)

for pattern in "${TEMP_PATTERNS[@]}"; do
    find ${pattern} -maxdepth 1 -type f -delete 2>/dev/null || true
done

echo ""
echo "✅ OAuth认证重置完成！"
echo ""
echo "🚀 下次启动应用时，将会："
echo "   1. 进入OAuth配置向导"
echo "   2. 让您选择使用内置凭据或自定义配置"
echo "   3. 如选择自定义，将引导您完成设置"
echo ""
echo "💡 提示："
echo "   - Debug模式下需要自定义OAuth凭据"
echo "   - Release模式可以使用内置凭据（如果可用）"
echo "   - 建议使用DMG分发版本以获得最佳体验"
echo ""

# 6. 询问是否立即启动应用
read -p "是否立即启动应用测试配置? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎯 启动应用..."
    if [ -f "build/macos/Build/Products/Release/${APP_NAME}.app/Contents/MacOS/${APP_NAME}" ]; then
        open "build/macos/Build/Products/Release/${APP_NAME}.app"
    else
        echo "⚠️ Release版本不存在，请先运行: flutter build macos --release"
        echo "或运行Debug模式: flutter run -d macos --debug"
    fi
fi