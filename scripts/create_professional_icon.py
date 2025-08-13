#!/usr/bin/env python3
"""
创建专业级macOS应用图标
遵循Apple Human Interface Guidelines
"""

import os
from PIL import Image, ImageDraw, ImageFilter
import math

def create_professional_icon(size=1024):
    """创建专业级的macOS应用图标"""
    
    # 创建画布，使用透明背景
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 圆角矩形参数（macOS图标标准）
    corner_radius = int(size * 0.2237)  # macOS标准圆角比例
    
    # 创建圆角矩形背景
    create_rounded_rectangle(draw, 0, 0, size, size, corner_radius, 
                           gradient_colors=['#007AFF', '#0051D5'])
    
    # 云朵设计 - 更现代的设计
    cloud_y_offset = int(size * 0.25)
    cloud_width = int(size * 0.6)
    cloud_height = int(size * 0.35)
    cloud_x = (size - cloud_width) // 2
    cloud_y = cloud_y_offset
    
    # 绘制现代化云朵
    draw_modern_cloud(draw, cloud_x, cloud_y, cloud_width, cloud_height)
    
    # 下载箭头 - 更精致的设计
    arrow_size = int(size * 0.25)
    arrow_x = (size - arrow_size) // 2
    arrow_y = cloud_y + cloud_height + int(size * 0.05)
    
    draw_download_arrow(draw, arrow_x, arrow_y, arrow_size)
    
    # 添加微妙的光泽效果（macOS风格）
    add_gloss_effect(draw, size, corner_radius)
    
    return img

def create_rounded_rectangle(draw, x, y, width, height, radius, gradient_colors):
    """创建带渐变的圆角矩形"""
    
    # 创建渐变背景
    for i in range(height):
        progress = i / height
        color = interpolate_color(gradient_colors[0], gradient_colors[1], progress)
        
        # 绘制每一行，考虑圆角
        line_y = y + i
        if i < radius:
            # 顶部圆角区域
            corner_width = int(radius - math.sqrt(radius * radius - (radius - i) * (radius - i)))
            draw.line([(x + corner_width, line_y), (x + width - corner_width, line_y)], 
                     fill=color, width=1)
        elif i > height - radius:
            # 底部圆角区域
            corner_offset = i - (height - radius)
            corner_width = int(radius - math.sqrt(radius * radius - (radius - corner_offset) * (radius - corner_offset)))
            draw.line([(x + corner_width, line_y), (x + width - corner_width, line_y)], 
                     fill=color, width=1)
        else:
            # 中间直线区域
            draw.line([(x, line_y), (x + width, line_y)], fill=color, width=1)

