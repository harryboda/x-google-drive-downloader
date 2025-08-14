import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/auth/auth_tokens.dart';
import '../../models/auth/user_info.dart';
import '../../config/app_config.dart';
import 'safe_auth_storage.dart';

class AuthService extends ChangeNotifier {
  // Google OAuth 2.0 配置 - 从配置文件获取
  static String get clientId => AppConfig.clientId;
  static String get clientSecret => AppConfig.clientSecret;
  static String get redirectUri => AppConfig.redirectUri;
  static String get scope => AppConfig.scope;
  
  static const String authorizationEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const String tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const String userInfoEndpoint = 'https://www.googleapis.com/oauth2/v2/userinfo';

  // 安全存储 - 使用多级存储策略
  final SafeAuthStorage _safeStorage = SafeAuthStorage();

  // 状态
  AuthTokens? _tokens;
  UserInfo? _userInfo;
  bool _isLoading = false;

  // Getters
  AuthTokens? get tokens => _tokens;
  UserInfo? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _tokens != null && !_tokens!.isExpired;

  final Dio _dio = Dio();

  AuthService() {
    _initializeDio();
    _initializeAppConfig();
  }
  
  /// 初始化AppConfig缓存
  Future<void> _initializeAppConfig() async {
    try {
      // 触发AppConfig的异步初始化，设置缓存
      await AppConfig.getClientId();
      await _loadSavedAuth();
    } catch (e) {
      debugPrint('初始化AppConfig失败: $e');
      await _loadSavedAuth();
    }
  }

  void _initializeDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // 添加请求拦截器自动添加Authorization header
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 排除OAuth相关的请求，避免递归和错误的Authorization header
        final isOAuthRequest = options.path.contains('oauth2.googleapis.com') || 
                               options.path.contains(tokenEndpoint) ||
                               options.path.contains(authorizationEndpoint);
        
