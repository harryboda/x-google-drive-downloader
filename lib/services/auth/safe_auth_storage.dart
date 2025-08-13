import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// 存储策略枚举
enum StorageStrategy {
  secureStorage,
  encryptedFile, 
  memoryCache,
  failed
}

/// 安全的认证存储服务
/// 实现多级存储策略：SecureStorage -> 加密文件 -> 内存缓存
class SafeAuthStorage {
  static const String _tokenKey = 'auth_tokens';
  static const String _userInfoKey = 'user_info';
  static const String _encryptionKey = 'gdrive_downloader_v2_key'; // 用于文件加密

  StorageStrategy _currentStrategy = StorageStrategy.secureStorage;
  
  // Flutter Secure Storage (首选方案)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // 内存缓存 (兜底方案)
  static String? _memoryTokens;
  static String? _memoryUserInfo;

  /// 保存认证令牌
  Future<bool> saveTokens(String tokensJson) async {
    return await _saveWithFallback(_tokenKey, tokensJson);
  }

  /// 保存用户信息
  Future<bool> saveUserInfo(String userInfoJson) async {
    return await _saveWithFallback(_userInfoKey, userInfoJson);
  }

  /// 读取认证令牌
  Future<String?> loadTokens() async {
    return await _loadWithFallback(_tokenKey);
  }

  /// 读取用户信息
  Future<String?> loadUserInfo() async {
    return await _loadWithFallback(_userInfoKey);
  }

  /// 清除所有认证数据
  Future<void> clearAll() async {
    // 清除所有存储方式的数据
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userInfoKey);
    } catch (e) {
      debugPrint('清除SecureStorage失败: $e');
    }

    try {
      final file = await _getEncryptedFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('清除加密文件失败: $e');
    }

    // 清除内存缓存
    _memoryTokens = null;
    _memoryUserInfo = null;
  }

  /// 获取当前使用的存储策略
  StorageStrategy get currentStrategy => _currentStrategy;

  /// 多级保存策略
  Future<bool> _saveWithFallback(String key, String value) async {
    // 策略1: 尝试SecureStorage
    try {
      await _secureStorage.write(key: key, value: value);
      _currentStrategy = StorageStrategy.secureStorage;
      debugPrint('✅ 使用SecureStorage保存认证数据');
      return true;
    } catch (e) {
      debugPrint('⚠️ SecureStorage保存失败: $e');
    }

    // 策略2: 尝试加密文件存储
    try {
      final success = await _saveToEncryptedFile(key, value);
      if (success) {
        _currentStrategy = StorageStrategy.encryptedFile;
        debugPrint('✅ 使用加密文件保存认证数据');
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ 加密文件保存失败: $e');
    }

    // 策略3: 内存缓存 (仅本次会话有效)
    try {
      if (key == _tokenKey) {
        _memoryTokens = value;
      } else if (key == _userInfoKey) {
        _memoryUserInfo = value;
      }
      _currentStrategy = StorageStrategy.memoryCache;
      debugPrint('⚠️ 使用内存缓存保存认证数据 (重启后丢失)');
      return true;
    } catch (e) {
      debugPrint('❌ 所有存储方式都失败: $e');
    }

    _currentStrategy = StorageStrategy.failed;
    return false;
  }

  /// 多级读取策略
  Future<String?> _loadWithFallback(String key) async {
    // 策略1: 尝试SecureStorage
    try {
      final value = await _secureStorage.read(key: key);
      if (value != null) {
        debugPrint('✅ 从SecureStorage读取认证数据');
        return value;
      }
    } catch (e) {
      debugPrint('⚠️ SecureStorage读取失败: $e');
    }

    // 策略2: 尝试加密文件
    try {
      final value = await _loadFromEncryptedFile(key);
      if (value != null) {
        debugPrint('✅ 从加密文件读取认证数据');
        return value;
      }
    } catch (e) {
      debugPrint('⚠️ 加密文件读取失败: $e');
    }

    // 策略3: 内存缓存
    try {
      String? value;
      if (key == _tokenKey) {
        value = _memoryTokens;
      } else if (key == _userInfoKey) {
        value = _memoryUserInfo;
      }
      
      if (value != null) {
        debugPrint('⚠️ 从内存缓存读取认证数据');
        return value;
      }
    } catch (e) {
      debugPrint('❌ 内存缓存读取失败: $e');
    }

    debugPrint('❌ 所有存储方式都无法读取数据');
    return null;
  }

  /// 保存到加密文件
  Future<bool> _saveToEncryptedFile(String key, String value) async {
    try {
      final file = await _getEncryptedFile();
      
      // 读取现有数据
      Map<String, String> data = {};
      if (await file.exists()) {
        final encryptedContent = await file.readAsString();
        final decryptedContent = _decrypt(encryptedContent);
        if (decryptedContent != null) {
          data = Map<String, String>.from(jsonDecode(decryptedContent));
        }
      }
      
      // 更新数据
      data[key] = value;
      
      // 加密并保存
      final jsonString = jsonEncode(data);
      final encryptedContent = _encrypt(jsonString);
      await file.writeAsString(encryptedContent);
      
      return true;
    } catch (e) {
      debugPrint('加密文件保存失败: $e');
      return false;
    }
  }

  /// 从加密文件读取
  Future<String?> _loadFromEncryptedFile(String key) async {
    try {
      final file = await _getEncryptedFile();
      if (!await file.exists()) {
        return null;
      }
      
      final encryptedContent = await file.readAsString();
      final decryptedContent = _decrypt(encryptedContent);
      
      if (decryptedContent == null) {
        return null;
      }
      
      final data = Map<String, String>.from(jsonDecode(decryptedContent));
      return data[key];
    } catch (e) {
      debugPrint('加密文件读取失败: $e');
      return null;
    }
  }

  /// 获取加密文件路径
  Future<File> _getEncryptedFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/gdrive_auth_cache.dat');
  }

  /// 简单的字符串加密 (基于MD5和异或)
  String _encrypt(String plaintext) {
    final key = md5.convert(utf8.encode(_encryptionKey)).bytes;
    final plaintextBytes = utf8.encode(plaintext);
    final encryptedBytes = <int>[];
    
    for (int i = 0; i < plaintextBytes.length; i++) {
      encryptedBytes.add(plaintextBytes[i] ^ key[i % key.length]);
    }
    
    return base64.encode(encryptedBytes);
  }

  /// 简单的字符串解密
  String? _decrypt(String ciphertext) {
    try {
      final key = md5.convert(utf8.encode(_encryptionKey)).bytes;
      final encryptedBytes = base64.decode(ciphertext);
      final decryptedBytes = <int>[];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ key[i % key.length]);
      }
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('解密失败: $e');
      return null;
    }
  }

  /// 获取存储状态诊断信息
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final info = <String, dynamic>{};
    
    // SecureStorage状态
    try {
      await _secureStorage.read(key: 'test_key');
      info['secureStorage'] = 'available';
    } catch (e) {
      info['secureStorage'] = 'failed: ${e.toString()}';
    }
    
    // 加密文件状态
    try {
      final file = await _getEncryptedFile();
      info['encryptedFile'] = {
        'path': file.path,
        'exists': await file.exists(),
        'directory_writable': await file.parent.exists(),
      };
    } catch (e) {
      info['encryptedFile'] = 'failed: ${e.toString()}';
    }
    
    // 内存缓存状态
    info['memoryCache'] = {
      'tokens_cached': _memoryTokens != null,
      'user_info_cached': _memoryUserInfo != null,
    };
    
    info['currentStrategy'] = _currentStrategy.toString();
    
    return info;
  }
}