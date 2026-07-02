import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/hourly_data.dart';

class HourlyItem extends StatelessWidget {
  final HourlyData h;
  final bool isFirst;

  const HourlyItem(
      this.h, {
        super.key,
        this.isFirst = false,
      });

  @override
  Widget build(BuildContext context) {
    final icon = _getWeatherIcon(h.weather);

    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isFirst
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFirst
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isFirst ? '下一個小時' : _getDayLabel(h.time),
            style: TextStyle(
              fontSize: 10,
              color: isFirst ? Colors.white : Colors.white60,
              fontWeight: isFirst ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            DateFormat('HH:mm').format(h.time),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            icon,
            size: 26,
            color: Colors.white,
          ),
          Text(
            '${h.temperature.toStringAsFixed(0)}°',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime time) {
    final now = DateTime.now().toUtc().add(
      const Duration(hours: 8),
    );

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final targetDay = DateTime(
      time.year,
      time.month,
      time.day,
    );

    final diff = targetDay.difference(today).inDays;

    if (diff == 0) {
      return '今天';
    }

    if (diff == 1) {
      return '明天';
    }

    return DateFormat('MM/dd').format(time);
  }

  IconData _getWeatherIcon(String weather) {
    if (weather.contains('雷')) {
      return Icons.thunderstorm_rounded;
    }

    if (weather.contains('雨')) {
      return Icons.grain_rounded;
    }

    if (weather.contains('陰')) {
      return Icons.cloud_rounded;
    }

    if (weather.contains('雲')) {
      return Icons.wb_cloudy_rounded;
    }

    if (weather.contains('晴')) {
      return Icons.wb_sunny_rounded;
    }

    return Icons.wb_cloudy_rounded;
  }
}