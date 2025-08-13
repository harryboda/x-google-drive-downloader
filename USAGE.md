# 应用使用说明

## 启动方式

### 1. Debug 模式（开发调试）
```bash
./debug_oauth.sh
```
- **用途**: 开发和调试
- **特点**: 包含调试信息，热重载支持，可能显示调试叠加层
- **OAuth配置**: 使用测试凭据

### 2. Release 模式（生产使用）  
```bash
./run_release.sh
```
- **用途**: 正式使用
- **特点**: 优化性能，无调试信息，清洁界面
- **OAuth配置**: 需要配置真实的Google OAuth凭据

## OAuth 配置

### 获取 Google OAuth 凭据

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建项目并启用 Google Drive API
3. 创建 OAuth 2.0 客户端ID（桌面应用程序类型）
4. 记录 Client ID 和 Client Secret

### 配置生产环境凭据

编辑 `run_release.sh` 文件，替换以下变量：

```bash
PROD_CLIENT_ID="your_actual_client_id.apps.googleusercontent.com"
PROD_CLIENT_SECRET="your_actual_client_secret"
```

## 界面差异

### Debug 模式可能显示
- 调试信息叠加层
- 开发者工具标记
- 性能监控信息
- 竖排调试文字标记

### Release 模式特点
- 清洁的用户界面
- 无调试信息干扰
- 优化的应用性能
- 适合最终用户使用

## 功能使用

1. **OAuth 登录**: 启动后点击"开始认证"按钮
2. **粘贴链接**: 在文件夹链接框中粘贴 Google Drive 分享链接
3. **选择路径**: 点击"选择"按钮选择下载保存位置
4. **开始下载**: 点击"开始下载"按钮开始下载过程
5. **监控进度**: 查看实时下载进度和状态

## 故障排除

### 界面显示异常
- 如果看到调试文字或叠加层，请使用 `./run_release.sh` 启动
- 重启应用清除系统缓存

### OAuth 认证失败
- 检查网络连接
- 确认 Google Cloud 项目配置正确
- 验证 OAuth 凭据是否有效

### 下载失败
- 确认 Google Drive 链接可访问
- 检查用户是否有相应权限
- 验证本地存储空间足够