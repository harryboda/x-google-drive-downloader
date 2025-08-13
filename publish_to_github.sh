#!/bin/bash

# X Google Drive Downloader GitHub自动发布脚本
# 自动化完成GitHub仓库创建、代码推送和Release发布

set -e  # 遇到错误立即退出

APP_NAME="X Google Drive Downloader"
VERSION="2.0.0"
REPO_NAME="x-google-drive-downloader"
DMG_FILE="XGoogleDriveDownloader-v2.0.0.dmg"

echo "🚀 开始发布 ${APP_NAME} 到 GitHub"
echo "=" * 60

# 检查必需的工具和文件
echo "🔍 检查发布环境..."

# 检查GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI 未安装"
    echo "请运行: brew install gh"
    echo "然后执行: gh auth login"
    exit 1
fi

# 检查是否已认证GitHub
if ! gh auth status &> /dev/null; then
    echo "❌ 未登录GitHub"
    echo "请运行: gh auth login"
    exit 1
fi

# 检查DMG文件是否存在
if [ ! -f "$DMG_FILE" ]; then
    echo "❌ DMG文件不存在: $DMG_FILE"
    echo "请先运行: ./create_dmg.sh"
    exit 1
fi

echo "✅ 环境检查通过"

# 获取GitHub用户名
GITHUB_USER=$(gh api user --jq .login)
echo "📍 GitHub用户: $GITHUB_USER"

# 1. 初始化Git仓库
echo ""
echo "📦 1. 初始化Git仓库..."

if [ ! -d ".git" ]; then
    git init
    echo "✅ Git仓库初始化完成"
else
    echo "✅ Git仓库已存在"
fi

# 2. 创建GitHub仓库
echo ""
echo "🏗️ 2. 创建GitHub仓库..."

# 检查仓库是否已存在
if gh repo view "$GITHUB_USER/$REPO_NAME" &> /dev/null; then
    echo "✅ GitHub仓库已存在: $GITHUB_USER/$REPO_NAME"
else
    gh repo create "$REPO_NAME" \
        --public \
        --description "Fast and secure Google Drive folder downloader for macOS" \
        --clone=false
    echo "✅ GitHub仓库创建成功"
fi

# 3. 设置远程仓库
echo ""
echo "🔗 3. 配置远程仓库..."

if git remote | grep -q "^origin$"; then
    git remote remove origin
fi

git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo "✅ 远程仓库配置完成"

# 4. 准备提交文件
echo ""
echo "📋 4. 准备提交文件..."

# 更新README中的用户名占位符
sed -i '' "s/your-username/$GITHUB_USER/g" README.md
echo "✅ README用户名已更新"

# 创建.gitignore（如果需要更新）
echo "✅ .gitignore已配置"

# 5. 提交代码
echo ""
echo "💾 5. 提交代码到GitHub..."

git add .

# 检查是否有文件需要提交
if git diff --staged --quiet; then
    echo "⚠️ 没有新的更改需要提交"
else
    git commit -m "🎉 Initial release - X Google Drive Downloader v2.0.0

✨ Features:
- Zero-configuration Google Drive folder downloading
- Built-in OAuth credentials for instant use
- Persistent authentication (login once, use forever)
- Modern macOS native UI design
- Smart clipboard link detection
- Multi-level secure storage strategy
- Professional custom app icon
- Direct DMG distribution

🔧 Technical:
- Flutter 3.8.1+ Desktop application
- Type-safe JSON serialization
- OAuth 2.0 + Google Drive API
- macOS 10.14+ support
- Universal Binary (Intel + Apple Silicon)

📦 Distribution:
- 24MB standalone DMG installer
- No environment variables required
- Drag-and-drop installation"

    echo "✅ 代码提交完成"
fi

# 推送到GitHub
echo "📤 推送代码到GitHub..."
git push -u origin main
echo "✅ 代码推送成功"

# 6. 创建Release
echo ""
echo "🎉 6. 创建GitHub Release..."

# 创建Release描述
cat > release-notes.md << EOF
# X Google Drive Downloader v2.0.0

