#!/usr/bin/env python3
"""
App图标生成脚本
从SVG源文件生成macOS应用所需的各种尺寸图标
"""

import os
import sys
import subprocess
import json
from pathlib import Path

def main():
    print("🎨 开始生成应用图标...")
    
    # 配置路径
    svg_source = "assets/x-google-drive-downloader-concrete.svg"
    icons_dir = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    output_dir = "generated_icons"
    
    print(f"📍 SVG源文件: {svg_source}")
    print(f"🎯 输出目录: {icons_dir}")
    
    # 检查SVG文件
    if not os.path.exists(svg_source):
        print(f"❌ 错误: SVG文件不存在: {svg_source}")
        sys.exit(1)
    
    # 创建输出目录
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(icons_dir, exist_ok=True)
    
    # macOS应用图标尺寸配置
    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]
    
    # 尝试找到可用的转换工具
    converter = find_converter()
    if not converter:
        print("❌ 错误: 未找到可用的SVG转换工具")
        print("建议安装以下工具之一:")
        print("  pip3 install cairosvg")
        print("  pip3 install Pillow")
        print("  brew install librsvg")
        print("  brew install inkscape")
        sys.exit(1)
    
    print(f"✅ 使用转换工具: {converter}")
    
    # 生成图标
    print("\n🔄 开始生成各种尺寸的图标...")
    success_count = 0
    
    for size, filename in sizes:
        print(f"📐 生成 {size}x{size} -> {filename}")
        if generate_icon(svg_source, size, output_dir, filename, converter):
            # 复制到最终位置
            src_path = os.path.join(output_dir, filename)
            dst_path = os.path.join(icons_dir, filename)
            
            try:
                import shutil
                shutil.copy2(src_path, dst_path)
                print(f"  ✅ 成功生成: {dst_path}")
                success_count += 1
            except Exception as e:
                print(f"  ❌ 复制失败: {e}")
        else:
            print(f"  ❌ 生成失败: {filename}")
    
    # 生成Contents.json
    print("\n📝 生成Contents.json配置文件...")
    generate_contents_json(icons_dir)
    
    # 生成额外图标
    print("\n🎯 创建额外图标文件...")
    
    # DMG用高分辨率图标
    generate_icon(svg_source, 1024, output_dir, "app_icon_1024.png", converter)
    
    # README用图标
    if generate_icon(svg_source, 128, output_dir, "user_icon.png", converter):
        try:
            import shutil
            shutil.copy2(os.path.join(output_dir, "user_icon.png"), "user_icon.png")
            print("✅ README图标已复制到根目录")
        except Exception as e:
            print(f"❌ 复制README图标失败: {e}")
    
    # 显示结果
    print(f"\n🎉 图标生成完成！")
    print(f"📊 统计信息:")
    print(f"   成功生成: {success_count}/{len(sizes)} 个图标")
    print(f"   输出目录: {icons_dir}")
    
    if success_count == len(sizes):
        print("✅ 所有图标生成成功！")
        print("\n🚀 下一步:")
        print("1. 运行 flutter clean && flutter build macos 重新构建")
        print("2. 检查应用图标是否正确显示") 
        print("3. 如需创建DMG，运行 ./create_dmg.sh")
    else:
        print("⚠️ 部分图标生成失败，请检查错误信息")

def find_converter():
    """查找可用的SVG转换工具"""
    # 检查Python库
    try:
        import cairosvg
        return "cairosvg"
    except ImportError:
        pass
    
    # 检查系统工具
    tools = [
        ("rsvg-convert", "librsvg"),
        ("inkscape", "inkscape"), 
        ("convert", "imagemagick")
    ]
    
    for tool, name in tools:
        if subprocess.run(["which", tool], capture_output=True, text=True).returncode == 0:
            return name
    
    return None

def generate_icon(svg_path, size, output_dir, filename, converter):
    """生成指定尺寸的图标"""
    output_path = os.path.join(output_dir, filename)
    
    try:
        if converter == "cairosvg":
            import cairosvg
            cairosvg.svg2png(
                url=svg_path,
                write_to=output_path,
                output_width=size,
                output_height=size
            )
        elif converter == "librsvg":
            subprocess.run([
                "rsvg-convert",
                "-w", str(size),
                "-h", str(size), 
                svg_path,
                "-o", output_path
            ], check=True, capture_output=True)
        elif converter == "inkscape":
            subprocess.run([
                "inkscape",
                f"--export-png={output_path}",
                f"--export-width={size}",
                f"--export-height={size}",
                svg_path
            ], check=True, capture_output=True)
        elif converter == "imagemagick":
            subprocess.run([
                "convert",
                "-background", "transparent",
                svg_path,
                "-resize", f"{size}x{size}",
                output_path
            ], check=True, capture_output=True)
        
        return os.path.exists(output_path)
    except Exception as e:
        print(f"    错误: {e}")
        return False

def generate_contents_json(icons_dir):
    """生成Contents.json配置文件"""
    contents = {
        "images": [
            {
                "size": "16x16",
                "idiom": "mac",
                "filename": "icon_16x16.png",
                "scale": "1x"
            },
            {
                "size": "16x16", 
                "idiom": "mac",
                "filename": "icon_16x16@2x.png",
                "scale": "2x"
            },
            {
                "size": "32x32",
                "idiom": "mac", 
                "filename": "icon_32x32.png",
                "scale": "1x"
            },
            {
                "size": "32x32",
                "idiom": "mac",
                "filename": "icon_32x32@2x.png", 
                "scale": "2x"
            },
            {
                "size": "128x128",
                "idiom": "mac",
                "filename": "icon_128x128.png",
                "scale": "1x"
            },
            {
                "size": "128x128",
                "idiom": "mac", 
                "filename": "icon_128x128@2x.png",
                "scale": "2x"
            },
            {
                "size": "256x256",
                "idiom": "mac",
                "filename": "icon_256x256.png",
                "scale": "1x"
            },
            {
                "size": "256x256",
                "idiom": "mac",
                "filename": "icon_256x256@2x.png",
                "scale": "2x"
            },
            {
                "size": "512x512", 
                "idiom": "mac",
                "filename": "icon_512x512.png",
                "scale": "1x"
            },
            {
                "size": "512x512",
                "idiom": "mac",
                "filename": "icon_512x512@2x.png",
                "scale": "2x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    contents_path = os.path.join(icons_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    
    print("✅ Contents.json 生成完成")

if __name__ == "__main__":
    main()