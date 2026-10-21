import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../widgets/empty_view.dart';
import '../widgets/leaderboard_tile.dart';

/// 骑行排行榜，数据来自 users 表的累计成绩。
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<User>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<UserRepository>().leaderboard();
  }

  Future<void> _reload() async {
    final future = context.read<UserRepository>().leaderboard();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('排行榜')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<User>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data ?? const <User>[];
            if (users.isEmpty) {
              return const EmptyView(message: '暂无排行数据');
            }
            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  LeaderboardTile(rank: index + 1, user: users[index]),
            );
          },
        ),
      ),
    );
  }
}
