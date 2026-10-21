import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/format_utils.dart';
import '../../../state/auth_provider.dart';
import '../../../state/stats_provider.dart';

/// 个人中心：用户信息、累计数据、退出登录。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const Center(
            child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              auth.user?.nickname ?? '未登录',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (!auth.isLoggedIn)
            Center(
              child: TextButton(
                onPressed: () => context.go(routeLogin),
                child: const Text('去登录'),
              ),
            ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('累计里程'),
            trailing: Text('${FormatUtils.distance(stats.totalDistance)} km'),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('累计时长'),
            trailing: Text(FormatUtils.duration(stats.totalDuration)),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('骑行次数'),
            trailing: Text('${stats.totalRides}'),
          ),
          const SizedBox(height: 24),
          if (auth.isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                // 退出后由路由守卫自动回到登录页。
                onPressed: auth.logout,
                child: const Text('退出登录'),
              ),
            ),
        ],
      ),
    );
  }
}
