import 'package:go_router/go_router.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/profile_page.dart';
import '../../features/history/pages/history_page.dart';
import '../../features/history/pages/stats_page.dart';
import '../../features/ride/pages/ride_page.dart';
import '../../features/social/pages/leaderboard_page.dart';
import '../../state/auth_provider.dart';
import '../../widgets/main_scaffold.dart';
import '../constants/app_constants.dart';

/// 登录页路由。
const String routeLogin = '/login';

/// 创建全局路由表，并挂载登录态守卫。
///
/// 未登录只会放行 [routeLogin]，登录后自动回到主页；登录态变化由
/// [AuthProvider] 通过 `refreshListenable` 触发重新鉴权。
GoRouter createAppRouter({required AuthProvider auth}) {
  return GoRouter(
    initialLocation: AppConstants.routeRide,
    refreshListenable: auth,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == routeLogin;
      if (!auth.isLoggedIn) {
        return loggingIn ? null : routeLogin;
      }
      return loggingIn ? AppConstants.routeRide : null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/ride',
            name: 'ride',
            builder: (context, state) => const RidePage(),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: '/stats',
            name: 'stats',
            builder: (context, state) => const StatsPage(),
          ),
          GoRoute(
            path: '/leaderboard',
            name: 'leaderboard',
            builder: (context, state) => const LeaderboardPage(),
          ),
        ],
      ),
      GoRoute(
        path: routeLogin,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
