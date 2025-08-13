# X Google Drive Downloader - App Store 分发指南

## 📱 应用信息
- **应用名称**: X Google Drive Downloader
- **包名**: com.xiong.googledrivedownload  
- **版本**: 2.0.0
- **类别**: 生产力工具 (Productivity)
- **平台**: macOS 10.14+
- **价格**: 免费

## 🎯 应用特色

### 核心功能
✅ **一键下载Google Drive文件夹**
- 支持大文件夹批量下载
- 保持原始文件夹结构
- 智能断点续传

✅ **零配置使用**
- 内置OAuth认证，无需技术设置
- 一次登录，长期免密使用
- 自动剪贴板链接检测

✅ **现代化界面**
- 原生macOS设计语言
- 实时下载进度显示
- 优雅的状态反馈

✅ **安全可靠**
- 多级加密存储认证信息
- 本地处理，保护隐私
- 官方Google API，安全合规

### 用户价值
- **办公族**: 批量下载团队共享文件夹
- **学生**: 下载课程资料和作业文件
- **设计师**: 获取客户共享的设计素材
- **内容创作者**: 下载协作项目文件

## 📋 App Store 准备清单

### 1. 开发者账号准备
- [ ] Apple Developer Program 会员资格
- [ ] Developer ID Application证书
- [ ] Mac App Store证书
- [ ] App Store Connect访问权限

### 2. 应用配置
- [x] Bundle ID: `com.xiong.googledrivedownload`
- [x] 应用名称: `X Google Drive Downloader`
- [x] 版本号: `2.0.0`
- [x] 自定义应用图标
- [x] 代码签名配置

### 3. 隐私和权限
- [x] 网络权限 (Google Drive API)
- [x] 文件系统访问 (用户选择的下载目录)
- [x] Keychain访问 (安全存储认证信息)
- [ ] 隐私政策页面
- [ ] 使用条款页面

### 4. App Store 元数据

#### 应用描述 (中文)
```
X Google Drive Downloader - 最快捷的Google Drive文件夹下载工具

🚀 一键下载Google Drive整个文件夹，保持完整目录结构
🔐 内置认证系统，无需复杂配置，开箱即用
📱 原生macOS设计，界面简洁优雅
⚡ 智能链接检测，复制链接即可开始下载
🛡️ 本地处理数据，保护您的隐私安全

主要功能：
• 批量下载Google Drive文件夹
• 智能剪贴板链接识别
• 实时下载进度显示
• 一次登录长期使用
• 自动创建文件夹结构
• 支持大文件和深层目录

适用场景：
• 团队协作文件获取
• 课程资料批量下载
• 设计素材整理归档
• 项目文件本地备份

完全免费，无广告，无内购，专注为您提供最佳的Google Drive下载体验。
```

#### 应用描述 (英文)
```
X Google Drive Downloader - The Fastest Way to Download Google Drive Folders

🚀 Download entire Google Drive folders with one click, maintaining full directory structure
🔐 Built-in authentication system, no complex setup required, ready to use out of the box
📱 Native macOS design with clean and elegant interface
⚡ Smart link detection, just copy and paste to start downloading
🛡️ Local data processing to protect your privacy

Key Features:
• Batch download Google Drive folders
• Smart clipboard link recognition
• Real-time download progress display
• One-time login for long-term use
• Automatic folder structure creation
• Support for large files and deep directories

Perfect for:
• Team collaboration file retrieval
• Bulk download of course materials
• Design asset organization
• Project file local backup

Completely free, no ads, no in-app purchases, dedicated to providing you with the best Google Drive download experience.
```

#### 关键词
```
Google Drive, 下载器, 文件管理, 云存储, 批量下载, 文件夹, 生产力, 办公工具
```

#### 支持的语言
- 简体中文 (主要)
- English (次要)

### 5. 应用截图要求

需要提供以下尺寸的截图：
- **1280 x 800** (推荐)
- **1440 x 900** 
- **2560 x 1600**
- **2880 x 1800**

#### 截图内容建议
1. **主界面** - 展示简洁的下载界面
2. **下载中** - 显示实时进度和文件状态
3. **OAuth设置** - 展示高级配置选项
4. **完成状态** - 显示下载成功的界面
5. **文件管理** - 展示下载后的文件夹结构

## 🔧 技术配置

### 代码签名设置
```bash
# 1. 生成App Store证书
# 在 Apple Developer 控制台创建以下证书：
# - Mac App Store Distribution Certificate
# - Developer ID Application Certificate

# 2. 配置Bundle ID
# 确保Bundle ID匹配：com.xiong.googledrivedownload

# 3. 创建Provisioning Profile
# 为App Store分发创建配置文件

# 4. 构建并签名
flutter build macos --release
codesign --force --verify --verbose --sign "3rd Party Mac Developer Application: Your Name" "build/macos/Build/Products/Release/X Google Drive Downloader.app"

# 5. 创建pkg包
productbuild --component "build/macos/Build/Products/Release/X Google Drive Downloader.app" /Applications --sign "3rd Party Mac Developer Installer: Your Name" XGoogleDriveDownloader.pkg
```

### App Sandbox配置
在 `Release.entitlements` 中确保包含：
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

## 📝 隐私政策模板

需要创建隐私政策页面，包含：

1. **数据收集**
   - 我们不收集任何个人数据
   - Google认证通过官方API进行
   - 所有数据本地处理

2. **数据存储**
   - 认证token仅存储在本地
   - 使用系统级加密保护
   - 用户可随时清除数据

3. **第三方服务**
   - 仅使用Google Drive API
   - 遵循Google隐私政策
   - 不向其他第三方共享数据

## 🚀 分发流程

### 1. 准备阶段
```bash
# 清理并重新构建
flutter clean
flutter pub get
flutter build macos --release
```

### 2. 上传到App Store Connect
```bash
# 使用Xcode或Application Loader上传
xcrun altool --upload-app -f XGoogleDriveDownloader.pkg -u your-apple-id -p app-specific-password
```

### 3. App Store Connect配置
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 创建新应用
3. 填写应用信息和描述
4. 上传截图和图标
5. 设置价格和发布地区
6. 提交审核

### 4. 审核准备
- 准备应用演示视频
- 提供测试账号信息
- 准备审核回复文档

## ⚠️ 注意事项

### App Store审核要点
1. **功能完整性**: 确保所有功能正常工作
2. **用户界面**: 符合macOS设计标准
3. **隐私合规**: 明确说明数据使用方式
4. **版权合规**: 确保不侵犯第三方版权
5. **安全性**: 通过静态分析和安全测试

### 可能的审核问题
1. **Google API使用**: 需要说明为何需要访问Google Drive
2. **用户数据**: 明确说明不收集用户数据
3. **应用价值**: 强调对用户的实际价值

## 🎯 发布策略

### 软启动 (Soft Launch)
1. 先在中国区发布
2. 收集用户反馈
3. 优化用户体验

### 全球发布 (Global Launch)
1. 添加英文本地化
2. 优化关键词
3. 扩展到更多地区

### 营销推广
1. 创建产品网站
2. 社交媒体宣传
3. 技术博客文章
4. 用户评价收集

---

## 📞 技术支持

**开发者**: Xiong
**邮箱**: [你的邮箱]
**问题反馈**: GitHub Issues
**更新日志**: 在应用内查看

---

*最后更新：2025-01-13*