        if (!isOAuthRequest && _tokens != null && !_tokens!.isExpired) {
          options.headers['Authorization'] = _tokens!.authorizationHeader;
        } else if (!isOAuthRequest && _tokens != null && _tokens!.isExpiringSoon) {
          // 只对非OAuth请求进行token刷新
          await _refreshTokenIfNeeded();
          if (_tokens != null) {
            options.headers['Authorization'] = _tokens!.authorizationHeader;
          }
        }
        handler.next(options);
      },
    ));
  }

  /// 加载保存的认证信息
  Future<void> _loadSavedAuth() async {
    try {
      final tokensJson = await _safeStorage.loadTokens();
      final userInfoJson = await _safeStorage.loadUserInfo();

      if (tokensJson != null) {
        _tokens = AuthTokens.fromJson(jsonDecode(tokensJson));
        debugPrint('✅ 成功加载认证令牌 (存储方式: ${_safeStorage.currentStrategy})');
      }

      if (userInfoJson != null) {
        _userInfo = UserInfo.fromJson(jsonDecode(userInfoJson));
        debugPrint('✅ 成功加载用户信息');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ 加载认证信息失败: $e');
    }
  }

  /// 保存认证信息
  Future<void> _saveAuth() async {
    try {
      bool success = true;
      
      if (_tokens != null) {
        final tokensSaved = await _safeStorage.saveTokens(jsonEncode(_tokens!.toJson()));
        if (!tokensSaved) {
          success = false;
          debugPrint('❌ 保存认证令牌失败');
        } else {
          debugPrint('✅ 成功保存认证令牌 (存储方式: ${_safeStorage.currentStrategy})');
        }
      }

      if (_userInfo != null) {
        final userInfoSaved = await _safeStorage.saveUserInfo(jsonEncode(_userInfo!.toJson()));
        if (!userInfoSaved) {
          success = false;
          debugPrint('❌ 保存用户信息失败');
        } else {
          debugPrint('✅ 成功保存用户信息');
        }
      }
      
      if (!success) {
        // 显示存储诊断信息
        final diagnostics = await _safeStorage.getDiagnosticInfo();
        debugPrint('🔍 存储诊断信息: $diagnostics');
      }
      
    } catch (e) {
      debugPrint('❌ 保存认证信息时发生异常: $e');
    }
  }

  /// 生成授权URL
  String generateAuthUrl() {
    debugPrint('🚀 生成OAuth认证URL...');
    debugPrint('🔑 Client ID: ${clientId.isNotEmpty ? "${clientId.substring(0, 20)}..." : "空"}');
    debugPrint('🔗 重定向URI: $redirectUri');
    
    if (clientId.isEmpty) {
      debugPrint('❌ Client ID为空，无法生成认证URL');
      return '';
    }
    
    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scope,
      'response_type': 'code',
      'access_type': 'offline',
      'prompt': 'consent',
      'state': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    final uri = Uri.parse(authorizationEndpoint).replace(
      queryParameters: params,
    );

    debugPrint('✅ 认证URL生成成功: ${uri.toString().substring(0, 100)}...');
    return uri.toString();
  }

  /// 通过授权码获取token
  Future<bool> exchangeCodeForTokens(String authorizationCode) async {
    _setLoading(true);

    try {
      debugPrint('🔄 开始交换授权码获取令牌...');
      debugPrint('📝 授权码: ${authorizationCode.substring(0, 10)}...');
      debugPrint('🔑 Client ID: ${clientId.isNotEmpty ? "${clientId.substring(0, 20)}..." : "空"}');
      debugPrint('🔐 Client Secret: ${clientSecret.isNotEmpty ? "已设置" : "未设置"}');
      debugPrint('🔗 重定向URI: $redirectUri');
      
      if (clientId.isEmpty || clientSecret.isEmpty) {
        debugPrint('❌ OAuth配置不完整！');
        return false;
      }
      
      debugPrint('🌐 发送令牌请求到: $tokenEndpoint');
      final response = await _dio.post(
        tokenEndpoint,
        data: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': authorizationCode,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      debugPrint('✅ 令牌请求成功！HTTP状态: ${response.statusCode}');
      final tokenData = response.data;
      debugPrint('📦 收到令牌数据: ${tokenData.keys.join(", ")}');
      
      _tokens = AuthTokens(
        accessToken: tokenData['access_token'],
        refreshToken: tokenData['refresh_token'],
        tokenType: tokenData['token_type'] ?? 'Bearer',
        expiresIn: tokenData['expires_in'],
        issuedAt: DateTime.now(),
        scope: tokenData['scope'] ?? scope,
      );

      debugPrint('👤 开始获取用户信息...');
      // 获取用户信息
      await _fetchUserInfo();
      
      debugPrint('💾 开始保存认证信息...');
      await _saveAuth();

      debugPrint('🎉 认证流程完成！');
      notifyListeners();
      return true;
    } catch (e) {
      String errorMessage = 'Failed to exchange code for tokens: $e';
      
      if (e is DioException) {
        final response = e.response;
        if (response != null) {
          errorMessage += '\nHTTP Status: ${response.statusCode}';
          errorMessage += '\nResponse: ${response.data}';
          
          // 分析具体错误
          if (response.data is Map && response.data['error'] != null) {
            final error = response.data['error'];
            final errorDescription = response.data['error_description'];
            errorMessage += '\nOAuth Error: $error';
            if (errorDescription != null) {
              errorMessage += '\nDescription: $errorDescription';
            }
          }
        }
      }
      
      debugPrint(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 获取用户信息
  Future<void> _fetchUserInfo() async {
    try {
      debugPrint('🌐 获取用户信息从: $userInfoEndpoint');
      final response = await _dio.get(userInfoEndpoint);
      _userInfo = UserInfo.fromJson(response.data);
      debugPrint('✅ 用户信息获取成功: ${_userInfo!.name}');
    } catch (e) {
      debugPrint('❌ 获取用户信息失败: $e');
    }
  }

  /// 刷新token
  Future<bool> _refreshTokenIfNeeded() async {
    if (_tokens?.refreshToken == null) return false;

    try {
      final response = await _dio.post(
        tokenEndpoint,
        data: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': _tokens!.refreshToken,
          'grant_type': 'refresh_token',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final tokenData = response.data;
      _tokens = _tokens!.copyWith(
        accessToken: tokenData['access_token'],
        expiresIn: tokenData['expires_in'],
        issuedAt: DateTime.now(),
      );

      await _saveAuth();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to refresh token: $e');
      return false;
    }
  }

  /// 登出
  Future<void> signOut() async {
    _tokens = null;
    _userInfo = null;

    await _safeStorage.clearAll();
    debugPrint('✅ 已清除所有认证信息');

    notifyListeners();
  }

  /// 获取用于API调用的Dio实例
  Dio getAuthenticatedDio() {
    return _dio;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 获取认证存储诊断信息 (用于调试)
  Future<Map<String, dynamic>> getStorageDiagnostics() async {
    return await _safeStorage.getDiagnosticInfo();
  }

  /// 获取当前存储策略
  String get currentStorageStrategy => _safeStorage.currentStrategy.toString();
}