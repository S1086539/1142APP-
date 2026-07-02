import 'package:flutter/material.dart';

class WeatherVisuals {
  final IconData icon;
  final List<Color> bgColors;
  final String animationPath;

  WeatherVisuals({required this.icon, required this.bgColors, this.animationPath = ""});

  static WeatherVisuals getVisuals(String description) {
    if (description.contains('雨')) {
      return WeatherVisuals(
          icon: Icons.umbrella,
          bgColors: [const Color(0xFF203A43), const Color(0xFF2C5364)]
      );
    } else if (description.contains('雲') || description.contains('陰')) {
      return WeatherVisuals(
          icon: Icons.cloud,
          bgColors: [const Color(0xFF616161), const Color(0xFF9BC5C3)]
      );
    } else {
      return WeatherVisuals(
          icon: Icons.wb_sunny,
          bgColors: [const Color(0xFF2980B9), const Color(0xFF6DD5FA)]
      );
    }
  }
}