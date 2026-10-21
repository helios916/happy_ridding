import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/ride_provider.dart';
import '../widgets/ride_control_bar.dart';
import '../widgets/ride_map.dart';
import '../widgets/ride_metrics_panel.dart';

/// 骑行记录主页：地图铺满，指标与控制栏浮在地图之上。
class RidePage extends StatelessWidget {
  const RidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RideProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: RideMap(track: provider.track)),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              child: RideMetricsPanel(
                duration: provider.duration,
                distance: provider.distance,
                currentSpeed: provider.currentSpeed,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(child: RideControlBar(provider: provider)),
          ),
        ],
      ),
    );
  }
}
