#!/usr/bin/env python3
"""
创建真实的macOS应用截图
修复中文字体渲染问题，使用系统字体
"""

import os
from PIL import Image, ImageDraw, ImageFont
import shutil

def get_system_fonts():
    """获取macOS系统字体"""
    font_paths = {
        'title': '/System/Library/Fonts/Helvetica.ttc',
        'body': '/System/Library/Fonts/Helvetica.ttc', 
        'chinese': '/System/Library/Fonts/PingFang.ttc',  # macOS中文字体
        'code': '/System/Library/Fonts/Monaco.ttf'
    }
    
    # 备用字体路径
    fallback_fonts = {
        'title': '/System/Library/Fonts/Helvetica.ttc',
        'body': '/System/Library/Fonts/Helvetica.ttc',
        'chinese': '/System/Library/Fonts/STHeiti Light.ttc',
        'code': '/System/Library/Fonts/Courier New.ttf'
    }
    
    # 检查字体文件是否存在，使用备用字体
    for key in font_paths:
        if not os.path.exists(font_paths[key]) and key in fallback_fonts:
            font_paths[key] = fallback_fonts[key]
    
    return font_paths

def create_realistic_app_screenshot():
    """创建真实的macOS应用界面截图"""
    width, height = 900, 650
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    
    # 创建窗口背景（macOS风格）
    create_macos_window_background(img, width, height)
    
    # 添加窗口内容
    add_app_content(img, width, height)
    
    return img

