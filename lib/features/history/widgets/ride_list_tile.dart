import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/format_utils.dart';
import '../../../data/models/ride.dart';

/// 单条骑行记录列表项。
class RideListTile extends StatelessWidget {
  const RideListTile({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('yyyy-MM-dd HH:mm').format(ride.startTime);

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.directions_bike)),
      title: Text('${FormatUtils.distance(ride.distance)} km'),
      subtitle: Text(dateText),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(FormatUtils.duration(ride.duration)),
          Text(
            '${FormatUtils.speed(ride.averageSpeed)} km/h',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
