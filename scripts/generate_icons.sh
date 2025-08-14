#!/bin/bash

# App图标生成脚本
# 从SVG源文件生成macOS应用所需的各种尺寸图标

set -e

SVG_SOURCE="assets/x-google-drive-downloader-concrete.svg"
ICONS_DIR="macos/Runner/Assets.xcassets/AppIcon.appiconset"
OUTPUT_DIR="generated_icons"

echo "🎨 开始生成应用图标..."
echo "📍 SVG源文件: $SVG_SOURCE"
echo "🎯 输出目录: $ICONS_DIR"

# 检查SVG文件是否存在
if [ ! -f "$SVG_SOURCE" ]; then
    echo "❌ 错误: SVG文件不存在: $SVG_SOURCE"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"
mkdir -p "$ICONS_DIR"

# macOS应用图标所需的尺寸
# 参考: https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/
declare -a sizes=(
    "16:icon_16x16.png"
    "32:icon_16x16@2x.png"
    "32:icon_32x32.png"
    "64:icon_32x32@2x.png"
    "128:icon_128x128.png" 
    "256:icon_128x128@2x.png"
    "256:icon_256x256.png"
    "512:icon_256x256@2x.png"
    "512:icon_512x512.png"
    "1024:icon_512x512@2x.png"
)

# 检查是否安装了转换工具
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
    echo "❌ 错误: 需要安装以下工具之一:"
    echo "  - librsvg: brew install librsvg"
    echo "  - inkscape: brew install inkscape"
    echo "  - imagemagick: brew install imagemagick"
    exit 1
fi

# 生成图标函数
generate_icon() {
    local size=$1
    local filename=$2
    local output_path="$OUTPUT_DIR/$filename"
    
    echo "📐 生成 ${size}x${size} -> $filename"
    
    case $CONVERTER in
        "rsvg-convert")
            rsvg-convert -w $size -h $size "$SVG_SOURCE" -o "$output_path"
            ;;
        "inkscape")
            inkscape --export-png="$output_path" --export-width=$size --export-height=$size "$SVG_SOURCE"
            ;;
        "imagemagick")
            convert -background transparent "$SVG_SOURCE" -resize ${size}x${size} "$output_path"
            ;;
    esac
    
    if [ -f "$output_path" ]; then
        echo "  ✅ 成功生成: $output_path"
        # 复制到最终位置
        cp "$output_path" "$ICONS_DIR/$filename"
    else
        echo "  ❌ 生成失败: $filename"
        return 1
    fi
}

# 生成所有尺寸的图标
echo ""
echo "🔄 开始生成各种尺寸的图标..."

for item in "${sizes[@]}"; do
    IFS=":" read -r size filename <<< "$item"
    generate_icon "$size" "$filename"
done

# 生成Contents.json文件
echo ""
echo "📝 生成Contents.json配置文件..."

cat > "$ICONS_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "icon_16x16.png",
      "scale" : "1x"
    },
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "icon_16x16@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "icon_32x32.png",
      "scale" : "1x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "icon_32x32@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "icon_128x128.png",
      "scale" : "1x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "icon_128x128@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "icon_256x256.png",
      "scale" : "1x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "icon_256x256@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "icon_512x512.png",
      "scale" : "1x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "icon_512x512@2x.png",
      "scale" : "2x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ Contents.json 生成完成"

# 创建用于DMG的高分辨率图标
echo ""
echo "🎯 创建DMG专用图标..."
generate_icon "1024" "app_icon_1024.png"

# 生成用于README的图标
generate_icon "128" "user_icon.png"
cp "$OUTPUT_DIR/user_icon.png" "./user_icon.png"
echo "✅ README图标已复制到根目录"

# 验证所有文件
echo ""
echo "🔍 验证生成的图标文件..."
total_files=0
success_files=0

for item in "${sizes[@]}"; do
    IFS=":" read -r size filename <<< "$item"
    if [ -f "$ICONS_DIR/$filename" ]; then
        file_size=$(wc -c < "$ICONS_DIR/$filename")
        echo "  ✅ $filename (${file_size} bytes)"
        success_files=$((success_files + 1))
    else
        echo "  ❌ $filename (缺失)"
    fi
    total_files=$((total_files + 1))
done

# 显示结果
echo ""
echo "🎉 图标生成完成！"
echo "📊 统计信息:"
echo "   成功生成: $success_files/$total_files 个图标"
echo "   输出目录: $ICONS_DIR"
echo "   临时文件: $OUTPUT_DIR"

if [ $success_files -eq $total_files ]; then
    echo "✅ 所有图标生成成功！"
    
    # 清理临时文件
    echo ""
    read -p "是否删除临时文件? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$OUTPUT_DIR"
        echo "🗑️ 临时文件已清理"
    fi
    
    echo ""
    echo "🚀 下一步:"
    echo "1. 运行 flutter clean && flutter build macos 重新构建"
    echo "2. 检查应用图标是否正确显示"
    echo "3. 如需创建DMG，运行 ./create_dmg.sh"
    
else
    echo "⚠️ 部分图标生成失败，请检查错误信息"
fi