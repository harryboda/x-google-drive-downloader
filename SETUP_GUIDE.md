# Google Drive Downloader v2.0 设置指南

## 项目概述

这是一个使用Flutter开发的现代化Google Drive文件夹下载工具，支持直接通过Google Drive API下载文件，无需依赖外部命令行工具。

## 功能特性

- ✅ 现代化macOS风格界面设计
- ✅ 直接Google Drive API集成（无需gdrive命令行工具）
- ✅ OAuth 2.0安全认证流程
- ✅ 并发下载优化（可配置并发数）
- ✅ 实时进度监控和状态显示
- ✅ 安全的Token存储和自动刷新
- ✅ 智能剪贴板检测Google Drive链接
- ✅ 完整的错误处理和重试机制

## 开发环境要求

- Flutter 3.x
- Dart 3.x
- macOS 开发环境
- Xcode 命令行工具

## Google Cloud Console 配置步骤

### 1. 创建Google Cloud项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 点击项目选择器，创建新项目或选择现有项目
3. 记录项目ID，后续会用到

### 2. 启用必要的API

在API库中启用以下API：
- Google Drive API
- Google+ API（用于用户信息）

### 3. 创建OAuth 2.0凭证

1. 进入 "API和服务" > "凭据"
2. 点击 "创建凭据" > "OAuth 2.0客户端ID"
3. 选择应用类型为 "桌面应用程序"
4. 输入名称：`Google Drive Downloader Desktop`
5. 在重定向URI中添加：`http://localhost`（注意：不需要端口号）

⚠️ **重要提示**：重定向URI必须完全匹配。对于桌面应用，使用 `http://localhost` 是Google推荐的标准配置。

### 4. 配置应用凭证

使用环境变量安全地配置凭证：

#### 方法一：使用 .env 文件（推荐）
```bash
# 1. 复制环境变量示例文件
cp .env.example .env

# 2. 编辑 .env 文件，填入真实凭证
# GOOGLE_CLIENT_ID=你的客户端ID.apps.googleusercontent.com
# GOOGLE_CLIENT_SECRET=你的客户端密钥
```

#### 方法二：直接设置环境变量
```bash
export GOOGLE_CLIENT_ID="你的客户端ID.apps.googleusercontent.com"
export GOOGLE_CLIENT_SECRET="你的客户端密钥"
```

⚠️ **安全提示：**
- 永远不要将真实凭证提交到代码仓库
- .env 文件已添加到 .gitignore 中
- 生产环境建议使用更安全的密钥管理服务

### 5. 权限配置说明

应用请求的权限范围：
- `https://www.googleapis.com/auth/drive.readonly` - 只读访问Google Drive
- `https://www.googleapis.com/auth/userinfo.profile` - 访问用户基本信息

## 构建和运行

### 快速开始（推荐）

#### 使用自动化脚本
```bash
# 开发环境运行（会自动加载.env文件）
./run_app.sh

# 构建发布版本
./build_app.sh
```

### 手动运行

#### 开发环境运行
```bash
# 1. 加载环境变量（如果使用.env文件）
source .env

# 2. 安装依赖
flutter pub get

# 3. 生成序列化代码
dart run build_runner build

# 4. 运行应用（通过dart-define传递环境变量）
flutter run -d macos \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
  --dart-define=GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET"
```

#### 构建发布版本
```bash
# 1. 加载环境变量
source .env

# 2. 构建macOS应用
flutter build macos --release \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
  --dart-define=GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET"

# 3. 应用位置
# ./build/macos/Build/Products/Release/gdrive_downloader_flutter.app
```

## 应用架构

### 核心服务
- `AuthService` - OAuth 2.0认证和Token管理
- `GoogleDriveApi` - Google Drive API客户端
- `AdvancedDownloadService` - 高性能并发下载引擎
- `ClipboardService` - 智能剪贴板监听

### 安全特性
- Flutter Secure Storage存储敏感信息
- 自动Token刷新机制
- App Sandbox安全模型
- 网络请求自动认证拦截器

## 使用说明

1. **首次启动**：应用会打开OAuth认证页面
2. **授权登录**：使用Google账户登录并授权应用访问
3. **输入链接**：粘贴Google Drive文件夹分享链接
4. **选择路径**：选择本地下载保存位置
5. **开始下载**：点击下载按钮开始批量下载
6. **监控进度**：实时查看下载进度和状态

## 故障排除

### 常见问题

**OAuth认证失败**
- 检查环境变量 GOOGLE_CLIENT_ID 和 GOOGLE_CLIENT_SECRET 是否正确设置
- 确认重定向URI配置正确：`http://localhost`（不是 `http://localhost:8080/auth/callback`）
- 检查Google Drive API和Google+ API是否已启用
- 验证 .env 文件格式是否正确（无空格、引号等）
- 确保Google Cloud Console中的应用类型选择为"桌面应用程序"
- 检查控制台日志获取详细错误信息

**下载失败**
- 检查网络连接
- 确认Google Drive文件夹为公开分享或已授权访问
- 查看应用日志获取详细错误信息

**环境变量配置问题**
- 应用启动时提示"未找到Google客户端ID"：确保已正确设置环境变量
- 检查 .env 文件是否存在：`ls -la .env`
- 验证环境变量加载：`echo $GOOGLE_CLIENT_ID`
- 确保运行 `source .env` 后再启动应用

**权限问题**
- 确认macOS文件访问权限
- 检查下载目标目录的写入权限

## 开发者信息

- 版本：v2.0.0
- 架构：Flutter Desktop (macOS)
- 认证：OAuth 2.0
- API：Google Drive API v3

## 版本历史

### v2.0.0 (当前版本)
- 完全重构为Flutter Desktop应用
- 直接集成Google Drive API
- 移除外部工具依赖
- 现代化UI设计
- 优化下载性能
- 🔒 **安全性升级**：使用环境变量管理OAuth凭证
- 🛠️ **开发体验**：提供自动化构建和运行脚本

### v1.0.0 (Legacy)
- Python Tkinter GUI
- 依赖gdrive命令行工具
- 基础下载功能