def create_macos_window_background(img, width, height):
    """创建macOS风格的窗口背景"""
    draw = ImageDraw.Draw(img)
    
    # 窗口背景色
    bg_color = (242, 242, 247, 255)  # macOS背景色
    
    # 绘制窗口背景（圆角矩形）
    corner_radius = 12
    draw.rounded_rectangle([0, 0, width, height], corner_radius, fill=bg_color)
    
    # 标题栏
    title_bar_height = 30
    title_bar_color = (236, 236, 236, 255)
    draw.rounded_rectangle([0, 0, width, title_bar_height], corner_radius, fill=title_bar_color)
    draw.rectangle([0, corner_radius, width, title_bar_height], fill=title_bar_color)
    
    # 交通灯按钮
    button_radius = 6
    button_y = title_bar_height // 2
    
    # 红色按钮
    draw.ellipse([12-button_radius, button_y-button_radius, 
                  12+button_radius, button_y+button_radius], 
                 fill=(255, 95, 87))
    
    # 黄色按钮  
    draw.ellipse([32-button_radius, button_y-button_radius,
                  32+button_radius, button_y+button_radius], 
                 fill=(255, 189, 46))
    
    # 绿色按钮
    draw.ellipse([52-button_radius, button_y-button_radius,
                  52+button_radius, button_y+button_radius], 
                 fill=(40, 202, 66))
    
    # 窗口标题
    try:
        font_paths = get_system_fonts()
        title_font = ImageFont.truetype(font_paths['title'], 14)
    except:
        title_font = ImageFont.load_default()
    
    title_text = "X Google Drive Downloader"
    title_bbox = draw.textbbox((0, 0), title_text, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text((width//2 - title_width//2, 8), title_text, 
              fill=(0, 0, 0, 255), font=title_font)

def add_app_content(img, width, height):
    """添加应用内容"""
    draw = ImageDraw.Draw(img)
    font_paths = get_system_fonts()
    
    # 字体设置
    try:
        app_title_font = ImageFont.truetype(font_paths['chinese'], 24)
        subtitle_font = ImageFont.truetype(font_paths['chinese'], 16)
        button_font = ImageFont.truetype(font_paths['chinese'], 14)
        label_font = ImageFont.truetype(font_paths['chinese'], 13)
    except Exception as e:
        print(f"字体加载失败，使用默认字体: {e}")
        app_title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        button_font = ImageFont.load_default()
        label_font = ImageFont.load_default()
    
    content_start_y = 50  # 标题栏下方
    
    # 应用图标
    icon_size = 80
    icon_x = (width - icon_size) // 2
    icon_y = content_start_y + 20
    
    # 使用生成的专业图标
    try:
        icon_img = Image.open('screenshots/app_icon_new.png')
        icon_img = icon_img.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        img.paste(icon_img, (icon_x, icon_y), icon_img if icon_img.mode == 'RGBA' else None)
    except:
        # 备用图标绘制
        draw.rounded_rectangle([icon_x, icon_y, icon_x+icon_size, icon_y+icon_size], 
                              16, fill=(0, 122, 255, 255))
        draw.text((icon_x + icon_size//2 - 10, icon_y + icon_size//2 - 8), 
                  "☁↓", fill=(255, 255, 255), font=button_font)
    
    # 应用标题
    app_title_y = icon_y + icon_size + 20
    app_title = "X Google Drive Downloader"
    title_bbox = draw.textbbox((0, 0), app_title, font=app_title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text((width//2 - title_width//2, app_title_y), app_title, 
              fill=(0, 0, 0, 255), font=app_title_font)
    
    # 副标题（中文）
    subtitle_y = app_title_y + 35
    subtitle = "快速、安全地下载 Google Drive 文件夹"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    draw.text((width//2 - subtitle_width//2, subtitle_y), subtitle, 
              fill=(102, 102, 102, 255), font=subtitle_font)
    
    # URL输入框
    input_y = subtitle_y + 50
    input_height = 40
    input_margin = 80
    input_bg_color = (255, 255, 255, 255)
    input_border_color = (200, 200, 200, 255)
    
    # 输入框背景
    draw.rounded_rectangle([input_margin, input_y, width-input_margin, input_y+input_height], 
                          8, fill=input_bg_color, outline=input_border_color, width=1)
    
    # 输入框标签
    input_label_y = input_y - 25
    input_label = "Google Drive 文件夹链接:"
    draw.text((input_margin, input_label_y), input_label, 
              fill=(51, 51, 51, 255), font=label_font)
    
    # 输入框占位符文本
    placeholder_text = "https://drive.google.com/drive/folders/..."
    draw.text((input_margin + 12, input_y + 12), placeholder_text, 
              fill=(153, 153, 153, 255), font=label_font)
    
    # 下载按钮
    button_y = input_y + input_height + 30
    button_width = 140
    button_height = 36
    button_x = (width - button_width) // 2
    button_color = (0, 122, 255, 255)
    button_hover_color = (0, 100, 220, 255)
    
    # 按钮背景
    draw.rounded_rectangle([button_x, button_y, button_x+button_width, button_y+button_height], 
                          8, fill=button_color)
    
    # 按钮文字
    button_text = "开始下载"
    button_bbox = draw.textbbox((0, 0), button_text, font=button_font)
    button_text_width = button_bbox[2] - button_bbox[0]
    button_text_height = button_bbox[3] - button_bbox[1]
    draw.text((button_x + (button_width - button_text_width)//2, 
               button_y + (button_height - button_text_height)//2), 
              button_text, fill=(255, 255, 255, 255), font=button_font)
    
    # 功能特性列表
    features_y = button_y + button_height + 40
    features = [
        "🚀 零配置体验 - 内置认证，开箱即用",
        "💾 智能下载 - 保持文件夹结构",
        "🔐 安全存储 - 认证信息本地加密"
    ]
    
    feature_spacing = 25
    for i, feature in enumerate(features):
        feature_y = features_y + i * feature_spacing
        draw.text((input_margin, feature_y), feature, 
                  fill=(68, 68, 68, 255), font=label_font)
    
    # AI开发标识
    ai_y = height - 40
    ai_text = "🤖 完全由 Claude Code 开发"
    ai_bbox = draw.textbbox((0, 0), ai_text, font=label_font)
    ai_width = ai_bbox[2] - ai_bbox[0]
    draw.text((width//2 - ai_width//2, ai_y), ai_text, 
              fill=(124, 58, 237, 255), font=label_font)

def create_feature_showcase_realistic():
    """创建真实的功能展示图"""
    width, height = 900, 600
    img = Image.new('RGBA', (width, height), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    font_paths = get_system_fonts()
    
    try:
        title_font = ImageFont.truetype(font_paths['chinese'], 28)
        feature_title_font = ImageFont.truetype(font_paths['chinese'], 18)
        feature_desc_font = ImageFont.truetype(font_paths['chinese'], 14)
    except:
        title_font = ImageFont.load_default()
        feature_title_font = ImageFont.load_default()
        feature_desc_font = ImageFont.load_default()
    
    # 标题
    title = "✨ X Google Drive Downloader 核心特性"
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text((width//2 - title_width//2, 40), title, fill=(0, 0, 0), font=title_font)
    
    # 特性网格
    features = [
        ("🚀", "零配置体验", "内置OAuth认证，下载即用"),
        ("🎨", "专业界面", "macOS原生设计风格"),
        ("💾", "智能下载", "保持完整文件夹结构"),
        ("🔐", "持久认证", "一次登录长期使用"),
        ("⚡", "剪贴板监听", "自动检测Drive链接"),
        ("🤖", "AI开发", "完全由Claude Code开发")
    ]
    
    # 2x3网格布局
    grid_cols = 2
    grid_rows = 3
    feature_width = (width - 120) // grid_cols
    feature_height = (height - 160) // grid_rows
    
    for i, (icon, title, desc) in enumerate(features):
        col = i % grid_cols
        row = i // grid_cols
        
        x = 60 + col * feature_width
        y = 120 + row * feature_height
        
        # 特性卡片背景
        card_padding = 20
        draw.rounded_rectangle([x, y, x+feature_width-20, y+feature_height-20], 
                              12, fill=(248, 248, 248), outline=(230, 230, 230), width=1)
        
        # 图标
        icon_y = y + card_padding
        draw.text((x + card_padding, icon_y), icon, fill=(0, 122, 255), font=title_font)
        
        # 标题
        title_y = icon_y + 40
        draw.text((x + card_padding, title_y), title, fill=(0, 0, 0), font=feature_title_font)
        
        # 描述
        desc_y = title_y + 30
        draw.text((x + card_padding, desc_y), desc, fill=(102, 102, 102), font=feature_desc_font)
    
    return img

def main():
    """主函数：生成所有真实截图"""
    print("🎨 开始生成真实macOS应用截图...")
    
    os.makedirs('screenshots', exist_ok=True)
    
    # 1. 生成主界面截图
    print("  - 生成主界面截图...")
    main_screenshot = create_realistic_app_screenshot()
    main_screenshot.save('screenshots/01_main_interface_fixed.png', 'PNG', quality=95)
    
    # 2. 生成特性展示图
    print("  - 生成特性展示图...")
    feature_screenshot = create_feature_showcase_realistic()
    feature_screenshot.save('screenshots/02_features_fixed.png', 'PNG', quality=95)
    
    # 3. 复制新的专业图标
    print("  - 更新应用图标...")
    if os.path.exists('screenshots/app_icon_new.png'):
        shutil.copy2('screenshots/app_icon_new.png', 'screenshots/03_app_icon_professional.png')
    
    print("✅ 真实截图生成完成！")
    print(f"📁 截图位置: {os.path.abspath('screenshots')}")
    
    # 列出生成的文件
    for file in ['01_main_interface_fixed.png', '02_features_fixed.png', '03_app_icon_professional.png']:
        filepath = f'screenshots/{file}'
        if os.path.exists(filepath):
            file_size = os.path.getsize(filepath) / 1024
            print(f"  - {file} ({file_size:.1f}KB)")

if __name__ == "__main__":
    main()