def draw_modern_cloud(draw, x, y, width, height):
    """绘制现代化的云朵"""
    
    # 云朵主体 - 使用多个椭圆组合
    cloud_color = (255, 255, 255, 240)  # 半透明白色
    shadow_color = (0, 0, 0, 30)  # 淡阴影
    
    # 绘制阴影
    shadow_offset = 3
    draw.ellipse([x + shadow_offset, y + height//3 + shadow_offset, 
                  x + width*0.4 + shadow_offset, y + height + shadow_offset], 
                 fill=shadow_color)
    draw.ellipse([x + width*0.3 + shadow_offset, y + shadow_offset, 
                  x + width*0.8 + shadow_offset, y + height*0.7 + shadow_offset], 
                 fill=shadow_color)
    draw.ellipse([x + width*0.6 + shadow_offset, y + height//4 + shadow_offset, 
                  x + width + shadow_offset, y + height*0.8 + shadow_offset], 
                 fill=shadow_color)
    
    # 绘制云朵主体
    draw.ellipse([x, y + height//3, x + width*0.4, y + height], fill=cloud_color)
    draw.ellipse([x + width*0.3, y, x + width*0.8, y + height*0.7], fill=cloud_color)
    draw.ellipse([x + width*0.6, y + height//4, x + width, y + height*0.8], fill=cloud_color)
    
    # 添加高光效果
    highlight_color = (255, 255, 255, 180)
    draw.ellipse([x + width*0.1, y + height*0.1, x + width*0.35, y + height*0.4], 
                 fill=highlight_color)

def draw_download_arrow(draw, x, y, size):
    """绘制精致的下载箭头"""
    
    arrow_color = (255, 255, 255, 255)
    shadow_color = (0, 0, 0, 60)
    
    # 箭头主体尺寸
    shaft_width = size // 6
    head_width = size // 2
    head_height = size // 3
    shaft_height = size - head_height
    
    # 绘制阴影
    shadow_offset = 2
    
    # 箭头杆阴影
    shaft_x = x + (size - shaft_width) // 2
    draw.rectangle([shaft_x + shadow_offset, y + shadow_offset, 
                   shaft_x + shaft_width + shadow_offset, y + shaft_height + shadow_offset], 
                   fill=shadow_color)
    
    # 箭头头阴影
    head_points = [
        (x + size//2 + shadow_offset, y + size + shadow_offset),  # 箭头尖端
        (x + (size - head_width)//2 + shadow_offset, y + shaft_height + shadow_offset),  # 左侧
        (x + (size + head_width)//2 + shadow_offset, y + shaft_height + shadow_offset)   # 右侧
    ]
    draw.polygon(head_points, fill=shadow_color)
    
    # 绘制箭头主体
    # 箭头杆
    draw.rectangle([shaft_x, y, shaft_x + shaft_width, y + shaft_height], fill=arrow_color)
    
    # 箭头头
    head_points = [
        (x + size//2, y + size),  # 箭头尖端
        (x + (size - head_width)//2, y + shaft_height),  # 左侧
        (x + (size + head_width)//2, y + shaft_height)   # 右侧
    ]
    draw.polygon(head_points, fill=arrow_color)
    
    # 添加高光
    highlight_color = (255, 255, 255, 200)
    highlight_width = shaft_width // 3
    highlight_x = shaft_x + highlight_width
    draw.rectangle([highlight_x, y, highlight_x + highlight_width, y + shaft_height//2], 
                   fill=highlight_color)

def add_gloss_effect(draw, size, corner_radius):
    """添加macOS风格的光泽效果"""
    
    gloss_color = (255, 255, 255, 40)
    
    # 顶部光泽
    gloss_height = size // 3
    for i in range(gloss_height):
        alpha = int(40 * (1 - i / gloss_height))
        if alpha > 0:
            color = (255, 255, 255, alpha)
            
            if i < corner_radius:
                corner_width = int(corner_radius - math.sqrt(corner_radius * corner_radius - (corner_radius - i) * (corner_radius - i)))
                draw.line([(corner_width, i), (size - corner_width, i)], fill=color, width=1)
            else:
                draw.line([(0, i), (size, i)], fill=color, width=1)

def interpolate_color(color1, color2, t):
    """在两种颜色之间插值"""
    def hex_to_rgb(hex_color):
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    
    def rgb_to_hex(rgb):
        return "#{:02x}{:02x}{:02x}".format(int(rgb[0]), int(rgb[1]), int(rgb[2]))
    
    rgb1 = hex_to_rgb(color1)
    rgb2 = hex_to_rgb(color2)
    
    r = rgb1[0] + (rgb2[0] - rgb1[0]) * t
    g = rgb1[1] + (rgb2[1] - rgb1[1]) * t
    b = rgb1[2] + (rgb2[2] - rgb1[2]) * t
    
    return (int(r), int(g), int(b), 255)

def generate_all_icon_sizes():
    """生成macOS应用所需的所有图标尺寸"""
    
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    icon_dir = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    
    print("🎨 生成专业级macOS应用图标...")
    
    for size in sizes:
        print(f"  - 生成 {size}x{size} 图标...")
        
        # 生成高分辨率图标然后缩放（保证质量）
        if size < 512:
            base_icon = create_professional_icon(1024)
            icon = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        else:
            icon = create_professional_icon(size)
        
        # 保存到正确位置
        filename = f"app_icon_{size}.png"
        filepath = os.path.join(icon_dir, filename)
        icon.save(filepath, "PNG", quality=95, optimize=True)
        
        # 也保存到screenshots目录用于展示
        if size == 1024:
            icon.save("screenshots/app_icon_new.png", "PNG", quality=95)
    
    print("✅ 专业级图标生成完成！")

if __name__ == "__main__":
    generate_all_icon_sizes()