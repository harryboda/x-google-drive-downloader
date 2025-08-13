import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:process_run/process_run.dart'; // 暂不使用
import '../models/folder_info.dart';

class GDriveService {
  static String? _gdriveExecutable;

  /// 获取 gdrive 可执行文件路径
  static Future<String?> _getGDriveExecutable() async {
    if (_gdriveExecutable != null) {
      return _gdriveExecutable;
    }

    // 尝试常见路径
    final possiblePaths = [
      '/opt/homebrew/bin/gdrive',
      '/usr/local/bin/gdrive',
      '/usr/bin/gdrive',
      'gdrive', // 系统PATH中
    ];

    for (final path in possiblePaths) {
      try {
        final result = await Process.run(path, ['version']);
        if (result.exitCode == 0) {
          _gdriveExecutable = path;
          return path;
        }
      } catch (e) {
        // 继续尝试下一个路径
      }
    }
    return null;
  }

  /// 检查 gdrive 是否已安装并配置
  static Future<bool> isGDriveAvailable() async {
    final executable = await _getGDriveExecutable();
    return executable != null;
  }

  /// 从URL提取文件夹ID
  static String extractFolderId(String url) {
    return FolderInfo.extractFolderId(url);
  }

  /// 获取文件夹信息
  static Future<FolderInfo> getFolderInfo(String folderId) async {
    try {
      final executable = await _getGDriveExecutable();
      if (executable == null) {
        throw Exception('gdrive 工具未找到');
      }

      final result = await Process.run(
        executable,
        ['files', 'info', folderId],
      );

      if (result.exitCode != 0) {
        throw Exception('无法获取文件夹信息: ${result.stderr}');
      }

      String folderName = 'Unknown Folder';
      final lines = result.stdout.toString().split('\n');
      
      for (final line in lines) {
        if (line.trim().startsWith('Name:')) {
          folderName = line.split(':')[1].trim();
          break;
        }
      }

      return FolderInfo(
        id: folderId,
        name: folderName,
        url: '', // URL will be set by caller
      );
    } catch (e) {
      throw Exception('获取文件夹信息失败: $e');
    }
  }

  /// 统计文件夹中的文件数量
  static Future<int> countFiles(String folderId) async {
    try {
      final executable = await _getGDriveExecutable();
      if (executable == null) {
        throw Exception('gdrive 工具未找到');
      }

      final result = await Process.run(
        executable,
        ['files', 'list', '--parent', folderId, '--max', '1000'],
      );

      if (result.exitCode != 0) {
        throw Exception('无法统计文件数量: ${result.stderr}');
      }

      final lines = result.stdout.toString().split('\n');
      // 减去标题行
      return lines.where((line) => line.trim().isNotEmpty).length - 1;
    } catch (e) {
      throw Exception('统计文件数量失败: $e');
    }
  }

  /// 下载文件夹
  static Future<void> downloadFolder({
    required String folderId,
    required String destinationPath,
    required Function(Map<String, dynamic>) onProgress,
    required Function(String) onError,
  }) async {
    try {
      // 确保目标目录存在
      final destinationDir = Directory(destinationPath);
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      final executable = await _getGDriveExecutable();
      if (executable == null) {
        throw Exception('gdrive 工具未找到');
      }

      // 启动 gdrive 下载进程
      final command = [executable, 'files', 'download', '--recursive', '--overwrite', '--destination', destinationPath, folderId];
      // print('Executing command: ${command.join(' ')}'); // 调试输出
      
      final process = await Process.start(
        executable,
        ['files', 'download', '--recursive', '--overwrite', '--destination', destinationPath, folderId],
        mode: ProcessStartMode.normal,
        environment: {
          'HOME': '/Users/xiong',
          'PATH': '/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin',
        },
      );

      int totalFiles = 0;
      int downloadedFiles = 0;

      // 监听进程输出
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        // print('gdrive stdout: $line'); // 调试输出

        if (line.trim().isEmpty) return;

        // 解析找到的文件总数
        final foundMatch = RegExp(r'Found (\d+) files').firstMatch(line);
        if (foundMatch != null) {
          totalFiles = int.parse(foundMatch.group(1)!);
          onProgress({
            'total_files': totalFiles,
            'downloaded_files': downloadedFiles,
            'current_file': '发现 $totalFiles 个文件',
            'percentage': 0.0,
            'is_complete': false,
          });
          return;
        }

        // 解析正在下载的文件
        if (line.contains('Downloading file')) {
          final fileMatch = RegExp(r"'([^']+)'").firstMatch(line);
          if (fileMatch != null) {
            downloadedFiles++;
            final currentFile = fileMatch.group(1)!;
            final fileName = currentFile.split('/').last;
            
            final percentage = totalFiles > 0 ? (downloadedFiles / totalFiles) * 100 : 0.0;
            
            onProgress({
              'total_files': totalFiles > downloadedFiles ? totalFiles : downloadedFiles,
              'downloaded_files': downloadedFiles,
              'current_file': fileName,
              'percentage': percentage,
              'is_complete': false,
            });
          }
          return;
        }

        // 解析下载完成
        final downloadedMatch = RegExp(r'Downloaded (\d+) files').firstMatch(line);
        if (downloadedMatch != null) {
          final finalCount = int.parse(downloadedMatch.group(1)!);
          onProgress({
            'total_files': finalCount,
            'downloaded_files': finalCount,
            'current_file': '下载完成',
            'percentage': 100.0,
            'is_complete': true,
          });
          return;
        }

        // 检查错误
        if (line.toLowerCase().contains('error') || 
            line.toLowerCase().contains('failed')) {
          onError('下载错误: $line');
          return;
        }
      });

      // 监听错误输出
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.trim().isNotEmpty) {
          onError('下载错误: $line');
        }
      });

      // 等待进程完成
      final exitCode = await process.exitCode;
      
      if (exitCode != 0) {
        onError('下载进程异常退出，退出码: $exitCode');
      }
      
    } catch (e) {
      onError('下载失败: $e');
    }
  }

  /// 验证Google Drive链接格式
  static bool isValidGoogleDriveUrl(String url) {
    try {
      extractFolderId(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取用户的Google Drive授权状态
  static Future<bool> checkAuthorization() async {
    try {
      final executable = await _getGDriveExecutable();
      if (executable == null) {
        return false;
      }

      final result = await Process.run(
        executable,
        ['about'],
      );
      // print('Authorization check: exitCode=${result.exitCode}'); // 调试输出
      return result.exitCode == 0;
    } catch (e) {
      // print('Authorization check failed: $e'); // 调试输出
      return false;
    }
  }
}