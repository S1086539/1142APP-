import 'package:flutter/material.dart';

import '../../models/ai_stylist_result.dart';
import '../common/glass_card.dart';

class StylistResultCard extends StatelessWidget {
  final AIStylistResult result;

  const StylistResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      blur: 16,
      opacity: 0.13,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageArea(),
          const SizedBox(height: 16),
          Text(
            result.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '建議單品',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.outfitItems.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    if (result.hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.memory(
          result.imageBytes!,
          width: double.infinity,
          height: 330,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checkroom_rounded,
              size: 36,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Fake Stylist Result',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Gemini 模式下會替換成真正生成的穿搭圖片',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}