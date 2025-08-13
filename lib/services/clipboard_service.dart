import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'gdrive_service.dart';

class ClipboardService extends ChangeNotifier {
  Timer? _timer;
  String? _lastClipboardContent;
  String? _detectedGoogleDriveUrl;
  bool _isMonitoring = false;

  String? get detectedGoogleDriveUrl => _detectedGoogleDriveUrl;
  bool get isMonitoring => _isMonitoring;

  /// 开始监听剪贴板
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _checkClipboard();
    });
    notifyListeners();
  }

  /// 停止监听剪贴板
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _isMonitoring = false;
    notifyListeners();
  }

  /// 检查剪贴板内容
  Future<void> _checkClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final currentContent = clipboardData?.text?.trim();
      
      // 如果内容没有变化，跳过
      if (currentContent == null || 
          currentContent.isEmpty || 
          currentContent == _lastClipboardContent) {
        return;
      }
      
      _lastClipboardContent = currentContent;
      
      // 检查是否为Google Drive链接
      if (_isGoogleDriveUrl(currentContent)) {
        _detectedGoogleDriveUrl = currentContent;
        notifyListeners();
      }
    } catch (e) {
      // 忽略剪贴板访问错误
      if (kDebugMode) {
        print('Clipboard access error: $e');
      }
    }
  }

  /// 检查是否为Google Drive分享链接
  bool _isGoogleDriveUrl(String url) {
    try {
      return GDriveService.isValidGoogleDriveUrl(url);
    } catch (e) {
      return false;
    }
  }

  /// 清除检测到的URL
  void clearDetectedUrl() {
    _detectedGoogleDriveUrl = null;
    notifyListeners();
  }

  /// 使用检测到的URL
  String? useDetectedUrl() {
    final url = _detectedGoogleDriveUrl;
    clearDetectedUrl();
    return url;
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}