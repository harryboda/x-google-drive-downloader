import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/download_service.dart';
import 'services/clipboard_service.dart';
import 'services/auth/auth_service.dart';
import 'ui/theme/app_theme.dart';
import 'ui/pages/app_startup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 认证服务 - 必须最先初始化
        ChangeNotifierProvider(create: (context) => AuthService()),
        
        // 简化Provider架构，移除复杂的依赖链
        // 在需要时通过AuthService.getAuthenticatedDio()直接创建服务
        
        // 下载服务 - 依赖认证服务
        ChangeNotifierProxyProvider<AuthService, DownloadService>(
          create: (context) => DownloadService(Provider.of<AuthService>(context, listen: false)),
          update: (context, authService, previous) => previous ?? DownloadService(authService),
        ),
        
        ChangeNotifierProvider(create: (context) => ClipboardService()),
      ],
      child: MaterialApp(
        title: 'X Google Drive Downloader',
        theme: AppTheme.lightTheme,
        home: const AppStartupPage(), // 使用新的启动页面，包含OAuth检测逻辑
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}