#!/usr/bin/env python3
"""
X Google Drive Downloader 简单图标生成器
使用Python PIL库生成应用图标
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os
except ImportError:
    print("❌ 需要安装 PIL 库")
    print("运行: pip3 install Pillow")
    exit(1)

def create_app_icon(size):
    """创建指定尺寸的应用图标"""
    
    # 创建图像
    img = Image.new('RGBA', (size, size), (250, 250, 250, 255))
    draw = ImageDraw.Draw(img)
    
    # 计算尺寸比例
    scale = size / 1024.0
    
    # 背景圆角矩形
    corner_radius = int(180 * scale)
    
    # 绘制云朵 (简化版)
    cloud_color = (0, 102, 204, 255)  # #0066CC
    cloud_x = int(200 * scale)
    cloud_y = int(300 * scale)
    cloud_w = int(400 * scale)
    cloud_h = int(150 * scale)
    
    # 云朵主体
    draw.ellipse([cloud_x, cloud_y, cloud_x + cloud_w, cloud_y + cloud_h], 
                 fill=cloud_color)
    
    # 云朵小圆
    draw.ellipse([cloud_x - int(50 * scale), cloud_y + int(30 * scale), 
                  cloud_x + int(100 * scale), cloud_y + int(120 * scale)], 
                 fill=cloud_color)
    draw.ellipse([cloud_x + int(150 * scale), cloud_y - int(30 * scale), 
                  cloud_x + int(300 * scale), cloud_y + int(60 * scale)], 
                 fill=cloud_color)
    draw.ellipse([cloud_x + int(300 * scale), cloud_y + int(20 * scale), 
                  cloud_x + int(450 * scale), cloud_y + int(110 * scale)], 
                 fill=cloud_color)
    
    # X标识
    x_size = int(60 * scale)
    x_pos = int(600 * scale)
    x_y = int(250 * scale)
    
    # X背景圆
    draw.ellipse([x_pos - int(40 * scale), x_y - int(40 * scale),
                  x_pos + int(40 * scale), x_y + int(40 * scale)], 
                 fill=(255, 255, 255, 200))
    
    # X字符 (使用线条绘制)
    line_width = max(1, int(8 * scale))
    x_offset = int(25 * scale)
    draw.line([x_pos - x_offset, x_y - x_offset, 
               x_pos + x_offset, x_y + x_offset], 
              fill=cloud_color, width=line_width)
    draw.line([x_pos + x_offset, x_y - x_offset, 
               x_pos - x_offset, x_y + x_offset], 
              fill=cloud_color, width=line_width)
    
    # 下载箭头
    arrow_x = int(400 * scale)
    arrow_y = int(500 * scale)
    arrow_color = (52, 199, 89, 255)  # #34C759
    
    # 箭头杆
    arrow_width = int(40 * scale)
    arrow_height = int(120 * scale)
    draw.rectangle([arrow_x - arrow_width//2, arrow_y,
                    arrow_x + arrow_width//2, arrow_y + arrow_height],
                   fill=arrow_color)
    
    # 箭头头部
    arrow_head_size = int(60 * scale)
    arrow_head_y = arrow_y + arrow_height - int(20 * scale)
    draw.polygon([
        (arrow_x, arrow_y + arrow_height + int(20 * scale)),  # 尖端
        (arrow_x - arrow_head_size, arrow_head_y),           # 左边
        (arrow_x + arrow_head_size, arrow_head_y)            # 右边
    ], fill=arrow_color)
    
    # 完成指示点
    dot_y = int(700 * scale)
    dot_radius = int(12 * scale)
    for i, x_offset in enumerate([-30, 0, 30]):
        dot_x = arrow_x + int(x_offset * scale)
        opacity = 255 if i == 1 else 180
        dot_color = (52, 199, 89, opacity)
        draw.ellipse([dot_x - dot_radius, dot_y - dot_radius,
                      dot_x + dot_radius, dot_y + dot_radius],
                     fill=dot_color)
    
    return img

def main():
    """主函数"""
    print("🎨 生成 X Google Drive Downloader 应用图标")
    print("=" * 50)
    
    # 图标尺寸
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    # 输出目录
    icon_dir = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    
    if not os.path.exists(icon_dir):
        print(f"❌ 图标目录不存在: {icon_dir}")
        return
    
    success_count = 0
    
    for size in sizes:
        try:
            # 生成图标
            icon = create_app_icon(size)
            
            # 保存文件
            filename = f"app_icon_{size}.png"
            filepath = os.path.join(icon_dir, filename)
            icon.save(filepath, "PNG")
            
            file_size = os.path.getsize(filepath)
            size_kb = file_size / 1024
            print(f"  ✅ {size}x{size} -> {filename} ({size_kb:.1f}KB)")
            success_count += 1
            
        except Exception as e:
            print(f"  ❌ 生成 {size}x{size} 失败: {e}")
    
    print("")
    if success_count == len(sizes):
        print("🎉 所有图标生成成功！")
        print(f"📁 图标位置: {icon_dir}/")
        print("")
        print("📋 图标特点:")
        print("  🔵 简约蓝色云朵代表Google Drive")
        print("  ❌ 白色背景X标识代表品牌")
        print("  ⬇️ 绿色箭头表示下载功能")
        print("  🟢 三个圆点表示下载的文件")
        print("")
        print("下一步:")
        print("1. flutter clean")
        print("2. flutter build macos --release")
        print("3. 检查新图标显示效果")
    else:
        print(f"⚠️ 部分图标生成失败 ({success_count}/{len(sizes)})")

if __name__ == "__main__":
    main()