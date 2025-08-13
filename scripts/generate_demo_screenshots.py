#!/usr/bin/env python3
"""
自动生成应用演示截图
使用PIL生成模拟的应用界面截图
"""

import os
from PIL import Image, ImageDraw, ImageFont
import shutil

def create_app_screenshot():
    """创建主应用界面截图"""
    # 创建800x600的画布（模拟macOS窗口）
    width, height = 800, 600
    img = Image.new('RGB', (width, height), color='#F2F2F7')  # macOS背景色
    draw = ImageDraw.Draw(img)
    
    # 绘制窗口标题栏
    title_bar_height = 28
    draw.rectangle([0, 0, width, title_bar_height], fill='#ECECEC')
    
    # 绘制交通灯按钮
    button_y = title_bar_height // 2
    draw.ellipse([12-6, button_y-6, 12+6, button_y+6], fill='#FF5F57')  # 红色
    draw.ellipse([32-6, button_y-6, 32+6, button_y+6], fill='#FFBD2E')  # 黄色
    draw.ellipse([52-6, button_y-6, 52+6, button_y+6], fill='#28CA42')  # 绿色
    
    # 窗口标题
    try:
        title_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 13)
    except:
        title_font = ImageFont.load_default()
    
    title_text = "X Google Drive Downloader"
    title_bbox = draw.textbbox((0, 0), title_text, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text((width//2 - title_width//2, 8), title_text, fill='#000000', font=title_font)
    
    # 主界面内容区域
    content_y = title_bar_height + 20
    
    # 应用图标区域
    icon_size = 64
    icon_x = width // 2 - icon_size // 2
    draw.rectangle([icon_x-2, content_y-2, icon_x+icon_size+2, content_y+icon_size+2], outline='#007AFF', width=2)
    draw.rectangle([icon_x, content_y, icon_x+icon_size, content_y+icon_size], fill='#007AFF')
    
    # 在图标中心绘制云下载符号
    cloud_font_size = 24
    try:
        symbol_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', cloud_font_size)
    except:
        symbol_font = ImageFont.load_default()
    
    symbol = "☁︎↓"
    symbol_bbox = draw.textbbox((0, 0), symbol, font=symbol_font)
    symbol_width = symbol_bbox[2] - symbol_bbox[0]
    symbol_height = symbol_bbox[3] - symbol_bbox[1]
    draw.text((icon_x + icon_size//2 - symbol_width//2, 
               content_y + icon_size//2 - symbol_height//2), 
              symbol, fill='white', font=symbol_font)
    
    # 应用标题
    app_title_y = content_y + icon_size + 20
    try:
        app_title_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 18)
    except:
        app_title_font = ImageFont.load_default()
    
    app_title = "X Google Drive Downloader"
    title_bbox = draw.textbbox((0, 0), app_title, font=app_title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text((width//2 - title_width//2, app_title_y), app_title, fill='#000000', font=app_title_font)
    
    # 副标题
    subtitle_y = app_title_y + 30
    try:
        subtitle_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 14)
    except:
        subtitle_font = ImageFont.load_default()
    
    subtitle = "快速、安全地下载 Google Drive 文件夹"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    draw.text((width//2 - subtitle_width//2, subtitle_y), subtitle, fill='#666666', font=subtitle_font)
    
    # URL输入框
    input_y = subtitle_y + 50
    input_height = 36
    input_margin = 60
    draw.rectangle([input_margin, input_y, width-input_margin, input_y+input_height], 
                  fill='white', outline='#CCCCCC', width=1)
    
    placeholder_text = "粘贴 Google Drive 文件夹链接..."
    try:
        input_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 12)
    except:
        input_font = ImageFont.load_default()
    
    draw.text((input_margin + 10, input_y + 12), placeholder_text, fill='#999999', font=input_font)
    
    # 下载按钮
    button_y = input_y + input_height + 20
    button_width = 120
    button_height = 32
    button_x = width//2 - button_width//2
    
    draw.rectangle([button_x, button_y, button_x+button_width, button_y+button_height], 
                  fill='#007AFF', outline='#007AFF')
    
    button_text = "开始下载"
    try:
        button_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 14)
    except:
        button_font = ImageFont.load_default()
    
    button_bbox = draw.textbbox((0, 0), button_text, font=button_font)
    button_text_width = button_bbox[2] - button_bbox[0]
    draw.text((button_x + button_width//2 - button_text_width//2, button_y + 8), 
              button_text, fill='white', font=button_font)
    
    # AI开发标识
    ai_y = height - 40
    ai_text = "🤖 完全由 Claude Code 开发"
    try:
        ai_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 11)
    except:
        ai_font = ImageFont.load_default()
    
    ai_bbox = draw.textbbox((0, 0), ai_text, font=ai_font)
    ai_width = ai_bbox[2] - ai_bbox[0]
    draw.text((width//2 - ai_width//2, ai_y), ai_text, fill='#7C3AED', font=ai_font)
    
    return img

def create_feature_showcase():
    """创建功能展示图"""
    width, height = 800, 500
    img = Image.new('RGB', (width, height), color='#FFFFFF')
    draw = ImageDraw.Draw(img)
    
    # 标题
    try:
        title_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 24)
        feature_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 16)
        desc_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 12)
    except:
        title_font = ImageFont.load_default()
        feature_font = ImageFont.load_default()
        desc_font = ImageFont.load_default()
    
    title = "✨ 主要特性"
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text((width//2 - title_width//2, 20), title, fill='#000000', font=title_font)
    
    # 特性列表
    features = [
        ("🚀", "零配置体验", "内置OAuth认证，下载即用，无需设置"),
        ("🎨", "专业界面", "macOS原生设计，现代化用户体验"),
        ("💾", "智能下载", "保持文件夹结构，默认保存到Downloads"),
        ("🔐", "持久认证", "一次登录，长期使用，安全存储"),
        ("⚡", "剪贴板监听", "自动检测Google Drive链接"),
        ("🤖", "AI开发", "完全由Claude Code开发，无人工干预")
    ]
    
    start_y = 80
    for i, (icon, title, desc) in enumerate(features):
        y = start_y + i * 60
        
        # 图标
        draw.text((60, y), icon, fill='#007AFF', font=title_font)
        
        # 标题
        draw.text((100, y), title, fill='#000000', font=feature_font)
        
        # 描述
        draw.text((100, y + 25), desc, fill='#666666', font=desc_font)
    
    return img

def main():
    """主函数：生成所有截图"""
    print("🎨 开始生成演示截图...")
    
    # 创建screenshots目录
    os.makedirs('screenshots', exist_ok=True)
    
    # 1. 生成主界面截图
    print("  - 生成主界面截图...")
    main_screenshot = create_app_screenshot()
    main_screenshot.save('screenshots/01_main_interface.png', 'PNG', quality=95)
    
    # 2. 生成特性展示图
    print("  - 生成特性展示图...")
    feature_screenshot = create_feature_showcase()
    feature_screenshot.save('screenshots/02_features.png', 'PNG', quality=95)
    
    # 3. 复制应用图标
    print("  - 复制应用图标...")
    icon_source = 'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png'
    if os.path.exists(icon_source):
        shutil.copy2(icon_source, 'screenshots/03_app_icon.png')
    
    # 4. 如果存在用户图标，也复制
    if os.path.exists('user_icon.png'):
        shutil.copy2('user_icon.png', 'screenshots/04_icon_design.png')
    
    print("✅ 演示截图生成完成！")
    print(f"📁 截图位置: {os.path.abspath('screenshots')}")
    
    # 列出生成的文件
    for file in os.listdir('screenshots'):
        if file.endswith('.png'):
            print(f"  - {file}")

if __name__ == "__main__":
    main()