import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/stats_provider.dart';
import '../../../widgets/empty_view.dart';
import '../widgets/ride_list_tile.dart';

/// 历史骑行记录列表。
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('骑行记录')),
      body: RefreshIndicator(
        onRefresh: stats.load,
        child: stats.isEmpty
            ? const EmptyView(
                message: '还没有骑行记录，去骑一次吧',
                icon: Icons.directions_bike_outlined,
              )
            : ListView.separated(
                itemCount: stats.rides.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    RideListTile(ride: stats.rides[index]),
              ),
      ),
    );
  }
}
