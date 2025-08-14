import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 调试用的OAuth重置工具
/// 清除所有OAuth配置，强制应用进入配置向导
void main() async {
  print('🔄 开始重置OAuth配置...');
  
  try {
    // 初始化SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // 清除所有OAuth相关的配置
    final keys = [
      'custom_oauth_config',
      'first_run_completed', 
      'oauth_config_choice',
      'auth_tokens',
      'user_info',
      'oauth_first_run',
      'has_oauth_config'
    ];
    
    for (String key in keys) {
      final removed = await prefs.remove(key);
      if (removed) {
        print('✅ 清除配置: $key');
      } else {
        print('ℹ️ 配置不存在: $key');
      }
    }
    
    // 清除所有存储的键
    final allKeys = prefs.getKeys();
    print('📋 当前存储的所有键: ${allKeys.join(", ")}');
    
    for (String key in allKeys) {
      if (key.contains('oauth') || key.contains('auth') || key.contains('google') || key.contains('client')) {
        await prefs.remove(key);
        print('🗑️ 删除相关键: $key');
      }
    }
    
    print('');
    print('✅ OAuth配置重置完成!');
    print('🚀 下次启动应用将进入配置向导');
    
  } catch (e) {
    print('❌ 重置失败: $e');
  }
}