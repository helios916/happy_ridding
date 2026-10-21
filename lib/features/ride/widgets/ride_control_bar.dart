import 'package:flutter/material.dart';

import '../../../state/ride_provider.dart';

/// 骑行控制栏：开始 / 暂停 / 继续 / 结束。
class RideControlBar extends StatelessWidget {
  const RideControlBar({super.key, required this.provider});

  final RideProvider provider;

  Future<void> _handleStart(BuildContext context) async {
    try {
      await provider.start();
    } on StateError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _handleFinish(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ride = await provider.finish();
    if (ride == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '本次骑行 ${(ride.distance / 1000).toStringAsFixed(2)} km，已保存',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.isIdle)
              FilledButton.icon(
                onPressed: () => _handleStart(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始骑行'),
              )
            else ...[
              FilledButton.tonalIcon(
                onPressed: provider.isRecording
                    ? provider.pause
                    : () => _handleStart(context),
                icon: Icon(provider.isRecording ? Icons.pause : Icons.play_arrow),
                label: Text(provider.isRecording ? '暂停' : '继续'),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => _handleFinish(context),
                icon: const Icon(Icons.stop),
                label: const Text('结束'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
