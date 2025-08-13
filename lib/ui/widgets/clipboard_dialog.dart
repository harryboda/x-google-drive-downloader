import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'animated_button.dart';

class ClipboardDialog extends StatelessWidget {
  final String detectedUrl;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ClipboardDialog({
    super.key,
    required this.detectedUrl,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 400,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标和标题
              _buildHeader(),
              
              const SizedBox(height: 20),
              
              // URL显示
              _buildUrlDisplay(),
              
              const SizedBox(height: 24),
              
              // 操作按钮
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            Icons.content_paste,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '检测到 Google Drive 链接',
                style: AppTheme.headlineStyle,
              ),
              const SizedBox(height: 4),
              Text(
                '是否要下载此文件夹？',
                style: AppTheme.subtitleStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrlDisplay() {
    // 缩短显示的URL
    String displayUrl = detectedUrl;
    if (displayUrl.length > 60) {
      displayUrl = '${displayUrl.substring(0, 30)}...${displayUrl.substring(displayUrl.length - 20)}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '链接地址:',
            style: AppTheme.captionStyle,
          ),
          const SizedBox(height: 4),
          Text(
            displayUrl,
            style: AppTheme.bodyStyle.copyWith(
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: '忽略',
            icon: Icons.close,
            onPressed: onReject,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedButton(
            text: '立即下载',
            icon: Icons.download_rounded,
            onPressed: onAccept,
          ),
        ),
      ],
    );
  }
}

/// 显示剪贴板检测对话框
Future<bool?> showClipboardDialog(
  BuildContext context,
  String detectedUrl,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ClipboardDialog(
      detectedUrl: detectedUrl,
      onAccept: () => Navigator.of(context).pop(true),
      onReject: () => Navigator.of(context).pop(false),
    ),
  );
}