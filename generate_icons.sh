#!/bin/bash

# X Google Drive Downloader 图标生成脚本
# 将SVG logo转换为所有需要的PNG尺寸

set -e

LOGO_SVG="assets/logo.svg"
ICON_DIR="macos/Runner/Assets.xcassets/AppIcon.appiconset"

echo "🎨 开始生成 X Google Drive Downloader 应用图标"
echo "=" * 50

# 检查SVG文件是否存在
if [ ! -f "$LOGO_SVG" ]; then
    echo "❌ 错误：找不到logo.svg文件"
    echo "请确保 $LOGO_SVG 文件存在"
    exit 1
fi

# 创建assets目录
mkdir -p assets

# 检查是否有可用的转换工具
CONVERTER=""
if command -v rsvg-convert &> /dev/null; then
    CONVERTER="rsvg-convert"
    echo "✅ 使用 rsvg-convert 进行转换"
elif command -v inkscape &> /dev/null; then
    CONVERTER="inkscape"
    echo "✅ 使用 Inkscape 进行转换"
elif command -v convert &> /dev/null; then
    CONVERTER="imagemagick"
    echo "✅ 使用 ImageMagick 进行转换"
else
    echo "⚠️ 未找到合适的SVG转PNG工具"
    echo "请安装以下工具之一："
    echo "  - rsvg-convert: brew install librsvg"
    echo "  - Inkscape: brew install --cask inkscape"
    echo "  - ImageMagick: brew install imagemagick"
    echo ""
    echo "或者使用在线工具转换SVG到PNG："
    echo "1. 打开 https://cloudconvert.com/svg-to-png"
    echo "2. 上传 assets/logo.svg"
    echo "3. 设置尺寸并下载PNG文件"
    echo "4. 重命名文件并放入 $ICON_DIR/ 目录"
    exit 1
fi

# 定义所需的图标尺寸
declare -a sizes=("16" "32" "64" "128" "256" "512" "1024")

echo "📐 生成不同尺寸的图标..."

for size in "${sizes[@]}"; do
    output_file="$ICON_DIR/app_icon_${size}.png"
    
    case $CONVERTER in
        "rsvg-convert")
            rsvg-convert -w $size -h $size "$LOGO_SVG" -o "$output_file"
            ;;
        "inkscape")
            inkscape "$LOGO_SVG" --export-png="$output_file" -w $size -h $size
            ;;
        "imagemagick")
            convert -background none -size ${size}x${size} "$LOGO_SVG" "$output_file"
            ;;
    esac
    
    if [ -f "$output_file" ]; then
        file_size=$(du -h "$output_file" | cut -f1)
        echo "  ✅ ${size}x${size} -> $output_file (${file_size})"
    else
        echo "  ❌ 生成 ${size}x${size} 失败"
    fi
done

# 验证所有图标文件
echo ""
echo "🔍 验证生成的图标文件..."
missing_files=()
for size in "${sizes[@]}"; do
    file_path="$ICON_DIR/app_icon_${size}.png"
    if [ -f "$file_path" ]; then
        echo "  ✅ app_icon_${size}.png"
    else
        echo "  ❌ app_icon_${size}.png (缺失)"
        missing_files+=("$size")
    fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
    echo ""
    echo "🎉 所有图标文件生成成功！"
    echo "📁 图标位置: $ICON_DIR/"
    echo ""
    echo "下一步："
    echo "1. 运行 flutter clean"
    echo "2. 运行 flutter build macos --release"
    echo "3. 检查新图标是否正确显示"
    echo ""
    echo "🔧 如果需要调整logo设计："
    echo "1. 编辑 $LOGO_SVG"
    echo "2. 重新运行此脚本"
else
    echo ""
    echo "⚠️ 有部分图标文件生成失败"
    echo "缺失的尺寸: ${missing_files[*]}"
    echo "请检查转换工具和SVG文件"
fi

echo ""
echo "💡 图标设计说明："
echo "  🔵 蓝色云朵 - 代表Google Drive云存储"
echo "  ⬇️ 渐变箭头 - 表示下载功能"
echo "  ❌ X标识 - 品牌标识符"
echo "  🟢 完成点 - 下载成功指示"