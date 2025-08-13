import 'package:json_annotation/json_annotation.dart';

part 'drive_file.g.dart';

@JsonSerializable()
class DriveFile {
  final String id;
  final String name;
  final String mimeType;
  @JsonKey(fromJson: _parseSize)
  final int? size;

  /// 安全地解析 size 字段，处理字符串或数字类型
  static int? _parseSize(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null; // 无法解析时返回null而不是抛出异常
  }
  final String? webContentLink;
  final String? webViewLink;
  final List<String>? parents;
  final DateTime? modifiedTime;
  final DateTime? createdTime;
  
  // 文件夹相关
  bool get isFolder => mimeType == 'application/vnd.google-apps.folder';
  
  // 可下载文件
  bool get isDownloadable => webContentLink != null && !isFolder;
  
  // 格式化文件大小
  String get formattedSize {
    if (size == null) return '未知大小';
    
    const units = ['B', 'KB', 'MB', 'GB'];
    int bytes = size!;
    int unitIndex = 0;
    
    while (bytes >= 1024 && unitIndex < units.length - 1) {
      bytes ~/= 1024;
      unitIndex++;
    }
    
    return '$bytes ${units[unitIndex]}';
  }

  const DriveFile({
    required this.id,
    required this.name,
    required this.mimeType,
    this.size,
    this.webContentLink,
    this.webViewLink,
    this.parents,
    this.modifiedTime,
    this.createdTime,
  });

  factory DriveFile.fromJson(Map<String, dynamic> json) => _$DriveFileFromJson(json);
  Map<String, dynamic> toJson() => _$DriveFileToJson(this);

  DriveFile copyWith({
    String? id,
    String? name,
    String? mimeType,
    int? size,
    String? webContentLink,
    String? webViewLink,
    List<String>? parents,
    DateTime? modifiedTime,
    DateTime? createdTime,
  }) {
    return DriveFile(
      id: id ?? this.id,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      webContentLink: webContentLink ?? this.webContentLink,
      webViewLink: webViewLink ?? this.webViewLink,
      parents: parents ?? this.parents,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}