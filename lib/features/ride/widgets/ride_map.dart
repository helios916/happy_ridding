import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../data/models/track_point.dart';
import '../../../data/services/location_service.dart';

/// 骑行轨迹地图：地图底图 + 轨迹线 + 「我的位置」定位圆点。
class RideMap extends StatefulWidget {
  const RideMap({super.key, required this.track});

  final List<TrackPoint> track;

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  /// 默认中心点（北京天安门），拿到定位后会移动到实际位置。
  static const LatLng _fallbackCenter = LatLng(39.909, 116.397);

  /// OSM 底图可用的缩放范围。
  static const double _minZoom = 3;
  static const double _maxZoom = 19;

  final MapController _mapController = MapController();

  /// 未开始记录时展示的定位点。
  TrackPoint? _myPosition;
  bool _mapReady = false;
  bool _centered = false;

  /// 定位早于底图就绪时，先把目标位置暂存下来。
  LatLng? _pendingCenter;

  @override
  void initState() {
    super.initState();
    unawaited(_watchMyPosition());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _watchMyPosition() async {
    if (!mounted) return;
    final position = await context.read<LocationService>().currentPosition();
    if (!mounted || position == null) return;
    setState(() => _myPosition = position);
    _centerOn(position);
  }

  /// 记录开始后跟随轨迹的最新点。
  TrackPoint? get _currentPoint =>
      widget.track.isNotEmpty ? widget.track.last : _myPosition;

  void _centerOn(TrackPoint point) {
    if (_centered) return;
    final target = LatLng(point.latitude, point.longitude);
    if (!_mapReady) {
      _pendingCenter = target;
      return;
    }
    _centered = true;
    _mapController.move(target, _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.track
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    final current = _currentPoint;
    final currentLatLng =
        current == null ? null : LatLng(current.latitude, current.longitude);
    final accuracy = current?.accuracy ?? 0;
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: points.isEmpty ? _fallbackCenter : points.last,
            initialZoom: 16,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            // 保留滚轮缩放、双击放大、双指缩放与惯性拖动，仅禁用旋转。
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapReady: () {
              _mapReady = true;
              final pending = _pendingCenter;
              if (pending == null) return;
              _pendingCenter = null;
              _centered = true;
              _mapController.move(pending, _mapController.camera.zoom);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.happy_ridding',
            ),
            if (points.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 5,
                    color: primary,
                  ),
                ],
              ),
            if (currentLatLng != null && accuracy > 0)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: currentLatLng,
                    radius: accuracy,
                    useRadiusInMeter: true,
                    color: primary.withValues(alpha: 0.15),
                    borderColor: primary.withValues(alpha: 0.4),
                    borderStrokeWidth: 1,
                  ),
                ],
              ),
            if (currentLatLng != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLatLng,
                    width: 36,
                    height: 36,
                    child: _MyLocationDot(color: primary),
                  ),
                ],
              ),
          ],
        ),
        // 桌面端没有双指手势，补一组缩放按钮。
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: _ZoomControls(
              controller: _mapController,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
            ),
          ),
        ),
      ],
    );
  }
}

/// 缩放按钮：每次调整一级。
class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.controller,
    required this.minZoom,
    required this.maxZoom,
  });

  final MapController controller;
  final double minZoom;
  final double maxZoom;

  void _zoomBy(double delta) {
    final camera = controller.camera;
    final zoom = (camera.zoom + delta).clamp(minZoom, maxZoom);
    controller.move(camera.center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '放大',
            onPressed: () => _zoomBy(1),
            icon: const Icon(Icons.add),
          ),
          const Divider(height: 1),
          IconButton(
            tooltip: '缩小',
            onPressed: () => _zoomBy(-1),
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

/// 定位圆点：外圈光晕 + 白边实心点。
class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ),
    );
  }
}
