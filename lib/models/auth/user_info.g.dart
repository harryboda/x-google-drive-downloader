// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  id: json['id'] as String?,
  email: json['email'] as String?,
  name: json['name'] as String?,
  picture: json['picture'] as String?,
  verifiedEmail: json['verifiedEmail'] as bool?,
  locale: json['locale'] as String?,
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'picture': instance.picture,
  'verifiedEmail': instance.verifiedEmail,
  'locale': instance.locale,
};
