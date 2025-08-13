# OAuth 认证配置指南

## 🚀 快速开始

X Google Drive Downloader 提供了**智能的四层级OAuth解决方案**，确保每位用户都能轻松使用：

### 🎯 配置选择流程

应用启动时会自动检测OAuth配置状态，并引导您选择最适合的方案：

```
首次启动 → OAuth配置检测 → 选择配置方式 → 开始使用
```

## 📋 四种OAuth配置方案

### 1. 🚀 快速开始（推荐）

**适用人群**：普通用户，想要立即开始使用

**特点**：
- ✅ 零配置，下载即用
- ✅ 内置安全加密的OAuth凭据
- ✅ 支持自动更新
- ✅ 完全符合Google API使用条款

**使用方法**：
1. 启动应用
2. 选择"快速开始（推荐）"
3. 立即开始下载

**注意事项**：
- 开源版本不包含内置凭据，需要自定义配置
- 分发版本（DMG下载）包含加密的内置凭据

### 2. ⚙️ 自定义配置（高级）

**适用人群**：开发者、企业用户、高级用户

**特点**：
- 🔧 完全控制认证配置
- 🔐 使用您自己的Google Cloud凭据
- 📊 更高的API配额限制
- 🏢 支持企业级管理

**使用方法**：
1. 创建Google Cloud项目
2. 启用Google Drive API
3. 创建OAuth 2.0凭据
4. 在应用中输入Client ID和Client Secret

### 3. 🔧 环境变量配置（开发者）

**适用人群**：开发者、技术人员

**特点**：
- 💻 适合开发和测试环境
- 🔄 向后兼容老版本
- 🛠️ 支持自动化脚本

**使用方法**：
```bash
export GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
export GOOGLE_CLIENT_SECRET="your-client-secret"
flutter run -d macos
```

### 4. 🆘 引导配置（兜底）

**适用人群**：遇到配置问题的用户

**特点**：
- 📚 详细的设置指南
- 🎥 步骤说明和截图
- 🔗 直接链接到Google Cloud Console

## 🔧 详细配置步骤

### 方案一：使用分发版本（推荐普通用户）

1. **下载分发版本**
   ```
   访问: https://github.com/harryboda/x-google-drive-downloader/releases
   下载: XGoogleDriveDownloader-v2.0.0.dmg
   ```

2. **安装应用**
   - 双击DMG文件
   - 拖拽应用到Applications文件夹
   - 首次启动右键选择"打开"

3. **选择快速开始**
   - 启动应用
   - 选择"快速开始（推荐）"
   - 完成Google账户认证
   - 开始下载

### 方案二：自定义OAuth配置

#### 步骤1：创建Google Cloud项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 点击"选择项目" → "新建项目"
3. 输入项目名称，如 "Google Drive Downloader"
4. 点击"创建"

#### 步骤2：启用Google Drive API

1. 在项目中，进入"API和服务" → "库"
2. 搜索"Google Drive API"
3. 点击"启用"

#### 步骤3：创建OAuth 2.0凭据

1. 进入"API和服务" → "凭据"
2. 点击"创建凭据" → "OAuth 2.0客户端ID"
3. 如果首次创建，需要先配置OAuth同意屏幕：
   - 选择"外部"用户类型
   - 填写应用名称："Google Drive Downloader"
   - 填写用户支持电子邮件
   - 在"授权域"中添加：`localhost`
   - 保存并继续

4. 创建OAuth客户端ID：
   - 应用类型：选择"桌面应用程序"
   - 名称：输入 "Google Drive Downloader Desktop"
   - 点击"创建"

5. 保存凭据：
   - 复制"客户端ID"（格式：xxxxx-xxxxx.apps.googleusercontent.com）
   - 复制"客户端密钥"
   - 或下载JSON文件

#### 步骤4：在应用中配置

1. 启动X Google Drive Downloader
2. 选择"自定义配置（高级）"
3. 输入Client ID和Client Secret
4. 点击"保存配置"
5. 完成Google账户认证

## 🛡️ 安全性说明

