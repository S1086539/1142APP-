import 'package:flutter/material.dart';

import '../../models/weather.dart';
import 'info_box.dart';

class WeatherDetailGrid extends StatelessWidget {
  final Weather weather;

  const WeatherDetailGrid({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.45,
        children: [
          InfoBox(
            label: '降雨機率',
            value: '${weather.rainChance}%',
            icon: Icons.umbrella_rounded,
          ),
          InfoBox(
            label: '體感溫度',
            value: '${weather.feelsLike.toStringAsFixed(0)}°',
            icon: Icons.thermostat_rounded,
          ),
          InfoBox(
            label: '濕度',
            value: '${weather.humidity}%',
            icon: Icons.water_drop_rounded,
          ),
          InfoBox(
            label: '風速',
            value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
            icon: Icons.air_rounded,
          ),
        ],
      ),
    );
  }
}