import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_button.dart';
import '../../config/app_config.dart';
import '../../services/auth/oauth_config_manager.dart';

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
  bool _isLoading = true;
  String _currentConfigSource = '';

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

  Future<void> _loadCurrentConfig() async {
    try {
      final credentials = await OAuthConfigManager.getCurrentCredentials();
      final configSource = await AppConfig.getConfigSource();
      
      setState(() {
        _currentConfigSource = configSource;
        if (credentials != null && credentials.source == 'custom') {
          _clientIdController.text = credentials.clientId;
          _clientSecretController.text = credentials.clientSecret;
          _isEditing = true;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentConfigSource = '获取失败';
      });
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      final success = await OAuthConfigManager.saveCustomCredentials(
        _clientIdController.text.trim(),
        _clientSecretController.text.trim(),
      );
      
      if (success) {
        await OAuthConfigManager.saveConfigChoice(ConfigChoice.useCustom);
        AppConfig.clearCredentialsCache();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OAuth配置保存成功'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _isEditing = false;
        });
        
        await _loadCurrentConfig();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OAuth配置保存失败，请检查格式'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetToBuiltIn() async {
    await OAuthConfigManager.saveConfigChoice(ConfigChoice.useBuiltIn);
    await OAuthConfigManager.clearCustomCredentials();
    AppConfig.clearCredentialsCache();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已重置为内置配置'),
        backgroundColor: Colors.green,
      ),
    );
    
    setState(() {
      _isEditing = false;
      _clientIdController.clear();
      _clientSecretController.clear();
    });
    
    await _loadCurrentConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: const Text('OAuth 设置'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 当前配置状态
                  _buildCurrentConfigCard(),
                  const SizedBox(height: 24),
                  
                  // 自定义配置表单
                  _buildCustomConfigCard(),
                  const SizedBox(height: 24),
                  
                  // 操作按钮
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  
                  // 帮助信息
                  _buildHelpCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentConfigCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCurrentConfigIcon(),
                color: _getCurrentConfigColor(),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '当前配置',
                style: AppTheme.headlineStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '配置来源: $_currentConfigSource',
            style: AppTheme.bodyStyle,
          ),
          const SizedBox(height: 8),
          if (_currentConfigSource == 'built-in') ...[
            Text(
              '✅ 使用内置安全凭据',
              style: AppTheme.bodyStyle.copyWith(color: Colors.green),
            ),
            Text(
              '零配置，开箱即用',
              style: AppTheme.captionStyle,
            ),
          ] else if (_currentConfigSource == 'custom') ...[
            Text(
              '⚙️ 使用自定义凭据',
              style: AppTheme.bodyStyle.copyWith(color: Colors.blue),
            ),
            Text(
              '您的Google Cloud项目凭据',
              style: AppTheme.captionStyle,
            ),
          ] else ...[
            Text(
              '❌ 配置未就绪',
              style: AppTheme.bodyStyle.copyWith(color: Colors.red),
            ),
            Text(
              '需要配置OAuth凭据',
              style: AppTheme.captionStyle,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomConfigCard() {
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '自定义配置',
                  style: AppTheme.headlineStyle,
                ),
                const Spacer(),
                Switch(
                  value: _isEditing,
                  onChanged: (value) {
                    setState(() {
                      _isEditing = value;
                      if (!value) {
                        _loadCurrentConfig();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Client ID
            TextFormField(
              controller: _clientIdController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Client ID',
                hintText: 'xxx-xxx.apps.googleusercontent.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_clientIdController.text),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入Client ID';
                }
                if (!value.endsWith('.apps.googleusercontent.com')) {
                  return 'Client ID格式不正确';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Client Secret
            TextFormField(
              controller: _clientSecretController,
              enabled: _isEditing,
              obscureText: !_showSecret,
              decoration: InputDecoration(
                labelText: 'Client Secret',
                hintText: '输入客户端密钥',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_showSecret ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showSecret = !_showSecret;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(_clientSecretController.text),
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入Client Secret';
                }
                if (value.length < 20) {
                  return 'Client Secret长度不足';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isEditing) ...[
          AnimatedButton(
            text: '保存配置',
            icon: Icons.save,
            width: double.infinity,
            onPressed: _saveConfig,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
              _loadCurrentConfig();
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('取消'),
          ),
        ] else ...[
          AnimatedButton(
            text: '编辑自定义配置',
            icon: Icons.edit,
            width: double.infinity,
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _resetToBuiltIn,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('重置为内置配置'),
        ),
      ],
    );
  }

  Widget _buildHelpCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '配置说明',
                style: AppTheme.headlineStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '• 内置配置：使用应用内置的安全凭据，零配置即可使用\n'
            '• 自定义配置：使用您自己的Google Cloud项目凭据\n'
            '• 如需创建自定义凭据，请访问Google Cloud Console\n'
            '• 应用类型请选择"桌面应用程序"',
            style: AppTheme.bodyStyle,
          ),
        ],
      ),
    );
  }

  IconData _getCurrentConfigIcon() {
    switch (_currentConfigSource) {
      case 'built-in':
        return Icons.security;
      case 'custom':
        return Icons.settings;
      default:
        return Icons.warning;
    }
  }

  Color _getCurrentConfigColor() {
    switch (_currentConfigSource) {
      case 'built-in':
        return Colors.green;
      case 'custom':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}