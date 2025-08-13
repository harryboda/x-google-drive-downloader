import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/download_progress.dart';
import '../models/api/drive_file.dart';
import 'auth/auth_service.dart';
import 'api/google_drive_api.dart';

class DownloadService extends ChangeNotifier {
  final AuthService _authService;
  GoogleDriveApi? _api;
  
  DownloadProgress _progress = DownloadProgress.initial;
  bool _isDownloading = false;

  DownloadService(this._authService) {
    _initializeApi();
  }

  void _initializeApi() {
    if (_authService.isAuthenticated) {
      _api = GoogleDriveApi(_authService.getAuthenticatedDio());
    }
  }

  DownloadProgress get progress => _progress;
  bool get isDownloading => _isDownloading;
  
  /// 安全地创建进度更新，确保类型正确
  void _safeUpdateProgress({
    int? totalFiles,
    int? downloadedFiles,
    String? currentFile,
    num? percentage,  // 接受num类型，内部转换为double
    bool? isComplete,
    String? status,
    String? error,
  }) {
    _updateProgress(_progress.copyWith(
      totalFiles: totalFiles,
      downloadedFiles: downloadedFiles,
      currentFile: currentFile,
      percentage: percentage?.toDouble(),
      isComplete: isComplete,
      status: status,
      error: error,
    ));
  }

  /// 开始下载
  Future<void> startDownload(String url, String destinationPath) async {
    if (_isDownloading) return;

    try {
      _setDownloading(true);
      _safeUpdateProgress(
        status: '正在验证认证状态...',
      );

      // 检查认证状态
      if (!_authService.isAuthenticated) {
        throw Exception('用户未登录。请先完成Google账户认证。');
      }

      // 初始化API（如果需要）
      if (_api == null) {
        _initializeApi();
      }

      if (_api == null) {
        throw Exception('Google Drive API初始化失败。请重新登录。');
      }

      // 验证链接格式并提取文件夹ID
      final folderId = _extractFolderId(url);
      if (folderId == null) {
        throw Exception('无效的 Google Drive 链接格式');
      }

      _safeUpdateProgress(
        status: '正在获取文件夹信息...',
      );

      // 获取所有文件（递归）
      final allFiles = await _api!.listAllFilesRecursively(folderId);
      final downloadableFiles = allFiles.where((file) => file.isDownloadable).toList();
      
      _safeUpdateProgress(
        totalFiles: downloadableFiles.length,
        status: '发现 ${downloadableFiles.length} 个可下载文件，开始下载...',
      );

      // 开始下载
      await _downloadFiles(downloadableFiles, destinationPath);

    } catch (e) {
      _handleError(e.toString());
    }
  }

  /// 提取Google Drive文件夹ID
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

  /// 下载文件列表
  Future<void> _downloadFiles(List<DriveFile> files, String destinationPath) async {
    int downloadedCount = 0;
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      
      try {
        _safeUpdateProgress(
          currentFile: file.name,
          downloadedFiles: downloadedCount,
          percentage: files.length > 0 ? (downloadedCount / files.length * 100).toDouble() : 0.0,
          status: '正在下载: ${file.name} (${downloadedCount + 1}/${files.length})',
        );

        // 创建目标文件路径
        final targetPath = path.join(destinationPath, file.name);
        final targetFile = File(targetPath);
        
        // 确保目录存在
        await targetFile.parent.create(recursive: true);
        
        // 下载文件
        final response = await _api!.downloadFile(file.id);
        
        // 将stream转换为字节
        final List<int> bytes = [];
        await for (final chunk in response.data!.stream) {
          bytes.addAll(chunk);
        }
        
        // 写入文件
        await targetFile.writeAsBytes(bytes);
        
        downloadedCount++;
        
      } catch (e) {
        debugPrint('下载文件失败: ${file.name}, 错误: $e');
        // 继续下载其他文件，不中断整个过程
      }
    }

    // 下载完成
    _safeUpdateProgress(
      downloadedFiles: downloadedCount,
      percentage: 100.0,
      isComplete: true,
      status: '下载完成！共下载 $downloadedCount 个文件',
    );
    
    _setDownloading(false);
  }

  /// 处理下载错误
  void _handleError(String error) {
    _safeUpdateProgress(
      error: error,
      status: '下载失败',
    );
    _setDownloading(false);
  }

  /// 更新进度
  void _updateProgress(DownloadProgress newProgress) {
    _progress = newProgress;
    notifyListeners();
  }

  /// 设置下载状态
  void _setDownloading(bool downloading) {
    _isDownloading = downloading;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _progress = DownloadProgress.initial;
    _isDownloading = false;
    notifyListeners();
  }

  /// 停止下载
  void stopDownload() {
    if (_isDownloading) {
      _setDownloading(false);
      _safeUpdateProgress(
        status: '已停止下载',
        error: '用户取消下载',
      );
    }
  }

  /// 清除错误
  void clearError() {
    if (_progress.error != null) {
      _safeUpdateProgress(error: null);
    }
  }

  /// 获取下载速度（文件/秒）
  double? getDownloadSpeed() {
    // 这里可以实现下载速度计算逻辑
    // 基于时间戳和已下载文件数量
    return null;
  }

  /// 获取预计剩余时间
  Duration? getEstimatedTimeRemaining() {
    // 这里可以实现剩余时间估算逻辑
    return null;
  }
}