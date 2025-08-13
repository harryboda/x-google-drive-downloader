import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../../models/api/drive_file.dart';
import '../../models/download_progress.dart';
import 'google_drive_api.dart';

class AdvancedDownloadService extends ChangeNotifier {
  final GoogleDriveApi _api;
  
  DownloadProgress _progress = DownloadProgress.initial;
  bool _isDownloading = false;
  bool _isPaused = false;
  final List<CancelToken> _cancelTokens = [];
  
  // 下载配置
  int maxConcurrentDownloads = 4;
  int retryAttempts = 3;
  Duration retryDelay = const Duration(seconds: 2);

  DownloadProgress get progress => _progress;
  bool get isDownloading => _isDownloading;
  bool get isPaused => _isPaused;

  AdvancedDownloadService(this._api);

  /// 开始下载文件夹
  Future<void> startDownload(String folderId, String destinationPath) async {
    if (_isDownloading) return;

    try {
      _setDownloading(true);
      _updateProgress(DownloadProgress.initial.copyWith(
        status: '正在获取文件夹信息...',
      ));

      // 获取文件夹信息
      final folderInfo = await _api.getFileInfo(folderId);
      _updateProgress(_progress.copyWith(
        status: '正在扫描文件夹内容...',
      ));

      // 递归获取所有文件
      final allFiles = await _api.listAllFilesRecursively(folderId);
      final downloadableFiles = allFiles.where((file) => file.isDownloadable).toList();

      if (downloadableFiles.isEmpty) {
        _handleError('文件夹中没有可下载的文件');
        return;
      }

      _updateProgress(_progress.copyWith(
        totalFiles: downloadableFiles.length,
        status: '开始下载 ${downloadableFiles.length} 个文件...',
      ));

      // 创建文件夹结构
      final targetPath = path.join(destinationPath, folderInfo.name);
      await _createFolderStructure(allFiles, targetPath, folderId);

      // 开始并发下载
      await _downloadFilesConcurrently(downloadableFiles, allFiles, targetPath, folderId);

      _updateProgress(_progress.copyWith(
        isComplete: true,
        status: '下载完成！共下载 ${downloadableFiles.length} 个文件',
      ));

    } catch (e) {
      _handleError('下载失败: $e');
    } finally {
      _setDownloading(false);
    }
  }

  /// 创建文件夹结构
  Future<void> _createFolderStructure(
    List<DriveFile> allFiles,
    String targetPath,
    String rootFolderId,
  ) async {
    final folders = allFiles.where((file) => file.isFolder).toList();
    final folderPaths = <String, String>{};
    folderPaths[rootFolderId] = targetPath;

    // 创建根目录
    await Directory(targetPath).create(recursive: true);

    // 递归创建子文件夹
    for (final folder in folders) {
      if (folder.parents != null && folder.parents!.isNotEmpty) {
        final parentId = folder.parents!.first;
        final parentPath = folderPaths[parentId];
        
        if (parentPath != null) {
          final folderPath = path.join(parentPath, folder.name);
          folderPaths[folder.id] = folderPath;
          await Directory(folderPath).create(recursive: true);
        }
      }
    }

    // 保存文件夹路径映射供下载时使用
    _folderPaths = folderPaths;
  }

  Map<String, String> _folderPaths = {};

  /// 并发下载文件
  Future<void> _downloadFilesConcurrently(
    List<DriveFile> downloadableFiles,
    List<DriveFile> allFiles,
    String targetPath,
    String rootFolderId,
  ) async {
    final downloadQueue = downloadableFiles.toList();
    final downloadTasks = <Future<void>>[];
    final semaphore = Semaphore(maxConcurrentDownloads);

    for (int i = 0; i < downloadableFiles.length; i++) {
      final file = downloadableFiles[i];
      
      final task = semaphore.acquire().then((_) async {
        try {
          await _downloadSingleFile(file, allFiles, targetPath, rootFolderId);
        } finally {
          semaphore.release();
        }
      });
      
      downloadTasks.add(task);
    }

    await Future.wait(downloadTasks);
  }

