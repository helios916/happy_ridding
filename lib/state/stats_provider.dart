import 'package:flutter/foundation.dart';

import '../data/models/ride.dart';
import '../data/repositories/ride_repository.dart';

/// 历史记录与统计汇总。
class StatsProvider extends ChangeNotifier {
  StatsProvider({required RideRepository repository}) : _repository = repository;

  final RideRepository _repository;

  List<Ride> _rides = const [];
  bool _loading = false;

  List<Ride> get rides => List.unmodifiable(_rides);
  bool get isLoading => _loading;
  bool get isEmpty => _rides.isEmpty;

  double get totalDistance =>
      _rides.fold<double>(0, (sum, ride) => sum + ride.distance);

  Duration get totalDuration => _rides.fold<Duration>(
        Duration.zero,
        (sum, ride) => sum + ride.duration,
      );

  int get totalRides => _rides.length;

  /// 近 7 天每日骑行距离（米），索引 0 为最早一天。
  List<double> get last7DaysDistance {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - index));
      return _rides
          .where((ride) =>
              ride.startTime.year == day.year &&
              ride.startTime.month == day.month &&
              ride.startTime.day == day.day)
          .fold<double>(0, (sum, ride) => sum + ride.distance);
    });
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _rides = await _repository.findAll();
    _loading = false;
    notifyListeners();
  }
}
