import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/download_service.dart';
import '../../services/clipboard_service.dart';
import '../../services/auth/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/modern_progress_indicator.dart';
import '../widgets/animated_button.dart';
import '../widgets/clipboard_dialog.dart';
import 'oauth_settings_page.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 设置默认值
    _urlController.text = 'https://drive.google.com/drive/folders/1Exfub--2Bx2tt3IW89QqbrecK8BrXj9d?usp=share_link';
    _pathController.text = _getDefaultDownloadPath();
    
    // 启动剪贴板监听并设置监听器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initClipboardService();
    });
  }
  
  void _initClipboardService() {
    final clipboardService = Provider.of<ClipboardService>(context, listen: false);
    clipboardService.startMonitoring();
    
    // 监听剪贴板服务的变化
    clipboardService.addListener(_onClipboardDetection);
  }
  
  void _onClipboardDetection() {
    final clipboardService = Provider.of<ClipboardService>(context, listen: false);
    if (clipboardService.detectedGoogleDriveUrl != null) {
      _showClipboardDialog(clipboardService.detectedGoogleDriveUrl!);
    }
  }
  
  Future<void> _showClipboardDialog(String url) async {
    final result = await showClipboardDialog(context, url);
    final clipboardService = Provider.of<ClipboardService>(context, listen: false);
    
    if (result == true) {
      // 用户选择下载，填充URL输入框
      setState(() {
        _urlController.text = clipboardService.useDetectedUrl() ?? url;
      });
    } else {
      // 用户拒绝，清除检测到的URL
      clipboardService.clearDetectedUrl();
    }
  }

  @override
  void dispose() {
    final clipboardService = Provider.of<ClipboardService>(context, listen: false);
    clipboardService.removeListener(_onClipboardDetection);
    clipboardService.stopMonitoring();
    
    _urlController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  String _getDefaultDownloadPath() {
    // 获取用户的Downloads目录
    try {
      final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (homeDir != null) {
        return '$homeDir/Downloads';
      }
    } catch (e) {
      // 如果获取失败，使用备用路径
    }
    
    // 备用方案：使用当前用户名
    return '/Users/${Platform.environment['USER'] ?? 'user'}/Downloads';
  }

  Future<void> _selectDownloadPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _pathController.text = selectedDirectory;
      });
    }
  }

  void _startDownload() {
    final downloadService = Provider.of<DownloadService>(context, listen: false);
    
    if (_urlController.text.trim().isEmpty) {
      _showErrorSnackBar('请输入Google Drive文件夹链接');
      return;
    }

    if (_pathController.text.trim().isEmpty) {
      _showErrorSnackBar('请选择下载保存位置');
      return;
    }

    // 使用现有的下载服务
    downloadService.startDownload(
      _urlController.text.trim(),
      _pathController.text.trim(),
    );
  }

  String? _extractFolderId(String url) {
    final patterns = [
      RegExp(r'/folders/([a-zA-Z0-9_-]+)'),
      RegExp(r'id=([a-zA-Z0-9_-]+)'),
      RegExp(r'folder/d/([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '下载设置',
          style: AppTheme.headlineStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                '下载方式',
                style: AppTheme.bodyStyle,
              ),
              subtitle: Text(
                '当前: Google Drive API (OAuth认证)',
                style: AppTheme.captionStyle,
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            const Divider(),
            ListTile(
              title: Text(
                '应用版本',
                style: AppTheme.bodyStyle,
              ),
              subtitle: Text(
                'v2.0.0 - API直连版本',
                style: AppTheme.captionStyle,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '关闭',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _navigateToOAuthSettings() async {
    // 导航到OAuth设置页面
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const OAuthSettingsPage(),
      ),
    );
    
    // 如果配置发生了变化，可能需要重新认证
    if (result == true) {
      // 显示提示信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OAuth配置已更新，下次认证时将使用新配置'),
          backgroundColor: AppTheme.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Consumer<DownloadService>(
                  builder: (context, downloadService, child) {
                    // 暂时只使用旧服务，避免Provider依赖问题
                    final progress = downloadService.progress;
                    final isDownloading = downloadService.isDownloading;
                    return AnimatedGlassCard(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 标题区域
                          _buildHeader(),
                          
                          const SizedBox(height: 32),
                          
                          // URL输入区域
                          _buildUrlSection(),
                          
                          const SizedBox(height: 24),
                          
                          // 路径选择区域
                          _buildPathSection(),
                          
                          const SizedBox(height: 32),
                          
                          // 进度显示区域
                          ModernProgressIndicator(
                            progress: progress.percentage / 100,
                            currentFile: progress.currentFile,
                            totalFiles: progress.totalFiles,
                            downloadedFiles: progress.downloadedFiles,
                            isVisible: isDownloading || progress.isComplete,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 下载按钮
                          _buildDownloadButton(isDownloading, progress),
                          
                          // 状态信息
                          if (progress.error != null) ...[
                            const SizedBox(height: 24),
                            _buildErrorMessage(progress.error!),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<ClipboardService>(
      builder: (context, clipboardService, child) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.buttonShadow,
              ),
              child: const Icon(
                Icons.cloud_download_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'X Google Drive Downloader',
                    style: AppTheme.titleStyle,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '快速下载 Google Drive 文件夹到本地',
                        style: AppTheme.subtitleStyle,
                      ),
                      if (clipboardService.isMonitoring) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.content_paste,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '监听中',
                                style: AppTheme.captionStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 用户信息和设置按钮
            Consumer<AuthService>(
              builder: (context, authService, child) {
                final user = authService.userInfo;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (user != null) ...[
                      // 用户头像
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: user.picture != null
                            ? NetworkImage(user.picture!)
                            : null,
                        child: user.picture == null
                            ? Icon(
                                Icons.person,
                                color: AppTheme.primaryBlue,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // 用户名
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name ?? 'Unknown User',
                            style: AppTheme.captionStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user.email ?? 'No Email',
                            style: AppTheme.captionStyle.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    // 设置/登出按钮
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppTheme.primaryBlue,
                      ),
                      onSelected: (value) async {
                        switch (value) {
                          case 'logout':
                            await authService.signOut();
                            break;
                          case 'settings':
                            _showSettingsDialog();
                            break;
                          case 'oauth_settings':
                            _navigateToOAuthSettings();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 8),
                              Text('应用设置'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'oauth_settings',
                          child: Row(
                            children: [
                              Icon(Icons.key),
                              SizedBox(width: 8),
                              Text('OAuth设置'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('登出'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Google Drive 文件夹链接',
          style: AppTheme.headlineStyle,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: '粘贴 Google Drive 文件夹分享链接...',
            prefixIcon: Icon(Icons.link),
          ),
          style: AppTheme.bodyStyle,
        ),
        const SizedBox(height: 8),
        Text(
          '支持 Google Drive 文件夹分享链接',
          style: AppTheme.captionStyle,
        ),
      ],
    );
  }

  Widget _buildPathSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '下载保存位置',
          style: AppTheme.headlineStyle,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pathController,
                decoration: const InputDecoration(
                  hintText: '选择保存位置...',
                  prefixIcon: Icon(Icons.folder),
                ),
                style: AppTheme.bodyStyle,
                readOnly: true,
              ),
            ),
            const SizedBox(width: 12),
            SecondaryButton(
              text: '选择',
              icon: Icons.folder_open,
              onPressed: _selectDownloadPath,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadButton(bool isDownloading, dynamic progress) {
    String buttonText = '开始下载';
    IconData? buttonIcon = Icons.download_rounded;
    
    if (isDownloading) {
      buttonText = '下载中...';
      buttonIcon = null;
    } else if (progress.isComplete) {
      buttonText = '下载完成';
      buttonIcon = Icons.check_circle;
    }

    return AnimatedButton(
      text: buttonText,
      icon: buttonIcon,
      width: double.infinity,
      isLoading: isDownloading,
      onPressed: isDownloading ? null : _startDownload,
      gradientColors: progress.isComplete ? [
        AppTheme.successGreen,
        AppTheme.successGreen,
      ] : null,
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorRed,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}