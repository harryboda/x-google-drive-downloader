import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens.g.dart';

@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  @JsonKey(fromJson: _parseExpiresIn)
  final int expiresIn;
  final DateTime issuedAt;
  final String scope;

  /// 安全地解析 expiresIn 字段，处理字符串或数字类型
  static int _parseExpiresIn(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.parse(value);
    throw ArgumentError('无法解析 expiresIn 值: $value');
  }

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
    required this.scope,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);

  // 检查token是否即将过期（提前5分钟刷新）
  bool get isExpiringSoon {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    final now = DateTime.now();
    final timeToExpiry = expiryTime.difference(now);
    return timeToExpiry.inMinutes <= 5;
  }

  // 检查token是否已过期
  bool get isExpired {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }

  // 获取Authorization header值
  String get authorizationHeader => '$tokenType $accessToken';

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    String? scope,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      scope: scope ?? this.scope,
    );
  }
}