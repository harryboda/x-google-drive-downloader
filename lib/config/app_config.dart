import '../services/auth/oauth_config_manager.dart';

/// 应用配置文件 v3.0 - 智能OAuth配置管理
class AppConfig {
  // 缓存的OAuth凭据
  static OAuthCredentials? _cachedCredentials;
  
  /// 获取客户端ID
  static Future<String> getClientId() async {
    final credentials = await _getCredentials();
    return credentials?.clientId ?? '';
  }
  
  /// 获取客户端密钥
  static Future<String> getClientSecret() async {
    final credentials = await _getCredentials();
    return credentials?.clientSecret ?? '';
  }
  
  /// 获取当前有效的OAuth凭据
  static Future<OAuthCredentials?> _getCredentials() async {
    if (_cachedCredentials != null) {
      return _cachedCredentials;
    }
    
    _cachedCredentials = await OAuthConfigManager.getCurrentCredentials();
    return _cachedCredentials;
  }
  
  /// 清除凭据缓存（当配置更改时调用）
  static void clearCredentialsCache() {
    _cachedCredentials = null;
  }
  
  /// 检查OAuth配置是否可用
  static Future<bool> hasValidOAuthConfig() async {
    final credentials = await _getCredentials();
    return credentials != null && 
           credentials.clientId.isNotEmpty && 
           credentials.clientSecret.isNotEmpty;
  }
  
  /// 获取当前配置来源信息
  static Future<String> getConfigSource() async {
    final credentials = await _getCredentials();
    return credentials?.source ?? '未配置';
  }
  
  /// 同步版本的clientId (向后兼容)
  static String get clientId {
    // 这个方法保持同步以向后兼容，但建议使用异步版本
    return _cachedCredentials?.clientId ?? '';
  }
  
  /// 同步版本的clientSecret (向后兼容)  
  static String get clientSecret {
    // 这个方法保持同步以向后兼容，但建议使用异步版本
    return _cachedCredentials?.clientSecret ?? '';
  }
  
  // 重定向URI (桌面应用标准配置)
  static const String redirectUri = 'http://localhost';
  
  // Google Drive API 权限范围
  static const String scope = 'https://www.googleapis.com/auth/drive.readonly https://www.googleapis.com/auth/userinfo.profile';
  
  // 下载配置
  static const int defaultConcurrentDownloads = 4;
  static const int maxConcurrentDownloads = 8;
  static const int defaultRetryAttempts = 3;
  
  // 应用信息
  static const String appName = 'X Google Drive Downloader';
  static const String appVersion = '2.0.0';
  static const String appDescription = '快速、安全地下载 Google Drive 文件夹';
  
  // 开发者设置指南
  static const String setupGuide = '''
要使用Google Drive API，请按以下步骤设置:

1. 访问 Google Cloud Console (https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 启用 Google Drive API
4. 创建 OAuth 2.0 客户端 ID
5. 设置环境变量:
   export GOOGLE_CLIENT_ID="your_client_id.apps.googleusercontent.com"
   export GOOGLE_CLIENT_SECRET="your_client_secret"
6. 构建并运行应用

安全提示:
- 永远不要将OAuth凭证提交到代码仓库
- 使用环境变量或安全的配置管理工具
- 生产环境建议使用更安全的密钥管理服务

详细步骤请参考项目中的SETUP_GUIDE.md文档。
''';
}