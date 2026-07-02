import 'package:flutter/material.dart';

import '../../models/weather.dart';
import '../common/glass_card.dart';

class HeroWeatherCard extends StatelessWidget {
  final Weather weather;
  final IconData icon;

  const HeroWeatherCard({
    super.key,
    required this.weather,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(22),
      borderRadius: 28,
      blur: 20,
      opacity: 0.14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationHeader(),
          const SizedBox(height: 24),
          _buildMainWeather(),
          const SizedBox(height: 20),
          _buildWeatherSummary(),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 20,
          color: Colors.white70,
        ),
        const SizedBox(width: 6),
        Text(
          weather.cityName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMainWeather() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            size: 58,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 72,
                  height: 0.95,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weather.description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          _SummaryItem(
            icon: Icons.umbrella_rounded,
            label: '降雨',
            value: '${weather.rainChance}%',
          ),
          _DividerLine(),
          _SummaryItem(
            icon: Icons.thermostat_rounded,
            label: '體感',
            value: '${weather.feelsLike.toStringAsFixed(0)}°',
          ),
          _DividerLine(),
          _SummaryItem(
            icon: Icons.water_drop_rounded,
            label: '濕度',
            value: '${weather.humidity}%',
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.lightBlueAccent,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}