import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/auth/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  WebViewController? _webViewController;
  bool _isWebViewVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // 处理重定向URI，包括localhost的任何端口
            if (request.url.startsWith('http://localhost')) {
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            // 页面加载完成后显示WebView
            if (_isWebViewVisible) {
              setState(() {});
            }
          },
        ),
      );
  }

  void _handleRedirect(String url) {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];

    setState(() {
      _isWebViewVisible = false;
    });

    if (error != null) {
      _showErrorDialog('认证失败: $error');
      return;
    }

    if (code != null) {
      _exchangeCodeForTokens(code);
    } else {
      _showErrorDialog('未收到授权码');
    }
  }

  Future<void> _exchangeCodeForTokens(String code) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('正在获取访问令牌...', style: AppTheme.bodyStyle),
          ],
        ),
      ),
    );
    
    final success = await authService.exchangeCodeForTokens(code);
    
    // 关闭加载对话框
    if (mounted) Navigator.of(context).pop();

    if (!success) {
      _showErrorDialog(
        '获取访问令牌失败\n\n'
        '可能的原因：\n'
        '1. 重定向URI配置不匹配\n'
        '2. 客户端ID或密钥错误\n'
        '3. 网络连接问题\n\n'
        '请检查控制台日志获取详细错误信息'
      );
    }
    // 成功的话，AuthService会通知UI更新，主app会自动导航到主页面
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '认证错误',
          style: AppTheme.headlineStyle,
        ),
        content: Text(
          message,
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '确定',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startAuth() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final authUrl = authService.generateAuthUrl();
    
    _webViewController?.loadRequest(Uri.parse(authUrl));
    setState(() {
      _isWebViewVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 主认证界面
              if (!_isWebViewVisible)
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return GlassCard(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 应用图标和标题
                                _buildHeader(),
                                
                                const SizedBox(height: 32),
                                
                                // 功能介绍
                                _buildFeatures(),
                                
                                const SizedBox(height: 32),
                                
                                // 登录按钮
                                AnimatedButton(
                                  text: '使用 Google 账户登录',
                                  icon: Icons.login,
                                  width: double.infinity,
                                  isLoading: authService.isLoading,
                                  onPressed: authService.isLoading ? null : _startAuth,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // 隐私说明
                                _buildPrivacyNote(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // WebView认证界面
              if (_isWebViewVisible)
                Column(
                  children: [
                    // 顶部工具栏
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isWebViewVisible = false;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Google 账户登录',
                              style: AppTheme.headlineStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // WebView
                    Expanded(
                      child: _webViewController != null
                          ? WebViewWidget(controller: _webViewController!)
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.buttonShadow,
          ),
          child: const Icon(
            Icons.cloud_download_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Google Drive Downloader',
          style: AppTheme.titleStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '快速、安全地下载 Google Drive 文件夹',
          style: AppTheme.subtitleStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      {'icon': Icons.security, 'title': '安全认证', 'desc': '直接通过 Google 官方认证'},
      {'icon': Icons.flash_on, 'title': '高速下载', 'desc': '并发下载，提升下载速度'},
      {'icon': Icons.folder, 'title': '批量处理', 'desc': '支持整个文件夹递归下载'},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      feature['desc'] as String,
                      style: AppTheme.captionStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrivacyNote() {
    return Text(
      '我们不会存储您的 Google 账户密码。认证过程完全由 Google 处理，确保您的账户安全。',
      style: AppTheme.captionStyle,
      textAlign: TextAlign.center,
    );
  }
}