import 'package:flutter/material.dart';

class WeatherErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const WeatherErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08203E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orangeAccent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 38,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '天氣資料讀取失敗',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatErrorMessage(error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重新整理'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatErrorMessage(Object error) {
    final raw = error.toString();

    if (raw.contains('connection timeout') ||
        raw.contains('receive timeout') ||
        raw.contains('DioException')) {
      return '目前連線較不穩定，請確認網路後再試一次。';
    }

    if (raw.contains('找不到') || raw.contains('尚未支援')) {
      return '目前尚未取得此城市的天氣資料，請改選其他支援縣市。';
    }

    return '資料讀取時發生問題，請稍後再試。';
  }
}