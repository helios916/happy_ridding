import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happy_ridding/data/datasources/in_memory_database.dart';
import 'package:happy_ridding/data/models/ride.dart';
import 'package:happy_ridding/data/models/track_point.dart';
import 'package:happy_ridding/data/repositories/ride_repository.dart';
import 'package:happy_ridding/data/services/location_service.dart';
import 'package:happy_ridding/features/ride/pages/ride_page.dart';
import 'package:happy_ridding/features/ride/widgets/ride_control_bar.dart';
import 'package:happy_ridding/features/ride/widgets/ride_map.dart';
import 'package:happy_ridding/features/ride/widgets/ride_metrics_panel.dart';
import 'package:happy_ridding/state/ride_provider.dart';
import 'package:provider/provider.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<TrackPoint?> currentPosition() async => null;

  @override
  Stream<TrackPoint> trackStream() => const Stream.empty();
}

/// 只做内存记录，避免测试等待数据库延迟。
class _FakeRideRepository extends RideRepository {
  Ride? saved;

  @override
  Future<Ride> save(Ride ride) async {
    saved = ride;
    return ride;
  }
}

void main() {
  test('结束骑行会写入 rides 表', () async {
    await InMemoryDatabase.instance.reset();
    final provider = RideProvider(
      locationService: _FakeLocationService(),
      repository: RideRepository(),
    );

    await provider.start();
    expect(provider.isRecording, isTrue);

    final ride = await provider.finish();
    expect(ride, isNotNull);
    expect(provider.isIdle, isTrue);

    final persisted = await RideRepository().findById(ride!.id);
    expect(persisted?.id, ride.id);
  });

  testWidgets('地图不被指标面板遮挡且结束按钮可用', (tester) async {
    tester.view.physicalSize = const Size(1170, 2100); // 逻辑 390x700
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = _FakeRideRepository();
    final locationService = _FakeLocationService();
    final provider = RideProvider(
      locationService: locationService,
      repository: repo,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // 地图会读取定位服务来绘制「我的位置」圆点。
          Provider<LocationService>.value(value: locationService),
          ChangeNotifierProvider<RideProvider>.value(value: provider),
        ],
        child: const MaterialApp(home: RidePage()),
      ),
    );

    final screen = tester.getSize(find.byType(RidePage));
    final metricsRect = tester.getRect(find.byType(RideMetricsPanel));
    final controlRect = tester.getRect(find.byType(RideControlBar));
    final mapVisibleHeight =
        screen.height - metricsRect.height - controlRect.height;

    expect(tester.getRect(find.byType(RideMap)).height, screen.height);
    expect(metricsRect.height, lessThan(200));
    expect(mapVisibleHeight, greaterThan(300));

    await tester.tap(find.text('开始骑行'));
    await tester.pump();
    await tester.pump();
    expect(provider.isRecording, isTrue);
    expect(find.text('结束'), findsOneWidget);

    await tester.tap(find.text('结束'));
    await tester.pump();
    await tester.pump();
    expect(provider.isIdle, isTrue);
    expect(repo.saved, isNotNull);
  });
}
