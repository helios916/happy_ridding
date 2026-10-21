/// 轨迹点：一次 GPS 采样的结果。
class TrackPoint {
  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
    this.accuracy,
  });

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        altitude: (json['altitude'] as num?)?.toDouble(),
        speed: (json['speed'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
      );

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  /// 海拔，单位米。
  final double? altitude;

  /// 瞬时速度，单位 m/s。
  final double? speed;

  /// 定位水平精度半径，单位米，用于绘制精度圈。
  final double? accuracy;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'altitude': altitude,
        'speed': speed,
        'accuracy': accuracy,
      };
}
