import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 底部导航骨架：承载骑行、历史、统计、排行榜四个主页面。
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = [
    '/ride',
    '/history',
    '/stats',
    '/leaderboard',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _routes.indexOf(location).clamp(0, _routes.length - 1);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          // 各主页面共用右上角的个人中心入口
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.filledTonal(
                  tooltip: '个人中心',
                  onPressed: () => context.push('/profile'),
                  icon: const Icon(Icons.person_outline),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => context.go(_routes[value]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_bike_outlined),
            selectedIcon: Icon(Icons.directions_bike),
            label: '骑行',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: '排行榜',
          ),
        ],
      ),
    );
  }
}
