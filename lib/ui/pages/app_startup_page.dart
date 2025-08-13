import 'package:flutter/material.dart';
import '../../services/auth/oauth_config_manager.dart';
import 'oauth_setup_page.dart';
import 'auth_page.dart';

/// 应用启动页面
/// 检测OAuth配置状态并引导用户到正确的页面
class AppStartupPage extends StatefulWidget {
  const AppStartupPage({super.key});

  @override
  State<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends State<AppStartupPage> {
  bool _isLoading = true;
  String _statusMessage = '正在初始化...';

  @override
  void initState() {
    super.initState();
    _checkOAuthConfig();
  }

  Future<void> _checkOAuthConfig() async {
    try {
      setState(() {
        _statusMessage = '检查认证配置...';
      });

      // 检查OAuth配置状态
      final status = await OAuthConfigManager.checkConfigStatus();
      
      if (!mounted) return;

      switch (status) {
        case OAuthConfigStatus.firstRun:
          _navigateToOAuthSetup(isFirstRun: true);
          break;
          
        case OAuthConfigStatus.needsConfiguration:
          _navigateToOAuthSetup(isFirstRun: false);
          break;
          
        case OAuthConfigStatus.builtInReady:
        case OAuthConfigStatus.customReady:
          _navigateToAuthPage();
          break;
      }
    } catch (e) {
      setState(() {
        _statusMessage = '初始化失败，正在重试...';
      });
      
      // 延迟后重试
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _navigateToOAuthSetup(isFirstRun: false);
      }
    }
  }

  void _navigateToOAuthSetup({required bool isFirstRun}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OAuthSetupPage(isFirstRun: isFirstRun),
      ),
    );
  }

  void _navigateToAuthPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.cloud_download,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 32),
            
            // 应用名称
            Text(
              'X Google Drive Downloader',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 8),
            
            // AI开发标识
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🤖 完全由 Claude Code 开发',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // 加载指示器
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
              ),
            ),
            const SizedBox(height: 16),
            
            // 状态消息
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8E8E93),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 手动配置按钮（故障排除）
            TextButton(
              onPressed: () => _navigateToOAuthSetup(isFirstRun: false),
              child: Text(
                '手动配置认证',
                style: TextStyle(
                  color: const Color(0xFF007AFF).withOpacity(0.7),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}