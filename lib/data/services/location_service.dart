import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/track_point.dart';

/// 封装设备定位能力：权限申请、位置流、距离计算。
class LocationService {
  /// 检查定位服务并申请权限，返回是否可用。
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// 持续的轨迹点流。
  Stream<TrackPoint> trackStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );
    return Geolocator.getPositionStream(locationSettings: settings).map(
      _toTrackPoint,
    );
  }

  /// 获取一次当前位置，用于地图上的定位圆点；不可用时返回 null。
  Future<TrackPoint?> currentPosition() async {
    try {
      if (!await ensurePermission()) return null;
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _toTrackPoint(position);
    } catch (_) {
      // 平台不支持（如 Web 无权限、测试环境）时静默忽略，不显示定位点。
      return null;
    }
  }

  TrackPoint _toTrackPoint(Position position) => TrackPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp,
        altitude: position.altitude,
        speed: position.speed,
        accuracy: position.accuracy,
      );

  /// 两点间球面距离，单位米。
  double distanceBetween(TrackPoint a, TrackPoint b) {
    return const Distance().as(
      LengthUnit.Meter,
      LatLng(a.latitude, a.longitude),
      LatLng(b.latitude, b.longitude),
    );
  }
}
