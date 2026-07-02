import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/glass_card.dart';

class FavoriteWeatherCard extends StatelessWidget {
  final String cityName;
  final double? temperature;
  final String? description;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteWeatherCard({
    super.key,
    required this.cityName,
    required this.onTap,
    required this.onRemove,
    this.temperature,
    this.description,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      blur: 18,
      opacity: 0.13,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Row(
          children: [
            _buildCityInfo(),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWeatherInfo(),
            ),
            const SizedBox(width: 8),
            _buildRemoveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cityName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 14,
              color: Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat('HH:mm').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherInfo() {
    if (isLoading) {
      return const Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (hasError) {
      return const Align(
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.error_outline_rounded,
          color: Colors.orangeAccent,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${temperature?.toStringAsFixed(0) ?? '--'}°',
          style: const TextStyle(
            fontSize: 38,
            height: 1,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description ?? '讀取中',
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return IconButton(
      tooltip: '移除關注',
      onPressed: onRemove,
      icon: const Icon(
        Icons.close_rounded,
        color: Colors.white54,
      ),
    );
  }
}