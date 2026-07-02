import 'package:flutter/material.dart';

import '../../models/weather.dart';
import '../common/glass_card.dart';

class WeatherAlertCard extends StatelessWidget {
  final Weather weather;

  const WeatherAlertCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final alert = _buildAlert(weather);

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
              color: alert.color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: alert.color.withValues(alpha: 0.32),
              ),
            ),
            child: Icon(
              alert.icon,
              color: alert.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _WeatherAlert _buildAlert(Weather weather) {
    if (weather.rainChance >= 70) {
      return const _WeatherAlert(
        icon: Icons.umbrella_rounded,
        color: Colors.lightBlueAccent,
        title: '降雨機率偏高',
        message: '今日可能會下雨，外出前建議攜帶雨具，行程也可以預留室內備案。',
      );
    }

    if (weather.temperature >= 34 || weather.feelsLike >= 36) {
      return const _WeatherAlert(
        icon: Icons.wb_sunny_rounded,
        color: Colors.orangeAccent,
        title: '高溫提醒',
        message: '目前氣溫偏高，外出請注意防曬、補充水分，避免長時間曝曬。',
      );
    }

    if (weather.windSpeed >= 8) {
      return const _WeatherAlert(
        icon: Icons.air_rounded,
        color: Colors.cyanAccent,
        title: '風勢較強',
        message: '目前風速較明顯，外出騎車或前往空曠地區時請多加留意。',
      );
    }

    if (weather.humidity >= 85) {
      return const _WeatherAlert(
        icon: Icons.water_drop_rounded,
        color: Colors.lightBlueAccent,
        title: '濕度偏高',
        message: '空氣濕度較高，體感可能較悶熱，建議穿著透氣衣物。',
      );
    }

    if (weather.temperature <= 18) {
      return const _WeatherAlert(
        icon: Icons.ac_unit_rounded,
        color: Colors.cyanAccent,
        title: '低溫提醒',
        message: '目前氣溫偏低，外出時可以多加一件外套，注意保暖。',
      );
    }

    return const _WeatherAlert(
      icon: Icons.check_circle_rounded,
      color: Colors.greenAccent,
      title: '天氣狀況穩定',
      message: '目前天氣條件良好，適合安排外出活動。',
    );
  }
}

class _WeatherAlert {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _WeatherAlert({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });
}