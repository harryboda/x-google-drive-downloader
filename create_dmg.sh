#!/bin/bash

# Google Drive Downloader v2.0 DMG 创建脚本
# 自动构建并创建可分发的 DMG 安装包

set -e  # 遇到错误立即退出

APP_NAME="X Google Drive Downloader"
APP_VERSION="2.1.1"
DMG_NAME="XGoogleDriveDownloader-v${APP_VERSION}"
BUILD_DIR="build/macos/Build/Products/Release"
TEMP_DMG_DIR="/tmp/${DMG_NAME}"

echo "🚀 开始创建 ${APP_NAME} v${APP_VERSION} DMG 安装包"
echo "=" * 60

# 1. 清理之前的构建
echo "🧹 清理之前的构建..."
flutter clean
rm -rf "${TEMP_DMG_DIR}"
mkdir -p "${TEMP_DMG_DIR}"

# 2. 构建 Release 版本
echo "🔨 构建 Release 版本..."
flutter build macos --release

# 检查构建是否成功
if [ ! -d "${BUILD_DIR}/${APP_NAME}.app" ]; then
    echo "❌ 构建失败：找不到应用程序包"
    echo "尝试查找: ${BUILD_DIR}/${APP_NAME}.app"
    ls -la "${BUILD_DIR}/"
    exit 1
fi

echo "✅ 构建成功"

# 3. 复制应用到临时目录
echo "📦 准备 DMG 内容..."
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${TEMP_DMG_DIR}/${APP_NAME}.app"

# 4. 创建 Applications 文件夹快捷方式
ln -s /Applications "${TEMP_DMG_DIR}/Applications"

# 5. 创建安装说明文件
cat > "${TEMP_DMG_DIR}/安装说明.txt" << EOF
Google Drive Downloader v${APP_VERSION} 安装说明
============================================

安装步骤：
1. 将 "${APP_NAME}.app" 拖拽到 "Applications" 文件夹中
2. 打开 "应用程序" 文件夹，找到 "${APP_NAME}"
3. 首次运行时，如果系统提示"无法打开，因为它来自身份不明的开发者"：
   - 按住 Control 键点击应用图标
   - 选择"打开"
   - 在弹出对话框中点击"打开"

功能特性：
✅ 内置 Google Drive API 认证，无需额外配置
✅ 智能剪贴板监听，自动识别 Google Drive 链接
✅ 持久化登录，一次授权长期使用
✅ 现代化 macOS 设计界面
✅ 安全的多级存储加密

使用方法：
1. 启动应用后完成 Google 账户授权
2. 粘贴 Google Drive 文件夹分享链接
3. 选择保存位置并开始下载

问题反馈：
如有问题，请访问项目主页获取支持。

© 2025 Google Drive Downloader v${APP_VERSION}
EOF

# 6. 创建 DMG 文件
echo "💿 创建 DMG 安装包..."
DMG_PATH="${DMG_NAME}.dmg"

# 删除已存在的 DMG 文件
[ -f "${DMG_PATH}" ] && rm "${DMG_PATH}"

# 使用 hdiutil 创建 DMG
hdiutil create -size 200m -srcfolder "${TEMP_DMG_DIR}" -volname "${APP_NAME} v${APP_VERSION}" -format UDZO -o "${DMG_PATH}"

# 7. 验证 DMG 创建
if [ -f "${DMG_PATH}" ]; then
    DMG_SIZE=$(du -h "${DMG_PATH}" | cut -f1)
    echo "✅ DMG 创建成功"
    echo "📁 文件路径: $(pwd)/${DMG_PATH}"
    echo "💾 文件大小: ${DMG_SIZE}"
else
    echo "❌ DMG 创建失败"
    exit 1
fi

# 8. 清理临时文件
echo "🧹 清理临时文件..."
rm -rf "${TEMP_DMG_DIR}"

# 9. 显示完成信息
echo ""
echo "🎉 DMG 安装包创建完成！"
echo "=" * 60
echo "📊 构建信息："
echo "   应用名称: ${APP_NAME}"
echo "   版本号: ${APP_VERSION}"
echo "   安装包: ${DMG_PATH}"
echo "   大小: ${DMG_SIZE}"
echo ""
echo "🔧 分发说明："
echo "   1. 用户下载 ${DMG_PATH}"
echo "   2. 双击打开 DMG 文件"
echo "   3. 拖拽应用到 Applications 文件夹"
echo "   4. 首次运行需要在系统偏好设置中允许"
echo ""
echo "✨ v2.0 特性："
echo "   ✅ 无需环境变量配置"
echo "   ✅ 内置 OAuth 凭据"
echo "   ✅ 持久化认证存储"
echo "   ✅ 现代化用户界面"
echo "   ✅ 独立可分发应用"

# 10. 可选：自动打开 DMG 预览
read -p "是否要打开 DMG 文件预览？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "${DMG_PATH}"
fi

echo "🏁 完成！"