  /// 下载单个文件
  Future<void> _downloadSingleFile(
    DriveFile file,
    List<DriveFile> allFiles,
    String targetPath,
    String rootFolderId,
  ) async {
    if (_isPaused) {
      // 等待恢复
      while (_isPaused && _isDownloading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    if (!_isDownloading) return;

    // 确定文件保存路径
    String filePath = targetPath;
    
    if (file.parents != null && file.parents!.isNotEmpty) {
      final parentId = file.parents!.first;
      final parentPath = _folderPaths[parentId];
      if (parentPath != null) {
        filePath = parentPath;
      }
    }

    final fullFilePath = path.join(filePath, file.name);

    // 检查文件是否已存在
    final targetFile = File(fullFilePath);
    if (await targetFile.exists()) {
      final existingSize = await targetFile.length();
      if (file.size != null && existingSize == file.size) {
        // 文件已存在且大小匹配，跳过下载
        _incrementDownloadedFiles(file.name);
        return;
      }
    }

    // 下载文件（带重试机制）
    await _downloadWithRetry(file, fullFilePath);
  }

  /// 带重试机制的下载
  Future<void> _downloadWithRetry(DriveFile file, String filePath) async {
    for (int attempt = 0; attempt < retryAttempts; attempt++) {
      try {
        await _performDownload(file, filePath);
        _incrementDownloadedFiles(file.name);
        return;
      } catch (e) {
        if (attempt == retryAttempts - 1) {
          // 最后一次尝试失败
          debugPrint('下载失败 ${file.name}: $e');
          _incrementDownloadedFiles(file.name, failed: true);
          return;
        }
        
        // 等待后重试
        await Future.delayed(retryDelay * (attempt + 1));
      }
    }
  }

  /// 执行实际下载
  Future<void> _performDownload(DriveFile file, String filePath) async {
    final cancelToken = CancelToken();
    _cancelTokens.add(cancelToken);

    try {
      final response = await _api.downloadFile(
        file.id,
        onReceiveProgress: (received, total) {
          // 这里可以添加单个文件的进度更新
        },
        cancelToken: cancelToken,
      );

      final responseBody = response.data!;
      final targetFile = File(filePath);
      final sink = targetFile.openWrite();

      await responseBody.stream.listen(
        (data) {
          sink.add(data);
        },
        onDone: () => sink.close(),
        onError: (error) {
          sink.close();
          throw error;
        },
      ).asFuture();

    } finally {
      _cancelTokens.remove(cancelToken);
    }
  }

  /// 增加已下载文件计数
  void _incrementDownloadedFiles(String fileName, {bool failed = false}) {
    final newProgress = _progress.copyWith(
      downloadedFiles: _progress.downloadedFiles + 1,
      currentFile: fileName,
      percentage: _progress.totalFiles > 0 
          ? ((_progress.downloadedFiles + 1) / _progress.totalFiles * 100).toDouble()
          : 0.0,
    );

    _updateProgress(newProgress);
  }

  /// 暂停下载
  void pauseDownload() {
    if (_isDownloading && !_isPaused) {
      _isPaused = true;
      _updateProgress(_progress.copyWith(
        status: '下载已暂停',
      ));
      notifyListeners();
    }
  }

  /// 恢复下载
  void resumeDownload() {
    if (_isDownloading && _isPaused) {
      _isPaused = false;
      _updateProgress(_progress.copyWith(
        status: '正在下载...',
      ));
      notifyListeners();
    }
  }

  /// 取消下载
  void cancelDownload() {
    if (_isDownloading) {
      _setDownloading(false);
      
      // 取消所有正在进行的下载
      for (final token in _cancelTokens) {
        token.cancel('用户取消下载');
      }
      _cancelTokens.clear();

      _updateProgress(_progress.copyWith(
        status: '下载已取消',
      ));
    }
  }

  /// 重置状态
  void reset() {
    _progress = DownloadProgress.initial;
    _isDownloading = false;
    _isPaused = false;
    _cancelTokens.clear();
    _folderPaths.clear();
    notifyListeners();
  }

  void _updateProgress(DownloadProgress newProgress) {
    _progress = newProgress;
    notifyListeners();
  }

  void _setDownloading(bool downloading) {
    _isDownloading = downloading;
    if (!downloading) {
      _isPaused = false;
    }
    notifyListeners();
  }

  void _handleError(String error) {
    _updateProgress(_progress.copyWith(
      error: error,
      status: '下载失败',
    ));
    _setDownloading(false);
  }
}

/// 信号量实现，用于限制并发数量
class Semaphore {
  final int maxCount;
  int _currentCount = 0;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount);

  Future<void> acquire() async {
    if (_currentCount < maxCount) {
      _currentCount++;
      return;
    } else {
      final completer = Completer<void>();
      _waitQueue.add(completer);
      return completer.future;
    }
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount--;
    }
  }
}