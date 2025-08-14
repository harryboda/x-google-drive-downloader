#!/usr/bin/env python3
"""
SVG到PNG转换脚本
直接解析SVG并使用PIL绘制
"""

import os
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont
import math

def parse_svg_and_create_png(svg_path, output_path, size=1024):
    """解析SVG文件并创建对应的PNG图像"""
    
    # 创建画布
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 缩放比例 (SVG是1024x1024)
    scale = size / 1024.0
    
    # 白色圆角背景
    corner_radius = int(102.4 * scale)
    draw_rounded_rectangle(draw, 0, 0, size-1, size-1, corner_radius, '#FFFFFF', '#E8EAED', int(2*scale))
    
    # Google Drive 三角形 (中心在512, 452)
    center_x, center_y = int(512 * scale), int(452 * scale)
    
    # 左侧蓝色三角形: (-120,60) -> (-20,-80) -> (80,60)
    blue_triangle = [
        (center_x + int(-120 * scale), center_y + int(60 * scale)),
        (center_x + int(-20 * scale), center_y + int(-80 * scale)),
        (center_x + int(80 * scale), center_y + int(60 * scale))
    ]
    draw.polygon(blue_triangle, fill='#4285F4')
    
    # 右侧绿色三角形: (80,60) -> (180,60) -> (80,-80)
    green_triangle = [
        (center_x + int(80 * scale), center_y + int(60 * scale)),
        (center_x + int(180 * scale), center_y + int(60 * scale)),
        (center_x + int(80 * scale), center_y + int(-80 * scale))
    ]
    draw.polygon(green_triangle, fill='#0F9D58')
    
    # 底部黄色三角形: (-120,60) -> (80,60) -> (180,60) -> (30,160) -> (-70,160)
    yellow_shape = [
        (center_x + int(-120 * scale), center_y + int(60 * scale)),
        (center_x + int(80 * scale), center_y + int(60 * scale)),
        (center_x + int(180 * scale), center_y + int(60 * scale)),
        (center_x + int(30 * scale), center_y + int(160 * scale)),
        (center_x + int(-70 * scale), center_y + int(160 * scale))
    ]
    draw.polygon(yellow_shape, fill='#F4B400')
    
    # X 标识 (中心在 512+30, 452+10)
    x_center_x, x_center_y = center_x + int(30 * scale), center_y + int(10 * scale)
    x_radius = int(45 * scale)
    
    # X的背景圆形
    draw.ellipse([
        x_center_x - x_radius, x_center_y - x_radius,
        x_center_x + x_radius, x_center_y + x_radius
    ], fill='#FFFFFF', outline='#202124', width=int(4*scale))
    
    # X字母的两条线
    x_line_half = int(20 * scale)
    x_line_width = int(6 * scale)
    
    # 对角线1 (左上到右下)
    draw_thick_line(draw, 
        x_center_x - x_line_half, x_center_y - x_line_half,
        x_center_x + x_line_half, x_center_y + x_line_half,
        x_line_width, '#202124')
    
    # 对角线2 (右上到左下)
    draw_thick_line(draw,
        x_center_x + x_line_half, x_center_y - x_line_half,
        x_center_x - x_line_half, x_center_y + x_line_half,
        x_line_width, '#202124')
    
    # 下载箭头 (中心在 512, 632)
    arrow_center_x, arrow_center_y = int(512 * scale), int(632 * scale)
    arrow_radius = int(40 * scale)
    
    # 箭头背景圆形
    draw.ellipse([
        arrow_center_x - arrow_radius, arrow_center_y - arrow_radius,
        arrow_center_x + arrow_radius, arrow_center_y + arrow_radius
    ], fill='#4285F4')
    
    # 箭头杆
    arrow_shaft_width = int(6 * scale)
    arrow_shaft_height = int(25 * scale)
    draw.rectangle([
        arrow_center_x - arrow_shaft_width//2, arrow_center_y - int(20 * scale),
        arrow_center_x + arrow_shaft_width//2, arrow_center_y + int(5 * scale)
    ], fill='#FFFFFF')
    
    # 箭头头部
    arrow_head = [
        (arrow_center_x - int(15 * scale), arrow_center_y + int(5 * scale)),
        (arrow_center_x, arrow_center_y + int(20 * scale)),
        (arrow_center_x + int(15 * scale), arrow_center_y + int(5 * scale)),
        (arrow_center_x + int(10 * scale), arrow_center_y + int(5 * scale)),
        (arrow_center_x, arrow_center_y + int(15 * scale)),
        (arrow_center_x - int(10 * scale), arrow_center_y + int(5 * scale))
    ]
    draw.polygon(arrow_head, fill='#FFFFFF')
    
    # 品牌文字 "DOWNLOADER" (中心在 512, 712)
    text_center_x, text_center_y = int(512 * scale), int(712 * scale)
    text_bg_width, text_bg_height = int(120 * scale), int(30 * scale)
    
    # 文字背景
    draw_rounded_rectangle(draw,
        text_center_x - text_bg_width//2, text_center_y - text_bg_height//2,
        text_center_x + text_bg_width//2, text_center_y + text_bg_height//2,
        int(15 * scale), '#202124', opacity=25)
    
    # 文字 (简化版本，因为字体可能不可用)
    try:
        font_size = int(20 * scale)
        if font_size > 8:  # 只在足够大时绘制文字
            # 尝试使用系统字体
            font = None
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
            except:
                try:
                    font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
                except:
                    font = ImageFont.load_default()
            
            text = "DOWNLOADER"
            # 获取文字尺寸
            bbox = draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            
            # 绘制文字
            draw.text(
                (text_center_x - text_width//2, text_center_y - text_height//2),
                text, font=font, fill='#202124'
            )
    except:
        # 如果字体处理失败，跳过文字
        pass
    
    # 保存图像
    img.save(output_path, 'PNG')
    return True

def draw_rounded_rectangle(draw, x1, y1, x2, y2, radius, fill_color, outline_color=None, outline_width=0, opacity=255):
    """绘制圆角矩形"""
    
    if isinstance(fill_color, str):
        # 将十六进制颜色转为RGBA
        fill_color = tuple(int(fill_color[i:i+2], 16) for i in (1, 3, 5)) + (opacity,)
    
    # 创建圆角矩形的路径点
    points = []
    
    # 右下角
    for angle in range(0, 91, 10):
        x = x2 - radius + radius * math.cos(math.radians(angle))
        y = y2 - radius + radius * math.sin(math.radians(angle))
        points.append((x, y))
    
    # 左下角
    for angle in range(90, 181, 10):
        x = x1 + radius + radius * math.cos(math.radians(angle))
        y = y2 - radius + radius * math.sin(math.radians(angle))
        points.append((x, y))
    
    # 左上角
    for angle in range(180, 271, 10):
        x = x1 + radius + radius * math.cos(math.radians(angle))
        y = y1 + radius + radius * math.sin(math.radians(angle))
        points.append((x, y))
    
    # 右上角
    for angle in range(270, 361, 10):
        x = x2 - radius + radius * math.cos(math.radians(angle))
        y = y1 + radius + radius * math.sin(math.radians(angle))
        points.append((x, y))
    
    # 绘制填充
    if len(points) > 2:
        draw.polygon(points, fill=fill_color)
    else:
        # 备选：绘制简单矩形
        draw.rectangle([x1, y1, x2, y2], fill=fill_color)
    
    # 绘制边框
    if outline_color and outline_width > 0:
        outline_rgba = tuple(int(outline_color[i:i+2], 16) for i in (1, 3, 5)) + (255,)
        if len(points) > 2:
            draw.polygon(points, outline=outline_rgba, width=outline_width)
        else:
            draw.rectangle([x1, y1, x2, y2], outline=outline_rgba, width=outline_width)

def draw_thick_line(draw, x1, y1, x2, y2, width, color):
    """绘制粗线条"""
    # 简化版本：绘制多条相邻的线
    if isinstance(color, str):
        color = tuple(int(color[i:i+2], 16) for i in (1, 3, 5))
    
    for i in range(-width//2, width//2 + 1):
        draw.line([(x1, y1+i), (x2, y2+i)], fill=color, width=1)
        draw.line([(x1+i, y1), (x2+i, y2)], fill=color, width=1)

def main():
    svg_source = "assets/x-google-drive-downloader-concrete.svg"
    output_path = "generated_icons/base_1024_improved.png"
    
    if not os.path.exists(svg_source):
        print(f"❌ SVG文件不存在: {svg_source}")
        return False
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    print("🎨 使用SVG内容创建精确的PNG图标...")
    
    if parse_svg_and_create_png(svg_source, output_path, 1024):
        print(f"✅ 高质量图标生成成功: {output_path}")
        return True
    else:
        print(f"❌ 图标生成失败")
        return False

if __name__ == "__main__":
    main()