/// 用户信息。
class User {
  const User({
    required this.id,
    required this.nickname,
    this.email,
    this.avatarUrl,
    this.totalDistance = 0,
    this.totalRides = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        email: json['email'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0,
        totalRides: json['totalRides'] as int? ?? 0,
      );

  final String id;
  final String nickname;
  final String? email;
  final String? avatarUrl;

  /// 累计骑行距离，单位米。
  final double totalDistance;

  /// 累计骑行次数。
  final int totalRides;

  User copyWith({
    String? nickname,
    String? email,
    String? avatarUrl,
    double? totalDistance,
    int? totalRides,
  }) =>
      User(
        id: id,
        nickname: nickname ?? this.nickname,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        totalDistance: totalDistance ?? this.totalDistance,
        totalRides: totalRides ?? this.totalRides,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'email': email,
        'avatarUrl': avatarUrl,
        'totalDistance': totalDistance,
        'totalRides': totalRides,
      };
}
