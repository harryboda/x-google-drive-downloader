import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_credentials_provider.dart';

/// OAuth配置管理器
/// 实现四层级的OAuth解决方案：
/// 1. 用户自定义配置（最高优先级）
/// 2. 环境变量配置（开发者/高级用户）
/// 3. 内置安全凭据（普通用户，加密存储）
/// 4. 引导用户配置（兜底方案）
class OAuthConfigManager {
  static const String _customConfigKey = 'custom_oauth_config';
  static const String _firstRunKey = 'first_run_completed';
  static const String _configChoiceKey = 'oauth_config_choice';
  
  // 配置选择类型
  enum ConfigChoice {
    notSelected,     // 未选择
    useBuiltIn,      // 使用内置凭据
    useCustom,       // 使用自定义凭据
    guided          // 需要引导设置
  }
  
  /// 检查OAuth配置状态
  static Future<OAuthConfigStatus> checkConfigStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = !prefs.getBool(_firstRunKey, false);
    
    if (isFirstRun) {
      return OAuthConfigStatus.firstRun;
    }
    
    final choice = _parseConfigChoice(prefs.getString(_configChoiceKey));
    
    switch (choice) {
      case ConfigChoice.useBuiltIn:
        if (await _hasValidBuiltInCredentials()) {
          return OAuthConfigStatus.builtInReady;
        }
        return OAuthConfigStatus.needsConfiguration;
        
      case ConfigChoice.useCustom:
        if (await _hasValidCustomCredentials()) {
          return OAuthConfigStatus.customReady;
        }
        return OAuthConfigStatus.needsConfiguration;
        
      case ConfigChoice.notSelected:
      case ConfigChoice.guided:
      default:
        return OAuthConfigStatus.needsConfiguration;
    }
  }
  
  /// 获取当前有效的OAuth配置
  static Future<OAuthCredentials?> getCurrentCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final choice = _parseConfigChoice(prefs.getString(_configChoiceKey));
    
    switch (choice) {
      case ConfigChoice.useBuiltIn:
        return await _getBuiltInCredentials();
        
      case ConfigChoice.useCustom:
        return await _getCustomCredentials();
        
      default:
        // 尝试环境变量（向后兼容）
        return _getEnvironmentCredentials();
    }
  }
  
  /// 保存用户的配置选择
  static Future<void> saveConfigChoice(ConfigChoice choice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configChoiceKey, choice.name);
    await prefs.setBool(_firstRunKey, true);
  }
  
  /// 保存自定义OAuth配置
  static Future<bool> saveCustomCredentials(String clientId, String clientSecret) async {
    try {
      if (!_validateCredentials(clientId, clientSecret)) {
        return false;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final config = {
        'client_id': clientId,
        'client_secret': clientSecret,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // 简单加密存储（用于基本保护）
      final encrypted = _encryptConfig(jsonEncode(config));
      await prefs.setString(_customConfigKey, encrypted);
      
      return true;
    } catch (e) {
      debugPrint('保存自定义OAuth配置失败: $e');
      return false;
    }
  }
  
  /// 清除自定义配置
  static Future<void> clearCustomCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customConfigKey);
  }
  
  /// 重置所有配置（用于故障排除）
  static Future<void> resetAllConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customConfigKey);
    await prefs.remove(_configChoiceKey);
    await prefs.remove(_firstRunKey);
  }
  
  // === 私有方法 ===
  
  static ConfigChoice _parseConfigChoice(String? value) {
    if (value == null) return ConfigChoice.notSelected;
    try {
      return ConfigChoice.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return ConfigChoice.notSelected;
    }
  }
  
  static Future<bool> _hasValidBuiltInCredentials() async {
    final credentials = await _getBuiltInCredentials();
    return credentials != null && 
           credentials.clientId.isNotEmpty && 
           credentials.clientSecret.isNotEmpty;
  }
  
  static Future<bool> _hasValidCustomCredentials() async {
    final credentials = await _getCustomCredentials();
    return credentials != null && 
           credentials.clientId.isNotEmpty && 
           credentials.clientSecret.isNotEmpty;
  }
  
  static Future<OAuthCredentials?> _getBuiltInCredentials() async {
    // 内置凭据（加密存储，用于普通用户）
    // 注意：这里使用编译时加密的默认凭据
    try {
      final decrypted = await _getSecureBuiltInCredentials();
      if (decrypted != null) {
        return OAuthCredentials(
          clientId: decrypted['client_id']!,
          clientSecret: decrypted['client_secret']!,
          source: 'built-in',
        );
      }
    } catch (e) {
      debugPrint('获取内置凭据失败: $e');
    }
    return null;
  }
  
  static Future<OAuthCredentials?> _getCustomCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encrypted = prefs.getString(_customConfigKey);
      if (encrypted == null) return null;
      
      final decrypted = _decryptConfig(encrypted);
      final config = jsonDecode(decrypted) as Map<String, dynamic>;
      
      return OAuthCredentials(
        clientId: config['client_id'] as String,
        clientSecret: config['client_secret'] as String,
        source: 'custom',
      );
    } catch (e) {
      debugPrint('获取自定义凭据失败: $e');
      return null;
    }
  }
  
  static OAuthCredentials? _getEnvironmentCredentials() {
    const clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    const clientSecret = String.fromEnvironment('GOOGLE_CLIENT_SECRET');
    
    if (clientId.isNotEmpty && clientSecret.isNotEmpty) {
      return OAuthCredentials(
        clientId: clientId,
        clientSecret: clientSecret,
        source: 'environment',
      );
    }
    return null;
  }
  
  static Future<Map<String, String>?> _getSecureBuiltInCredentials() async {
    // 使用安全凭据提供器获取内置凭据
    try {
      return await SecureCredentialsProvider.getBuiltInCredentials();
    } catch (e) {
      debugPrint('获取安全内置凭据失败: $e');
      return null;
    }
  }
  
  static bool _validateCredentials(String clientId, String clientSecret) {
    // 验证Google OAuth客户端ID格式
    final clientIdPattern = RegExp(r'^[0-9]+-[a-zA-Z0-9]+\.apps\.googleusercontent\.com$');
    if (!clientIdPattern.hasMatch(clientId)) {
      return false;
    }
    
    // 验证客户端密钥格式
    final clientSecretPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!clientSecretPattern.hasMatch(clientSecret) || clientSecret.length < 20) {
      return false;
    }
    
    return true;
  }
  
  static String _encryptConfig(String data) {
    // 简单的基于设备的加密（用于基本保护）
    final key = _generateDeviceKey();
    final bytes = utf8.encode(data);
    final encrypted = <int>[];
    
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ key[i % key.length]);
    }
    
    return base64Encode(encrypted);
  }
  
  static String _decryptConfig(String encryptedData) {
    final key = _generateDeviceKey();
    final encrypted = base64Decode(encryptedData);
    final decrypted = <int>[];
    
    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ key[i % key.length]);
    }
    
    return utf8.decode(decrypted);
  }
  
  static List<int> _generateDeviceKey() {
    // 基于应用包名和一些常量生成简单的密钥
    const packageName = 'com.xiong.googledrivedownload';
    const salt = 'claude-code-ai-2024';
    final combined = '$packageName$salt';
    return sha256.convert(utf8.encode(combined)).bytes.take(32).toList();
  }
}

/// OAuth配置状态
enum OAuthConfigStatus {
  firstRun,           // 首次运行，需要引导
  builtInReady,       // 内置凭据可用
  customReady,        // 自定义凭据可用
  needsConfiguration, // 需要配置
}

/// OAuth凭据数据类
class OAuthCredentials {
  final String clientId;
  final String clientSecret;
  final String source;
  
  const OAuthCredentials({
    required this.clientId,
    required this.clientSecret,
    required this.source,
  });
  
  /// 重定向URI（桌面应用标准）
  String get redirectUri => 'http://localhost';
  
  /// Google Drive API权限范围
  String get scope => 'https://www.googleapis.com/auth/drive.readonly https://www.googleapis.com/auth/userinfo.profile';
  
  @override
  String toString() => 'OAuthCredentials(source: $source, clientId: ${clientId.substring(0, 20)}...)';
}