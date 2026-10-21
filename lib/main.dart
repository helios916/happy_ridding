import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'data/datasources/in_memory_database.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/ride_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/location_service.dart';
import 'state/auth_provider.dart';
import 'state/ride_provider.dart';
import 'state/stats_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 演示环境用内存数据库代替真实 DB：建表 + 写入种子数据。
  final database = InMemoryDatabase.instance;
  await database.ensureSeeded();

  // 先恢复登录态再启动路由，避免启动瞬间被守卫弹回登录页。
  final authProvider = AuthProvider(
    repository: AuthRepository(
      userRepository: UserRepository(database: database),
      database: database,
    ),
  );
  await authProvider.restore();

  runApp(
    HappyRiddingBootstrap(database: database, authProvider: authProvider),
  );
}

/// 应用启动入口：集中声明依赖，便于后续替换为真实实现或注入 Mock。
class HappyRiddingBootstrap extends StatelessWidget {
  const HappyRiddingBootstrap({
    super.key,
    required this.database,
    required this.authProvider,
  });

  final InMemoryDatabase database;
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 数据源
        Provider<InMemoryDatabase>.value(value: database),
        Provider<ApiClient>(
          create: (_) => ApiClient(baseUrl: AppConstants.apiBaseUrl),
        ),

        // 设备能力
        Provider<LocationService>(create: (_) => LocationService()),

        // 数据仓库
        Provider<UserRepository>(
          create: (context) => UserRepository(database: context.read()),
        ),
        Provider<RideRepository>(
          create: (context) => RideRepository(database: context.read()),
        ),

        // 全局状态（AuthProvider 在 main 中提前构建，以便启动前恢复登录态）
        ChangeNotifierProvider(
          create: (context) => RideProvider(
            locationService: context.read(),
            repository: context.read(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(
          create: (context) => StatsProvider(repository: context.read())..load(),
        ),
      ],
      child: const HappyRiddingApp(),
    );
  }
}
