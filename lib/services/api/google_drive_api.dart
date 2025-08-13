import 'package:dio/dio.dart';
import '../../models/api/drive_file.dart';
import '../../models/api/drive_files_list.dart';

class GoogleDriveApi {
  static const String baseUrl = 'https://www.googleapis.com/drive/v3';
  static const String uploadUrl = 'https://www.googleapis.com/upload/drive/v3';
  
  final Dio _dio;

  GoogleDriveApi(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  /// 获取文件信息
  Future<DriveFile> getFileInfo(String fileId) async {
    final response = await _dio.get(
      '/files/$fileId',
      queryParameters: {
        'fields': 'id,name,mimeType,size,webContentLink,webViewLink,parents,modifiedTime,createdTime',
      },
    );
    
    return DriveFile.fromJson(response.data);
  }

  /// 列出文件夹中的文件
  Future<DriveFilesList> listFiles({
    String? folderId,
    String? pageToken,
    int pageSize = 100,
    String? query,
  }) async {
    final queryParams = <String, dynamic>{
      'pageSize': pageSize,
      'fields': 'nextPageToken,files(id,name,mimeType,size,webContentLink,webViewLink,parents,modifiedTime,createdTime)',
    };

    if (pageToken != null) {
      queryParams['pageToken'] = pageToken;
    }

    // 构建查询条件
    final queryConditions = <String>[];
    
    if (folderId != null) {
      queryConditions.add('"$folderId" in parents');
    }
    
    queryConditions.add('trashed = false');
    
    if (query != null && query.isNotEmpty) {
      queryConditions.add('name contains "$query"');
    }

    queryParams['q'] = queryConditions.join(' and ');

    final response = await _dio.get('/files', queryParameters: queryParams);
    return DriveFilesList.fromJson(response.data);
  }

  /// 递归获取文件夹中的所有文件
  Future<List<DriveFile>> listAllFilesRecursively(String folderId) async {
    final allFiles = <DriveFile>[];
    final foldersToProcess = <String>[folderId];

    while (foldersToProcess.isNotEmpty) {
      final currentFolderId = foldersToProcess.removeAt(0);
      String? pageToken;

      do {
        final filesList = await listFiles(
          folderId: currentFolderId,
          pageToken: pageToken,
          pageSize: 1000, // 大批量获取
        );

        allFiles.addAll(filesList.files);

        // 将子文件夹添加到处理队列
        final subFolders = filesList.folders;
        for (final folder in subFolders) {
          foldersToProcess.add(folder.id);
        }

        pageToken = filesList.nextPageToken;
      } while (pageToken != null);
    }

    return allFiles;
  }

  /// 下载文件
  Future<Response<ResponseBody>> downloadFile(
    String fileId, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<ResponseBody>(
      '/files/$fileId',
      queryParameters: {'alt': 'media'},
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: false,
        validateStatus: (status) => status! < 400,
      ),
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }

  /// 获取文件夹统计信息
  Future<Map<String, dynamic>> getFolderStats(String folderId) async {
    final files = await listAllFilesRecursively(folderId);
    
    int totalFiles = 0;
    int totalFolders = 0;
    int totalSize = 0;

    for (final file in files) {
      if (file.isFolder) {
        totalFolders++;
      } else {
        totalFiles++;
        totalSize += file.size ?? 0;
      }
    }

    return {
      'totalFiles': totalFiles,
      'totalFolders': totalFolders,
      'totalSize': totalSize,
      'formattedSize': _formatBytes(totalSize),
    };
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }
}