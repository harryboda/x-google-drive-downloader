import 'package:json_annotation/json_annotation.dart';
import 'drive_file.dart';

part 'drive_files_list.g.dart';

@JsonSerializable()
class DriveFilesList {
  final String? nextPageToken;
  final List<DriveFile> files;
  final bool? incompleteSearch;

  const DriveFilesList({
    this.nextPageToken,
    required this.files,
    this.incompleteSearch,
  });

  factory DriveFilesList.fromJson(Map<String, dynamic> json) => _$DriveFilesListFromJson(json);
  Map<String, dynamic> toJson() => _$DriveFilesListToJson(this);

  // 是否有更多页面
  bool get hasMore => nextPageToken != null && nextPageToken!.isNotEmpty;
  
  // 获取所有文件夹
  List<DriveFile> get folders => files.where((file) => file.isFolder).toList();
  
  // 获取所有普通文件
  List<DriveFile> get regularFiles => files.where((file) => !file.isFolder).toList();
  
  // 获取可下载的文件
  List<DriveFile> get downloadableFiles => files.where((file) => file.isDownloadable).toList();
}