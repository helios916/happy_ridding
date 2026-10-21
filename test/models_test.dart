import 'package:flutter_test/flutter_test.dart';
import 'package:happy_ridding/core/utils/format_utils.dart';
import 'package:happy_ridding/data/models/ride.dart';
import 'package:happy_ridding/data/models/track_point.dart';

void main() {
  test('Ride 序列化与反序列化保持数据一致', () {
    final ride = Ride(
      id: '1',
      startTime: DateTime(2026, 1, 1, 8),
      endTime: DateTime(2026, 1, 1, 9),
      distance: 15000,
      duration: const Duration(minutes: 50),
      track: [
        TrackPoint(
          latitude: 39.9,
          longitude: 116.4,
          timestamp: DateTime(2026, 1, 1, 8),
        ),
      ],
    );

    final restored = Ride.fromJson(ride.toJson());
    expect(restored.id, ride.id);
    expect(restored.distance, ride.distance);
    expect(restored.duration, ride.duration);
    expect(restored.track.length, 1);
  });

  test('平均速度按里程与时长计算', () {
    final ride = Ride(
      id: '2',
      startTime: DateTime(2026, 1, 1),
      distance: 1000,
      duration: const Duration(seconds: 100),
    );
    expect(ride.averageSpeed, closeTo(10, 0.001));
  });

  test('格式化工具输出符合预期', () {
    expect(FormatUtils.duration(const Duration(seconds: 3661)), '01:01:01');
    expect(FormatUtils.distance(1500), '1.50');
    expect(FormatUtils.speed(10), '36.0');
  });
}
