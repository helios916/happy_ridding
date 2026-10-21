import 'package:flutter/material.dart';

import '../../../core/utils/format_utils.dart';
import '../../../data/models/user.dart';

/// 排行榜条目。
class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({super.key, required this.rank, required this.user});

  final int rank;
  final User user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('$rank')),
      title: Text(user.nickname),
      subtitle: Text('${user.totalRides} 次骑行'),
      trailing: Text(
        '${FormatUtils.distance(user.totalDistance, fractionDigits: 1)} km',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
