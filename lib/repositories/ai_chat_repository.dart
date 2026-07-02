import 'dart:math';

import '../models/ai_trip_prompt_context.dart';

abstract class AIChatRepository {
  Stream<String> streamReply({
    required String text,
    AITripPromptContext? promptContext,
  });
}

class FakeAIChatRepository implements AIChatRepository {
  @override
  Stream<String> streamReply({
    required String text,
    AITripPromptContext? promptContext,
  }) async* {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (text.toLowerCase().contains('error') || text.contains('錯誤')) {
      throw Exception('Fake AI error');
    }

    final reply = _generateMockReply(
      text,
      promptContext,
    );

    for (final chunk in _splitText(reply, size: 5)) {
      await Future.delayed(
        const Duration(milliseconds: 35),
      );

      yield chunk;
    }
  }

  String _generateMockReply(
      String userText,
      AITripPromptContext? promptContext,
      ) {
    final weatherAdvice = _buildWeatherAdvice(promptContext);

    if (userText.contains('花蓮')) {
      return '''
我先幫你規劃一個花蓮兩天一夜的行程草稿：

Day 1
上午：七星潭海岸散步
下午：松園別館、將軍府周邊
晚上：東大門夜市

Day 2
上午：太魯閣或砂卡礑步道
下午：鯉魚潭或貨櫃星巴克
晚上：返回

天氣提醒：
如果午後降雨機率偏高，建議把海邊與步道安排在上午，下午改成室內景點或咖啡廳。
$weatherAdvice
''';
    }

    if (userText.contains('宜蘭')) {
      return '''
我可以先幫你安排宜蘭一日遊草稿：

上午：幾米公園、宜蘭市區散步
中午：在地小吃
下午：羅東林業文化園區或礁溪溫泉

雨天備案：
蘭陽博物館、觀光工廠、室內咖啡廳會比較適合親子行程。
$weatherAdvice
''';
    }

    if (userText.contains('臺南') || userText.contains('台南')) {
      return '''
臺南美食一日行程可以這樣安排：

上午：赤崁樓、國華街小吃
中午：牛肉湯、米糕、蝦仁飯
下午：孔廟、林百貨、神農街
晚上：花園夜市或海安路周邊

天氣提醒：
臺南白天較熱，建議中午安排室內用餐或咖啡廳休息，傍晚再走戶外路線。
$weatherAdvice
''';
    }

    return '''
我已收到你的需求。

目前這一版仍使用 FakeAIChatRepository 模擬 AI 串流回覆。下一版串接 Gemini/OpenAI 後，我會自動解析目的地、旅遊天數、偏好與天氣條件，產生完整行程。
$weatherAdvice
''';
  }

  String _buildWeatherAdvice(AITripPromptContext? promptContext) {
    final weather = promptContext?.destinationWeather;

    if (weather == null) {
      return '';
    }

    final cityName = promptContext?.destinationCity ?? weather.cityName;

    final base =
        '\n目的地天氣參考：$cityName 目前約 ${weather.temperature.toStringAsFixed(0)}°，'
        '${weather.description}，降雨機率 ${weather.rainChance}%。';

    if (weather.rainChance >= 60) {
      return '''
$base
建議：戶外景點盡量安排在上午，下午保留室內展館、咖啡廳或商圈作為雨天備案。
''';
    }

    if (weather.temperature >= 32 || weather.feelsLike >= 34) {
      return '''
$base
建議：中午避免長時間戶外曝曬，可安排室內用餐、展館或甜點店休息。
''';
    }

    if (weather.temperature <= 18) {
      return '''
$base
建議：氣溫偏低，行程可以保留較彈性的室內停留時間，並提醒攜帶外套。
''';
    }

    return '''
$base
建議：目前天氣條件適合一般戶外行程，但仍建議保留一個室內備案。
''';
  }

  List<String> _splitText(
      String text, {
        required int size,
      }) {
    final chars = text.runes
        .map((codePoint) => String.fromCharCode(codePoint))
        .toList();

    final chunks = <String>[];

    for (int i = 0; i < chars.length; i += size) {
      chunks.add(
        chars
            .sublist(
          i,
          min(i + size, chars.length),
        )
            .join(),
      );
    }

    return chunks;
  }
}