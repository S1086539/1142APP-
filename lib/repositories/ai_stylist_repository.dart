import '../models/ai_stylist_prompt_context.dart';
import '../models/ai_stylist_result.dart';

abstract class AIStylistRepository {
  Future<AIStylistResult> generateStylingImage({
    required AIStylistPromptContext context,
  });
}

class FakeAIStylistRepository implements AIStylistRepository {
  @override
  Future<AIStylistResult> generateStylingImage({
    required AIStylistPromptContext context,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    return AIStylistResult(
      title: _buildTitle(context),
      description: _buildDescription(context),
      outfitItems: _buildOutfitItems(context),
      imagePrompt: context.imagePrompt,
      imageUrl: null,
      createdAt: DateTime.now(),
    );
  }

  String _buildTitle(AIStylistPromptContext context) {
    return '${context.destinationCity} 旅行穿搭建議';
  }

  String _buildDescription(AIStylistPromptContext context) {
    return '根據你的 ${context.destinationCity} 行程、活動內容與天氣提醒，建議以舒適、好走、適合拍照的旅行穿搭為主。';
  }

  List<String> _buildOutfitItems(AIStylistPromptContext context) {
    final items = <String>[
      '舒適透氣上衣',
      '好走的休閒鞋',
      '小型斜背包',
    ];

    final text = [
      context.weatherNote,
      context.activitySummary,
      context.outfitSummary,
    ].join(' ');

    if (text.contains('雨') || text.contains('降雨')) {
      items.add('輕薄防水外套');
      items.add('摺疊傘');
    }

    if (text.contains('熱') || text.contains('高溫') || text.contains('曝曬')) {
      items.add('防曬外套或帽子');
      items.add('淺色透氣下身');
    }

    if (text.contains('冷') || text.contains('外套')) {
      items.add('薄外套或層次穿搭');
    }

    if (text.contains('夜市') || text.contains('小吃') || text.contains('美食')) {
      items.add('方便行走的輕便穿搭');
    }

    return items.toSet().toList();
  }
}