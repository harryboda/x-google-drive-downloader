#!/bin/bash

# 真实macOS应用截图系统
# 启动Flutter应用并自动截取真实的应用截图

set -e

APP_NAME="X Google Drive Downloader"
SCREENSHOTS_DIR="screenshots"
BUILD_DIR="build/macos/Build/Products/Debug"

echo "📸 开始真实应用截图流程..."

# 1. 确保应用已构建
echo "🔨 检查应用构建状态..."
if [ ! -d "$BUILD_DIR/X Google Drive Downloader.app" ]; then
    echo "  构建Debug版本应用..."
    flutter build macos --debug
fi

# 2. 创建截图目录
mkdir -p "$SCREENSHOTS_DIR"

# 3. 启动应用
echo "🚀 启动应用..."
open "$BUILD_DIR/X Google Drive Downloader.app"

# 等待应用完全启动
echo "⏳ 等待应用启动 (8秒)..."
sleep 8

# 4. 确保应用窗口处于前台
echo "🎯 激活应用窗口..."
osascript << EOF
tell application "System Events"
    set appName to "$APP_NAME"
    try
        tell application appName to activate
        delay 1
        -- 确保窗口完全加载
        delay 2
    on error
        display dialog "无法找到应用: " & appName
    end try
end tell
EOF

# 5. 截图1: 主界面（启动状态）
echo "📷 截图1: 应用主界面..."
screencapture -w -x "$SCREENSHOTS_DIR/01_main_interface_real.png"
echo "  ✅ 主界面截图完成"

sleep 2

# 6. 模拟用户输入URL
echo "📝 模拟输入Google Drive URL..."
osascript << EOF
tell application "System Events"
    tell application "$APP_NAME" to activate
    delay 1
    
    -- 模拟点击输入框并输入URL
    keystroke "https://drive.google.com/drive/folders/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
    delay 2
end tell
EOF

# 7. 截图2: 输入URL后的界面
echo "📷 截图2: 输入URL后的界面..."
screencapture -w -x "$SCREENSHOTS_DIR/02_with_url_real.png"
echo "  ✅ URL输入截图完成"

sleep 2

# 8. 尝试打开应用菜单或设置（如果有）
echo "🔧 尝试访问应用菜单..."
osascript << EOF
tell application "System Events"
    tell application "$APP_NAME" to activate
    delay 1
    
    -- 尝试使用Cmd+comma打开设置（macOS标准）
    key code 43 using {command down}
    delay 3
end tell
EOF

# 9. 截图3: 设置或菜单界面（如果存在）
echo "📷 截图3: 设置界面..."
screencapture -w -x "$SCREENSHOTS_DIR/03_settings_real.png" 2>/dev/null || echo "  ⚠️ 设置界面截图可选"

sleep 2

# 10. 回到主界面并截取完整窗口
echo "📷 截图4: 完整应用窗口..."
osascript << EOF
tell application "System Events"
    tell application "$APP_NAME" to activate
    delay 1
    key code 53 -- ESC key
    delay 1
end tell
EOF

screencapture -w "$SCREENSHOTS_DIR/04_full_window_real.png"
echo "  ✅ 完整窗口截图完成"

# 11. 关闭应用
echo "🛑 关闭应用..."
osascript << EOF
tell application "$APP_NAME"
    quit
end tell
EOF

# 等待应用完全关闭
sleep 2

# 12. 优化截图尺寸和质量
echo "🔄 优化截图质量..."
for img in "$SCREENSHOTS_DIR"/*_real.png; do
    if [[ -f "$img" ]]; then
        # 使用sips优化图片（macOS内置工具）
        sips -Z 1200 "$img" --out "$img" > /dev/null 2>&1
        # 压缩文件大小但保持质量
        sips -s format png -s formatOptions 90 "$img" --out "$img" > /dev/null 2>&1
        echo "  ✅ 优化完成: $(basename "$img")"
    fi
done

# 13. 显示结果
echo ""
echo "🎉 真实应用截图完成！"
echo "📁 截图保存位置: $(pwd)/$SCREENSHOTS_DIR/"
echo ""
echo "📷 生成的截图："
ls -la "$SCREENSHOTS_DIR"/*_real.png 2>/dev/null || echo "  检查截图文件..."

echo ""
echo "💡 提示："
echo "  - 如果截图效果不理想，可以手动调整应用窗口大小后重新运行"
echo "  - 确保在运行期间不要移动或点击其他窗口"
echo "  - 如果应用界面有特殊功能，可以编辑此脚本添加更多交互"