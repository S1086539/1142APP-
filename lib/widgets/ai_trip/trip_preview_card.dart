import 'package:flutter/material.dart';

import '../../models/trip_preview.dart';
import '../common/glass_card.dart';

class TripPreviewCard extends StatelessWidget {
  final TripPreview preview;
  final bool isConfirmed;
  final VoidCallback? onConfirmPressed;
  final VoidCallback? onStylistPressed;

  const TripPreviewCard({
    super.key,
    required this.preview,
    this.isConfirmed = false,
    this.onConfirmPressed,
    this.onStylistPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(17),
      borderRadius: 24,
      blur: 16,
      opacity: 0.13,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildMetaChips(),
          const SizedBox(height: 14),

          if (preview.days.isNotEmpty)
            _buildDaySchedule()
          else
            _buildHighlights(),

          const SizedBox(height: 14),
          _buildWeatherNote(),
          const SizedBox(height: 16),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.map_rounded,
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            preview.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (isConfirmed)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.32),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Colors.greenAccent,
                ),
                SizedBox(width: 4),
                Text(
                  '已確認',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetaChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InfoChip(
          icon: Icons.location_on_rounded,
          text: preview.destinationCity,
        ),
        _InfoChip(
          icon: Icons.calendar_month_rounded,
          text: preview.dayCount <= 1 ? '一日遊' : '${preview.dayCount} 天',
        ),
      ],
    );
  }

  Widget _buildDaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '行程預覽',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...preview.days.map(
              (day) => _DayBlock(day: day),
        ),
      ],
    );
  }

  Widget _buildHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '行程重點',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...preview.highlights.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: Colors.lightBlueAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.lightBlueAccent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.wb_cloudy_rounded,
            size: 18,
            color: Colors.lightBlueAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              preview.weatherNote,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onConfirmPressed,
            icon: Icon(
              isConfirmed
                  ? Icons.check_circle_rounded
                  : Icons.event_available_rounded,
            ),
            label: Text(
              isConfirmed ? '已確認' : '確認行程',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isConfirmed ? Colors.greenAccent : Colors.white,
              side: BorderSide(
                color: isConfirmed
                    ? Colors.greenAccent.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.22),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: onStylistPressed,
            icon: const Icon(Icons.checkroom_rounded),
            label: const Text('穿搭建議'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayBlock extends StatelessWidget {
  final TripPreviewDay day;

  const _DayBlock({
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day ${day.dayNumber}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.lightBlueAccent,
            ),
          ),
          const SizedBox(height: 9),
          ...day.slots.map(
                (slot) => _TimeSlotRow(slot: slot),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  final TripPreviewTimeSlot slot;

  const _TimeSlotRow({
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              slot.period,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              slot.displayText,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
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
            size: 15,
            color: Colors.white70,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}