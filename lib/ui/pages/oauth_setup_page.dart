import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth/oauth_config_manager.dart';

/// OAuth设置引导页面
/// 为用户提供两种选择：使用内置凭据或自定义配置
class OAuthSetupPage extends StatefulWidget {
  final bool isFirstRun;
  
  const OAuthSetupPage({
    super.key,
    this.isFirstRun = false,
  });

  @override
  State<OAuthSetupPage> createState() => _OAuthSetupPageState();
}

class _OAuthSetupPageState extends State<OAuthSetupPage> with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isLoading = false;
  
  // 自定义配置表单
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildChoiceStep();
      case 2:
        return _buildCustomConfigStep();
      case 3:
        return _buildGoogleCloudGuideStep();
      default:
        return _buildWelcomeStep();
    }
  }

  /// 欢迎步骤
  Widget _buildWelcomeStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 应用图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_download,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 欢迎标题
                Text(
                  widget.isFirstRun ? '欢迎使用' : '重新配置',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'X Google Drive Downloader',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF007AFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 描述
                Text(
                  widget.isFirstRun 
                    ? '感谢选择我们的应用！\n为了连接到 Google Drive，我们需要配置认证信息。'
                    : '需要重新配置 Google Drive 认证信息。\n请选择适合您的配置方式。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF8E8E93),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // 开始按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _nextStep(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '开始配置',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 选择配置方式步骤
  Widget _buildChoiceStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮
          IconButton(
            onPressed: () => _previousStep(),
            icon: const Icon(Icons.arrow_back_ios),
            color: const Color(0xFF007AFF),
          ),
          const SizedBox(height: 16),
          
          // 标题
          Text(
            '选择配置方式',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请选择最适合您的认证配置方式',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: Column(
              children: [
                // 推荐选项：使用内置凭据
                _buildChoiceCard(
                  icon: Icons.rocket_launch,
                  title: '快速开始（推荐）',
                  subtitle: '使用内置认证配置',
                  description: '• 立即开始使用，无需额外设置\n• 适合个人用户和一般使用\n• 安全可靠，定期更新',
                  isRecommended: true,
                  onTap: () => _selectBuiltInConfig(),
                ),
                const SizedBox(height: 16),
                
                // 高级选项：自定义配置
                _buildChoiceCard(
                  icon: Icons.settings,
                  title: '自定义配置（高级）',
                  subtitle: '使用您自己的 Google Cloud 凭据',
                  description: '• 完全控制认证配置\n• 适合企业用户或开发者\n• 需要 Google Cloud Console 账户',
                  isRecommended: false,
                  onTap: () => _nextStep(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 配置选择卡片
  Widget _buildChoiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRecommended ? const Color(0xFF007AFF) : Colors.transparent,
          width: isRecommended ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRecommended ? const Color(0xFF007AFF) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isRecommended ? Colors.white : const Color(0xFF8E8E93),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D1D1F),
                              ),
                            ),
                            if (isRecommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '推荐',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 自定义配置步骤
  Widget _buildCustomConfigStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮
          IconButton(
            onPressed: () => _previousStep(),
            icon: const Icon(Icons.arrow_back_ios),
            color: const Color(0xFF007AFF),
          ),
          const SizedBox(height: 16),
          
          // 标题
          Text(
            '自定义 OAuth 配置',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '输入您的 Google Cloud OAuth 2.0 凭据',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 说明卡片
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF007AFF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '需要 Google Cloud Console 凭据',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1D1D1F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 13,
                                      ),
                                      children: [
                                        const TextSpan(text: '还没有凭据？'),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () => _nextStep(),
                                            child: const Text(
                                              '查看设置指南',
                                              style: TextStyle(
                                                color: Color(0xFF007AFF),
                                                fontSize: 13,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 客户端ID输入
                      Text(
                        'Client ID',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D1D1F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _clientIdController,
                        decoration: InputDecoration(
                          hintText: '例如：123456789-abcdef.apps.googleusercontent.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.content_paste, size: 20),
                            onPressed: () => _pasteFromClipboard(_clientIdController),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入 Client ID';
                          }
                          if (!value.contains('.apps.googleusercontent.com')) {
                            return 'Client ID 格式不正确';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // 客户端密钥输入
                      Text(
                        'Client Secret',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D1D1F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _clientSecretController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '输入 Client Secret',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.content_paste, size: 20),
                            onPressed: () => _pasteFromClipboard(_clientSecretController),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入 Client Secret';
                          }
                          if (value.length < 20) {
                            return 'Client Secret 长度不足';
                          }
                          return null;
                        },
                      ),
                      
                      const Spacer(),
                      
                      // 保存按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCustomConfig,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '保存配置',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Google Cloud 设置指南步骤
  Widget _buildGoogleCloudGuideStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮
          IconButton(
            onPressed: () => _previousStep(),
            icon: const Icon(Icons.arrow_back_ios),
            color: const Color(0xFF007AFF),
          ),
          const SizedBox(height: 16),
          
          // 标题
          Text(
            'Google Cloud 配置指南',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '按照以下步骤创建您的 OAuth 2.0 凭据',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 快速链接
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.open_in_new,
                            color: Color(0xFF007AFF),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '打开 Google Cloud Console',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _openGoogleCloudConsole(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('打开控制台'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 步骤说明
                    Expanded(
                      child: ListView(
                        children: [
                          _buildGuideStep(
                            '1',
                            '创建项目',
                            '在 Google Cloud Console 中创建新项目或选择现有项目',
                          ),
                          _buildGuideStep(
                            '2',
                            '启用 API',
                            '在"API 和服务" > "库"中启用 Google Drive API',
                          ),
                          _buildGuideStep(
                            '3',
                            '创建凭据',
                            '在"凭据"页面点击"创建凭据" > "OAuth 2.0 客户端 ID"',
                          ),
                          _buildGuideStep(
                            '4',
                            '配置客户端',
                            '选择"桌面应用程序"类型，设置名称',
                          ),
                          _buildGuideStep(
                            '5',
                            '获取凭据',
                            '下载 JSON 文件或复制 Client ID 和 Client Secret',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 返回配置按钮
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 2),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF007AFF)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '返回输入凭据',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === 事件处理方法 ===

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _selectBuiltInConfig() async {
    setState(() => _isLoading = true);
    
    try {
      await OAuthConfigManager.saveConfigChoice(ConfigChoice.useBuiltIn);
      if (mounted) {
        Navigator.of(context).pop(true); // 返回成功
      }
    } catch (e) {
      _showErrorSnackBar('配置失败：$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCustomConfig() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final success = await OAuthConfigManager.saveCustomCredentials(
        _clientIdController.text.trim(),
        _clientSecretController.text.trim(),
      );
      
      if (success) {
        await OAuthConfigManager.saveConfigChoice(ConfigChoice.useCustom);
        if (mounted) {
          Navigator.of(context).pop(true); // 返回成功
        }
      } else {
        _showErrorSnackBar('凭据格式不正确，请检查后重试');
      }
    } catch (e) {
      _showErrorSnackBar('保存失败：$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pasteFromClipboard(TextEditingController controller) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        controller.text = clipboardData!.text!;
      }
    } catch (e) {
      _showErrorSnackBar('粘贴失败');
    }
  }

  Future<void> _openGoogleCloudConsole() async {
    const url = 'https://console.cloud.google.com/apis/credentials';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showErrorSnackBar('无法打开链接');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}