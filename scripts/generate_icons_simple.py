#!/usr/bin/env python3
"""
简化版图标生成脚本
使用macOS自带的qlmanage工具转换SVG
"""

import os
import sys
import subprocess
import json
import tempfile
from pathlib import Path

def main():
    print("🎨 开始生成应用图标 (使用macOS内置工具)...")
    
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
    
    print("✅ 使用macOS内置的SVG处理工具")
    
    # 先创建一个基础的大尺寸PNG图像
    print("\n🔄 先生成基础1024x1024图像...")
    base_png = os.path.join(output_dir, "base_1024.png")
    
    if create_base_png_with_html(svg_source, base_png):
        print("✅ 基础PNG图像生成成功")
    else:
        print("❌ 基础PNG图像生成失败")
        # 尝试创建简单的彩色替代图标
        create_fallback_icon(base_png)
    
    # 从基础图像生成各种尺寸
    print("\n🔄 开始生成各种尺寸的图标...")
    success_count = 0
    
    for size, filename in sizes:
        print(f"📐 生成 {size}x{size} -> {filename}")
        if resize_image_with_sips(base_png, size, output_dir, filename):
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
    
    # 复制1024版本用于DMG
    try:
        import shutil
        shutil.copy2(base_png, os.path.join(output_dir, "app_icon_1024.png"))
    except:
        pass
    
    # README用图标 (128px)
    if resize_image_with_sips(base_png, 128, output_dir, "user_icon.png"):
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

def create_base_png_with_html(svg_path, output_path):
    """使用HTML包装SVG，然后用webkit2png转换"""
    try:
        # 读取SVG内容
        with open(svg_path, 'r') as f:
            svg_content = f.read()
        
        # 创建HTML包装
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ 
                    margin: 0; 
                    padding: 0; 
                    background: transparent; 
                    width: 1024px; 
                    height: 1024px; 
                }}
                svg {{ 
                    width: 1024px; 
                    height: 1024px; 
                }}
            </style>
        </head>
        <body>
            {svg_content}
        </body>
        </html>
        """
        
        # 创建临时HTML文件
        with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
            f.write(html_content)
            html_path = f.name
        
        try:
            # 使用webkit2png (如果可用)
            result = subprocess.run([
                '/usr/bin/python', '-c',
                f'''
import subprocess
import sys
import os

try:
    # 尝试使用webkit2png
    subprocess.run([
        "webkit2png",
        "--width=1024",
        "--height=1024", 
        "--fullsize",
        "--format=png",
        "--output={output_path}",
        "file://{html_path}"
    ], check=True, capture_output=True)
    print("webkit2png success")
except:
    # 使用备选方案
    try:
        subprocess.run([
            "osascript", "-e",
            f"""
            tell application "Safari"
                open "file://{html_path}"
                delay 2
            end tell
            """
        ], check=True, capture_output=True)
        print("Safari backup used")
    except:
        print("All methods failed")
        sys.exit(1)
                '''
            ], capture_output=True, text=True, timeout=30)
            
            return os.path.exists(output_path) and os.path.getsize(output_path) > 1000
            
        finally:
            # 清理临时文件
            try:
                os.unlink(html_path)
            except:
                pass
            
    except Exception as e:
        print(f"    HTML转换错误: {e}")
        return False

def create_fallback_icon(output_path):
    """创建备用的彩色图标"""
    try:
        # 使用Python PIL创建简单图标
        try:
            from PIL import Image, ImageDraw
            
            # 创建1024x1024的图像
            img = Image.new('RGBA', (1024, 1024), (255, 255, 255, 0))
            draw = ImageDraw.Draw(img)
            
            # 绘制Google Drive风格的三角形
            # 蓝色三角形
            draw.polygon([(300, 612), (400, 452), (500, 612)], fill='#4285F4')
            # 绿色三角形  
            draw.polygon([(500, 612), (600, 612), (500, 452)], fill='#0F9D58')
            # 黄色三角形
            draw.polygon([(300, 612), (500, 612), (600, 612), (530, 712), (370, 712)], fill='#F4B400')
            
            # X字母
            draw.ellipse([520, 430, 610, 520], fill='white', outline='#202124', width=4)
            # X的两条线
            draw.line([540, 450, 590, 500], fill='#202124', width=6)
            draw.line([540, 500, 590, 450], fill='#202124', width=6)
            
            # 下载箭头
            draw.ellipse([472, 732, 552, 812], fill='#4285F4')
            # 箭头杆
            draw.rectangle([509, 752, 515, 777], fill='white')
            # 箭头头部
            draw.polygon([(497, 785), (512, 800), (527, 785), (522, 785), (512, 795), (502, 785)], fill='white')
            
            img.save(output_path, 'PNG')
            print("✅ 使用PIL创建备用图标")
            return True
            
        except ImportError:
            # PIL不可用，创建简单的颜色块
            print("⚠️ PIL不可用，创建简单图标")
            return False
            
    except Exception as e:
        print(f"    备用图标创建错误: {e}")
        return False

def resize_image_with_sips(input_path, size, output_dir, filename):
    """使用macOS的sips工具调整图像尺寸"""
    output_path = os.path.join(output_dir, filename)
    
    try:
        subprocess.run([
            "sips",
            "-Z", str(size),
            input_path,
            "--out", output_path
        ], check=True, capture_output=True)
        
        return os.path.exists(output_path) and os.path.getsize(output_path) > 100
        
    except subprocess.CalledProcessError as e:
        print(f"    sips错误: {e}")
        return False
    except Exception as e:
        print(f"    调整尺寸错误: {e}")
        return False

def generate_contents_json(icons_dir):
    """生成Contents.json配置文件"""
    contents = {
        "images": [
            {"size": "16x16", "idiom": "mac", "filename": "icon_16x16.png", "scale": "1x"},
            {"size": "16x16", "idiom": "mac", "filename": "icon_16x16@2x.png", "scale": "2x"},
            {"size": "32x32", "idiom": "mac", "filename": "icon_32x32.png", "scale": "1x"},
            {"size": "32x32", "idiom": "mac", "filename": "icon_32x32@2x.png", "scale": "2x"},
            {"size": "128x128", "idiom": "mac", "filename": "icon_128x128.png", "scale": "1x"},
            {"size": "128x128", "idiom": "mac", "filename": "icon_128x128@2x.png", "scale": "2x"},
            {"size": "256x256", "idiom": "mac", "filename": "icon_256x256.png", "scale": "1x"},
            {"size": "256x256", "idiom": "mac", "filename": "icon_256x256@2x.png", "scale": "2x"},
            {"size": "512x512", "idiom": "mac", "filename": "icon_512x512.png", "scale": "1x"},
            {"size": "512x512", "idiom": "mac", "filename": "icon_512x512@2x.png", "scale": "2x"}
        ],
        "info": {"author": "xcode", "version": 1}
    }
    
    contents_path = os.path.join(icons_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    
    print("✅ Contents.json 生成完成")

if __name__ == "__main__":
    main()