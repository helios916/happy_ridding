import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/models/ride.dart';
import '../data/models/track_point.dart';
import '../data/repositories/ride_repository.dart';
import '../data/services/location_service.dart';

enum RideStatus { idle, recording, paused, finished }

/// 骑行记录状态机：采集轨迹、累计距离时长、暂停/结束并保存。
class RideProvider extends ChangeNotifier {
  RideProvider({
    required LocationService locationService,
    required RideRepository repository,
  })  : _locationService = locationService,
        _repository = repository;

  final LocationService _locationService;
  final RideRepository _repository;

  RideStatus _status = RideStatus.idle;
  DateTime? _startTime;
  Duration _duration = Duration.zero;
  double _distance = 0;
  double _currentSpeed = 0;
  final List<TrackPoint> _track = [];

  StreamSubscription<TrackPoint>? _subscription;
  Timer? _ticker;

  RideStatus get status => _status;
  Duration get duration => _duration;
  double get distance => _distance;
  double get currentSpeed => _currentSpeed;
  List<TrackPoint> get track => List.unmodifiable(_track);
  bool get isIdle => _status == RideStatus.idle;
  bool get isRecording => _status == RideStatus.recording;
  bool get isPaused => _status == RideStatus.paused;

  /// 开始或继续骑行。
  Future<void> start() async {
    if (_status == RideStatus.recording) return;

    if (_subscription == null) {
      final granted = await _locationService.ensurePermission();
      if (!granted) {
        throw StateError('未获得定位权限，无法开始记录');
      }
      _startTime = DateTime.now();
      _subscription = _locationService.trackStream().listen(_onPoint);
    }

    _status = RideStatus.recording;
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _duration += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    if (_status != RideStatus.recording) return;
    _status = RideStatus.paused;
    notifyListeners();
  }

  /// 结束本次骑行并写入 rides 表，返回生成的记录。
  Future<Ride?> finish() async {
    if (_status == RideStatus.idle) return null;

    final startTime = _startTime;
    if (startTime == null) {
      _reset();
      notifyListeners();
      return null;
    }

    // 先停掉采集并切换状态：关闭定位流可能要等平台回调，
    // 不能让它阻塞 UI 的状态恢复。
    final subscription = _subscription;
    _subscription = null;
    unawaited(subscription?.cancel());
    _ticker?.cancel();
    _ticker = null;
    _status = RideStatus.finished;
    notifyListeners();

    final ride = Ride(
      id: startTime.millisecondsSinceEpoch.toString(),
      startTime: startTime,
      endTime: DateTime.now(),
      distance: _distance,
      duration: _duration,
      track: List.of(_track),
    );

    await _repository.save(ride);
    _reset();
    notifyListeners();
    return ride;
  }

  void _onPoint(TrackPoint point) {
    if (_status != RideStatus.recording) return;

    if (_track.isNotEmpty) {
      final delta = _locationService.distanceBetween(_track.last, point);
      if (delta >= AppConstants.minMoveDistanceMeters) {
        _distance += delta;
        _track.add(point);
      }
    } else {
      _track.add(point);
    }

    _currentSpeed = point.speed ?? 0;
    notifyListeners();
  }

  void _reset() {
    _status = RideStatus.idle;
    _startTime = null;
    _duration = Duration.zero;
    _distance = 0;
    _currentSpeed = 0;
    _track.clear();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _ticker?.cancel();
    super.dispose();
  }
}
