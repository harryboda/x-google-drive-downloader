// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String?,
  tokenType: json['tokenType'] as String,
  expiresIn: AuthTokens._parseExpiresIn(json['expiresIn']),
  issuedAt: DateTime.parse(json['issuedAt'] as String),
  scope: json['scope'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'tokenType': instance.tokenType,
      'expiresIn': instance.expiresIn,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'scope': instance.scope,
    };
