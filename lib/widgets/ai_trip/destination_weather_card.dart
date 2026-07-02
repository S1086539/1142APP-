import 'package:flutter/material.dart';

import '../../models/weather.dart';
import '../common/glass_card.dart';

class DestinationWeatherCard extends StatelessWidget {
  final String cityName;
  final Weather? weather;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onClosePressed;

  const DestinationWeatherCard({
    super.key,
    required this.cityName,
    this.weather,
    this.isLoading = false,
    this.hasError = false,
    this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      blur: 16,
      opacity: 0.12,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.lightBlueAccent.withValues(alpha: 0.28),
              ),
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: Colors.lightBlueAccent,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: _buildContent(),
          ),

          if (onClosePressed != null) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: '隱藏目的地天氣',
              onPressed: onClosePressed,
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: Colors.white54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '正在取得 $cityName 天氣',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'AI 行程會參考目的地天氣狀況。',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      );
    }

    if (hasError || weather == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$cityName 天氣讀取失敗',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '稍後仍可產生行程，但可能不會包含完整天氣判斷。',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      );
    }

    final w = weather!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$cityName 目的地天氣',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: [
            _WeatherChip(
              icon: Icons.thermostat_rounded,
              text: '${w.temperature.toStringAsFixed(0)}°',
            ),
            _WeatherChip(
              icon: Icons.cloud_rounded,
              text: w.description,
            ),
            _WeatherChip(
              icon: Icons.umbrella_rounded,
              text: '降雨 ${w.rainChance}%',
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WeatherChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.lightBlueAccent,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}