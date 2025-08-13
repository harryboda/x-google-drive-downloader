#!/usr/bin/env python3
"""
提取用户提供的图标并转换为应用所需的所有尺寸
"""

try:
    from PIL import Image, ImageDraw
    import os
except ImportError:
    print("❌ 需要安装 PIL 库")
    print("运行: pip3 install Pillow")
    exit(1)

def create_icon_from_source(source_path, size):
    """从源图标创建指定尺寸的应用图标"""
    
    try:
        # 打开源图标文件
        source_img = Image.open(source_path).convert('RGBA')
        
        # 调整尺寸（保持高质量）
        resized_img = source_img.resize((size, size), Image.Resampling.LANCZOS)
        
        # 如果需要，可以在这里添加圆角处理
        # macOS会自动处理圆角，所以保持原始方形
        
        # 确保没有透明背景（如果需要）
        if size >= 256:  # 大尺寸图标保持透明度
            final_img = resized_img
        else:  # 小尺寸图标可能需要白色背景以提高可见性
            background = Image.new('RGBA', (size, size), (255, 255, 255, 255))
            final_img = Image.alpha_composite(background, resized_img)
        
        # 转换为RGB（PNG格式不需要alpha通道用于macOS图标）
        final_img = final_img.convert('RGB')
        
        return final_img
        
    except Exception as e:
        print(f"处理图标时出错: {e}")
        return None

def main():
    """主函数"""
    print("🎨 提取并转换用户提供的图标")
    print("=" * 50)
    
    # 查找用户提供的图标文件
    possible_sources = [
        "user_icon.png",
        "provided_icon.png", 
        "source_icon.png",
        "icon.png"
    ]
    
    source_path = None
    for path in possible_sources:
        if os.path.exists(path):
            source_path = path
            break
    
    if not source_path:
        print("❌ 未找到用户提供的图标文件")
        print("请将图标文件重命名为以下之一并放在项目根目录：")
        for path in possible_sources:
            print(f"  - {path}")
        return False
    
    print(f"✅ 找到源图标文件: {source_path}")
    
    # 图标尺寸
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    # 输出目录
    icon_dir = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    
    if not os.path.exists(icon_dir):
        print(f"❌ 图标目录不存在: {icon_dir}")
        return False
    
    success_count = 0
    
    for size in sizes:
        try:
            # 生成图标
            icon = create_icon_from_source(source_path, size)
            
            if icon is None:
                continue
            
            # 保存文件
            filename = f"app_icon_{size}.png"
            filepath = os.path.join(icon_dir, filename)
            icon.save(filepath, "PNG", quality=95)
            
            file_size = os.path.getsize(filepath)
            size_kb = file_size / 1024
            print(f"  ✅ {size}x{size} -> {filename} ({size_kb:.1f}KB)")
            success_count += 1
            
        except Exception as e:
            print(f"  ❌ 生成 {size}x{size} 失败: {e}")
    
    print("")
    if success_count == len(sizes):
        print("🎉 所有图标转换成功！")
        print(f"📁 图标位置: {icon_dir}/")
        print("")
        print("📋 转换特点:")
        print("  🔵 保持原图标的专业设计")
        print("  📱 适配macOS应用图标规范")
        print("  ⚡ 高质量Lanczos算法调整尺寸")
        print("  🎯 小尺寸图标优化可见性")
        print("")
        print("下一步:")
        print("1. flutter clean")
        print("2. flutter build macos --release")
        print("3. 检查新图标显示效果")
        return True
    else:
        print(f"⚠️ 部分图标转换失败 ({success_count}/{len(sizes)})")
        return False

if __name__ == "__main__":
    success = main()
    if success:
        print("\n🚀 准备构建应用以查看新图标效果...")
    else:
        print("\n❌ 图标转换未完成，请检查错误信息")