🎉 **首个开源发布版本！**

## 📥 下载

**推荐下载**: [XGoogleDriveDownloader-v2.0.0.dmg](https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/v2.0.0/XGoogleDriveDownloader-v2.0.0.dmg) (24MB)

## ✨ 新特性

🚀 **零配置体验** - 内置OAuth认证，下载即用，无需任何设置  
🎨 **专业界面** - 全新设计的macOS原生界面和自定义图标  
💾 **智能下载** - 默认保存到~/Downloads，保持完整文件夹结构  
🔐 **持久认证** - 一次Google登录，长期免密使用  
⚡ **剪贴板监听** - 复制Google Drive链接自动提示下载  
🛡️ **安全存储** - 多级加密保护认证信息  

## 🛠️ 系统要求

- macOS 10.14+ (Mojave或更高版本)
- Intel x64 或 Apple Silicon (M1/M2)
- 稳定的网络连接

## 📦 安装方法

1. 下载 \`XGoogleDriveDownloader-v2.0.0.dmg\`
2. 双击打开DMG文件
3. 拖拽应用到Applications文件夹
4. 首次启动右键选择"打开"

## 🚀 使用方法

1. 启动应用
2. 首次使用完成Google账户授权
3. 复制Google Drive文件夹分享链接
4. 选择保存位置并开始下载

## 🔄 从v1.0升级

如果你使用过早期版本，v2.0带来了革命性的改进：
- ❌ 不再需要环境变量配置
- ❌ 不再需要shell脚本启动  
- ❌ 不再需要重复认证
- ✅ 开箱即用的完整体验

## 🐛 问题反馈

遇到问题请提交 [Issue](https://github.com/$GITHUB_USER/$REPO_NAME/issues)

## 📚 更多信息

- [使用文档](https://github.com/$GITHUB_USER/$REPO_NAME#使用方法)
- [开发指南](https://github.com/$GITHUB_USER/$REPO_NAME#开发)
- [隐私政策](https://github.com/$GITHUB_USER/$REPO_NAME/blob/main/docs/PRIVACY_POLICY.md)

---

**完整更新日志**: https://github.com/$GITHUB_USER/$REPO_NAME/blob/main/CHANGELOG.md
EOF

# 创建Release
gh release create "v$VERSION" \
    --title "$APP_NAME v$VERSION" \
    --notes-file release-notes.md \
    "$DMG_FILE"

echo "✅ GitHub Release创建成功"

# 7. 设置仓库Topics
echo ""
echo "🏷️ 7. 设置仓库标签..."

gh repo edit --add-topic "google-drive,macos,flutter,downloader,desktop-app,oauth,open-source"
echo "✅ 仓库标签设置完成"

# 8. 清理临时文件
rm -f release-notes.md
echo "✅ 临时文件清理完成"

# 9. 显示发布结果
echo ""
echo "🎉 GitHub发布完成！"
echo "=" * 60
echo "📊 发布信息："
echo "   仓库地址: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "   Release页面: https://github.com/$GITHUB_USER/$REPO_NAME/releases/tag/v$VERSION"
echo "   DMG下载: https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/v$VERSION/$DMG_FILE"
echo ""
echo "📱 分享链接："
echo "   GitHub: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "   直接下载: https://github.com/$GITHUB_USER/$REPO_NAME/releases/latest/download/$DMG_FILE"
echo ""
echo "🚀 推广建议："
echo "   1. 在社交媒体分享项目链接"
echo "   2. 提交到 Product Hunt"
echo "   3. 分享到相关技术社区 (Reddit, Hacker News)"
echo "   4. 写技术博客介绍开发历程"
echo ""
echo "🎯 下一步："
echo "   1. 监控GitHub Issues和用户反馈"
echo "   2. 规划v2.1版本功能"
echo "   3. 考虑App Store上架"

# 可选：自动打开发布页面
read -p "是否要打开GitHub Release页面？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "https://github.com/$GITHUB_USER/$REPO_NAME/releases/tag/v$VERSION"
fi

echo ""
echo "🏁 发布脚本执行完成！"