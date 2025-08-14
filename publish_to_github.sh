#!/bin/bash

# X Google Drive Downloader GitHub自动发布脚本
# 自动化完成GitHub仓库创建、代码推送和Release发布

set -e  # 遇到错误立即退出

APP_NAME="X Google Drive Downloader"
VERSION="2.1.0"
REPO_NAME="x-google-drive-downloader"
DMG_FILE="XGoogleDriveDownloader-v2.1.0.dmg"

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
    git commit -m "🔧 v2.1.0 - OAuth认证修复版

✨ 修复的关键问题:
- 修复OAuth令牌获取卡顿问题（Dio拦截器递归死锁）
- 修复认证后导航黑屏问题
- 优化应用启动状态检测
- 修复编译错误和枚举定义问题

🚀 改进内容:
- 完全修复OAuth 2.0认证流程
- 消除黑屏和卡顿问题
- 增强调试日志和错误提示
- 优化代码架构和质量

📦 Distribution:
- 24MB standalone DMG installer
- 零配置，开箱即用
- 稳定可靠的认证系统"

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
# X Google Drive Downloader v2.1.0

🔧 **OAuth认证修复版！**

## 📥 下载

**推荐下载**: [XGoogleDriveDownloader-v2.1.0.dmg](https://github.com/$GITHUB_USER/$REPO_NAME/releases/download/v2.1.0/XGoogleDriveDownloader-v2.1.0.dmg) (24MB)

## 🔧 修复的关键问题

✅ **OAuth令牌获取卡顿** - 解决了获取令牌后一直转圈的问题  
✅ **认证后黑屏问题** - 修复认证成功后不进入主界面的bug  
✅ **应用启动检测** - 优化OAuth配置和认证状态检测  
✅ **编译错误修复** - 解决枚举定义和类型错误  

## ✨ 技术改进

🚀 **Dio拦截器优化** - 排除OAuth请求避免递归死锁  
🎯 **导航逻辑完善** - 认证成功后自动进入主界面  
💡 **调试日志增强** - 更详细的错误信息和状态追踪  
🔐 **四层级OAuth系统** - 智能配置管理和自动检测  

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