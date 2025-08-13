#!/usr/bin/env python3
"""
根据用户提供的图标描述创建高质量图标
基于用户提供的蓝色云下载图标设计
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import math
except ImportError:
    print("❌ 需要安装 PIL 库")
    print("运行: pip3 install Pillow")
    exit(1)

def create_professional_icon(size=1024):
    """创建专业的蓝色云下载图标"""
    
    # 创建图像
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))  # 透明背景
    draw = ImageDraw.Draw(img)
    
    # 计算尺寸比例
    scale = size / 1024.0
    
    # 颜色定义
    primary_blue = (74, 133, 244, 255)      # #4A85F4 (Google蓝)
    secondary_blue = (25, 103, 210, 255)    # #1967D2 (深蓝)
    white = (255, 255, 255, 255)
    shadow_color = (0, 0, 0, 30)
    
    # 创建背景渐变圆角矩形
    corner_radius = int(180 * scale)
    
    # 绘制背景
    bg_rect = [0, 0, size, size]
    draw.rounded_rectangle(bg_rect, corner_radius, fill=primary_blue)
    
    # 云朵设计 - 更专业和现代化
    cloud_center_x = size // 2
    cloud_center_y = int(300 * scale)
    cloud_width = int(400 * scale)
    cloud_height = int(120 * scale)
    
    # 主云朵体
    cloud_main = [
        cloud_center_x - cloud_width//2, 
        cloud_center_y - cloud_height//2,
        cloud_center_x + cloud_width//2, 
        cloud_center_y + cloud_height//2
    ]
    draw.ellipse(cloud_main, fill=white)
    
    # 云朵凸起部分 - 创建更自然的云朵形状
    bumps = [
        # 左侧凸起
        [cloud_center_x - int(180 * scale), cloud_center_y - int(80 * scale),
         cloud_center_x - int(80 * scale), cloud_center_y + int(20 * scale)],
        # 上方凸起
        [cloud_center_x - int(100 * scale), cloud_center_y - int(100 * scale),
         cloud_center_x + int(100 * scale), cloud_center_y - int(20 * scale)],
        # 右侧凸起
        [cloud_center_x + int(80 * scale), cloud_center_y - int(60 * scale),
         cloud_center_x + int(180 * scale), cloud_center_y + int(40 * scale)]
    ]
    
    for bump in bumps:
        draw.ellipse(bump, fill=white)
    
    # 添加云朵阴影效果
    shadow_offset = int(4 * scale)
    for bump in bumps:
        shadow_bump = [b + shadow_offset for b in bump]
        draw.ellipse(shadow_bump, fill=shadow_color)
    
    # 下载箭头 - 现代化设计
    arrow_center_x = cloud_center_x
    arrow_start_y = cloud_center_y + int(80 * scale)
    arrow_length = int(200 * scale)
    arrow_width = int(30 * scale)
    
    # 箭头杆
    arrow_rect = [
        arrow_center_x - arrow_width//2,
        arrow_start_y,
        arrow_center_x + arrow_width//2,
        arrow_start_y + arrow_length
    ]
    draw.rounded_rectangle(arrow_rect, int(15 * scale), fill=secondary_blue)
    
    # 箭头头部 - 三角形
    arrow_head_size = int(70 * scale)
    arrow_tip_y = arrow_start_y + arrow_length + int(30 * scale)
    
    arrow_points = [
        (arrow_center_x, arrow_tip_y),  # 尖端
        (arrow_center_x - arrow_head_size, arrow_start_y + arrow_length - int(20 * scale)),  # 左
        (arrow_center_x + arrow_head_size, arrow_start_y + arrow_length - int(20 * scale))   # 右
    ]
    draw.polygon(arrow_points, fill=secondary_blue)
    
    # 添加光泽效果
    highlight_y = int(200 * scale)
    highlight_height = int(150 * scale)
    highlight_ellipse = [
        int(200 * scale), highlight_y,
        int(824 * scale), highlight_y + highlight_height
    ]
    draw.ellipse(highlight_ellipse, fill=(255, 255, 255, 40))
    
    # 添加底部完成指示
    dot_y = arrow_tip_y + int(60 * scale)
    dot_radius = int(15 * scale)
    
    # 三个指示点
    for i, x_offset in enumerate([-40, 0, 40]):
        dot_x = arrow_center_x + int(x_offset * scale)
        opacity = 255 if i == 1 else 180  # 中间点更亮
        dot_color = (*secondary_blue[:3], opacity)
        
        dot_bounds = [
            dot_x - dot_radius, dot_y - dot_radius,
            dot_x + dot_radius, dot_y + dot_radius
        ]
        draw.ellipse(dot_bounds, fill=dot_color)
    
    return img

def main():
    """主函数"""
    print("🎨 创建专业蓝色云下载图标")
    print("=" * 40)
    
    # 创建高分辨率源图标
    icon = create_professional_icon(1024)
    
    # 保存源文件
    source_path = "user_icon.png"
    icon.save(source_path, "PNG")
    
    file_size = len(icon.tobytes()) / 1024
    print(f"✅ 创建源图标: {source_path} ({file_size:.1f}KB)")
    
    print("")
    print("📋 图标特征:")
    print("  🔵 专业蓝色配色方案")
    print("  ☁️ 现代化云朵设计")
    print("  ⬇️ 清晰的下载箭头")
    print("  ✨ 光泽和阴影效果")
    print("  📱 适配macOS应用标准")
    
    print("")
    print("下一步: 运行 python3 extract_and_convert_icon.py 转换为所有尺寸")

if __name__ == "__main__":
    main()