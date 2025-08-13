#!/bin/bash

# 自动截图脚本 - X Google Drive Downloader
# 此脚本会自动启动应用，等待加载，然后截取应用窗口

set -e

echo "🖥️ 开始自动截图流程..."

# 创建screenshots目录
mkdir -p screenshots

# 1. 构建并启动应用（后台运行）
echo "📱 启动应用..."
flutter run -d macos --release &
FLUTTER_PID=$!

# 等待应用启动
echo "⏳ 等待应用启动 (15秒)..."
sleep 15

# 2. 查找应用窗口并截图
APP_NAME="X Google Drive Downloader"

echo "📸 开始截图..."

# 截图1: 主界面
echo "  - 截取主界面..."
screencapture -w -x screenshots/01_main_interface.png

# 等待一下让用户看到截图提示
sleep 2

# 截图2: 应用图标和关于信息（点击菜单）
echo "  - 模拟菜单操作..."
# 使用AppleScript模拟点击菜单
osascript << EOF
tell application "System Events"
    tell application "$APP_NAME" to activate
    delay 1
    key code 53 -- ESC键确保菜单关闭
    delay 0.5
end tell
EOF

sleep 1
screencapture -w -x screenshots/02_app_window.png

# 3. 使用AppleScript模拟输入URL
echo "  - 模拟输入URL..."
osascript << EOF
tell application "System Events"
    tell application "$APP_NAME" to activate
    delay 1
    -- 假设有文本输入框，输入示例URL
    keystroke "https://drive.google.com/drive/folders/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
    delay 2
end tell
EOF

sleep 1
screencapture -w -x screenshots/03_with_url.png

# 4. 截取整体应用截图（包含标题栏）
echo "  - 截取完整窗口..."
screencapture -w screenshots/04_full_window.png

# 5. 截取应用图标
echo "  - 截取应用图标..."
cp "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png" "screenshots/05_app_icon.png"

# 关闭应用
echo "🛑 关闭应用..."
kill $FLUTTER_PID 2>/dev/null || true

# 等待进程完全关闭
sleep 2

# 验证截图文件
echo "✅ 截图完成，文件列表："
ls -la screenshots/

# 优化截图尺寸（确保适合GitHub显示）
echo "🔄 优化截图尺寸..."
for img in screenshots/*.png; do
    if [[ -f "$img" ]]; then
        # 使用sips调整图片大小（macOS内置工具）
        sips -Z 800 "$img" --out "$img" > /dev/null 2>&1 || true
        echo "  优化完成: $(basename "$img")"
    fi
done

echo "🎉 自动截图流程完成！"
echo "📁 截图保存位置: $(pwd)/screenshots/"