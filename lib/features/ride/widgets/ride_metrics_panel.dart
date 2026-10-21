import 'package:flutter/material.dart';

import '../../../core/utils/format_utils.dart';

/// 实时骑行指标面板：时长 / 距离 / 速度。
class RideMetricsPanel extends StatelessWidget {
  const RideMetricsPanel({
    super.key,
    required this.duration,
    required this.distance,
    required this.currentSpeed,
  });

  final Duration duration;
  final double distance;
  final double currentSpeed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            _Metric(label: '时长', value: FormatUtils.duration(duration)),
            _Metric(label: '距离(km)', value: FormatUtils.distance(distance)),
            _Metric(label: '速度(km/h)', value: FormatUtils.speed(currentSpeed)),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
