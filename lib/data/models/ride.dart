import 'track_point.dart';

/// 一次骑行记录。
class Ride {
  const Ride({
    required this.id,
    required this.startTime,
    required this.distance,
    required this.duration,
    this.endTime,
    this.track = const [],
  });

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] == null
            ? null
            : DateTime.parse(json['endTime'] as String),
        distance: (json['distance'] as num).toDouble(),
        duration: Duration(seconds: json['duration'] as int),
        track: (json['track'] as List<dynamic>? ?? const [])
            .map((e) => TrackPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final DateTime startTime;
  final DateTime? endTime;

  /// 累计距离，单位米。
  final double distance;

  /// 骑行时长（不含暂停）。
  final Duration duration;

  /// GPS 轨迹点。
  final List<TrackPoint> track;

  /// 平均速度，单位 m/s。
  double get averageSpeed =>
      duration.inSeconds == 0 ? 0 : distance / duration.inSeconds;

  Ride copyWith({
    DateTime? endTime,
    double? distance,
    Duration? duration,
    List<TrackPoint>? track,
  }) =>
      Ride(
        id: id,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        track: track ?? this.track,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'distance': distance,
        'duration': duration.inSeconds,
        'track': track.map((e) => e.toJson()).toList(),
      };
}
