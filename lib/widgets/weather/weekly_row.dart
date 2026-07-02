import 'package:flutter/material.dart';

import '../../models/daily_forecast.dart';

class WeeklyRow extends StatelessWidget {
  final DailyForecast d;

  const WeeklyRow(
      this.d, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    final minTemp = d.minTemp;
    final maxTemp = d.maxTemp;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          _buildDay(),
          const SizedBox(width: 8),
          _buildRainChance(),
          const SizedBox(width: 12),
          _buildMinTemp(minTemp),
          const SizedBox(width: 8),
          Expanded(
            child: _TemperatureRangeBar(
              minTemp: minTemp,
              maxTemp: maxTemp,
            ),
          ),
          const SizedBox(width: 8),
          _buildMaxTemp(maxTemp),
        ],
      ),
    );
  }

  Widget _buildDay() {
    return SizedBox(
      width: 58,
      child: Text(
        d.day,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildRainChance() {
    return SizedBox(
      width: 58,
      child: Row(
        children: [
          const Icon(
            Icons.water_drop_rounded,
            size: 15,
            color: Colors.lightBlueAccent,
          ),
          const SizedBox(width: 3),
          Text(
            '${d.rainChance}%',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinTemp(double minTemp) {
    return SizedBox(
      width: 34,
      child: Text(
        '${minTemp.toStringAsFixed(0)}°',
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white60,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMaxTemp(double maxTemp) {
    return SizedBox(
      width: 34,
      child: Text(
        '${maxTemp.toStringAsFixed(0)}°',
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.orangeAccent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TemperatureRangeBar extends StatelessWidget {
  final double minTemp;
  final double maxTemp;

  const _TemperatureRangeBar({
    required this.minTemp,
    required this.maxTemp,
  });

  @override
  Widget build(BuildContext context) {
    const displayMin = 10.0;
    const displayMax = 40.0;
    const barHeight = 8.0;

    final leftRatio =
    ((minTemp - displayMin) / (displayMax - displayMin)).clamp(0.0, 1.0);

    final rightRatio =
    ((maxTemp - displayMin) / (displayMax - displayMin)).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        final left = totalWidth * leftRatio;
        final right = totalWidth * rightRatio;
        final activeWidth = (right - left).clamp(12.0, totalWidth);

        return SizedBox(
          height: 18,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Positioned(
                left: left,
                child: Container(
                  width: activeWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightBlueAccent.withValues(alpha: 0.85),
                        Colors.orangeAccent.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}