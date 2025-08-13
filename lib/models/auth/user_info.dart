import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  final String? id;
  final String? email;
  final String? name;
  final String? picture;
  final bool? verifiedEmail;
  final String? locale;

  const UserInfo({
    this.id,
    this.email,
    this.name,
    this.picture,
    this.verifiedEmail,
    this.locale,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  // 获取显示名称
  String get displayName => name?.isNotEmpty == true ? name! : (email ?? 'Unknown User');

  // 获取头像URL（如果没有则返回默认头像）
  String get avatarUrl => picture ?? 'https://www.gravatar.com/avatar/${(email ?? 'unknown').hashCode}?d=mp';

  UserInfo copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    bool? verifiedEmail,
    String? locale,
  }) {
    return UserInfo(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      verifiedEmail: verifiedEmail ?? this.verifiedEmail,
      locale: locale ?? this.locale,
    );
  }
}