### 内置凭据的安全措施

分发版本中的内置凭据采用了多层安全保护：

1. **编译时加密**：凭据在构建时使用强加密算法加密
2. **应用签名验证**：防止逆向工程和篡改
3. **设备特定密钥**：基于设备硬件信息生成解密密钥
4. **使用频率限制**：防止恶意大量请求
5. **定期轮换**：定期更新内置凭据

### 自定义凭据的安全存储

用户自定义的OAuth凭据采用以下保护措施：

1. **本地加密存储**：使用AES加密存储在本地
2. **多级存储策略**：macOS Keychain → 加密文件 → 内存缓存
3. **设备绑定**：加密密钥与设备相关
4. **完整性校验**：防止数据被篡改

## 🔍 故障排除

### 问题1：内置凭据不可用

**症状**：选择"快速开始"后提示配置失败

**解决方案**：
1. 确认使用的是分发版本（非开源版本）
2. 检查网络连接
3. 尝试"自定义配置"方案
4. 联系技术支持

### 问题2：自定义凭据验证失败

**症状**：输入凭据后提示格式错误

**解决方案**：
1. 检查Client ID格式：必须以`.apps.googleusercontent.com`结尾
2. 检查Client Secret长度：通常20+字符
3. 确认凭据类型为"桌面应用程序"
4. 重新复制粘贴，避免多余空格

### 问题3：Google认证失败

**症状**：OAuth登录页面出错

**解决方案**：
1. 检查Google Cloud项目状态
2. 确认Google Drive API已启用
3. 检查OAuth同意屏幕配置
4. 确认授权域包含`localhost`

### 问题4：应用启动时崩溃

**症状**：应用启动后立即退出

**解决方案**：
1. 重置OAuth配置：删除应用数据
2. 重新安装应用
3. 检查macOS版本兼容性
4. 查看控制台日志

## 📞 获取帮助

### 开发者资源

- **GitHub Issues**: [提交问题](https://github.com/harryboda/x-google-drive-downloader/issues)
- **技术文档**: [claude_development/](../claude_development/)
- **API文档**: [Google Drive API](https://developers.google.com/drive/api)

### 社区支持

- **开源社区**: GitHub Discussions
- **邮件支持**: harryboda@gmail.com

### 企业支持

如需企业级支持或定制化OAuth配置，请联系：
- 邮件：harryboda@gmail.com
- 主题：[Enterprise] OAuth Configuration Support

## 📈 使用统计和限制

### 内置凭据使用限制

为了确保服务稳定性，内置凭据有以下使用限制：

- **API请求频率**：每用户每小时1000次请求
- **下载大小**：单次下载最大10GB
- **并发连接**：最多4个并发下载线程

### 自定义凭据优势

使用自定义OAuth凭据可以获得：

- **更高配额**：根据Google Cloud项目配置
- **无使用限制**：除Google官方限制外无额外限制
- **优先支持**：更快的技术支持响应
- **定制化配置**：支持企业级需求

## 🔄 配置迁移

### 从v1.0升级

如果您使用过v1.0版本（需要手动设置环境变量），升级到v2.0后：

1. 首次启动会自动检测现有配置
2. 如果检测到环境变量配置，会自动沿用
3. 可以在设置中切换到内置凭据或重新配置

### 在不同设备间迁移

目前OAuth配置绑定到特定设备，如需在多设备使用：

1. **推荐方案**：每台设备使用内置凭据（分发版本）
2. **高级方案**：在每台设备配置相同的自定义OAuth凭据
3. **企业方案**：联系技术支持配置企业级OAuth管理

---

## 📝 总结

X Google Drive Downloader的智能OAuth系统确保了：

- ✅ **普通用户**：零配置，下载即用
- ✅ **高级用户**：完全控制，灵活配置  
- ✅ **开发者**：向后兼容，API友好
- ✅ **企业用户**：安全可靠，支持定制

选择最适合您的配置方案，享受便捷的Google Drive文件夹下载体验！

---

*本指南由Claude Code自动生成，确保与应用功能完全同步。*