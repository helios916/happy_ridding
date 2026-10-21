import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_ridding/core/constants/app_constants.dart';
import 'package:happy_ridding/core/router/app_router.dart';
import 'package:happy_ridding/data/datasources/in_memory_database.dart';
import 'package:happy_ridding/data/models/track_point.dart';
import 'package:happy_ridding/data/repositories/auth_repository.dart';
import 'package:happy_ridding/data/repositories/ride_repository.dart';
import 'package:happy_ridding/data/repositories/user_repository.dart';
import 'package:happy_ridding/data/services/location_service.dart';
import 'package:happy_ridding/features/auth/pages/login_page.dart';
import 'package:happy_ridding/state/auth_provider.dart';
import 'package:happy_ridding/state/ride_provider.dart';
import 'package:happy_ridding/state/stats_provider.dart';
import 'package:provider/provider.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<TrackPoint?> currentPosition() async => null;

  @override
  Stream<TrackPoint> trackStream() => const Stream.empty();
}

AuthProvider _createAuth() => AuthProvider(
      repository: AuthRepository(
        userRepository: UserRepository(database: InMemoryDatabase.instance),
        database: InMemoryDatabase.instance,
      ),
    );

Widget _wrap({required AuthProvider auth, GoRouter? router}) {
  final config = router ?? createAppRouter(auth: auth);
  return MultiProvider(
    providers: [
      Provider<UserRepository>.value(value: UserRepository()),
      Provider<RideRepository>.value(value: RideRepository()),
      Provider<LocationService>.value(value: _FakeLocationService()),
      ChangeNotifierProvider<RideProvider>(
        create: (context) => RideProvider(
          locationService: context.read(),
          repository: context.read(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => StatsProvider(repository: context.read()),
      ),
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
    ],
    child: MaterialApp.router(routerConfig: config),
  );
}

Future<void> _pumpFrames(WidgetTester tester, {int times = 5}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() => InMemoryDatabase.instance.reset());

  test('内存凭证：demo 登录成功，密码错误被拒绝', () async {
    final auth = _createAuth();
    await auth.restore();
    expect(auth.isLoggedIn, isFalse);

    final ok = await auth.login(account: 'demo', password: '123456');
    expect(ok, isTrue);
    expect(auth.user?.nickname, '风一样的骑士');

    await auth.logout();
    expect(auth.isLoggedIn, isFalse);
    expect(await AuthRepository(userRepository: UserRepository()).currentUser(),
        isNull);

    final wrong = await auth.login(account: 'demo', password: 'bad');
    expect(wrong, isFalse);
    expect(auth.isLoggedIn, isFalse);
  });

  testWidgets('未登录访问任意主页面都会被拦到登录页', (tester) async {
    final auth = _createAuth();
    // 内存表带 60ms 模拟延迟，必须放在真实异步区执行。
    await tester.runAsync(auth.restore);
    final router = createAppRouter(auth: auth);

    await tester.pumpWidget(_wrap(auth: auth, router: router));
    await _pumpFrames(tester);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(router.state.matchedLocation, routeLogin);

    router.go('/leaderboard');
    await _pumpFrames(tester);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(router.state.matchedLocation, routeLogin);
  });

  testWidgets('登录成功后自动进入主页', (tester) async {
    final auth = _createAuth();
    await tester.runAsync(auth.restore);
    final router = createAppRouter(auth: auth);

    await tester.pumpWidget(_wrap(auth: auth, router: router));
    await _pumpFrames(tester);
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.runAsync(
      () => auth.login(account: 'demo', password: '123456'),
    );
    await _pumpFrames(tester, times: 10);

    expect(find.byType(LoginPage), findsNothing);
    expect(router.state.matchedLocation, AppConstants.routeRide);
    expect(find.text('开始骑行'), findsOneWidget);
  });
}
