import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trip_preview.dart';
import '../../models/ai_stylist_prompt_context.dart';

import '../../services/ai_stylist_prompt_builder.dart';

import '../../providers/confirmed_trip_provider.dart';
import '../../providers/ai_stylist_provider.dart';

import '../../widgets/ai_stylist/stylist_result_card.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/app_snack_bar.dart';

class AIStylistPage extends ConsumerWidget {
  const AIStylistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmedTrip = ref.watch(confirmedTripProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF08203E),
      appBar: AppBar(
        title: const Text(
          'AI Stylist',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: confirmedTrip == null
          ? _buildEmptyView(context)
          : _buildConfirmedTripView(
        context,
        ref,
        confirmedTrip,
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: GlassCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(24),
          borderRadius: 28,
          blur: 18,
          opacity: 0.13,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checkroom_rounded,
                  size: 34,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '尚未確認行程',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '請先回到 AI 行程頁，產生並確認一份行程後，再使用 AI Stylist 產生穿搭建議。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('返回行程頁'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmedTripView(
      BuildContext context,
      WidgetRef ref,
      TripPreview trip,
      ) {
    final promptContext = AIStylistPromptBuilder.build(trip);
    final stylistState = ref.watch(aiStylistProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(trip),
          const SizedBox(height: 14),
          _buildTripSummaryCard(trip),
          const SizedBox(height: 14),
          _buildStyleDirectionCard(trip),
          const SizedBox(height: 14),

          if (stylistState.errorMessage != null)
            _buildErrorCard(stylistState.errorMessage!),

          if (stylistState.result != null) ...[
            StylistResultCard(
              result: stylistState.result!,
            ),
            const SizedBox(height: 14),
          ],

          _buildGenerateButton(
            context,
            ref,
            promptContext,
            stylistState,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(TripPreview trip) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(22),
      borderRadius: 28,
      blur: 18,
      opacity: 0.14,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orangeAccent.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.checkroom_rounded,
              size: 34,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '根據行程產生穿搭建議',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${trip.destinationCity}，${trip.dayCount <= 1 ? '一日遊' : '${trip.dayCount} 天行程'}',
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

  Widget _buildTripSummaryCard(TripPreview trip) {
    final slots = trip.days
        .expand((day) => day.slots)
        .take(10)
        .toList();

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      blur: 16,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '已確認行程摘要',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),

          if (slots.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                return _ActivityChip(
                  period: slot.period,
                  text: slot.place,
                );
              }).toList(),
            )
          else
            Column(
              children: trip.highlights.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        size: 17,
                        color: Colors.lightBlueAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStyleDirectionCard(TripPreview trip) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      blur: 16,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '穿搭判斷依據',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _StyleRuleRow(
            icon: Icons.location_on_rounded,
            title: '目的地',
            value: trip.destinationCity,
          ),
          const SizedBox(height: 10),
          _StyleRuleRow(
            icon: Icons.calendar_month_rounded,
            title: '行程天數',
            value: trip.dayCount <= 1 ? '一日遊' : '${trip.dayCount} 天',
          ),
          const SizedBox(height: 10),
          _StyleRuleRow(
            icon: Icons.wb_cloudy_rounded,
            title: '天氣提醒',
            value: trip.weatherNote,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(
      BuildContext context,
      WidgetRef ref,
      AIStylistPromptContext promptContext,
      AIStylistState stylistState,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: stylistState.isGenerating
            ? null
            : () async {
          await ref
              .read(aiStylistProvider.notifier)
              .generate(promptContext);

          if (!context.mounted) return;

          final latestState = ref.read(aiStylistProvider);

          if (latestState.errorMessage != null) {
            AppSnackBar.show(
              context,
              message: latestState.errorMessage!,
              type: AppSnackType.error,
            );
            return;
          }

          AppSnackBar.show(
            context,
            message: 'AI Stylist 穿搭建議已產生',
            type: AppSnackType.success,
          );
        },
        icon: stylistState.isGenerating
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.auto_awesome_rounded),
        label: Text(
          stylistState.isGenerating ? '生成中...' : '產生穿搭建議',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.black87,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.14),
          disabledForegroundColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        borderRadius: 20,
        blur: 14,
        opacity: 0.12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromptPreview(
      BuildContext context,
      AIStylistPromptContext promptContext,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          decoration: const BoxDecoration(
            color: Color(0xFF102A46),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'AI Stylist Prompt 預覽',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '下一步會把這段 prompt 送給圖片生成模型。',
                style: TextStyle(
                  color: Colors.white60,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    promptContext.imagePrompt,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    AppSnackBar.show(
                      context,
                      message: 'AI Stylist Prompt 已準備完成',
                      type: AppSnackType.success,
                    );
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('確認'),
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
          ),
        );
      },
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final String period;
  final String text;

  const _ActivityChip({
    required this.period,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            period,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
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

class _StyleRuleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StyleRuleRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.lightBlueAccent,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white60,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}