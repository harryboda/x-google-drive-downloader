// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_files_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriveFilesList _$DriveFilesListFromJson(Map<String, dynamic> json) =>
    DriveFilesList(
      nextPageToken: json['nextPageToken'] as String?,
      files: (json['files'] as List<dynamic>)
          .map((e) => DriveFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      incompleteSearch: json['incompleteSearch'] as bool?,
    );

Map<String, dynamic> _$DriveFilesListToJson(DriveFilesList instance) =>
    <String, dynamic>{
      'nextPageToken': instance.nextPageToken,
      'files': instance.files,
      'incompleteSearch': instance.incompleteSearch,
    };
