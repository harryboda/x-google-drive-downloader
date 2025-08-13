/// 应用配置文件 v2.0
class AppConfig {
  // Google OAuth 2.0 配置 - 支持内置默认值和用户自定义
  
  // 内置的默认OAuth配置 (开发者提供)
  static const String _defaultClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String _defaultClientSecret = 'YOUR_GOOGLE_CLIENT_SECRET';
  
  // 用户自定义配置 (高级用户可以设置)
  static String? _customClientId;
  static String? _customClientSecret;
  
  /// 获取客户端ID (优先级: 环境变量 > 用户自定义 > 内置默认)
  static String get clientId {
    // 1. 优先使用环境变量 (保持向后兼容)
    const clientIdFromEnv = String.fromEnvironment('GOOGLE_CLIENT_ID');
    if (clientIdFromEnv.isNotEmpty) {
      return clientIdFromEnv;
    }
    
    // 2. 使用用户自定义配置
    if (_customClientId != null && _customClientId!.isNotEmpty) {
      return _customClientId!;
    }
    
    // 3. 使用内置默认配置
    return _defaultClientId;
  }
  
  /// 获取客户端密钥 (优先级: 环境变量 > 用户自定义 > 内置默认)
  static String get clientSecret {
    // 1. 优先使用环境变量 (保持向后兼容)
    const clientSecretFromEnv = String.fromEnvironment('GOOGLE_CLIENT_SECRET');
    if (clientSecretFromEnv.isNotEmpty) {
      return clientSecretFromEnv;
    }
    
    // 2. 使用用户自定义配置
    if (_customClientSecret != null && _customClientSecret!.isNotEmpty) {
      return _customClientSecret!;
    }
    
    // 3. 使用内置默认配置
    return _defaultClientSecret;
  }
  
  /// 设置用户自定义OAuth配置
  static void setCustomOAuth({
    required String clientId,
    required String clientSecret,
  }) {
    _customClientId = clientId.trim();
    _customClientSecret = clientSecret.trim();
  }
  
  /// 清除用户自定义配置，恢复默认值
  static void resetToDefault() {
    _customClientId = null;
    _customClientSecret = null;
  }
  
  /// 获取当前配置来源信息
  static String get configSource {
    const envClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    if (envClientId.isNotEmpty) {
      return '环境变量';
    }
    
    if (_customClientId != null) {
      return '用户自定义';
    }
    
    return '内置默认';
  }
  
  /// 检查是否使用默认配置
  static bool get isUsingDefault {
    const envClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    return envClientId.isEmpty && _customClientId == null;
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