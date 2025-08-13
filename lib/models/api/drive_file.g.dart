// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriveFile _$DriveFileFromJson(Map<String, dynamic> json) => DriveFile(
  id: json['id'] as String,
  name: json['name'] as String,
  mimeType: json['mimeType'] as String,
  size: DriveFile._parseSize(json['size']),
  webContentLink: json['webContentLink'] as String?,
  webViewLink: json['webViewLink'] as String?,
  parents: (json['parents'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  modifiedTime: json['modifiedTime'] == null
      ? null
      : DateTime.parse(json['modifiedTime'] as String),
  createdTime: json['createdTime'] == null
      ? null
      : DateTime.parse(json['createdTime'] as String),
);

Map<String, dynamic> _$DriveFileToJson(DriveFile instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'mimeType': instance.mimeType,
  'size': instance.size,
  'webContentLink': instance.webContentLink,
  'webViewLink': instance.webViewLink,
  'parents': instance.parents,
  'modifiedTime': instance.modifiedTime?.toIso8601String(),
  'createdTime': instance.createdTime?.toIso8601String(),
};
