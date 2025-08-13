import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_button.dart';
import '../../config/app_config.dart';

class OAuthSettingsPage extends StatefulWidget {
  const OAuthSettingsPage({super.key});

  @override
  State<OAuthSettingsPage> createState() => _OAuthSettingsPageState();
}

class _OAuthSettingsPageState extends State<OAuthSettingsPage> {
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isEditing = false;
  bool _showSecret = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  void _loadCurrentConfig() {
    // 如果当前使用自定义配置，显示当前值
    if (!AppConfig.isUsingDefault) {
      _clientIdController.text = AppConfig.clientId;
      _clientSecretController.text = AppConfig.clientSecret;
      _isEditing = true;
    }
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      AppConfig.setCustomOAuth(
        clientId: _clientIdController.text.trim(),
        clientSecret: _clientSecretController.text.trim(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OAuth配置已保存'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      Navigator.of(context).pop(true); // 返回true表示配置已更改
    }
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '重置为默认配置',
          style: AppTheme.headlineStyle,
        ),
        content: const Text(
          '确定要重置为内置的默认OAuth配置吗？\n\n'
          '这将清除您的自定义配置，并使用开发者提供的默认凭据。'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              AppConfig.resetToDefault();
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已重置为默认配置'),
                  backgroundColor: AppTheme.successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text(
              '确定重置',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
                child: AnimatedGlassCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        
                        const SizedBox(height: 32),
                        
                        _buildCurrentStatus(),
                        
                        const SizedBox(height: 32),
                        
                        _buildConfigSection(),
                        
                        const SizedBox(height: 32),
                        
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OAuth 高级设置',
                style: AppTheme.titleStyle,
              ),
              const SizedBox(height: 4),
              Text(
                '自定义Google Drive API凭据',
                style: AppTheme.subtitleStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.isUsingDefault 
            ? AppTheme.successGreen.withValues(alpha: 0.1)
            : AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConfig.isUsingDefault 
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : AppTheme.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppConfig.isUsingDefault ? Icons.check_circle : Icons.settings,
                color: AppConfig.isUsingDefault 
                    ? AppTheme.successGreen 
                    : AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '当前配置状态',
                style: AppTheme.headlineStyle.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '配置来源: ${AppConfig.configSource}',
            style: AppTheme.bodyStyle,
          ),
          if (AppConfig.isUsingDefault) ...[
            const SizedBox(height: 4),
            Text(
              '✅ 使用内置默认配置，无需额外设置即可使用',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.successGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '自定义配置 (高级用户)',
              style: AppTheme.headlineStyle,
            ),
            const Spacer(),
            Switch(
              value: _isEditing,
              onChanged: (value) {
                setState(() {
                  _isEditing = value;
                  if (!value) {
                    _clientIdController.clear();
                    _clientSecretController.clear();
                  }
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '如果您有自己的Google Cloud项目，可以使用自定义OAuth凭据',
          style: AppTheme.captionStyle,
        ),
        
        const SizedBox(height: 16),
        
        if (_isEditing) ...[
          // Client ID输入框
          Text(
            'Client ID',
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _clientIdController,
            decoration: InputDecoration(
              hintText: '输入您的Google OAuth Client ID',
              prefixIcon: const Icon(Icons.key),
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste, size: 20),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    _clientIdController.text = data!.text!;
                  }
                },
                tooltip: '粘贴',
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入Client ID';
              }
              if (!value.contains('.apps.googleusercontent.com')) {
                return 'Client ID格式不正确';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Client Secret输入框
          Text(
            'Client Secret',
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _clientSecretController,
            obscureText: !_showSecret,
            decoration: InputDecoration(
              hintText: '输入您的Google OAuth Client Secret',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.content_paste, size: 20),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        _clientSecretController.text = data!.text!;
                      }
                    },
                    tooltip: '粘贴',
                  ),
                  IconButton(
                    icon: Icon(
                      _showSecret ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showSecret = !_showSecret;
                      });
                    },
                    tooltip: _showSecret ? '隐藏' : '显示',
                  ),
                ],
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入Client Secret';
              }
              if (value.length < 10) {
                return 'Client Secret长度不正确';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 帮助链接
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 获取OAuth凭据:',
                  style: AppTheme.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1. 访问 Google Cloud Console\n'
                  '2. 创建项目并启用Drive API\n'
                  '3. 创建OAuth 2.0客户端ID\n'
                  '4. 复制Client ID和Secret',
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isEditing) ...[
          AnimatedButton(
            text: '保存配置',
            icon: Icons.save,
            onPressed: _saveConfig,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
        ],
        
        if (!AppConfig.isUsingDefault) ...[
          SecondaryButton(
            text: '重置为默认配置',
            icon: Icons.refresh,
            onPressed: _resetToDefault,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
        ],
        
        SecondaryButton(
          text: '返回',
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          width: double.infinity,
        ),
      ],
    );
  }
}